---
name: memory-sync
description: Automatically analyzes git diff and session summaries, then updates project memory in PROJECT_MEMORY.md.
---

# Memory Sync Skill

## Purpose:
Automated updating of project state and `Active Status` / `Session Log` sections in `.foragents/PROJECT_MEMORY.md` based on applied commits and diffs.

## Execution Algorithm:
0. Ensure `.foragents/PROJECT_MEMORY.md` exists (run `.agents/scripts/init-foragents.ps1` if missing).
1. Run `scripts/sync-memory.ps1` or `scripts/sync-memory.sh` to extract `git status` and `git diff --stat`.
2. Extract list of modified C# source files and newly created interfaces.
3. Update `📌 1. Active Status` and `📜 4. Last Session Log` sections in `.foragents/PROJECT_MEMORY.md`.
4. Commit memory updates to project Git tracking.

