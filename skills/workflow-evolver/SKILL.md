---
name: workflow-evolver
description: Analyzes project tech stack and repetitive user tasks, generating new specialized Skills and Subagent Profiles.
---

# Workflow Evolver Skill

## Purpose:
Automated auditing of agent network and generation of new skills and subagents matching evolving project requirements.

## Execution Algorithm:
1. Read existing skills registry from `skills/` and subagent profiles from `subagents/`.
2. Compare requirements with project architectural tech stack.
3. Automatically generate folder structure `skills/<new-skill>/SKILL.md` or file `subagents/<new-agent>.md`.
4. Log Tier 2 protocol in `logs/`.
