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
