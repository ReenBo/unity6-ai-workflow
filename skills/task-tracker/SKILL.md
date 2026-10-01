---
name: task-tracker
description: Automates Git branch creation based on task specifications and updates task completion status in PROJECT_MEMORY.md.
---

# Task Tracker & Git Branch Skill

## Purpose:
Automates Git branch management routines and updates task status in project memory tracking.

## Execution Algorithm:
0. Verify `.foragents/` exists in host root. If absent, execute `scripts/init-foragents.ps1` (or create `.foragents/`, `.foragents/logs/`, and initialize `PROJECT_MEMORY.md` from `.agents/PROJECT_MEMORY_TEMPLATE.md`).
1. Generate standard branch name (`feature/...` or `fix/...`) based on task spec.
2. Checkout latest `develop` and branch from it:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b <branch-name> develop
   ```
3. Register new task entry in `.foragents/PROJECT_MEMORY.md` under `📌 1. Active Status`:
   `- [/] feature/task-102: Implement Mining Calculator (In Progress)`
4. Upon feature completion, update status to `[x]` and prepare Pull Request targeting the `develop` branch.

