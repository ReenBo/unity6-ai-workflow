<#
.SYNOPSIS
Analyzes transcript logs to isolate token bottlenecks, heavy tool payloads, and prompt bloat.

.DESCRIPTION
Inspects Antigravity transcript.jsonl, scanning both model response steps and tool execution steps.
Identifies Top-N context consumers, large tool outputs, and cache efficiency to provide actionable advice.
#>
[CmdletBinding()]
param(
    [string]$ConversationId,
    [string]$AppDataDir = "$env:USERPROFILE\.gemini\antigravity",
    [int]$TopCount = 3,
    [int]$ThresholdTokens = 25000
)

function Resolve-TranscriptPath {
    param([string]$AppDir, [string]$ConvId)
    $brainDir = Join-Path $AppDir "brain"
    if (-not (Test-Path $brainDir)) { return $null }

    if ($ConvId) {
        $candidate = Join-Path $brainDir "$ConvId\.system_generated\logs\transcript.jsonl"
        if (Test-Path $candidate) { return $candidate }
    }

    $candidates = Get-ChildItem -Path $brainDir -Filter "transcript.jsonl" -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending
    if ($candidates -and $candidates.Count -gt 0) { return $candidates[0].FullName }
    return $null
}

$transcriptPath = Resolve-TranscriptPath -AppDir $AppDataDir -ConvId $ConversationId
if (-not $transcriptPath) {
    Write-Warning "No active Antigravity transcript.jsonl found."
    return
}

$lines = Get-Content $transcriptPath -Encoding UTF8 -ErrorAction Stop
$steps = @()
foreach ($l in $lines) {
    if (-not [string]::IsNullOrWhiteSpace($l)) {
        try { $steps += (ConvertFrom-Json $l) } catch { }
    }
}

if ($steps.Count -eq 0) {
    Write-Warning "Transcript is empty."
    return
}

# Scope to latest task (last USER_INPUT)
$lastUserInput = $steps | Where-Object { $_.type -eq "USER_INPUT" } | Select-Object -Last 1
$startIdx = if ($lastUserInput) { $lastUserInput.step_index } else { 0 }
$scopedSteps = $steps | Where-Object { $_.step_index -ge $startIdx }

$plannerSteps = $scopedSteps | Where-Object { $_.type -eq "PLANNER_RESPONSE" }
$genericSteps = $scopedSteps | Where-Object { $_.type -eq "GENERIC" -or $_.source -eq "TOOL" }

# 1. Heaviest Model Steps
$heavyModelSteps = $plannerSteps | Sort-Object { $_.input_tokens + $_.output_tokens } -Descending | Select-Object -First $TopCount

# 2. Heaviest Tool Outputs
$heavyTools = $scopedSteps | Where-Object { $_.content -and $_.type -ne "USER_INPUT" } |
    Select-Object step_index, @{N="CharLength"; E={$_.content.Length}}, @{N="Snippet"; E={$_.content.Substring(0, [Math]::Min(120, $_.content.Length)).Replace("`r`n", " ").Replace("`n", " ")}} |
    Sort-Object CharLength -Descending |
    Select-Object -First $TopCount

# 3. Tool Usage Statistics
$toolCalls = @()
foreach ($ps in $plannerSteps) {
    if ($ps.tool_calls) {
        foreach ($tc in $ps.tool_calls) {
            $toolCalls += $tc.name
        }
    }
}
$toolStats = $toolCalls | Group-Object | Select-Object Name, Count | Sort-Object Count -Descending

# 4. Cache Efficiency
$totalUncached = ($plannerSteps | Measure-Object -Property input_tokens -Sum).Sum
$totalCached = ($plannerSteps | Measure-Object -Property cache_read_tokens -Sum).Sum
$totalSeen = $totalUncached + $totalCached
$cacheRatio = if ($totalSeen -gt 0) { [Math]::Round(($totalCached / $totalSeen) * 100, 1) } else { 0 }

# Formatting Output
Write-Output "================================================================="
Write-Output "🕵️ TOKEN & COST PROFILER: BOTTLENECK DIAGNOSTIC REPORT"
Write-Output "================================================================="
Write-Output "Analysis Scope: Current Task (from step $startIdx)"
Write-Output "Cache Hit Efficiency: $cacheRatio% (Cached: $totalCached / Context: $totalSeen)"
Write-Output ""

Write-Output "--- TOP MODEL CONTEXT SPIKES ---"
foreach ($ms in $heavyModelSteps) {
    $tIn = $ms.input_tokens
    $tCache = $ms.cache_read_tokens
    $tOut = $ms.output_tokens
    Write-Output "Step $($ms.step_index): In: $tIn | Cache: $tCache | Out: $tOut (Total: $($tIn + $tCache + $tOut))"
}
Write-Output ""

Write-Output "--- TOP HEAVY TOOL OUTPUTS (Payload Bloat) ---"
foreach ($ht in $heavyTools) {
    Write-Output "Step $($ht.step_index): $($ht.CharLength) characters -> $($ht.Snippet)..."
}
Write-Output ""

Write-Output "--- TOOL INVOCATION BREAKDOWN ---"
foreach ($ts in $toolStats) {
    Write-Output "  $($ts.Name): $($ts.Count) calls"
}
Write-Output ""

Write-Output "--- ACTIONABLE BOTTLENECK RECOMMENDATIONS ---"
$adviceCount = 0
if ($cacheRatio -lt 70 -and $totalSeen -gt $ThresholdTokens) {
    Write-Output "💡 [Prompt Cache]: Cache hit is low ($cacheRatio%). Minimize dynamic text injected before static instruction blocks."
    $adviceCount++
}
if ($toolStats | Where-Object { $_.Name -eq "read_file" -and $_.Count -gt 5 }) {
    Write-Output "💡 [File Reads]: Frequent read_file calls detected. Use StartLine/EndLine slices or ripgrep rather than whole file dumps."
    $adviceCount++
}
if ($heavyTools | Where-Object { $_.CharLength -gt 4000 }) {
    Write-Output "💡 [Stdout Bloat]: Oversized tool outputs detected (>4000 chars). Filter terminal commands with grep/Select-String to keep context lean."
    $adviceCount++
}
if ($plannerSteps.Count -gt 10) {
    Write-Output "💡 [Orchestration]: High step count ($($plannerSteps.Count) turns). For simple tasks, enforce Tier 0 (Fast-Path) to bypass multi-agent overhead."
    $adviceCount++
}
if ($adviceCount -eq 0) {
    Write-Output "✅ Context consumption is balanced. No severe bottlenecks detected."
}
Write-Output "================================================================="

