from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
MOBS = ROOT / "assets" / "art" / "mobs" / "biomes"
OUTPUT = ROOT / "artifacts" / "biome_phase5_audit"
ARCHETYPES = ["skirmisher", "striker", "artillery", "bulwark"]
HEADERS = ["SKIRMISHER", "STRIKER", "ARTILLERY", "BULWARK"]
BIOMES = [
    ("TUNNEL CRUST", "tunnel", [56, 24, 14, 6], "STONE BRACE", (138, 117, 104)),
    ("HIVE BAND", "hive", [62, 22, 12, 4], "BROOD RUSH", (155, 99, 143)),
    ("BUNKER SHELL", "bunker", [40, 20, 30, 10], "SAPPER PROTOCOL", (99, 136, 146)),
    ("CRYSTAL CAVERN", "crystal", [38, 36, 18, 8], "PRISM SHOT", (101, 191, 210)),
    ("FOUNDRY DEPTHS", "foundry", [34, 20, 22, 24], "HEAT STRIDE", (189, 116, 72)),
    ("SULFUR BOG", "sulfur", [40, 18, 34, 8], "TOXIC REACH", (154, 170, 71)),
    ("IRON STRATA", "iron", [38, 18, 18, 26], "MAGNETIC MASS", (154, 101, 78)),
]


def main() -> None:
    width, height = 1120, 660
    image = Image.new("RGBA", (width, height), (5, 12, 16, 255))
    draw = ImageDraw.Draw(image)
    font = ImageFont.load_default()
    draw.text((18, 14), "PHASE 5 // BIOME ENEMY ECOLOGY", font=font, fill=(222, 241, 244, 255))
    draw.text((18, 31), "LATE-WAVE ROLE WEIGHTS + ONE RESTRAINED HOME TRAIT // SPAWN IDENTITY PERSISTS ACROSS BORDERS", font=font, fill=(105, 153, 163, 255))
    x_roles = [265, 440, 615, 790]
    for x, header in zip(x_roles, HEADERS):
        draw.text((x, 59), header, font=font, fill=(132, 177, 185, 255))
    draw.text((950, 59), "ECOLOGY TRAIT", font=font, fill=(132, 177, 185, 255))

    row_top, row_height = 78, 80
    for row, (name, slug, weights, trait, accent) in enumerate(BIOMES):
        y = row_top + row * row_height
        draw.rectangle((12, y, width - 12, y + row_height - 6), fill=(9, 20, 25, 255), outline=(*accent, 165))
        draw.rectangle((12, y, 18, y + row_height - 6), fill=(*accent, 255))
        draw.text((28, y + 17), name, font=font, fill=(224, 234, 232, 255))
        draw.text((28, y + 36), f"MIX {'/'.join(str(value) for value in weights)}", font=font, fill=(*accent, 255))
        for column, archetype in enumerate(ARCHETYPES):
            sprite = Image.open(MOBS / slug / f"{archetype}_runtime.png").convert("RGBA")
            scale = 2 if archetype != "bulwark" else 1
            sprite = sprite.resize((sprite.width * scale, sprite.height * scale), Image.Resampling.NEAREST)
            center_x = x_roles[column] + 38
            image.alpha_composite(sprite, (center_x - sprite.width // 2, y + 34 - sprite.height // 2))
            bar_x, bar_y = x_roles[column] + 76, y + 26
            draw.rectangle((bar_x, bar_y, bar_x + 62, bar_y + 8), fill=(18, 34, 39, 255), outline=(53, 78, 84, 255))
            draw.rectangle((bar_x + 1, bar_y + 1, bar_x + 1 + weights[column], bar_y + 7), fill=(*accent, 230))
            draw.text((bar_x + 20, bar_y + 15), f"{weights[column]:02d}%", font=font, fill=(186, 210, 213, 255))
        draw.text((950, y + 29), trait, font=font, fill=(*accent, 255))
    draw.text((18, 641), "COMMON READABILITY CONTRACT // SAME FOUR ROLE SILHOUETTES, TELEGRAPHS, HIT FLASH, PROJECTILE SIZE, AND BASE DAMAGE", font=font, fill=(107, 153, 162, 255))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(OUTPUT / "phase5_enemy_ecology_preview.png")


if __name__ == "__main__":
    main()
