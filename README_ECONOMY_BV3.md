# Crawl Brawl Economy BV3

This pass repairs the economy loop without changing SAVE_VERSION 14.

## Fixed blockers

- `heavy_doorway` is now part of the persistent construction unlock registry. Older saves that already researched it can restore the saved `true` value instead of silently dropping the key on load.
- Personal Base fabrication no longer checks an obsolete `12` material-capacity weight. Deployables use stack slots, so the gate now checks for a real deployable stack destination.
- Deployable shop previews no longer add and then remove a real kit to test inventory room. The preview is now a pure capacity query, preventing a full inventory preview from consuming an existing kit.
- The free Foundry MK1 kit stays pending when there is no deployable slot instead of being silently lost.
- Doorway upgrade prices and material requirements now live in `upgrade_economy.gd` instead of being duplicated in UI and purchase code.

## Wall economy

Every natural wall now has an economic output tied to its biome.

| Biome | Primary | Secondary | Main use |
| --- | --- | --- | --- |
| Tunnel Crust | Granite | Copper | Stone blocks + early Bronze |
| Hive Band | Basalt | Sulfur | Reinforced blocks + explosives |
| Bunker Shell | Granite | Iron | Stone + Steel |
| Crystal Cavern | Quartz | Energy Crystal | Optics + Crystal cores |
| Foundry Depths | Iron | Coal | Steel + Foundry fuel |
| Sulfur Bog | Sulfur | Coal | Explosive compound |
| Iron Strata | Iron | Titanium | Steel + Titanium plating |

Mining MK1 converts natural walls directly into low-volume raw biome salvage. Mining MK2+ preserves the wall as a reusable biome block when a stack can accept it. Wall blocks can then be placed, recycled at a Core into biome raw feedstock, or sold directly at a Core.

Player-placed walls are protected against value duplication: re-mining one does not award the normal per-cell scrap, mineral discovery, or another natural-wall salvage roll. It recovers the original block; if block inventory is full, its value falls back to recycled raw material/pickup rather than disappearing.

## Playability balance

Foundry research: MK1 $300, MK2 $900, MK3 $2200.

Construction research and fabrication were compressed so industry can unlock through ordinary mining/combat rather than long cash-only grinds. Heavy Doorway is now an early-industry item (Stone + Bronze) rather than a late-game Titanium/Reinforced requirement. Advanced blast, explosive, rocket, laser, and upper Doorway upgrades still require higher Foundry tiers.

## Test priorities

1. Start/continue a save that has Heavy Doorway researched and verify it remains researched after save/reload.
2. Mine ordinary walls in at least Tunnel, Hive, Crystal, Sulfur, and Iron biomes.
3. With Mining MK1, verify raw wall salvage enters material capacity or drops when full.
4. With Mining MK2+, verify biome wall blocks stack and can be placed.
5. At a Core > Materials, verify `RECYCLE WALL BLOCKS` and `SELL WALL BLOCKS` appear and work.
6. Place then re-mine the same wall repeatedly and verify it does not generate mining credits/material profit.
7. Research Foundry MK1 with a completely full deployable inventory, free a slot, then open build selection and verify the pending free Foundry kit is delivered.
8. Research/craft/place Heavy Doorway, save/reload, then upgrade it through Level 2 and Level 3.
9. Craft Personal Base with low/free material capacity but one valid deployable slot and verify the stale 12-capacity gate is gone.

## Validation status

Static source checks are complete. A real Godot 4.7.1 import and gameplay pass remain pending on the Windows project machine; use the Crawl Brawl launcher as the compile/runtime gate before promoting this hotfix.
