# Crawl Brawl — Game and Production Plan

Status: Beta 0.1 save-portability and Windows-distribution hardening implemented (August 5, 2026); runtime validation pending on the developer test machine  
Platform: Windows PC via Steam; Steam Deck-friendly from the first prototype  
Engine: Godot 4.7.1 stable, GDScript  
Launch scope: polished single-player game; co-op is a post-launch possibility, not a launch promise


## Beta 0.1 storage and distribution gate

- Persistent realm data now lives in `user://saves`, separate from the executable and writable in exported builds.
- The storage password is stable across install paths and machines, enabling legitimate backup, reinstall, Steam Cloud, and computer-transfer workflows.
- Valid pre-beta installation-local saves are discovered and re-encrypted into the portable user-data store without deleting the source files.
- Atomic primary/backup writes, recovery journals, schema checks, realm identity validation, and active-pointer verification remain in place.
- The Windows release preset produces a standalone embedded-PCK executable with Beta metadata and excludes development-only content.
- A scripted packaging step creates a tester ZIP with licenses, player instructions, and a SHA-256 checksum.
- Required developer validation: load and resave a legacy realm, move the game folder, copy the user-data saves to a second machine, and run the packaged ZIP without Godot installed.

## Patch 4.21 release state — Brood Ecology & Encounter Pacing

- Scheduled Brood Carriers turn independent expedition movement into an interceptable strategic threat.
- Carriers select connected procedural sockets, travel using shared cached flow fields, and visibly channel before establishing a nest.
- Nests incubate, mature, emit bounded local broods, and become weighted main-wave entrances.
- Players can purge nests for credits and score, permanently closing that spawn front for the realm.
- The original hive retains half of weighted wave traffic, preventing remote nests from replacing the authored siege origin.
- Local nest broods do not block wave completion, while formal-wave stragglers are recalled after a bounded cleanup window.
- Ecology state extends the existing version 4 payload through optional fields without invalidating older realms.

## Included Patch 4.20 release state — HUD & Tactical Map Cohesion

- A shared safe-area contract fixes the combat HUD at the native 640x360 canvas while existing display scaling handles output resolution.
- Top telemetry separates expedition, fixed-order base network, Suit, Energy, and ammunition information.
- Bottom telemetry separates tactical mapping, weapon selection, objective severity, and immediate interaction context.
- Surveyed terrain is cached; active-region, player, base, turret-selection, and sensor-authorized enemy markers remain live.
- Previously explored terrain no longer grants permanent global tracking of ordinary mobs.
- No balance, procedural generation, control, or save-format changes are included.

## Included Patch 4.19 release state — Display Scaling & Terminal UIX

- Persistent resolution, Windowed, Borderless, Fullscreen, Compact, and Standard choices are available from the main menu.
- Runtime overlays scale from the center instead of expanding against the bottom and right screen edges.
- Compact terminal typography and corrected button minimums keep every action and hint visible at common display sizes.
- Display preferences remain separate from protected realm saves and do not affect gameplay.

## Included Patch 4.18 release state — Realm Visual Cohesion

- Existing high-detail atlases now retain more texture information under a darker, menu-aligned atmosphere.
- Deterministic visual dressing gives tunnel, hive, and bunker regions distinct clutter without adding saved state or scene nodes.
- Wall depth, structure grounding, Core presentation, local lighting, and camera framing improve world readability.
- HUD cards and accents now use the same visual language as the main menu.
- Gameplay balance, procedural topology, economy, AI, controls, and save schema are unchanged.

## Included Patch 4.17 release state — Procedural Region Foundation

- A bounded 3×3 active-region window follows the player instead of allowing the loaded-region set to grow indefinitely.
- Visited regions persist separately, preserving exploration and minimap history after an area leaves the active window.
- Terrain persistence stores only cells changed from deterministic seed generation.
- Version 3 full-terrain realm saves remain readable and migrate to version 4 deltas on their next save.
- The current fixed realm remains the compatible origin world; on-demand region generation is the next expansion step.

## Included Patch 4.16 release state — Menu, Shop & Chest UIX

- Main-menu hierarchy now presents the selected expedition profile and current patch state at a glance.
- The Frontier Core keeps nine departments accessible in a bounded service list while leaving Close fixed in place.
- Shop selection, item status, missing requirements, and disabled actions use consistent state language and color.
- Storage chests expose pack and vault capacity, one-item and stack transfer controls, clickable bulk transfer, and explicit Close behavior.
- UI changes do not alter prices, crafting recipes, inventory capacity, progression, or save compatibility.

## Included Patch 4.15 release state — Industrial Defenses & Backpack Progression

- Seven additional seed-distributed geology types extend mining beyond the original precious-metal loop.
- The Foundry produces structural blocks, Steel, Titanium, Explosive Compound, and Optic Cores.
- Blueprint research gates Reinforced and Blast Barriers, Land Mines, Rocket Turrets, and Laser Turrets behind long-run credit and component requirements.
- Fabrication creates finite carried kits; field placement consumes exactly one kit.
- Backpack MK1–MK4 creates a 36–116 capacity progression across material, ammunition, and deployment inventory.
- Full-pack field rewards remain collectible in the realm and persist through saves.
- Twenty new transparent sprites and material textures support the expanded inventory and field defenses.

## Included Patch 4.14 release state — Muzzle Alignment & Mining Progression

- Combat Laser and mining ray originate from a shared animation-aware weapon muzzle.
- The mining ray stops at the near face of the first mineable rock and cannot visually exceed actionable reach.
- Walking uses stronger alternating weight transfer, step timing, footfall debris, and shadow compression without changing the collision body.
- Dedicated Cutter Speed and Mining Emitter MK1–MK4 tracks provide expensive, persistent long-term progression.
- The Core terminal includes a seventh Mining department with exact costs, component requirements, and current-versus-next performance.

## Included Patch 4.13 release state — Mining, Exploration & Motion

- Mining and Laser actions use layered beams, recoil, impact flares, shockwaves, and stronger debris feedback.
- Seeded realms conceal a deterministic share of deposits and all supply caches until excavation.
- Supply caches release physical collectible ammunition sprites instead of granting ammunition invisibly.
- Shop economy cards clearly separate spendable credits from raw cargo, refined upgrade stock, and sale value.
- Sustained sprint uses a rechargeable energy bar and complements the existing invulnerable dash.
- Survivor and enemy sprites use locomotion, attack, and directional hit-reaction animation without changing collision or balance.
- Patch 4.12.1 launch corrections and the complete Armory, Supplies, Defenses, Materials, Base, and Style catalog remain preserved.

## Patch 4.12 release state — Complete Armory & Shop Polish

- Six Core terminal departments separate equipment progression, consumable supplies, and cosmetic style.
- All five weapons use distinct MK1–MK4 stat progressions with exact before-and-after comparisons.
- Supplies sell itemized ammunition, Laser charging, a mixed field bundle, and medical treatment.
- Turret and Frontier Core upgrades expose exact combat and network values before confirmation.
- Purchase handlers validate research, maximum state, credits, and refined materials before changing state.
- Thirty shop icons and four persistent cosmetic survivor sprites replace generic text-only shopping and the procedural player body.
- Patch 4.11 mob art and Patch 4.9–4.10 realm, save, combat, economy, and interface systems remain in place.

## 1. The pitch

**Crawl Brawl** is a top-down pixel-action fortress game. The player digs tunnels through a quarantined underground complex, turns the excavated space into a kill maze, and personally fights swarms of mutant spiders and the infected humans they control. Every wave gives the player a little more territory, scrap, firepower, and trouble. The hive is always searching for a route to the player's Security Core.

The short player fantasy is:

> Dig your bunker. Shape the attack route. Build the guns. Survive the swarm.

The game combines three readable activities:

1. **Excavate:** choose where the fortress expands and where enemies can travel.
2. **Engineer:** place walls, doors, traps, power, and automated weapons.
3. **Brawl:** fight in the tunnels with guns, lasers, explosives, and movement abilities.

The important twist is that digging is not just exploration. Every tunnel the player opens can become a useful firing lane or a new route into the base.

## 2. Product pillars

### Shape the battlefield

The fortress is not a preset tower-defense board. The player digs it out one tile at a time, creating choke points, loops, fallback rooms, and risky shortcuts.

### Fight beside the fortress

Turrets help but do not play the game for the player. The strongest results come from moving, aiming, kiting, repairing, and combining personal weapons with defenses.

### Huge, readable swarms

The screen can become crowded, but hazards, elites, projectiles, and safe routes must remain legible. Small enemies may die in showers of pixels; dangerous attacks get distinctive colors, silhouettes, sounds, and windups.

### Every wave changes the problem

New enemy traits, tunnel breaches, upgrade choices, and boss behaviors prevent one maze or weapon from solving every run.

## 3. Scope guardrails

The first commercial version should include:

- One biome: the buried quarantine facility and surrounding hive tunnels.
- One playable engineer.
- One 30–45 minute **Bastion Run** ending in a boss and extraction decision.
- One unlockable **Endless Siege** mode with score and leaderboards later if time allows.
- Eight personal weapons, six defense structures, six common enemy types, three elites, and three bosses.
- Permanent unlocks that broaden future choices without making the opening waves trivial.
- Mouse/keyboard and full controller support.
- Local saves, Steam Auto-Cloud, achievements, and optional Steam leaderboards.

Explicitly defer these until the single-player game is fun and stable:

- Online or local co-op.
- Multiple characters or character classes.
- A story campaign with authored levels.
- Workshop/mod support.
- Multiple biomes.
- Dedicated servers, accounts, battle passes, or microtransactions.

## 4. How the game starts

### First boot

The player sees a ten-second pixel-art transmission: the surface city has gone silent, emergency cameras show spider nests and infected civilians, and the underground Security Core is the last functioning containment system. A maintenance engineer seals the lift and receives one instruction: **keep the Core powered.**

The title appears as the lift doors buckle from the other side.

### First playable ten minutes

| Time | Player experience | What it teaches |
|---|---|---|
| 0:00–1:00 | Walk around the Core room, aim a service pistol, and inspect the flashing breach indicator. | Move, aim, shoot, interact. |
| 1:00–2:30 | Use a mining tool to open a short tunnel to a scrap cache. Digging reveals a pulsing hive wall. | Digging changes the map and may expose danger. |
| 2:30–4:00 | Place a barricade and one sentry on highlighted tiles. The first siren begins. | Build mode, rotation, power capacity. |
| 4:00–5:30 | Wave 1 sends slow spiderlings down the newly opened tunnel. | Shooting, reloading, turret support, Core health. |
| 5:30–7:00 | Collect scrap and biomass. Choose one of three upgrades: ricochet rounds, faster mining, or stronger barricades. | The run changes through choices. |
| 7:00–9:00 | Dig toward a generator room while a small pack breaks through a soft wall elsewhere. | Tunnels have tradeoffs; enemies can create breaches. |
| 9:00–10:00 | A large spider silhouette crosses behind a cracked wall. The next-wave panel identifies a new threat. | Telegraph the boss and set the long-term goal. |

The tutorial uses normal game rules and transitions directly into the first run. Prompts disappear as soon as the relevant action is completed and remain available in a codex.

## 5. Core loop

Each wave cycle takes roughly three to five minutes:

1. **Survey:** see likely breach directions and one partially identified enemy trait.
2. **Dig:** reach scrap, power relays, sealed rooms, and optional risk/reward caches.
3. **Fortify:** spend scrap on structures and repairs within a short preparation window.
4. **Fight:** survive the attack while protecting the Security Core.
5. **Salvage:** collect dropped biomass and a limited amount of field scrap.
6. **Upgrade:** choose one of three combat or engineering upgrades.

Every fifth wave is an escalation wave. It adds an elite, map event, or boss. A Bastion Run ends after the final boss, when the player chooses to extract with the run's research or stay for score in an endless overtime.

### Win and loss

- The Core loses integrity when enemies reach it and complete an attack.
- If the player is downed, a short automated recovery timer begins; enemies continue advancing.
- A run ends when Core integrity reaches zero.
- Defeating the final boss unlocks extraction and counts as a win.
- Endless score is based on waves, boss kills, remaining Core integrity, and optional objectives—not raw play time alone.

## 6. Digging and map design

Use a grid of 16-pixel art tiles. The logical simulation treats each tile as solid, open, reinforced, occupied, or hazardous. Maps begin from authored layouts with randomized sealed chambers, resource pockets, soft walls, and breach points. This gives replayability without the incoherence of fully procedural noise.

Digging rules:

- The mining tool removes soft rock quickly and reinforced material slowly.
- Certain hive walls awaken enemies or open a new spawn route.
- Structural pillars and the Security Core cannot be removed.
- Placed structures can be dismantled during preparation for a partial refund.
- The player can never completely seal every route. The build preview shows whether at least one valid path remains.
- Dig previews display affected tiles and warn when a new exterior route will be connected.

The map should create meaningful choices between a short dangerous route, a long controllable kill lane, and side rooms containing resources or permanent damage repair.

## 7. Fortress systems

Keep the economy understandable: **scrap** builds and repairs; **power capacity** limits active machines. Biomass is only used for the between-wave upgrade choice and long-term research after a run.

### Launch defenses

| Structure | Function | Counter-pressure |
|---|---|---|
| Barricade | Cheap obstruction that buys time. | Brutes and diggers destroy it quickly. |
| Blast door | Expensive controllable gate with high health. | Costs power while locked. |
| Sentry | Reliable single-target ballistic fire. | Limited firing arc and magazine. |
| Arc coil | Chains damage through dense spiderlings. | Weak against isolated armored enemies. |
| Laser tripwire | Damages and marks a narrow lane. | Can overheat and be web-disabled. |
| Auto-repair node | Repairs nearby structures between attacks. | Fragile, expensive, and power-hungry. |

The player should be able to save, label, and rebuild a small **blueprint group** only after the basic placement system works. It is a convenience feature, not an MVP dependency.

## 8. Personal combat and upgrades

### Phase 4 implemented exploration economy

The playable map now uses a 96×54-cell expedition layout with a camera-follow view, distant branch rooms, survey sectors, seeded mineral faces, and multiple sealed bunker approaches. Exploration produces bounded run currency through $5 sector surveys, copper, energy crystals, rare diamonds, supply caches, and a $20 six-find milestone bonus.

Core Base is the conversion point for this economy. Players can unlock the SMG and railgun, improve individual weapons through four marks, upgrade already placed sentries through four installed tiers, repair all damaged equipment, and restock ammunition. Sentries are valid enemy targets from their first tier; barricades intercept first, while enemy role and late-wave pressure determine equipment damage. This establishes an exploration → extraction → return → invest → defend loop without adding pay-to-win or out-of-run currency.

### Weapons

1. Service pistol — accurate fallback with unlimited reserve ammo and modest damage.
2. Pump shotgun — close-range knockback and lane clearing.
3. SMG — mobile sustained fire with high ammunition demand.
4. Nail cannon — pins enemies and rewards tunnel-aligned shots.
5. Grenade launcher — area damage that can trigger environmental barrels but never damage the Core.
6. Mining laser — continuous beam that cuts enemies and terrain, creating dangerous accidental routes.
7. Arc projector — chains through swarms and powers nearby coils while firing.
8. Rail driver — slow, high-penetration shot for armored elites and bosses.

Each weapon has a small, authored upgrade tree rather than random percentage soup. Example shotgun branches:

- **Breacher:** wider cone, stronger knockback, barricade damage immunity.
- **Slugger:** single projectile, armor penetration, boss stagger.
- **Incendiary:** lingering burn, biomass explosions, heat management.

Run upgrades should change behavior whenever possible: ricochet, piercing, orbiting drones, reload shockwaves, dash mines, or kills that recharge nearby turrets. Simple damage and fire-rate increases support these transformations but should not dominate the choices.

### Movement and survival

- Eight-direction movement with independent aim.
- Short dodge burst with clear invulnerability feedback.
- Manual reload.
- Context action for repair, revive, open, and activate.
- Optional aim assist and target friction on controller.
- No contact damage from every enemy; attacks use visible animations so close combat feels fair.

## 9. Enemies and bosses

### Common enemies

| Enemy | Battlefield job |
|---|---|
| Spiderling | Fast, fragile swarm body that pressures ammunition and lanes. |
| Leaper | Pauses, telegraphs, then jumps barricades or gaps toward the player. |
| Webber | Slows the player and disables a structure until the web is shot away. |
| Burrower | Creates a temporary side breach if ignored. |
| Husk | Infected human; slow, durable, and releases spiderlings when destroyed. |
| Spitter | Fires a visible acid arc at clustered defenses. |

### Elites

- **Bulwark:** armored front, vulnerable abdomen; forces flanking or piercing.
- **Screamer Husk:** accelerates nearby swarms until interrupted.
- **Brood Carrier:** releases multiple waves of spiderlings and becomes faster as its sacs are destroyed.

### Bosses

- **Siege Weaver:** webs whole corridors, climbs over walls, and forces the player to clear anchor points.
- **Burrow King:** tunnels between marked impact zones and permanently alters several map tiles.
- **The Matriarch:** final multi-phase boss that attacks the Core from multiple lanes and summons infected husks.

Bosses must challenge fortress layouts without simply ignoring them. They disable, climb, reroute, or pressure multiple lanes while defenses still contribute meaningful damage.

## 10. Wave director

The director spends a threat budget on enemy packs. Budget grows by wave, then receives modifiers from difficulty, performance, selected map event, and how well the player is doing. It should never silently hard-counter the player's build.

Rules:

- Preview the next wave's dominant threat and likely entry sectors.
- Introduce only one new enemy behavior at a time during the first run.
- Spawn in pulses with brief breathing spaces rather than one continuous stream.
- Cap active complex enemies; overflow threat becomes cheap spiderlings or later pulses.
- Give repeated spawn routes diminishing weight so other openings remain relevant.
- Boss waves are authored sequences controlled by the same spawn interface.

Difficulty changes enemy composition, telegraph windows, resource pressure, and boss patterns. Avoid turning difficulty into health inflation alone.

## 11. Progression

### During a run

- Weapon pickups and authored weapon branches.
- One of three upgrade cards after each wave.
- Fortress modules found in sealed rooms.
- Temporary Core protocols, such as emergency shields or double turret power for one wave.

### Between runs

Recovered research unlocks new items into the run pool, starting loadouts, cosmetics, codex entries, and difficulty modifiers. Early upgrades should mostly add options. Small permanent bonuses can exist at the end of research branches, capped low enough that skill and fortress design remain important.

Recommended progression tracks:

- Ballistics
- Energy weapons
- Automation
- Excavation
- Containment/Core systems

The first run starts with pistol, shotgun, barricade, and sentry. Every run should unlock or visibly advance something during the first few hours.

## 12. Art, sound, and tone

- Pixel art with 16-pixel environment tiles and larger multi-tile bosses.
- Dark rock and industrial backgrounds; warm player lighting; sickly magenta/green hive materials.
- High-contrast enemy outlines and color-independent shapes.
- Stylized pixel debris rather than realistic gore; provide reduced gore and screen-shake settings.
- Music layers add percussion and distortion as wave threat rises.
- Weapons need distinct transient sounds, reload rhythms, and low-ammo cues.
- Digging, building, and shooting should each have satisfying hit-stop, particles, and camera feedback, all individually reducible.

Use a 640×360 gameplay design canvas, a 16:9 safe area, and an adaptive camera/UI that also supports 16:10 without cropping. UI text renders at a readable native scale rather than being baked into tiny sprites.

## 13. Controls, UI, and accessibility

Keyboard/mouse defaults:

- WASD: move
- Mouse: aim
- Left mouse: fire
- Right mouse: alternate fire or mining tool
- Space: dodge
- Shift: sprint while energy remains
- R: reload
- E: interact/repair
- Tab: build mode
- 1–4 / wheel: weapon or build selection

Controller defaults use twin-stick aim, triggers for fire/mine, a face button for dodge, and radial build/weapon menus. Every action is remappable.

Required options for launch:

- Full input rebinding and simultaneous mouse/controller input.
- Aim assist strength, hold/toggle fire, and hold/toggle build mode.
- Screen shake, hit flash, gore, damage numbers, and flashing intensity controls.
- Master/music/effects sliders and mono audio option.
- UI scale and high-contrast threat indicators.
- Subtitles for transmissions; important gameplay information is never audio-only.
- Pause in all single-player gameplay, including upgrade screens.

## 14. Engine and technical plan

### Why Godot

Use **Godot 4.7.1 stable** and freeze that patch version for each milestone. Godot has a dedicated 2D renderer, 2D physics, tilemaps, animation, particles, desktop export tools, and no engine royalty. Its MIT license permits commercial distribution; include the Godot license notice or official license link in the game credits.

Use GDScript for gameplay and tools. Only move a proven hotspot to C++/GDExtension after profiling. Avoid an engine upgrade in the middle of a milestone.

### System architecture

Keep content data-driven and Steam-independent:

- `WorldGrid`: authoritative tile state and chunk dirtiness.
- `TunnelSystem`: dig validation, tile damage, reveals, and breach warnings.
- `FlowFieldSystem`: grid-based routes from open cells to the Core; recalculates dirty regions on a controlled cadence.
- `BuildSystem`: placement rules, refunds, power capacity, and structure ownership.
- `WaveDirector`: threat budget, spawn pulses, previews, and boss sequences.
- `EnemyAgent`: lightweight state machine following the shared flow field.
- `CombatSystem`: damage packets, status effects, projectiles, explosions, and factions.
- `EntityPool`: reuses enemies, projectiles, decals, damage numbers, and particles.
- `RunState`: seed, wave, inventory, choices, score, and extraction status.
- `SaveService`: versioned saves with migration; keeps save data separate from machine settings.
- `PlatformService`: local no-op implementation plus a Steam implementation for achievements, stats, overlay, and leaderboards.

Godot scenes represent actors and structures. Custom `Resource` files define weapons, enemies, waves, structures, and upgrades so balance changes do not require editing code.

### Pathfinding and swarm performance

Do not run independent A* searches for every spider. Maintain one or a few flow fields pointing toward the Core and update them only when the tunnel grid changes. Enemies use simple local separation to avoid perfect stacking.

Performance targets:

- Locked 60 FPS at 1280×800 on the chosen minimum-spec test PC and Steam Deck-class hardware.
- Vertical slice: 250 active simple enemies plus projectiles and defenses.
- Release target: 500 active simple enemies in a stress arena; complex enemies remain capped.
- Far/off-screen enemies use reduced update frequency.
- Collision is simplified to circles/capsules; cosmetic legs do not have physics.
- Pool high-churn entities and profile before adding threads or native code.

### Save and test design

- Autosave permanent progression after every unlock and at run end.
- Save an active run only between waves; loading returns to the preparation phase to avoid fragile mid-combat serialization.
- Use a schema version and retain at least one backup save.
- Put save/progression files in Steam Auto-Cloud; exclude display, graphics, and device-specific input settings.
- Allow the game to run fully offline and without Steam; Steam features degrade gracefully.
- Seeded runs, deterministic wave composition where practical, and a debug spawn panel make balance bugs reproducible.

## 15. Suggested project layout

```text
res://
  autoload/
    game.gd
    save_service.gd
    platform_service.gd
    audio_service.gd
  data/
    enemies/
    weapons/
    structures/
    upgrades/
    waves/
  scenes/
    boot/
    menus/
    run/
    player/
    enemies/
    structures/
    projectiles/
    ui/
  systems/
    world_grid.gd
    tunnel_system.gd
    flow_field_system.gd
    wave_director.gd
    combat_system.gd
  art/
  audio/
  tests/
```

## 16. Production roadmap

These are scope ranges for one experienced full-time developer with part-time art/audio help. A new developer or evenings-only schedule should multiply them substantially.

### Phase 0 — Preproduction, 1–2 weeks

- Lock the pillars and scope guardrails.
- Prototype a gray-box player, digging tiles, one spider, and Core targeting.
- Prove that opening a tunnel changes the shared enemy route.
- Define the art palette, tile size, camera scale, and input actions.

**Exit gate:** digging, aiming, shooting, and rerouting an enemy are fun enough to repeat for ten minutes.

### Phase 1 — Combat prototype, 3–5 weeks

- Add pistol, shotgun, one turret, barricades, repair, and two enemy types.
- Add pooled projectiles/enemies and the first flow field.
- Create a five-wave test with temporary UI and restart.
- Profile 250-enemy stress scene.

**Exit gate:** testers understand the loop without explanation and choose different tunnel layouts on repeat runs.

### Phase 2 — Vertical slice, 6–8 weeks

- Build the opening ten minutes and one polished 15–20 minute run segment.
- Add four weapons, four structures, four enemies, one elite, and Siege Weaver.
- Add upgrade choices, basic meta progression, save/load, controller support, and final-quality representative art/audio.
- Export and test through a Steam private branch early.

**Exit gate:** the slice looks like the intended store screenshots and reaches 60 FPS under its swarm target.

### Phase 3 — Production, 10–16 weeks

- Complete launch weapons, defenses, enemies, bosses, research, events, UI, settings, and tutorial.
- Implement PlatformService Steam features, Auto-Cloud configuration, and achievements.
- Run weekly external playtests and balance from completion/death/choice telemetry saved locally or gathered with tester consent.
- Build the public Steam demo from the same project with a content flag.

**Exit gate:** all advertised features are implemented; the game is content-complete from first boot to credits.

### Phase 4 — Alpha/beta and launch, 6–10 weeks

- Feature freeze, bug fixing, performance, accessibility, controller glyphs, save migration, localization-ready text, and store assets.
- Test fresh install, upgrade install, offline first run, cloud conflict, multiple resolutions, alt-tab, suspend/resume, and controller disconnect.
- Use Steam Playtest or private beta branches, then submit the near-final store page and build for review.
- Keep at least two weeks of schedule buffer after content lock.

**Exit gate:** no progression blockers, no reproducible save loss, stable 60 FPS at target load, correct store claims, and an approved Steam build.

Total practical target: roughly **6–10 full-time months** for a polished small game, depending mostly on art production, balance iteration, and developer experience. Multiplayer would add substantial time and risk and is not included.

## 17. Steam deployment plan

Begin Steam onboarding during the vertical slice, not at the end.

1. Create the Steamworks partner account, complete identity/bank/tax verification, sign the agreements, and pay the **$100 USD app fee**.
2. Respect Steam's minimum timing gates: the first titles cannot release until 30 days after paying the fee, and the public Coming Soon page must be live for at least two weeks.
3. Create one Windows 64-bit depot and upload Godot exports with SteamPipe. Keep `internal`, `playtest`, `demo`, and `default` branches as needed.
4. Make the Windows export launch directly with no separate launcher. Include the Godot license notice in credits.
5. Integrate Steam behind `PlatformService`; the non-Steam build must still launch. Start with achievements/stats and overlay. Configure Steam Auto-Cloud for progression saves. Add leaderboards only when Endless scoring is cheat-resistant enough for the intended level of seriousness.
6. Publish the Coming Soon page when screenshots and the core visual identity are representative. Store screenshots must show real gameplay and listed features must exist at launch.
7. Ship a focused demo containing the tutorial and an abbreviated run. Keep demo progression isolated or intentionally transferable, and state which behavior is used.
8. Submit the store presence and near-final build at least seven business days before the desired release-review deadline; Valve says reviews typically take 3–5 business days but recommends more buffer.
9. Test on a clean Steam account, offline mode, controller only, 1280×800, and Proton/Steam Deck. All menus and content must be reachable with the default controller configuration.
10. After approval and the Coming Soon minimum, use Steamworks' release controls manually on launch day. Prepare a rollback build and first-week patch branch before release.

### Steam launch feature set

- 10–15 achievements tied to milestones and play styles, not excessive grinding.
- Steam Auto-Cloud for progression and between-wave run saves.
- Full controller support and correct live glyphs.
- Rich Presence if schedule allows: wave, mode, and current boss.
- Endless leaderboard only if the mode is ready; do not advertise it speculatively.
- Steam Deck compatibility target: controller-complete, readable at 1280×800, no launcher, offline single-player, and device-specific graphics settings excluded from cloud sync.

## Phase 4.5 implementation record — Frontier Core Expansion

Phase 4.5 proves the territorial campaign inside the current 96×54 world before any chunk-streaming expansion:

- The original objective is the permanent Command Core; its loss ends the run.
- Three seeded regional sites become Crystal Research, Industrial Foundry, and Hive Containment bases after discovery, Guardian clearance, investment, and an activation defense.
- Operational bases own powered territory, regional services, local structures, independent condition, and a cached enemy flow field.
- Frontier loss is recoverable. Disabled bases remove their territory and shop until reactivated.
- Expansion raises scheduled population by 12% per active Frontier Core and enables stable split-target attacks, preventing an uncontested territorial snowball.
- The versioned local run save makes longer territorial campaigns resumable and is deliberately separate from device-specific graphics settings for later Steam Auto-Cloud use.

The next world-size increase should not begin until tests prove zero-to-three Frontier Cores, simultaneous pressure, disable/reactivate behavior, save restoration, and the 280-enemy performance ceiling.

## Phase 4.6 implementation record — UIX Command Clarity

Phase 4.6 makes the growing territorial campaign readable without changing its economy, difficulty, or combat balance:

- The HUD treats immediate combat, base-network condition, and contextual interaction as separate information layers.
- Every revealed Core receives a compact state card, while threatened off-screen Cores produce directional markers.
- Frontier activation, base danger, and turret locks take priority in the objective channel.
- Unsurveyed sectors remain concealed on the minimap, preventing the interface from spoiling the exploration network.
- Equipment hunters visually acquire targets and targeted sentries expose their attacker count.
- Structure and Core condition now shifts through clear healthy, caution, and critical visual states.
- Core Base services are grouped beneath identity, funds, condition, and linked-defense summaries with controller-visible focus states.

Future UI passes should add rebindable controls, platform glyph switching, scalable text presets, and a dedicated full-screen territory map only after the current 640×360 layout passes runtime capture and controller testing.

## Patch 4.7 implementation record — Materials and Economic Agency

Patch 4.7 replaces direct mineral cash payouts with a transparent extraction economy:

- Raw copper, silver, gold, crystal, and diamond cargo remains visible until the player chooses how to process it.
- Contract refining converts deposited raw cargo into credits after a 24-second job.
- A $5,000 player-owned Foundry unlocks self-refining into bronze, silver, gold, crystal-core, and cut-diamond components.
- Refined stock can be retained for technology requirements or sold for a higher payout.
- Weapon, turret, and base marks consume named components as well as credits.
- Frontier Core construction costs $1,000 and reports every unmet construction condition.
- Turret upgrades are assigned to a player-selected linked turret, with synchronized world and minimap highlighting.
- The Core interface is divided into Armory, Defenses, Materials, and Base departments so resource state and purchase purpose remain visible within the 640×360 viewport.

## 18. Testing checklist

### Fun and balance

- Can new players explain why opening a tunnel was risky?
- Do at least three fortress shapes work at the same difficulty?
- Does the player personally contribute even with a strong fortress?
- Is every death attributable to a visible mistake or tradeoff?
- Do bosses interact with defenses without nullifying them?

### Technical

- Repeatedly dig, fill, dismantle, and reroute while 500 enemies are active.
- Kill hundreds of enemies with chain lightning and explosions in the same second.
- Save, force close, restore, migrate an old schema, and recover the backup.
- Disconnect/reconnect a controller during every menu and combat state.
- Change resolution/aspect ratio and UI scale during a run.
- Launch without Steam, without internet, and after Steam Cloud conflicts.

### Release

- Clean-machine install has all redistributables and launches from Steam.
- Store language, screenshots, tags, controller claims, system requirements, and accessibility claims match the build.
- Credits contain licenses and attribution for Godot and every third-party asset/library.
- Crash logs never include personal data or Steam credentials.

## 19. Main risks and answers

| Risk | Early answer |
|---|---|
| Dynamic digging makes pathfinding expensive. | Prove the shared flow field and dirty-region update in Phase 0; never use one path search per enemy. |
| Fortress play becomes passive. | Make enemies pressure the player, require manual repairs/reloads, and cap automated power. |
| Swarms become visual noise. | Reserve strong colors and large effects for dangerous attacks; cap overlapping VFX and damage numbers. |
| Procedural maps create unwinnable layouts. | Randomize authored room graphs and validate at least one route before accepting a seed. |
| Meta progression overwhelms skill. | Unlock options first; cap permanent numerical power. |
| Multiplayer consumes the project. | Keep player input decoupled, but do not build networking until after a successful single-player launch. |
| Steam work arrives too late. | Onboard and upload a private vertical-slice build months before release. |

## 20. First build backlog

The first playable should contain only the proof of the game's unique idea:

1. Create the Godot project, fixed art grid, input map, and Windows export preset.
2. Implement player movement, mouse/twin-stick aiming, pistol, health, and dodge.
3. Implement a 40×30 logical tile grid with diggable and indestructible cells.
4. Add the Security Core and a shared flow field from open tiles to the Core.
5. Add one spiderling that follows the field and attacks the Core.
6. Recalculate the route when the player digs a tile.
7. Add pooled spiderlings and bullets; stress-test 250 enemies.
8. Add scrap, barricade placement, one sentry, and repair.
9. Add a five-wave director with a restart screen.
10. Put the build in front of five testers before adding more content.

The prototype succeeds if players discover that they can deliberately dig a longer firing lane, understand that the tunnel also exposes the Core, and immediately want to try a different fortress layout.

## Primary references

- [Godot 4.7.1 stable release archive](https://godotengine.org/download/archive/)
- [Godot dedicated 2D feature documentation](https://docs.godotengine.org/en/stable/tutorials/2d/index.html)
- [Godot Windows export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html)
- [Godot license](https://godotengine.org/license/)
- [Steamworks onboarding](https://partner.steamgames.com/doc/gettingstarted/onboarding?l=english)
- [Steam Direct fee](https://partner.steamgames.com/doc/gettingstarted/appfee?l=english)
- [Steam release options](https://partner.steamgames.com/doc/store/types?l=english)
- [Steam review process](https://partner.steamgames.com/doc/store/Review_Process?l=english)
- [Steam Cloud](https://partner.steamgames.com/doc/features/cloud?l=english)
- [Steam achievements](https://partner.steamgames.com/doc/features/achievements?l=english)
- [Steam Deck recommendations](https://partner.steamgames.com/doc/steamdeck/recommendations?l=english)
# Patch 4.9 Realm Persistence Addendum

- Patch 4.9 supersedes the earlier 96×54 validation world with a 192×108 realm divided into 24×24 streaming regions.
- Realm topology is deterministic from a positive 31-bit seed.
- Saves are stored under writable `user://saves/<realm-id>/`, use encrypted atomic writes, and remain portable across install paths and machines.
- The previous valid checkpoint is retained as `world.backup.cbr`.
- Realm identity, seed, topology, and save payload must agree before Continue is offered.
- Wave 20+ combat state includes surviving hostiles and pending overlapping surges in persistence.
- Absolute prevention of local-owner modification is not a valid offline security promise; the release target is tamper resistance and safe rejection.

# Patch 4.11 Mutant Bestiary Addendum

- Every implemented enemy role owns a distinct project-local raster sprite and silhouette.
- Sprite dimensions may exceed collision radii for readability, but art never changes the Patch 4.10 combat contract.
- Directional facing follows flow-field movement; attack poses are renderer-only state.
- Spitter, Leaper, Guardian, Broodling, and turret-hunter telegraphs remain readable above the sprite layer.
- Enemy texture draw calls are camera-culled before the late-wave 280-hostile safety cap.
- Runtime mob PNGs load directly from packaged bytes and must pass alpha, decode, dependency, and clean-extraction gates.
