# UI Framework & CSS Architecture Rules (Unity 6)

## 1. UI Ideology
* All UI elements must follow the declarative MVVM / Data Binding pattern.
* Layout, styling, and visual tokens must be separated into custom CSS / USS files.
* Direct hardcoding of colors, margins, or font sizes in C# code is strictly prohibited — use stylesheet classes and tokens.

---

## 2. Element Naming & Unique IDs
* Every interactive UI element (`Button`, `Toggle`, `TextField`) must have a unique `id` / `name` for automated testing and binding context.
* Use binding extension methods like `ImageBindingExtensions`, `TextBindingExtensions` for reactive property binding.

---

## 3. UI LifetimeScope & VContainer
* UI controllers must not manage business logic directly. UI controllers subscribe to models/services via VContainer DI and present R3 reactive data properties.

---

## 4. SUIF DTO Standard & Zero-Realloc UI Enforcement
* **DTO Contracts (`IViewDto`)**: Every parameterized view must receive immutable value-type DTOs (`struct : IViewDto`) composed of domain primitives and enums—never localized text, formatted strings, RichText tags, CSS tokens, or `UnityEngine.UIElements` references.
* **ViewModels (`BaseViewModel`)**: Must emit `ReactiveProperty<TDto>` or DTO arrays cleanly without string interpolation (`$"..."`), `ZString.Format`, or UI formatting logic.
* **Formatters (`FixedTextWriter<TState>`)**: All UI text assembly belongs in stateless formatter classes writing into `ref Utf16ValueStringBuilder` with zero-allocation `switch` expressions for enum tokens.
* **Fixed Capacity & Pooling (`AllocPage` Protection)**: Dynamic text MUST update through `FixedTextSlot`, `FixedSlotLabel`, or `ToFixedText(...)` (`SetWritten<TState>` with static delegates). Repeated DOM slots MUST pre-allocate via `FixedElementPool<TElement>` in `Bind()` using `DisplayStyle.None` for inactive elements (never `Visibility.Hidden` for cached views).
