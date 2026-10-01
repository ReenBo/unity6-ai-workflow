---
name: task-tracker
description: Automates Git branch creation based on task specifications and updates task completion status in PROJECT_MEMORY.md.
---

# Task Tracker & Git Branch Skill

## Purpose:
Automates Git branch management routines and updates task status in project memory tracking.

## Execution Algorithm:
1. Generate standard branch name (`feature/...` or `fix/...`) based on task spec.
2. Execute `git checkout -b <branch-name>`.
3. Register new task entry in `.agents/PROJECT_MEMORY.md` under `📌 1. Active Status`:
   `- [/] feature/task-102: Implement Mining Calculator (In Progress)`
4. Upon feature completion, update status to `[x]` and prepare summary for Pull Request.
