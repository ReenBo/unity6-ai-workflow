---
name: token-cost-profiler
description: Analyzes execution transcripts for token consumption spikes, tool payload bloat (oversized file reads, verbose logs), measures cache efficiency, and generates optimization advice.
---

# Token & Cost Profiler Skill

> **Purpose:** Automated diagnostic skill for pinpointing context bloat, token consumption bottlenecks, and execution latency. Enables evidence-based token optimization across subagents and tools.

---

## 🔍 1. Trigger Conditions

1. **Automatic Threshold Trigger (`Budget Alert`)**:
   - Fires automatically when any single model request or the current task exceeds **25,000 tokens** (configurable in `AGENTS.md`).
   - Runs independently in background mode until pre-commit, analyzing logs and preparing a bottleneck diagnosis.
2. **Manual Invocation**:
   - Developer command: `/profile-tokens`, `/cost-audit`, or explicit prompt *“Analyze token consumption”*.

---

## 📊 2. Modern Analytical Metrics

| Metric | Target / Benchmark | Formula / Meaning |
| :--- | :--- | :--- |
| **Cache Hit Ratio (CHR)** | **> 75%** | `cache_read_tokens / (input_tokens + cache_read_tokens)`. Below 50% indicates cache invalidation due to dynamic prompt prefixes. |
| **Tool Payload Ratio (TPR)** | **< 20%** of context | Size of tool outputs (`read_file`, terminal stdout) relative to prompt size. Flags bloated reads. |
| **Subagent Dispatch Tax (SDT)** | **0 for Tier 0** | Context duplicated across subagent transitions. Evaluates whether multi-agent pipeline was necessary. |
| **Fix Loop Penalty (FLP)** | **0-1 retries** | Number of repetitive compilation / test fix loops. Flags runaway auto-fixer loops. |
| **Code Efficiency Index (CEI)** | **High** | Changed lines in `git diff` relative to total context consumed. |

---

## 🛠️ 3. Execution Algorithm

1. **Extract Metrics**:
   - Run `.agents/skills/token-cost-profiler/scripts/analyze-token-bottlenecks.ps1` to parse `transcript.jsonl`.
2. **Identify Top Offenders**:
   - List Top-3 most expensive steps (by `input_tokens` or tool output payload).
   - Check if large files (>200 lines) were read entirely instead of targeted slicing (`StartLine`/`EndLine`).
3. **Formulate Actionable Advice**:
   - If styles/markup were touched: *Recommend Fast-Path (Tier 0) to eliminate subagent dispatch tax.*
   - If terminal output exceeded 50 lines: *Recommend piping through grep / Select-String or using Unity CLI concise modes.*
   - If repetitive retries detected: *Advise manual inspection or targeted compiler error querying.*
4. **Report Generation**:
   - Output concise diagnostic Markdown card into chat and attach to Tier 2 execution logs if critical.

