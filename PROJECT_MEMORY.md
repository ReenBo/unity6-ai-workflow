# 🧠 Project Memory & Active Status

> **Note:** This file is read by Antigravity agents first. It stores a dry summary of the project state, architectural decisions, and active tasks, eliminating the need to spend tokens scanning source files.

---

## 📌 1. Active Status & Task Tracker

- [x] Initialized `Unity6-AI-Workflow` architecture submodule in `.agents`.
- [x] Connected `.agents` to `DaE_Project` on branch `develop`.
- [x] **Completed**: `feature/ui-framework-bindings`: Comprehensive analysis, audit, and refactoring of `UIFramework` using AI Workflow package (`.agents`), with parallel validation and improvement of the AI package itself.
- [ ] **Next**: Receive feature task scope from developer and implement next UIFramework features (Data Binding, SMACSS, etc.).

---

## 📐 2. Architectural Decisions Record (ADR)

* **Architecture**: Declarative MVVM / UI Toolkit + SMACSS CSS Architecture.
* **DI Framework**: **VContainer**. Pure logic, managers, and services are plain C# (POCO) registered in `UILifetimeScope`.
* **Reactivity & Async**: **R3** (`ObservableList`, `ReactiveProperty`) & **UniTask** (`CancellationToken`).
* **Zero-Allocation**: No heap allocations, boxing, or LINQ in frequent runtime loops, binding callbacks, or `ITickable.Tick()`.
* **String Formatting**: `ZString` for high-frequency/runtime text updates.
* **UI Toolkit Specifics**:
  * Strict SMACSS layering (`1_Base`, `2_Layout`, `3_Modules`, `4_States`, `5_Themes`).
  * `picking-mode="Ignore"` inline on transparent wrapper layers in UXML.
  * Direct child `flex-grow: 1` on instantiated `TemplateContainer` in `.l-layer > *`.
  * Virtualized ListView recycling uses `IView.Unbind()` / `ViewBinder.Clear()` to preserve ViewModels and CompositeDisposables.
  * Show/Hide utilizes `.is-hidden` CSS class rather than inline style overrides.

---

## ⚠️ 3. Known Gotchas & Technical Debt

* *Submodule isolation*: `.agents` changes should be committed to submodule repository when syncing upstream.
* *Addressables Testing*: `UIThemeService` now uses `IUIAssetProvider` for easy mock unit testing without live Addressables catalog.

---

## 📜 4. Last Session Log

* **Date**: 2026-10-01
* **Role**: Primary Agent / Task Analyzer & Code Reviewer
* **Summary**: Branch `feature/ui-framework-bindings` created. Completed comprehensive audit of `UIFramework` & `.agents`. Fixed ListView virtualization recycling bug, ViewData boxing in List.Remove, Addressables coupling in UIThemeService, SMACSS inline style overrides, and hardened .agents CI scripts on Windows. All CI audits passing cleanly. Ready for feature scope from developer.
