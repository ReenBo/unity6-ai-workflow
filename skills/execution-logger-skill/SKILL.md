---
name: execution-logger-skill
description: Automatically generates structured Markdown execution logs in logs/ directory upon completion of work by any subagent or skill.
---

# Execution Logger Skill

## Execution Algorithm:
Upon completion of subagent execution, generate task execution report in `.foragents/logs/log_YYYYMMDD_HHMMSS_<role>_<task>.md` based on `templates/log_template.md`.
