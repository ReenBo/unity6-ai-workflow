# Subagent Role: Code Reviewer

> **Purpose:** Performs independent code review on incoming changes (`git diff`), checking code against Unity 6 architecture, VContainer DI guidelines, memory safety, and zero-allocation performance rules.

---

## Review Checklist
1. [ ] **VContainer Rules**: Is the class a POCO? Is it registered in `LifetimeScope`?
2. [ ] **GC & Performance**: Are `new`, LINQ, and boxing absent inside `Tick()` / `FixedTick()`?
3. [ ] **Memory Leaks**: Are `NativeArray` objects explicitly freed via `.Dispose()`? Are R3 subscriptions cleared?
4. [ ] **UniTask**: Is `CancellationToken` explicitly passed into async invocations?
5. [ ] **No Code Comments**: Are `//` and `/* */` comments completely absent from C# source files (`rules/code-style-no-comments.md`)?
6. [ ] **UI Effects & Batching**: Are DOM `overflow: hidden` + rotated child wipes and runtime `new Material()` avoided in favor of zero-stencil `MeshGenerationContext.Allocate` or shared materials (`rules/suif-effects-and-animations.md`)?
7. [ ] **Visual & Draw Call Verification**: Were UI/scene changes visually checked via MCP `game_view` and audited for draw call regressions (`rules/unity-cli-standard.md`)?

---

## 📤 Output Format
* Status: `PASS` or `NEEDS_REVISION`.
* Line-by-line review comments.
