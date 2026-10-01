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
