<#
.SYNOPSIS
Calculates model token metrics, prompt cache efficiency, and estimated cost for the current task or session.

.DESCRIPTION
Parses Antigravity transcript.jsonl logs to extract hardware model metrics:
uncached input tokens, cache read tokens, output tokens, and execution wall-clock time.
Supports customizable token budget alert thresholds (default 25,000 tokens).

.PARAMETER ConversationId
Optional specific conversation ID. If omitted, detects the most recent active session in brain directory.

.PARAMETER AppDataDir
Path to Antigravity app data directory. Defaults to $env:USERPROFILE\.gemini\antigravity.

.PARAMETER Scope
Analysis scope: "Task" (from latest user prompt), "Commit" (since last git commit), or "Session" (full transcript). Default: "Task".

.PARAMETER ThresholdTokens
Configurable threshold limit in tokens per single request or task. Default: 25000.

.PARAMETER Format
Output format: "Table" (formatted ASCII widget), "Summary" (one-liner), or "Json". Default: "Table".
#>
[CmdletBinding()]
param(
    [string]$ConversationId,
    [string]$AppDataDir = "$env:USERPROFILE\.gemini\antigravity",
    [ValidateSet("Task", "Commit", "Session")]
    [string]$Scope = "Task",
    [int]$ThresholdTokens = 25000,
    [ValidateSet("Table", "Summary", "Json")]
    [string]$Format = "Table"
)

function Resolve-TranscriptPath {
    param([string]$AppDir, [string]$ConvId)

    $brainDir = Join-Path $AppDir "brain"
    if (-not (Test-Path $brainDir)) {
        return $null
    }

    if ($ConvId) {
        $candidate = Join-Path $brainDir "$ConvId\.system_generated\logs\transcript.jsonl"
        if (Test-Path $candidate) { return $candidate }
    }

    # Find the most recently modified transcript.jsonl
    $candidates = Get-ChildItem -Path $brainDir -Filter "transcript.jsonl" -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending

    if ($candidates -and $candidates.Count -gt 0) {
        return $candidates[0].FullName
    }
    return $null
}

$transcriptPath = Resolve-TranscriptPath -AppDir $AppDataDir -ConvId $ConversationId
if (-not $transcriptPath) {
    Write-Warning "No active Antigravity transcript.jsonl found."
    return
}

# Read and parse transcript
$lines = Get-Content $transcriptPath -Encoding UTF8 -ErrorAction Stop
$steps = @()
foreach ($line in $lines) {
    if (-not [string]::IsNullOrWhiteSpace($line)) {
        try {
            $steps += (ConvertFrom-Json $line)
        } catch { }
    }
}

if ($steps.Count -eq 0) {
    Write-Warning "Transcript is empty."
    return
}

# Determine scope start index
$startIndex = 0
$scopeDescription = "Full Session"

if ($Scope -eq "Task") {
    $lastUserInput = $steps | Where-Object { $_.type -eq "USER_INPUT" } | Select-Object -Last 1
    if ($lastUserInput) {
        $startIndex = $lastUserInput.step_index
        $scopeDescription = "Current Task (Step $($lastUserInput.step_index)+)"
    }
} elseif ($Scope -eq "Commit") {
    try {
        $lastCommitDateStr = git log -1 --format=%cI 2>$null
        if ($lastCommitDateStr) {
            $lastCommitDate = [DateTime]::Parse($lastCommitDateStr).ToUniversalTime()
            $filtered = $steps | Where-Object {
                if ($_.created_at) {
                    $d = [DateTime]::Parse($_.created_at).ToUniversalTime()
                    $d -ge $lastCommitDate
                } else { $false }
            }
            if ($filtered -and $filtered.Count -gt 0) {
                $startIndex = $filtered[0].step_index
                $scopeDescription = "Since Last Commit ($($lastCommitDate.ToString('HH:mm:ss')))"
            }
        }
    } catch { }
}

$scopedSteps = $steps | Where-Object { $_.step_index -ge $startIndex }
$plannerSteps = $scopedSteps | Where-Object { $_.type -eq "PLANNER_RESPONSE" }

$uncachedIn = ($plannerSteps | Measure-Object -Property input_tokens -Sum).Sum
if (-not $uncachedIn) { $uncachedIn = 0 }

$cachedIn = ($plannerSteps | Measure-Object -Property cache_read_tokens -Sum).Sum
if (-not $cachedIn) { $cachedIn = 0 }

$outputTokens = ($plannerSteps | Measure-Object -Property output_tokens -Sum).Sum
if (-not $outputTokens) { $outputTokens = 0 }

$totalContext = $uncachedIn + $cachedIn
$totalBilledTokens = $uncachedIn + $cachedIn + $outputTokens

$cacheHitRatio = 0.0
if ($totalContext -gt 0) {
    $cacheHitRatio = [Math]::Round(($cachedIn / $totalContext) * 100, 1)
}

# Calculate duration
$durationStr = "N/A"
if ($scopedSteps.Count -gt 1) {
    try {
        $firstTime = [DateTime]::Parse($scopedSteps[0].created_at)
        $lastTime = [DateTime]::Parse($scopedSteps[-1].created_at)
        $diff = $lastTime - $firstTime
        if ($diff.TotalMinutes -ge 1) {
            $durationStr = "{0}m {1:d2}s" -f [int]$diff.TotalMinutes, $diff.Seconds
        } else {
            $durationStr = "{0}s" -f [int]$diff.TotalSeconds
        }
    } catch { }
}

# Pricing estimation (Gemini 2.5 / 3.8 Flash default rates: $0.075 / 1M input, $0.01875 / 1M cache, $0.30 / 1M output)
$rateInput = 0.075 / 1000000.0
$rateCache = 0.01875 / 1000000.0
$rateOutput = 0.30 / 1000000.0
$estimatedCost = ($uncachedIn * $rateInput) + ($cachedIn * $rateCache) + ($outputTokens * $rateOutput)
$costFormatted = if ($estimatedCost -lt 0.01) { "< `$0.01" } else { "`$$([Math]::Round($estimatedCost, 4))" }

# Budget Threshold Evaluation
$isThresholdExceeded = $false
$maxSingleStepTokens = 0
foreach ($p in $plannerSteps) {
    $stepTotal = ($p.input_tokens + $p.output_tokens)
    if ($stepTotal -gt $maxSingleStepTokens) {
        $maxSingleStepTokens = $stepTotal
    }
}
if ($totalBilledTokens -gt $ThresholdTokens -or $maxSingleStepTokens -gt $ThresholdTokens) {
    $isThresholdExceeded = $true
}

$budgetStatus = if ($isThresholdExceeded) {
    "[!] EXCEEDED ($([Math]::Max($totalBilledTokens, $maxSingleStepTokens)) > $ThresholdTokens) -> Profiler Recommended"
} else {
    "OK (Under $ThresholdTokens limit)"
}

$resultObject = [PSCustomObject]@{
    Scope              = $scopeDescription
    PlannerCalls       = $plannerSteps.Count
    UncachedInput      = $uncachedIn
    CacheRead          = $cachedIn
    CacheHitRatio      = "$cacheHitRatio%"
    OutputTokens       = $outputTokens
    TotalContext       = $totalContext
    TotalTokens        = $totalBilledTokens
    Duration           = $durationStr
    EstimatedCost      = $costFormatted
    ThresholdLimit     = $ThresholdTokens
    ThresholdExceeded  = $isThresholdExceeded
    MaxSingleStep      = $maxSingleStepTokens
}

if ($Format -eq "Json") {
    $resultObject | ConvertTo-Json -Depth 3
    return
}

if ($Format -eq "Summary") {
    Write-Output "[$($scopeDescription)] Tokens: $totalBilledTokens (In: $uncachedIn, Cache: $cachedIn ($cacheHitRatio%), Out: $outputTokens) | Turns: $($plannerSteps.Count) | Time: $durationStr | Cost: $costFormatted"
    return
}

# Format Table (ASCII / Unicode widget)
$separator = "+" + ("-" * 61) + "+"
$rowFormat = "| {0,-23} | {1,-33} |"

Write-Output $separator
Write-Output ("| " + ("{0,-59}" -f "TASK TOKEN & COST METRICS ($scopeDescription)") + " |")
Write-Output $separator
Write-Output ($rowFormat -f "Uncached Input", ("{0:N0} tokens" -f $uncachedIn))
Write-Output ($rowFormat -f "Prompt Cache Read", ("{0:N0} tokens ({1} hit)" -f $cachedIn, "$cacheHitRatio%"))
Write-Output ($rowFormat -f "Output Generated", ("{0:N0} tokens" -f $outputTokens))
Write-Output ($rowFormat -f "Total Context Seen", ("{0:N0} tokens" -f $totalContext))
Write-Output ($rowFormat -f "Model Turns", ("{0} calls" -f $plannerSteps.Count))
Write-Output ($rowFormat -f "Task Duration", $durationStr)
Write-Output ($rowFormat -f "Estimated Cost", ("~{0} (Gemini Flash)" -f $costFormatted))
Write-Output ($rowFormat -f "Budget Status", $budgetStatus)
Write-Output $separator
