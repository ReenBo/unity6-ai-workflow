# Performance & Garbage Collection Standards (Unity 6)

## 1. Zero-Allocation Rule in `Tick()` / `Update()`
Inside frame-update methods (`ITickable.Tick()`, `IFixedTickable.FixedTick()`), the following are **STRICTLY PROHIBITED**:
* Heap allocations (`new` keyword usage).
* LINQ queries (`.Where()`, `.Select()`, `.FirstOrDefault()`).
* Boxing of value types into `object`.
* String concatenations (`string + string` or `$"..."` — use `StringBuilder` or cached strings).

---

## 2. Native Collections & Burst/Jobs Usage
When processing data collections or mathematical computations:
* Use `NativeArray<T>`, `NativeList<T>`, `NativeHashMap<K, V>`.
* **MANDATORY RULE**: Every created `NativeArray` must be disposed of via `.Dispose()` or job completion to prevent native C++ memory leaks.

```csharp
// Proper disposal pattern:
using var nativeArray = new NativeArray<float>(100, Allocator.TempJob);
// Execute logic / schedule job
nativeArray.Dispose();
```

---

## 3. Asynchronous Logic & Event Handling
* `System.Threading.Tasks.Task` and `async void` are prohibited.
* Use `UniTask` / `UniTaskVoid` with mandatory passing of `CancellationToken` (e.g., `destroyCancellationToken` or token from `LifetimeScope`).
* Reactive subscriptions must be managed via **R3**, storing `IDisposable` in a `CompositeDisposable` cleared in `Dispose()`.
