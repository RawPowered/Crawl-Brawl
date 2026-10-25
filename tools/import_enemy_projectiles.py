#!/usr/bin/env python3
"""Cut / chroma / fit enemy artillery + FX sheets into combat runtime PNGs.

Source sheets: assets/art/mobs/projectiles/
  Biome 3-panel: {Tunnel,Hive,...}.png -> equal thirds (stable, unchanged)
  FX sheets: subject-aware extract (no mid-panel shear) + padded fit
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from import_combat_textures import (  # noqa: E402
    COMBAT_DIR,
    key_magenta_with_spill,
    save_png,
)

SOURCE_DIR = ROOT / "assets" / "art" / "mobs" / "projectiles"
ARCHIVE_DIR = COMBAT_DIR / "import" / "enemy_projectiles"

# biome file stem -> (texture prefix matching combat_vfx ids, sizes)
SHEETS: dict[str, tuple[str, tuple[tuple[int, int], tuple[int, int], tuple[int, int]]]] = {
    "Tunnel": ("tunnel_spore", ((10, 10), (12, 4), (12, 12))),
    "Hive": ("hive_venom", ((10, 10), (12, 4), (12, 12))),
    "Bunker": ("bunker_arc", ((10, 10), (12, 4), (12, 12))),
    "Crystal": ("crystal_arc", ((10, 10), (12, 4), (12, 12))),
    "Foundry": ("foundry_thermal", ((10, 10), (12, 4), (12, 12))),
    "Sulfur": ("sulfur_corrosive", ((10, 10), (12, 4), (12, 12))),
    "Iron": ("iron_kinetic", ((10, 10), (12, 4), (12, 12))),
}

# FX only: subject-aware cuts + larger canvases so rings/bursts keep margins
FX_THREE_PANEL: dict[str, tuple[str, tuple[tuple[int, int], tuple[int, int], tuple[int, int]]]] = {
    "bulwark_lob_source_sheet": ("enemy_lob", ((14, 14), (16, 6), (18, 18))),
    "guardian_cyst_source_sheet": ("enemy_cyst", ((16, 16), (16, 6), (18, 18))),
}

FX_TWO_PANEL: dict[str, tuple[tuple[str, tuple[int, int]], tuple[str, tuple[int, int]]]] = {
    "hazard_thermal_source_sheet": (
        ("hazard_thermal", (40, 40)),
        ("hazard_thermal_ember", (12, 12)),
    ),
    "hazard_spore_source_sheet": (
        ("hazard_spore", (40, 40)),
        ("hazard_spore_puff", (12, 12)),
    ),
}

FX_SINGLE: dict[str, tuple[str, tuple[int, int]]] = {
    "status_venom_rim_source": ("status_venom_rim", (18, 18)),
    "status_dot_pulse_source": ("status_dot_pulse", (18, 18)),
}

PARTS = ("glob", "trail", "splat")
FX_FIT_PAD = 2
FX_BBOX_PAD = 6


def split_n_panel(sheet: Image.Image, panels: int) -> list[Image.Image]:
    """Equal panel split — biome artillery only."""
    width, height = sheet.size
    cells: list[Image.Image] = []
    for col in range(panels):
        left = col * width // panels
        right = (col + 1) * width // panels
        cells.append(sheet.crop((left, 0, right, height)))
    return cells


def fit_subject(cell: Image.Image, target_size: tuple[int, int], edge_pad: int = 0, already_keyed: bool = False) -> Image.Image:
    if already_keyed:
        keyed = cell.convert("RGBA")
    elif cell.mode == "RGBA" and _looks_unkeyed(cell):
        keyed = key_magenta_with_spill(cell)
    else:
        keyed = cell.convert("RGBA")
    bbox = keyed.getbbox()
    if bbox is None:
        return Image.new("RGBA", target_size, (0, 0, 0, 0))
    cropped = keyed.crop(bbox)
    sprite = Image.new("RGBA", target_size, (0, 0, 0, 0))
    pad = max(0, edge_pad)
    usable = (max(1, target_size[0] - pad * 2), max(1, target_size[1] - pad * 2))
    scale = min(usable[0] / cropped.width, usable[1] / cropped.height)
    resized = cropped.resize(
        (
            max(1, int(round(cropped.width * scale))),
            max(1, int(round(cropped.height * scale))),
        ),
        Image.Resampling.NEAREST,
    )
    offset = ((target_size[0] - resized.width) // 2, (target_size[1] - resized.height) // 2)
    sprite.paste(resized, offset, resized)
    return sprite


def _looks_unkeyed(image: Image.Image) -> bool:
    """Heuristic: magenta-heavy sheets still need keying."""
    sample = image.resize((32, 32), Image.Resampling.NEAREST)
    pixels = list(sample.getdata())
    magenta = 0
    for red, green, blue, _alpha in pixels:
        if min(red, blue) - green > 80 and red > 110 and blue > 110:
            magenta += 1
    return magenta > len(pixels) * 0.08


def _column_alpha_mass(keyed: Image.Image) -> list[int]:
    width, height = keyed.size
    pixels = keyed.load()
    masses = [0] * width
    for x in range(width):
        mass = 0
        for y in range(height):
            if pixels[x, y][3] > 16:
                mass += 1
        masses[x] = mass
    return masses


def _panel_x_ranges(keyed: Image.Image, panels: int) -> list[tuple[int, int]]:
    """Split on magenta gutters when possible; else equal widths."""
    width, _height = keyed.size
    if panels <= 1:
        return [(0, width)]
    masses = _column_alpha_mass(keyed)
    # Smooth a little so single-pixel gaps do not win.
    smooth = masses[:]
    for x in range(1, width - 1):
        smooth[x] = (masses[x - 1] + masses[x] * 2 + masses[x + 1]) // 4
    peak = max(1, max(smooth) if smooth else 1)
    splits: list[int] = []
    for i in range(1, panels):
        lo = int(width * (i - 0.35) / panels)
        hi = int(width * (i + 0.35) / panels)
        lo = max(2, lo)
        hi = min(width - 2, max(lo + 1, hi))
        gutter = min(range(lo, hi), key=lambda x: smooth[x])
        # Require a real valley; otherwise equal split for this boundary.
        if smooth[gutter] > peak * 0.18:
            gutter = i * width // panels
        splits.append(gutter)
    edges = [0] + splits + [width]
    return [(edges[i], edges[i + 1]) for i in range(panels)]


def _largest_opaque_bbox(image: Image.Image, min_alpha: int = 16) -> tuple[int, int, int, int] | None:
    """BBox of the largest connected opaque component (ignores fringe dust)."""
    width, height = image.size
    pixels = image.load()
    seen = [[False] * width for _ in range(height)]
    best: tuple[int, int, int, int, int] | None = None  # area, x0,y0,x1,y1
    for y in range(height):
        for x in range(width):
            if seen[y][x] or pixels[x, y][3] <= min_alpha:
                continue
            queue = [(x, y)]
            seen[y][x] = True
            min_x = max_x = x
            min_y = max_y = y
            area = 0
            qi = 0
            while qi < len(queue):
                cx, cy = queue[qi]
                qi += 1
                area += 1
                min_x = min(min_x, cx)
                max_x = max(max_x, cx)
                min_y = min(min_y, cy)
                max_y = max(max_y, cy)
                for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                    if nx < 0 or ny < 0 or nx >= width or ny >= height:
                        continue
                    if seen[ny][nx] or pixels[nx, ny][3] <= min_alpha:
                        continue
                    seen[ny][nx] = True
                    queue.append((nx, ny))
            if best is None or area > best[0]:
                best = (area, min_x, min_y, max_x + 1, max_y + 1)
    if best is None:
        return None
    return best[1:]


def extract_fx_subjects(sheet: Image.Image, count: int, bbox_pad: int = FX_BBOX_PAD) -> list[Image.Image]:
    """Extract N FX subjects without equal-panel shear.

    Gutter bands keep left/right (or 3-panel) layout, then each band keeps only
    its largest opaque component so dust/chrome cannot stretch the crop.
    """
    keyed = key_magenta_with_spill(sheet.convert("RGBA"))
    width, height = keyed.size
    ranges = _panel_x_ranges(keyed, count)
    subjects: list[Image.Image] = []
    for left, right in ranges:
        band = keyed.crop((left, 0, right, height))
        bbox = _largest_opaque_bbox(band)
        if bbox is None:
            subjects.append(Image.new("RGBA", (1, 1), (0, 0, 0, 0)))
            continue
        x0, y0, x1, y1 = bbox
        x0 = max(0, x0 - bbox_pad)
        y0 = max(0, y0 - bbox_pad)
        x1 = min(band.width, x1 + bbox_pad)
        y1 = min(band.height, y1 + bbox_pad)
        subjects.append(band.crop((x0, y0, x1, y1)))
    if any(s.size == (1, 1) for s in subjects):
        return [key_magenta_with_spill(cell) for cell in split_n_panel(sheet, count)]
    return subjects


def import_three_panel(source_stem: str, prefix: str, sizes: tuple, *, fx: bool = False) -> None:
    source_path = SOURCE_DIR / f"{source_stem}.png"
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
    sheet = Image.open(source_path).convert("RGBA")
    save_png(ARCHIVE_DIR / f"{prefix}_sheet_source.png", sheet)
    cells = extract_fx_subjects(sheet, 3) if fx else split_n_panel(sheet, 3)
    edge_pad = FX_FIT_PAD if fx else 0
    for part, cell, target_size in zip(PARTS, cells, sizes, strict=True):
        sprite = fit_subject(cell, target_size, edge_pad=edge_pad, already_keyed=fx)
        texture_id = f"{prefix}_{part}"
        save_png(COMBAT_DIR / f"{texture_id}.png", sprite)
        save_png(COMBAT_DIR / f"{texture_id}_source.png", cell.convert("RGBA"))


def import_two_panel_fx(source_stem: str, parts: tuple) -> None:
    source_path = SOURCE_DIR / f"{source_stem}.png"
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
    sheet = Image.open(source_path).convert("RGBA")
    save_png(ARCHIVE_DIR / f"{source_stem}_archive.png", sheet)
    cells = extract_fx_subjects(sheet, 2)
    for cell, (texture_id, target_size) in zip(cells, parts, strict=True):
        sprite = fit_subject(cell, target_size, edge_pad=FX_FIT_PAD, already_keyed=True)
        save_png(COMBAT_DIR / f"{texture_id}.png", sprite)
        save_png(COMBAT_DIR / f"{texture_id}_source.png", cell.convert("RGBA"))


def import_single(source_stem: str, texture_id: str, target_size: tuple[int, int]) -> None:
    source_path = SOURCE_DIR / f"{source_stem}.png"
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
    cell = Image.open(source_path).convert("RGBA")
    save_png(ARCHIVE_DIR / f"{texture_id}_sheet_source.png", cell)
    keyed = key_magenta_with_spill(cell)
    sprite = fit_subject(keyed, target_size, edge_pad=FX_FIT_PAD, already_keyed=True)
    save_png(COMBAT_DIR / f"{texture_id}.png", sprite)
    save_png(COMBAT_DIR / f"{texture_id}_source.png", cell)


def import_fx_only() -> None:
    for source_stem, (prefix, sizes) in FX_THREE_PANEL.items():
        import_three_panel(source_stem, prefix, sizes, fx=True)
        print(f"imported FX {source_stem} -> {prefix}_{{glob,trail,splat}}")
    for source_stem, parts in FX_TWO_PANEL.items():
        import_two_panel_fx(source_stem, parts)
        print(f"imported FX {source_stem} -> {[p[0] for p in parts]}")
    for source_stem, (texture_id, size) in FX_SINGLE.items():
        import_single(source_stem, texture_id, size)
        print(f"imported FX {source_stem} -> {texture_id}")


def import_biome_only() -> None:
    for source_name, (prefix, sizes) in SHEETS.items():
        import_three_panel(source_name, prefix, sizes, fx=False)
        print(f"imported {source_name} -> {prefix}_{{glob,trail,splat}}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Import enemy projectile / FX combat textures")
    parser.add_argument("--fx-only", action="store_true", help="Re-cut FX sheets only (hazards, lob, cyst, status)")
    parser.add_argument("--biome-only", action="store_true", help="Re-cut biome artillery sheets only")
    args = parser.parse_args()
    COMBAT_DIR.mkdir(parents=True, exist_ok=True)
    if args.fx_only:
        import_fx_only()
        return
    if args.biome_only:
        import_biome_only()
        return
    import_biome_only()
    import_fx_only()


if __name__ == "__main__":
    main()
