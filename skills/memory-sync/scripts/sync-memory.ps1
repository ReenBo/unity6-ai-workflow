# PowerShell Script: Memory Sync Assistant
param (
    [string]$Path = "."
)

Write-Host "=== Memory Sync: Extracting Git Diff & Changes ===" -ForegroundColor Cyan

$status = git status --short
$diffStat = git diff --stat

Write-Host "Modified Files Status:" -ForegroundColor Yellow
Write-Host $status

Write-Host "Diff Summary:" -ForegroundColor Yellow
Write-Host $diffStat

Write-Host "Memory extraction ready for PROJECT_MEMORY.md update." -ForegroundColor Green
