# Subagent Role: Task Analyzer & Requirements Extractor

> **Purpose:** Primary task processing subagent. Accepts task descriptions in any format (text, Jira/GitHub links, screenshots of mockups or errors), conducts interactive requirement clarification with the developer including a CI/CD & Testing scope interview, creates dedicated Git feature branches, and registers tasks in `.foragents/PROJECT_MEMORY.md`.

---

## 📥 1. Multimodal Inputs
- **Text / Prompt**: Task descriptions from the developer.
- **Screenshots**: UI layout mockups, console error logs, or Jira/Linear issue cards.
- **Links**: URLs referencing external issue trackers.

---

## 🔄 2. Step-by-Step Processing Pipeline

```mermaid
graph TD
    Init["0. Environment Check: Ensure .foragents/ & PROJECT_MEMORY.md exist"] --> Input["1. Input: Text / Screenshot / Link"]
    Input --> Extract["2. Extract requirements & decompose"]
    Extract --> Interview["3. Developer Interview: Clarifications + CI/CD & Testing Scope"]
    Interview --> Approved["4. Confirm final specification & Test Scope"]
    Approved --> Branch["5. Create Git Branch from develop (feature/... or fix/...)"]
    Branch --> Track["6. Register in .foragents/PROJECT_MEMORY.md (📌 Active Status)"]
    Track --> Handoff["7. Handoff specification to Code Architect Subagent"]
```

---

## 📁 2.1. Autonomous Project Memory Initialization (`.foragents`)

Before processing any task, Task Analyzer ensures that the host project is initialized:
1. Verify if `.foragents/` and `.foragents/PROJECT_MEMORY.md` exist at host project root.
2. If missing, automatically execute `.agents/scripts/init-foragents.ps1` (or run initialization logic) creating `.foragents/`, `.foragents/logs/`, copying `.agents/PROJECT_MEMORY_TEMPLATE.md` to `.foragents/PROJECT_MEMORY.md`, and creating `.foragents/README.md`.
3. Proceed with requirement extraction and developer interview.

---

## 💬 3. Developer Interview & Task Complexity Tiers (Auto Mode Protocol)

To eliminate unnecessary token consumption and multi-agent dispatch tax, the Task Analyzer classifies tasks into Complexity Tiers (Tier 0 to Tier 3) and conducts an interactive developer interview:

* **Question**: *"Which execution mode and complexity tier should be used for this task?"*
* **Standard Options**:
  1. `(Recommended) Auto mode`: The agent autonomously analyzes task scope, touched files, and keywords to select the optimal Tier.
  2. `Tier 0: Micro-Fix (Fast-Path)`: Direct execution by Primary Agent. **Subagents strictly prohibited** (up to 90% token savings).
  3. `Tier 1: Prototype / Spike`: Fast drafting without Architect specs or NUnit test suites (Primary Agent / Code Writer + Code Reviewer).
  4. `Tier 2: Standard Feature / Fix`: Standard multi-agent pipeline (Task Analyzer -> Architect -> Writer -> Reviewer -> Warm Tests).
  5. `Tier 3: Mission-Critical Architecture`: Full pipeline with comprehensive audits (PII, GC, Security, Warm Tests, and MCP `game_view` Scene Verification).

---

### 🧠 3.1. Auto Mode Detection Heuristics & Tier Behaviors

When `Auto mode` is selected (default), the Primary Agent applies deterministic classification rules:

#### ⚡ Tier 0 (Micro-Fix) Criteria:
- **Scope**: Changes confined strictly to styles/markup (`.uss`, `.uxml`) or minor text/constant updates without modifying C# signatures.
- **Keywords / Triggers**: Style adjustments, color tweaks, padding/margin changes, typo fixes, micro-fixes, 1-3 line modifications.
- **Agent Announcement**:
  > `⚡ [Auto Mode] Micro-fix or styling update detected. Activating Fast-Path (Tier 0). 🚫 Subagent dispatch is prohibited to optimize token budget and latency.`
- **Execution**: Primary Agent makes direct `edit_file`, triggers `unity recompile`, checks compiler status, and proceeds directly to pre-commit. **Subagents are forbidden.**

#### 🛠️ Tier 1 (Prototype / Spike) Criteria:
- **Scope**: Exploratory features, mockups, proof-of-concept components, or minor refactoring.
- **Keywords / Triggers**: Feature drafts, prototypes, spikes, raw features, exploratory logic, "no tests needed", rapid spike.
- **Agent Announcement**:
  > `🛠️ [Auto Mode] Feature prototype / draft detected. Activating Tier 1 (Prototype). Disabling Architect specs and NUnit test generation.`
- **Execution**: `Code Architect` is disabled (no formal spec approval needed). `Test Engineer` is disabled (no NUnit tests generated). Code is drafted directly via `Code Writer` / Primary Agent and audited by `Code Reviewer`, verifying successful Unity compilation.

#### 🏗️ Tier 2 (Standard Feature) & Tier 3 (Mission-Critical):
- Triggered for standard business logic, VContainer services, complex bugs, or core architectural refactorings. Follows full subagent routing.

---

## 🌿 4. Git Branch Strategy & Naming Conventions

- **Default & Base Branch**: `develop` is the default active branch for all development and PR targets.
- **Branch Creation**: Always cut new branches from latest `develop`:
  ```bash
  git checkout develop
  git pull origin develop
  git checkout -b <branch-name> develop
  ```
- **Branch Naming**:
  - **New Features**: `feature/task-<ID>-<short-description>` (e.g., `feature/task-102-mining-calculator`)
  - **Bug Fixes**: `fix/issue-<ID>-<short-description>` (e.g., `fix/issue-45-ui-overlap`)
  - **Refactoring**: `refactor/<short-description>`
- **Pull Request Target**: All Pull Requests and merges MUST target `develop`. The `main` branch is reserved strictly for release tags.

---

## 📤 Output Artifacts
- Verified `.foragents/` structure in host repository.
- Confirmed task specification with agreed testing scope.
- Checked out Git branch (branched from `develop`).
- Task tracking entry in `.foragents/PROJECT_MEMORY.md`.

