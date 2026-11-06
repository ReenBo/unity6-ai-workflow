# Token Budgeting & Context Isolation Rules

## 1. Context Handoff Limits
To maintain maximum response quality and token efficiency, the following context slice limits apply:

| Subagent Role | Max Input Context Size | Input Data Format |
| :--- | :--- | :--- |
| `Task Analyzer` | ~400 lines | Prompt / Link / Screenshot description |
| `Code Architect` | ~500 lines | Spec + `PROJECT_MEMORY.md` |
| `Code Writer` | ~300 lines | C# Interface Contract + Single Target File |
| `Code Reviewer` | ~150 lines | Git diff + GC/DI checklist |
| `Security Auditor` | ~150 lines | Git diff + Secrets/PII patterns |
| `Execution Logger` | ~100 lines | Execution Metadata (Status, Files, Result) |

---

## 2. Handoff Contract Format
Information handoff between agents occurs strictly via structured blocks:

```markdown
### HANDOFF CONTRACT
- **Goal**: Implement ore yield calculation service.
- **Interfaces**:
```csharp
public interface IMiningCalculator {
    float CalculateYield(int minerLevel, float nodeDensity);
}
```
- **Target File**: `Assets/_project/Scripts/GameLogic/Services/MiningCalculator.cs`
```

---

## 3. Chat & Generation Discipline
- **Concise Responses**: Provide concise, actionable responses. Do not generate conversational filler, apologies, or unrequested essays.
- **No Redundant Code Re-printing**: Never print full files, classes, or large code snippets in chat that have already been applied via `edit_file` or `write_file`. Provide only clickable file links with line ranges (e.g., `[MiningService.cs#L20-L35](file:///...)`) or minimal 1-2 line diff snippets.
- **Surgical Edits Only**: Always use targeted replacements (`edit_file`) instead of full file overwrites. Unprompted opportunistic refactoring, whitespace reformatting, or touching adjacent code outside the task scope is strictly prohibited.

---

## 4. File Access & Context Hygiene (Unity 6 Scope)
- **Search Before Read**: Never open files blindly. Locate the exact symbol, class, or method via grep / symbol search before opening a file.
- **100-Line Bounding Mandate**: For any file exceeding 100 lines, ALWAYS specify `StartLine` and `EndLine`. Reading entire large files is strictly forbidden.
- **Prohibited Files & Dirs (Unity 6 Scope)**:
  - **Engine & Build Caches**: `Library/`, `Temp/`, `obj/`, `Build/`, `Builds/`.
  - **Raw Log Streams**: `Editor.log`, `Player.log`, `upm.log` (always query structured JSON via `unity cmd console get`).
  - **Massive Serialized YAML Assets**: `*.unity` (scenes), `*.prefab`, `*.asset` must never be read wholly into context (use Unity CLI/MCP or targeted grep for GUIDs).
  - **Metadata & Lockfiles**: Never inspect `*.meta` or `Packages/packages-lock.json` unless actively troubleshooting GUID collisions or package dependency resolution.

---

## 5. Tool Call Circuit Breaker
- **15-Step Tool Call Limit**: If a subtask executes **15 consecutive tool calls** without reaching a verified milestone (such as successful `unity recompile`, passed targeted test, or artifact generation), execution MUST be paused immediately to report progress and ask the user for confirmation.

---

## 6. Terminal Output Budgeting
- **Pipelined Output Bounding**: Always truncate potentially large terminal outputs using `Select-Object -Last 50` (PowerShell) or `Select-String` (grep).
- **Targeted Test Execution**: Run only the specific test or assembly matching the modified file via `unity test --filter <TestName>` rather than running the entire project suite.
