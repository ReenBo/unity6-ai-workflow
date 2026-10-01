---
name: vcontainer-auditor
description: Scans C# source files for VContainer DI rules compliance, checks for .AsImplementedInterfaces() registrations, and flags prohibited MonoBehaviour usage.
---

# VContainer Auditor Skill

## Purpose:
Automated auditing of new and modified C# source files for VContainer DI standards.

## Audit Algorithm:
1. Run runner script `scripts/audit-vcontainer.ps1` or `scripts/audit-vcontainer.sh`.
2. Find all C# classes without `: MonoBehaviour` having constructors with dependencies.
3. Verify whether classes are registered in corresponding `LifetimeScope`.
4. Generate audit report and handoff result to `Execution Logger`.
