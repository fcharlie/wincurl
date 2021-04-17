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
        Remove-Item -Force $File
        if (!(WinGet -URL $URL -O $File)) {
            return $false
        }
    }
    $xhash = Get-FileHash -Algorithm SHA256 $File
    if ($xhash.Hash -ne $Hash) {
        return $false
    }

    if ((Exec -FilePath $tarexe -Argv "$decompress $File") -ne 0) {
        Write-Host -ForegroundColor Red "Decompress $File failed"
        return $false
    }
    return $true
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
    "C:\Program Files (x86)\Microsoft Visual Studio\2021\Enterprise"
    "C:\Program Files (x86)\Microsoft Visual Studio\2021\Community"
    "C:\Program Files (x86)\Microsoft Visual Studio\2021\BuildTools"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools"
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
$vsArch = $env:MSVC_ARCH
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
    return 1
}
Write-Host -ForegroundColor Green "curl: $curlexe"

$cmakeexe = Findcommand -Name "cmake"
if ($null -eq $cmakeexe) {
    Write-Host -ForegroundColor Red "Please install cmake."
    return 1
}
Write-Host -ForegroundColor Green "cmake: $cmakeexe"

$tarexe = Findcommand -Name "tar"
$decompress = "-xvf"
if ($null -eq $tarexe) {
    $tarexe = $cmakeexe
    $decompress = "-E tar -xvf"
}
Write-Host -ForegroundColor Green "Use $tarexe as tar"

$Ninjaexe = Findcommand -Name "ninja"
if ($null -eq $Ninjaexe) {
    Write-Host -ForegroundColor Red "Please install ninja."
    return 1
}
Write-Host -ForegroundColor Green "ninja: $Ninjaexe"

$Patchexe = Findcommand -Name "patch"
if ($null -eq $Patchexe) {
    $Patchexe = Findcommand4GitDevs -Command "patch"
    if ($null -eq $Patchexe) {
        return 1;
    }
}
Write-Host  -ForegroundColor Green "path: $Patchexe"

$Perlexe = Findcommand -Name "perl"

if ($null -eq $Perlexe) {
    Write-Host -ForegroundColor Red "Please install perl (strawberryperl, activeperl).
    perl implementation must produce Windows like paths (with backward slash directory separators). "
    return 1
}
Write-Host  -ForegroundColor Green "perl: $Perlexe"


$RefName = "$env:REF_NAME".TrimStart("refs/tags/")

Write-Host "build wincurl $RefName"
