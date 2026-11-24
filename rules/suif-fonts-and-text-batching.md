# SUIF Font Batching & PanelTextSettings Architecture (Unity 6 UI Toolkit)

> **Mandatory Rule:** All UI Toolkit fonts, USS text styles, `FontAsset` configurations, and `PanelTextSettings` across SUIF applications must follow the **Single-Atlas Static SDF Batching Standard** to keep UI rendering consolidated within the shared `8`-slot GPU uber-shader budget, guarantee deterministic cross-platform WebGL2 output, and prevent runtime atlas/buffer churn.

---

## 🏛️ 1. Executive Summary & Architectural Tenets

| Axis | Mandatory Standard | Prohibited Anti-Pattern |
| :--- | :--- | :--- |
| **Font Asset Type** | **`-unity-font-definition`** referencing a TextCore `FontAsset` (`.asset`) + explicit `PanelTextSettings.defaultFontAsset` | Legacy **`-unity-font`** (raw `.ttf`/`.otf`) or leaving `PanelSettings.textSettings = null` |
| **Atlas Population** | **`AtlasPopulationMode.Static`** with **`isMultiAtlasTexturesEnabled = false`** (`atlasTextures.Length == 1`) for known alphabets | **`DynamicOS`** or OS fallback fonts (`Arial`, `Microsoft YaHei`) that break WebGL/Linux determinism |
| **Render Mode & Padding** | **`GlyphRenderMode.SDFAA`** (`SDFAA_HINTED` / `SDF16`) with **`atlasPadding` = `5–9` px** | **`atlasPadding == 0`** (breaks SDF AA/spread/outlines) or `RASTER*`/`SMOOTH*` bitmap modes across varied sizes |
| **Font Weight Strategy** | Synthetic shader bold/italic (`-unity-font-style`) on the primary atlas, or explicit atlases strictly capped at **`<= 2`** concurrent `FontAsset` textures | Dozens of per-weight `fontWeightTable` assets or per-screen font swaps exhausting GPU slots |
| **Text Effects** | `color`, `font-size`, `-unity-text-outline-*`, `text-shadow` stored in `ShaderInfoStorage` (`TextCoreSettings`) on the same atlas | Duplicating `Material` instances or adding multi-atlas RichText `<font>` / `<sprite>` tags inside hot labels |
| **Dynamic Text Allocation** | Pair single-atlas fonts with `FixedTextSlot` / `FixedSlotLabel` + `AttachToPanelEvent` deferral | Raw `Label.text = $"..."` updates causing `AllocPage` `KickRangesReason.PageChange` splits |

---

## ⚡ 2. RenderChain Internals: Uber-Shader & 8-Slot Texture Batching

In Unity 6 (`UnityEngine.UIElements.UIR`), solid quads, dynamic/sprite images, and TextCore SDF text render through a single default uber-shader (`Hidden/Internal-UIRDefault`).

### 2.1. `TextureSlotManager` & Texture Slot Budget
* `TextureSlotManager` manages **`k_MaxSlotCount = 8`** active texture bindings per GPU draw range batch (`k_SlotSize = 2` `Vector4` entries per slot in the GPU texture table carrying dimensions, `sdfScale`, `sharpness`, and `isPremultiplied` keyed by `TextureId`).
* Every distinct `TextureId` active simultaneously in a batch consumes **1** of the **8** shared slots:
  1. Panel Dynamic Atlas (`UIR` image/icon atlas).
  2. Standalone un-atlased textures/gradients or RenderTextures.
  3. Primary `FontAsset` atlas page (`atlasTextures[0]`).
  4. Any extra `FontAsset` page: multi-atlas overflow pages (`atlasTextures[1..]`), `fontWeightTable` regular/bold/italic atlases, `fallbackFontAssets`, emoji/sprite assets (`defaultSpriteAsset`), or OS fallback fonts triggered by missing glyphs.
* When active textures exceed available slots, `UIRenderDevice` flushes the current batch via **`KickRangesReason.TextureSlotsExhausted`** and starts a new draw call (`DrawRange`).

### 2.2. Per-Element Effects Without Breaking Text Batches
* `EntryProcessor` and `ShaderInfoStorage` (`s_TextCorePagePosID`, `TextCoreSettingsMode`) upload **`TextCoreSettings`** (`faceColor`, `outlineColor`, `outlineWidth`, `underlayColor`, `underlayOffset`, `underlaySoftness`) in GPU structured pages rather than per-material uniforms.
* Consequence: Differing `color`, `font-size`, `text-shadow` (underlay), and `-unity-text-outline-*` across `Label`s sharing the **same** SDF `FontAsset` texture merge cleanly into the **same Draw Call** and shader state.

### 2.3. What Actually Forces Text Batch Splits (`KickRangesReason`)
1. **`KickRangesReason.TextureSlotsExhausted`**: Too many distinct textures/font atlases/weight atlases/OS fallbacks active in the UI layer exceed the `8`-slot budget (or `ForceSingleTextureSlot` fallback hardware paths).
2. **`KickRangesReason.PageChange`**: Variable-length text updates reallocate vertices into non-adjacent `UIRenderDevice` vertex/index `AllocPage`s (mitigated by `FixedTextSlot` / `FixedSlotLabel`).
3. **`KickRangesReason.StencilRefChange` / `ScissorChange`**: DOM `overflow: hidden` + transform/clipping masks (such as `ScrollView` clipping containers or rotated children) slice text and UI meshes across separate draw ranges.
4. **`KickRangesReason.MaterialChange` / `DefaultMaterialChange`**: Custom `Material` overrides on `VisualElement`s interrupt default-shader text + panel geometry merging.

---

## ⚙️ 3. Font Asset & USS Mandatory Standards

### 3.1. `-unity-font-definition` Only (Forbid Legacy `-unity-font`)
* Always bind fonts in USS/TSS via **`-unity-font-definition: url("...")`** pointing to a TextCore `FontAsset` (`.asset`) and configure **`PanelTextSettings.defaultFontAsset`**.
* Never leave **`-unity-font`** referencing raw `.ttf`/`.otf` `Font` assets in production USS; raw dynamic fonts fall back to runtime bitmap/legacy conversion paths and break SDF shader determinism.
* Never leave `PanelSettings.textSettings` set to **`null` (`{fileID: 0}`)** — UI Toolkit falls back to runtime default settings and Windows/macOS OS fonts (e.g., `Arial`, `Microsoft YaHei`), which **do not exist on Linux WebGL CI builders (`ubuntu-latest`)** and create secondary runtime fallback atlases.

### 3.2. `GlyphRenderMode` & SDF Padding Rule
* Always configure UI Toolkit SDF `FontAsset`s with:
  * **`atlasRenderMode = GlyphRenderMode.SDFAA`** (or `SDFAA_HINTED` / `SDF16` for crisp small monospace HUD glyphs).
  * **`atlasPadding` between `5` and `9` px** (for typical `512x512`–`1024x1024` atlases).
* **Strictly forbid `atlasPadding == 0`**: zero padding collapses SDF distance spread, degrades antialiasing at fractional/small pixel sizes (`8–11px`), and corrupts outline/underlay gradients. *(Audit flag: `SUIF`'s `Schiffbauer-Regular SDF.asset` currently has `pad=0` and `multiAtlas=True`.)*
* **Prohibit Bitmap Modes (`RASTER`, `RASTER_HINTED`, `SMOOTH`, `SMOOTH_HINTED`)** when UI styles span multiple `font-size` tiers (`8px`..`26px`), because each point size must rasterize discrete glyph bitmaps, bloating atlas memory and causing multi-atlas overflow.

### 3.3. `AtlasPopulationMode` & Single-Atlas Consolidation
* **Mandatory for Known UI Alphabets (`ASCII` / `Cyrillic` / Curated FUI Symbols):**
  * **`atlasPopulationMode = AtlasPopulationMode.Static`**
  * **`isMultiAtlasTexturesEnabled = false`**
  * **`atlasTextures.Length == 1`** (single static texture packed up front).
  * Benefits: **0 ms** runtime glyph rasterization, **0** runtime CPU texture uploads (critical on single-threaded WebGL2), guaranteed glyph presence across headless Linux CI and browsers.
* **Strictly Forbidden:** **`AtlasPopulationMode.DynamicOS`** and unbundled OS fallback fonts (`Arial`, `Microsoft YaHei`, system sans-serif).
* **Conditional Exception (`AtlasPopulationMode.Dynamic`):** Permitted **only** on a dedicated secondary fallback `FontAsset` for unbounded user-generated input, localization dialects, or CJK text where static packing would exceed `2048x2048` VRAM budgets — always define explicit `clearDynamicDataOnBuild` behavior and keep embedded source font data scoped.

### 3.4. Font Weights (`fontWeightTable`) vs Synthetic Styling
* To achieve a **1–2 Draw Call** UI budget on WebGL/mobile, keep `fontWeightTable` empty on the primary UI `FontAsset` and let the TextCore SDF shader synthesize `-unity-font-style: bold` / `italic` from the single atlas.
* If true geometric bold/mono fonts are artistically required, embed dedicated `Static` `SDFAA` `FontAsset`s in **one shared or capped pair (`<= 2` concurrent font atlases visible on screen)** so total batch textures stay safely inside `TextureSlotManager` limits.

### 3.5. `PanelTextSettings` Hygiene
1. Every project `PanelSettings` asset MUST reference a dedicated `PanelTextSettings` asset (`ShowcasePanelTextSettings.asset` in Showcase).
2. Assign `defaultFontAsset` explicitly to the primary embedded `Static` `SDFAA` `FontAsset`.
3. Set **`enableEmojiSupport = false`** unless user chat/rich-emoji rendering is required (avoids unnecessary emoji asset probing/slots).
4. Keep `fallbackFontAssets` minimal and project-embedded (never rely on empty/OS-default fallback discovery for static UI labels).

### 3.6. RichText Tags, Unicode Symbols & Glyph Coverage Audit
* **Avoid inline `<font="...">` and `<sprite=...>` tags inside hot labels** (`FixedSlotLabel` grids/lists/HUD): mid-string font/sprite switches split one `Label` into multiple `RenderChainCommand`s bound to different `TextureId`s.
* **Non-ASCII Symbol Audit:** Any character in `.uxml`, `.uss`, or C# formatters missing from `FontAsset.characterTable` triggers fallback font resolution at runtime (creating a hidden OS fallback atlas like `Microsoft YaHei - Regular Atlas` in Editor or blank boxes on Linux WebGL).
  * Either **bake** all intentionally used symbols cleanly into the primary `Static` `FontAsset` character list, **or** replace stray Unicode glyphs (`●`, `↻`, `×`, `■`, `┼`, `»`, `›`, `▲`, `▼`, `–`, `═`, `◢`, `◣`) with standard ASCII tokens / GPU-batched procedural geometry (`MeshGenerationContext.Allocate`).

---

## ✅ 4. Font & Text Batching Pre-Commit Verification Checklist

Before completing any task that creates or modifies fonts, `PanelSettings`, `.uss`, `.tss`, `.uxml`, or dynamic text components:

- [ ] `PanelSettings.textSettings` is **non-null** and references an explicit project `PanelTextSettings` asset.
- [ ] Primary UI stylesheets declare `-unity-font-definition` (zero runtime reliance on legacy `-unity-font` or missing default OS fonts).
- [ ] Primary UI `FontAsset` uses `GlyphRenderMode.SDFAA` (or `SDFAA_HINTED`/`SDF16`), **`atlasPadding` >= `5` px**, **`AtlasPopulationMode.Static`**, and **`isMultiAtlasTexturesEnabled = false`** (`atlasTextures.Length == 1`).
- [ ] `DynamicOS` is absent across all UI `FontAsset`s and `fallbackFontAssets`.
- [ ] Concurrent visible `FontAsset` atlas textures stay `<= 2` (total simultaneous textures strictly well within `TextureSlotManager`'s `8`-slot budget).
- [ ] All Unicode glyphs present in `.uxml` / `.cs` text sources are verified covered by `FontAsset.characterTable` (zero OS fallback font atlas spawns in Editor `TextureRegistry` or UI Toolkit Debugger).
- [ ] Dynamic labels use `FixedTextSlot` / `FixedSlotLabel` + single-atlas fonts so Play Mode `UIRenderDevice.GatherDrawStatistics()` shows stable `drawRangeCallCount` with zero `PageChange` or `TextureSlotsExhausted` splits.
