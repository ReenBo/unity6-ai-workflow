# Architectural Standard: VContainer & POCO Rules (Unity 6)

## 1. Core Rule
**It is strictly forbidden to inherit classes of pure logical systems, managers, controllers, and services from `MonoBehaviour`.**

All business logic must be written in Plain Old C# Objects (POCO) and managed through the **VContainer** dependency injection container utilizing its declarative lifecycle interfaces.

---

## 2. VContainer Lifecycle Mapping

| Unity Lifecycle Message | VContainer Interface | Method | Description |
| :--- | :--- | :--- | :--- |
| `Awake` / `Start` (Setup) | `IInitializable` | `Initialize()` | Internal configuration right after container assembly. |
| `Start` (Launch) | `IStartable` | `Start()` | Launching systems when scene starts. |
| Async `Start` | `IAsyncStartable` | `StartAsync(CancellationToken)` | Asynchronous initialization built on UniTask. |
| `Update` (Every Frame) | `ITickable` | `Tick()` | Centralized zero-allocation update loop. |
| `FixedUpdate` (Physics) | `IFixedTickable` | `FixedTick()` | Physics loop updates. |
| `LateUpdate` (Camera/UI) | `ILateTickable` | `LateTick()` | Updates executed after main frame logic. |
| `OnDestroy` / Cleanup | `IDisposable` | `Dispose()` | Reclaiming R3 subscriptions and resources. |

---

## 3. LifetimeScope Registration

All POCO classes must be registered with bindings to their implementing lifecycle interfaces:

```csharp
protected override void Configure(IContainerBuilder builder)
{
    builder
        .Register<GameScoreService>(Lifetime.Singleton)
        .AsImplementedInterfaces()
        .AsSelf();
}
```

---

## 4. Allowable MonoBehaviour Exceptions

Inheriting from `MonoBehaviour` is permitted **strictly** in the following cases:
1. **Views (Visual Components)**: Physical scene actors containing rendering (`SpriteRenderer`, `MeshRenderer`) or physics (`Collider`, `Rigidbody`) components.
2. **Data-Sourcing Contexts**: Scripts storing scene references or inspector-configured parameters (`LifetimeScope`, `UIRoot`).
3. **Third-Party Plugins**: Systems strictly mandating MonoBehaviour inheritance by API design (e.g., Cinemachine Virtual Cameras).
