# PowerShell Script: Task Tracker Initialization & Verification
param (
    [string]$ProjectRoot = ""
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$initScript = Join-Path (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $scriptDir))) "scripts\init-foragents.ps1"

if (Test-Path $initScript) {
    & $initScript -ProjectRoot $ProjectRoot
} else {
    Write-Host "Fallback: Invoking local initialization..." -ForegroundColor Cyan
    # Fallback to local logic if standalone
    if (-not $ProjectRoot) {
        $ProjectRoot = (Get-Location).Path
    }
    $foragentsDir = Join-Path $ProjectRoot ".foragents"
    $logsDir = Join-Path $foragentsDir "logs"
    if (-not (Test-Path $foragentsDir)) { New-Item -ItemType Directory -Path $foragentsDir -Force | Out-Null }
    if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }
}
