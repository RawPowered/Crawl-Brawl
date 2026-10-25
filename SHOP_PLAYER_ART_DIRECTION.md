# Patch 4.12 Shop and Player Art Direction

## Runtime goal

- Replace the procedural player body with a readable project-local survivor sprite.
- Keep the existing collision radius, movement, combat, and camera behavior unchanged.
- Give every Core terminal item an icon that communicates category before the label is read.
- Support cosmetic-only player styles with persistent unlock and equipped state.

## Player source prompt

Create a horizontal row of four full-body, top-down three-quarter-view pixel-art underground survivors with the same silhouette and pose: cyan Survey Suit, orange Foundry Suit, violet Containment Suit, and white-gold Frontier Veteran. Use crisp hard pixels, strong outlines, identical scale, right-facing weapons, no text, no shadow, and a uniform removable green background. Each survivor must remain readable near 24×24 pixels.

## Directional derivative prompt

Using the approved four-style sheet as the identity reference, rebuild the same suits in a strict 4×4 grid. Rows are Survey, Foundry, Containment, and Veteran; columns are down, right, up, and left. Preserve scale, armor identity, palette, and pixel treatment. Each firearm must point in the same direction as the character. Use no labels or grid lines and retain the uniform removable green background.

## Shop source prompt

Create a strict 6×5 pixel-art atlas with thirty separate centered inventory icons: five weapons, general and weapon-specific ammunition, medical care, turrets and engineering, Core structures, raw minerals, refined components, Foundry equipment, and a cosmetic suit. Use crisp hard pixels, strong silhouettes, a cohesive cyan/orange/gold/steel palette, no text or frames, and a uniform removable magenta background.

## Integration rules

- Runtime PNGs decode directly from packaged bytes and must not depend on Godot import cache state.
- Player styles are cosmetic only; no style modifies health, speed, hitbox, damage, economy, or enemy targeting.
- The active sprite selects a real down, right, up, or left frame from aim direction while its collision and weapon origin remain controlled by gameplay code.
- Shop icons are selected from the actual item label/category and scale inside existing controller-reachable buttons.
- Missing art must fall back safely to the prior procedural player or a generic shop icon.
