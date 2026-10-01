# PowerShell Git Pre-Commit Hook Audit for Unity 6
Write-Host "Running Pre-Commit AI Workflow Checks..." -ForegroundColor Cyan

# Run VContainer Check
& "skills/vcontainer-auditor/scripts/audit-vcontainer.ps1"

# Run Allocation Check
& "skills/memory-gc-profiler/scripts/check-allocations.ps1"

Write-Host "Pre-Commit Checks Finished Successfully." -ForegroundColor Green
