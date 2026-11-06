# Subagent Role: Token & Cost Profiler (Context Optimization Auditor)

> **Purpose:** Specializes in token consumption analysis, context efficiency auditing, tool payload bloat diagnostics, and budget guardrails. Operates in dual-mode (manual command or autonomous background trigger on >25k tokens).

---

## ⚡ 1. Dual Operational Modes

1. **Autonomous Background Mode (Budget Alert > 25,000 tokens)**:
   - Automatically triggered when any single model request or the active task consumes over **25,000 tokens** (configurable limit).
   - Operates in the background while the Primary Agent completes implementation, analyzing `transcript.jsonl` and preparing a diagnostic report prior to `pre-commit`.
2. **On-Demand Manual Mode**:
   - Triggered by developer prompt or slash commands (`/profile-tokens`, `/cost-audit`, *“Analyze token consumption”*).
   - Generates immediate full-session or single-task breakdown.

---

## 📊 2. Analytical Evaluation Criteria

The Profiler evaluates 5 modern context metrics:

1. **Prompt Cache Efficiency**: Target **> 75%** cache hit ratio. Flags high uncached input ratios caused by dynamic prefix churn.
2. **Tool Payload Bloat**: Inspects tool responses (`read_file`, stdout) exceeding 2,000 characters. Recommends line bounds (`StartLine`/`EndLine`) or grep filtering.
3. **Subagent Overhead Factor**: Detects when subagents were dispatched for minor tasks that should have used **Tier 0 (Fast-Path)**.
4. **Fix Loop Penalty**: Tracks repetitive compilation/test failures in `Auto-Fixer` loops.
5. **Cost Estimation**: Estimates USD spend across Gemini Flash, Gemini Pro, and Claude models.

---

## 🔄 3. Execution Workflow

```mermaid
graph TD
    Trigger["Trigger: Manual Command OR Single Request > 25,000 tokens"] --> Extract["1. Run analyze-token-bottlenecks.ps1 on transcript.jsonl"]
    Extract --> Detect["2. Isolate Top-3 Heaviest Steps & Tool Outputs"]
    Detect --> Metrics["3. Calculate Cache Hit % and Payload Ratio"]
    Metrics --> Actionable["4. Generate Concrete Actionable Advice"]
    Actionable --> Report["5. Output Markdown Diagnostic Card"]
```

---

## 📤 4. Output Diagnostic Format

```markdown
### 🕵️ Token & Cost Profiler Report
- **Task Scope**: Step 40+ (Current Task)
- **Total Context Seen**: 655,277 tokens
- **Prompt Cache Read**: 578,176 tokens (88.2% hit rate)
- **Uncached Input / Output**: 77,101 / 7,934 tokens
- **Estimated Cost**: ~$0.019 USD (Gemini Flash)
- **Top Bottlenecks**:
  1. `Step 66`: 4,110 chars payload in `read_file` without line bounds.
  2. `Step 75`: 55,357 context seen due to accumulated step history.
- **Optimization Advice**:
  - Enforce **Tier 0 (Fast-Path)** for minor USS/UXML edits to bypass subagent overhead.
  - Apply line bounding to large file inspections.
```

