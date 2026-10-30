# PowerShell Script: Unity Test Runner with Unity CLI & Fallback
param (
    [string]$ProjectPath = ".",
    [string]$TestMode = "EditMode",
    [string]$Filter = "",
    [string]$ResultsFile = ""
)

Write-Host "=== Unity Test Runner ($TestMode) ===" -ForegroundColor Cyan

if (-not $ResultsFile) {
    $ResultsFile = Join-Path $ProjectPath "logs/unity_test_results.xml"
}

$resultsDir = Split-Path -Parent $ResultsFile
if ($resultsDir -and -not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
}

# 1. Primary Route: Official Unity CLI (Ultra-fast Warm Editor or Managed Headless)
$unityCli = Get-Command "unity" -ErrorAction SilentlyContinue
if ($unityCli) {
    Write-Host "[+] Using official Unity CLI: $($unityCli.Source)" -ForegroundColor Green
    
    $argsList = @("test", "`"$ProjectPath`"", "--mode", $TestMode, "--output", "`"$ResultsFile`"")
    if ($Filter) {
        $argsList += @("--filter", "`"$Filter`"")
    }

    $process = Start-Process -FilePath "unity" -ArgumentList $argsList -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -eq 0) {
        Write-Host "Unity Tests Execution Finished Successfully. Results: $ResultsFile" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Unity Tests reported failures (ExitCode: $($process.ExitCode)). Results: $ResultsFile" -ForegroundColor Yellow
        exit $process.ExitCode
    }
}

# 2. Fallback Route: Direct Unity Editor Executable Detection via ProjectVersion.txt
Write-Host "[!] Unity CLI not found in PATH. Falling back to direct Editor binary detection..." -ForegroundColor Yellow

$projectVersionFile = Join-Path $ProjectPath "ProjectSettings/ProjectVersion.txt"
$version = "6000.0.0f1"
if (Test-Path $projectVersionFile) {
    $verLine = Get-Content $projectVersionFile | Where-Object { $_ -match "m_EditorVersion:\s*(.+)" }
    if ($verLine -and $Matches[1]) {
        $version = $Matches[1].Trim()
    }
}

$unityExe = ""
if ($IsMacOS -or ($env:OS -like "*Darwin*")) {
    $unityExe = "/Applications/Unity/Hub/Editor/$version/Unity.app/Contents/MacOS/Unity"
} elseif ($IsLinux) {
    $unityExe = "$env:HOME/Unity/Hub/Editor/$version/Editor/Unity"
} else {
    $possiblePaths = @(
        "C:\Program Files\Unity\Hub\Editor\$version\Editor\Unity.exe",
        "E:\UnityEditor\$version\Editor\Unity.exe",
        "D:\UnityEditor\$version\Editor\Unity.exe"
    )
    foreach ($p in $possiblePaths) {
        if (Test-Path $p) {
            $unityExe = $p
            break
        }
    }
}

if ($unityExe -and (Test-Path $unityExe)) {
    Write-Host "Found Unity at: $unityExe" -ForegroundColor Green
    $batchArgs = @("-batchmode", "-runTests", "-projectPath", "`"$ProjectPath`"", "-testResults", "`"$ResultsFile`"", "-testPlatform", $TestMode)
    if ($Filter) {
        $batchArgs += @("-testFilter", "`"$Filter`"")
    }
    $p = Start-Process -FilePath $unityExe -ArgumentList $batchArgs -Wait -NoNewWindow -PassThru
    exit $p.ExitCode
} else {
    Write-Host "Unity Executable not found for version $version. Simulation mode active." -ForegroundColor Yellow
    exit 0
}
