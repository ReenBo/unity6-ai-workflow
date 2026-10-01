# PowerShell Script: Allocation & Memory Check
param (
    [string]$Path = "."
)

Write-Host "=== GC & Allocation Checker ===" -ForegroundColor Cyan
$csFiles = Get-ChildItem -Path $Path -Filter "*.cs" -Recurse | Where-Object { $_.FullName -notmatch "Library|Temp|Packages" }

$allocWarnings = 0

foreach ($file in $csFiles) {
    $lines = Get-Content $file.FullName
    $inTick = $false
    $lineNum = 0

    foreach ($line in $lines) {
        $lineNum++
        if ($line -match "void\s+Tick\(\)") { $inTick = $true }
        if ($inTick -and $line -match "\}") { $inTick = $false }

        if ($inTick -and $line -match "new\s+") {
            Write-Host "WARNING: Allocation in Tick() at $($file.Name):$lineNum -> $line" -ForegroundColor Red
            $allocWarnings++
        }
    }
}

if ($allocWarnings -eq 0) {
    Write-Host "No GC allocations found in Tick() loops!" -ForegroundColor Green
} else {
    Write-Host "Found $allocWarnings allocation warnings." -ForegroundColor Yellow
}
