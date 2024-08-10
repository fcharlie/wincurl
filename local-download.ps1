#!/usr/bin/env pwsh


# TLS enable tls12/tls13
[enum]::GetValues('Net.SecurityProtocolType') | Where-Object { $_ -ge 'Tls12' } | ForEach-Object {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor $_
}

Import-Module -Name "$PSScriptRoot/script/Utility"

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

    return $true
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

Write-Host "download root in $WD"

. "$PSScriptRoot/version.ps1"

Write-Host -ForegroundColor Yellow "Build zstd $ZSTD_VERSION"
if (!(DecompressTar -URL "https://mirror.ghproxy.com/$ZSTD_URL" -File "$ZSTD_FILE.tar.gz" -Hash $ZSTD_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://mirror.ghproxy.com/$BROTLI_URL" -File "$BROTLI_FILE.tar.gz" -Hash $BROTLI_HASH)) {
    exit 1
}

if (!(DecompressTar -URL $ZLIBNG_URL -File "$ZLIBNG_FILE.tar.xz" -Hash $ZLIBNG_HASH)) {
    exit 1
}

if (!(DecompressTar -URL $OPENSSL_URL -File "$OPENSSL_FILE.tar.gz" -Hash $OPENSSL_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://mirror.ghproxy.com/$NGHTTP3_URL" -File "$NGHTTP3_FILE.tar.xz" -Hash $NGHTTP3_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://mirror.ghproxy.com/$NGTCP2_URL" -File "$NGTCP2_FILE.tar.xz" -Hash $NGTCP2_HASH)) {
    exit 1
}


if (!(DecompressTar -URL "https://mirror.ghproxy.com/$NGHTTP2_URL" -File "$NGHTTP2_FILE.tar.xz" -Hash $NGHTTP2_HASH)) {
    exit 1
}

if (!(DecompressTar -URL $LIBSSH2_URL -File "$LIBSSH2_FILE.tar.gz" -Hash $LIBSSH2_HASH)) {
    exit 1
}

if (!(DecompressTar -URL $CURL_URL -File "$CURL_FILE.tar.xz" -Hash $CURL_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://mirror.ghproxy.com/$QUICTLS_URL" -File "$QUICTLS_FILE.tar.gz" -Hash $QUICTLS_HASH)) {
    exit 1
}