# Pack: Bunker Shell

**Biome slug:** `bunker`  
**Palette:** gunmetal `#6a7a88`, steel `#9aa8b8`, amber `#e7b46a`  
**Output:** `assets/art/mobs/biomes/bunker/{archetype}_runtime.png`

**Import (2×2 pack sheet, top-left → bottom-right):**
```bash
python tools/import_mob_sprites.py bunker path/to/bunker_pack_source.png
```
Quadrant order: skirmisher | striker / artillery | bulwark. Archives source as `bunker_pack_source.png`.

Use mob prefix from `00-production-spec.md`.

---

## Skirmisher — Scrap Runner (22×21)

Salvaged wheeled maintenance drone, bent plate and cable, low and fast, no weapon arms.

---

## Striker — Jumpjet Drone (27×21)

Compact hopper bot, side vent thrusters, folded landing legs, mid-crouch. Exhaust orange `#ff9b45`.

---

## Artillery — Arc Relay Crawler (24×24)

Tracked scrap bot, shoulder-mounted energy emitter dome, empty manipulator arms — no handheld gun. Emitter cyan `#58d8ef`.

---

## Bulwark — Plate Walker (40×32)

Heavy exo-frame walker, blank arm sockets, layered bunker steel plates. Steel `#82969a`.
