# PowerShell Script: Autonomous .foragents Initialization for AI Workflow
param (
    [string]$ProjectRoot = ""
)

$ErrorActionPreference = "Stop"

if (-not $ProjectRoot) {
    $current = Split-Path -Parent $MyInvocation.MyCommand.Path
    while ($current -and (Split-Path -Leaf $current) -ne ".agents") {
        $parent = Split-Path -Parent $current
        if ($parent -eq $current) { break }
        $current = $parent
    }
    if ($current -and (Split-Path -Leaf $current) -eq ".agents") {
        $ProjectRoot = Split-Path -Parent $current
    } else {
        $ProjectRoot = (Get-Location).Path
    }
}

$agentsDir = Join-Path $ProjectRoot ".agents"
$foragentsDir = Join-Path $ProjectRoot ".foragents"
$logsDir = Join-Path $foragentsDir "logs"
$memoryFile = Join-Path $foragentsDir "PROJECT_MEMORY.md"
$readmeFile = Join-Path $foragentsDir "README.md"
$templateFile = Join-Path $agentsDir "PROJECT_MEMORY_TEMPLATE.md"

Write-Host "=== AI Workflow: Verifying .foragents Directory ===" -ForegroundColor Cyan
Write-Host "Target Host Project: $ProjectRoot"

# 1. Ensure .foragents directory
if (-not (Test-Path $foragentsDir)) {
    Write-Host "[+] Creating $foragentsDir ..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $foragentsDir -Force | Out-Null
} else {
    Write-Host "[OK] $foragentsDir exists." -ForegroundColor Green
}

# 2. Ensure logs directory
if (-not (Test-Path $logsDir)) {
    Write-Host "[+] Creating $logsDir ..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
} else {
    Write-Host "[OK] $logsDir exists." -ForegroundColor Green
}

# 3. Ensure PROJECT_MEMORY.md
if (-not (Test-Path $memoryFile)) {
    if (Test-Path $templateFile) {
        Write-Host "[+] Initializing $memoryFile from template..." -ForegroundColor Yellow
        Copy-Item -Path $templateFile -Destination $memoryFile
    } else {
        Write-Host "[!] Template not found at $templateFile. Generating default PROJECT_MEMORY.md..." -ForegroundColor Yellow
        $lines = @(
            "# Project Memory and Active Status",
            "",
            "## 1. Active Status and Task Tracker",
            "- [ ] Initial project task.",
            "",
            "## 2. Architectural Decisions Record (ADR)",
            "* VContainer POCO architecture.",
            "* Zero-allocation in Tick().",
            "",
            "## 3. Known Gotchas and Technical Debt",
            "* None recorded.",
            "",
            "## 4. Last Session Log",
            "* Initialized .foragents directory."
        )
        Set-Content -Path $memoryFile -Value $lines -Encoding UTF8
    }
} else {
    Write-Host "[OK] $memoryFile exists." -ForegroundColor Green
}

# 4. Ensure README.md
if (-not (Test-Path $readmeFile)) {
    Write-Host "[+] Creating $readmeFile ..." -ForegroundColor Yellow
    $readmeLines = @(
        "# .foragents: Project Memory and Task Execution Logs",
        "",
        "> **Purpose:** This folder stores project-specific AI workflow data, architectural decisions, and human-readable task logs.",
        "> All files in this folder are tracked in the host project Git repository.",
        "",
        "## Structure",
        "- `PROJECT_MEMORY.md` (Tier 1): High-level architectural status and task registry.",
        "- `logs/` (Tier 2): Markdown reports for code review and Pull Requests."
    )
    Set-Content -Path $readmeFile -Value $readmeLines -Encoding UTF8
} else {
    Write-Host "[OK] $readmeFile exists." -ForegroundColor Green
}

Write-Host "=== .foragents verification complete! ===" -ForegroundColor Green
