# PowerShell Git Pre-Commit Hook Audit for Unity 6
Write-Host "Running Pre-Commit AI Workflow Checks..." -ForegroundColor Cyan

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$workflowRoot = Split-Path -Parent $scriptDir

$vcontainerScript = Join-Path $workflowRoot "skills/vcontainer-auditor/scripts/audit-vcontainer.ps1"
$gcScript = Join-Path $workflowRoot "skills/memory-gc-profiler/scripts/check-allocations.ps1"

# Run VContainer Check
if (Test-Path $vcontainerScript) {
    & $vcontainerScript -Path (Get-Location).Path
} else {
    Write-Host "VContainer auditor script not found at $vcontainerScript" -ForegroundColor Yellow
}

# Run Allocation Check
if (Test-Path $gcScript) {
    & $gcScript -Path (Get-Location).Path
} else {
    Write-Host "Allocation checker script not found at $gcScript" -ForegroundColor Yellow
}

Write-Host "Pre-Commit Checks Finished Successfully." -ForegroundColor Green
