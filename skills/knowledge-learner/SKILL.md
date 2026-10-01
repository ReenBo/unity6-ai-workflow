---
name: knowledge-learner
description: Persistently saves new coding rules and developer requirements to PROJECT_MEMORY.md or rules/ via /learn command or feedback comments.
---

# Knowledge Learner Skill (/learn Protocol)

## Purpose:
Captures developer corrections and preferences to prevent recurring AI errors.

## Execution Algorithm:
1. Capture verbal or written feedback from developer (e.g., *"Resources.Load is forbidden in this project"*).
2. Extract architectural essence of the rule.
3. Append entry to `Architectural Decisions Record` in `.agents/PROJECT_MEMORY.md` or create corresponding markdown in `.agents/rules/`.
4. Confirm rule persistence in execution log.
