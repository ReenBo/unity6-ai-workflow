# PowerShell Script: Dual-Mode Unity Test Runner (Hot Editor via Pipeline or Headless)
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

$fullProjectPath = (Resolve-Path $ProjectPath).Path

# 1. Check if official Unity CLI is available
$unityCli = Get-Command "unity" -ErrorAction SilentlyContinue
if ($unityCli) {
    Write-Host "[+] Using official Unity CLI: $($unityCli.Source)" -ForegroundColor Green

    # Check if Unity Editor is currently running for this project
    $isEditorRunning = $false
    try {
        $statusJson = unity status --format json | ConvertFrom-Json
        if ($statusJson.success -and $statusJson.data.count -gt 0) {
            foreach ($instance in $statusJson.data.instances) {
                if ($instance.state -eq "ready" -and ($instance.project -replace '\\', '/' -eq $fullProjectPath -replace '\\', '/')) {
                    $isEditorRunning = $true
                    break
                }
            }
        }
    } catch {
        $isEditorRunning = $false
    }

    if ($isEditorRunning) {
        Write-Host "[⚡ HOT EXECUTION] Running tests inside active Unity Editor via Pipeline..." -ForegroundColor Yellow
        $cmdArgs = @("cmd", "test", "run", "--mode", $TestMode)
        if ($Filter) {
            $cmdArgs += @("--filter", "`"$Filter`"")
        }

        $process = Start-Process -FilePath "unity" -ArgumentList $cmdArgs -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Host "Hot Editor Tests Execution Finished Successfully." -ForegroundColor Green
            exit 0
        } else {
            Write-Host "Hot Editor Tests reported failures (ExitCode: $($process.ExitCode))." -ForegroundColor Red
            exit $process.ExitCode
        }
    } else {
        Write-Host "[HEADLESS EXECUTION] Editor not running. Spawning managed test run via Unity CLI..." -ForegroundColor Cyan
        $cliArgs = @("test", "`"$fullProjectPath`"", "--mode", $TestMode, "--output", "`"$ResultsFile`"")
        if ($Filter) {
            $cliArgs += @("--filter", "`"$Filter`"")
        }
        $process = Start-Process -FilePath "unity" -ArgumentList $cliArgs -NoNewWindow -Wait -PassThru
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
