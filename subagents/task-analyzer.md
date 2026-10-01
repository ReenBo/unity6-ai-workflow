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

## 💬 3. Developer Interview Protocol (CI/CD & Testing Scope)

In most everyday tasks, running heavy builds or full native PlayMode tests is unnecessary. During step 3, the Task Analyzer explicitly interviews the developer via interactive questions:

* **Question**: *"Требуется ли для данной задачи запуск CI/CD проверок и тестов Unity?"*
* **Standard Options**:
  1. `(Recommended) Пропустить тесты/сборку`: Fast-path — только валидация кода, code review и проверка синтаксиса.
  2. `Быстрый аудит CI`: Запуск консольных скриптов (`ci/run-all-checks.ps1`: VContainer, PII, GC, UI).
  3. `Полный прогон тестов Unity`: Запуск Native Unity Test Runner (`unity-test-runner` EditMode/PlayMode).

The developer's decision is recorded in the task specification and respected by the `Test Engineer` subagent (Step 6).

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

