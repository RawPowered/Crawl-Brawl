# Crawl Brawl BV5.3 — Chunked World / Simulation Stabilization

BV5.3 is the runtime-boundary pass for Crawl Brawl's open world. It does not copy Minecraft implementation details; it adopts the same useful high-level principle: **world state can be durable while only a bounded neighborhood is generated, simulated, and rendered at full frequency.**

## Runtime hierarchy

1. **Durable world memory** — realm seed, deterministic generation contracts, sparse `cell_deltas`, visited/discovery/save state.
2. **Prepared chunk horizon** — a rolling ~9x9-region generation/cache horizon around travel instead of the old growing 1000x1000-cell prepare rectangle.
3. **Simulation window** — the visible render set plus a one-region halo, capped at 81 regions. Spawn admission and high-frequency hostile AI use this boundary.
4. **Render window** — the smaller viewport-driven region set, capped at 64 and normally much smaller.
5. **Mining mutation sectors** — persistent 8x8-cell overlay layers update changed terrain locally while expensive 24x24 regional rasters wait for a quiet refinement frame.

## Mining latency changes

- Mining aim no longer projects the chunk-stream center ahead of the player.
- While the cutter is held, background topology preparation and visual prop/formation cache builds receive zero frame budget.
- A block mutation signal is emitted before route-cache maintenance so its immediate visual update is queued first.
- Block placement and terrain-open gameplay hooks no longer schedule duplicate visual invalidations.
- New mutations redraw only the touched 8x8 mutation sector(s), rather than replaying every outstanding mutation or rebuilding the full 24x24 terrain region.
- Full-quality region refinement is forbidden during mining, movement, bullets, or active enemies and runs only after a stable idle interval.
- Telemetry now separates `open_cell_peak_us`, full `mining_commit_peak_us`, and mutation-queue cost so the next playtest can identify whether any remaining hitch is terrain state, economy/discovery work, or presentation.

## Mob simulation / spawning

- `WorldGrid.is_spawn_ready()` now means **prepared + simulation-active + walkable**, not simply generated somewhere in the prepare horizon.
- Hostiles outside the simulation window skip LOS, target selection, pathfinding, collision, and attacks.
- Spawn population gates count simulation-active hostiles rather than every hibernated mob in world memory.
- Incidental, non-wave, non-persistent ecology hostiles are retired after 12 seconds outside simulation so long-distance travel cannot grow the live enemy array forever. Wave members, scouts, brood carriers, guardians, and nest-owned enemies hibernate instead.
- Flow corridor bookkeeping now works directly in **region coordinates**, removing the old per-tile rectangle scan and removing legacy 512x288 coordinate clamps from infinite-world routing.

## World-memory invariants

- The same seed and generator version must reconstruct the same unedited region.
- Player terrain changes remain in `cell_deltas` and are reapplied when an evicted region returns.
- Generated sparse cell arrays outside the rolling prepare horizon are evicted; they are not the authoritative long-term world record.
- Prepared chunks are not automatically visited, rendered, spawn-ready, or simulation-active.
- Visible/travel-critical region requests are promoted ahead of low-priority horizon generation.

## Diagnostics handoff

On a normal telemetry-enabled shutdown, Crawl Brawl writes:

`diagnostics/LAST_SESSION.json`

Launcher v3.2's source-only handoff includes this small JSON file. It contains frame-spike counts, mining frame peaks, mining transaction timing, simulation/render region peaks, preload backlog, streaming work, routing counters, and enemy peak. This gives the next browser/Codex session real performance evidence without adding the heavyweight runtime logs to the ZIP.

## Runtime validation requested

1. Validate the build in the native launcher.
2. Mine continuously while stationary for 30–60 seconds.
3. Mine while walking and immediately after crossing a region boundary.
4. Fight a dense encounter around walls and Heavy Doorways.
5. Travel several regions away so old chunks leave render/simulation, then return.
6. Confirm mined terrain persists after leaving/re-entering the area.
7. Confirm local hostile spawning continues after long travel and waves do not hang.
8. Exit normally with telemetry enabled, then create the next source handoff so `diagnostics/LAST_SESSION.json` is included.

Save schema remains 14. BV5.3 changes runtime residency/simulation policy, not persistent gameplay schema.
