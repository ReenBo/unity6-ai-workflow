# Unity 6 AI Workflow & Antigravity Agents Repository

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Author](https://img.shields.io/badge/author-Reen__Bo-purple.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Unity](https://img.shields.io/badge/unity-6.0%2B-black.svg)
![Architecture](https://img.shields.io/badge/architecture-VContainer%20POCO-purple.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-orange.svg)

Ecosystem of global/project rules, self-evolving subagents (Workflow Creator), data privacy protection (Security Auditor), cross-platform Python runner (`ci/runner.py`), universal CI/CD templates (GitHub, GitLab, Bitbucket, Azure), automated rollback checkpoints (Git State Guard), memory synchronization (Memory Sync), auto-debugging (Auto-Fixer), headless test execution (Unity Test Runner), and a 3-tier logging architecture for team application development on **Unity 6** using **Antigravity IDE (Gemini 3.6 Flash / Claude 3.7)**.

*Read this document in Russian: [README_RU.md](README_RU.md)*  
*Full Documentation (English): [DOCUMENTATION.md](DOCUMENTATION.md)* | *(Russian): [DOCUMENTATION_RU.md](DOCUMENTATION_RU.md)*

---

## 🎯 Core Goals & Architectural Ideology

1. **Multimodal Task Analysis & Branching (Task Analyzer)**: Accepts tasks as text, links, or **screenshots**, conducts requirement clarification interviews (including CI/CD and testing scope interview), auto-creates Git feature branches (`feature/...`), and tracks progress in `.foragents/PROJECT_MEMORY.md`.
2. **Cross-Platform Python Runner (`ci/runner.py`)**: 100% consistent execution of VContainer, PII leak, and GC allocation audits across **Windows**, **macOS**, and **Linux**.
3. **Provider-Agnostic CI/CD**: Unified check runner `ci/run-all-checks.ps1` / `ci/run-all-checks.sh` / `ci/runner.py` with ready-to-use templates for **GitHub Actions**, **GitLab CI**, **Bitbucket Pipelines**, and **Azure DevOps**.
4. **Security & Checkpoint Rollback (Git State Guard)**: Automatic creation of `git stash` / `ai-checkpoint` before major refactoring tasks for 1-click rollback.
5. **Memory Synchronization (Memory Sync)**: Automatic updating of `.foragents/PROJECT_MEMORY.md` from `git status` and `git diff`.
6. **Data Privacy & Human-in-the-Loop (Security Auditor)**: Ensures zero leaks of personal identifiable information (PII), absolute paths, or secret API keys with explicit developer approval required.
7. **Auto-Debugging & Test Execution (Auto-Fixer & Unity Test Runner)**: Autonomous bug localization based on stack traces (up to 2 retries) and headless Unity test execution.
8. **Feedback Loop & Learning (Knowledge Learner /learn)**: Immediate persistence of developer feedback and preferences into project memory.
9. **Token Budgeting (Context Isolation)**: Information handoff strictly via C# interfaces and isolated subagent context windows.
10. **Three-Tier Logging Architecture**: Clear separation of data for developers (Tier 2 Markdown in `.foragents/logs/`), agents (Tier 1 Memory in `.foragents/PROJECT_MEMORY.md`), and IDE system traces (Tier 3).
11. **Package vs Project Data Isolation**: The `.agents` package remains clean and reusable across any project, while project memory and execution logs are stored in `.foragents/` at the root of the host repository.

---

## ⚡ Quick Start

### 1. Add as `.agents` Submodule to your Unity 6 Project
```bash
cd /path/to/your/UnityProject
git submodule add https://github.com/ReenBo/unity6-ai-workflow.git .agents
```

### 2. Install Local Git Hooks (1-Click)
* **Windows (PowerShell)**:
  ```powershell
  .\.agents\hooks\install-hooks.ps1
  ```
* **macOS / Linux / Git Bash**:
  ```bash
  bash ./.agents/hooks/install-hooks.sh
  ```

---

## 📁 Repository Structure

```text
Unity6-AI-Workflow/
├── package.json                        # Package Manifest & Versioning (unity6-ai-workflow v1.0.0 by Reen_Bo)
├── CHANGELOG.md                        # Version Release History
├── LICENSE                             # MIT License (Copyright Reen_Bo)
├── AGENTS.md                           # Master Antigravity Orchestrator (Routing, 5 Mechanics & 3-Tier Logs)
├── PROJECT_MEMORY_TEMPLATE.md          # Dry Project Memory Template (State & Architecture)
├── mcp_config.json.template            # MCP Server Configuration Template (Git, Filesystem, Unity)
├── README.md                           # English README
├── README_RU.md                        # Russian README
├── DOCUMENTATION.md                    # Full Master Documentation (English)
├── DOCUMENTATION_RU.md                 # Full Master Documentation (Russian)
│
├── ci/                                 # 🚀 UNIVERSAL CI/CD MODULE (Python + Dual Shell)
│   ├── runner.py                      # 🐍 PYTHON RUNNER: 100% cross-platform audit runner
│   ├── run-all-checks.ps1             # PowerShell wrapper script
│   ├── run-all-checks.sh              # Bash wrapper script (Linux / macOS / Git Bash)
│   └── templates/                      # Provider templates:
│       ├── github-actions.yml         # GitHub Actions template
│       ├── gitlab-ci.yml              # GitLab CI template
│       ├── bitbucket-pipelines.yml    # Bitbucket Pipelines template
│       └── azure-pipelines.yml        # Azure DevOps template
│
├── rules/                              # Modular Coding Rules
│   ├── unity6-vcontainer-architecture.md  # VContainer POCO, LifetimeScopes, ITickable
│   ├── unity6-performance-gc.md           # Zero-Alloc Update, NativeArray, Burst/Jobs
│   ├── unity6-ui-framework.md             # CSS Architecture, UI Toolkit, Binding
│   └── context-and-token-budget.md        # Token Budgeting & Context Isolation Rules
│
├── subagents/                          # Specialized Subagent Profiles
│   ├── task-analyzer.md               # 📋 TASK ANALYZER: Text/Screenshot/Link analysis + Git branching
│   ├── git-state-guard.md                 # 🛡️ ROLLBACK GUARD: Safe state checkpoint creation
│   ├── auto-fixer.md                      # 🔧 AUTO-FIXER: Autonomous error localization via stack traces
│   ├── workflow-creator.md                # 🤖 META-AGENT: Creator of new skills and roles
│   ├── security-privacy-auditor.md        # 🔒 SECURITY AUDITOR: PII & Data privacy inspector (Human-in-the-loop)
│   ├── code-architect.md                  # Architect Subagent (Contracts & Specs)
│   ├── code-writer.md                     # Code Writer Subagent (Isolated C# POCO implementation)
│   ├── code-reviewer.md                   # Code Reviewer Subagent (Audit diff, VContainer & GC)
│   ├── test-engineer.md                   # Test Engineer Subagent (Unit/Integration tests)
│   └── execution-logger.md                # Logger Subagent (Tier 2 Markdown report generation)
│
├── skills/                             # Specialized Skills
│   ├── task-tracker/                      # 📌 TRACKER: Task card management and Git branch switching
│   ├── memory-sync/                       # 🧠 MEMORY SYNC: Auto-update PROJECT_MEMORY.md from git diff
│   ├── knowledge-learner/                 # 🧠 LEARNER: Developer feedback persistence via /learn
│   ├── unity-test-runner/                 # 🧪 TEST RUNNER: Headless Unity Test Runner (batchmode)
│   ├── security-pii-scanner/              # 🔒 PII SCANNER: Secret keys, PII, and C:\Users\ path scanner
│   ├── workflow-evolver/                  # 🧬 META-SKILL: Skill generator skill
│   ├── vcontainer-auditor/                # VContainer DI compliance auditor
│   ├── ui-builder-validator/              # UI Framework & USS stylesheet validator
│   ├── memory-gc-profiler/                # Garbage allocation profiler for Tick() loops
│   └── execution-logger-skill/            # Tier 2 execution report generator for .foragents/logs/
│
├── logs/                               # Tier 2 Report Templates & Schemas (project logs go to .foragents/logs/)
│   ├── README.md                          # Report format specification (English)
│   └── schema_execution_log.json          # JSON Schema for log validation
│
└── hooks/                              # Git Hooks & Installer (Dual Shell)
    ├── install-hooks.ps1              # PowerShell Installer
    ├── install-hooks.sh               # Bash Installer (macOS/Linux)
    ├── pre-commit-audit.ps1
    ├── pre-commit-audit.sh
    └── hooks.json
```
