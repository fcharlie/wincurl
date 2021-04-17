#!/usr/bin/env pwsh

$perl = Get-Command -Name "perl" -ErrorAction SilentlyContinue

if ($null -ne $perl) {
    Write-Host $perl.Source
    perl --version
}