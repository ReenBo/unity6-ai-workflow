# Antigravity Global Rules & Subagent Orchestration (Unity 6 Workflow)

> **Purpose:** This file defines the global behavior of Antigravity agents, context management rules (Token Budgeting), 5 autonomous security mechanisms, subagent routing, multimodal task analysis, and the 3-tier logging system.

---

## 🧠 1. Roles & Task Routing Pipeline

When receiving new tasks, the **Primary Agent** routes work through a step-by-step pipeline:

| Step | Subagent | Input Context | Output Result |
| :--- | :--- | :--- | :--- |
| **0. Task Analysis & Branching** | `Task Analyzer` | Text / Screenshot / Link | **Clarifying Questions + CI/CD & Testing Interview + Git Branch Creation + Tracker Entry in `.foragents/PROJECT_MEMORY.md`** |
| **0.1. AI Evolution** | `Workflow Creator` | Agent/Skill Registry + New Task | Generation of new Skills (`SKILL.md`) and Subagents |
| **1. Architecture & Design** | `Code Architect` | Specs + `rules/unity6-vcontainer-architecture.md` | C# Contracts (Interfaces/DTOs) + Implementation Spec |
| **2. Code Implementation** | `Code Writer` | Architect Contract + Target C# File | POCO Class Implementation |
| **3. Audit & Code Review** | `Code Reviewer` | `git diff` + `rules/unity6-performance-gc.md` | Audit Report (Pass/Fail) + Refinements |
| **4. Security & PII Protection** | `Security Auditor` | `git diff` + Secrets/Personal Data | **Human-in-the-Loop Approval Protocol** |
| **5. Auto-Debugger** | `Auto-Fixer` | Error Stack Trace / Failed Test | Surgical Fix (Maximum 2 autonomous retries) |
| **6. Automated Testing** | `Test Engineer` | Interview Preference + Native Test Runner | EditMode / PlayMode Test Runs (or **SKIPPED** per Developer Interview) |
| **7. Learning (/learn Protocol)** | `Knowledge Learner` | Developer Feedback & Corrections | New Rule Entry in `.foragents/PROJECT_MEMORY.md` |
| **8. Execution Logging** | `Execution Logger` | Pipeline Results | Tier 2 Task Log in `.foragents/logs/log_YYYYMMDD_*.md` |

---

## 🛡️ 2. Seven Security & Autonomy Mechanics

1. **`Git State Guard` (Rollback Snapshots)**: Before any major change, a localized `git stash` or `ai-checkpoint` is created for 1-click rollback.
2. **`Self-Correction Protocol` (Auto-Debugger)**: On compilation or test failures, the agent performs up to 2 surgical fixes based on stack traces before escalating to human.
3. **`Human-in-the-Loop Protocol` (PII Approval)**: All operations involving personal data, secrets, or hardcoded paths require explicit developer confirmation.
4. **`Feedback Loop & /learn` (Continuous Learning)**: Developer feedback is immediately persisted into project memory and never repeated.
5. **`Developer Interview Protocol` (CI/CD & Testing Scope)**: At Step 0, the agent conducts an interactive interview asking whether CI/CD builds or unit/playmode tests are required for the task, avoiding unnecessary heavy test overhead.
6. **`Loop & Token Budget Guard` (Iteration Limits)**: A hard limit of 5 retry loops per subagent execution to prevent run-away token expenditure.
7. **`Autonomous Project Setup Guard` (.foragents Auto-Creation)**: If `.foragents/` or `.foragents/PROJECT_MEMORY.md` is missing in the host project root, the workflow automatically initializes it from `.agents/PROJECT_MEMORY_TEMPLATE.md` without requiring manual developer setup.


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

---

## 🌿 6. Git Branching & Pull Request Standards

1. **Default & Base Branch (`develop`)**:
   - In both the `ai-workflow` repository and host projects, `develop` is the default active and integration branch.
   - All feature, fix, and refactoring branches (`feature/*`, `fix/*`, `refactor/*`) MUST branch from the latest `develop` (`git checkout develop && git pull origin develop`).
2. **Pull Request Target (`develop`)**:
   - All Pull Requests and merges MUST target `develop`.
   - The `main` branch is reserved strictly for stable release tags.

