# Crawl Brawl BV5.4 - Streaming Ownership + Siege Routing

BV5.4 follows the DEV006 diagnostic session. The session showed that mining cell mutation was already cheap (0.32 ms peak commit), while 30.5% of sampled frames exceeded 33 ms and regional mob routing produced zero successful flow steps.

## Fixes

- Corridor preload bursts no longer replace live render/simulation tickets.
- Infinite-world render travel headroom is reduced from radius 2 to radius 1; camera bounds plus the simulation halo remain authoritative.
- Base, lane, and carrier flow fields model stable terrain topology rather than dynamic player-built blockers.
- Doors/barriers are resolved by the blocker cache. When a terrain-flow step enters a blocking structure, mobs commit to that footprint as a breach instead of attempting to local-BFS around a sealed defense.
- Structure placement/destruction/door toggles refresh blockers and route viability without rebuilding regional BFS fields.
- `_enemy_can_occupy()` removes a square-root distance from its hot probe loop.
- Terrain flow rebuilds remain pending while mining is held and execute after cutter release.
- Telemetry adds `flow_breach` so the next session can distinguish useful siege commitment from fallback routing.

## Expected DEV007 diagnostics

- `render_regions_peak` should fall sharply from DEV006's 66-region peak.
- `simulation_regions_peak` should fall from 69 toward the local render+halo envelope.
- `flow_ok + flow_breach` should become non-zero and ideally dominate `greedy`.
- `stall_recover` and `foot_aim_blocked` should decline.
- Mining commit timings should remain sub-millisecond even if the overall frame is busy.

`SAVE_VERSION` remains 14. No economy or progression balance is changed.
