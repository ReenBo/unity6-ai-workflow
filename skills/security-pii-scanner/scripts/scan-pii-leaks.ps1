# PowerShell Script: PII & Security Leak Scanner
param (
    [string]$Path = "."
)

Write-Host "=== Security & PII Leak Scanner ===" -ForegroundColor Cyan

$files = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.FullName -notmatch "Library|Temp|Packages|\.git" -and -not $_.PSIsContainer }

$leakCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }

    # Check for hardcoded user paths
    if ($content -match "[C-Z]:\\Users\\") {
        Write-Host "SECURITY WARNING: Hardcoded User Path in $($file.Name)" -ForegroundColor Red
        $leakCount++
    }

    # Check for potential API Keys
    if ($content -match "sk-[a-zA-Z0-9]{20,}") {
        Write-Host "CRITICAL RISK: Potential API Key in $($file.Name)" -ForegroundColor Red
        $leakCount++
    }
}

if ($leakCount -eq 0) {
    Write-Host "No PII or Secret Leaks Detected." -ForegroundColor Green
} else {
    Write-Host "Found $leakCount Security Risks! Developer approval required." -ForegroundColor Yellow
}
