# SUIF Visual Effects & Animation Architecture (Unity 6 UI Toolkit)

> **Mandatory Rule:** All dynamic visual effects, chamfered/angled contours, hover wipes, and transitions across SUIF components must follow the **GPU-Driven Vertex Injection Pattern** to maximize dynamic batching (1 Draw Call for all elements), ensure zero heap allocations, and eliminate CPU main-thread render overhead.

---

## 🏛️ 1. Executive Summary & Architectural Tenets

| Axis | Standard Rule | Prohibited Anti-Pattern |
| :--- | :--- | :--- |
| **Batching** | **1 Draw Call for all buttons/panels** sharing single static Material Asset | Creating runtime instances via `new Material(shader)` per element |
| **Clipping** | **GPU-Math Fragment Clipping** (SDF / linear equations + `smoothstep`) | DOM `overflow: hidden` with rotated/skewed child pseudo-elements |
| **Animation Driving** | **Vertex Attribute Stream** (`Vertex.tint` / `uv1`) or GPU `_Time` | CPU `generateVisualContent` (`Painter2D.MarkDirtyRepaint()`) in frame loops |
| **Memory & GC** | **0 B (Zero-Alloc)** struct-based value lerpers | Heap closures (`Action`, `Func`), Coroutines, or `MonoBehaviour` drivers |
| **Anti-Aliasing** | **Subpixel AA** via screen-space derivatives (`fwidth()`) | Jagged pixel boundaries or expensive multi-pass MSAA buffers |

---

## ⚡ 2. The Single Material Vertex Injection Pattern

### 2.1. The 1-Draw-Call Batching Principle
In Unity 6 UI Toolkit, dynamic batching merges all visual elements sharing the same **Texture Atlas** and **Material Asset** into a single draw call. 

* **The Problem:** Modifying material uniforms (`material.SetFloat("_HoverProgress", val)`) requires creating unique material instances, forcing $N$ Draw Calls for $N$ elements.
* **The SUIF Solution:** All interactive elements bind to **one shared static Material asset** (`SUIF-CyberUI-Core.mat`). Individual dynamic state is packed directly into per-element **Vertex Data** (`Vertex.tint` or secondary UVs):

```mermaid
flowchart LR
    SharedMat["Single Shared Material Asset (SUIF-CyberUI-Core.mat)"] --> Batcher["UITK Dynamic Batcher"]
    Atlas["Shared Texture Atlas"] --> Batcher
    
    Btn1["Btn 01: Vertex.tint.r = 0.25 (Wipe 25%)"] --> Batcher
    Btn2["Btn 02: Vertex.tint.r = 1.00 (Wipe 100%)"] --> Batcher
    Btn3["Btn 03: Vertex.tint.r = 0.00 (Idle 0%)"] --> Batcher
    
    Batcher --> OneDrawCall["🏆 1 SINGLE DRAW CALL (100% Batched)"]
```

### 2.2. Vertex Attribute Packing Protocol
When rendering custom quads or procedural elements via `MeshGenerationContext`:

| Vertex Attribute | Target Parameter | Range | Description |
| :--- | :--- | :--- | :--- |
| **`Vertex.tint.r`** | `HoverProgress` | `0.0 .. 1.0` | Normalized progress of diagonal wipe / transition front. |
| **`Vertex.tint.g`** | `ChamferNormalized` | `0.0 .. 1.0` | Corner cut ratio relative to element dimensions. |
| **`Vertex.tint.b`** | `StateFlags` | `0, 1, 2, 3` | Encoded flags (0: Normal, 1: Active, 2: Disabled, 3: Danger). |
| **`Vertex.tint.a`** | `BaseOpacity` | `0.0 .. 1.0` | Global opacity multiplier. |

---

## 🚫 3. Prohibited Approaches (Anti-Patterns)

### 3.1. Prohibition of DOM `overflow: hidden` + Rotated Pseudo-Elements
* **Prohibited:** Creating angled hover wipes by placing an inner element with `rotate(15deg)` or `transform: skew` inside a container with `overflow: hidden`.
* **Reason:** In UITK, rotated children inside clipped containers cannot be clipped by hardware Scissor Rects. UITK forces Stencil buffer allocation and breaks batching, transforming a 10-button menu into 25–40 separate draw calls.

### 3.2. Prohibition of Per-Frame `Painter2D` Animation
* **Prohibited:** Overriding `generateVisualContent` and calling `MarkDirtyRepaint()` on every frame in `ITickable.Tick()` to animate shapes via CPU.
* **Reason:** Re-triangulating contours and uploading vertex buffers (`UploadMesh`) at 60–120 FPS causes main-thread CPU spikes and battery drain.
* **Allowed Use for `generateVisualContent`:** Static or resize-only vector framing (e.g., drawing non-standard window border geometry once upon window creation or resolution change).

---

## 🧮 4. Mathematical GPU Shader Formulation

All diagonal wipes, chamfers, and edge contours are calculated analytically in the fragment shader with subpixel anti-aliasing:

```hlsl
// SUIF Cyberpunk Angled Frontline & Chamfer Formula
float4 EvaluateCyberWipe(float2 uv, float progress, float chamferSize, float4 baseColor, float4 activeColor)
{
    // 1. Angled Frontline (Cyberpunk 35-degree sweep)
    const float slope = 0.35;
    float frontLine = uv.x + (1.0 - uv.y) * slope;
    float scaledProgress = progress * (1.0 + slope);

    // Subpixel screen-space anti-aliasing
    float aa = fwidth(frontLine) * 1.5;
    float wipeMask = smoothstep(frontLine - aa, frontLine + aa, scaledProgress);

    // 2. Chamfered Corner (e.g. Top-Right Corner Cut)
    float cornerSum = uv.x + uv.y;
    float cornerCut = step(cornerSum, 2.0 - chamferSize);

    // 3. Single-Pass Color Composite
    float4 finalColor = lerp(baseColor, activeColor, wipeMask);
    finalColor.a *= cornerCut;
    return finalColor;
}
```

---

## 🔄 5. Zero-Allocation Animation Drivers

1. **Pure Struct Lerpers**:
   - Animation transitions must use unmanaged struct-based interpolators (`ValueAnimation<float>`).
   - Do not allocate lambda expressions (`Action<float>`) in frame loops.
2. **UniTask & R3 Integration**:
   - Drive value transitions via value-task loops using `CancellationToken`:
     ```csharp
     // Recommended pattern:
     public async UniTask AnimateHoverAsync(float targetProgress, CancellationToken ct)
     {
         float start = CurrentProgress;
         float elapsed = 0f;
         while (elapsed < Duration)
         {
             ct.ThrowIfCancellationRequested();
             elapsed += Time.unscaledDeltaTime;
             float t = Mathf.Clamp01(elapsed / Duration);
             CurrentProgress = Mathf.Lerp(start, targetProgress, EaseOutExpo(t));
             ApplyVertexTint(CurrentProgress);
             await UniTask.Yield(PlayerLoopTiming.Update, ct);
         }
     }
     ```
3. **GPU-Time Autonomy**:
   - For cyclical ambient effects (e.g., scanning lines, radar sweeps, pulsing glows), use GPU `_Time.y` in the shader graph directly. Zero C# CPU code or ticking required.

---

## 📝 6. Dynamic Text & Foreground Inversion Protocol

When a high-contrast angled wipe sweeps across a button:
1. **Shader Inversion**: If text/icon is integrated into the procedural quad, color inversion occurs in a single pass via `lerp(NormalTextCol, InvertedTextCol, wipeMask)`.
2. **TextCore Dual-Binding**: If using standard UITK `Label` (TextCore SDF font), synchronize the label's CSS transition duration to match the wipe duration:
   ```css
   .fui-btn-label {
       color: var(--fg-primary);
       transition-property: color;
       transition-duration: 0.18s;
       transition-timing-function: ease-out-expo;
   }
   .fui-btn:hover .fui-btn-label {
       color: #050507;
   }
   ```
