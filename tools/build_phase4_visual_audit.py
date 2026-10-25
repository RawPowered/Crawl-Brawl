from __future__ import annotations

import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ENV = ROOT / "assets" / "art" / "environment"
WORLD = ROOT / "assets" / "art" / "world"
OUTPUT = ROOT / "artifacts" / "biome_phase4_audit"

BIOMES = [
    ("TUNNEL CRUST", "tunnel", [16, 35, 37, 33, 82, 56], [41, 50, 55], (155, 143, 130), (224, 168, 97), 42,
     [("rubble", (-1, 0), (-3, 3)), ("crate", (0, 0), (2, 1)), ("lamp", (1, -1), (4, -2))]),
    ("HIVE BAND", "hive", [34, 17, 35, 74, 44, 86], [90, 31, 70], (188, 121, 182), (203, 114, 200), 96,
     [("eggs", (-1, 0), (-3, 2)), ("eggs", (0, 1), (2, 4)), ("web", (1, -1), (4, -3)), ("acid", (1, 1), (-2, 2))]),
    ("BUNKER SHELL", "bunker", [0, 1, 19, 10, 15, 9], [35, 89, 26], (118, 153, 160), (115, 200, 215), 28,
     [("conduit", (-1, 0), (-4, 1)), ("grate", (0, 0), (1, 3)), ("conduit", (1, 0), (4, 1)), ("lamp", (1, -1), (3, -3))]),
    ("CRYSTAL CAVERN", "crystal", [0, 1, 80, 10, 96, 78], [97, 49, 2], (121, 217, 238), (128, 231, 255), 76,
     [("crystal_shard", (-1, 1), (-4, 3)), ("crystal_shard", (0, 0), (1, -2)), ("crystal_shard", (1, 1), (4, 4))]),
    ("FOUNDRY DEPTHS", "foundry", [20, 2, 0, 77, 71, 88], [82, 14, 29], (219, 129, 80), (255, 136, 76), 54,
     [("slag_heap", (-1, 1), (-4, 3)), ("grate", (0, 0), (0, 2)), ("conduit", (1, 0), (4, -1))]),
    ("SULFUR BOG", "sulfur", [98, 80, 39, 99, 6, 10], [7, 60, 91], (183, 203, 84), (198, 226, 82), 105,
     [("sulfur_vent", (-1, 0), (-4, 1)), ("acid", (0, 1), (0, 4)), ("sulfur_vent", (1, -1), (4, -3))]),
    ("IRON STRATA", "iron", [90, 99, 87, 78, 74, 31], [15, 14, 19], (162, 116, 99), (212, 128, 93), 38,
     [("rubble", (-1, 0), (-4, 2)), ("slag_heap", (0, 1), (1, 4)), ("grate", (1, 0), (4, 1))]),
]


def macro(atlas: Image.Image, index: int) -> Image.Image:
    x, y = (index % 10) * 32, (index // 10) * 32
    return atlas.crop((x, y, x + 32, y + 32))


def paste_center(canvas: Image.Image, sprite: Image.Image, position: tuple[int, int]) -> None:
    if sprite.width > 24 or sprite.height > 24:
        sprite.thumbnail((24, 24), Image.Resampling.NEAREST)
    canvas.alpha_composite(sprite, (position[0] - sprite.width // 2, position[1] - sprite.height // 2))


def main() -> None:
    output = Image.new("RGBA", (1280, 468), (5, 12, 16, 255))
    draw = ImageDraw.Draw(output)
    font = ImageFont.load_default()
    panel_w, panel_h, header_h = 320, 210, 25
    for biome_id, (name, key, base_pool, formation_pool, mote, light, density, composition) in enumerate(BIOMES):
        col = biome_id % 4
        row = biome_id // 4
        x0 = col * panel_w
        if row == 1:
            x0 += panel_w // 2
        y0 = 10 + row * (panel_h + 18)
        base = Image.open(ENV / f"{key}_material_base_phase1.png").convert("RGBA")
        ornate = Image.open(ENV / f"{key}_material_formation_phase2.png").convert("RGBA")
        rng = random.Random(418418 + biome_id * 977)
        panel = Image.new("RGBA", (panel_w, 160), (12, 20, 24, 255))
        for ty in range(5):
            for tx in range(10):
                panel.alpha_composite(macro(base, rng.choice(base_pool)), (tx * 32, ty * 32))
        for formation_x, formation_y, atlas_index in [(64, 32, formation_pool[0]), (96, 32, formation_pool[1]), (224, 96, formation_pool[2])]:
            patch = macro(ornate, atlas_index)
            patch.putalpha(patch.getchannel("A").point(lambda value: int(value * 0.56)))
            panel.alpha_composite(patch, (formation_x, formation_y))
        grade = Image.new("RGBA", panel.size, (*light, 9))
        panel = Image.alpha_composite(panel, grade)
        anchor = (160, 82)
        glow = Image.new("RGBA", panel.size, (0, 0, 0, 0))
        glow_draw = ImageDraw.Draw(glow)
        for _, cell_offset, pixel_offset in composition:
            px = anchor[0] + cell_offset[0] * 16 + pixel_offset[0]
            py = anchor[1] + cell_offset[1] * 16 + pixel_offset[1]
            glow_draw.ellipse((px - 22, py - 22, px + 22, py + 22), fill=(*light, 13))
            glow_draw.ellipse((px - 11, py - 11, px + 11, py + 11), fill=(*light, 18))
        panel = Image.alpha_composite(panel, glow)
        for prop_name, cell_offset, pixel_offset in composition:
            sprite = Image.open(WORLD / f"{prop_name}_runtime.png").convert("RGBA")
            position = (anchor[0] + cell_offset[0] * 16 + pixel_offset[0], anchor[1] + cell_offset[1] * 16 + pixel_offset[1])
            paste_center(panel, sprite, position)
        mote_count = max(1, round(density / 18))
        panel_draw = ImageDraw.Draw(panel)
        for _ in range(mote_count):
            px, py = rng.randrange(8, panel_w - 8), rng.randrange(8, 152)
            panel_draw.point((px, py), fill=(*mote, 160))
            if rng.randrange(3) == 0:
                panel_draw.point((px, py + 1), fill=(*mote, 80))
        draw.rectangle((x0, y0, x0 + panel_w - 1, y0 + header_h + 160), fill=(9, 18, 22, 255), outline=(*light, 150))
        draw.text((x0 + 8, y0 + 7), name, font=font, fill=(220, 238, 240, 255))
        draw.text((x0 + 191, y0 + 7), f"MOTES {density:03d}/1000", font=font, fill=(*mote, 255))
        output.alpha_composite(panel, (x0, y0 + header_h))
        draw.rectangle((x0 + 297, y0 + 6, x0 + 307, y0 + 16), fill=(*light, 255))
    draw.text((12, 448), "PHASE 4 PROFILE AUDIT // QUIET BASE + FORMATION ANCHOR + MULTI-PROP LANDMARK + LOCAL AIR/LIGHT", font=font, fill=(116, 160, 168, 255))
    OUTPUT.mkdir(parents=True, exist_ok=True)
    output.convert("RGB").save(OUTPUT / "phase4_atmosphere_landmark_preview.png")
    squint = output.convert("L").filter(ImageFilter.GaussianBlur(3.0)).convert("RGB")
    squint.save(OUTPUT / "phase4_atmosphere_landmark_preview_squint.png")


if __name__ == "__main__":
    main()
