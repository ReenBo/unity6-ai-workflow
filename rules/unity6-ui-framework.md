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

## 4. SUIF Universal Data & Zero-Realloc UI Enforcement
* **Optional Data Contracts (`TData`)**: Data payloads (`struct`, `class`, `ScriptableObject`) must remain UI-agnostic and must NEVER be forced to implement framework marker interfaces (`IViewDto`).
* **Thin ViewModel & Thin View**: Domain calculations, counters, timestamps, and catalogs belong in injected Domain Services or `ScriptableObject` assets. ViewModels (`IReactiveDataViewModel<TData>`) expose reactive properties, command forwards, and read-only `Formatter` access; Views (`BaseReactiveDataView<TViewModel, TData>` / `BaseView<TViewModel>`) remain strictly container-agnostic (`[Inject]` and `using VContainer;` in Views are strictly prohibited) and contain only `[UQuery]` fields, `Binder.FixedSlot(...)` / `FixedElementPool<TElement>`, and reactive bindings.
* **Injectable DI Formatters (Zero Global Statics)**: Avoid `static` formatting classes and `static` data arrays. Register `Singleton` formatter services caching `FixedTextWriter<T>` delegates at startup and inject them into ViewModels (`ViewModel.Formatter`).
* **Fixed Capacity & Pooling (`AllocPage` Protection)**: Dynamic text MUST update via `Binder.FixedSlot`, `FixedSlotLabel`, or `ToFixedWritten(...)` with zero-closure delegates. Repeated DOM slots MUST pre-allocate via `FixedElementPool<TElement>` in `OnBind()`/`Bind()` using `DisplayStyle.None` (never `Visibility.Hidden`).
* **Async / Parallel Preloading**: Heavy startup catalogs or service initialization MUST preload in parallel via `UniTask.WhenAll` paired with a cached `UILayer.Topmost` loading spinner View.
