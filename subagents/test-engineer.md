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
