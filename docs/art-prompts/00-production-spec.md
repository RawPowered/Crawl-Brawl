# Art Prompt Production Spec

Shared rules for every ChatGPT generation in this folder.

## Generate

| Setting | Value |
|---------|-------|
| Style | Hand-crafted pixel art, 8–16 colors, strong 1px dark outline |
| Camera | Top-down three-quarter orthographic, facing **right** (mobs) or noted direction (player) |
| Background | Flat solid **#FF00FF** — no shadow, floor, gradient, or magenta inside subject |
| Source size | **1024×1024** (mobs) or **512×512** (player) |
| Subject | One only, centered, full body, no cropped limbs |
| Weapons | **None in source art** — empty hands / organic emitters only |

## Runtime cut (after download)

| Asset | Runtime canvas | Importer |
|-------|----------------|----------|
| Skirmisher | 22×21 | `python tools/import_mob_sprites.py` |
| Striker | 27×21 | ↑ |
| Artillery | 24×24 | ↑ |
| Bulwark | 40×32 | ↑ |
| Player direction/portrait | 28×30 | `python tools/import_player_sprites.py --passive sheet.png [--active sheet.png]` |

4×5 sheet order: rows `survey|foundry|containment|veteran`; columns `down|right|up|left|portrait`.

Passive PNGs: `{style}_{direction}.png`, `{style}.png`  
Active PNGs: `{style}_{direction}_active.png` (combat aim pose, empty hands)

Pipeline: perimeter-sampled edge chroma cleanup → connected-subject extraction → nearest-neighbor fit with transparent padding → validate dimensions/background/alpha → save PNG.

## Mob output paths

`assets/art/mobs/biomes/{biome}/{archetype}_runtime.png`

Archetypes: `skirmisher`, `striker`, `artillery`, `bulwark`

## Global mob output paths (2×1 sheet, odd canvases)

| Mob | Canvas | File |
|-----|--------|------|
| Broodling | 13×11 | `assets/art/mobs/broodling_runtime.png` |
| Brood Carrier | 24×20 | `assets/art/mobs/brood_carrier_runtime.png` |
| Guardian | 58×54 | `assets/art/mobs/guardian_runtime.png` |

```bash
python tools/import_mob_sprites.py --global path/to/global_sheet.png
```

## Player output paths

`assets/art/player/{style}_{direction}.png` — styles: `survey`, `foundry`, `containment`, `veteran`

## Player weapon overlay zones (keep empty on 28×30)

| Direction | Rect (x, y, w, h) |
|-----------|-------------------|
| right | 18, 11, 8, 7 |
| left | 2, 11, 8, 7 |
| up | 11, 2, 9, 8 |
| down | 11, 19, 9, 8 |

## Mob prefix (append creature line to every mob prompt)

```
Premium hand-crafted pixel art for a top-down 2D action-defense game; exactly one creature; strict top-down three-quarter orthographic view; facing right; full body and every limb visible; limited palette; strong dark outline; isolated on perfectly flat solid #ff00ff chroma-key background; no scenery, shadow, text, UI, watermark, cropped limbs, or magenta inside the creature. Empty hands / natural appendages only — no firearms or held weapons. Generate at 1024x1024. After trim fit within {W}x{H} pixels.
```
