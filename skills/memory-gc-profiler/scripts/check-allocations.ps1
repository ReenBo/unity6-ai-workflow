# PowerShell Script: Allocation & Memory Check
param (
    [string]$Path = "."
)

Write-Host "=== GC & Allocation Checker ===" -ForegroundColor Cyan
$csFiles = Get-ChildItem -Path $Path -Filter "*.cs" -Recurse | Where-Object { $_.FullName -notmatch "Library|Temp|Packages|\.agents" }

$allocWarnings = 0

foreach ($file in $csFiles) {
    $lines = Get-Content $file.FullName
    $inHotMethod = $false
    $braceDepth = 0
    $lineNum = 0
    $methodName = ""

    foreach ($line in $lines) {
        $lineNum++
        $trimmed = $line.Trim()

        # Ignore comments
        if ($trimmed.StartsWith("//") -or $trimmed.StartsWith("/*")) {
            continue
        }

        # Check for start of hot loop method
        if (-not $inHotMethod -and $line -match "(void\s+(?:Tick|FixedTick|LateTick|Update)\s*\([^)]*\))") {
            $inHotMethod = $true
            $methodName = $Matches[1]
            $braceDepth = 0
        }

        if ($inHotMethod) {
            # Count open and close braces on this line
            $opens = ($line.ToCharArray() | Where-Object { $_ -eq '{' }).Count
            $closes = ($line.ToCharArray() | Where-Object { $_ -eq '}' }).Count
            $braceDepth += ($opens - $closes)

            if ($braceDepth -gt 0) {
                # Check for heap allocation via 'new'
                if ($line -match "new\s+(?!struct|readonly|Vector2|Vector3|Quaternion|Color|CancellationTokenSource)") {
                    Write-Host "WARNING: Allocation in $methodName at $($file.Name):$lineNum -> $trimmed" -ForegroundColor Red
                    $allocWarnings++
                }

                # Check for LINQ usage in hot path
                if ($line -match "\.(Where|Select|ToList|ToArray|First|FirstOrDefault)\s*\(") {
                    Write-Host "WARNING: LINQ query in $methodName at $($file.Name):$lineNum -> $trimmed" -ForegroundColor Red
                    $allocWarnings++
                }
            } elseif ($opens -gt 0 -or $closes -gt 0) {
                if ($braceDepth -le 0) {
                    $inHotMethod = $false
                    $methodName = ""
                }
            }
        }
    }
}

if ($allocWarnings -eq 0) {
    Write-Host "No GC allocations found in hot frame loops!" -ForegroundColor Green
} else {
    Write-Host "Found $allocWarnings allocation warnings." -ForegroundColor Yellow
}
