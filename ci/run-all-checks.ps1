# PowerShell Script: Universal CI/CD Check Runner for Unity 6
param (
    [string]$ProjectPath = "."
)

if (Get-Command python -ErrorAction SilentlyContinue) {
    python "$ProjectPath/ci/runner.py" "$ProjectPath"
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    python3 "$ProjectPath/ci/runner.py" "$ProjectPath"
} else {
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "🚀 Starting Unity 6 AI Workflow CI Checks" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan

    # Fallback to PowerShell scripts
    if (Test-Path "$ProjectPath/skills/vcontainer-auditor/scripts/audit-vcontainer.ps1") {
        & "$ProjectPath/skills/vcontainer-auditor/scripts/audit-vcontainer.ps1" -Path $ProjectPath
    }

    if (Test-Path "$ProjectPath/skills/security-pii-scanner/scripts/scan-pii-leaks.ps1") {
        & "$ProjectPath/skills/security-pii-scanner/scripts/scan-pii-leaks.ps1" -Path $ProjectPath
    }

    if (Test-Path "$ProjectPath/skills/memory-gc-profiler/scripts/check-allocations.ps1") {
        & "$ProjectPath/skills/memory-gc-profiler/scripts/check-allocations.ps1" -Path $ProjectPath
    }
}
