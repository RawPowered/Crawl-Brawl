# Pack: Enemy Projectiles

**Pipeline:** Magenta chroma `#FF00FF` — same as `00-production-spec.md`  
**Importer:** `python tools/import_enemy_projectiles.py`  
**Source sheets (your gens):** `assets/art/mobs/projectiles/{Tunnel,Hive,Bunker,Crystal,Foundry,Sulfur,Iron}.png`  
**Runtime output:** `assets/art/combat/{biome}_{type}_{glob|trail|splat}.png`  
**Runtime:** `systems/combat_vfx.gd` → enemy glob/trail/splat by `source_biome_id`  
**Fallback until import:** existing `acid_glob` / `acid_trail` / `acid_splat`

**Output naming (after cut):**  
`assets/art/combat/projectiles/{biome}_{type}_{glob|trail|splat}_source.png`  

Examples: `tunnel_spore_glob_source.png`, `hive_venom_trail_source.png`, `iron_kinetic_splat_source.png`

| Setting | Value |
|---------|-------|
| Generate size | **512×512** per sheet (3-panel strip) |
| Runtime target | Readable at ~8–16px after import |
| Background | Flat solid **#FF00FF** only |
| Subject | Projectile parts only — **no creature body** |

**How to use with ChatGPT**

1. Paste **Shared prefix**  
2. Paste **Shared sheet layout**  
3. Paste **one** kit body (Sprint A §1–7, or Sprint B add-on)  
4. Download the sheet → keep as source until cut/import  

Generate all **7 Sprint A** kits before Sprint B add-ons.

---

## Shared prefix (paste first every time)

```
Premium hand-crafted pixel art for a top-down 2D action-defense game (Crawl Brawl). Exactly ONE projectile sheet subject. Strict top-down three-quarter orthographic view. Limited 8–16 color palette, strong 1px dark outline, readable when shrunk to 16px. Isolated on perfectly flat solid #FF00FF magenta chroma-key background — no shadow, floor, gradient, scenery, text, UI, watermark. No magenta inside the subject. No creature body — projectile parts only. Generate at 512x512. Style: organic brood / industrial infestation hybrid, AAA indie pixel clarity.
```

## Shared sheet layout (append every time)

```
Output a single horizontal 3-panel strip on one #FF00FF canvas: [1] flight body (glob/bolt)  [2] motion trail fragment  [3] impact splat/burst. Equal panel spacing, each subject clear, no labels, no panel borders.
```

---

## Sprint A — Artillery kits (generate all 7)

### 1. Tunnel — SPORE LAUNCHER (`spore`)

**Save as:** `tunnel_spore_*` → `tunnel_spore_glob_source.png`, `tunnel_spore_trail_source.png`, `tunnel_spore_splat_source.png`

```
Spore pod projectile: dusty mushroom puff-ball with tiny spore flecks, muted ochre and olive, soft spherical body, crumbly trail of spores, impact as expanding spore cloud puff. Not liquid acid.
```

### 2. Hive — VENOM SPITTER (`venom`)

**Save as:** `hive_venom_*`

```
Venom spit projectile: glossy organic droplet, toxic green-lime with darker green core, thin mucus trail, impact as sticky venom splat with small drip beads. Classic brood spit, not fire.
```

### 3. Bunker — ARC RELAY CRAWLER (`arc`)

**Save as:** `bunker_arc_*`

```
Arc bolt projectile: short electric spear of cyan-white energy with scrap-metal core spark, jagged trail of micro-arcs, impact as crackling star burst. Industrial hive-tech, not organic goo.
```

### 4. Crystal — CRYSTAL SIPHON (`arc`)

**Save as:** `crystal_arc_*`

```
Prism shard projectile: faceted cyan-ice crystal dart, translucent edges, faint light refraction, sparkling trail of crystal dust, impact as shattering ice burst. Cold and sharp, not acid. Must silhouette differently from bunker arc bolt.
```

### 5. Foundry — EMBER SPITTER (`thermal`)

**Save as:** `foundry_thermal_*`

```
Slag ember projectile: glowing orange-hot coal blob with darker cooled crust, heat shimmer trail of sparks, impact as ember burst with tiny flame flecks. Hot foundry spit, not green acid.
```

### 6. Sulfur — GAS BLISTER (`corrosive`)

**Save as:** `sulfur_corrosive_*`

```
Acid gas blister projectile: sickly yellow-green translucent bubble with toxic haze inside, wispy gas trail, impact as blister pop into corrosive puddle spray. Toxic sulfur chemistry.
```

### 7. Iron — MAGNET PULSER (`kinetic`)

**Save as:** `iron_kinetic_*`

```
Magnetic metal slug projectile: dense dark iron oval with blue magnetic fringe rings, short dense trail of metal filings, impact as heavy kinetic punch with spark chips. Solid mass, not liquid.
```

---

## Sprint B — Optional add-ons (generate after A)

### Bulwark lob (pick one biome kit and upscale mass)

Same ChatGPT paste as that biome’s Sprint A kit, plus this line at the end:

```
Larger lobbed mortar silhouette, slower-looking mass, thicker outline, 20–30% bigger than the artillery glob.
```

**Save as:** `{biome}_{type}_lob_*` (e.g. `iron_kinetic_lob_glob_source.png`)

### Guardian cyst

**Save as:** `guardian_cyst_*`

```
Brood guardian cyst projectile: large chitin egg-sac lob, deep purple-green shell with venom cracks, heavy arc silhouette, impact as rupturing cyst spraying venom droplets. Boss-scale, menacing. 3-panel strip same layout.
```

---

## QA before handoff for cut / chroma / import

- [ ] Flat `#FF00FF` only; no magenta inside subject  
- [ ] Three panels clearly separable  
- [ ] Silhouette distinct from the other six at thumbnail size  
- [ ] No guns, UI, text, or creature bodies  
- [ ] Crystal arc reads differently from bunker arc  
- [ ] All 7 Sprint A sheets ready before requesting cut/import  

**Handoff:** Drop source sheets (or a zip) back in chat when ready for cutting, chroma keying, and combat importer wiring.
