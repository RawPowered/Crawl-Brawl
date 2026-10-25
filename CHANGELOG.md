# Changelog

## 2026-08-22 — BV5.7 Opening Pacing + Frame Phase Isolation

- **Protected opening:** passive region traversal/surveying no longer adds Hive Awareness or contact pressure. The first scout waits for at least three surveyed regions; early scout investigations are separated by two additional regions.
- **Readable first contact:** one scout report creates partial pressure only. The normal early path requires a second confirmed contact, starts with a four-hostile hunting party, and applies a 70-second recovery before another pressure-backed party may release.
- **Delayed brood escalation:** remote brood milestones move to awareness tiers II/IV/VI/VIII, new nests incubate for 90 seconds, activation radius falls to 150 px, and brood pulses are slower.
- **10 Hz bounded ecology authority:** one world-ecology step maximum per display frame; brood/frontier work alternates, far-nest retry runs at 2 Hz only while pending, and ecology yields whenever a visible terrain raster is waiting.
- **Heavy-phase isolation:** lighting is deferred on terrain-raster and ecology-authority frames so DEV009's 40-50 ms terrain/lighting/ecology costs cannot stack into the same display frame.
- **Startup hitch removal:** run bootstrap no longer synchronously generates even one full decorative prop/formation region before play begins. Active streaming also performs no eager decorative-cache builds.
- **Lean terrain fast path:** active 24x24 chunks skip formation generation, two-cell bleed, biome-boundary contamination, and redundant eight-neighbor wall-edge scans. Full visual refinement remains available while gameplay is UI-frozen.
- **Lighting cache safety:** active lighting consumes existing prop caches only and uses a sparser deterministic mote grid; it cannot synthesize decorative caches inside a lighting draw.
- **Pacing/phase telemetry:** LAST_SESSION now records ecology subphase peaks plus awareness, pressure, encounter, brood-nest and cooldown state for the next runtime comparison.
- **Regression:** adds `open_world_pacing_bv57_test.gd` and updates awareness/scout/breather contracts. Main save schema remains 14.

## 2026-08-22 — BV5.6 Open-World Runtime Authority

- **Tower-defense wave authority retired:** live hunting-party size, cadence, specialist selection, health/damage/travel scaling, frontier progression, nest expansion, apex gates, and skill progression now derive from Hive Awareness / ecology / expedition accomplishments rather than encounter count.
- **Hunting parties are delivery events:** once authorized contacts enter the world, the delivery closes. No kill-all cleanup, straggler recall, periodic wave boss slots, inter-wave countdown, or wave-clear economy remains in the live loop.
- **20 Hz bounded world tick:** scouts, missing-scout escalation, encounter delivery, Frontier activation, brood ecology, and far-nest retry advance at 20 Hz with at most two catch-up steps per display frame.
- **Active-play terrain is always lean:** expensive decorated region refinement runs only while gameplay is already UI-frozen, targeting DEV008's pre-combat 149 ms-class frame spikes.
- **Tighter active world:** render cap 12 regions; simulation cap 25 regions. Prepared deterministic terrain remains separate from active simulation/render ownership.
- **Pressure-native runtime APIs:** live mob role, biome role, health, damage, speed, and catch-up calls use pressure-named functions. Wave-named helpers remain compatibility wrappers only.
- **Frontier gates:** site construction is exploration + guardian + clear-site based; Frontier Core MK2/MK3 use Expedition Level 4/8.
- **Diagnostics:** LAST_SESSION adds terrain/actor/lighting draw timings plus bounded ecology-tick timing for the next performance pass.
- **Regression:** adds `open_world_pacing_bv56_test.gd`; save schema remains 14.

## 2026-08-22 — BV5.5 Frame Budget + Flow-Step Commitment

- **Hard live-world budget:** render cap 24 regions; simulation cap 36 regions, aligned with `MAX_FLOW_REGIONS`. `apply_render_window`, legacy scheduling, and stationary over-budget recovery all enforce the caps.
- **Prepare-only far helpers:** sparse `ensure_regions_around()` no longer grants simulation/visited ownership to frontier/nest/ecology preparation requests.
- **Render-only visual builds:** prop/formation cache generation ignores simulation-halo chunks until they are actually rendered.
- **Same-cell regional flow commitment:** spiders cache the chosen regional flow exit per source cell/target/flow epoch instead of re-ranking neighbors and body clearance every combat frame. Telemetry records flow-step build/reuse.
- **Performance attribution:** LAST_SESSION now records enemy-update and streaming-update phase peaks / >=4 ms counts so remaining frame spikes can be assigned to a concrete runtime phase.
- **Regression:** adds `frame_budget_bv55_test.gd` for hard caps, prepare-vs-sim ownership, flow-budget alignment, and stable flow-step commitment. Save schema remains 14.

## 2026-08-22 — BV5.3 Chunked World / Simulation Stabilization

- **Bounded prepared horizon:** replaces the growing 1000x1000-cell prepare rectangle with a rolling ~9x9-region generation/cache horizon. Sparse region cell arrays outside that horizon can evict and reconstruct from deterministic generation plus `cell_deltas`.
- **Simulation distance separated from render distance:** render tickets remain viewport-driven; simulation uses render + one region halo (cap 81). Prepared-only chunks are not spawn-ready or high-frequency ticked.
- **Mining owns its frame:** cutter input no longer drives travel prefetch, and background topology generation plus visual prop/formation cache builds pause while mining. Topology and visual-cache generation also never stack on the same frame.
- **8x8 mutation sectors:** mined/placed terrain updates persistent local CanvasItems, so a new block redraws only touched sectors. Full 24x24 chunk rasters are deferred until quiet idle refinement.
- **Single visual invalidation:** `terrain_cell_changed` owns mutation presentation; placement and terrain-open hooks no longer invalidate the same cell twice. Terrain mutation notification is emitted before route-cache maintenance.
- **Region-native routing corridors:** flow-corridor construction no longer scans every tile between endpoints and no longer clamps infinite coordinates into the legacy 512x288 realm rectangle.
- **Bounded hostile simulation:** off-simulation mobs skip AI/LOS/pathing/collision. Spawn caps count simulation-active enemies, while incidental non-persistent background ecology retires after 12 seconds outside simulation; wave/persistent mobs hibernate.
- **Compact performance evidence:** telemetry writes `diagnostics/LAST_SESSION.json` with frame/mining/chunk/routing counters. Mining timing separates terrain-open cost from the full mining transaction. Launcher v3.2 source handoffs include this JSON without shipping full logs.
- **Regression:** adds `chunk_simulation_bv53_test.gd` and updates world-load/open-boundary/realm-scale contracts for bounded prepared, simulation, and render layers. Save schema remains 14.

## 2026-08-22 — BV5.2 Routing + Mining Latency Stabilization

- **Mining elimination latency:** `WorldGrid.invalidate_walkable_route_cache_for_cell()` no longer copies/erases every cached route key in GDScript when a relevant spawn corridor changes. It now performs one native dictionary clear after the corridor hit is established, preserving the existing correctness contract while removing the per-key mining-frame loop.
- **Read-only route viability:** wave-pressure/spawn accounting no longer calls the mutating local-BFS builder. `_local_route_viable_read_only()` checks committed fallback/one-step viability without rewriting mob navigation state.
- **Recovery target stability:** live stuck recovery receives the combat target already selected for the frame rather than performing a second torch/turret/base target selection. The legacy two-argument helper remains as a compatibility facade.
- **Recovery-side hysteresis:** stalled mobs retain the same lateral escape side for 90 combat ticks, reducing the last left/right recovery flips at corners.
- **Post-recovery recheck:** wave relocation invalidates the stale negative viability cache after a physical recovery move before deciding to teleport/reposition.
- **Mining lighting throttle:** held mining no longer rebuilds the lighting layer every frame. Lighting runs every fourth mining frame, while each actual terrain-open mutation dirties lighting once and immediately enters the terrain mutation patch renderer.
- **Regression:** added `mob_routing_stability_bv52_test.gd` for read-only viability, route-cache invalidation, recovery-side commitment, and mutation-render/lighting behavior. Save schema remains 14.

## 2026-08-12 (84)

- **Spawn first-contact unlock**: Removed the four glowing start-chamber breach markers. Hive unlock is now first rock mine or hostile spider kill via `_register_first_contact` (opens seal, `establish_first_breach`, deferred mining_partial flows). Scrap tip `"MINE A WALL // EARN SCRAP TO EXPAND"` stays until first mine even after kill-first unlock. Save: `first_mine_earned`; `first_breach_cell` is always the seal.

## 2026-08-12 (83)

- **Lean terrain raster under backlog**: When redraw queue ≥2 (or boot drain), skip props/decorative overlays and use cached backing colors; boot/mining flush capped to 1 chunk/frame so ~25ms rasters don't stack; player-flow refresh defers while terrain queue is non-empty.

## 2026-08-12 (82)

- **Boot terrain drain**: Near-player boot flush raised to 10 chunks; remaining undrawn stream chunks stay queued and drain at 4/frame until queue ≤3 (`_boot_terrain_drain_active`), cutting the start-of-game 1-chunk hitch train.

## 2026-08-12 (81)

- **FX import miscrop fix**: Hazard/lob/cyst/status sheets use magenta-gutter bands + largest-component crop + padded fit (`python tools/import_enemy_projectiles.py --fx-only`). Stops mid-panel shear on AOE rings. Biome artillery equal-thirds unchanged.

## 2026-08-12 (80)

- **Enemy projectile VFX alive**: Type-driven spin/wobble/trail stretch + lob bob (≤2.5px), WHITE modulate (cyst slight purple), typed thermal/spore hazard draw (never `flame_patch`), venom/DoT status overlay (slow > DoT), muzzle glob puff + `enemy_pop` impacts, flamethrower eviction skips `player_only` hazards, load/death clears status+enemy hazards. Importer cuts FX sheets (`enemy_lob_*`, `enemy_cyst_*`, `hazard_*`, `status_*`). Prompt: `docs/art-prompts/pack-enemy-projectile-fx.md`. Test: `enemy_projectile_vfx_test`.

## 2026-08-12 (79)

- **Enemy projectile Sprint B**: Structure/turret hits for arc/corrosive (spatial buckets + type bias), player venom slow + DoT (DoT ignores i-frames; stacked refresh), capped player-only thermal/spore hazards (≤8), bulwark lob / guardian cyst (1 special lob per encounter). Helper: `systems/enemy_projectile_effects.gd`. Test: `enemy_projectile_sprint_b_test`.

## 2026-08-12 (78)

- **Typed enemy artillery (Sprint A)**: Biome→damage type + L1–L4 combat profiles (`projectile_combat_profile`) bake speed/AoE/damage/cooldown at spit. Central `_try_fire_spitter_projectile`, O(1) enemy bullet cap 24 with 0.25s cap-retry, pressure cached per enemy/bullet tick. Biome VFX already imported; tests: `enemy_projectile_types_test`, updated `biome_bestiary_test`.

## 2026-08-11 (77)

- **Enemy biome projectiles**: Cut/chroma-keyed 7 artillery sheets from `assets/art/mobs/projectiles/` via `tools/import_enemy_projectiles.py` into `assets/art/combat/{biome}_{type}_{glob|trail|splat}.png`. Runtime draw uses `source_biome_id` with `acid_*` fallback.

## 2026-08-10 (72)

- **Spider routing flow batching**: Fallback-path spiders were calling `_mark_flow_region_dirty` every frame (replacing a proper deferred queue), flooding `flow_dirty_regions` and triggering 95ms+ flow rebuilds. Batched into `_service_spider_routing_flow_refresh` (only when stalled ≥0.45s), throttled `_spider_has_viable_route` to every 8 frames per spider.

## 2026-08-10 (71)

- **Brood nest lag pass**: Nest discovery was double-opening chambers and running sync full flow rebuilds; carrier site search could flow-check every scannable cell. Removed duplicate open/ensure from nest discovery, deferred CMD-only flow rebuild, capped nest site flow checks to 16, added nest instrumentation logs.

## 2026-08-10 (70)

- **Barrier-break lag pass**: Logs showed 1220 chunk redraws (37x per region), q>0 frames avg 85ms vs 57ms idle, and `boot_light` disabling on breach causing 95–109ms flow rebuilds. Boot now flushes 6 near chunks only (not all 25). `terrain_chunk_committed` skips redundant re-queues. Breach terrain dirty limited to seam regions (not flow corridors). `boot_light` stays until wave/combat starts, not breach.

## 2026-08-10 (69)

- **Revert chunk mesh cache**: SubViewport texture baking never stored meshes (`cached_chunks: 0`) and the live-draw fallback rasterized all visible chunks every frame (~140ms). Restored direct chunk drawing with Minecraft-style dirty tracking: chunks only redraw when changed, boot flushes 6 near-player chunks, then 1/frame stream.

## 2026-08-10 (68)

- **Chunk mesh bake fix**: Failed bakes no longer drop regions from the redraw queue (was causing permanent transparent void). Viewport readback uses a 2-frame deferred bake, visible offscreen viewport, and relaxed image resize. Uncached chunks fall back to live draw until their mesh stores.

## 2026-08-10 (67)

- **Minecraft-style chunk meshes**: Terrain regions bake once into cached `ImageTexture` meshes via an offscreen viewport. Gameplay draws cheap texture blits; only 1 chunk rebakes per frame (2-3 while mining). Stale meshes stay visible until rebake completes. Boot bakes 3 near-player chunks then streams the rest progressively.

## 2026-08-10 (66)

- **Lag spike pass 2**: Boot flow now uses a light CMD-only rebuild (~9 regions) instead of a 620ms full-network rebuild. Mining partial flow rebuilds CMD only, skips stacked player-flow refresh, and caps mining regions to 12. Restored boot terrain burst; mining coalesces seam redraws when the queue is backed up and drains 2 chunks/frame when queue > 12. Turret-hunter target scans throttle to every 4 frames.

## 2026-08-10 (65)

- **Early lag spike pass**: Defer `_update_enemies` player-flow rebuilds while mining or when a terrain flow debounce is pending; cap player-flow to a 3×3 region window instead of merging all dirty mining regions. Boot terrain now flushes 4 chunks/frame instead of the full stream window in one frame.

## 2026-08-10 (64)

- **Minimap hostile reveal**: Tactical map no longer tracks every loaded-region enemy, turret hunters, brood carriers, or recalled cleanup units. Hostile dots render only inside powered base territory or active torch/lantern vision radius.

## 2026-08-10 (63)

- **Lighting draw trim (Phase 4E+)**: Cell-based camera lighting dirty (replaces 64px threshold). Player movement no longer forces lighting every sub-pixel step; prop lights throttle to every 2nd frame while moving (full rate when mining/combat). Viewport cull for bases, discoveries, structures, bullets, fire patches; `_should_draw_heavy_lighting()` skips prop pass on throttled frames. `_terrain_stream_draw_bounds` uses cached stream regions.

## 2026-08-10 (62)

- **Mining redraw pipeline (Phase 4)**: Single flush owner in `_queue_visual_redraw`; removed streaming burst flush. Mining prioritizes beam/target seam regions (cap 6 candidates, budget 3/frame) instead of sorting the full redraw queue. Added `MAX_TERRAIN_REDRAW_QUEUE=32` prune, `_mining_beam_regions` cache, and viewport cull for `_draw_world` / `_draw_region_prop_lights`.

Verified: `mining_redraw_budget_test`, `terrain_chunk_render_test`, `mining_crosshair_test`.

## 2026-08-10 (61)

- **Phase 3 hot-path defer + throttle**: `ensure_region_for_cell` and `_queue_render_region` are enqueue-only (no sync populate/topology on movement/mining). Mining beam prefetch moved into `_update_region_streaming` with unified `REGION_PRELOAD_MINING_BUDGET=4`; removed duplicate mining preload drain. Render window apply throttled by player/camera region change, moving/mining tick `% 3`, prepare-zone expansion, and signature skip.

Verified: `region_preload_test`, `render_window_throttle_test`, `open_world_boundary_test`.

## 2026-08-10 (60)

- **Streaming delta scans**: Removed per-frame `loaded_regions.duplicate()` and full-key visual warm loop. `process_region_preload_budget` now records `_region_preload_delta`; `_update_region_streaming` warms props/formations only for regions materialized that frame via `take_region_preload_delta()`.

Verified: `region_preload_test`, `stream_window_budget_test`.

## 2026-08-10 (59)

- **Bounded sliding render window**: Replaced add-only viewport streaming with `compute_desired_render_regions` + `apply_render_window` (`MAX_RENDER_REGIONS=64`). Prunes `_stream_window_regions`, `loaded_regions`, and terrain chunk layers when leaving view; defers unprepared regions to preload instead of sync populate on the hot path.

Verified: `stream_window_budget_test`, `open_world_boundary_test`, `terrain_chunk_render_test`.

## 2026-08-10 (58)

- **Open-world boundary removal**: Disabled legacy authored bedrock box in infinite sparse mode (`_uses_authored_bedrock_rim`). Added `ensure_region_for_cell` and viewport-driven `activate_render_window_for_bounds`; streaming now prefetches travel direction via `_region_stream_centers()` and treats prepare-zone prepared regions as ACTIVE for simulation. Removed boot `schedule_region_window` fallback.

Verified: `open_world_boundary_test`, `infinite_region_stream_test`, `terrain_chunk_render_test`.

## 2026-08-10 (57)

- **Post-handoff black screen fix**: Prepare zone no longer mirrors ~1800 regions into the render path at boot. Simulation uses prepared-zone `is_region_loaded`; only the near-player render window gets terrain chunk layers. Removed `loaded_regions` fallback in chunk sync/draw, added `_ensure_boot_render_window()`, full boot chunk flush, and `player_camera.make_current()`.

## 2026-08-10 (56)

- **Expedition Boot lore pass**: Load screen comms and rotating tips rewritten for the tired ship commander tone — failed prior expeditions, one-volunteer drops, nest crash landing, foothold mandate — without spoiling unrevealed story (military site truth, surface arc, missing pioneer reunion).

## 2026-08-10 (55)

- **Handoff crash fix**: Split prepare-zone simulation (`loaded_regions`, full 1000×1000 terrain) from render window (`activate_render_window`, add-only ~25 regions near player). Boot no longer instantiates/flushes ~1800 terrain chunk layers synchronously after load handoff.

## 2026-08-10 (54)

- **Prepare zone tuned to 1000×1000**: Reduced initial bulk load footprint from 5000×5000 to 1000×1000 cells (`INITIAL_PREPARE_SIZE=1000`) so expedition boot completes in reasonable time while keeping stable add-only streaming and 500-cell edge expansion.

## 2026-08-10 (53)

- **Stable 5000×5000 prepare zone**: Initial expedition load bulk-materializes a 5000×5000 cell square centered on the command core (`INITIAL_PREPARE_SIZE=5000`). Runtime streaming no longer recenters a small moving window each frame; terrain render chunks are add-only until the player comes within 100 cells of the prepared edge (`EXPANSION_EDGE_THRESHOLD`), then the zone grows by 500 cells on that axis (`EXPANSION_STEP=500`). Prepared regions inside the zone are never evicted. Longer load, stable gameplay.

Verified: `world_load_bulk_test`, `authored_no_evict_test`, `realm_scale_test`, `terrain_chunk_render_test`.

## 2026-08-10 (52)

- **Minecraft-style world load + Expedition Boot UX**: New blocking load screen pre-generates full authored interior (~252 regions) on new/restart expeditions with lore-forward comms, trait tips, and segmented progress. `systems/world_load.gd` drives phased bulk materialization (`WORLD_LOAD_BUDGET=12`); `scripts/world_load_screen.gd` handles presentation. Three-layer contract preserved: Layer A terrain prepared on load, Layer B stream window only, Layer C exploration (`visited_regions`/`explored_sectors`) player-driven only. Resume skips bulk; `prepare_resume_context` restores spawn route before visited materialize (breach fix). Outdated `generator_version` saves rejected. Exterior horizon prefetch within 100 cells (`EXTERIOR_ENQUEUE_CAP=1`/frame). Megachunk bleed uses prepared authored cells. Boot calls `_bootstrap_stream_visuals()` to flush terrain textures/lighting immediately after load handoff.

Verified: `world_load_bulk_test`, `generator_version_gate_test`, `breached_save_route_test`, `authored_no_evict_test`, `hud_minimap_test`, `combat_pressure_test`, `lazy_save_lifecycle_test`.

## 2026-08-10 (51)

- **Legacy linear hallway extraction**: Retired authored spine/column lattice and boot seed-signature carve. Authored interior regions now materialize via `_generate_region_topology` (cross+rooms, trait branches, playability guards P1–P2). Route-aware 1-wide spawn↔core strips carve on region materialize; `_route_epoch` refreshes strips after `establish_first_breach`. Bunker/seals-only bootstrap; hive pocket owned by start chamber/breach. Frontier POIs route to `core_cell` directly. Vein placement accepts `_near_floor(1)` anchors. `GENERATOR_VERSION` bumped to `2` (new realms only; cell deltas preserved).

Verified: `authored_region_topology_test`, `lazy_region_topology_test`, `route_connectivity_test`, `topology_idempotency_test`, `boot_floor_budget_test`, `world_seed_determinism_test`, `vein_after_topology_test`, `region_density_playability_test`, `random_start_breach_test`, `brood_ecology_test`, `hostile_spawn_admission_test`, `infinite_region_stream_test`, `lazy_materialization_order_test`.


- **Performance pass (Phases 0–5)**: Sparse-safe FlowField uses region-local distance maps (`576` cells/region) so exterior signed coords no longer OOB-crash incremental rebuilds. Visual redraw gated by `_visual_dirty_mask` bitflags with aim invalidation, paused-path HUD dirty-once, decoupled terrain sync, stream-window burst flush, and minimap defer off the draw path. Frame-scoped `_wave_pressure_nearby` cache plus two-tier 220/280px route checks reduce spawn-admission scans; brood nest pulses, aggro bursts, and frontier activation respect `regional_population_cap()` / encounter party size; combat damage routes through `_combat_pressure_level()`; mid-encounter reload clamps `spawns_remaining` to `encounter_party_size()`. Incremental `_rebuild_base_flows` scopes to dirty-region/base intersection, preserves `brood_carrier_flows` on partial rebuild, removes the 80-enemy mining re-defer cliff, tunes flow debounce to 0.45s, and defers carrier site search (one/frame). Terrain chunk formation lookup cached per chunk; mining adjacent-priority flush (up to 3/frame) and `REGION_PRELOAD_MINING_BUDGET=1` enqueue-only preload. Structure spatial buckets plus cached `bases_under_attack`; player flow refresh widens to 0.5s when stable and no recent mine.

Verified: `flow_field_test`, `regional_flow_field_test`, `flow_local_rebuild_test`, `combat_pressure_test`, `brood_ecology_test`, `hud_minimap_test`, `wave_save_fidelity_test`, `terrain_chunk_render_test`, `terrain_seam_render_test`, `hive_awareness_test`, `hostile_spawn_admission_test`.

**Save note:** In-progress saves with legacy high `wave` counters but lower Hive tier encounter quotas become slightly easier on reload — no schema bump.

## 2026-08-09 (49)

- **Hive-tier encounter authority**: Hunting parties now size from Hive Awareness tier (`build_encounter_plan`) instead of cumulative wave count. Legacy wave counter kept for milestones/saves only. Party quota capped at `6 + tier×3` (max 24); population budget tightened. Pause menu shows `HIVE` tier instead of `WAVE`. Brood nest pulses decoupled from encounter headroom reserve.

Verified: `hive_awareness_test`, `combat_pressure_test`, `brood_ecology_test`, `wave_save_fidelity_test`.

## 2026-08-09 (48)

- **Movement hitch trim**: Minimap now scrolls 1–4 cell steps instead of rebuilding 134×74 every tile crossed. Terrain chunk redraws on stream-window shifts only touch added/removed regions (budget stays at 1/frame). Region scheduling early-outs when the stream window is unchanged.

Verified: `hud_minimap_test`, `terrain_chunk_render_test`, `region_preload_test`.

## 2026-08-09 (47)

- **Infinite spawn optimization**: Wave and mining-discovery flow rebuilds no longer bulk-materialize spawn routes. Sparse mode resolves hunting-party spawns on prepared cells only (7–22 cell fallback), skips sync lane connect on carrier ticks, and retries queued brood packs at stream edges until `spawn_ready`. Far nest placement samples the active stream window instead of scanning the full grid; exterior brood sites use signed region bounds; nest lane registration enqueues corridor preload instead of sync carving. `_prune_unreachable_spawn_lanes` runs only when spawn cells change.

Verified: `hostile_spawn_admission_test`, `prepared_spawn_control_test`, `combat_pressure_test`, `brood_ecology_test`, `region_preload_test`.

## 2026-08-09 (46)

- **Terrain boundary seam scheduling**: Stream-window changes now burst-flush all pending terrain chunk redraws the same frame so transparent chunk canvases no longer expose parent `#121820` backing as 384px void slabs. Border neighbors invalidate when new regions enter the window; chunk bleed expanded to 2 cells for macro straddles.

Verified: `terrain_seam_render_test`, `terrain_chunk_render_test`.

## 2026-08-09 (45)

- **Player-centered minimap**: Tactical map now scrolls a 134×74 cell window centered on the player (1 pixel per cell) instead of squashing the finite grid. Immediate cache rebuild on origin change; off-view markers clip safely; cyan `loaded_regions` overlay removed. Edge ticks homeward for off-screen CMD, bases under attack, and active recovery cache; player facing wedge draws last.

Verified: `hud_minimap_test`.

## 2026-08-09 (44)

- **Terrain seam removal**: Complete uniform 2×2 floor blocks now draw one 32×32 macro quad via `_draw_floor_macro_block`; mixed or partial blocks keep per-cell fallback. Terrain backing renders once on `WorldLayer` beneath regional chunks (chunk siblings no longer paint opaque fills over neighbor tiles). Chunks bleed one cell into loaded stream neighbors; terrain chunks sync to the full stream window with rock shells and prepare invalidation.

Verified: `terrain_seam_render_test`, `terrain_chunk_render_test`, `floor_macro_tile_test`.

## 2026-08-09 (43)

- **Unified hostile spawn admission**: Legacy hunting parties, exploration scouts, guardians, brood nests, guardian summons, and settlement-defense attackers now share a two-entity-per-frame admission budget. Multi-mob brood events retain their intended pressure through a bounded queue instead of constructing whole packs in one frame, and inactive/unloaded requests expire safely.
- **Bounded settlement probes**: Frontier activation no longer scans and sorts a 45x45 cell square for every attacker. It samples a deterministic annulus with a prepared-region fallback, removing another intermittent spawn-time spike.

Verified: project compile, focused hostile-admission test, brood-ecology test, combat-pressure test, biome-scout alert test, prepared spawn-control test, base spawn-exclusion test, hive-awareness test, and scene/chunk boot test.

## 2026-08-09 (42)

- **Terrain-oriented mineral veins**: Regional resources now form several small biome-driven seams that begin with a visible cave-face lead and extend into solid rock with occasional concealed members. Realm-wide rare-resource placement is capped per prepared region so early wall edges no longer absorb the global ledger, while supply caches remain fully hidden discoveries.

Verified: project compile, deterministic mineral-vein distribution test, lazy-discovery test, realm-scale test, and infinite-region streaming test.

## 2026-08-09 (41)

- **Minecraft-style terrain rendering**: Static cave terrain now renders through retained 24x24 regional `CanvasItem` chunks instead of rebuilding every visible tile every frame. Mining invalidates only the changed region and adjacent edge regions, while dynamic actors, lighting, beam feedback, and HUD continue to redraw independently. Dirty terrain redraws are admitted at one chunk per frame to prevent excavation bursts from producing render spikes.

Verified: Godot project compile, short project boot, infinite-region streaming test, and focused terrain-chunk render test.

## 2026-08-09 (40)

- **Streaming first-touch latency**: Dynamic region generation is capped at one chunk per frame, mining prioritizes its beam corridor instead of stacking two preload budgets, stale directional requests are discarded when the player turns, and speculative movement look-ahead has been tightened while retaining the active region radius.

## 2026-08-09 (39)

- **Infinite streaming Phase 2A**: Sparse `WorldGrid` streaming now accepts signed regions beyond the original authored rectangle. Exterior chunks generate deterministic connected cave crosses, rooms, seams, biome identities, minerals, and exploration content from the realm seed and region address.
- **Unbounded traversal shell**: Region preloading, active windows, forward prefetch, camera limits, visible-cell rendering, and world background rendering no longer clamp players to the original realm dimensions. The authored central settlement remains intact and exterior chunk generation opens deterministic transition seams through its former rim as those regions prepare.
- **Persistence and hibernation**: Inactive exterior terrain chunks now evict their generated arrays and reconstruct deterministically when revisited, then reapply sparse signed cell deltas. Existing visited-region and delta dictionaries remain within the current save schema.
- **Focused verification only**: Added `infinite_region_stream_test.gd` for positive exterior, negative signed, connected-seam, and deterministic-biome checks. Extended traversal, long-session memory, save-growth, and visual QA are intentionally left for hands-on testing.

Verified: Godot project compile and `infinite_region_stream_test`.

## 2026-08-09 (38)

- **Base spawn exclusion**: Hostile spiders can no longer materialize inside an active or activating Core's power radius, with an additional two-cell dispersion buffer, or within eight cells of a living Personal Base. Spiders may still enter these areas normally to attack the settlement.
- **Unified spawn routing**: Hunting parties, biome scouts, broodlings, nest pressure, guardians, nest bosses, Frontier activation attackers, and unreachable-mob route re-seeding now use the same prepared-ground exclusion contract. Future brood nest sites also reject protected locations.
- **Regression coverage**: Added `base_spawn_exclusion_test.gd` to verify Core, field-hut, broodling, guardian, nest-boss, and standard hunting-party behavior.

Verified: `base_spawn_exclusion_test`, `prepared_spawn_control_test`, `biome_scout_alert_test`, `brood_ecology_test`, `random_start_breach_test`.

## 2026-08-09 (37)

- **Core-independent field huts**: Personal Base kits can now be deployed on any active prepared ground, including sectors outside every Core territory. Field huts remain intentionally basic: no regional shop or industry access.
- **Heal-and-save loop**: Resting at any field hut fully restores health and energy, commits that hut's signed world-cell identity as the active respawn checkpoint, and reloads the hut before resolving checkpoint spawn. Hut saves do not inherit the old archive cooldown.
- **Ruined fortress discoveries**: Deterministic exploration rolls can materialize broken former-settlement fortresses only in active prepared regions. Their damaged wall shells and salvage chests persist through the existing structure/save contracts.
- **Discovery reward**: Each fortress chest contains deterministic minor material loot and, on first open, grants one randomly selected weapon or construction item the player has not unlocked. Deeper exploration, expedition level, and Hive Awareness expand the eligible luck tier; fully completed arsenals receive a Field Hut kit fallback.
- **UI and regression coverage**: Build/shop copy now explains free placement and the heal/save/no-shop contract. Added `field_hut_checkpoint_test.gd` and `ruined_fortress_test.gd` to the regression batch.

Verified: `field_hut_checkpoint_test`, `ruined_fortress_test`, `personal_base_kit_test`, `personal_base_rest_siege_test`, `personal_base_sp_upgrade_test`, `checkpoint_respawn_test`, `progression_checkpoint_slots_test`.

## 2026-08-09 (36)

- **Open-world enemy authority foundation**: Added persistent Hive Awareness driven by exploration, discoveries, settlement growth, guardian losses, and boss progress. Inactive encounters no longer begin from visible countdowns, and late-game pressure no longer restarts itself on a timer.
- **Biome scout propagation**: Every biome now dispatches a distinct scout identity using its own ecology role. A surviving scout report mobilizes a hunting party; a killed or unloaded scout becomes a saved missing-patrol investigation that escalates after a hidden delay.
- **Prepared-region spawn contract**: Added explicit absent, queued, generated, prepared, and active region readiness. Hunting parties, brood pulses, guardians, Frontier activation contacts, and boss-pit defenders must spawn on walkable cells inside active prepared regions.
- **Progressive population control**: Hostile caps now grow from Hive Awareness, prepared territory, and active settlement bases while retaining a hard runtime ceiling. Streaming completion has priority over encounter release.
- **Infinite address groundwork**: Added exact signed 64-bit region/local-cell address math, including negative coordinates and extreme-distance round trips. The tactical map now shows signed cell/region coordinates plus Hive Awareness and local threat instead of a finite survey total.
- **Persistence and QA**: Hive Awareness, surveyed regions, pending scouts, missing-scout investigations, and boss world-gate progress survive realm saves. Added focused address, coordinate UIX, awareness, biome-scout, and prepared-spawn regression coverage.

Verified: `world_address_test`, `map_coordinate_uix_test`, `hive_awareness_test`, `biome_scout_alert_test`, `prepared_spawn_control_test`, `continuous_breather_test`, `region_preload_test`, `lazy_materialization_order_test`, `wave_save_fidelity_test`, `mob_locomotion_test`.

## 2026-08-09 (35)

- **Biome encounter composition**: Added distinct four-role weights for all seven biome ecologies while preserving wave-director specialist beats and difficulty unlocks. Ordinary bulwarks join mature waves from wave six onward.
- **Restrained ecology traits**: Tunnel and Iron resist knockback; Hive and Foundry gain bounded home-ground movement; Bunker pressures structures; Crystal and Sulfur artillery receive bounded projectile behavior changes without extra damage.
- **Origin identity contract**: Spawn biome now remains authoritative for sprite, name, and trait after border crossing or relocation. Saves retain the identity, while legacy enemy records recover it from their saved position.
- **Combat readability**: Role silhouettes, collision, windups, hit flashes, projectile sprite/radius, and base damage remain shared. Only Crystal/Sulfur projectile tint and bounded travel behavior vary.
- **Phase 5 QA**: Added role-profile, unlock-gate, deterministic-distribution, unique-trait, border-crossing, projectile-source, and save-fidelity assertions plus a seven-biome ecology audit.

Verified: `biome_ecology_profile_test`, `biome_bestiary_test`, `mob_locomotion_test`.

## 2026-08-09 (34)

- **Biome atmosphere profiles**: Replaced the universal cyan mote field with sparse deterministic palettes and densities for Tunnel, Hive, Bunker, Crystal, Foundry, Sulfur, and Iron. The active biome now also supplies a restrained ambient grade and practical-light color.
- **Authored room landmarks**: Added two multi-prop compositions per biome using existing runtime assets. Formation anchors host a deterministic budget of zero to two landmarks per region, with bounded sub-cell offsets and no navigation changes.
- **Rare local emission**: Biome lamps, crystal shards, sulfur vents, slag, acid, eggs, and conduits now cast restrained stepped light pools; landmark sources receive a small emphasis without exceeding combat FX.
- **Generic dressing removal**: Removed fixed-coordinate lamps, crates, support ribs, grates, hive eggs, veins, webs, and their duplicated light list. Saved discovery scars remain gameplay-authoritative.
- **Phase 4 QA**: Added atmosphere palette/density, landmark silhouette/budget, runtime determinism, placement metadata, and cache-pruning assertions plus color/grayscale visual audit previews.

Verified: `biome_atmosphere_profile_test`, `realm_visual_test`.

## 2026-08-09 (33)

- **Geographic biome borders**: Visual terrain now crosses logical region edges through a shared seeded displacement curve capped at three cells, plus sparse correlated contamination within a four-cell band. Gameplay biome ownership and saved topology are unchanged.
- **Biome-aware walls**: Exposed rock inherits the dominant adjacent visual biome, one of four reviewed ornate wall skins, a restrained material tint, and a distinct edge palette. Interior rock stays on the quiet cave bank.
- **Connected wall topology**: Straight faces, adjacent corners, opposite-side connectors, and isolated three/four-sided pillars now receive different edge treatments instead of one universal brown lip.
- **Mining readability**: Biome wall skins draw below fungus, concealed geology tells, and revealed mineral seams.
- **Phase 3 QA**: Added deterministic displacement, correlation, contamination-budget, wall-pool, edge-palette, generated-border, and runtime wall-inheritance assertions.

Verified: `biome_transition_profile_test`, `floor_macro_tile_test`, `realm_visual_test`.

## 2026-08-09 (32)

- **Meso-scale biome formations**: Added deterministic 36-cell/12-cell visual fields, eight irregular macro-stamp silhouettes, and quiet/standard/dense region budgets. Formations now read as veins, branches, fans, and broken patches instead of decorated random cells.
- **Ornate atlas deployment**: Generated seven separate unframed `*_material_formation_phase2.png` banks. Each biome uses eight reviewed formation macros at subordinate opacity while Phase 1 base materials remain untouched.
- **Formation prop ecology**: Existing shards, vents, slag, eggs, webs, acid, grates, conduits, rubble, crates, and lamps now anchor formations with deterministic sub-cell offsets. Independent prop noise is suppressed inside formation footprints.
- **Streaming-safe cache**: Formation records cache per region, rebuild when mining opens terrain, and prune with unloaded visual regions.
- **Phase 2 QA**: Added formation-pool, stamp-shape, noise-correlation, runtime determinism, opacity, atlas-range, and cache-pruning assertions plus color/grayscale formation previews.

Verified: `biome_formation_profile_test`, `floor_macro_tile_test`, `realm_visual_test`.

## 2026-08-09 (31)

- **Biome quiet-base profiles**: Measured and reviewed all seven 10x10 terrain atlases, then restricted each biome to six low-contrast base macros with deliberate `4/3/2/1/1/1` weighting.
- **Tile-soup removal**: Runtime floor selection can no longer choose bright formation, transition, or signature cells as ordinary base terrain. Selection remains deterministic by realm seed and macro coordinate.
- **Grid-frame removal**: Tunnel and Hive reuse their preserved continuous runtime textures; the other five biomes load reproducible unframed Phase 1 base atlases. Ornate phase3 banks remain intact for later formation/detail layers.
- **Phase 1 audit**: Added the reviewed candidate contact sheet and documented every selected atlas index in `docs/BIOME_VISUAL_RECOVERY_PLAN.md`.

Verified: `floor_macro_tile_test`, `realm_visual_test`.

## 2026-08-09 (30)

- **Terrain atlas recovery**: Restored the authored 32px macro contract. Four 16px source quadrants now map coherently onto each 2x2 block of 16px world cells instead of sampling unrelated fragments.
- **Blank wall fix**: Complete rock macros retain their correct 32x32 world footprint, and cave selection is restricted to the populated 4x4 bank rather than choosing from 84 blank atlas slots.
- **Deterministic deployment**: Macro variants now use the realm seed and macro coordinate rather than periodic coordinate stripes.
- **Professional recovery spec**: Added `docs/BIOME_VISUAL_RECOVERY_PLAN.md` with atlas contracts, biome grammar, visual budgets, phased implementation, and native-scale QA gates.

Verified: `floor_macro_tile_test`, `realm_visual_test`.

## 2026-08-09 (29)

- **Mob/player sprite recovery**: Recut all 28 biome mobs, broodling, brood carrier, guardian, and 32 directional player poses from their archived source sheets. Removed opaque magenta cards, label fragments, wrong slot cuts, and top-cropped bottom-row creatures.
- **Importer hardening**: `sheet_cut.py` now samples the real generated-sheet perimeter, flood-clears only edge-connected background, removes compressed chroma fringe, extracts the main connected subject, preserves detached effects only for artillery, and fits every runtime sprite with transparent padding.
- **Fail-closed asset QA**: Importers reject wrong dimensions, empty/rectangular output, and remaining source-background pixels. Godot tests now enforce exact mob/player canvases, alpha coverage, and transparent borders.

Verified: `biome_bestiary_test`, `runtime_asset_integrity_test`, `display_uix_test`, `realm_visual_test`, `combat_sprite_usage_test`, plus a 67-file post-import sprite audit.

## 2026-08-09 (28)

- **Rock texture fix**: Cave atlas re-imported at **32px** macro patches; complete 2×2 rock blocks draw one unstretched quad again while floor keeps 16px sub-patches.
- **Biome bestiary**: `biome_bestiary.gd` maps 7 biomes × 4 archetypes (28 runtime sprites); spawn/draw resolve biome-aware mob textures with legacy fallback.
- **Gun-free player art**: `import_player_sprites.py` imports 4×5 passive/active sheets; passive strips baked weapons; active aim pose keeps empty gun-hold hands; combat draw swaps to `{style}_{direction}_active.png` when crosshair is live.
- **Mob import pipeline**: `import_mob_sprites.py` migrates hive spider art; Iron Strata and Sulfur Bog packs imported from ChatGPT 2×2 sheets (mouth FX preserved on Magnet Pulser and Gas Blister).

Verified: `floor_macro_tile_test`, `biome_bestiary_test`, `runtime_asset_integrity_test`, `realm_visual_test`.

## 2026-08-09 (27)

- **UI typography**: Shared font tokens in `display_settings.gd`; COMPACT overlay scale **0.88**; Command Core panel reflow (360px tall, taller tabs/services/detail).
- **HUD readability**: Density-aware scrap/pack/SUIT/NRG/objective fonts; wider pack line and taller objective strip.
- **Reticle alignment**: Per-reticle optical hotspots in `combat_vfx.gd`; crosshair draw and aim pointer share `_combat_pointer_world()` with deadzone removed.
- **Floor sub-patches**: Importer emits 2×2 **16px** sub-patches per source cell; runtime draws per-cell macro quadrants instead of flat 32px plates.

Verified: `display_uix_test`, `floor_macro_tile_test`, `realm_visual_test`.

## 2026-08-09 (26)

- **Foundry coal buffer**: Purchased coal now fills powered Foundry fuel buffers instead of the sellable field pack; `_foundry_fuel_purchase_room()` counts powered (not operational-only) facilities.
- **Unified coal consumption**: `consume_coal()` draws recipe and batch fuel from the facility buffer first, then the pack; manual/auto load moves pack coal into storage on Foundry open.
- **Sell loop fix**: Buffer coal is isolated from `sell_raw_quick()` and contract deposit; Foundry panel slot 5 toggles LOAD vs BUY coal.

Verified: `foundry_operations_test`, `shop_economy_test`.

## 2026-08-09 (25)

- **Grid seam fix**: Backing rects now sample each macro patch edge via `_backing_color_for_source()` instead of a single atlas corner, removing dark hairlines between 32px plates.
- **Wall edge rework**: `_draw_wall_edges()` moved lip highlights onto rock cells facing walkable floor instead of dark shadow strips on every floor cell (the main corridor grid artifact).
- **Terrain color pass**: Warmer default/bunker floor tints, `_cave_cell_tint()` variation on rock macro blocks, and mineral specks on cave overlays.
- **Importer**: 3px edge bleed and averaged patch-edge atlas background; re-ran `import_chatgpt_textures.py`.

Verified: `floor_macro_tile_test`, `realm_visual_test`.

## 2026-08-09 (24)

- **Floor macro-block draw**: Complete 2×2 floor blocks now draw one unstretched 32×32 atlas plate via `_draw_floor_macro_block`; partial blocks fall back to per-cell 16px sampling. Rock uses the same macro path for 2×2 cave blocks.
- **Backing color sync**: `_cache_terrain_backing_colors()` samples atlas corner pixels so seam hairlines match patch edges instead of blue-gray void tones.
- **Importer bleed**: `apply_edge_bleed()` now softens the outer 2px of each 32px macro patch; re-ran `import_chatgpt_textures.py`.

Verified: `floor_macro_tile_test`, `realm_visual_test`, `run_regression_batch`.

## 2026-08-08 (23)

- **Held weapon aim sync**: Importer now single-pass orients art, aligns the measured grip on-canvas, and records real barrel vectors. Draw uses `aim.angle() - barrel.angle()` so the muzzle tracks the reticle instead of the sprite long axis.
- **Held weapon layering**: Weapon always draws in front of the body; hand mount uses direction offsets instead of aim-normal drift.

Verified: `mining_crosshair_test`, `held_weapon_alignment_test`, `runtime_asset_integrity_test`, `combat_sprite_usage_test`.

## 2026-08-08 (22)

- **Left-aim weapon layer**: Removed the `aim_direction.x < -0.1` behind-body pass so left aim keeps the held weapon in front of the sprite.
- **Held weapon rotation**: Draw now uses `direction.angle()` directly instead of the left-mirror transform that inverted vertical aim.

Verified: `mining_crosshair_test`, `held_weapon_alignment_test`, `runtime_asset_integrity_test`, `combat_sprite_usage_test`.

## 2026-08-08 (21)

- **Body strip safety**: `_strip_baked_weapon_from_player_texture()` now clears only gun-colored pixels inside the edge mask via `_is_baked_gun_pixel()`, preserving torso pixels that the old rect wipe removed (visible in gameplay video as grid showing through the player).
- **Held weapon aim**: Importer rotates shop icons so grip→muzzle is horizontal; draw uses `atan2(y, abs(x))` plus horizontal mirror when aiming left so asymmetric guns stay upright at every angle.

Verified: `held_weapon_alignment_test`, `runtime_asset_integrity_test`, `mining_crosshair_test`, `combat_sprite_usage_test`.

## 2026-08-08 (20)

- **Invisible body fix**: Shrunk `PLAYER_WEAPON_MASK_BY_DIRECTION` to edge-only gun rects so `_strip_baked_weapon_from_player_texture()` no longer clears the torso/limbs.
- **Held weapon rotation**: `_held_weapon_draw_angle()` compensates for each sprite's intrinsic barrel vector; `_player_tool_pose()` rotates muzzle origin the same way. Re-imported `held_*.png` with horizontal normalization and measured grip/muzzle metadata in `CombatVfx`.

Verified: `held_weapon_alignment_test`, `runtime_asset_integrity_test`, `mining_crosshair_test`, `combat_sprite_usage_test`.

## 2026-08-08 (19)

- **Player sprite gun strip**: Directional player sprites had baked-in weapons conflicting with held-weapon overlays. `_strip_baked_weapon_from_player_texture()` clears direction-specific mask rects at load.
- **Floor grid seam fix**: Switched `_floor_texture_region` and rock sampling to per-cell 16px `_tile_texture_region` instead of 2×2 macro quadrants, removing the visible macro-block grid. Removed rock cell tint overlay and scratch lines that read as grid noise.

Verified: `floor_macro_tile_test`, `mining_crosshair_test`, `runtime_asset_integrity_test`.

## 2026-08-08 (18)

- **Terrain render fix**: Per-cell 16px floor/rock draw via `_macro_texture_region`; floor uses `_material_for_cell`, rock uses `cave_texture` with neighbor backing only. Removed macro-origin gates, 32px world quads, and floor-on-rock layering. Retuned `_draw_wall_edges` opacity.
- **Held weapon sprites**: `import_combat_textures.py` now generates normalized 24×16 `held_*.png` sprites from shop icons. `CombatVfx.held_weapon_spec()` supplies shared grip/muzzle geometry for draw, muzzle origin, and combat FX alignment.
- **Mining aim mask**: `_should_draw_held_weapon()` hides the held weapon whenever mine is pressed (not gated on `mining_beam_valid`). Up/left aim draws behind the body consistently.
- **Asset integrity**: `_validate_runtime_assets()` checks existing registries after load, prints `CRAWL_BRAWL_ASSETS_OK`, and shows a HUD fault banner on failure.

Verified: `floor_macro_tile_test`, `mining_crosshair_test`, `runtime_asset_integrity_test`, `held_weapon_alignment_test`, `combat_sprite_usage_test`, `realm_visual_test`, `display_uix_test`.

## 2026-08-08 (17)

- **Biome-linked rock**: Minable walls now sample the same floor biome atlas as adjacent terrain via `_material_for_macro_block`, `_rock_tint_for_material`, and `_rock_salt_for_material`; `cave_texture` remains fallback only. Macro-block material resolves from block center cell so 2×2 plates stay consistent across biome cuts.
- **Wall-edge soften**: Reduced `_draw_wall_edges` shadow opacity and removed horizontal band lines that read as floor grid stripes in corridors.
- **Mining aim cleanup**: `_should_draw_combat_crosshair()` suppresses the combat reticle while mining; procedural held-weapon barrel hides when `mining_beam_valid` so only beam + target arc show.
- **Importer**: Atlas background fill uses first-patch corner tone instead of pure black to reduce macro-boundary hairlines.

Verified: `floor_macro_tile_test`, `mining_crosshair_test`, `realm_visual_test`, `combat_sprite_usage_test`, `display_uix_test`.

## 2026-08-08 (16)

- **Floor macro tiling**: `import_chatgpt_textures.py` now trims ChatGPT sheet gutters, builds 32px macro atlas plates, and applies edge bleed; re-ran importer for all floor/cave atlases. `_floor_texture_region` routes through `_macro_texture_region` so each 2x2 floor block shares one coherent plate; removed procedural bunker/foundry/iron grid overlays. Core/spawn material bubbles tightened to 4 cells; cave wall backing now matches adjacent floor tone via `_cave_backing_color_for_cell`.
- **Held weapon overlay**: `_player_tool_pose` / `_draw_player_weapon` now use combat `recoil_*` sprites instead of shop inventory icons, with smaller mount calibration and behind-body draw order when aiming up/left. Muzzle-flash recoil skips when the held sprite is already visible.
- **Follow-up polish**: Floor now draws one unstretched 32×32 macro quad per 2×2 block (eliminates inner 16px seam grid). Removed full-width bunker conduit lines that read as horizontal floor grid in the core. Held weapons switched to compact procedural barrels (recoil sprites read as yellow flash blobs, not guns). Importer gutter increased to 8%.

Verified: `floor_macro_tile_test`, `realm_visual_test`, `combat_sprite_usage_test`, `display_uix_test`, and `run_regression_batch`.

## 2026-08-08

- **HUD**: XP pip and breather bars still used the pre-cleanup flat dark-blue backing rect (`Color("142a31")`) because their `_draw_hud_meter_bar` calls never passed a `texture_id`. Wired them to `hud_bar_cyan` / `hud_bar_green`/`hud_bar_amber` (breather now matches its existing color logic) so all HUD bars share the same chrome treatment as SUIT/NRG.
- **HUD assets**: Removed 148 orphaned HUD texture files (`hud_action_icons`, `hud_button_strip`, `hud_direction_arrows`, `hud_health_bars`, `hud_meter_bars`, `hud_menu_icons`, `hud_reticles`, `hud_side_panels`, `hud_status_icons`, `hud_status_00`-`15`, `hud_window_wide`, `hud_arrow_*`, assorted unused `hud_icon_*`) plus their `_source` and `.import` companions. None were referenced by any script; left over from an earlier, abandoned slicing pass.
- **Mob AI**: `_update_enemies` fell back to a raw beeline (`destination = player_position`) whenever a mob's flow field had no path for its cell — no wall-awareness, so every stranded mob during a large siege pointed at the exact same spot and jammed into the same rock/doorway instead of spreading out. Added `_greedy_step_toward` (wall-aware single-step, picks the closest passable neighbor) as the fallback, and flag the mob's region in `flow_dirty_regions` so the next base-flow rebuild gives it real routing.

Verified: `mob_locomotion_test`, `flow_field_test`, `regional_flow_field_test`, `display_uix_test`, `hud_minimap_test`, `uix_polish_test`, and the full `run_regression_batch` all pass.

## 2026-08-08 (2)

- **Ground texture seams**: `_tile_draw_rect` grew every floor/rock tile's destination rect by 1px on each side (`rect.grow(1.0)`) to hide gaps, but kept the source atlas sample at the original 16x16 size — every tile got stretched ~12.5% and the overlapping, mismatched edges of neighboring (differently-seeded) tile variants painted over each other, showing as a visible grid pattern. Tiles now draw at their exact 1:1 source/dest size, and `project.godot` enables `2d/snap/snap_2d_transforms_to_pixel` + `2d/snap/snap_2d_vertices_to_pixel` so tile boundaries land on whole pixels and butt together with no gap or overlap needed, at any window/stretch scale.

Verified: `run_regression_batch`, `realm_visual_test`, `region_foundation_test`, `realm_scale_test`, `random_start_breach_test`, `display_uix_test` all pass.

## 2026-08-08 (3)

- **Projectile/combat FX enabled**: `USE_IMPORTED_COMBAT_FX` was quarantined off because every projectile/muzzle/trail/impact sprite was a near-blank fragment. Root cause: `tools/import_combat_textures.py`'s `COMBAT_SHEETS` grid dimensions were transposed against the actual master sheets (e.g. coded 2 cols × 3 rows for a sheet that's really 3 cols × 2 rows), so `crop_grid_cell` sliced diagonal fragments of neighboring sprites instead of whole ones. Verified the true layout of all 9 combat sheets by eye and corrected the grid dims (sheets 1, 2, 3, 5, 6, 7, 9), and applied the existing `key_magenta_with_spill` soft-edge keying (already used for HUD icons) to `import_combat_sheets` so glow/spark edges don't keep a pink fringe. Re-ran the importer and flipped `USE_IMPORTED_COMBAT_FX` to `true` — pistol/shotgun/SMG/railgun/sentry rounds, muzzle flashes, laser beam/impact, flamethrower stream/patch/ember, rocket body/trail/explosion, acid glob/trail/splat, and all 9 impact sparks now render as their real sprites instead of a raw line/circle fallback.
- Also fixed the same transposed-grid bug in the unused `recoil_*` sheet (sheet 9) while in the file, for asset-pipeline correctness; recoil sprites aren't wired into gameplay yet (no consumer in `phase0_run.gd`), so that remains a future feature.

Verified: `display_uix_test` (now also asserts every combat FX sprite decodes), `flamethrower_phase4_test`, `torch_phase1_test`, `uix_polish_test`, and the full `run_regression_batch` all pass.

## 2026-08-08 (4)

- **Ground texture seams, take 2**: user screenshots showed the grid still present after the (2) fix above — pixel snapping alone didn't close a gl_compatibility-renderer sub-pixel seam between two adjacent, independently-rasterized texture quads, which showed the dark void/base color through as a hairline grid at every tile edge. `_tile_draw_rect` now grows only the flat-color *backing* rect drawn under each tile (`Color("121820")` for rock, each material's `base_color` for floor) by 1px; the texture itself still draws at its exact, unstretched 16x16 rect on top. A solid color has no source to mismatch when grown, so any residual seam now reveals matching base tone instead of a visible dark line.
- **Muzzle flash invisible**: `flash_alpha` was computed as `muzzle_flash / 0.14` for every weapon, but `0.14` is the *railgun's* flash duration — pistol (0.06s) peaked at 43% opacity and SMG (0.035s) at 25%, both easy to miss entirely mid-combat, which read as "no gun fire animation." Added `muzzle_flash_max`, set alongside `muzzle_flash` in every `_fire_*` function, so alpha now normalizes against each weapon's own duration and every shot flashes at full brightness at its peak.

Verified: `display_uix_test`, `realm_visual_test`, and the full `run_regression_batch` all pass.

## 2026-08-08 (5)

- **Spider reset / mass relocate**: `_spider_has_wave_route` only checked base flow, so player-hunting mobs with valid `player_flow` or greedy routing still counted as unreachable — `_reposition_unreachable_wave_spiders` teleported up to entire wave counts (`ROUTE RE-SEED // 25 HOSTILES RELOCATED` in gameplay footage). Same bad check in `_wave_spawn_pressure_count` falsely hit spawn-cap stall every 12s, triggering more relocates. Added `_spider_has_viable_route` (base + player + explorer flow, greedy step, low stall grace), capped hard relocates to 3/tick, blocked within 200px of player, require 1s locomotion stall, soft `_recover_stuck_spider` before teleport, and spawn-cap stall now rebuilds flows first instead of recall+relocate. `_recall_wave_stragglers` skips mobs near the player. Reroute interval 10s → 22s.
- **Explore / mine micro-hitch**: deferred region-shift and sector minimap patches (batched dirty rebuild instead of synchronous `_patch_minimap_region` / `_patch_minimap_sector`), extended terrain flow debounce to 0.65s with `maxf` stacking during mining bursts, throttled mining spark bursts (0.14s, fewer particles).

Verified: `mob_locomotion_test`, `flow_field_test`, `regional_flow_field_test`, `run_regression_batch`.

## 2026-08-08 (6)

- **Mob flow behavior audit**: greedy fallback in `_update_enemies` still stepped every stranded mob toward the *player* even when the mob's mission was core/expedition/torch/turret — mismatch with `_spider_has_viable_route` and a source of wall-jam + apparent resets. Fallback now uses `_spider_combat_target_position` (expedition waypoint included). `player_flow` only rebuilt on region change, so mining in the same region left hunter routing stale until `_refresh_player_flow`/`player_flow_stale` were added (invalidated when mining within 28 cells of player, refreshed after base-flow rebuild while hostiles active). Added `mob_flow_behavior_test.gd` + `route_tactics_test.gd` to regression batch.

## 2026-08-08 (7)

- **Siege combat perf**: large mobs + SMG/mining stacked O(bullets×enemies) collision, unbounded sparks, and full 4-base flow BFS on every mined cell during waves. Added `systems/combat_spatial.gd` (48px enemy buckets) for bullet hits, land mines, and amortized turret targeting; capped `_burst` at `MAX_SPARKS` (384) with siege throttling and mining-spark skip under load; partial `_rebuild_base_flows(false,false)` now refreshes COMMAND flow only during heavy combat with `BASE_FLOW_COMBAT_THROTTLE` (1.75s) and `_mark_flow_region_dirty` rate limits; torch/turret scans skipped for distant non-saboteur mobs. Added `combat_pressure_test.gd` to regression batch.

## 2026-08-08 (8)

- **Explore/mine lag**: peaceful mining no longer marks `player_flow_stale` or rebuilds hunter flow every cell; player flow refresh debounced to 0.25s. Region/sector discovery patches minimap incrementally instead of scheduling full rebuilds; minimap GPU upload throttled to every 2 frames.
- **Wall regeneration**: `_sync_generated_cells_in_region` no longer wipes mined `cell_deltas` when chunk still reads ROCK; `_set_cell_as_generated` refuses to re-seal cells with an open FLOOR delta.
- **Nest kill spike**: `_establish_brood_nest` defers flow rebuild via terrain debounce; relocate uses `_choose_brood_nest_site`/random sampling instead of full-grid scan; autosave, apex spawns, and bonus relocate deferred off kill frame.
- **Wall ridges**: shared `_move_entity` slide collision for player (5px radius); enemy probe margin reduced 0.45→0.25 tile; greedy fallback validates body radius before stepping.

## 2026-08-08 (9)

- **Preemptive region preload**: mega-realm streaming now uses `schedule_region_window` + budgeted `process_region_preload_budget` (2/frame explore, 4/frame mining) instead of synchronous burst materialization on boundary cross. Mining beam calls `prefetch_mining_beam_regions` before hit resolve; `get_cell` no longer lazy-pops on access. Stream centers include movement + aim look-ahead (1–1.75 regions). Added `region_preload_test.gd`.

Verified: `region_preload_test`, `terrain_preservation_test`, `lazy_region_topology_test`, `lazy_materialization_order_test`.

## 2026-08-08 (10)

- **Upgrade currency pivot**: Expedition XP no longer pays tier upgrades. Sentry MK, Frontier Core MK, and Personal Base MK now spend **Skill Points** plus refined parts via `systems/upgrade_economy.gd`. Shop rows show `[SP %d]`; expedition XP only levels the run and banks more SP.
- **Economy rebalance plugin**: Centralized turret material ladder (Bronze → Silver+Bronze → Gold+Diamond), softer rocket/laser research/craft costs, mining/construction requirements, and zero scrap co-pays on mining upgrades. `phase0_run.gd` routes `_turret_material_requirements`, construction, and mining lookups through the plugin.
- **Tests**: Replaced XP purchase tests with `sentry_sp_upgrade_test.gd`, `progression_command_sp_test.gd`, and new `economy_pacing_test.gd`; updated `progression_functional_test.gd` and `smoke_test.gd`.

## 2026-08-08 (11)

- **SP upgrade finalization**: Fixed stale Defenses copy that still referenced Expedition XP; BASE and Personal Base detail panels now show SP + refined-part costs. Moved `frontier_core_material_requirements` and `personal_base_upgrade_requirements` into `upgrade_economy.gd`; removed dead `_spend_expedition_xp` and legacy `ShelterUnit.upgrade_cost`. Tier SP spends now pulse `hud_sp_pulse` and push a comms alert. Renamed `EXPEDITION_XP_UPGRADE_BONUS` to `EXPEDITION_XP_THRESHOLD_TOPUP`.
- **Regression coverage**: Added `personal_base_sp_upgrade_test.gd` and wired `sentry_sp_upgrade_test`, `progression_command_sp_test`, `progression_functional_test`, and `personal_base_sp_upgrade_test` into `run_regression_batch.gd`.

## 2026-08-08 (12)

- **Operator armor stats**: Equipped survivor suits now grant tiered strength (weapon damage) and defense (incoming damage reduction) via `systems/player_armor.gd`. Survey stays baseline; Foundry/Containment/Veteran map to Bronze/Silver/Diamond tiers. Style tab, pause summary, and progress multipliers show active armor values; `_hurt_player()` and `_weapon_damage_scale()` consume the equipped multipliers.

## 2026-08-08 (13)

- **Progress menu unlock audit**: Skill node purchases now rebuild progression multipliers from `skill_unlocks` instead of applying a single incremental effect. Progress INFO rows stay non-interactive; `[LVL n]` labels strip cleanly in the terminal. Added `progression_menu_unlock_test.gd` to verify all five level-gated nodes unlock through `_execute_core_action` with correct READY/OWNED UI states.

## 2026-08-08 (14)

- **Leveling system audit**: Wave autosave now runs after expedition XP award so progression is not lost on crash. Load path repairs invalid `skill_unlocks` prerequisite order via `ProgressionTree.repair_unlock_order()`. UI sync announces overflow level-ups; branch unlocks pulse SP feedback like tier spends. Automation/Defenses/Progress copy clarifies sentry vs rocket/laser gates and milestone bonus SP. Added `progression_wave_save_order_test.gd`; expanded regression batch with gate and save tests.

## 2026-08-10 (76)

- **Perf Sprint 2**: Region prop/formation generation is budgeted off the preload tick (`_enqueue_visual_region_build` / `_service_visual_region_builds`, 1–2/frame). Chunk raster memoizes 2x2 floor/rock macro classification once per draw. Stream sync keeps chunk layers aligned with the window and invalidates bleed borders on expand; burst flush honors the requested budget. Fixed formation cache corruption from `_chunk_formations_cache.clear()` mutating the shared cached dictionary.

## 2026-08-10 (75)

- **Spawn ecology polish (Sprint 1.5)**: Discovery adds awareness only (pressure 0); ambush pack sizes scale from `_combat_pressure_level()`. Nest pressure spiders, nest bosses, guardians, explorer splits, and nest pulse cooldowns unified on combat pressure instead of expedition wave. `_update_encounter_delivery()` replaces `_update_waves()` as the live delivery tick; `build_plan()` marked deprecated for tests only.

## 2026-08-10 (74)

- **Perf Phase 0+1**: Gated debug file I/O behind `AGENT_PERF_DEBUG`. Deferred encounter flow rebuild with `ENCOUNTER_FLOW_GRACE`; boot preload capped at `BOOT_REGION_PRELOAD_CAP`; removed duplicate sync `flow.rebuild`. Enemy torch/turret scans use structure spatial buckets; wave pressure uses lightweight route cache; player flow refresh moved out of enemy loop; flow dirty marks no longer expand per cell.

## 2026-08-10 (73)

- **Encounter spawn refactor**: Removed dead `wave_countdown` and `continuous_surge_remaining` state. Hunting parties now release exclusively through `_try_release_encounter()` (Hive Awareness scout/reaction gate). `_start_encounter()` replaces inline wave start; nest milestones track `encounters_completed`. Scout stats scale from `_combat_pressure_level()`. Tests migrated from `build_plan` to `build_encounter_plan`.

## 2026-08-08 (15)

- **Complete combat asset wiring**: Added `systems/combat_vfx.gd` manifest and impact/recoil/reticle mappings. Timed `combat_impacts` overlays now render rocket explosions, acid splats, mining breaks, structure hits, and color-mapped bullet impacts; laser beams tile `laser_segment`; turrets show `muzzle_sentry` / `laser_muzzle`; player weapons show recoil sprites. Enabled imported reticles with procedural fallback. Added `combat_sprite_usage_test.gd` and `combat_impact_test.gd`; wired `display_uix_test` into regression batch.


## 2026-08-22 - BV5.1 Mob Stability + Siege Frame-Pacing
- Preserved local fallback commitment when a regional flow exists but has no occupiable next edge.
- Reused frame-resolved combat targets during fallback routing instead of duplicate torch/turret acquisition.
- Aligned mob facing to actual post-collision displacement; brood carriers follow the same rule.
- Open Heavy Doorways are passable/non-attackable and now refresh blocker/flow state immediately on toggle.
- Doorway footprint upgrades invalidate structure spatial/routing state.
- Structure spatial buckets persist until explicit mutation instead of rebuilding every combat frame.
- `_nearby_structure()` now uses spatial buckets; torch acquisition is staggered and avoids global structure scans.
- Added local fallback build/reuse telemetry and `mob_routing_stability_bv5_test.gd`.

## BV5.4 - Streaming Ownership + Siege Routing
- Fixed corridor preload bursts taking ownership of render/simulation windows after resume.
- Reduced sparse-world render center headroom to one region; camera bounds and simulation halo remain authoritative.
- Converted enemy regional flows to terrain-only topology and added explicit structure-breach commitment.
- Dynamic defense edits no longer rebuild regional BFS fields.
- Deferred terrain-flow rebuilds until mining release.
- Optimized the hot enemy occupancy probe with squared-distance checks.
- Added `flow_breach` telemetry and `streaming_siege_bv54_test.gd`.
