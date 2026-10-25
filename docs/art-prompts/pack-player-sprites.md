# Pack: Player Sprites

**Runtime canvas:** 28×30 px (exact)  
**Generate at:** 512×512 per cell (sheet 1024×682)  
**Output:** `assets/art/player/{style}_{direction}.png` (+ `{style}_{direction}_active.png`)  
**Import:** `python tools/import_player_sprites.py --passive passive.png --active active.png`

4×5 sheet layout: rows `survey`, `foundry`, `containment`, `veteran`; columns `down`, `right`, `up`, `left`, `portrait`.

Styles: `survey`, `foundry`, `containment`, `veteran`  
Directions: `down`, `right`, `up`, `left`  
Portraits: `{style}.png` (facing right)

Weapon overlay zones — keep empty on final canvas (see `00-production-spec.md`).

---

## Shared prefix

Replace `{DIRECTION}` and append style line:

```
Premium hand-crafted pixel art for a top-down 2D action-defense game; exactly one humanoid miner in a sealed exploration suit; strict top-down three-quarter orthographic view; facing {DIRECTION}; full body visible; limited palette; strong dark outline; isolated on perfectly flat solid #ff00ff; no scenery, shadow, text, UI, watermark. Both hands completely empty — no gun, tool, or weapon. Leave clear space at the forward grip side for a runtime weapon overlay. Generate at 512x512. After trim fit within 28x30 pixels.
```

---

## Survey (teal `#4a9a9a`, visor `#7ec4d8`)

| File | Direction | Note |
|------|-----------|------|
| `survey_down.png` | down | Compact visor, utility belt |
| `survey_right.png` | right | Empty right hip (18–25, 11–17) |
| `survey_up.png` | up | Empty upper torso (11–19, 2–9) |
| `survey_left.png` | left | Empty left hip (2–9, 11–17) |
| `survey.png` | right | Portrait, empty hands |

---

## Foundry (orange `#c87848`, visor `#ffae4f`)

| File | Direction | Note |
|------|-----------|------|
| `foundry_down.png` | down | Heat shield plates |
| `foundry_right.png` | right | Empty right hip |
| `foundry_up.png` | up | Empty upper torso |
| `foundry_left.png` | left | Empty left hip |
| `foundry.png` | right | Portrait |

---

## Containment (yellow `#d8c848`, collar `#a89828`)

| File | Direction | Note |
|------|-----------|------|
| `containment_down.png` | down | Sealed collar, tank pack |
| `containment_right.png` | right | Empty right hip |
| `containment_up.png` | up | Empty upper torso |
| `containment_left.png` | left | Empty left hip |
| `containment.png` | right | Portrait |

---

## Veteran (olive `#6a7a4a`, patch `#8a8a68`)

| File | Direction | Note |
|------|-----------|------|
| `veteran_down.png` | down | Worn patches, heavy boots |
| `veteran_right.png` | right | Empty right hip |
| `veteran_up.png` | up | Empty upper torso |
| `veteran_left.png` | left | Empty left hip |
| `veteran.png` | right | Portrait |
