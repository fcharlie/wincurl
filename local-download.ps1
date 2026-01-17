#!/usr/bin/env pwsh

Function Exec {
    param(
        [string]$FilePath,
        [string]$Argv,
        [string]$WD
    )
    $pi = New-Object System.Diagnostics.ProcessStartInfo
    $pi.FileName = $FilePath
    Write-Host "$FilePath $Argv [$WD] "
    if ([String]::IsNullOrEmpty($WD)) {
        $pi.WorkingDirectory = $PWD
    }
    else {
        $pi.WorkingDirectory = $WD
    }
    $pi.Arguments = $Argv
    $pi.UseShellExecute = $false ## use createprocess not shellexecute
    $ps = New-Object System.Diagnostics.Process
    $ps.StartInfo = $pi
    if ($ps.Start() -eq $false) {
        return -1
    }
    $ps.WaitForExit()
    return $ps.ExitCode
}

Function WinGet {
    param(
        [String]$URL,
        [String]$O
    )
    # 
    Write-Host "Download file: $O"
    $ex = Exec -FilePath "curl.exe" -Argv "--progress-bar -fS --connect-timeout 15 --retry 3 -o `"$O`" -L --proto-redir =https $URL" -WD $PWD
    if ($ex -ne 0) {
        return $false
    }
    return $true
}

Function MakeDirs {
    param(
        [String]$Dir
    )
    try {
        New-Item -ItemType Directory -Force $Dir
    }
    catch {
        Write-Host -ForegroundColor Red "mkdir $Dir error: $_"
        return $false
    }
    return $true
}


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
if (!(DecompressTar -URL "https://gh.llkk.cc/$ZSTD_URL" -File "$ZSTD_DIRNAME.tar.gz" -Hash $ZSTD_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://gh.llkk.cc/$BROTLI_URL" -File "$BROTLI_DIRNAME.tar.gz" -Hash $BROTLI_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://gh.llkk.cc/$ZLIBNG_URL" -File "$ZLIBNG_DIRNAME.tar.gz" -Hash $ZLIBNG_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://gh.llkk.cc/$OPENSSL_URL" -File "$OPENSSL_DIRNAME.tar.gz" -Hash $OPENSSL_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://gh.llkk.cc/$NGHTTP3_URL" -File "$NGHTTP3_DIRNAME.tar.xz" -Hash $NGHTTP3_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://gh.llkk.cc/$NGTCP2_URL" -File "$NGTCP2_FILE.tar.xz" -Hash $NGTCP2_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "https://gh.llkk.cc/$NGHTTP2_URL" -File "$NGHTTP2_DIRNAME.tar.xz" -Hash $NGHTTP2_HASH)) {
    exit 1
}

if (!(DecompressTar -URL "$LIBSSH2_URL" -File "$LIBSSH2_DIRNAME.tar.gz" -Hash $LIBSSH2_HASH)) {
    exit 1
}

if (!(DecompressTar -URL $CURL_URL -File "$CURL_DIRNAME.tar.xz" -Hash $CURL_HASH)) {
    exit 1
}

