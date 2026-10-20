---
trigger: always_on
---

# Code Style & Comments Policy (Unity 6 Workflow)

> **Mandatory Rule:** Writing inline or block explanatory comments in source code is strictly prohibited.

---

## 🚫 1. Strict Prohibition of Code Comments

* **No Inline Comments**: Do NOT write `// ...` explanatory comments inside methods, logic blocks, or variable declarations.
* **No Block Comments**: Do NOT write `/* ... */` comment blocks in code.
* **No Commented-Out Code**: Never leave commented-out code snippets (`// int oldX = 1;`). Remove dead code completely.
* **No Obvious Annotations**: Comments like `// Bind elements`, `// Dispose subscription`, or `// Initialize view` are forbidden.

---

## 💡 2. Self-Documenting Code Standards

Instead of writing comments, ensure clarity through clean code practices:
1. **Expressive Method & Variable Names**: Use intention-revealing, unambiguous names (`CreateAndBindInventorySlots()` instead of `CreateSlots()` + comment).
2. **Small Focused Methods**: Extract complex conditionals or blocks into private methods whose names describe their purpose.
3. **Domain Types & Enums**: Use strongly-typed enums and value types rather than primitive obsession accompanied by comments.
4. **Architectural Separation**: Keep POCO logic, DI registration, and visual element binding in their dedicated layers per SUIF and VContainer standards.

---

## 📝 3. Allowed Exceptions

* **Compiler Directives**: Preprocessor directives (`#if`, `#pragma warning disable`) are allowed when strictly necessary for conditional compilation.
