# PowerShell Script: Universal CI/CD Check Runner for Unity 6
param (
    [string]$ProjectPath = "."
)

$hasPython = $false
$pyCmd = Get-Command python -ErrorAction SilentlyContinue
if ($pyCmd -and $pyCmd.Source -notmatch "WindowsApps") {
    $testResult = python --version 2>&1
    if ($LASTEXITCODE -eq 0 -and "$testResult" -match "Python") {
        $hasPython = $true
    }
}

if (-not $hasPython) {
    $py3Cmd = Get-Command python3 -ErrorAction SilentlyContinue
    if ($py3Cmd -and $py3Cmd.Source -notmatch "WindowsApps") {
        $testResult = python3 --version 2>&1
        if ($LASTEXITCODE -eq 0 -and "$testResult" -match "Python") {
            $hasPython = $true
            $pyCmd = $py3Cmd
        }
    }
}

if ($hasPython) {
    & $pyCmd.Source "$ProjectPath/ci/runner.py" "$ProjectPath"
} else {
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "🚀 Starting Unity 6 AI Workflow CI Checks (PowerShell Mode)" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan

    $allPassed = $true
    $global:LASTEXITCODE = 0

    # Run VContainer Auditor
    if (Test-Path "$ProjectPath/skills/vcontainer-auditor/scripts/audit-vcontainer.ps1") {
        $global:LASTEXITCODE = 0
        & "$ProjectPath/skills/vcontainer-auditor/scripts/audit-vcontainer.ps1" -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    # Run Security & PII Scanner
    if (Test-Path "$ProjectPath/skills/security-pii-scanner/scripts/scan-pii-leaks.ps1") {
        $global:LASTEXITCODE = 0
        & "$ProjectPath/skills/security-pii-scanner/scripts/scan-pii-leaks.ps1" -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    # Run GC & Allocation Profiler
    if (Test-Path "$ProjectPath/skills/memory-gc-profiler/scripts/check-allocations.ps1") {
        $global:LASTEXITCODE = 0
        & "$ProjectPath/skills/memory-gc-profiler/scripts/check-allocations.ps1" -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    # Run UI Validator
    if (Test-Path "$ProjectPath/skills/ui-builder-validator/scripts/validate-ui.ps1") {
        $global:LASTEXITCODE = 0
        & "$ProjectPath/skills/ui-builder-validator/scripts/validate-ui.ps1" -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    Write-Host "=========================================" -ForegroundColor Cyan
    if ($allPassed) {
        Write-Host "✅ All AI Workflow Audits Passed!" -ForegroundColor Green
    } else {
        Write-Host "❌ Some audits reported warnings or failures." -ForegroundColor Yellow
    }
}
