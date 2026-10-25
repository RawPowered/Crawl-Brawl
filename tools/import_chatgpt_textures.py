#!/usr/bin/env python3
"""Import ChatGPT-generated textures into grid-aligned runtime atlases."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DOWNLOADS = Path.home() / "Downloads"
ENV_DIR = ROOT / "assets" / "art" / "environment"
WORLD_DIR = ROOT / "assets" / "art" / "world"
ART_DIR = ROOT / "assets" / "art"
IMPORT_DIR = ENV_DIR / "import"
ATLAS_SIZE = 320
PATCH_SIZE = 16
MACRO_PATCH_SIZE = 16
CAVE_MACRO_PATCH_SIZE = 32
SUBPATCHES_PER_SIDE = 2
MACRO_PATCHES_PER_SIDE = ATLAS_SIZE // MACRO_PATCH_SIZE
CAVE_PATCHES_PER_SIDE = ATLAS_SIZE // CAVE_MACRO_PATCH_SIZE
PATCHES_PER_SIDE = ATLAS_SIZE // PATCH_SIZE
PROP_SIZE = 16
CHROMA_KEY = (255, 0, 255)
CHROMA_TOLERANCE = 48
CELL_GUTTER = 0.08
INNER_FLATTEN = 0.0
PHASE1_BASE_INSET = 5

FLOOR_ATLASES = {
    "ChatGPT Image Aug 7, 2026, 12_48_47 AM.png": ("tunnel_material_phase3.png", 10, 10),
    "ChatGPT Image Aug 7, 2026, 12_49_30 AM.png": ("hive_material_phase3.png", 10, 10),
    "ChatGPT Image Aug 7, 2026, 12_51_18 AM.png": ("bunker_material_phase3.png", 10, 10),
}

BIOME_STRIPS = [
    ("crystal_material_phase3.png", 0),
    ("foundry_material_phase3.png", 1),
    ("sulfur_material_phase3.png", 2),
    ("iron_material_phase3.png", 3),
]

BIOME_ATLAS_TARGETS = [
    "tunnel_material_phase3.png",
    "hive_material_phase3.png",
    "bunker_material_phase3.png",
    "crystal_material_phase3.png",
    "foundry_material_phase3.png",
    "sulfur_material_phase3.png",
    "iron_material_phase3.png",
]

PHASE1_CONTINUOUS_BASE_SOURCES = {
    "tunnel_material_phase3.png": "tunnel_material_runtime.png",
    "hive_material_phase3.png": "hive_material_runtime.png",
}

PROPS = {
    "ChatGPT Image Aug 7, 2026, 12_44_06 AM.png": "crystal_shard_runtime.png",
    "ChatGPT Image Aug 7, 2026, 12_45_51 AM.png": "sulfur_vent_runtime.png",
    "ChatGPT Image Aug 7, 2026, 12_46_41 AM.png": "slag_heap_runtime.png",
}

PHASE4_SOURCE = "ChatGPT Image Aug 7, 2026, 12_43_23 AM.png"
CAVE_SOURCE = "ChatGPT Image Aug 7, 2026, 12_52_44 AM.png"


def source_path(name: str) -> Path:
    download = DOWNLOADS / name
    if download.exists():
        return download
    archived = IMPORT_DIR / name.replace(", ", "_").replace(" ", "_")
    if archived.exists():
        return archived
    raise FileNotFoundError(name)


def ensure_dirs() -> None:
    for path in (ENV_DIR, WORLD_DIR, IMPORT_DIR):
        path.mkdir(parents=True, exist_ok=True)


def save_png(path: Path, image: Image.Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    print(f"wrote {path.relative_to(ROOT)} ({image.size[0]}x{image.size[1]} {image.mode})")


def archive_source(name: str) -> None:
    source = source_path(name)
    target = IMPORT_DIR / name.replace(", ", "_").replace(" ", "_")
    if source.resolve() != target.resolve() and not target.exists():
        Image.open(source).save(target, format="PNG")
        print(f"archived {target.relative_to(ROOT)}")


def crop_grid_cell(image: Image.Image, col: int, row: int, cols: int, rows: int) -> Image.Image:
    width, height = image.size
    left = col * width // cols
    top = row * height // rows
    right = (col + 1) * width // cols
    bottom = (row + 1) * height // rows
    if CELL_GUTTER > 0.0:
        trim_x = int((right - left) * CELL_GUTTER)
        trim_y = int((bottom - top) * CELL_GUTTER)
        left += trim_x
        top += trim_y
        right -= trim_x
        bottom -= trim_y
    return image.crop((left, top, right, bottom))


def flatten_subpatch(subcell: Image.Image) -> Image.Image:
    width, height = subcell.size
    side = min(width, height)
    left = (width - side) // 2
    top = (height - side) // 2
    square = subcell.crop((left, top, left + side, top + side))
    if INNER_FLATTEN > 0.0:
        trim = int(side * INNER_FLATTEN)
        square = square.crop((trim, trim, side - trim, side - trim))
    patch = square.resize((MACRO_PATCH_SIZE, MACRO_PATCH_SIZE), Image.Resampling.NEAREST)
    return apply_edge_bleed(patch)


def flatten_subpatches(cell: Image.Image) -> list[Image.Image]:
    width, height = cell.size
    patches: list[Image.Image] = []
    for sub_y in range(SUBPATCHES_PER_SIDE):
        for sub_x in range(SUBPATCHES_PER_SIDE):
            left = sub_x * width // SUBPATCHES_PER_SIDE
            top = sub_y * height // SUBPATCHES_PER_SIDE
            right = (sub_x + 1) * width // SUBPATCHES_PER_SIDE
            bottom = (sub_y + 1) * height // SUBPATCHES_PER_SIDE
            patches.append(flatten_subpatch(cell.crop((left, top, right, bottom))))
    return patches


def flatten_macro_cell(cell: Image.Image) -> Image.Image:
    return flatten_subpatches(cell)[0]


def flatten_cave_cell(cell: Image.Image) -> Image.Image:
    width, height = cell.size
    side = min(width, height)
    left = (width - side) // 2
    top = (height - side) // 2
    square = cell.crop((left, top, left + side, top + side))
    patch = square.resize((CAVE_MACRO_PATCH_SIZE, CAVE_MACRO_PATCH_SIZE), Image.Resampling.NEAREST)
    return apply_edge_bleed(patch)


def apply_edge_bleed(patch: Image.Image, bleed: int = 3) -> Image.Image:
    if patch.size[0] < bleed + 1 or patch.size[1] < bleed + 1:
        return patch
    pixels = patch.load()
    width, height = patch.size
    for depth in range(bleed):
        outer_y = depth
        inner_y = depth + 1
        for x in range(width):
            outer = pixels[x, outer_y][:3]
            inner = pixels[x, inner_y][:3]
            pixels[x, outer_y] = tuple((outer[i] + inner[i]) // 2 for i in range(3))
            outer_y = height - 1 - depth
            inner_y = height - 2 - depth
            outer = pixels[x, outer_y][:3]
            inner = pixels[x, inner_y][:3]
            pixels[x, outer_y] = tuple((outer[i] + inner[i]) // 2 for i in range(3))
        outer_x = depth
        inner_x = depth + 1
        for y in range(height):
            outer = pixels[outer_x, y][:3]
            inner = pixels[inner_x, y][:3]
            pixels[outer_x, y] = tuple((outer[i] + inner[i]) // 2 for i in range(3))
            outer_x = width - 1 - depth
            inner_x = width - 2 - depth
            outer = pixels[outer_x, y][:3]
            inner = pixels[inner_x, y][:3]
            pixels[outer_x, y] = tuple((outer[i] + inner[i]) // 2 for i in range(3))
    return patch


def atlas_background_color(image: Image.Image, cols: int, rows: int) -> tuple[int, int, int]:
    patch = flatten_macro_cell(crop_grid_cell(image.convert("RGB"), 0, 0, cols, rows))
    width, height = patch.size
    reds: list[int] = []
    greens: list[int] = []
    blues: list[int] = []
    for x in range(width):
        for y in (0, height - 1):
            red, green, blue = patch.getpixel((x, y))[:3]
            reds.append(red)
            greens.append(green)
            blues.append(blue)
    for y in range(1, height - 1):
        for x in (0, width - 1):
            red, green, blue = patch.getpixel((x, y))[:3]
            reds.append(red)
            greens.append(green)
            blues.append(blue)
    if not reds:
        return patch.getpixel((0, 0))[:3]
    return (
        sum(reds) // len(reds),
        sum(greens) // len(greens),
        sum(blues) // len(blues),
    )


def build_cave_atlas(image: Image.Image, cols: int, rows: int) -> Image.Image:
    source = image.convert("RGB")
    seed_patch = flatten_cave_cell(crop_grid_cell(source, 0, 0, cols, rows))
    atlas = Image.new("RGB", (ATLAS_SIZE, ATLAS_SIZE), seed_patch.getpixel((0, 0))[:3])
    for src_row in range(rows):
        for src_col in range(cols):
            cell = crop_grid_cell(source, src_col, src_row, cols, rows)
            patch = flatten_cave_cell(cell)
            out_col = src_col
            out_row = src_row
            if out_col >= CAVE_PATCHES_PER_SIDE or out_row >= CAVE_PATCHES_PER_SIDE:
                continue
            atlas.paste(patch, (out_col * CAVE_MACRO_PATCH_SIZE, out_row * CAVE_MACRO_PATCH_SIZE))
    return atlas


def build_macro_grid_atlas(
    image: Image.Image,
    cols: int,
    rows: int,
    out_cols: int = -1,
    out_rows: int = -1,
) -> Image.Image:
    source = image.convert("RGB")
    if out_cols < 0:
        out_cols = min(MACRO_PATCHES_PER_SIDE, cols * SUBPATCHES_PER_SIDE)
    if out_rows < 0:
        out_rows = min(MACRO_PATCHES_PER_SIDE, rows * SUBPATCHES_PER_SIDE)
    atlas = Image.new("RGB", (ATLAS_SIZE, ATLAS_SIZE), atlas_background_color(source, cols, rows))
    for src_row in range(rows):
        for src_col in range(cols):
            cell = crop_grid_cell(source, src_col, src_row, cols, rows)
            subpatches = flatten_subpatches(cell)
            for sub_y in range(SUBPATCHES_PER_SIDE):
                for sub_x in range(SUBPATCHES_PER_SIDE):
                    out_col = src_col * SUBPATCHES_PER_SIDE + sub_x
                    out_row = src_row * SUBPATCHES_PER_SIDE + sub_y
                    if out_col >= out_cols or out_row >= out_rows:
                        continue
                    patch = subpatches[sub_y * SUBPATCHES_PER_SIDE + sub_x]
                    atlas.paste(patch, (out_col * MACRO_PATCH_SIZE, out_row * MACRO_PATCH_SIZE))
    return atlas


def build_phase1_base_atlas(atlas: Image.Image) -> Image.Image:
    """Remove the generated sheet frame while preserving every macro interior."""
    source = atlas.convert("RGB")
    result = Image.new("RGB", source.size)
    macro_cols = source.width // (MACRO_PATCH_SIZE * SUBPATCHES_PER_SIDE)
    macro_rows = source.height // (MACRO_PATCH_SIZE * SUBPATCHES_PER_SIDE)
    macro_size = MACRO_PATCH_SIZE * SUBPATCHES_PER_SIDE
    for row in range(macro_rows):
        for col in range(macro_cols):
            left = col * macro_size
            top = row * macro_size
            interior = source.crop(
                (
                    left + PHASE1_BASE_INSET,
                    top + PHASE1_BASE_INSET,
                    left + macro_size - PHASE1_BASE_INSET,
                    top + macro_size - PHASE1_BASE_INSET,
                )
            )
            unframed = interior.resize((macro_size, macro_size), Image.Resampling.NEAREST)
            result.paste(apply_edge_bleed(unframed), (left, top))
    return result


def import_phase1_base_atlases() -> None:
    for source_name in BIOME_ATLAS_TARGETS:
        base_source_name = PHASE1_CONTINUOUS_BASE_SOURCES.get(source_name, source_name)
        source_path = ENV_DIR / base_source_name
        target_name = source_name.replace("_phase3.png", "_base_phase1.png")
        source = Image.open(source_path)
        if source_name in PHASE1_CONTINUOUS_BASE_SOURCES:
            base_atlas = source.convert("RGB")
        else:
            base_atlas = build_phase1_base_atlas(source)
        save_png(ENV_DIR / target_name, base_atlas)


def import_phase2_formation_atlases() -> None:
    """Preserve ornate macros as an unframed bank for meso-scale formations."""
    for source_name in BIOME_ATLAS_TARGETS:
        source_path = ENV_DIR / source_name
        target_name = source_name.replace("_phase3.png", "_formation_phase2.png")
        save_png(ENV_DIR / target_name, build_phase1_base_atlas(Image.open(source_path)))


def chroma_to_rgba(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    key_r, key_g, key_b = CHROMA_KEY
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            if (
                abs(red - key_r) <= CHROMA_TOLERANCE
                and abs(green - key_g) <= CHROMA_TOLERANCE
                and abs(blue - key_b) <= CHROMA_TOLERANCE
            ):
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def fit_prop(image: Image.Image) -> Image.Image:
    rgba = chroma_to_rgba(image)
    bbox = rgba.getbbox()
    if bbox is None:
        return Image.new("RGBA", (PROP_SIZE, PROP_SIZE), (0, 0, 0, 0))
    cropped = rgba.crop(bbox)
    fitted = Image.new("RGBA", (PROP_SIZE, PROP_SIZE), (0, 0, 0, 0))
    scale = min(PROP_SIZE / cropped.width, PROP_SIZE / cropped.height)
    resized = cropped.resize(
        (max(1, int(round(cropped.width * scale))), max(1, int(round(cropped.height * scale)))),
        Image.Resampling.NEAREST,
    )
    offset = ((PROP_SIZE - resized.width) // 2, (PROP_SIZE - resized.height) // 2)
    fitted.paste(resized, offset, resized)
    return fitted


def import_floor_atlases() -> None:
    for source_name, (target_name, cols, rows) in FLOOR_ATLASES.items():
        archive_source(source_name)
        atlas = build_macro_grid_atlas(Image.open(source_path(source_name)), cols, rows)
        save_png(ENV_DIR / target_name, atlas)


def import_phase4_sheet() -> None:
    archive_source(PHASE4_SOURCE)
    sheet = Image.open(source_path(PHASE4_SOURCE)).convert("RGB")
    strip_height = sheet.height // len(BIOME_STRIPS)
    strips: list[Image.Image] = []
    for target_name, index in BIOME_STRIPS:
        top = index * strip_height
        strip = sheet.crop((0, top, sheet.width, top + strip_height))
        side = min(strip.width, strip.height)
        left = (strip.width - side) // 2
        strip = strip.crop((left, 0, left + side, side))
        atlas = build_macro_grid_atlas(strip, 10, 10)
        save_png(ENV_DIR / target_name, atlas)
        strips.append(atlas)
    combined = Image.new("RGB", (ATLAS_SIZE, ATLAS_SIZE * len(strips)))
    for index, atlas in enumerate(strips):
        combined.paste(atlas, (0, index * ATLAS_SIZE))
    save_png(ENV_DIR / "phase4_environment_source.png", combined)


def import_props() -> None:
    for source_name, target_name in PROPS.items():
        archive_source(source_name)
        prop = fit_prop(Image.open(source_path(source_name)))
        save_png(WORLD_DIR / target_name, prop)
        source_target = WORLD_DIR / target_name.replace("_runtime.png", "_runtime_source.png")
        Image.open(source_path(source_name)).save(source_target, format="PNG")
        print(f"wrote {source_target.relative_to(ROOT)}")


def import_cave_material() -> None:
    archive_source(CAVE_SOURCE)
    source = Image.open(source_path(CAVE_SOURCE))
    cave = build_cave_atlas(source, 4, 4)
    save_png(ART_DIR / "cave_material_runtime.png", cave.convert("RGBA"))
    save_png(ART_DIR / "cave_material.png", source.convert("RGB"))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--phase1-base-only",
        action="store_true",
        help="derive quiet unframed base atlases from the current phase3 atlases",
    )
    parser.add_argument(
        "--phase2-formations-only",
        action="store_true",
        help="derive unframed formation atlases from the current phase3 atlases",
    )
    args = parser.parse_args()
    ensure_dirs()
    if args.phase1_base_only:
        import_phase1_base_atlases()
        return
    if args.phase2_formations_only:
        import_phase2_formation_atlases()
        return
    import_phase4_sheet()
    import_floor_atlases()
    import_phase1_base_atlases()
    import_phase2_formation_atlases()
    import_props()
    import_cave_material()


if __name__ == "__main__":
    main()
