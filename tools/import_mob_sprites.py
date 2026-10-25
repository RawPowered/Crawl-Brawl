#!/usr/bin/env python3
"""Import biome mob runtime sprites from pack sheets, legacy art, or tinted placeholders."""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

from sheet_cut import (
    archive_source_png,
    assert_clean_runtime_sprite,
    assert_no_magenta,
    chroma_to_rgba,
    clear_background_color_pixels,
    crop_region,
    dominant_border_color,
    extract_subject_components,
    find_split_index,
    fit_canvas,
    sprite_density,
)

ROOT = Path(__file__).resolve().parents[1]
MOB_DIR = ROOT / "assets" / "art" / "mobs"
BIOME_DIR = MOB_DIR / "biomes"

ARCHETYPES = ("skirmisher", "striker", "artillery", "bulwark")
BIOMES = ("tunnel", "hive", "bunker", "crystal", "foundry", "sulfur", "iron")

PACK_QUADRANTS: tuple[tuple[str, int, int], ...] = (
    ("skirmisher", 0, 0),
    ("striker", 1, 0),
    ("artillery", 0, 1),
    ("bulwark", 1, 1),
)

LEGACY_BY_ARCHETYPE = {
    "skirmisher": "swarmer_runtime.png",
    "striker": "leaper_runtime.png",
    "artillery": "spitter_runtime.png",
    "bulwark": "brute_runtime.png",
}

TARGET_SIZE_BY_ARCHETYPE = {
    "skirmisher": (22, 21),
    "striker": (27, 21),
    "artillery": (24, 24),
    "bulwark": (40, 32),
}

GLOBAL_MOB_SLOTS: tuple[tuple[str, str, tuple[int, int], float, float, float, float], ...] = (
    ("broodling", "broodling_runtime.png", (13, 11), 0.0, 0.0, 0.5, 0.5),
    ("brood_carrier", "brood_carrier_runtime.png", (24, 20), 0.5, 0.0, 1.0, 0.5),
    ("guardian", "guardian_runtime.png", (58, 54), 0.0, 0.5, 1.0, 1.0),
)

LABEL_BAND_RATIO = 0.16

BIOME_TINTS = {
    "tunnel": (0.78, 0.74, 0.68),
    "hive": (1.0, 1.0, 1.0),
    "bunker": (0.72, 0.78, 0.86),
    "crystal": (0.62, 0.88, 0.96),
    "foundry": (1.0, 0.72, 0.48),
    "sulfur": (0.82, 0.92, 0.38),
    "iron": (0.86, 0.62, 0.52),
}


def ensure_dirs() -> None:
    for biome in BIOMES:
        (BIOME_DIR / biome).mkdir(parents=True, exist_ok=True)


def load_rgba(path: Path) -> Image.Image:
    source = Image.open(path)
    if "A" in source.getbands():
        return source.convert("RGBA")
    return chroma_to_rgba(source.convert("RGB"))


def column_sprite_density(image: Image.Image, y_start: int) -> list[int]:
    return sprite_density(image, "column", y_start, image.height)


def row_sprite_density(image: Image.Image) -> list[int]:
    return sprite_density(image, "row", 0, image.width)


def detect_global_row_split(image: Image.Image) -> int:
    label_skip = int(image.height * LABEL_BAND_RATIO)
    body = image.crop((0, label_skip, image.width, image.height))
    density = row_sprite_density(body)
    search_start = int(len(density) * 0.35)
    search_end = int(len(density) * 0.55)
    local_split = find_split_index(density, search_start, search_end)
    return label_skip + local_split


def detect_pack_splits(image: Image.Image) -> tuple[int, int]:
    # Biome packs have an explicit 2x2 contract. Do not infer boundaries from
    # sprite density: large/effect-heavy mobs legitimately cross visual centers.
    return image.width // 2, image.height // 2


def fit_sprite(image: Image.Image, canvas: tuple[int, int]) -> Image.Image:
    return fit_canvas(image, canvas, padding=1)


def tint_sprite(image: Image.Image, tint: tuple[float, float, float]) -> Image.Image:
    tinted = image.copy()
    pixels = tinted.load()
    for y in range(tinted.height):
        for x in range(tinted.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha <= 0:
                continue
            pixels[x, y] = (
                min(255, int(red * tint[0])),
                min(255, int(green * tint[1])),
                min(255, int(blue * tint[2])),
                alpha,
            )
    return tinted


def write_runtime(
    path: Path,
    image: Image.Image,
    expected_size: tuple[int, int],
    background_reference: tuple[int, int, int] | None = None,
) -> None:
    if background_reference is not None:
        clear_background_color_pixels(image, background_reference)
    assert_no_magenta(image, path.name)
    assert_clean_runtime_sprite(image, path.name, expected_size, background_reference)
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    print(f"wrote {path.relative_to(ROOT)}")


def migrate_hive() -> None:
    for archetype in ARCHETYPES:
        source = MOB_DIR / LEGACY_BY_ARCHETYPE[archetype]
        target = BIOME_DIR / "hive" / f"{archetype}_runtime.png"
        if not source.exists():
            raise FileNotFoundError(source)
        runtime = fit_sprite(load_rgba(source), TARGET_SIZE_BY_ARCHETYPE[archetype])
        write_runtime(target, runtime, TARGET_SIZE_BY_ARCHETYPE[archetype])
        print(f"normalized {target.relative_to(ROOT)}")


def extract_global_sprite(slot: Image.Image) -> Image.Image:
    return extract_subject_components(slot, keep_detached=False)


def import_global_mob_sheet(source_path: Path) -> None:
    source_path = source_path.resolve()
    if not source_path.exists():
        raise FileNotFoundError(source_path)

    archive = MOB_DIR / "global_mobs_pack_source.png"
    archive_source_png(source_path, archive)
    print(f"archived {archive.relative_to(ROOT)}")

    source_rgb = Image.open(source_path).convert("RGB")
    background_reference = dominant_border_color(source_rgb)
    sheet = chroma_to_rgba(source_rgb)
    row_split = detect_global_row_split(sheet)
    col_split = find_split_index(
        column_sprite_density(sheet, 0),
        int(sheet.width * 0.35),
        int(sheet.width * 0.65),
    )
    print(f"detected splits row={row_split} col={col_split}")

    for slot_name, target_name, canvas, left_ratio, top_ratio, right_ratio, bottom_ratio in GLOBAL_MOB_SLOTS:
        if top_ratio <= 0.0 and bottom_ratio <= 0.5:
            left = 0 if left_ratio <= 0.0 else col_split
            right = col_split if right_ratio <= 0.5 else sheet.width
            region = sheet.crop((left, 0, right, row_split))
        else:
            region = sheet.crop((0, row_split, sheet.width, sheet.height))
        sprite = extract_global_sprite(region)
        runtime = fit_sprite(sprite, canvas)
        write_runtime(MOB_DIR / target_name, runtime, canvas, background_reference)


def extract_sprite_from_quadrant(quadrant: Image.Image, keep_detached: bool) -> Image.Image:
    return extract_subject_components(quadrant, keep_detached=keep_detached)


def import_biome_pack_sheet(biome: str, source_path: Path) -> None:
    if biome not in BIOMES:
        raise ValueError(f"Unknown biome slug: {biome}")
    source_path = source_path.resolve()
    if not source_path.exists():
        raise FileNotFoundError(source_path)

    out_dir = BIOME_DIR / biome
    out_dir.mkdir(parents=True, exist_ok=True)
    archive = out_dir / f"{biome}_pack_source.png"
    archive_source_png(source_path, archive)
    print(f"archived {archive.relative_to(ROOT)}")

    source_rgb = Image.open(source_path).convert("RGB")
    background_reference = dominant_border_color(source_rgb)
    sheet = chroma_to_rgba(source_rgb)
    col_split, row_split = detect_pack_splits(sheet)
    print(f"detected splits row={row_split} col={col_split}")

    for archetype, col, row in PACK_QUADRANTS:
        left = 0 if col == 0 else col_split
        right = col_split if col == 0 else sheet.width
        top = 0 if row == 0 else row_split
        bottom = row_split if row == 0 else sheet.height
        quadrant = crop_region(sheet, left, top, right, bottom)
        sprite = extract_sprite_from_quadrant(quadrant, keep_detached=archetype == "artillery")
        runtime = fit_sprite(sprite, TARGET_SIZE_BY_ARCHETYPE[archetype])
        write_runtime(
            out_dir / f"{archetype}_runtime.png",
            runtime,
            TARGET_SIZE_BY_ARCHETYPE[archetype],
            background_reference,
        )


def generate_biome_placeholders() -> None:
    for biome in BIOMES:
        if biome == "hive":
            continue
        tint = BIOME_TINTS[biome]
        for archetype in ARCHETYPES:
            source = MOB_DIR / LEGACY_BY_ARCHETYPE[archetype]
            fitted = fit_sprite(load_rgba(source), TARGET_SIZE_BY_ARCHETYPE[archetype])
            runtime = tint_sprite(fitted, tint)
            write_runtime(
                BIOME_DIR / biome / f"{archetype}_runtime.png",
                runtime,
                TARGET_SIZE_BY_ARCHETYPE[archetype],
            )


def main() -> None:
    ensure_dirs()
    if len(sys.argv) >= 2 and sys.argv[1] == "--hive":
        migrate_hive()
        print("CRAWL_BRAWL_HIVE_MOBS_OK")
        return
    if len(sys.argv) >= 3 and sys.argv[1] == "--global":
        import_global_mob_sheet(Path(sys.argv[2]))
        print("CRAWL_BRAWL_GLOBAL_MOBS_OK")
        return
    if len(sys.argv) >= 3:
        import_biome_pack_sheet(sys.argv[1], Path(sys.argv[2]))
        print(f"CRAWL_BRAWL_BIOME_PACK_OK {sys.argv[1]}")
        return
    migrate_hive()
    generate_biome_placeholders()


if __name__ == "__main__":
    main()
