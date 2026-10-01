# PowerShell Script: UI Validator
param (
    [string]$Path = "."
)

Write-Host "=== UI Framework, UXML & CSS Audit ===" -ForegroundColor Cyan

$uxmlFiles = Get-ChildItem -Path $Path -Filter "*.uxml" -Recurse | Where-Object { $_.FullName -notmatch "Library|Temp|Packages" }
$ussFiles = Get-ChildItem -Path $Path -Filter "*.uss" -Recurse | Where-Object { $_.FullName -notmatch "Library|Temp|Packages" }

$warnings = 0

# 1. Audit USS Files
foreach ($uss in $ussFiles) {
    $content = Get-Content $uss.FullName -Raw
    
    # Check for invalid picking-mode property in USS (causes Unity compilation warning)
    if ($content -match "picking-mode\s*:") {
        Write-Host "ERROR: picking-mode is NOT a CSS property! Found in $($uss.Name). Must be set inline in UXML attribute." -ForegroundColor Red
        $warnings++
    }
}

# 2. Audit UXML Files
$interactiveTags = @("Button", "Toggle", "TextField", "Slider", "DropdownField", "ListView", "ScrollView")

foreach ($uxml in $uxmlFiles) {
    $lines = Get-Content $uxml.FullName
    $lineNum = 0

    foreach ($line in $lines) {
        $lineNum++
        $trimmed = $line.Trim()

        foreach ($tag in $interactiveTags) {
            if ($trimmed -match "<(?:ui:)?$tag\b" -and $trimmed -notmatch "name\s*=\s*`"[^`"]+`"") {
                Write-Host "WARNING: Interactive element <$tag> lacks 'name' attribute in $($uxml.Name):$lineNum" -ForegroundColor Yellow
                $warnings++
            }
        }
    }
}

if ($warnings -eq 0) {
    Write-Host "UI & CSS Validation Passed cleanly! (UXML: $($uxmlFiles.Count), USS: $($ussFiles.Count))" -ForegroundColor Green
} else {
    Write-Host "Found $warnings UI validation warnings." -ForegroundColor Yellow
}
