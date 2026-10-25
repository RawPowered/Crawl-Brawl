# Crawl Brawl BV5.5 - Frame Budget + Flow-Step Commitment

BV5.5 is based on verified `BV5-DEV007` (SHA256 `d3dafa7d5018675bf3272fd2808fcf9b9e6fb5776b52141aa2933b1ebba77e48`). It is a bounded performance/routing pass: no economy, progression, save-schema, or art changes.

## Why this pass exists

DEV007 showed real progress: regional flow produced 31,966 successful steps and local fallback reused 8,468 committed steps against 877 builds. Mining mutations were also cheap (0.336 ms peak commit). However, 4,225 sampled frames were still over 33 ms, render/simulation ownership still peaked at 61/59 regions, and 9,345 no-flow/greedy decisions plus 578 stall recoveries remained.

The remaining work therefore moves from "repair routing" to "enforce a strict active-world budget and stop recomputing a good routing decision every frame."

## Runtime changes

### Hard active-world caps

- `MAX_RENDER_REGIONS`: 36 -> 24.
- `MAX_SIMULATION_REGIONS`: 49 -> 36.
- Simulation capacity is now aligned with `MAX_FLOW_REGIONS` (36), so the live hostile envelope cannot exceed the full regional-flow budget by design.
- `apply_render_window()` caps callers internally; callers can no longer bypass the budget by handing it an oversized region dictionary.
- The legacy `schedule_region_window()` path uses the same render cap + simulation halo contract.
- `_update_region_streaming()` forces a render-window sanitization whenever an old/legacy path leaves render or loaded-region counts above budget, even if the player is stationary.

### Prepare is not simulate

`WorldGrid.ensure_regions_around()` is now prepare-only in sparse infinite streaming. Far nests/frontier/ecology helpers may request terrain preparation, but they cannot add those chunks to `loaded_regions` or mark them explored. Only the bounded render/simulation window owns high-frequency simulation residency.

### Render-only visual cache building

Formation/prop cache work is serviced only for regions currently in the render window, not for every prepared simulation-halo region.

### Per-mob regional flow-step commitment

Each spider now caches one regional flow exit keyed by:

- source cell,
- target base id,
- `flow_epoch`.

While the spider remains in that cell, the cached next step is reused instead of rerunning `ranked_passable_neighbors()` plus body-clearance probes every combat frame. Dynamic structure edits already invalidate the flow epoch/blocker state, so normal reuse needs only the live blocker-cell check.

This reduces CPU work and removes another frame-to-frame opportunity for the steering layer to choose a different exit direction while traversing the same cell.

Telemetry now reports `flow_step_build` and `flow_step_reuse`.

## Diagnostic attribution

The next `diagnostics/LAST_SESSION.json` additionally records:

- enemy update peak microseconds and count of enemy-update frames >=4 ms,
- streaming update peak microseconds and count of streaming-update frames >=4 ms.

This gives the next pass direct attribution if frame spikes remain after the active-window fix.

## Expected DEV008 gates

- `render_regions_peak <= 24`
- `simulation_regions_peak <= 36`
- `flow_step_reuse` should materially exceed `flow_step_build`
- `no_flow`, `greedy`, `foot_aim_blocked`, and `stall_recover` should decline versus DEV007
- frames over 33 ms should decline materially from DEV007's 4,225 / 18,556 samples
- mining mutation/commit timings should remain sub-millisecond

If the hard active-world gates hold but frame spikes remain, the new `runtime_phases` fields should tell us whether enemy simulation or world streaming is still responsible. At that point the next optimization should target the measured phase rather than expanding this patch.

`SAVE_VERSION` remains 14.
