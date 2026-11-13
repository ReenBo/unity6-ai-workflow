# Unity CLI & MCP Tools Standard (Unity 6 Workflow)

> **Mandatory Rule:** In Unity 6 projects where `com.unity.pipeline`, the `unity` CLI, and the Unity MCP Server are available, agents MUST prioritize the Unity CLI and MCP Tools for compilation checks, live error diagnosis, runtime introspection, and **mandatory visual verification of any objects in the scene before task completion**.

---

## 🚫 1. Prohibited Legacy Practices

1. **No Cold Batchmode When Editor Is Open**: Never execute `Unity.exe -batchmode` when a running editor instance is detected by `unity status`. Doing so fails due to `UnityLockfile` and wastes 30-90 seconds.
2. **No Raw `Editor.log` Ingestion**: Ingesting massive raw `Editor.log` text into LLM contexts is strictly prohibited under token budgeting rules. Use structured JSON from `unity cmd console get` or MCP console inspection instead.
3. **No Unverified C# Edits**: After writing or modifying C# code, agents must trigger compilation verification via `unity recompile` (or MCP `recompile`) rather than passing the burden to the developer.
4. **No Blind Task Completion (Visual Verification Mandate)**: Marking any task as complete that modifies UI elements, 3D/2D scenes, shaders, materials, cameras, or visual GameObjects without performing visual inspection via MCP `game_view` is strictly prohibited.

---

## ⚡ 2. Mandatory Unity CLI & MCP Tools Workflow

### 2.1. Compilation Verification (Auto-Debugger & Code Writer)
Immediately following any C# modification:
```bash
# 1. Trigger compilation in open editor (CLI or MCP recompile)
unity recompile

# 2. Query structured console ground truth
unity cmd console status
```
* If `compilationFailed` is `false` and `consoleErrors` is `0`, the change is verified.
* If errors exist, query only the errors with zero log bloat:
  ```bash
  unity cmd console get --level error
  ```
* Clear console after resolving errors: `unity cmd console clear`.

### 2.2. Runtime State Introspection & Event Simulation
* **Safe Roslyn `eval`**: Use MCP `eval` to verify VContainer dependency resolution, reactive R3 streams, and visual element hierarchies in the active AppDomain. MCP `eval` compiles inside a method body, so use fully-qualified type names (`UnityEngine.Object`, `System.Reflection.BindingFlags`) instead of top-level `using` directives.
  > [!CAUTION]
  > Never execute synchronous blocking calls (e.g., `Thread.Sleep()`, `.GetAwaiter().GetResult()`) inside `eval`. Blocking the Unity main thread hangs the PlayerLoop and crashes the Pipeline server. Always use `async void` or non-blocking queries.
* **UI Toolkit Batching & Draw Call Audit**: In PlayMode, inspect `UIRenderDevice.GatherDrawStatistics()` (`drawCommandCount`, `drawRangeCount`, `drawRangeCallCount`), `RenderTree.m_FirstCommand` (`texture`, `stencilRef`, `material`, `flags`), and `TextureRegistry` via MCP `eval` to pinpoint batch breaks without adding debug MonoBehaviours.
* **Input Simulation**: Use MCP `simulate_pointer` and UI Toolkit event dispatching (`NavigationSubmitEvent`, `ClickEvent`) for autonomous UI testing and button validation without requiring manual clicks from the developer.

### 2.3. Mandatory Visual Verification of Scene Objects (MCP `game_view`)
Before completing any task, opening a PR, or requesting developer review for changes involving scene objects or UI:
1. **Capture Composite Screen View**:
   Call MCP `game_view` with `source: "screen"` and reference resolution (e.g., 1920x1080) to capture the composite frame including Screen Space - Overlay UI Toolkit canvases and cameras. **Never write temporary screenshots inside `Assets/`** (it triggers `AssetDatabase` imports and `.meta` churn); store temporary captures in the conversation `scratch/` directory if needed.
2. **Visual Inspection**:
   Inspect the captured image to verify:
   * **Layout Fidelity**: No overlapping boxes, clipping, or incorrect anchor alignments.
   * **Text Integrity**: Multi-line strings wrap cleanly (`white-space: normal`) without running off container edges.
   * **Visual Hierarchy & Contrast**: Themes, borders, colors, and active states render as specified in design contracts.
   * **Regression Check**: Background viewports and inactive elements correctly transition to standby or hidden states.

### 2.4. Targeted Automated Testing (Test Engineer)
Running entire test suites indiscriminately is prohibited. Always scope test runs strictly to modified files or fixtures using filters:
```bash
# Target specific fixture, class, or method
unity test --mode EditMode --filter "<NamespaceOrClassName>"
```

### 2.5. Token Budget Optimization & Terminal Bounding
Always prefer structured JSON or MCP tool responses over raw text streams:
* `unity cmd console status`: ~40 tokens (99.8% token savings vs reading `Editor.log`).
* `unity cmd console get --level error`: targeted error traces only.
* MCP `recompile`: ~25 tokens structured status.
* **Terminal Truncation**: When running CLI commands with potentially verbose outputs, pipe through `Select-Object -Last 50` or filter with `Select-String` (grep). Raw dumps of build logs or console streams into LLM context are prohibited.

---

## 🛡️ 3. Fallback Mechanism
If the developer does not have Unity Editor open (`unity status` returns empty or not ready):
* `unity test` and `unity build` automatically invoke headless execution matching `ProjectSettings/ProjectVersion.txt`.
* If the `unity` CLI binary is absent from PATH, fallback to existing static audit scripts (`ci/runner.py`, `ci/run-all-checks.ps1`).
