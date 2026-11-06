# Antigravity Global Rules & Subagent Orchestration (Unity 6 Workflow)

> **Purpose:** This file defines the global behavior of Antigravity agents, context management rules (Token Budgeting), 5 autonomous security mechanisms, subagent routing, multimodal task analysis, and the 3-tier logging system.

---

## 🧠 1. Roles & Task Routing Pipeline

When receiving new tasks, the **Primary Agent** routes work through a step-by-step pipeline:

| Step | Subagent | Input Context | Output Result |
| :--- | :--- | :--- | :--- |
| **0. Task Analysis & Branching** | `Task Analyzer` | Text / Screenshot / Link | **Clarifying Questions + Complexity Tiers Interview + Git Branch Creation + Tracker Entry in `.foragents/PROJECT_MEMORY.md`** |
| **0.1. AI Evolution** | `Workflow Creator` | Agent/Skill Registry + New Task | Generation of new Skills (`SKILL.md`) and Subagents |
| **1. Architecture & Design** | `Code Architect` | Specs + `rules/unity6-vcontainer-architecture.md` | C# Contracts (Interfaces/DTOs) + Implementation Spec |
| **2. Code Implementation** | `Code Writer` | Architect Contract + Target C# File | POCO Class Implementation + **Live Recompilation via `unity recompile`** |
| **3. Audit & Code Review** | `Code Reviewer` | `git diff` + `rules/unity6-performance-gc.md` + Scene/UI Changes | Audit Report (Pass/Fail) + **Mandatory MCP `game_view` Scene Verification** |
| **4. Security & PII Protection** | `Security Auditor` | `git diff` + Secrets/Personal Data | **Human-in-the-Loop Approval Protocol** |
| **4.1. Token & Cost Profiling** | `Token & Cost Profiler` | `transcript.jsonl` + >25k Tokens / Command | **Context Bloat Analysis + Top-Offenders Report + Pre-Commit Budget Audit** |
| **5. Auto-Debugger** | `Auto-Fixer` | Error Stack Trace / Failed Test | **Targeted Error Diagnosis via `unity cmd console get` + Surgical Fix (Max 2 retries)** |
| **6. Automated Testing** | `Test Engineer` | Interview Preference + Native Test Runner | **Warm Editor Execution via `unity test`** (or **SKIPPED** per Developer Interview) |
| **7. Learning (/learn Protocol)** | `Knowledge Learner` | Developer Feedback & Corrections | New Rule Entry in `.foragents/PROJECT_MEMORY.md` |
| **8. Execution Logging** | `Execution Logger` | Pipeline Results | Tier 2 Task Log in `.foragents/logs/log_YYYYMMDD_*.md` |

---

### 🚦 1.1. Task Complexity Tiers & Adaptive Fast-Path Routing

To prevent runaway token expenditure, the Primary Agent routes work through deterministic Complexity Tiers:

| Tier | Target Scope | Pipeline Policy | Token Economy |
| :--- | :--- | :--- | :--- |
| **Tier 0: Micro-Fix** | USS/UXML styles, typos, comments, 1-3 lines of C# | **Subagents strictly PROHIBITED.** Primary Agent edits directly, runs `unity recompile`, and commits. | **~85-90% token reduction** |
| **Tier 1: Prototype / Spike** | PoC, UI mockups, raw features, minor refactoring | `Code Architect` and `Test Engineer` **DISABLED**. Direct execution via Primary / Writer + Reviewer. | **~50-60% token reduction** |
| **Tier 2: Standard Feature** | Business logic, VContainer services, bug fixes | Standard multi-agent pipeline (`Analyzer -> Architect -> Writer -> Reviewer -> Tests`). | Baseline |
| **Tier 3: Mission-Critical** | Core architecture, DI root, security, public API | Full pipeline with comprehensive audits (PII, GC, Warm Tests, MCP `game_view`). | Maximum rigor |

#### ⚡ Auto Mode Classification & Announcement Strings
When `Auto mode` is active (default), the Primary Agent autonomously classifies the request and announces:
- **For Tier 0 (Micro-Fix)**:
  > `⚡ [Auto Mode] Micro-fix or styling update detected. Activating Fast-Path (Tier 0). 🚫 Subagent dispatch is prohibited to optimize token budget and latency.`
- **For Tier 1 (Prototype / Spike)**:
  > `🛠️ [Auto Mode] Feature prototype / draft detected. Activating Tier 1 (Prototype). Disabling Architect specs and NUnit test generation.`

---

## 🛡️ 2. Ten Security & Autonomy Mechanics

1. **`Git State Guard` (Rollback Snapshots)**: Before any major change, a localized `git stash` or `ai-checkpoint` is created for 1-click rollback.
2. **`Self-Correction Protocol` (Auto-Debugger)**: On compilation or test failures, the agent performs up to 2 surgical fixes based on stack traces before escalating to human.
3. **`Human-in-the-Loop Protocol` (PII Approval)**: All operations involving personal data, secrets, or hardcoded paths require explicit developer confirmation.
4. **`Feedback Loop & /learn` (Continuous Learning)**: Developer feedback is immediately persisted into project memory and never repeated.
5. **`Developer Interview Protocol` (Complexity Tiers & Auto Mode)**: At Step 0, the agent conducts an interactive interview prioritizing `(Recommended) Auto mode`, allowing fast-path bypass of heavy subagents.
6. **`Loop & Token Budget Guard` (Iteration Limits)**: A hard limit of 5 retry loops per subagent execution to prevent run-away token expenditure.
7. **`Autonomous Project Setup Guard` (.foragents Auto-Creation)**: If `.foragents/` or `.foragents/PROJECT_MEMORY.md` is missing in the host project root, the workflow automatically initializes it from `.agents/PROJECT_MEMORY_TEMPLATE.md` without requiring manual developer setup.
8. **`Unity CLI & MCP Tools Guard` (Zero-Latency Introspection & Scene Verification)**: When Unity Editor is active, all compilation verification, test running, and error diagnostics are routed through the `unity` CLI and Unity MCP Server (`com.unity.pipeline`). Raw `Editor.log` ingestion is strictly prohibited to optimize token budgets. Furthermore, before completing any task modifying scene or UI objects, agents MUST perform visual verification via MCP `game_view` (`rules/unity-cli-standard.md`).
9. **`Token Budget Guard & Background Profiler` (25,000 Token Alert)**: If any single model request or the active task exceeds **25,000 tokens** (configurable limit), a Budget Alert is triggered. The agent spawns the background `Token & Cost Profiler` (`token-cost-profiler`) to inspect payload bloat and cache efficiency until `pre-commit`.
10. **`Mandatory Pre-Push Cost Summary`**: Before executing any `git push` or prompting `"Push? Да или нет?"`, the Primary Agent MUST execute `.agents/scripts/get-task-cost.ps1` and display the formatted ASCII metrics card containing uncached tokens, prompt cache read, cache hit %, output tokens, execution duration, and estimated USD cost.

---

## ⚡ 3. Token Budgeting & Context Isolation Protocol

1. **No Context Bloat**:
   - Each subagent receives **ONLY** the relevant slice of information required for its specific task.
2. **Handoff by Contract**:
   - Communication between Architect and Writer agents occurs strictly via C# interfaces (`interface IMyService`).
3. **Project Memory Usage**:
   - Agents read `.foragents/PROJECT_MEMORY.md` to instantly acquire the latest architectural context without scanning hundreds of source files.
4. **Package vs Project Data Isolation**:
   - The `.agents` submodule package strictly contains reusable, project-agnostic workflow tools, rules, skills, and subagent profiles.
   - All host project data, active task status, and execution logs must be stored in `.foragents/` at the root of the host project (`.foragents/PROJECT_MEMORY.md`, `.foragents/logs/`) and committed to the host project repository.
5. **Autonomous Project Initialization**:
   - If `.foragents/` or `.foragents/PROJECT_MEMORY.md` does not exist in the host project, agents automatically execute `.agents/scripts/init-foragents.ps1` (or create `.foragents/`, `.foragents/logs/`, and initialize `PROJECT_MEMORY.md` from `PROJECT_MEMORY_TEMPLATE.md`) before executing any task.
6. **Fast-Path Subagent Blocking**:
   - When Tier 0 is active, subagent invocations (`invoke_subagent`) are strictly prohibited to prevent context duplication.
7. **Payload Bounding & Tool Discipline**:
   - File reads must specify `StartLine`/`EndLine` for files exceeding 100 lines.
   - Terminal command outputs must be filtered with grep / Select-String to prevent dumping mega-payloads into context.

---

## 📊 4. Three-Tier Logging Architecture

- **🟢 Tier 1 (`.foragents/PROJECT_MEMORY.md`)**: High-level architectural status and active feature tracking in host project Git.
- **🟡 Tier 2 (`.foragents/logs/log_*.md`)**: Human-readable Markdown task protocols in host project Git for Code Review and Pull Requests. **Must be written strictly in English.**
- **🔴 Tier 3 (`brain/logs`)**: Raw system execution traces of Antigravity IDE tools (stored locally).

---

## 🏗️ 5. Core Unity 6 Architectural Standards

1. **VContainer POCO Only**: It is strictly forbidden to inherit pure logic systems, managers, or controllers from `MonoBehaviour`. All logic is written in plain C# (POCO) and managed via VContainer `LifetimeScope`.
2. **Zero-Allocation Execution**: Inside `ITickable.Tick()` (replacing `Update()`), all `new` allocations, LINQ queries, and boxing are strictly prohibited.
3. **Async & Reactive**: Asynchronous workflows must use **UniTask** with obligatory `CancellationToken` passing. Event subscriptions must use **R3**.
4. **Strict Prohibition of Code Comments**: Writing inline or block comments (`//`, `/* ... */`) in source code is strictly prohibited (`rules/code-style-no-comments.md`). The code must be self-documenting through expressive naming, domain types, and clean architectural decomposition.
5. **Mandatory Unity CLI & MCP Tools Integration**: Use `unity recompile` (or MCP `recompile`), `unity cmd console status`, and `unity test` for automated validation and zero-overhead test execution. Use MCP `game_view` for mandatory visual verification of any objects in the scene before task completion (`rules/unity-cli-standard.md`).
6. **UI Effects & Batching Standard**: UI visual effects, chamfers, and hover transitions must adhere to the GPU-Driven Vertex Injection Pattern (`rules/suif-effects-and-animations.md`), strictly prohibiting runtime material duplication (`new Material()`) and DOM-based clipping (`overflow: hidden` with rotated elements).

---

## 🌿 6. Git Branching & Pull Request Standards

1. **Default & Base Branch (`develop`)**:
   - In both the `ai-workflow` repository and host projects, `develop` is the default active and integration branch.
   - All feature, fix, and refactoring branches (`feature/*`, `fix/*`, `refactor/*`) MUST branch from the latest `develop` (`git checkout develop && git pull origin develop`).
2. **Pull Request Target (`develop`)**:
   - All Pull Requests and merges MUST target `develop`.
   - The `main` branch is reserved strictly for stable release tags.

