# PowerShell Script: PII & Security Leak Scanner
param (
    [string]$Path = "."
)

Write-Host "=== Security & PII Leak Scanner ===" -ForegroundColor Cyan

$ignoredExtensions = @(".dll", ".wasm", ".so", ".dylib", ".a", ".png", ".jpg", ".jpeg", ".tga", ".psd", ".asset", ".unity", ".prefab", ".meta", ".fbx", ".obj", ".wav", ".mp3", ".ogg", ".log")
$files = Get-ChildItem -Path $Path -Recurse | Where-Object { 
    $_.FullName -notmatch "Library|Temp|Packages|\.git|\.foragents|Builds" -and 
    -not $_.PSIsContainer -and 
    $ignoredExtensions -notcontains $_.Extension.ToLower() 
}

$leakCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }

    # Skip markdown documentation rule descriptions unless they contain real user directories
    $isDoc = $file.Extension -eq ".md"

    # Check for hardcoded user paths
    if ($content -match "[C-Z]:\\Users\\[a-zA-Z0-9_\.]+\\" -or $content -match "\/(?:home|Users)\/[a-zA-Z0-9_\.]+\/") {
        if (-not ($isDoc -and ($content -match "username" -or $content -match "<user>"))) {
            Write-Host "SECURITY WARNING: Hardcoded User Path in $($file.Name)" -ForegroundColor Red
            $leakCount++
        }
    }

    # Check for potential API Keys
    if ($content -match "\bsk-[a-zA-Z0-9]{20,}\b") {
        Write-Host "CRITICAL RISK: Potential API Key in $($file.Name)" -ForegroundColor Red
        $leakCount++
    }
}

if ($leakCount -eq 0) {
    Write-Host "No PII or Secret Leaks Detected." -ForegroundColor Green
} else {
    Write-Host "Found $leakCount Security Risks! Developer approval required." -ForegroundColor Yellow
}
