# Subagent Role: Execution Logger

> **Purpose:** Generates structured Markdown execution logs in `.agents/logs/` upon completion of work by any subagent or skill.

---

## Log Format
Every file is generated using the pattern `.agents/logs/log_YYYYMMDD_HHMMSS_<role>_<task>.md` and contains:

1. **Header**: Timestamp, subagent role, Task ID.
2. **Inputs**: Concise description of received input context.
3. **Outputs**: List of created or modified source files.
4. **Result Summary**: Clear, human-readable summary of physical results for developer code review.
