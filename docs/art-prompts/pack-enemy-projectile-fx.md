# Pack: Enemy Projectile FX

**Pipeline:** Magenta chroma `#FF00FF` — same as `00-production-spec.md`  
**Companion pack (do not re-generate):** [`pack-enemy-projectiles.md`](pack-enemy-projectiles.md) — 7 biome artillery kits already covered  
**Importer (later hook):** extend `tools/import_enemy_projectiles.py` or dedicated FX cut  
**Source sheets (your gens):** `assets/art/mobs/projectiles/fx/`  
**Runtime targets:** `assets/art/combat/` — hazard / status / lob / cyst IDs  
**Fallback until import:** procedural tinted disks (hazards), existing acid glob/trail/splat (lob), WHITE/cyst modulate (cyst)

| Setting | Value |
|---------|-------|
| Generate size | **512×512** per sheet |
| Runtime target | Hazards ~24–48px; status ~16×16; lob/cyst ~12–20px |
| Background | Flat solid **#FF00FF** only |
| Subject | FX / projectile parts only — **no creature body**, no UI, no text |

**How to use with ChatGPT**

1. Paste **Shared prefix**  
2. Paste the **layout line** for that asset (2-panel, status tile, or 3-panel)  
3. Paste **one** body below  
4. Download → drop under `assets/art/mobs/projectiles/fx/` until cut/import  

Generate hazards + status before lob/cyst if bandwidth is limited.

---

## Shared prefix (paste first every time)

```
Premium hand-crafted pixel art for a top-down 2D action-defense game (Crawl Brawl). Exactly ONE combat FX subject. Strict top-down three-quarter orthographic view. Limited 8–16 color palette, strong 1px dark outline, readable when shrunk to 16px. Isolated on perfectly flat solid #FF00FF magenta chroma-key background — no shadow, floor, gradient, scenery, text, UI, watermark. No magenta inside the subject. No creature body — FX and projectile parts only. Generate at 512x512. Style: organic brood / industrial infestation hybrid, AAA indie pixel clarity.
```

---

## 1. Hazard — thermal ground patch

**Layout (append):**

```
Output a single horizontal 2-panel strip on one #FF00FF canvas: [1] thermal ground ring / heat disk  [2] small ember fleck accent. Equal panel spacing, each subject clear, no labels, no panel borders.
```

**Body:**

```
Thermal hazard floor FX: glowing orange-hot slag ring with darker cooled crust edge, soft heat shimmer inside the ring, ember fleck as a tiny bright orange spark chip. Must read as hot foundry ground hazard — not green acid, not mushroom spores, and not a tall flame geyser. Flat ground-plane silhouette suitable for a floor patch under the player.
```

**Save as:** `hazard_thermal_ring_source.png`, `hazard_thermal_ember_source.png`  
**Runtime IDs (planned):** `hazard_thermal`, `hazard_thermal_ember`

---

## 2. Hazard — spore ground patch

**Layout (append):**

```
Output a single horizontal 2-panel strip on one #FF00FF canvas: [1] spore ground cloud disk  [2] soft spore puff accent. Equal panel spacing, each subject clear, no labels, no panel borders.
```

**Body:**

```
Spore hazard floor FX: muted ochre-olive dusty mushroom cloud disk with tiny spore flecks, soft crumbly edges, puff accent as a small ochre spore burst. Must silhouette differently from thermal heat rings and from flamethrower flame_patch art — dusty organic fog on the floor, not fire, not liquid acid.
```

**Save as:** `hazard_spore_cloud_source.png`, `hazard_spore_puff_source.png`  
**Runtime IDs (planned):** `hazard_spore`, `hazard_spore_puff`

---

## 3. Status — venom slow rim

**Layout (append):**

```
Output a single centered tile on one #FF00FF canvas: one small circular status rim icon only. No panels, no labels. Subject should remain clear at ~16x16 after shrink.
```

**Body:**

```
Venom slow status rim: thin toxic green-lime circular outline with a soft mucus sheen, slight drip bead at the bottom of the ring, hollow center so it can sit around a player silhouette. Reads as sticky venom slow — not fire, not purple DoT, not a full splat.
```

**Save as:** `status_venom_rim_source.png`  
**Runtime ID (planned):** `status_venom_rim`

---

## 4. Status — DoT pulse

**Layout (append):**

```
Output a single centered tile on one #FF00FF canvas: one small circular status pulse icon only. No panels, no labels. Subject should remain clear at ~16x16 after shrink.
```

**Body:**

```
Damage-over-time status pulse: compact corrosive/venom pulse disc with sickly yellow-green to purple-bruise core, soft outer glow ring, hollow enough to overlay a player. Must silhouette differently from the venom slow rim — filled pulse vs thin mucus outline. Not fire, not sparks, not a full impact splat.
```

**Save as:** `status_dot_pulse_source.png`  
**Runtime ID (planned):** `status_dot_pulse`

---

## 5. Bulwark lob mass (3-panel)

**Layout (append):**

```
Output a single horizontal 3-panel strip on one #FF00FF canvas: [1] flight body (heavy lob mass)  [2] motion trail fragment  [3] impact splat/burst. Equal panel spacing, each subject clear, no labels, no panel borders.
```

**Body:**

```
Bulwark lobbed mortar projectile: thick heavy organic-industrial mass, slower-looking silhouette, thicker 1px-plus outline feel, 20–30% bulkier than a normal artillery glob. Muted ochre-iron crust with toxic core flecks. Dense short trail, impact as crushing mortar burst with chunky debris — not a thin spit droplet, not a guardian egg-sac.
```

**Save as:** `bulwark_lob_glob_source.png`, `bulwark_lob_trail_source.png`, `bulwark_lob_splat_source.png`  
**Runtime IDs (planned):** `enemy_lob_glob`, `enemy_lob_trail`, `enemy_lob_splat` (or biome-prefixed if importer unifies)

---

## 6. Guardian cyst (3-panel)

**Layout (append):**

```
Output a single horizontal 3-panel strip on one #FF00FF canvas: [1] flight body (cyst sac)  [2] motion trail fragment  [3] impact splat/burst. Equal panel spacing, each subject clear, no labels, no panel borders.
```

**Body:**

```
Brood guardian cyst projectile: large chitin egg-sac lob, deep purple-green shell with venom crack veins, heavy arc silhouette, mucus trail beads, impact as rupturing cyst spraying venom droplets. Boss-scale and menacing. Must read differently from bulwark lob mortar mass — egg-sac biology vs chunky mortar.
```

**Save as:** `guardian_cyst_glob_source.png`, `guardian_cyst_trail_source.png`, `guardian_cyst_splat_source.png`  
**Runtime IDs (planned):** `enemy_cyst_glob`, `enemy_cyst_trail`, `enemy_cyst_splat`

---

## QA before handoff for cut / chroma / import

- [ ] Flat `#FF00FF` only; no magenta inside subject  
- [ ] Hazard thermal ≠ hazard spore ≠ existing `flame_patch`  
- [ ] Status rim (outline) ≠ status DoT (filled pulse) at thumbnail size  
- [ ] Lob mass ≠ cyst egg-sac at thumbnail size  
- [ ] No guns, UI, text, or creature bodies  
- [ ] Do **not** regenerate the 7 biome artillery kits from `pack-enemy-projectiles.md`

**Handoff:** Drop source sheets (or a zip) back in chat when ready for cutting, chroma keying, and FX importer wiring.
