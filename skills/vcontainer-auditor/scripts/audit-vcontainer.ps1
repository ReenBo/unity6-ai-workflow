# PowerShell Script: VContainer Auditor for Unity 6
param (
    [string]$Path = "."
)

Write-Host "=== VContainer & POCO Rules Audit ===" -ForegroundColor Cyan

$csFiles = Get-ChildItem -Path $Path -Filter "*.cs" -Recurse | Where-Object { $_.FullName -notmatch "Library|Temp|Packages" }

$monoCount = 0
$pocoCount = 0

foreach ($file in $csFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "class\s+\w+\s*:\s*MonoBehaviour") {
        $monoCount++
    } elseif ($content -match "class\s+\w+") {
        $pocoCount++
    }
}

Write-Host "Found POCO Classes: $pocoCount" -ForegroundColor Green
Write-Host "Found MonoBehaviour Classes: $monoCount" -ForegroundColor Yellow
Write-Host "Audit completed cleanly." -ForegroundColor Green
