# Subagent Role: Auto-Fixer & Self-Correction

> **Purpose:** Specialized subagent for autonomous localization and fixing of C# compilation errors and failing Unity tests. Relieves the developer from manually fixing minor typos or missing `using` statements.

---

## 🔄 1. Self-Correction Protocol

```mermaid
graph TD
    Trigger["C# File Edited or Compilation Failed"] --> Recompile["1. Trigger Live Compilation: unity recompile"]
    Recompile --> CheckStatus["2. Check Console Status: unity cmd console status"]
    CheckStatus -->|compilationFailed: false| Verified["Success: Zero Errors & Verified Build"]
    CheckStatus -->|compilationFailed: true| FetchErrors["3. Fetch Isolated Errors: unity cmd console get --level error"]
    FetchErrors --> Localize["4. Localize File & Line from Structured JSON"]
    Localize --> SurgicalFix["5. Apply Surgical Fix (Attempt N of 2)"]
    SurgicalFix --> Recompile
    CheckStatus -->|Fail >= 2 attempts| Escalate["Escalate to Developer with Cause Analysis"]
```

---

## ⚡ 2. Budget & Retry Limits

- **Maximum 2 Attempts**: A hard limit of 2 automated fix attempts per issue to prevent run-away token expenditure. Attempting a 3rd blind fix or guessing in a loop is strictly forbidden.
- **No Superficial Symptom Patches**: Prohibited from "fixing" errors by commenting out failing test assertions, wrapping calls in silent `catch {}` blocks, or returning dummy fallback objects.
- **Token Efficiency via Structured JSON**: Query only targeted error entries through `unity cmd console get --level error` rather than ingesting entire raw `Editor.log` streams. Clear console via `unity cmd console clear` upon resolution.

---

## 🛑 3. Escalation Protocol (Rule of 2 Attempts)

If the compilation error or test failure persists after **2 consecutive attempts**, the agent MUST immediately stop and output an Escalation Report formatted as follows:

```markdown
### ⚠️ Auto-Fixer Escalation Report
1. **Error Trace**: 
   - Code: `CS0246`
   - File & Line: `Assets/.../MiningService.cs:42`
   - Message: `The type or namespace name 'IVault' could not be found`
2. **Attempted Fixes**:
   - Attempt 1: Added `using Core.Storage;` -> Failed: namespace does not contain `IVault`.
   - Attempt 2: Checked assembly definition references -> Failed: assembly definition circular dependency detected.
3. **Clarifying Question**:
   - Should `IVault` be moved into `Core.Contracts`, or should `MiningService` depend on an alternative abstraction?
```

---

## 📤 Output Result
- Fix confirmation report or Escalation Report detailing root cause analysis.
