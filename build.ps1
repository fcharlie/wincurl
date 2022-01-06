#!/usr/bin/env pwsh

# TLS enable tls12/tls13
[enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -ge 'Tls12' } | ForEach-Object {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
}

Import-Module -Name "$PSScriptRoot/script/Utility"

Function Findcommand4GitDevs {
    param(
        [String]$Command
    )
    $gitexex = Findcommand -Name "git"
    if ($null -eq $gitexex) {
        Write-Host -ForegroundColor Red "Please install git-for-windows."
        return $null
    }
    $gitinstall = Split-Path -Parent (Split-Path -Parent $gitexex)
    if ([String]::IsNullOrEmpty($gitinstall)) {
        Write-Host -ForegroundColor Red "Please install git-for-windows."
        return $null
    }
    $cmdx = Join-Path $gitinstall "usr/bin/${Command}.exe"
    Write-Host "Try to find patch from $cmdx"
    if (!(Test-Path $cmdx)) {
        $xinstall = Split-Path -Parent $gitinstall
        if ([String]::IsNullOrEmpty($xinstall)) {
            Write-Host -ForegroundColor Red "Please install git-for-windows."
            return $null
        }
        $cmdx = Join-Path  $xinstall "usr/bin/${Command}.exe"
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
    "$env:ProgramFiles\Microsoft Visual Studio\2022\Enterprise"
    "$env:ProgramFiles\Microsoft Visual Studio\2022\Community"
    "$env:ProgramFiles\Microsoft Visual Studio\2022\BuildTools"
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise"
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community"
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools"
)
$vsvars = ""

foreach ($vi in $vsinstalls) {
    if (Test-Path "$vi\VC\Auxiliary\Build\vcvarsall.bat") {
        $vsvars = "$vi\VC\Auxiliary\Build\vcvarsall.bat"
        break;
    }
}

if ($vsvars.Length -eq 0) {
    Write-Host "Not found visual studio installed."
    exit 1
}
$vsArch = "$env:MSVC_ARCH"
Write-Host "We try run '$vsvars $vsArch' and initialize environment."

Invoke-BatchFile -Path $vsvars -ArgumentList "$vsArch" 

$clexe = Get-Command -CommandType Application "cl" -ErrorAction SilentlyContinue
if ($null -eq $clexe) {
    Write-Host -ForegroundColor Red "Not found cl.exe"
    exit 1
}
Write-Host "Find cl.exe: $($clexe.Version)"

$curlexe = Findcommand -Name "curl"
if ($null -eq $curlexe) {
    Write-Host -ForegroundColor Red "Please use the latest Windows release."
    exit 1
}
Write-Host -ForegroundColor Green "curl: $curlexe"

$cmakeexe = Findcommand -Name "cmake"
if ($null -eq $cmakeexe) {
    Write-Host -ForegroundColor Red "Please install cmake."
    exit 1
}
Write-Host -ForegroundColor Green "cmake: $cmakeexe"

$Ninjaexe = Findcommand -Name "ninja"
if ($null -eq $Ninjaexe) {
    Write-Host -ForegroundColor Red "Please install ninja."
    exit 1
}
Write-Host -ForegroundColor Green "ninja: $Ninjaexe"


$Patchexe = Findcommand4GitDevs -Command "patch"
if ($null -eq $Patchexe) {
    $Patchexe = Findcommand -Name "patch"
    if ($null -eq $Patchexe) {
        Write-Host -ForegroundColor Red "Please install patch."
        exit 1
    }
}

Write-Host  -ForegroundColor Green "path: $Patchexe"

$Perlexe = Findcommand -Name "perl"

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

Write-Host "build wincurl $RefName <$PSScriptRoot>"
$WD = "build"
if (![String]::IsNullOrEmpty($env:BUILD_DIR)) {
    $WD = $env:BUILD_DIR
}
$WD = Join-Path $PSScriptRoot $WD
if (!(MkdirAll -Dir $WD)) {
    exit 1
}
Set-Location $WD

Write-Host "build work directory $WD"

. "$PSScriptRoot/version.ps1"

$WINCURL_TARGET = "$env:WINCURL_TARGET"
Write-Host -ForegroundColor Green "compile curl $CURL_VERSION for $env:WINCURL_TARGET"

$Prefix = Join-Path $WD "cleanroot"
$CURLOUT = Join-Path $WD "out"
$CURLDEST = Join-Path $PSScriptRoot "dest"

Write-Host "we will deploy curl to: $CURLPrefix"

if (!(MkdirAll -Dir $Prefix)) {
    exit 1
}

if (!(MkdirAll -Dir $CURLDEST)) {
    exit 1
}


################################################## Zlib
if (!(DecompressTar -URL $ZLIB_URL -File "$ZLIB_FILENAME.tar.gz" -Hash $ZLIB_HASH)) {
    exit 1
}

$ZLIBDIR = Join-Path $PWD $ZLIB_FILENAME
$ZLIBBD = Join-Path $ZLIBDIR "build"

Write-Host -ForegroundColor Yellow "Apply zlib.patch ..."
$ZLIB_PACTH = Join-Path $PSScriptRoot "patch/zlib.patch"

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$ZLIB_PACTH`"" -WD $ZLIBDIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $ZLIB_PACTH failed"
}

if (!(MkdirAll -Dir $ZLIBBD)) {
    exit 1
}

$cmakeflags = "-GNinja " + `
    "-DCMAKE_BUILD_TYPE=Release " + `
    "`"-DCMAKE_INSTALL_PREFIX=$Prefix`" " + `
    "-DSKIP_INSTALL_FILES=ON " + `
    "-DSKIP_BUILD_EXAMPLES=ON " + `
    "-DBUILD_SHARED_LIBS=OFF `"$ZLIBDIR`""


$ec = Exec -FilePath $cmakeexe -Argv $cmakeflags -WD $ZLIBBD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $ZLIBBD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $ZLIBBD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zlib: install error"
    exit 1
}

Move-Item -Path "$Prefix/lib/zlibstatic.lib"   "$Prefix/lib/zlib.lib"  -Force -ErrorAction SilentlyContinue
#Copy-Item -Path "$ZLIBDIR/LICENSE" 

##################################################### OpenSSL
Write-Host -ForegroundColor Yellow "Build OpenSSL $OPENSSL_VERSION"

if (!(DecompressTar -URL $OPENSSL_URL -File "$OPENSSL_FILE.tar.gz" -Hash $OPENSSL_HASH)) {
    exit 1
}

# Update env
$env:INCLUDE = "$Prefix\include;$env:INCLUDE"
$env:LIB = "$Prefix\lib;$env:LIB"

$OPENSSL_ARCH = "VC-WIN64A"
if ($vsArch -eq "amd64_x86") {
    $OPENSSL_ARCH = "VC-WIN32"
}
elseif ($vsArch -eq "amd64_arm64") {
    $OPENSSL_ARCH = "VC-WIN64-ARM"
}

# perl Configure no-shared no-ssl3 enable-capieng -utf-8

$opensslflags = "Configure no-shared no-unit-test no-asm no-tests no-ssl3 enable-capieng -utf-8 " + `
    "$OPENSSL_ARCH `"--prefix=$Prefix`" `"--openssldir=$Prefix`""

$openssldir = Join-Path $WD $OPENSSL_FILE

$ec = Exec -FilePath $Perlexe -Argv $opensslflags -WD $openssldir
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "openssl: config error"
    exit 1
}

$ec = Exec -FilePath nmake -Argv "-f makefile build_libs" -WD $openssldir
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "openssl: build error"
    exit 1
}

$ec = Exec -FilePath nmake -Argv "-f makefile install_dev" -WD $openssldir
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "openssl: install_dev error"
    exit 1
}
# build brotli static
######################################################### Brotli
Write-Host -ForegroundColor Yellow "Build brotli $BROTLI_VERSION"
if (!(DecompressTar -URL $BROTLI_URL -File "$BROTLI_FILE.tar.gz" -Hash $BROTLI_HASH)) {
    exit 1
}

$BDIR = Join-Path $WD $BROTLI_FILE
$BBUILD = Join-Path $BDIR "out"
$BPATCH = Join-Path $PSScriptRoot "patch/brotli.patch"

if (!(MkdirAll -Dir $BBUILD)) {
    exit 1
}

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$BPATCH`"" -WD $BDIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $BPATCH failed"
}


$brotliflags = "-GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF " + `
    "-DBROTLI_DISABLE_TESTS=ON `"-DCMAKE_INSTALL_PREFIX=$Prefix`" .."


$ec = Exec -FilePath $cmakeexe -Argv $brotliflags -WD $BBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $BBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $BBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "brotli: install error"
    exit 1
}

Move-Item -Path "$Prefix/lib/brotlicommon-static.lib"   "$Prefix/lib/brotlicommon.lib"  -Force -ErrorAction SilentlyContinue
Move-Item -Path "$Prefix/lib/brotlidec-static.lib"   "$Prefix/lib/brotlidec.lib"  -Force -ErrorAction SilentlyContinue
Move-Item -Path "$Prefix/lib/brotlienc-static.lib"   "$Prefix/lib/brotlienc.lib"  -Force -ErrorAction SilentlyContinue

######################################################### Nghttp2
Write-Host -ForegroundColor Yellow "Build nghttp2 $NGHTTP2_VERSION"
if (!(DecompressTar -URL $NGHTTP2_URL -File "$NGHTTP2_FILE.tar.gz" -Hash $NGHTTP2_HASH)) {
    exit 1
}

$NGDIR = Join-Path $WD $NGHTTP2_FILE
$NGBUILD = Join-Path $NGDIR "build"
$NGPATCH = Join-Path $PSScriptRoot "patch/nghttp2.patch"

if (!(MkdirAll -Dir $NGBUILD)) {
    exit 1
}

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$NGPATCH`"" -WD $NGDIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $NGPATCH failed"
}

$ngflags = "-GNinja -DCMAKE_BUILD_TYPE=Release -DENABLE_SHARED_LIB=OFF -DENABLE_STATIC_LIB=ON " + `
    "-DENABLE_LIB_ONLY=ON -DENABLE_ASIO_LIB=OFF `"-DCMAKE_INSTALL_PREFIX=$Prefix`" .."

$ec = Exec -FilePath $cmakeexe -Argv $ngflags -WD $NGBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $NGBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $NGBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "nghttp2: install error"
    exit 1
}

if (Test-Path "$Prefix/lib/nghttp2_static.lib") {
    Copy-Item -Path "$Prefix/lib/nghttp2_static.lib"   "$Prefix/lib/nghttp2.lib"  -Force -ErrorAction SilentlyContinue
}

############################################################# Libssh2
Write-Host -ForegroundColor Yellow "Build libssh2 $LIBSSH2_VERSION"
if (!(DecompressTar -URL $LIBSSH2_URL -File "$LIBSSH2_FILE.tar.gz" -Hash $LIBSSH2_HASH)) {
    exit 1
}
$LIBSSH2DIR = Join-Path $WD $LIBSSH2_FILE
$LIBSSH2BUILD = Join-Path $LIBSSH2DIR "build"
$LIBSSH2PATCH = Join-Path $PSScriptRoot "patch/libssh2.patch"

if (!(MkdirAll -Dir $LIBSSH2BUILD)) {
    exit 1
}

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$LIBSSH2PATCH`"" -WD $LIBSSH2DIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $LIBSSH2PATCH failed"
}

$libssh2flags = "-GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF " + `
    "-DBUILD_EXAMPLES=OFF " + `
    "-DBUILD_TESTING=OFF " + `
    "-DENABLE_ZLIB_COMPRESSION=ON " + `
    "`"-DCMAKE_INSTALL_PREFIX=$Prefix`" .."

$ec = Exec -FilePath $cmakeexe -Argv $libssh2flags -WD $LIBSSH2BUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $LIBSSH2BUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $LIBSSH2BUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "libssh2: install error"
    exit 1
}


############################################################# zstd
Write-Host -ForegroundColor Yellow "Build zstd $ZSTD_VERSION"
if (!(DecompressTar -URL $ZSTD_URL -File "$ZSTD_FILE.tar.gz" -Hash $ZSTD_HASH)) {
    exit 1
}

$zstdflags = "-GNinja -DCMAKE_BUILD_TYPE=Release -DZSTD_BUILD_STATIC=ON " + `
    "-DZSTD_BUILD_PROGRAMS=OFF " + `
    "-DZSTD_BUILD_SHARED=OFF " + `
    "-DZSTD_USE_STATIC_RUNTIME=ON `"-DCMAKE_INSTALL_PREFIX=$Prefix`" .."

$ZSTDDIR = Join-Path $WD "$ZSTD_FILE/build/cmake"
$ZSTDBUILD = Join-Path $ZSTDDIR "build"
if (!(MkdirAll -Dir $ZSTDBUILD)) {
    exit 1
}

$ec = Exec -FilePath $cmakeexe -Argv $zstdflags -WD $ZSTDBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $ZSTDBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $ZSTDBUILD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "zstd: install error"
    exit 1
}

Move-Item -Path "$Prefix/lib/zstd_static.lib"   "$Prefix/lib/zstd.lib"  -Force -ErrorAction SilentlyContinue

############################################################## CURL

Write-Host -ForegroundColor Yellow "Final build curl $CURL_VERSION"
if (!(DecompressTar -URL $CURL_URL -File "$CURL_FILE.tar.gz" -Hash $CURL_HASH)) {
    exit 1
}

$CURLDIR = Join-Path $WD $CURL_FILE
$CURLBD = Join-Path $CURLDIR "build"
$CURLPATCH = Join-Path $PSScriptRoot "patch/curl.patch"
$CURLICON = Join-Path $PSScriptRoot "patch/curl.ico"

if (!(MkdirAll -Dir $CURLBD)) {
    exit 1
}

# copy icon to path
Copy-Item $CURLICON -Destination "$CURLDIR/src"-Force -ErrorAction SilentlyContinue

$ec = Exec -FilePath $Patchexe -Argv "-Nbp1 -i `"$CURLPATCH`"" -WD $CURLDIR
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "Apply $CURLPATCH failed"
}

#https://github.com/curl/curl/blob/master/CMake/FindBrotli.cmake
$BROTLIDEC_LIBRARY = Join-Path $Prefix "lib/brotlidec-static.lib"
$BROTLICOMMON_LIBRARY = Join-Path $Prefix "lib/brotlicommon-static.lib"
$BROTLI_INCLUDE_DIR = Join-Path $Prefix "include"
# we now not use this!!!!
[void]$BROTLIDEC_LIBRARY
[void]$BROTLICOMMON_LIBRARY
[void]$BROTLI_INCLUDE_DIR
## Use codepage 1252

$curlflags = "-GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF " + `
    "-DUSE_NGHTTP2=ON -DBUILD_TESTING=OFF " + `
    "-DBUILD_CURL_EXE=ON " + `
    "-DCURL_STATIC_CRT=ON " + `
    "-DCURL_USE_OPENSSL=ON " + `
    "-DCURL_USE_SCHANNEL=ON " + `
    "-DCURL_USE_LIBSSH2=ON " + `
    "-DCURL_ZSTD=ON " + `
    "-DCURL_BROTLI=ON " + `
    "-DCMAKE_RC_FLAGS=-c1252 " + `
    "`"-DBROTLI_DIR=$Prefix`" " + `
    "`"-DCMAKE_INSTALL_PREFIX=$CURLOUT`" .."

$ec = Exec -FilePath $cmakeexe -Argv $curlflags -WD $CURLBD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: create build.ninja error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "all" -WD $CURLBD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: build error"
    exit 1
}

$ec = Exec -FilePath $Ninjaexe -Argv "install" -WD $CURLBD
if ($ec -ne 0) {
    Write-Host -ForegroundColor Red "curl: install error"
    exit 1
}

# download curl-ca-bundle.crt

$CA_BUNDLE = Join-Path $CURLOUT "bin/curl-ca-bundle.crt"

if (!(WinGet -URL $CA_BUNDLE_URL -O $CA_BUNDLE)) {
    Write-Host -ForegroundColor Red "download curl-ca-bundle.crt  error"
}

Write-Host -ForegroundColor Green "curl: build completed"

$VersionName = $CURL_VERSION
if (!$RefName.StartsWith("refs/heads/")) {
    $VersionName = $RefName
}

$DestinationPath = "$CURLDEST\$WINCURL_TARGET-$VersionName.zip"
Compress-Archive -Path "$CURLOUT\*" -DestinationPath $DestinationPath
$obj = Get-FileHash -Algorithm SHA256 $DestinationPath
$baseName = Split-Path -Leaf $DestinationPath
$hashtext = $obj.Algorithm + ":" + $obj.Hash.ToLower()
$hashtext | Out-File -Encoding utf8 -FilePath "$DestinationPath.sha256"
Write-Host "$baseName`n$hashtext"
