# Crawl Brawl Runtime Component Refactor — Phase 1

## Objective

Reduce `scripts/phase0_run.gd` from a single implementation owner into a stable composition facade without changing gameplay contracts, save schema, feature APIs, or external method names.

The supplied runtime is 17,923 lines and exposes 862 top-level functions. `SysMap.xml` already describes many domain systems, but `phase0_run.gd` still owns most integration logic, mutable state, presentation, combat orchestration, UI, persistence adapters, and runtime callbacks. Phase 1 uses branch-by-abstraction: state stays on `CrawlBrawlRun`, while one bounded subsystem moves behind delegates.

## What Phase 1 extracts

### `run_world_presentation.gd`
105 functions.

Owns presentation logic for:
- world/terrain drawing
- streamed terrain chunk draw bounds
- ground/rock macro tiling
- biome/material visual selection
- visual props, formations, and landmarks
- terrain visual cache invalidation
- minimap raster/cache construction and patching

### `run_actor_presentation.gd`
46 functions.

Owns presentation logic for:
- command core and structures
- turrets/barriers/torches/chests visual state
- enemies and brood nests
- bullets and enemy hazard patches
- player sprite/status/held weapon rendering
- mining beam and targeting
- structure relocation/build holograms and build belt

### `run_hud_presentation.gd`
21 functions.

Owns presentation logic for:
- HUD motion smoothing
- comms queue and severity transitions
- HUD panels, objective state, and state glyphs
- atmospheric lighting pools
- region prop lights
- contact shadows and ambient motes

## Compatibility strategy

`CrawlBrawlRun` remains the scene-facing class and public method facade. Each extracted method keeps its original name and signature in `phase0_run.gd`; the method body delegates to one of the presentation components. Existing callers therefore continue calling the same method on the run node.

Mutable state intentionally remains on the host during Phase 1. Components proxy only the state they use. This avoids a dangerous simultaneous state migration and behavior migration.

Compile-time constants used by an extracted component are mirrored into that component using a dependency-closed subset of the original constants. This is transitional. A later phase should move shared constants into a single `run_config.gd`/contract module after runtime behavior has been characterized.

## Files to overlay into the project

- `scripts/phase0_run.gd`
- `systems/run_components/run_world_presentation.gd`
- `systems/run_components/run_actor_presentation.gd`
- `systems/run_components/run_hud_presentation.gd`

The other files in this package are documentation, maps, validation output, and the reproducible extractor.

## Invariants that must not change

1. `class_name CrawlBrawlRun` remains the runtime scene contract.
2. Existing method names/signatures remain callable on `CrawlBrawlRun`.
3. `SAVE_VERSION` remains 14 and RealmSave schema behavior is untouched.
4. Authoritative mutable gameplay/save state remains on `CrawlBrawlRun` in Phase 1.
5. Existing system script paths and APIs remain unchanged.
6. Presentation components do not own gameplay progression, spawning, damage, economy, or persistence decisions.
7. No feature behavior is intentionally changed in this phase.

## Recommended next extraction order

1. **World runtime** — streaming/preload scheduling, exploration/discovery, terrain invalidation; leave drawing in world presentation.
2. **Operator runtime** — input, movement, mining, loadout/backpack, pickups, onboarding.
3. **Encounter runtime** — scouts, hive awareness, waves, spawn admission, nests, enemy routing/locomotion.
4. **Combat runtime** — weapons, bullets/projectiles, hazards/status, hit resolution, combat feedback.
5. **Structure runtime** — placement, barriers, turrets, torches, doors, chests, foundry world interactions.
6. **Economy/progression runtime** — shop, materials/scrap, crafting, upgrades, skill tree, armor/base progression.
7. **Persistence runtime** — checkpoint slots, serialization, load/migration, recovery cache.
8. **Overlay UI runtime** — pause, archive, command core, foundry, chest, backpack Control-tree construction and interaction.
9. **State ownership migration** — only after the above behavior seams are stable, move mutable state out of `CrawlBrawlRun` into explicit state objects/components.

## Why state migration is deliberately later

Moving 400+ run fields at the same time as 800+ methods would mix two kinds of change: ownership and behavior. That makes save regressions, accidental copies of Dictionaries/Arrays, signal breakage, and cross-system initialization ordering much harder to isolate. The facade-first approach gives each later extraction a rollback boundary.

## Validation performed here

Static structural validation only; Godot is not installed in this execution environment and the full project/dependency tree was not supplied.

Passed checks:
- 862 facade methods remain in `phase0_run.gd`.
- 172 implementation functions were extracted: 105 world + 46 actor + 21 HUD.
- all 172 host methods delegate to the mapped component.
- GDScript lexical scan reports no error tokens in the modified host or three component files.
- delimiter balance is zero for `()`, `[]`, and `{}` in all modified scripts.
- extracted components contain no unresolved references to the monolith-local runtime entity type names.
- every call from an extracted component to a non-owned `CrawlBrawlRun` method is routed through `host.<method>`.

## Runtime regression gate to run in the real project

At minimum, run the tests already named by `SysMap.xml` for the affected presentation contracts:

- `realm_visual_test`
- `terrain_chunk_render_test`
- `terrain_seam_render_test`
- `floor_macro_tile_test`
- `hud_minimap_test`
- `display_uix_test`
- `combat_sprite_usage_test`
- `combat_impact_test`
- `enemy_projectile_vfx_test`
- `held_weapon_alignment_test`
- `torch_phase1_test`
- `runtime_asset_integrity_test`
- `smoke_test`
- `run_regression_batch`

Also verify boot/resume, mining terrain redraw, build placement preview, turret art, held-weapon alignment, minimap scrolling, base attack cards, foundry/torch light pools, and HUD comms in an actual run.

## Rollback

Phase 1 is independently reversible: restore the original `scripts/phase0_run.gd` and remove the three `systems/run_components/run_*_presentation.gd` files. No save migration or data rewrite is required.


## Phase 1.1 live Godot 4.7.1 hotfix

The first real import on Godot 4.7.1 returned OS exit code 0 but emitted 106
GDScript parse errors across the three presentation components. The launcher
correctly detected those errors. Every reported failure was an inferred local
(`:=`) whose right-hand expression became dynamically typed after extraction
through the Phase-1 host proxy boundary.

This hotfix changes only those 106 compiler-reported local declarations from
`:=` to `=`. Their assigned expressions and control flow are unchanged. All other
local static inference is preserved in the runtime files. The generator contains
a broader compatibility fallback so future regeneration will not recreate this
class of import failure.
