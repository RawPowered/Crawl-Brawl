# Pack: Global Mobs

Cross-biome ecology — not biome-slotted. Paths under `assets/art/mobs/`.

**Layout:** **2×1 sheet** — Broodling | Brood Carrier on top row, Guardian full-width on bottom.  
**Not** the same 2×2 grid as biome packs.

| Mob | Canvas | File |
|-----|--------|------|
| Broodling | **13×11** | `broodling_runtime.png` |
| Brood Carrier | **24×20** | `brood_carrier_runtime.png` |
| Guardian | **58×54** | `guardian_runtime.png` |

**Import:**
```bash
python tools/import_mob_sprites.py --global path/to/global_mobs_sheet.png
```
Auto-detects row/column splits; strips label text; archives as `global_mobs_pack_source.png`.

Background: `#FF00FF`. Facing **right**. No firearms.

**Generation sheet layout (1024×682 or similar):**
```
[ Broodling 13×11 ] [ Brood Carrier 24×20 ]
[        Guardian 58×54 (full width)      ]
```
Label each creature with name + dimensions above the sprite.

---

## Broodling (13×11)

```
Premium hand-crafted pixel art for a top-down 2D action-defense game; exactly one tiny larval mutant spider; strict top-down three-quarter orthographic view; facing right; needle limbs; lime bio-glow #a9eb55; limited palette; strong dark outline; #ff00ff background; no weapons; fits ~13x11px after trim.
```

---

## Brood Carrier (24×20)

```
Premium hand-crafted pixel art for a top-down 2D action-defense game; exactly one bloated brood carrier spider with egg sac; strict top-down three-quarter orthographic view; facing right; lime and rust palette; strong dark outline; #ff00ff background; no weapons; fits ~24x20px after trim.
```

---

## Guardian (58×54)

```
Premium hand-crafted pixel art for a top-down 2D action-defense game; exactly one large purple bio-mechanical boss spider with crown back plates and glowing energy core; strict top-down three-quarter orthographic view; facing right; palette purple #9a4ecf, energy #ff6ecf, dark chitin #2a1a32; strong dark outline; #ff00ff background; no firearms; fits ~58x54px after trim.
```
