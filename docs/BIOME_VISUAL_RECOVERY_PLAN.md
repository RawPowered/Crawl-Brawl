# Biome Visual Recovery Plan

Status: active  
Owner: world rendering / procedural environment  
Target viewport: 640x360  
Primary renderer: `scripts/phase0_run.gd`

## Outcome

The world must read as connected geology and authored places before it reads as a tile grid. Each biome must be identifiable by material, formations, props, atmosphere, and local enemy ecology while preserving combat readability.

No new environment art is required for the first recovery milestone. Existing texture banks and props must be correctly inventoried and deployed first.

## Confirmed regressions

- [x] Floor atlases were sampled at 8x8 source pixels even though each world cell owns a 16x16 source quadrant. This quartered the authored texture cells.
- [x] Complete 2x2 rock blocks occupied 16x16 world pixels but were drawn at 32x32, causing overlap and repeated wall bands.
- [x] The cave atlas contains a populated 4x4 wall bank inside a 10x10 canvas. Sampling all 100 slots selected blank background as wall art.
- [x] Floor selection previously treated every authored macro as an equal-purpose base tile, creating random tile soup even when coordinates were correct.
- [x] Walls previously used one generic visual language and one edge color across all biomes.
- [x] Props previously relied on isolated per-cell rolls; formations and landmarks now create deposits, runs, growths, and ruins.
- [x] Biome mobs now combine unique art with distinct encounter composition and one restrained secondary behavior.

## Runtime texture contract

| Item | Contract |
|---|---|
| World cell | 16x16 pixels |
| Terrain macro | 2x2 world cells / 32x32 destination pixels |
| Authored atlas macro | 32x32 source pixels |
| Source quadrant | 16x16 source pixels mapped to one 16x16 world cell |
| Biome atlas | 320x320 / 10x10 authored macros |
| Cave atlas | 320x320 canvas / only the upper-left 4x4 macros are populated |
| Static variation | Deterministic from realm seed, macro coordinate, biome, and purpose salt |

Source size and destination size must never share one constant. Atlas validators must reject dimensions that violate this contract.

## Visual budgets

These are starting budgets per biome, tuned after native-resolution captures:

| Layer | Coverage / frequency |
|---|---|
| Quiet base material | 65-75% |
| Subtle base variation | 15-20% |
| Meso-scale formations | 6-10% |
| Distinctive props / decals | 2-5% |
| Hero landmark | 0-2 per major chamber |
| Bright or emissive terrain | Less than 2%; reserved for signatures and gameplay |

Environment luminance remains below mobs, projectiles, interactables, defenses, and warnings.

## Atlas inventory schema

Every 10x10 biome atlas receives explicit metadata. Atlas positions are not selected from the whole sheet without a semantic pool.

```gdscript
{
    "quiet_base": PackedInt32Array(),
    "subtle_base": PackedInt32Array(),
    "formation": PackedInt32Array(),
    "transition": PackedInt32Array(),
    "edge": PackedInt32Array(),
    "detail": PackedInt32Array(),
    "rare": PackedInt32Array(),
}
```

The importer/audit tool will export a numbered contact sheet and measurements for each macro: mean luminance, luminance variance, contrast, edge density, and dominant color. Automated measurements assist classification; final semantic assignments are visually reviewed at gameplay scale.

## Biome grammar

| Biome | Quiet base | Meso structure | Rare signature | Prop ecology | Wall / edge language |
|---|---|---|---|---|---|
| Tunnel Crust | dark worn stone | sediment bands, fractures | collapsed excavation | rubble, sparse lamps, crates | stratified rock, muted warm lip |
| Hive Band | dark resin membrane | branching growth, feeding scars | brood chamber | webs, eggs, acid | resin-coated rock, violet/acid contamination |
| Bunker Shell | low-contrast plates | conduit runs, damaged deck zones | sealed machinery bay | grates, conduits, lamps | reinforced panels, cool steel lip |
| Crystal Cavern | blue-gray stone | branching crystal seams | geode chamber | shard clusters, rare conduits | faceted rock, restrained cyan edge |
| Foundry Depths | soot-dark industrial floor | heat scars, slag fields | ruined furnace line | grates, slag, conduits | scorched masonry, amber heat edge |
| Sulfur Bog | damp dark mineral earth | seepage and gas fissures | toxic basin | vents, acid, mineral bloom | stained rock, sickly yellow-green edge |
| Iron Strata | charcoal layered stone | horizontal ore bands | compressed iron seam | rubble, grates, slag | oxidized strata, rust-red edge |

## Implementation phases

### Phase 0 - Restore correct rendering

- [x] Separate atlas source dimensions from world destination dimensions.
- [x] Map one 32x32 authored macro coherently across a 2x2 world block.
- [x] Use stable seeded selection instead of periodic coordinate stripes.
- [x] Restrict cave selection to its populated 4x4 bank.
- [x] Add source-quadrant and cave-bank regression assertions.
- [ ] Capture native-resolution before/after frames from at least three seeds.

### Phase 1 - Eliminate random tile soup

- [x] Generate a reviewed contact sheet and per-cell luminance/contrast measurements for all seven biome atlases.
- [x] Curate six quiet base variants per biome.
- [x] Define weighted base pools; the plainest variants receive the highest weight.
- [x] Resolve base outliers through curation and unframing; destructive luminance normalization was not required.
- [x] Replace whole-atlas floor selection with purpose-aware weighted selection.
- [x] Run deterministic color, grayscale, blur, and native-scale terrain comparisons.

Weighted pool contract: 12 entries with six unique macros at `4/3/2/1/1/1` frequency. Reviewed atlas indices:

| Biome | Quiet-base indices, highest weight first |
|---|---|
| Tunnel | 16, 35, 37, 33, 82, 56 |
| Hive | 34, 17, 35, 74, 44, 86 |
| Bunker | 00, 01, 19, 10, 15, 09 |
| Crystal | 00, 01, 80, 10, 96, 78 |
| Foundry | 20, 02, 00, 77, 71, 88 |
| Sulfur | 98, 80, 39, 99, 06, 10 |
| Iron | 90, 99, 87, 78, 74, 31 |

Review artifact: `artifacts/biome_phase1_audit/quiet_base_contact_sheet.png`.

Runtime base sources:

- Tunnel and Hive reuse their preserved continuous runtime materials.
- Bunker, Crystal, Foundry, Sulfur, and Iron use reproducible `*_material_base_phase1.png` atlases derived by removing the five-pixel generated-sheet frame from each macro.
- Original `*_material_phase3.png` banks remain untouched and reserved for formations, transitions, and details.

Exit condition: individual base macros are difficult to identify while moving, and at least 65% of visible floor reads as one material mass.

### Phase 2 - Add meso-scale formations

- [x] Add deterministic low-frequency biome field and medium-frequency formation fields.
- [x] Add irregular formation stamps sized approximately 2-10 cells.
- [x] Create eight silhouette families per biome using eight reviewed ornate atlas macros and existing props.
- [x] Include horizontal, vertical, diagonal, fan, branch, and patch orientations while enforcing region budgets.
- [x] Place props at formation anchors with deterministic sub-cell offsets instead of unrelated centered cells.

Phase 2 runtime contract:

- Smooth seeded value fields sample at 36-cell and 12-cell scales.
- Each region receives 0, 2, or 3 formation anchors; 15% of regions intentionally remain quiet.
- Formation components occupy 2x2 terrain macros and use one of eight irregular silhouettes.
- Base atlases remain unchanged. Formations render from separate `*_material_formation_phase2.png` ornate banks at 46-65% opacity.
- Independent prop rolls are suppressed inside formation footprints; up to 72% of formation anchors receive one biome-specific prop.
- Formation and prop records are cached per region, invalidated when terrain opens, and pruned when regions unload.
- Visual audit: `artifacts/biome_phase2_audit/phase2_formation_preview.png` and its grayscale squint companion.

Exit condition: screenshots contain quiet ground, several coherent formations, and very few isolated high-contrast cells.

### Phase 3 - Repair walls and boundaries

- [x] Give walls biome-aware material/tint, edge color, and detail pools.
- [x] Add straight, corner, connector, and isolated boundary handling.
- [x] Distort biome boundaries with a seeded low-frequency field.
- [x] Add sparse contamination cells at biome borders rather than hard rectangular cuts.
- [x] Preserve mining tells and resource readability above wall decoration.

Phase 3 runtime contract:

- Logical region biome ownership remains authoritative for gameplay, minerals, spawning, saves, and mob identity.
- Visual floor ownership may cross a logical region edge by at most three cells through a shared seeded boundary displacement.
- Correlated contamination is restricted to a four-cell boundary band and never replaces an entire edge.
- Core, spawn, and revealed Hive material overrides retain priority over visual boundary blending.
- Exposed rock inherits the dominant adjacent visual biome, one of four reviewed ornate wall macros, and a unique biome edge color.
- Interior rock remains on the quiet cave material; biome wall skins appear only where rock meets walkable floor.
- Straight faces receive inset depth, adjacent two-sided faces receive corner caps, opposite faces receive connector lines, and three/four-sided cells read as isolated pillars.
- Wall skins render below fungus, geology tells, and revealed mineral seams so mining information remains readable.
- Visual boundary decisions cache per loaded region and prune with the existing visual streaming window.
- Visual audit: `artifacts/biome_phase3_audit/phase3_transition_wall_preview.png` and its grayscale squint companion.

Exit condition: biome boundaries look geographic and walls identify the adjacent area without becoming brighter than threats.

### Phase 4 - Atmosphere and landmarks

- [x] Replace global cyan motes with low-density biome profiles.
- [x] Add biome-specific light colors and rare emissive sources.
- [x] Create 0-2 landmark placements per major chamber from existing assets and multi-cell compositions.
- [x] Offset non-colliding props within cells and allow selected silhouettes to cross tile boundaries.
- [x] Remove or localize hard-coded generic props that flatten biome identity.

Phase 4 runtime contract:

- Draw-time motes sample a stable 40px lattice and use per-biome densities of 28-105 candidates per thousand, replacing the former universal cyan 27% lattice fill.
- Mote, practical-light, and subtle ambient-grade colors are unique across all seven biomes. The ambient grade follows the player biome; topology and gameplay remain unchanged.
- Each biome exposes two reviewed landmark compositions made from three or four existing runtime props. Composition silhouettes span adjacent cells and apply at most four pixels of visual offset.
- A region budget permits zero landmarks in 70% of regions, one in 26%, and two in only 4%. Actual placement requires a valid formation anchor and may remain below budget.
- Crystal shards, sulfur vents, slag, acid, eggs, conduits, and biome-colored lamps provide restrained local emission; landmark sources receive only a small emphasis increase.
- Landmark records share the formation streaming lifecycle: deterministic generation, terrain invalidation, per-region caching, and unload pruning.
- Fixed-coordinate decorative lamps, crates, support ribs, grates, hive eggs, veins, and webs have been removed. Explicit discovery scars remain because they communicate saved gameplay state.
- Visual audit: `artifacts/biome_phase4_audit/phase4_atmosphere_landmark_preview.png` and its grayscale squint companion.

Exit condition: entering a biome changes its air, practical lighting, and rare room-scale silhouette without adding enough brightness or motion to compete with mobs and projectiles.

### Phase 5 - Enemy ecology

- [x] Use unique runtime mob art and names for seven biomes and four combat archetypes.
- [x] Define biome-specific role weights and wave compositions.
- [x] Add one restrained secondary trait or environmental synergy per biome.
- [x] Keep silhouette, projectile, hit, and danger readability consistent across skins.
- [x] Validate that mobs retain their spawn-biome identity when crossing a border.

Phase 5 runtime contract:

- Every biome owns a four-role percentage profile. Hive emphasizes skirmishers, Crystal emphasizes strikers, Bunker and Sulfur emphasize artillery, and Foundry/Iron introduce substantially more bulwark pressure.
- The wave director retains authority over guaranteed leaper/spitter beats and difficulty unlock waves. Biome weighting reshapes otherwise ordinary swarm slots; ordinary bulwarks remain locked until wave six.
- Tunnel mobs use `STONE BRACE` (78% knockback), Hive uses `BROOD RUSH` (108% speed on home ground), Bunker uses `SAPPER PROTOCOL` (115% structure damage), Crystal uses `PRISM SHOT` (112% artillery projectile speed), Foundry uses `HEAT STRIDE` (112% speed on home ground), Sulfur uses `TOXIC REACH` (118% projectile lifetime / 114% firing range), and Iron uses `MAGNETIC MASS` (52% knockback).
- Traits never increase base contact damage. Typed artillery uses intentional type×L spawn scales (`projectile_combat_profile`) for projectile damage/speed/AoE/cooldown; ecology traits still only season speed/life/range. Home-ground bonuses deactivate after the mob crosses into another biome.
- All four roles retain their shared silhouette sizes, windups, hit flashes, health bars, and collision rules. Biome artillery now resolves distinct glob/trail/splat VFX by `source_biome_id` with `acid_*` fallback.
- `biome_id` is assigned from the spawn cell, saved with the hostile, restored with legacy fallback, and never rewritten by movement or relocation. Sprite, display name, composition identity, and trait therefore remain tied to origin.
- Visual audit: `artifacts/biome_phase5_audit/phase5_enemy_ecology_preview.png`.

Exit condition: a player can identify the local encounter mix from repeated contact while every individual threat remains readable by its shared combat role.

## QA gates

Every terrain change must pass:

1. Atlas contract test: correct source sizes, coherent quadrants, valid populated ranges.
2. Determinism test: the same seed and cell produce the same result.
3. Coverage test: only semantically classified atlas cells are reachable.
4. Native-scale test: 640x360 gameplay capture with player, mobs, projectiles, and structures.
5. Squint test: blurred/grayscale terrain reads as large masses and formations, not a checkerboard.
6. Repetition test: no obvious single-cell or fixed-period stripe pattern.
7. Multi-seed test: at least three seeds preserve biome grammar without identical layouts.
8. Performance test: formation and prop caches do not add per-frame generation or allocation spikes.

## Current milestone

Phases 0-5 are implemented. The next milestone is native gameplay capture and balance tuning across multiple seeds, without reopening the recovered texture contracts.
