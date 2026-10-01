---
name: security-pii-scanner
description: Scans source code and configurations for personal identifiable information (PII) leaks, absolute developer user paths, API keys, and passwords.
---

# Security & PII Scanner Skill

## Purpose:
Automated detection of secrets and sensitive personal data inside Unity 6 project codebase.

## Audit Algorithm:
1. Run runner script `scripts/scan-pii-leaks.ps1` or `scripts/scan-pii-leaks.sh`.
2. Inspect codebase using regex patterns for API keys (`sk-...`, `bearer ...`), absolute user paths `C:\Users\`, `/Users/`, `/home/`, and raw password logging.
3. Upon detection, block execution and request developer confirmation (Human-in-the-Loop Protocol).
