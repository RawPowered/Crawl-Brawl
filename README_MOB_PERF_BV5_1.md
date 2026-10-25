# Crawl Brawl BV5.1 - Mob Stability + Siege Frame-Pacing Pass

Source baseline: `BV5-DEV002` (`cf6cc98ea12140c6dc621c2233d5d86c81052b1d82896436957526896f36ed7c`).

## Scope

This pass is intentionally narrow. It addresses the remaining minor mob spinning and siege hitching after Mob AI BV2 and Rendering BV4 without changing save schema, economy balance, wave counts, or authored map topology.

## Routing stability fixes

- A valid regional flow no longer clears the mob's committed local fallback route **before** proving that an occupiable next flow cell exists.
  - Previously, a flow could technically contain the mob's cell while every ranked next cell was blocked by a live structure/body-radius constraint.
  - The runtime cleared fallback commitment, discovered the flow edge was unusable, rebuilt local BFS, then repeated that process on the next frame.
  - This caused unnecessary BFS work and could alternate wall-following choices around barriers.
- Local fallback routing now reuses the combat target already selected for the frame instead of calling torch/turret target selection a second time.
- Mob facing is driven by **actual displacement after collision sliding**, not merely the requested steering vector. This removes visual rotation toward a blocked diagonal while the body is sliding along one axis.
- Brood carriers use the same actual-displacement facing rule.
- Open Heavy Doorways are no longer considered attackable nearby blockers. Mobs pass through them instead of stopping at the threshold.
- Heavy Doorway open/close now refreshes the live enemy blocker cache immediately and schedules a flow refresh for every touched region.
- Heavy Doorway footprint upgrades invalidate the structure spatial cache and refresh routing for the expanded footprint.

## Performance fixes

- The structure spatial index is now persistent between explicit structure mutations.
  - Prior behavior rebuilt every combat frame even though structures do not move.
- `_nearby_structure()` now uses `CombatSpatial` buckets instead of two full structure-array scans for every mob every frame.
- Torch acquisition no longer performs a global deployed-torch scan for every eligible mob.
- New torch target acquisition is staggered over three combat frames; retained targets remain responsive every frame.
- Fallback movement no longer re-runs torch/turret acquisition just to determine the same target cell.

## Telemetry additions

`route_snapshot` now includes:

- `local_route_build`
- `local_route_reuse`
- `dt_local_route_build`
- `dt_local_route_reuse`

A healthy play session should show reuse rising above builds when mobs are temporarily navigating around live blockers. If builds remain close to fallback-frame count, another route invalidation source is still forcing unnecessary repaths.

## Validation target

1. Validate Build in the native launcher.
2. Run a dense encounter around barricades and a Heavy Doorway.
3. Toggle the doorway open while mobs are approaching. They should transition through rather than orbit/attack the open threshold.
4. Close the doorway. Mobs should recognize the blocker immediately and reroute/attack it consistently.
5. Observe mobs sliding along walls: sprite facing should follow actual travel rather than rotating into the wall.
6. Keep gameplay telemetry enabled and compare:
   - `stall_recover`
   - `foot_aim_blocked`
   - `local_route_build`
   - `local_route_reuse`
   - `greedy_share`
7. After testing, use Launcher v3.2 **SAVE CODE HANDOFF ZIP** to create the next numbered source state.

## Compatibility

- `SAVE_VERSION`: unchanged (`14`).
- No asset payload changes.
- No wave/economy tuning changes.
- No serialized Spider fields added.
