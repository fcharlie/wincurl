#!/usr/bin/env pwsh

param(
    [ValidateSet("win64", "arm64")]
    [string]$Target = "win64"
)

$targetLists = @{
    "win64" = "amd64";
    "arm64" = "amd64_arm64";
}

$MsvcTarget = $targetLists[$Target]

# TLS enable tls12/tls13
[enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -ge 'Tls12' } | ForEach-Object {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
}

Import-Module -Name "$PSScriptRoot/script/Utility"

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


Function Invoke-BatchFile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,
        [string] $ArgumentList
    )
    Set-StrictMode -Version Latest
    $tempFile = [IO.Path]::GetTempFileName()

    cmd.exe /c " `"$Path`" $argumentList && set > `"$tempFile`" " | Out-Host
    ## Go through the environment variables in the temp file.
    ## For each of them, set the variable in our local environment.
    Get-Content $tempFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
    }
    Remove-Item $tempFile
}

$vsinstalls = @(
    "$env:ProgramFiles/Microsoft Visual Studio/2022/Enterprise"
    "$env:ProgramFiles/Microsoft Visual Studio/2022/Community"
    "$env:ProgramFiles/Microsoft Visual Studio/2022/Professional"
    "$env:ProgramFiles/Microsoft Visual Studio/2022/BuildTools"
    "$env:ProgramFiles/Microsoft Visual Studio/2022/Preview"
)
$vsvars = ""

foreach ($vi in $vsinstalls) {
    if (Test-Path "$vi/VC/Auxiliary/Build/vcvarsall.bat") {
        $vsvars = "$vi/VC/Auxiliary/Build/vcvarsall.bat"
        break;
    }
}

if ($vsvars.Length -eq 0) {
    Write-Host "Not found visual studio installed."
    exit 1
}

Write-Host "We try run '$vsvars $MsvcTarget' and initialize environment."

Invoke-BatchFile -Path $vsvars -ArgumentList "$MsvcTarget" 

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

$cmakeexe = FindCommand -Name "cmake"
if ($null -eq $cmakeexe) {
    Write-Host -ForegroundColor Red "Please install cmake."
    exit 1
}
Write-Host -ForegroundColor Green "cmake: $cmakeexe"

$Ninjaexe = FindCommand -Name "ninja"
if ($null -eq $Ninjaexe) {
    Write-Host -ForegroundColor Red "Please install ninja."
    exit 1
}
Write-Host -ForegroundColor Green "ninja: $Ninjaexe"


$Patchexe = FindCommand4GitDevs -Cmd "patch"
if ($null -eq $Patchexe) {
    $Patchexe = FindCommand -Name "patch"
    if ($null -eq $Patchexe) {
        Write-Host -ForegroundColor Red "Please install patch."
        exit 1
    }
}

Write-Host  -ForegroundColor Green "path: $Patchexe"

$Perlexe = FindCommand -Name "perl"

if ($null -eq $Perlexe) {
    Write-Host -ForegroundColor Red "Please install perl (strawberryperl, activeperl).
    perl implementation must produce Windows like paths (with backward slash directory separators). "
    exit 1
}
Write-Host  -ForegroundColor Green "perl: $Perlexe"


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
    Write-Host "Get-FileHash  $File"
    $xhash = Get-FileHash -Algorithm SHA256 $File
    if ($xhash.Hash -ne $Hash) {
        Write-Host "download $File checksum mismatch expected $Hash actual $($xhash.Hash)"
        Remove-Item -Force $File
        if (!(WinGet -URL $URL -O $File)) {
            return $false
        }
    }
    $xhash = Get-FileHash -Algorithm SHA256 $File
    if ($xhash.Hash -ne $Hash) {
        Write-Host "download $File checksum mismatch expected $Hash actual $($xhash.Hash)"
        return $false
    }

    if ((Exec -FilePath $cmakeexe -Argv "-E tar -xvf $File") -ne 0) {
        Write-Host -ForegroundColor Red "Decompress $File failed"
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

$CLEAN_ROOT = (Join-Path $WD "cleanroot").Replace("\", "/")
$CURL_BUILD_ROOT = Join-Path $WD "out"
$CURL_DESTINATION = Join-Path $PSScriptRoot "destination"

Write-Host "we will deploy curl to: $CURLPrefix"

if (!(MakeDirs -Dir $CLEAN_ROOT)) {
    exit 1
}

if (!(MakeDirs -Dir $CURL_DESTINATION)) {
    exit 1
}

$env:INCLUDE = "$env:INCLUDE;$CLEAN_ROOT/include"
$env:LIB = "$env:LIB;$CLEAN_ROOT/lib"

############################################################# zstd
Write-Host -ForegroundColor Yellow "Build zstd $ZSTD_VERSION"
if (!(DecompressTar -URL $ZSTD_URL -File "$ZSTD_FILE.tar.gz" -Hash $ZSTD_HASH)) {
    exit 1
}

$ZSTD_SOURCE_DIR = Join-Path $WD $ZSTD_FILE
Write-Host -ForegroundColor Yellow "Apply zstd CMakeLists.txt ..."
$ZSTD_CMAKE = Join-Path $PSScriptRoot "cmake/zstd/CMakeLists.txt"
Copy-Item $ZSTD_CMAKE -Destination $ZSTD_SOURCE_DIR -Force

$zstd_options = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_INSTALL_PREFIX=$CLEAN_ROOT`" .."

$ZSTD_BUILD = Join-Path $ZSTD_SOURCE_DIR "out"
if (!(MakeDirs -Dir $ZSTD_BUILD)) {
    exit 1
}

$ec = Exec -FilePath $cmakeexe -Argv $zstd_options -WD $ZSTD_BUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $ZSTD_BUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $ZSTD_BUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: install error"
    exit 1
}

# build brotli static
######################################################### Brotli
Write-Host -ForegroundColor Yellow "Build brotli $BROTLI_VERSION"
if (!(DecompressTar -URL $BROTLI_URL -File "$BROTLI_FILE.tar.gz" -Hash $BROTLI_HASH)) {
    exit 1
}

$BROTLI_SOURCE_DIR = Join-Path $WD $BROTLI_FILE

Write-Host -ForegroundColor Yellow "Apply brotli CMakeLists.txt ..."
$BROTLI_CMAKE = Join-Path $PSScriptRoot "cmake/brotli/CMakeLists.txt"
Copy-Item $BROTLI_CMAKE -Destination $BROTLI_SOURCE_DIR -Force


$BROTLI_BUILD_DIR = Join-Path $BROTLI_SOURCE_DIR "out"
if (!(MakeDirs -Dir $BROTLI_BUILD_DIR)) {
    exit 1
}

$brotli_options = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_INSTALL_PREFIX=$CLEAN_ROOT`" .."


$ec = Exec -FilePath $cmakeexe -Argv $brotli_options -WD $BROTLI_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $BROTLI_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $BROTLI_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: install error"
    exit 1
}

################################################## zlib-ng
if (!(DecompressTar -URL $ZLIBNG_URL -File "$ZLIBNG_FILE.tar.gz" -Hash $ZLIBNG_HASH)) {
    exit 1
}

$ZLIBNG_SOURCE_DIR = Join-Path $PWD $ZLIBNG_FILE
$ZLIBNG_BUILD_DIR = Join-Path $ZLIBNG_SOURCE_DIR "out"
$ZLIBNG_PATCH = Join-Path $PSScriptRoot "patch/zlib-ng.patch"

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$ZLIBNG_PATCH`"" -WD $ZLIBNG_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $CURL_PATCH failed"
}

if (!(MakeDirs -Dir $ZLIBNG_BUILD_DIR)) {
    exit 1
}

$zlibng_options = "-GNinja -DCMAKE_BUILD_TYPE=Release `"-DCMAKE_INSTALL_PREFIX=$CLEAN_ROOT`""
$zlibng_options = "${zlibng_options} -DBUILD_SHARED_LIBS=OFF -DZLIB_COMPAT=ON -DZLIB_ENABLE_TESTS=OFF -WITH_GZFILEOP=OFF .."

$ec = Exec -FilePath $cmakeexe -Argv $zlibng_options -WD $ZLIBNG_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib-ng: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $ZLIBNG_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib-ng: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $ZLIBNG_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib-ng: install error"
    exit 1
}

##################################################### OpenSSL
Write-Host -ForegroundColor Yellow "Build OpenSSL $OPENSSL_VERSION"

if (!(DecompressTar -URL $OPENSSL_URL -File "$OPENSSL_FILE.tar.gz" -Hash $OPENSSL_HASH)) {
    exit 1
}

$OPENSSL_SOURCE_DIR = Join-Path $WD $OPENSSL_FILE

# Update env
$env:INCLUDE = "$CLEAN_ROOT/include;$env:INCLUDE"
$env:LIB = "$CLEAN_ROOT/lib;$env:LIB"

$OPENSSL_ARCH = "VC-WIN64A"
if ($vsArch -eq "amd64_x86") {
    $OPENSSL_ARCH = "VC-WIN32"
}
elseif ($vsArch -eq "amd64_arm64") {
    $OPENSSL_ARCH = "VC-WIN64-ARM"
}

# perl Configure no-shared no-ssl3 enable-capieng -utf-8

$openssl_options = "Configure no-shared no-legacy  no-unit-test no-asm no-tests no-ssl3 enable-capieng -utf-8"
$openssl_options = "${openssl_options} $OPENSSL_ARCH `"--prefix=$CLEAN_ROOT`" `"--$OPENSSL_SOURCE_DIR=$CLEAN_ROOT`""

$ec = Exec -FilePath $Perlexe -Argv $openssl_options -WD $OPENSSL_SOURCE_DIR
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
if (!(DecompressTar -URL $NGHTTP3_URL -File "$NGHTTP3_FILE.tar.xz" -Hash $NGHTTP3_HASH)) {
    exit 1
}

$NGHTTP3_SOURCE_DIR = Join-Path $WD $NGHTTP3_FILE
$NGHTTP3_BUILD_DIR = Join-Path $NGHTTP3_SOURCE_DIR "build"

if (!(MakeDirs -Dir $NGHTTP3_BUILD_DIR)) {
    exit 1
}

$nghttp3_options = "-GNinja -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON -DENABLE_LIB_ONLY=ON -DENABLE_STATIC_CRT=ON" 
$nghttp3_options = "${nghttp3_options} `"-DCMAKE_INSTALL_PREFIX=$CLEAN_ROOT`" .." 

$ec = Exec -FilePath $cmakeexe -Argv $nghttp3_options -WD $NGHTTP3_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp3: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $NGHTTP3_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp3: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $NGHTTP3_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp3: install error"
    exit 1
}

# ######################################################### ngtcp2
# Write-Host -ForegroundColor Yellow "Build ngtcp2 $NGTCP2_VERSION"
# if (!(DecompressTar -URL $NGTCP2_URL -File "$NGTCP2_FILE.tar.xz" -Hash $NGTCP2_HASH)) {
#     exit 1
# }

# $NGTCP2_SOURCE_DIR = Join-Path $WD $NGTCP2_FILE
# $NGTCP2_BUILD_DIR = Join-Path $NGTCP2_SOURCE_DIR "build"

# if (!(MakeDirs -Dir $NGTCP2_BUILD_DIR)) {
#     exit 1
# }

# $NGTCP2_PATCHH = Join-Path $PSScriptRoot "patch/ngtcp2.patch"
# $ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$NGTCP2_PATCHH`"" -WD $NGTCP2_SOURCE_DIR
# if ($ec -ne 0) {
#     Write-Host -ForegroundColor Red "Apply $NGTCP2_PATCHH failed"
# }

# $ngtcp2_options = "-GNinja -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON -DENABLE_LIB_ONLY=ON -DENABLE_STATIC_CRT=ON"
# $ngtcp2_options = "${ngtcp2_options} -DENABLE_OPENSSL=ON"
# $ngtcp2_options = "${ngtcp2_options} -DLIBEV_LIBRARY="
# $ngtcp2_options = "${ngtcp2_options} `"-DCMAKE_INSTALL_PREFIX=$CLEAN_ROOT`" `"-DCMAKE_PREFIX_PATH=${CLEAN_ROOT}`" .."

# $ec = Exec -FilePath $cmakeexe -Argv $ngtcp2_options -WD $NGTCP2_BUILD_DIR
# if ($ec -ne 0) {
#     Write-Host -ForegroundColor Red "ngtcp2: create build.ninja error"
#     exit 1
# }

# $ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $NGTCP2_BUILD_DIR
# if ($ec -ne 0) {
#     Write-Host -ForegroundColor Red "ngtcp2: build error"
#     exit 1
# }

# $ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $NGTCP2_BUILD_DIR
# if ($ec -ne 0) {
#     Write-Host -ForegroundColor Red "ngtcp2: install error"
#     exit 1
# }

# # FIXME: ngtcp2 no ENABLE_STATIC_LIB
# Move-Item -Path "$CLEAN_ROOT/lib/ngtcp2_static.lib"   "$CLEAN_ROOT/lib/ngtcp2.lib"  -Force -ErrorAction SilentlyContinue
# Move-Item -Path "$CLEAN_ROOT/lib/ngtcp2_crypto_openssl_static.lib"   "$CLEAN_ROOT/lib/ngtcp2_crypto_openssl.lib"  -Force -ErrorAction SilentlyContinue

######################################################### nghttp2
Write-Host -ForegroundColor Yellow "Build nghttp2 $NGHTTP2_VERSION"
if (!(DecompressTar -URL $NGHTTP2_URL -File "$NGHTTP2_FILE.tar.xz" -Hash $NGHTTP2_HASH)) {
    exit 1
}

$NGHTTP2_SOURCE_DIR = Join-Path $WD $NGHTTP2_FILE
$NGHTTP2_BUILD_DIR = Join-Path $NGHTTP2_SOURCE_DIR "build"

if (!(MakeDirs -Dir $NGHTTP2_BUILD_DIR)) {
    exit 1
}

$nghttp2_options = "-GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DENABLE_LIB_ONLY=ON -DENABLE_ASIO_LIB=OFF -DENABLE_STATIC_CRT=ON"
$nghttp2_options = "${nghttp2_options} -DENABLE_OPENSSL=ON -DHAVE_SSL_IS_QUIC=ON"
$nghttp2_options = "${nghttp2_options} `"-DCMAKE_INSTALL_PREFIX=${CLEAN_ROOT}`" `"-DCMAKE_PREFIX_PATH=${CLEAN_ROOT}`" .." 

$ec = Exec -FilePath $cmakeexe -Argv $nghttp2_options -WD $NGHTTP2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $NGHTTP2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $NGHTTP2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: install error"
    exit 1
}


############################################################# Libssh2
Write-Host -ForegroundColor Yellow "Build libssh2 $LIBSSH2_VERSION"
if (!(DecompressTar -URL $LIBSSH2_URL -File "$LIBSSH2_FILE.tar.gz" -Hash $LIBSSH2_HASH)) {
    exit 1
}
$LIBSSH2_SOURCE_DIR = Join-Path $WD $LIBSSH2_FILE
$LIBSSH2_BUILD_DIR = Join-Path $LIBSSH2_SOURCE_DIR "build"
$LIBSSH2_PATCHH = Join-Path $PSScriptRoot "patch/libssh2.patch"

if (!(MakeDirs -Dir $LIBSSH2_BUILD_DIR)) {
    exit 1
}

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$LIBSSH2_PATCHH`"" -WD $LIBSSH2_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $LIBSSH2_PATCHH failed"
}

$LIBSSH2_CFLAGS = "-DHAVE_EVP_AES_128_CTR=1"
$libssh2_options = "-GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DENABLE_ZLIB_COMPRESSION=ON"
$libssh2_options = "${libssh2_options} -DCRYPTO_BACKEND=OpenSSL"
$libssh2_options = "${libssh2_options} -DENABLE_ZLIB_COMPRESSION=ON"
$libssh2_options = "${libssh2_options} `"-DCMAKE_C_FLAGS=${LIBSSH2_CFLAGS}`" `"-DCMAKE_INSTALL_PREFIX=$CLEAN_ROOT`" `"-DCMAKE_PREFIX_PATH=${CLEAN_ROOT}`"  .. " 

$ec = Exec -FilePath $cmakeexe -Argv $libssh2_options -WD $LIBSSH2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $LIBSSH2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $LIBSSH2_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: install error"
    exit 1
}

############################################################## CURL

Write-Host -ForegroundColor Yellow "Final build curl $CURL_VERSION"
if (!(DecompressTar -URL $CURL_URL -File "$CURL_FILE.tar.xz" -Hash $CURL_HASH)) {
    exit 1
}

$CURL_SOURCE_DIR = Join-Path $WD $CURL_FILE
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

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$CURL_PATCH`"" -WD $CURL_SOURCE_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $CURL_PATCH failed"
}

$CURL_CFLAGS = "-DHAS_ALPN"
$options = "-GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DENABLE_UNICODE=ON -DBUILD_CURL_EXE=ON -DCURL_STATIC_CRT=ON -DCMAKE_RC_FLAGS=-c1252 -DCURL_TARGET_WINDOWS_VERSION=0x0A00 -DCURL_LTO=ON"
$options = "${options} -DBUILD_LIBCURL_DOCS=OFF -DENABLE_CURL_MANUAL=OFF -DUSE_LIBIDN2=OFF -DCURL_USE_LIBPSL=OFF"
# zlib
$options = "${options} -DUSE_ZLIB=ON"
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
$options = "${options} `"-DCMAKE_C_FLAGS=${CURL_CFLAGS}`" `"-DCMAKE_INSTALL_PREFIX=$CURL_BUILD_ROOT`" `"-DCMAKE_PREFIX_PATH=${CLEAN_ROOT}`"  .."

$ec = Exec -FilePath $cmakeexe -Argv $options -WD $CURL_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $CURL_BUILD_DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $CURL_BUILD_DIR
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
Remove-Item -Force $DestinationPath
Compress-Archive -Path "$CURL_BUILD_ROOT/*" -DestinationPath $DestinationPath
$obj = Get-FileHash -Algorithm SHA256 $DestinationPath
$baseName = Split-Path -Leaf $DestinationPath
$hashtext = $obj.Algorithm + ":" + $obj.Hash.ToLower()
$hashtext | Out-File -Encoding utf8 -FilePath "$DestinationPath.sha256"
Write-Host "$baseName`n$hashtext"
