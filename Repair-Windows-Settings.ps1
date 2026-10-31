# Repair the Windows Settings app registration.
# Run in Windows PowerShell as Administrator.
# This script does not delete personal files or reset Windows.

#requires -Version 5.1

$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Please open Windows PowerShell as Administrator and run this script again.' -ForegroundColor Yellow
    exit 1
}

try {
    $packages = @(Get-AppxPackage -AllUsers -Name 'windows.immersivecontrolpanel')

    if ($packages.Count -eq 0) {
        throw 'Windows Settings app package was not found. Re-registration cannot proceed.'
    }

    foreach ($package in $packages) {
        $manifest = Join-Path -Path $package.InstallLocation -ChildPath 'AppXManifest.xml'

        if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
            throw "Windows Settings app manifest was not found: $manifest"
        }

        Write-Host 'Re-registering Windows Settings...' -ForegroundColor Cyan
        Add-AppxPackage -DisableDevelopmentMode -Register $manifest -ErrorAction Stop
    }

    Write-Host 'Re-registration completed. Try Windows + I to open Settings.' -ForegroundColor Green
    Write-Host 'If it still does not open, restart your computer and try again.'
}
catch {
    Write-Host "Repair failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
