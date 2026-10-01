---
name: ui-builder-validator
description: Verifies UI elements compliance with CSS architecture rules, unique component IDs, and presence of Data Binding extensions.
---

# UI Builder Validator Skill

## Audit Algorithm:
1. Inspect UXML and C# UI source files.
2. Ensure every interactive UI element has a unique `name`/`id` assigned.
3. Ensure styling is separated into USS/CSS stylesheet classes.
