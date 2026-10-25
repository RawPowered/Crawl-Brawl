#!/usr/bin/env python3
"""Generate grid-aligned biome floor atlases and prop sprites for Crawl Brawl."""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ENV_DIR = ROOT / "assets" / "art" / "environment"
WORLD_DIR = ROOT / "assets" / "art" / "world"

ATLAS_SIZE = 320
PATCH_SIZE = 32
TILE_SIZE = 16
PATCH_COLUMNS = ATLAS_SIZE // PATCH_SIZE


def clamp(value: int, low: int, high: int) -> int:
    return max(low, min(high, value))


def mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(clamp(int(a[i] + (b[i] - a[i]) * t), 0, 255) for i in range(3))


def patch_seed(name: str, px: int, py: int) -> random.Random:
    seed = sum(ord(ch) * (idx + 17) for idx, ch in enumerate(name))
    seed ^= px * 92837111 ^ py * 689287499
    return random.Random(seed & 0xFFFFFFFF)


def fill_patch(image: Image.Image, px: int, py: int, painter) -> None:
    origin = (px * PATCH_SIZE, py * PATCH_SIZE)
    patch = Image.new("RGB", (PATCH_SIZE, PATCH_SIZE), (0, 0, 0))
    painter(patch, px, py)
    image.paste(patch, origin)


def paint_crystal_patch(patch: Image.Image, px: int, py: int) -> None:
    rng = patch_seed("crystal", px, py)
    base = (20, 28, 34)
    rock = (34, 44, 52)
    accent = (66, 118, 132)
    draw = ImageDraw.Draw(patch)
    for ty in range(2):
        for tx in range(2):
            tile_origin = (tx * TILE_SIZE, ty * TILE_SIZE)
            tile_color = mix(base, rock, rng.random() * 0.35)
            draw.rectangle(
                [tile_origin[0], tile_origin[1], tile_origin[0] + TILE_SIZE - 1, tile_origin[1] + TILE_SIZE - 1],
                fill=tile_color,
            )
            if rng.random() < 0.45:
                x0 = tile_origin[0] + rng.randint(2, TILE_SIZE - 4)
                y0 = tile_origin[1] + rng.randint(2, TILE_SIZE - 4)
                draw.line((x0, y0, x0 + rng.randint(1, 3), y0 + rng.randint(1, 3)), fill=mix(accent, rock, 0.35), width=1)
    if rng.random() < 0.28:
        cx = rng.randint(8, PATCH_SIZE - 8)
        cy = rng.randint(8, PATCH_SIZE - 8)
        draw.polygon(
            [(cx, cy - 4), (cx + 3, cy), (cx, cy + 4), (cx - 3, cy)],
            fill=mix(accent, rock, 0.25),
            outline=mix(accent, base, 0.5),
        )


def paint_foundry_patch(patch: Image.Image, px: int, py: int) -> None:
    rng = patch_seed("foundry", px, py)
    base = (28, 26, 24)
    plate = (52, 48, 44)
    seam = (74, 68, 62)
    rust = (92, 58, 40)
    draw = ImageDraw.Draw(patch)
    for ty in range(2):
        for tx in range(2):
            origin = (tx * TILE_SIZE, ty * TILE_SIZE)
            draw.rectangle(
                [origin[0], origin[1], origin[0] + TILE_SIZE - 1, origin[1] + TILE_SIZE - 1],
                fill=mix(base, plate, 0.2 + rng.random() * 0.25),
            )
            if ty == 0 or tx == 0:
                draw.line((origin[0], origin[1], origin[0] + TILE_SIZE - 1, origin[1]), fill=mix(seam, plate, 0.2), width=1)
    for _ in range(rng.randint(1, 2)):
        x = rng.randint(0, PATCH_SIZE - 10)
        y = rng.randint(0, PATCH_SIZE - 3)
        draw.rectangle([x, y, x + rng.randint(7, 11), y + 1], fill=mix(seam, rust, rng.random() * 0.35))


def paint_sulfur_patch(patch: Image.Image, px: int, py: int) -> None:
    rng = patch_seed("sulfur", px, py)
    bog = (34, 42, 18)
    crust = (96, 108, 34)
    acid = (168, 198, 52)
    pool = (18, 24, 12)
    draw = ImageDraw.Draw(patch)
    for ty in range(2):
        for tx in range(2):
            origin = (tx * TILE_SIZE, ty * TILE_SIZE)
            draw.rectangle(
                [origin[0], origin[1], origin[0] + TILE_SIZE - 1, origin[1] + TILE_SIZE - 1],
                fill=mix(bog, crust, rng.random() * 0.55),
            )
            for _ in range(rng.randint(1, 3)):
                bx = origin[0] + rng.randint(1, TILE_SIZE - 4)
                by = origin[1] + rng.randint(1, TILE_SIZE - 4)
                draw.rectangle([bx, by, bx + 2, by + 2], fill=mix(crust, acid, rng.random()))
    if rng.random() < 0.45:
        draw.ellipse([8, 8, 24, 24], fill=mix(pool, bog, 0.35))
        draw.ellipse([12, 12, 20, 20], fill=mix(acid, (220, 240, 120), 0.25))


def paint_iron_patch(patch: Image.Image, px: int, py: int) -> None:
    rng = patch_seed("iron", px, py)
    dark = (28, 30, 34)
    band = (72, 76, 82)
    rust = (118, 62, 38)
    draw = ImageDraw.Draw(patch)
    for ty in range(2):
        for tx in range(2):
            origin = (tx * TILE_SIZE, ty * TILE_SIZE)
            shade = mix(dark, band, 0.15 + ((px + ty + tx) % 3) * 0.12)
            draw.rectangle(
                [origin[0], origin[1], origin[0] + TILE_SIZE - 1, origin[1] + TILE_SIZE - 1],
                fill=shade,
            )
            draw.line((origin[0], origin[1] + TILE_SIZE // 2, origin[0] + TILE_SIZE - 1, origin[1] + TILE_SIZE // 2), fill=mix(band, dark, 0.35), width=1)
    for _ in range(rng.randint(2, 4)):
        x = rng.randint(0, PATCH_SIZE - 1)
        draw.line((x, 0, x + rng.randint(-2, 2), PATCH_SIZE - 1), fill=mix(rust, band, rng.random() * 0.4), width=1)


PAINTERS = {
    "crystal": paint_crystal_patch,
    "foundry": paint_foundry_patch,
    "sulfur": paint_sulfur_patch,
    "iron": paint_iron_patch,
}


def build_atlas(name: str) -> Image.Image:
    atlas = Image.new("RGB", (ATLAS_SIZE, ATLAS_SIZE), (0, 0, 0))
    painter = PAINTERS[name]
    for py in range(PATCH_COLUMNS):
        for px in range(PATCH_COLUMNS):
            fill_patch(atlas, px, py, painter)
    return atlas


def build_phase4_source(atlases: dict[str, Image.Image]) -> Image.Image:
    strip_height = ATLAS_SIZE
    sheet = Image.new("RGB", (ATLAS_SIZE, strip_height * len(atlases)), (0, 0, 0))
    for index, name in enumerate(["crystal", "foundry", "sulfur", "iron"]):
        sheet.paste(atlases[name], (0, index * strip_height))
    draw = ImageDraw.Draw(sheet)
    for index, name in enumerate(["crystal", "foundry", "sulfur", "iron"]):
        draw.text((4, index * strip_height + 4), name.upper(), fill=(220, 220, 220))
    return sheet


def build_crystal_shard() -> Image.Image:
    image = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.polygon([(8, 1), (12, 6), (10, 14), (6, 14), (4, 6)], fill=(120, 220, 240, 230))
    draw.polygon([(8, 3), (10, 6), (9, 12), (7, 12), (6, 6)], fill=(210, 250, 255, 220))
    return image


def build_sulfur_vent() -> Image.Image:
    image = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.ellipse([3, 8, 13, 14], fill=(36, 44, 18, 255))
    draw.ellipse([5, 4, 11, 10], fill=(170, 210, 58, 230))
    draw.ellipse([6, 5, 10, 9], fill=(230, 250, 140, 210))
    return image


def build_slag_heap() -> Image.Image:
    image = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.polygon([(2, 13), (8, 4), (14, 13)], fill=(92, 54, 30, 255))
    draw.polygon([(4, 13), (8, 6), (12, 13)], fill=(150, 78, 36, 240))
    draw.line((5, 10, 11, 8), fill=(240, 150, 64, 220), width=1)
    return image


def write_png(path: Path, image: Image.Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    print(f"wrote {path.relative_to(ROOT)} ({image.size[0]}x{image.size[1]} {image.mode})")


def main() -> None:
    atlases: dict[str, Image.Image] = {}
    for name in PAINTERS:
        atlas = build_atlas(name)
        atlases[name] = atlas
        write_png(ENV_DIR / f"{name}_material_phase3.png", atlas)

    write_png(ENV_DIR / "phase4_environment_source.png", build_phase4_source(atlases))
    write_png(WORLD_DIR / "crystal_shard_runtime.png", build_crystal_shard())
    write_png(WORLD_DIR / "sulfur_vent_runtime.png", build_sulfur_vent())
    write_png(WORLD_DIR / "slag_heap_runtime.png", build_slag_heap())


if __name__ == "__main__":
    main()
