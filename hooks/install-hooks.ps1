# PowerShell Script: Install Git Hooks for Unity Project
param (
    [string]$TargetGitFolder = "../.git"
)

Write-Host "=== Installing AI Workflow Git Hooks ===" -ForegroundColor Cyan

if (-not (Test-Path "$TargetGitFolder/hooks")) {
    Write-Host "Git directory not found at $TargetGitFolder." -ForegroundColor Red
    exit 1
}

$preCommitScript = @"
#!/bin/sh
if [ -f "./.agents/hooks/pre-commit-audit.ps1" ]; then
    powershell -ExecutionPolicy Bypass -File ./.agents/hooks/pre-commit-audit.ps1
elif [ -f "./hooks/pre-commit-audit.ps1" ]; then
    powershell -ExecutionPolicy Bypass -File ./hooks/pre-commit-audit.ps1
fi
"@

Set-Content -Path "$TargetGitFolder/hooks/pre-commit" -Value $preCommitScript
Write-Host "Local pre-commit hook installed successfully in $TargetGitFolder/hooks/pre-commit" -ForegroundColor Green
