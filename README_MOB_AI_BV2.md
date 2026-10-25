# Crawl Brawl Mob AI / Routing Stabilization BV2

Base: `Crawl_Brawl_Pre_HotFix_BV1.zip`
Save schema: unchanged (`SAVE_VERSION = 14`)
Godot target: 4.7.1

## What this hotfix addresses

### 1. Flow-rebuild debounce starvation
The prior runtime queued a routing refresh from no-flow mobs every frame and then did:

`terrain_flow_rebuild_cooldown = max(current, TERRAIN_FLOW_REBUILD_DELAY)`

Because the request happened continuously, the countdown was pushed back to 0.9 seconds every frame and could never expire. The telemetry signature was extreme: a long session completed with zero flow routing and persistent greedy/no-flow fallback.

BV2 changes routing refresh to a **leading-edge debounce**. The first accepted dirty region arms the rebuild. Repeated requests are coalesced and cannot postpone the deadline.

### 2. Route-aware repair corridors
A light/mining flow rebuild only retained dirty/player/core regions. When those regions were separated, the flow field saw disconnected islands and could not reach the mob.

BV2 retains one farthest repair anchor per target base and builds a connected regional corridor through the authored spawn/core backbone before rebuilding the affected base flows.

### 3. Anti-spiral local routing
The old no-flow fallback was pure Euclidean greedy routing. It could not take a temporary sideways/away step around a wall. At a blocked cell it repeatedly aimed at itself, recovered sideways, and was pulled back toward the same wall.

BV2 adds a bounded local BFS fallback (10-cell radius / 144-node budget) and commits the selected first step until the mob changes cells. Immediate reversal is strongly penalized.

### 4. Zero-vector steering
A zero desired direction used to preserve the previous heading (or force RIGHT). That turned a legitimate stop/self-cell result into a false movement direction and fed the stuck-recovery loop.

BV2 treats zero desired direction as a real stop.

### 5. Spawn admission
Wave, broodling, guardian, nest-pressure, and relocated hostiles are now assigned only to an active base with a topologically valid authored route. Sparse worlds fall back to known registered lanes when a local player-adjacent spawn is not route-safe.

### 6. Combat commitment
When a mob is close to its intended combat target and has line of sight, it commits directly to that target instead of continuing to chase grid waypoint centers. Core melee reach was slightly widened to match the physical footprint so mobs engage instead of orbiting the core edge.

The unreachable legacy "stall >= 0.85 siege attack" branch was removed because the code reset stall at 0.45 first, making that branch impossible to execute.

### 7. Routing telemetry share
`no_flow` and `dead_end` are diagnostic causes, while `flow_ok` and `greedy` are movement modes. The telemetry percentage denominator now uses the two movement modes rather than double-counting the same fallback decision.

## Install
Copy the contents of this ZIP over the Crawl Brawl project root, preserving paths.

Changed runtime files:
- `scripts/phase0_run.gd`
- `systems/run_components/run_world_presentation.gd`
- `systems/gameplay_telemetry.gd`

Mapping updates:
- `EnVars/SysMap.xml`
- `EnVars/VarMap.xml`

## What to test
1. Start from the same realm/save where mobs previously spiraled.
2. Let at least one hunting party fully spawn and reach the base/player.
3. Put a barrier or barricade in a route and watch mobs approach and attack/navigate around it.
4. Move far enough from Command Core that mobs must traverse multiple regions.
5. Test a turret-hunting brute/leaper and a player-hunting spitter/leaper.
6. Leave telemetry enabled and send the new `gameplay_telemetry.ndjson` after 5–10 minutes.

## Expected telemetry improvement
- `flow_ok` should become non-zero after the first route repair.
- `refresh_batch` should fall from many batches per second to roughly dirty-region cadence rather than frame cadence.
- `stall_recover` and `foot_aim_blocked` should fall substantially.
- `greedy` is still allowed during lazy streaming/repair, but should no longer be the permanent routing mode.

## Runtime validation status
Static validation and deterministic failure-mode simulations pass. A true Godot 4.7.1 runtime/playtest still requires the user's Windows project because this supplied ZIP does not include `project.godot` and the execution environment does not have Godot installed.
