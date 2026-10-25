# Crawl Brawl BV5.6 — Open-World Runtime Authority

BV5.6 removes the remaining tower-defense **wave count** authority from the live game loop. The game is now explicitly modeled as an exploration / defense / building / crafting strategy sandbox where Hive Awareness and world ecology create threat.

## DEV008 evidence

The DEV008 `diagnostics/LAST_SESSION.json` showed that early hitching was not combat-bound:

- frame peak: ~149.35 ms
- frames sampled: 1,870
- frames >33 ms: 119
- enemy peak: 1
- enemy update peak: ~1.676 ms
- streaming update peak: ~8.484 ms
- mining commit peak: ~0.343 ms
- render window peak: 24 regions
- simulation window peak: 36 regions

The largest stalls therefore happened outside enemy simulation, streaming, and terrain mutation. Historical terrain notes already identified a full decorated region raster as a ~25 ms-class GDScript operation, and active play could still request that path for a lone newly visible chunk.

## Open-world authority

### Threat that remains

- Hive Awareness
- exploration pressure
- scout reports
- overdue / missing scouts
- settlement activity
- brood nests and local brood pulses
- guardians and regional world sites
- biome ecology
- apex / lair accomplishment gates

### Wave authority retired

Wave / round number no longer controls:

- hunting-party size
- hunting-party entry cadence
- specialist role selection in the live runtime
- enemy health / damage / travel scaling in the live runtime
- periodic bosses
- brood-carrier eligibility
- kill-all cleanup
- straggler recall
- wave-clear credit / ammo / heal rewards
- Frontier Core construction
- Frontier Core tier upgrades
- nest expansion milestones
- Spider Lair / apex progression
- skill-point milestones

`wave`, `wave_active`, `spawns_remaining`, `current_wave_plan`, and related names remain where needed for **SAVE_VERSION 14** compatibility. Their live meaning is either historical metadata or a short hunting-party delivery state; they are not progression authority.

## 20 Hz world ecology tick

Low-frequency world systems now advance on a bounded 20 Hz tick:

- scouts
- missing-scout escalation
- hunting-party delivery
- Frontier Core activation pressure
- brood-nest ecology
- pending distant-nest retries

At most two ecology ticks may run during one display frame. A long frame therefore slows world time briefly instead of triggering an unbounded catch-up loop. Player control, movement, weapons, enemy movement, projectiles, and rendering stay on the normal display frame path.

## Terrain frame policy

Active-play terrain chunks are now always committed using the lean raster. The expensive decorated/full-quality raster is only requested by the low-priority refinement service while gameplay is already frozen behind a pause, backpack, terminal, chest, or other UI state.

This removes the previous case where a single newly visible region could decide to perform a full-quality decorated draw merely because the player happened to be stationary.

## Smaller live-world envelope

- render cap: **12 regions**
- simulation cap: **25 regions**
- deterministic prepared world remains separate and larger

Preparation is world memory. Simulation is gameplay. Rendering is presentation. They are no longer synonyms.

## Diagnostics added

The next `diagnostics/LAST_SESSION.json` includes:

- terrain draw peak / samples / >=8 ms count
- actor draw peak
- lighting draw peak
- 20 Hz ecology update peak / >=2 ms count

This should identify the next remaining source of frame spikes without guessing.

## Compatibility

- SAVE_VERSION remains 14.
- Existing serialized wave/history fields remain readable.
- Existing public compatibility functions retain their signatures.
- Legacy wave curve helpers remain available to old tests/tools, but the live runtime calls pressure-native APIs.
