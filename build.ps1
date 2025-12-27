#!/usr/bin/env pwsh

param(
    [ValidateSet("win64", "arm64")]
    [string]$Target = "win64"
)

Import-Module -Name "$PSScriptRoot/script/Utility"

function Get-VSWhere {
    $app = Get-Command -CommandType Application "vswhere" -ErrorAction SilentlyContinue
    if ($null -ne $app) {
        return  $app[0].Source
    }
    $vswhere = Join-Path ${env:ProgramFiles(x86)} -ChildPath "Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        return $vswhere
    }
    return $null
}

Function Invoke-BatchFile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,
        [string] $Arguments
    )
    Set-StrictMode -Version Latest
    $tempFile = [IO.Path]::GetTempFileName()

    cmd.exe /c " `"$Path`" $Arguments && set > `"$tempFile`" " | Out-Host
    ## Go through the environment variables in the temp file.
    ## For each of them, set the variable in our local environment.
    Get-Content $tempFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }
    Remove-Item $tempFile
}

Function FindCommand4GitDevs {
    param(
        [String]$Cmd
    )
    $gitexex = FindCommand -Name "git"
    if ($null -eq $gitexex) {
        Write-Host -ForegroundColor Red "Please install git-for-windows."
        return $null
    }
    $gitinstall = Split-Path -Parent (Split-Path -Parent $gitexex)
    if ([String]::IsNullOrEmpty($gitinstall)) {
        Write-Host -ForegroundColor Red "Please install git-for-windows."
        return $null
    }
    $cmdx = Join-Path $gitinstall "usr/bin/${Cmd}.exe"
    Write-Host "Try to find patch from $cmdx"
    if (!(Test-Path $cmdx)) {
        $xinstall = Split-Path -Parent $gitinstall
        if ([String]::IsNullOrEmpty($xinstall)) {
            Write-Host -ForegroundColor Red "Please install git-for-windows."
            return $null
        }
        $cmdx = Join-Path  $xinstall "usr/bin/${Cmd}.exe"
        if (!(Test-Path $cmdx)) {
            Write-Host -ForegroundColor Red "Please install git-for-windows."
            return $null
        }
    }
    return $cmdx
}

$targetTables = @{
    "win-x64@win64"   = "amd64";
    "win-x64@arm64"   = "amd64_arm64";
    "win-arm64@arm64" = "arm64";
    "win-arm64@win64" = "arm64_amd64";
}

$RID = [System.Runtime.InteropServices.RuntimeInformation]::RuntimeIdentifier # win-x64 win-arm64
$vscomponent = "Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
if ($Target -eq "arm64") {
    $vscomponent = "Microsoft.VisualStudio.Component.VC.Tools.ARM64"
}

$vsarch = $targetTables["$RID@$Target"]

$vswhere = Get-VSWhere
if ($null -eq $vswhere) {
    Write-Host -ForegroundColor Red "No vswhere installation found"
    exit 1
}

# vswhere -latest -prerelease -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$vsInstallDir = &$vswhere -latest  -products * -requires $vscomponent -property installationPath
if ([string]::IsNullOrEmpty($vsInstallDir)) {
    $vsInstallDir = &$vswhere -latest -prerelease -products * -requires $vscomponent -property installationPath
}
if ([string]::IsNullOrEmpty($vsInstallDir)) {
    Write-Host -ForegroundColor Red "No Visual Studio installation found."
    exit 1
}

$VisualCxxBatchFile = Join-Path $vsInstallDir -ChildPath "VC\Auxiliary\Build\vcvarsall.bat"

Write-Host "call `"$VisualCxxBatchFile`" $vsarch"

Invoke-BatchFile -Path $VisualCxxBatchFile -Arguments $vsarch

$clexe = Get-Command -CommandType Application "cl" -ErrorAction SilentlyContinue
if ($null -eq $clexe) {
    Write-Host -ForegroundColor Red "Not found cl.exe"
    exit 1
}
Write-Host "Find cl.exe: $($clexe.Version)"

$curlexe = FindCommand -Name "curl"
if ($null -eq $curlexe) {
    Write-Host -ForegroundColor Red "Please use the latest Windows release."
    exit 1
}
Write-Host -ForegroundColor Green "curl: $curlexe"

$cmakeExe = FindCommand -Name "cmake"
if ($null -eq $cmakeExe) {
    Write-Host -ForegroundColor Red "Please install cmake."
    exit 1
}
Write-Host -ForegroundColor Green "cmake: $cmakeExe"

$ninjaExe = FindCommand -Name "ninja"
if ($null -eq $ninjaExe) {
    Write-Host -ForegroundColor Red "Please install ninja."
    exit 1
}
Write-Host -ForegroundColor Green "ninja: $ninjaExe"

$patchExe = FindCommand4GitDevs -Cmd "patch"
if ($null -eq $patchExe) {
    $patchExe = FindCommand -Name "patch"
    if ($null -eq $patchExe) {
        Write-Host -ForegroundColor Red "Please install patch."
        exit 1
    }
}

Write-Host  -ForegroundColor Green "path: $patchExe"

$perlExe = FindCommand -Name "perl"

if ($null -eq $perlExe) {
    Write-Host -ForegroundColor Red "Please install perl (strawberryperl, activeperl).
    perl implementation must produce Windows like paths (with backward slash directory separators). "
    exit 1
}
Write-Host  -ForegroundColor Green "perl: $perlExe"


Function DecompressTar {
    param(
        [String]$URL,
        [String]$File,
        [String]$Hash
    )
    if (!(Test-Path $File)) {
        if (!(WinGet -URL $URL -O $File)) {
            return $false
        }
    }
    Write-Host "check sha256sum:  $File"
    $xhash = Get-FileHash -Algorithm SHA256 $File
    if ($xhash.Hash -ne $Hash) {
        Write-Host "Download $File checksum mismatch expected $Hash actual $($xhash.Hash)"
        Remove-Item -Force $File
        if (!(WinGet -URL $URL -O $File)) {
            return $false
        }
    }
    $xhash = Get-FileHash -Algorithm SHA256 $File
    if ($xhash.Hash -ne $Hash) {
        Write-Host "Download $File checksum mismatch expected $Hash actual $($xhash.Hash)"
        return $false
    }

    if ((Exec -FilePath $cmakeExe -Argv "-E tar -xf $File") -ne 0) {
        Write-Host -ForegroundColor Red "decompress $File failed"
        return $false
    }
    return $true
}


$RefName = StripPrefix "$env:REF_NAME" "refs/tags/" # remove prefix

if ($RefName.Length -eq 0) {
    $RefName = "dev"
}


Write-Host "build wincurl $RefName <$PSScriptRoot>"
$WD = "build"
if (![String]::IsNullOrEmpty($env:BUILD_DIR)) {
    $WD = $env:BUILD_DIR
}
$WD = Join-Path $PSScriptRoot $WD
if (!(MakeDirs -Dir $WD)) {
    exit 1
}

Set-Location $WD

Write-Host "build work directory $WD"

. "$PSScriptRoot/version.ps1"

Write-Host -ForegroundColor Green "compile curl $CURL_VERSION for $Target"

$BUILD_STAGE0_ROOT = (Join-Path $WD "cleanroot").Replace("\", "/")
$CURL_BUILD_ROOT = Join-Path $WD "out"
$CURL_DESTINATION = Join-Path $PSScriptRoot "destination"

Write-Host "we will deploy curl to: $CURLPrefix"


if (!(MakeDirs -Dir "$BUILD_STAGE0_ROOT/include")) {
    exit 1
}
if (!(MakeDirs -Dir "$BUILD_STAGE0_ROOT/lib")) {
    exit 1
}

if (!(MakeDirs -Dir $CURL_DESTINATION)) {
    exit 1
}

$env:INCLUDE = "$env:INCLUDE;$BUILD_STAGE0_ROOT/include"
$env:LIB = "$env:LIB;$BUILD_STAGE0_ROOT/lib"

if (!(DecompressTar -URL $ZSTD_URL -File "$ZSTD_FILE.tar.gz" -Hash $ZSTD_HASH)) {
    exit 1
}
if (!(DecompressTar -URL $BROTLI_URL -File "$BROTLI_FILE.tar.gz" -Hash $BROTLI_HASH)) {
    exit 1
}
if (!(DecompressTar -URL $ZLIBNG_URL -File "$ZLIBNG_FILE.tar.gz" -Hash $ZLIBNG_HASH)) {
    exit 1
}
if (!(DecompressTar -URL $OPENSSL_URL -File "$OPENSSL_FILE.tar.gz" -Hash $OPENSSL_HASH)) {
    exit 1
}
if (!(DecompressTar -URL $NGHTTP3_URL -File "$NGHTTP3_FILE.tar.xz" -Hash $NGHTTP3_HASH)) {
    exit 1
}
if (!(DecompressTar -URL $NGHTTP2_URL -File "$NGHTTP2_FILE.tar.xz" -Hash $NGHTTP2_HASH)) {
    exit 1
}
if (!(DecompressTar -URL $LIBSSH2_URL -File "$LIBSSH2_FILE.tar.gz" -Hash $LIBSSH2_HASH)) {
    exit 1
}
if (!(DecompressTar -URL $CURL_URL -File "$CURL_FILE.tar.xz" -Hash $CURL_HASH)) {
    exit 1
}

################################################## zlib-ng
$ZLIBNG_BUILD_DIR = Join-Path $PWD "$ZLIBNG_FILE/out"
if (!(MakeDirs -Dir $ZLIBNG_BUILD_DIR)) {
    exit 1
}

$zlibngOptions = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_PREFIX_PATH=$BUILD_STAGE0_ROOT`" `"-DCMAKE_INSTALL_PREFIX=$BUILD_STAGE0_ROOT`" "
$zlibngOptions += "-DCMAKE_MSVC_RUNTIME_LIBRARY=`"MultiThreaded$<$<CONFIG:Debug>:Debug>`" "
$zlibngOptions += "-DBUILD_SHARED_LIBS=OFF -DZLIB_COMPAT=ON -DBUILD_TESTING=OFF -WITH_GZFILEOP=OFF .."

$ec = Exec -FilePath $cmakeExe -Argv $zlibngOptions -WD $ZLIBNG_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib-ng: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "all" -WD $ZLIBNG_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib-ng: build error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "install" -WD $ZLIBNG_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib-ng: install error"
    exit 1
}

############################################################# zstd
Write-Host -ForegroundColor Yellow "Build zstd $ZSTD_VERSION"

$ZSTD_BUILD_DIR = Join-Path $WD "$ZSTD_FILE/build/cmake/out"
if (!(MakeDirs -Dir $ZSTD_BUILD_DIR)) {
    exit 1
}

$zstdOptions = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_PREFIX_PATH=$BUILD_STAGE0_ROOT`" `"-DCMAKE_INSTALL_PREFIX=$BUILD_STAGE0_ROOT`" "
$zstdOptions += "-DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_SHARED=OFF -DZSTD_LEGACY_SUPPORT=OFF -DZSTD_BUILD_PROGRAMS=OFF -DBUILD_TESTING=OFF -DZSTD_USE_STATIC_RUNTIME=ON .."

$ec = Exec -FilePath $cmakeExe -Argv $zstdOptions -WD $ZSTD_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "all" -WD $ZSTD_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: build error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "install" -WD $ZSTD_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: install error"
    exit 1
}

if (!(Test-Path "$BUILD_STAGE0_ROOT/lib/zstd.lib") -and (Test-Path "$BUILD_STAGE0_ROOT/lib/zstd_static.lib")) {
    Copy-Item -Force "$BUILD_STAGE0_ROOT/lib/zstd_static.lib" "$BUILD_STAGE0_ROOT/lib/zstd.lib" # copy to zstd.lib
}

# build brotli static
######################################################### Brotli
Write-Host -ForegroundColor Yellow "Build brotli $BROTLI_VERSION"
$BROTLI_BUILD_DIR = Join-Path $WD "$BROTLI_FILE/out"
if (!(MakeDirs -Dir $BROTLI_BUILD_DIR)) {
    exit 1
}
$brotliOptions = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_PREFIX_PATH=$BUILD_STAGE0_ROOT`" `"-DCMAKE_INSTALL_PREFIX=$BUILD_STAGE0_ROOT`" "
$brotliOptions += "-DCMAKE_MSVC_RUNTIME_LIBRARY=`"MultiThreaded$<$<CONFIG:Debug>:Debug>`" "
$brotliOptions += "-DBUILD_SHARED_LIBS=OFF -DBROTLI_BUILD_TOOLS=OFF -DBROTLI_DISABLE_TESTS=ON .."
$ec = Exec -FilePath $cmakeExe -Argv $brotliOptions -WD $BROTLI_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "all" -WD $BROTLI_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: build error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "install" -WD $BROTLI_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: install error"
    exit 1
}

##################################################### OpenSSL
Write-Host -ForegroundColor Yellow "Build OpenSSL $OPENSSL_VERSION"
$OPENSSL_SOURCE_DIR = Join-Path $WD $OPENSSL_FILE
# Update env
$env:INCLUDE = "$BUILD_STAGE0_ROOT/include;$env:INCLUDE"
$env:LIB = "$BUILD_STAGE0_ROOT/lib;$env:LIB"

$OPENSSL_ARCH = "VC-WIN64A"
if ($vsArch -eq "amd64_x86") {
    $OPENSSL_ARCH = "VC-WIN32"
}
elseif ($vsArch -eq "amd64_arm64") {
    $OPENSSL_ARCH = "VC-WIN64-ARM"
}

# perl Configure no-shared no-ssl3 enable-capieng -utf-8
$opensslOptions = "Configure no-shared no-legacy no-unit-test no-asm no-tests no-ssl3 enable-capieng -utf-8 "
$opensslOptions += "$OPENSSL_ARCH `"--prefix=$BUILD_STAGE0_ROOT`" "
$ec = Exec -FilePath $perlExe -Argv $opensslOptions -WD $OPENSSL_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "openssl: config error"
    exit 1
}

$ec = Exec -FilePath nmake -Argv "-f makefile build_libs" -WD $OPENSSL_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "openssl: build error"
    exit 1
}

$ec = Exec -FilePath nmake -Argv "-f makefile install_dev" -WD $OPENSSL_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "openssl: install_dev error"
    exit 1
}

######################################################### nghttp3
Write-Host -ForegroundColor Yellow "Build nghttp3 $NGHTTP3_VERSION"
$NGHTTP3_BUILD_DIR = Join-Path $WD "$NGHTTP3_FILE/out"
if (!(MakeDirs -Dir $NGHTTP3_BUILD_DIR)) {
    exit 1
}

$nghttp3Options = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_PREFIX_PATH=$BUILD_STAGE0_ROOT`" `"-DCMAKE_INSTALL_PREFIX=$BUILD_STAGE0_ROOT`" " 
$nghttp3Options += "-DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON -DENABLE_LIB_ONLY=ON -DENABLE_STATIC_CRT=ON .." 

$ec = Exec -FilePath $cmakeExe -Argv $nghttp3Options -WD $NGHTTP3_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp3: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "all" -WD $NGHTTP3_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp3: build error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "install" -WD $NGHTTP3_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp3: install error"
    exit 1
}

######################################################### nghttp2
Write-Host -ForegroundColor Yellow "Build nghttp2 $NGHTTP2_VERSION"
$NGHTTP2_BUILD_DIR = Join-Path $WD "$NGHTTP2_FILE/out"
if (!(MakeDirs -Dir $NGHTTP2_BUILD_DIR)) {
    exit 1
}

$nghttp2Options = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_INSTALL_PREFIX=${BUILD_STAGE0_ROOT}`" `"-DCMAKE_PREFIX_PATH=${BUILD_STAGE0_ROOT}`" "
$nghttp2Options += "-DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DENABLE_LIB_ONLY=ON -DENABLE_ASIO_LIB=OFF -DENABLE_STATIC_CRT=ON "
$nghttp2Options += "-DENABLE_OPENSSL=ON -DHAVE_SSL_IS_QUIC=ON .."

$ec = Exec -FilePath $cmakeExe -Argv $nghttp2Options -WD $NGHTTP2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "all" -WD $NGHTTP2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: build error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "install" -WD $NGHTTP2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: install error"
    exit 1
}


############################################################# Libssh2
Write-Host -ForegroundColor Yellow "Build libssh2 $LIBSSH2_VERSION"
$LIBSSH2_SOURCE_DIR = Join-Path $WD $LIBSSH2_FILE
$LIBSSH2_BUILD_DIR = Join-Path $LIBSSH2_SOURCE_DIR "build"
$LIBSSH2_PATCHH = Join-Path $PSScriptRoot "patch/libssh2.patch"
$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$LIBSSH2_PATCHH`"" -WD $LIBSSH2_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $LIBSSH2_PATCHH failed"
}
if (!(MakeDirs -Dir $LIBSSH2_BUILD_DIR)) {
    exit 1
}


$LIBSSH2_CFLAGS = "-DHAVE_EVP_AES_128_CTR=1"
$libssh2Options = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_INSTALL_PREFIX=$BUILD_STAGE0_ROOT`" `"-DCMAKE_PREFIX_PATH=${BUILD_STAGE0_ROOT}`" "
$libssh2Options += "-DBUILD_SHARED_LIBS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DENABLE_ZLIB_COMPRESSION=ON "
$libssh2Options += "-DCRYPTO_BACKEND=OpenSSL "
$libssh2Options += "-DENABLE_ZLIB_COMPRESSION=ON "
$libssh2Options += "-DCMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT=`"MultiThreaded$<$<CONFIG:Debug>:Debug>`" "
$libssh2Options += "`"-DCMAKE_C_FLAGS=${LIBSSH2_CFLAGS}`" .. " 
$ec = Exec -FilePath $cmakeExe -Argv $libssh2Options -WD $LIBSSH2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "all" -WD $LIBSSH2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: build error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "install" -WD $LIBSSH2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: install error"
    exit 1
}

############################################################## CURL

Write-Host -ForegroundColor Yellow "Final build curl $CURL_VERSION"

$CURL_SOURCE_DIR = Join-Path $WD "$CURL_FILE"
$CURL_BUILD_DIR = Join-Path $CURL_SOURCE_DIR "build"
$CURL_PATCH = Join-Path $PSScriptRoot "patch/curl.patch"
$CURL_ICON_FILE = Join-Path $PSScriptRoot "patch/curl.ico"

if (!(MakeDirs -Dir $CURL_BUILD_DIR)) {
    exit 1
}

# download curl-ca-bundle.crt

$CA_BUNDLE = Join-Path $CURL_SOURCE_DIR "curl-ca-bundle.crt"

if (!(WinGet -URL $CA_BUNDLE_URL -O $CA_BUNDLE)) {
    Write-Host -ForegroundColor Red "download curl-ca-bundle.crt  error"
}

# copy icon to path
Copy-Item $CURL_ICON_FILE -Destination "$CURL_SOURCE_DIR/src"-Force -ErrorAction SilentlyContinue

$ec = Exec -FilePath $patchExe -Argv "-Nbp1 -i `"$CURL_PATCH`"" -WD $CURL_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $CURL_PATCH failed"
}

$CURL_CFLAGS = "-DHAS_ALPN"
$options = "-GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DENABLE_UNICODE=ON -DBUILD_CURL_EXE=ON -DCURL_STATIC_CRT=ON -DCMAKE_RC_FLAGS=-c1252 -DCURL_TARGET_WINDOWS_VERSION=0x0A00 -DCURL_LTO=ON"
$options = "${options} -DBUILD_LIBCURL_DOCS=OFF -DENABLE_CURL_MANUAL=OFF -DUSE_LIBIDN2=OFF -DCURL_USE_LIBPSL=OFF"
# zstd
$options = "${options} -DCURL_ZSTD=ON"
# openssl-quic
$options = "${options} -DCURL_USE_OPENSSL=ON"
$options = "${options} -DCURL_DISABLE_OPENSSL_AUTO_LOAD_CONFIG=ON"
$CURL_CFLAGS = "${CURL_CFLAGS} -DHAVE_OPENSSL_SRP -DUSE_TLS_SRP"
# libssh2
$options = "${options} -DCURL_USE_LIBSSH2=ON"
# nghttp2
$options = "${options} -DUSE_NGHTTP2=ON"
$CURL_CFLAGS = "${CURL_CFLAGS} -DNGHTTP2_STATICLIB"
# nghttp3
$options = "${options} -DUSE_NGHTTP3=ON"
$CURL_CFLAGS = "${CURL_CFLAGS} -DNGHTTP3_STATICLIB"

$options = "${options} -DCURL_USE_OPENSSL=ON -DUSE_OPENSSL_QUIC=ON"
$options = "${options} `"-DCURL_CA_EMBED=$CA_BUNDLE`""
$options = "${options} `"-DCMAKE_C_FLAGS=${CURL_CFLAGS}`" `"-DCMAKE_INSTALL_PREFIX=$CURL_BUILD_ROOT`" `"-DCMAKE_PREFIX_PATH=${BUILD_STAGE0_ROOT}`"  .."

$ec = Exec -FilePath $cmakeExe -Argv $options -WD $CURL_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "all" -WD $CURL_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: build error"
    exit 1
}

$ec = Exec -FilePath $ninjaExe -Argv "install" -WD $CURL_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: install error"
    exit 1
}

Write-Host -ForegroundColor Green "curl: build completed"

$VersionName = $CURL_VERSION
if (!$RefName.StartsWith("refs/heads/")) {
    $VersionName = $RefName
}

$DestinationPath = "$CURL_DESTINATION/wincurl-${Target}-$VersionName.zip"
if (Test-Path $DestinationPath) {
    Remove-Item -Force $DestinationPath 
}
Compress-Archive -Path "$CURL_BUILD_ROOT/*" -DestinationPath $DestinationPath
$obj = Get-FileHash -Algorithm SHA256 $DestinationPath
$baseName = Split-Path -Leaf $DestinationPath
$hashtext = $obj.Algorithm + ":" + $obj.Hash.ToLower()
$hashtext | Out-File -Encoding utf8 -FilePath "$DestinationPath.sha256"
Write-Host "$baseName`n$hashtext"
