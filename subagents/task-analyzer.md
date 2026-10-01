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
    Input["1. Input: Text / Screenshot / Link"] --> Extract["2. Extract requirements & decompose"]
    Extract --> Interview["3. Developer Interview: Clarifications + CI/CD & Testing Scope"]
    Interview --> Approved["4. Confirm final specification & Test Scope"]
    Approved --> Branch["5. Create Git Branch (feature/... or fix/...)"]
    Branch --> Track["6. Register in .foragents/PROJECT_MEMORY.md (📌 Active Status)"]
    Track --> Handoff["7. Handoff specification to Code Architect Subagent"]
```

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

## 🌿 4. Git Branch Naming Conventions

- **New Features**: `feature/task-<ID>-<short-description>` (e.g., `feature/task-102-mining-calculator`)
- **Bug Fixes**: `fix/issue-<ID>-<short-description>` (e.g., `fix/issue-45-ui-overlap`)
- **Refactoring**: `refactor/<short-description>`

---

## 📤 Output Artifacts
- Confirmed task specification with agreed testing scope.
- Checked out Git branch.
- Task tracking entry in `.foragents/PROJECT_MEMORY.md`.
