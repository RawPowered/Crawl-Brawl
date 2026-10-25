# Crawl Brawl BV5.2 — Routing + Mining Latency Stabilization

Baseline: `BV5-DEV003` (`f97b51c620d72c890d0e4af418debb3a5e4002afa05cc2f9eb97c13a36e8965e`).

This is a behavior-preserving stabilization pass aimed at the remaining rare mob spinning, intermittent siege hitching, and mining-wall disappearance delay.

## Changes

### 1. Route-cache invalidation is no longer a per-key mining-frame loop

`WorldGrid.invalidate_walkable_route_cache_for_cell()` previously discovered that a changed terrain region intersected a spawn-lane corridor, copied every route-cache key into an array, then erased each key in interpreted GDScript. Because route-cache keys do not encode traversed regions, the end result was already effectively a whole-cache invalidation.

BV5.2 keeps the same correctness behavior but performs one native `Dictionary.clear()` after the first relevant corridor hit. The remaining scan is only over spawn-lane corridors, not all cached routes.

### 2. Lightweight route viability cannot build routes

`_compute_wave_pressure_nearby()` can call `_spider_route_viable_light()` frequently. That function previously invoked `_local_route_step_toward()`, which constructs a bounded BFS route and mutates the spider's fallback commitment fields.

BV5.2 introduces `_local_route_viable_read_only()`. The light path can inspect an existing committed fallback or test a one-step greedy option, but it cannot rewrite fallback routing state. Full local BFS construction remains owned by the movement/recovery path.

### 3. Stuck recovery uses the already-selected combat target

The live movement loop now calls `_recover_stuck_spider_to(spider, direction, combat_target)`. Recovery no longer re-runs torch/turret/base target selection after the movement target was already chosen.

The existing two-argument `_recover_stuck_spider()` remains intact as a compatibility facade for older tests/tools.

### 4. Recovery-side hysteresis

Each spider carries two transient values:

- `recovery_side_sign`
- `recovery_side_lock_until_tick`

A lateral recovery side is favored for 90 combat ticks. This prevents consecutive stuck recoveries from alternating left/right at the same corner unless geometry actually forces a different solution.

### 5. Post-recovery viability cache is refreshed

Wave-straggler recovery physically moves a spider. BV5.1 then immediately rechecked route viability using the negative cache computed before that move. BV5.2 invalidates the route-check tick after recovery so the post-move state is genuinely re-evaluated before relocation.

### 6. Mining lighting is decoupled from input frequency

The block mutation renderer remains immediate. Held mining now dirties the heavy lighting layer every fourth combat frame instead of every frame. When a cell actually opens, the mutation event dirties lighting once so the new geometry/shadow state still catches up immediately after the block change.

## Validation targets

1. Mine rapidly through ordinary rock and across region seams. The wall should disappear through the mutation patch without waiting on route-cache housekeeping.
2. Fight around corners, barriers, and Heavy Doorways. Rare stalled mobs should commit to one recovery side instead of visibly flipping left/right.
3. Run a dense encounter with telemetry enabled. `local_route_reuse` should remain healthy while pressure counting no longer creates local BFS builds by itself.
4. Validate the build in the native launcher before playtesting.

## Runtime gate

This environment does not include Godot 4.7.1, so final import/runtime validation remains on the local Crawl Brawl launcher. Save version remains `14`; no asset or save-schema migration is introduced.
