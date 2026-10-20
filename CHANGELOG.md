# Changelog

All notable changes to the `Unity6-AI-Workflow` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
