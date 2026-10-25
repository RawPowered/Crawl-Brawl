# Patch 4.11 Mutant Bestiary Art Direction

## Gameplay contract

- The art changes threat recognition, not combat balance.
- Collision radii, health, damage, speed, routing, rewards, and spawn composition remain unchanged from Patch 4.10.
- Each role must remain readable in motion against hive, tunnel, and bunker materials at the 640×360 viewport.
- Runtime assets are transparent PNGs loaded directly from bytes so a clean extraction does not depend on Godot import caches.

## Role silhouettes

| Role | Visual read | Runtime presentation |
|---|---|---|
| Broodling | Needle-limbed larval mutant | 13×11, jittering sprint, lime bio-glow |
| Swarmer | Balanced decayed hunter | 22×21, directional scuttle |
| Leaper | Long rear legs and wedge body | 27×21, compressed windup pose |
| Spitter | Swollen acid reservoir and nozzle mouth | 24×24, toxic aura and target-facing shot |
| Brute | Broad rust-plated tank silhouette | 40×32, heavy lunge |
| Guardian | Crown-backed purple bio-mechanical boss | 58×54, energy-core pulse and threat ring |

## Generation prompt pattern

All six source images used the built-in OpenAI image-generation workflow with this production pattern:

> Premium hand-crafted pixel art for a top-down 2D action-defense game; exactly one mutant zombie spider; strict top-down three-quarter orthographic view; facing right; full body and every limb visible; limited palette; strong dark outline; isolated on a perfectly flat solid #ff00ff chroma-key background; no scenery, shadow, text, UI, watermark, cropped limbs, or magenta inside the creature.

The role-specific anatomy in the table above was appended to that shared prompt. The generated sources were chroma-keyed, alpha-validated, trimmed, palette-reduced, and resized into the six files under `assets/art/mobs/`.
