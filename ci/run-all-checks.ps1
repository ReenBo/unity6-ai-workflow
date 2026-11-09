# PowerShell Script: Universal CI/CD Check Runner for Unity 6
param (
    [string]$ProjectPath = "."
)

$env:PYTHONIOENCODING = "utf-8"
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

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

$scriptDir = $PSScriptRoot
$workflowRoot = Split-Path -Parent $scriptDir
$runnerScript = Join-Path $scriptDir "runner.py"
if (-not (Test-Path $runnerScript)) {
    $runnerScript = "$ProjectPath/ci/runner.py"
}

if ($hasPython -and (Test-Path $runnerScript)) {
    & $pyCmd.Source $runnerScript "$ProjectPath"
    exit $LASTEXITCODE
} else {
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "🚀 Starting Unity 6 AI Workflow CI Checks (PowerShell Mode)" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan

    $allPassed = $true
    $global:LASTEXITCODE = 0

    $skillsDir = Join-Path $workflowRoot "skills"
    if (-not (Test-Path $skillsDir)) {
        $skillsDir = "$ProjectPath/skills"
    }

    # Run VContainer Auditor
    $vcontainerScript = "$skillsDir/vcontainer-auditor/scripts/audit-vcontainer.ps1"
    if (Test-Path $vcontainerScript) {
        $global:LASTEXITCODE = 0
        & $vcontainerScript -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    # Run Security & PII Scanner
    $piiScript = "$skillsDir/security-pii-scanner/scripts/scan-pii-leaks.ps1"
    if (Test-Path $piiScript) {
        $global:LASTEXITCODE = 0
        & $piiScript -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    # Run GC & Allocation Profiler
    $gcScript = "$skillsDir/memory-gc-profiler/scripts/check-allocations.ps1"
    if (Test-Path $gcScript) {
        $global:LASTEXITCODE = 0
        & $gcScript -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    # Run UI Validator
    $uiScript = "$skillsDir/ui-builder-validator/scripts/validate-ui.ps1"
    if (Test-Path $uiScript) {
        $global:LASTEXITCODE = 0
        & $uiScript -Path $ProjectPath
        if (-not $? -or $global:LASTEXITCODE -ne 0) { $allPassed = $false }
    }

    Write-Host "=========================================" -ForegroundColor Cyan
    if ($allPassed) {
        Write-Host "✅ All AI Workflow Audits Passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "❌ Some audits reported warnings or failures." -ForegroundColor Yellow
        exit 1
    }
}
