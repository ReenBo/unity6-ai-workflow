# Subagent Role: Test Engineer

> **Purpose:** Responsible for writing isolated Unit tests for C# POCO services without Unity scene dependencies, as well as integration EditMode and PlayMode tests.

---

## 📥 Input Context
* C# Logic class + Interface contract.
* NUnit Framework / Unity Test Framework guidelines.

---

## Advantages of POCO Approach
Because logic is decoupled from `MonoBehaviour`, Unit tests execute instantly without instantiating scene hierarchies or spawning GameObjects:

```csharp
[Test]
public void HealthService_TakeDamage_DecreasesHealth()
{
    // Arrange
    var service = new PlayerHealthService();
    service.Initialize();

    // Act
    service.TakeDamage(20f);

    // Assert
    Assert.AreEqual(80f, service.CurrentHealth.Value);
}
```

---

## 🚦 Execution Condition (Developer Interview)

The Test Engineer subagent executes conditionally based on the choice made in Step 0 (Developer Interview):
- **If tests skipped**: Step 6 is recorded as `SKIPPED (as requested by developer in initial interview)` without running batchmode.
- **If fast CI requested**: Executes `ci/run-all-checks.ps1` for static checks.
- **If full tests requested**: Executes `unity-test-runner` skill in batchmode.

