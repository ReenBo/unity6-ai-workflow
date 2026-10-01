---
name: memory-gc-profiler
description: Scans Tick() and Update() methods for heap allocations (new, LINQ, boxing) and missing NativeArray.Dispose() calls.
---

# Memory & GC Profiler Skill

## Purpose:
Automated codebase audit for hidden garbage collection allocations.

## Checks:
1. Search for `new` operator inside `Tick()`, `FixedTick()`, and `Update()` methods.
2. Search for `.Where()`, `.Select()` LINQ invocations inside hot frame loops.
3. Search for `NativeArray` declarations lacking paired `.Dispose()` calls.
