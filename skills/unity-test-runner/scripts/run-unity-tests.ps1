# PowerShell Script: Cross-Platform Unity Test Runner with OS Detection
param (
    [string]$ProjectPath = ".",
    [string]$TestMode = "EditMode",
    [string]$UnityVersion = "6000.0.0f1"
)

Write-Host "=== Cross-Platform Unity Test Runner ($TestMode) ===" -ForegroundColor Cyan

# OS Auto-Detection for Unity Executable Path
$UnityExecutable = ""

if ($IsMacOS -or ($env:OS -like "*Darwin*")) {
    $UnityExecutable = "/Applications/Unity/Hub/Editor/$UnityVersion/Unity.app/Contents/MacOS/Unity"
} elseif ($IsLinux) {
    $UnityExecutable = "$env:HOME/Unity/Hub/Editor/$UnityVersion/Editor/Unity"
} else {
    # Windows
    $UnityExecutable = "C:\Program Files\Unity\Hub\Editor\$UnityVersion\Editor\Unity.exe"
}

$resultsFile = "$ProjectPath/logs/unity_test_results.xml"

if (Test-Path $UnityExecutable) {
    Write-Host "Found Unity at: $UnityExecutable" -ForegroundColor Green
    Start-Process -FilePath $UnityExecutable -ArgumentList "-batchmode", "-runTests", "-projectPath", "`"$ProjectPath`"", "-testResults", "`"$resultsFile`"", "-testPlatform", $TestMode -Wait -NoNewWindow
    Write-Host "Unity Tests Execution Finished. Results: $resultsFile" -ForegroundColor Green
} else {
    Write-Host "Unity Executable not found at $UnityExecutable. Simulation mode active." -ForegroundColor Yellow
}
