# 🧠 Project Memory & Active Status (Project Memory Template)

> **Note:** This file is read by Antigravity agents first. It stores a dry summary of the project state, architectural decisions, and active tasks, eliminating the need to spend tokens scanning source files.

---

## 📌 1. Active Status & Task Tracker

- [x] Initialized `Unity6-AI-Workflow` architecture repository.
- [/] **In Progress**: VContainer rules configuration, subagent setup, and 3-tier logging integration.
- [ ] **Next**: Connecting repository to target Unity 6 project.

---

## 📐 2. Architectural Decisions Record (ADR)

* **DI Framework**: **VContainer**. Plain C# objects injected via `LifetimeScope`.
* **MonoBehaviour Exceptions**: Permitted **strictly** for visual Views (`SpriteRenderer`, `MeshRenderer`, `Collider`) and data-sourcing contexts.
* **Performance**: Zero heap allocations in `Tick()` / `Update()`. Use `NativeArray` / `JobSystem` for data collections.
* **Async & Events**: **UniTask** (`CancellationToken`) and **R3**.

---

## ⚠️ 3. Known Gotchas & Technical Debt

* *Token Budgeting*: Task logs must not exceed 200 lines per report.
* *Native Collections*: Always explicitly call `.Dispose()` on `NativeArray` to prevent C++ memory leaks in Unity native engine.

---

## 📜 4. Last Session Log

* **Date**: YYYY-MM-DD
* **Role**: Primary Agent / Orchestrator
* **Summary**: Description of applied changes and milestone status.
