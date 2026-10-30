# Unity CLI & Hot Pipeline Standard (Unity 6 Workflow)

> **Mandatory Rule:** In Unity 6 projects where `com.unity.pipeline` and the `unity` CLI are available, agents MUST prioritize the Unity CLI for compilation checks, test running, and live error diagnosis.

---

## 🚫 1. Prohibited Legacy Practices

1. **No Cold Batchmode When Editor Is Open**: Never execute `Unity.exe -batchmode` when a running editor instance is detected by `unity status`. Doing so fails due to `UnityLockfile` and wastes 30-90 seconds.
2. **No Raw `Editor.log` Ingestion**: Ingesting massive raw `Editor.log` text into LLM contexts is strictly prohibited under token budgeting rules. Use structured JSON from `unity cmd console get` instead.
3. **No Unverified C# Edits**: After writing or modifying C# code, agents must trigger compilation verification via `unity recompile` rather than passing the burden to the developer.

---

## ⚡ 2. Mandatory Unity CLI Workflow

### 2.1. Compilation Verification (Auto-Debugger & Code Writer)
Immediately following any C# modification:
```bash
# 1. Trigger compilation in open editor
unity recompile

# 2. Query structured console ground truth
unity cmd console status
```
* If `compilationFailed` is `false` and `consoleErrors` is `0`, the change is verified.
* If errors exist, query only the errors:
  ```bash
  unity cmd console get --level error
  ```

### 2.2. Automated Testing (Test Engineer)
Run unit/playmode tests through the hot runner:
```bash
unity test --mode EditMode
```
If specific classes were modified, leverage test filtering:
```bash
unity test --mode EditMode --filter "<NamespaceOrClassName>"
```

### 2.3. Token Budget Optimization
Always prefer `--json` or `unity cmd` structured outputs:
* `unity cmd console status`: ~40 tokens (99.8% token savings vs reading `Editor.log`).
* `unity cmd console get --level error`: targeted error traces only.
* Clear console after resolving errors: `unity cmd console clear`.

---

## 🛡️ 3. Fallback Mechanism
If the developer does not have Unity Editor open (`unity status` returns empty or not ready):
* `unity test` and `unity build` automatically invoke headless execution matching `ProjectSettings/ProjectVersion.txt`.
* If the `unity` CLI binary is absent from PATH, fallback to existing static audit scripts (`ci/runner.py`, `ci/run-all-checks.ps1`).
