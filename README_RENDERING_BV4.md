# Crawl Brawl Rendering BV4 Hotfix

Target: the working Crawl Brawl build represented by `CrawlBrawl_PreHotFix_BV4.zip`.
Godot target: 4.7.1.
Save schema/version: unchanged (`SAVE_VERSION = 14`).

## Goals

This pass stabilizes the interaction rendering hot path and restores chest presentation/transfer behavior without changing combat balance or progression rules.

## Rendering and frame-budget changes

### 1. Immediate terrain mutation overlay
Mining and placed-block changes no longer depend on a full 24x24 regional chunk raster before the player can see the result.

- A lightweight `TerrainMutationLayer` redraws the changed cell plus its eight neighbors immediately.
- Full chunk rasters remain authoritative, but are coalesced while mining/building is active.
- The mutation overlay is capped at 128 cells to prevent it becoming a second world renderer.
- Streamed-out regions now clear their pending mutation/refinement state.

### 2. Deferred full-quality terrain refinement
Lean terrain redraws are no longer treated as permanently finished.

- Lean chunk commits schedule a later full-quality pass.
- Expensive regional prop/formation/landmark cache invalidation is moved out of the mining frame.
- Quality refinement runs only when chunk backlog, movement, mining, and combat pressure permit it.
- Full terrain invalidation clears temporary mutation/refinement overlays safely.

### 3. Tighter sprite presentation

- World, actor, effects, lighting, HUD, and overlay draw roots use nearest texture filtering.
- Camera presentation is pixel-snapped without changing simulation positions.
- Mob texture centers, player sprite centers, held-weapon mounts, mining-gun mounts, and pickups are snapped to the pixel grid.

### 4. Effects draw-path tightening

- EffectsLayer no longer redraws merely because enemies exist.
- Off-screen bullets, hazard patches, sparks, and XP text are culled before draw calls.
- Actor animation and effects invalidation are separated so unrelated effect work is not performed every hostile frame.

## Chest restoration

### Visible cargo
Chest and field-pack panels now render both raw and refined material manifests. Previously refined cargo could exist in the chest but never appear because the UI only enumerated `RAW_ORDER`.

### Correct withdrawals
`WITHDRAW ALL` now:

- honors available backpack material capacity;
- restores raw cargo to `material_economy.raw`;
- restores refined cargo to `material_economy.refined`;
- leaves overflow in the chest instead of silently overfilling the pack;
- updates the chest fill bar immediately;
- produces explicit stored/withdrawn/full feedback.

### Save repair
Older saves affected by the previous chest-withdraw bug can contain refined IDs under the serialized raw dictionary. `material_economy.restore()` now migrates those misplaced units into the refined inventory instead of discarding them.

### UI refresh
Old GridContainer children are detached immediately before deferred deletion, preventing a one-frame old+new cargo layout overlap during transfers.

## Other consistency fix

Opening/closing a Heavy Doorway now explicitly invalidates actor/effects presentation so the doorway art updates immediately instead of waiting for unrelated actor movement.

## Validation completed here

- 50/50 static BV4 regression gates passed.
- Existing function signatures retained for every pre-existing function in all four modified scripts.
- Delimiter balance passed for all modified scripts.
- No duplicate function declarations introduced.
- No new component proxy `:=` inference hazards introduced.
- `SAVE_VERSION` remains 14.
- Hotfix ZIP integrity and SHA-256 checks are produced separately.

## Remaining runtime gate

The supplied BV4 archive does not include `project.godot`, so this environment cannot run the complete project import/runtime gate. Use the Crawl Brawl launcher against the full project after overlaying this hotfix and run **Validate Build** before playtesting.

## Recommended playtest

1. Mine continuously across a region seam for 30-60 seconds and watch for frame hitching and stale wall edges.
2. Place and re-mine biome wall blocks rapidly; confirm the visual tile changes immediately.
3. Stop mining and remain still; verify regional decorative detail settles back to full quality.
4. Fight a dense encounter and compare projectile/spark smoothness, especially with off-screen mobs.
5. Open a chest containing raw and refined materials; confirm both are visible.
6. Deposit all and withdraw all with both free and nearly-full backpack capacity.
7. Confirm the world chest fill bar changes immediately after each transfer.
8. Load an older save that had refined chest withdrawals, if available, and verify the refined units are recovered.
9. Open/close a Heavy Doorway while no enemies are present; confirm its art updates immediately.
