# Crawl Brawl BV5.7 — Opening Pacing + Frame Phase Isolation

Baseline: **BV5-DEV009**  
Baseline SHA-256: `208114afd74c2256e8568498acc8d142570958239ffe8390f1fb2a7f30a29444`

## Why this pass exists

BV5.6 correctly retired tower-defense wave count as live progression authority, but two new-game tests still became hostile too quickly and DEV009 still contained early frame spikes. DEV009 finally gives enough phase-level evidence to treat those as separate problems rather than tuning mob routing again.

### DEV009 measured baseline

- 9,200 sampled frames
- 542 frames >=25 ms (5.89%)
- 312 frames >=33 ms (3.39%)
- peak display frame: 150.0 ms
- 1,516 mining frames; 15 >=25 ms (0.99%)
- mining transaction peak: 678 us
- terrain-open peak: 86 us
- mutation-queue peak: 94 us
- terrain draw: 353 samples, all 353 >=8 ms, peak 42,081 us
- lighting draw peak: 45,758 us
- ecology update peak: 53,919 us
- enemy update peak: 62,004 us; enemy population peak 36
- streaming peak: 5,675 us
- render/simulation envelopes held at 12 / 25 regions

The mining mutation itself is already sub-millisecond. The important pre-combat spike pattern is instead that terrain, lighting and ecology each have independent 40-50 ms-class work. If two or three land on one display frame, a 100-150 ms hitch is plausible even before battle becomes dense.

## Opening pacing

BV5.7 makes Hive Awareness a long-horizon reaction system rather than an exploration stopwatch.

- Passive region traversal: 0 awareness / 0 pressure.
- Passive survey: 0 awareness / 0 pressure.
- First scout investigation: not before three surveyed regions.
- Early scout cadence: one new investigation per two additional surveyed regions.
- Only one scout investigation may be outstanding at a time.
- Scout report: +2 awareness / +3 contact pressure.
- Early encounter threshold: 6 pressure, so one report is not enough.
- First hunting party: 4 hostiles.
- Early hunting-party recovery: 70 seconds after authorization is consumed.
- Party cap: 18 at the highest awareness tier.
- Passive time still never creates threat.

With the normal exploration path, the origin is the first surveyed region, a first scout can appear around the third region, and a second early scout is not eligible until roughly the fifth surveyed region. Two confirmed reports are then enough to authorize the first small party. Killing/loss of a scout, settlement activity, guardians and other meaningful events can change this path; it is intentionally not a fixed timer.

## Brood pacing

Remote brood expansion is delayed so the player can discover, build and prepare before nests become a persistent pressure source.

- Milestone tiers: II / IV / VI / VIII instead of I-VI.
- Incubation: 90 seconds instead of 42 seconds.
- Aggro radius: 150 px instead of 190 px.
- Pressure pulses: 18 s aggressive / 30 s passive, with a 10 s minimum.

## Frame-phase isolation

### 10 Hz world ecology

Background ecology now advances at 10 Hz with **one authority step maximum per display frame**. A long frame slows world time slightly instead of replaying multiple overdue ecology steps.

Every tick still handles lightweight scout/contact delivery, while heavier systems alternate:

- even ecology ticks: brood ecology (0.2 s represented delta)
- odd ecology ticks: Frontier activation (0.2 s represented delta)
- far-nest search: 2 Hz only while a milestone is actually pending

If a visible terrain raster is waiting, ecology yields that display frame.

### Lighting cannot stack with terrain or ecology

DEV009 measured terrain at ~42 ms, lighting at ~46 ms and ecology at ~54 ms peaks. BV5.7 carries explicit per-frame ownership flags. When a terrain raster or ecology authority step owns the frame, lighting keeps its dirty bit and waits for the next available frame rather than stacking another heavy callback.

### Startup decorative-cache hitch removed

Run bootstrap previously queued every active region for decorative generation and synchronously built one region immediately. Active gameplay now needs only lean terrain; full decorative formations/props are refinement. BV5.7 performs **zero synchronous decorative region builds at run start** and **zero eager decorative-cache builds during live streaming**. Full-quality cache generation remains available while the player is already UI-frozen.

## Lean terrain fast path

The active chunk renderer is now explicitly cheaper:

- quality is decided before any formation-cache lookup;
- lean chunks own exactly their 24x24 cells instead of using two-cell bleed;
- lean material selection uses deterministic region material directly;
- wall lips reuse four cardinal walkability tests instead of an eight-neighbor pre-scan plus another eight-neighbor material blend;
- expensive formations/props are drawn only by full-quality paused refinement;
- off-camera queued chunks remain queued until they enter the real camera envelope.

Lighting consumes existing prop caches only and uses 64 px deterministic mote spacing instead of 40 px. Lighting can no longer generate an expensive prop cache inside its draw callback.

## Diagnostics added for DEV010

`diagnostics/LAST_SESSION.json` now adds:

- peak cost and >=2 ms counts for ecology subphases (`scouts`, `missing_scouts`, `encounter`, `brood`, `frontier`, `far_nest`);
- current/peak Hive Awareness tier;
- current/peak contact pressure;
- hunting-party count;
- current/peak brood-nest count;
- remaining encounter recovery cooldown.

## DEV010 verification targets

The next session should preserve `render_regions_peak <= 12` and `simulation_regions_peak <= 25`.

More importantly, compare against DEV009:

- frames >=33 ms should fall materially below 312 / 9,200 (3.39%);
- terrain draw peak should fall materially below 42.1 ms and the >=8 ms ratio should no longer be 100%;
- lighting should no longer share a frame with terrain raster or ecology authority work;
- ecology peak should fall materially below 53.9 ms; if not, subphase telemetry should identify the offender;
- mining commit should remain below 1 ms;
- the first normal hunting party should require an actual early exploration/contact sequence rather than arriving almost immediately;
- remote brood nests should not be an opening-game pressure source.

Enemy-update spikes may still appear later with dense populations. If DEV010 shows that terrain/ecology/lighting are under control but enemy update remains the dominant late-game cost, the next optimization should be mob simulation LOD/update batching rather than more regional-routing redesign.

## Compatibility

- Main `SAVE_VERSION` remains **14**.
- Hive Awareness's nested save payload advances to schema 2 with defaults for old payloads.
- Existing production function signatures are preserved.
- No asset payloads are changed.
- Godot 4.7.1 runtime/regression execution remains a local validation gate.
