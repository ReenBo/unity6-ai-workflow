# Changelog

All notable changes to the `Unity6-AI-Workflow` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-10-30

### Added
- **Mandatory Unity CLI Standard**: Introduced `rules/unity-cli-standard.md` requiring AI subagents and skills to leverage the official standalone `unity` CLI and `com.unity.pipeline` for live compilation (`unity recompile`), instant EditMode/PlayMode testing (`unity test`), and structured console inspection (`unity cmd console status`).
- **Comprehensive Unity CLI Architectural Guide**: Added `docs/unity-cli-integration.md` detailing the paradigm shift from legacy cold batchmode to warm RPC editor automation, token budget optimization, command reference, and Model Context Protocol (MCP) client configuration.
- **Official Model Context Protocol (MCP) Setup**: Standardized native editor connection for Antigravity, Cursor, and Claude Code via `unity mcp configure`.

### Changed
- **`Auto-Fixer` Subagent**: Refactored self-correction protocol to execute live recompilation via `unity recompile` and fetch targeted errors via `unity cmd console get --level error` (saving ~99.8% token context versus ingesting raw `Editor.log` streams).
- **`Test Engineer` Subagent & `unity-test-runner` Skill**: Rewrote test runner scripts (`run-unity-tests.ps1` and `run-unity-tests.sh`) to prioritize warm execution via `unity test` (1-2 seconds) with zero lockfile collisions, falling back to version-detected headless mode only when the editor is closed.
- **Master Orchestrator (`AGENTS.md`)**: Elevated Unity CLI to the 8th core autonomy and security mechanic (`Unity CLI & Hot Pipeline Guard`).

## [1.2.1] - 2026-10-29

### Fixed
- **Pre-Commit Hook Paths Resolution**: Fixed path resolution in `pre-commit-audit.ps1` and `pre-commit-audit.sh` so audit scripts are correctly located whether running within a host project (via `.agents` submodule) or standalone.
- **VContainer Audit Scope**: Excluded `.agents` directory from scanning in `audit-vcontainer.ps1` to prevent false positive matches in external workflow files.
- **Dual Mode Hook Installer**: Updated `install-hooks.ps1` and `install-hooks.sh` to support both submodule (`.agents`) and standalone hook dispatching.

## [1.2.0] - 2026-10-20

### Added
- **Prohibition of Comments in Code**: Introduced mandatory rule `rules/code-style-no-comments.md` strictly prohibiting inline and block comments in source code; code must be self-documenting via clear naming, types, and architectural separation.
- **English-Only Execution Logging**: Formally standardized that all Tier 2 execution log files in `.foragents/logs/` must be authored strictly in English. Updated `execution-logger-skill` and `templates/log_template.md`.

## [1.1.0] - 2026-10-01

### Added
- **Autonomous `.foragents` Initialization**: Automatic creation of `.foragents/`, `.foragents/logs/`, `README.md`, and instantiation of `PROJECT_MEMORY.md` from template whenever missing in the host project. Added cross-platform scripts `scripts/init-foragents.ps1` and `scripts/init-foragents.sh`.
- **Develop-First Git Standard**: Formalized `develop` as the default development branch and target branch for all Pull Requests across both the `ai-workflow` repository and host projects.
- **Developer Interview Protocol**: Interactive requirement clarification in Step 0 asking whether CI/CD audits or native Unity tests should be executed or skipped.
- **Package vs Project Data Isolation**: Strict separation of generic workflow engine in `.agents` and host project memory/logs in `.foragents/`.

## [1.0.0] - 2026-10-01


### Added
- **Multimodal Task Analyzer**: Task processing pipeline supporting text, Jira/GitHub URLs, and UI/console screenshots.
- **Git State Guard**: Automatic creation of `git stash` / `ai-checkpoint` for 1-click rollback before refactoring.
- **Security Auditor & PII Scanner**: Mandatory PII, token, and path leak inspection with **Human-in-the-Loop Protocol**.
- **Auto-Fixer & Unity Test Runner**: Autonomous error localization based on stack traces (up to 2 retries) and headless Unity test execution.
- **Self-Evolving Workflow Creator**: Meta-agent and meta-skill (`workflow-evolver`) for dynamic skill generation.
- **Three-Tier Logging Architecture**: Tier 1 Memory, Tier 2 Task Protocols in Git for PRs, and Tier 3 IDE traces.
- **Cross-Platform Dual Shell & Python Runner**: `ci/runner.py`, PowerShell `.ps1`, and Bash `.sh` scripts with `.gitattributes` line ending normalization.
- **Provider-Agnostic CI/CD**: Pre-configured integration templates for GitHub Actions, GitLab CI, Bitbucket Pipelines, and Azure DevOps.
- **Multilingual Master Documentation**: Pure English package core with dedicated English (`DOCUMENTATION.md`) and Russian (`DOCUMENTATION_RU.md`) user guides.
