#!/usr/bin/env python3
"""Import and normalize player sprites from 4x5 pack sheets or existing PNGs."""

from __future__ import annotations

import argparse
import sys
from collections import deque
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
    find_split_indices,
    fit_canvas,
)

ROOT = Path(__file__).resolve().parents[1]
PLAYER_DIR = ROOT / "assets" / "art" / "player"

STYLE_SLUGS = ("survey", "foundry", "containment", "veteran")
DIRECTIONS = ("down", "right", "up", "left")
SHEET_COLUMNS: tuple[tuple[str, int], ...] = (
    ("down", 0),
    ("right", 1),
    ("up", 2),
    ("left", 3),
    ("portrait", 4),
)

CANVAS = (28, 30)
LEFT_LABEL_RATIO = 0.172
TOP_LABEL_RATIO = 0.067
BOTTOM_TRIM_RATIO = 0.062

def is_player_chroma_spill(red: int, green: int, blue: int, alpha: int) -> bool:
    """Detect compressed magenta-sheet fringe in the player-only palette.

    The four suits use teal, orange, yellow, and olive. None intentionally use
    purple, so this can be stricter than the shared mob-safe chroma key.
    """
    return (
        alpha > 12
        and red >= 20
        and blue >= 20
        and green <= min(red, blue) * 0.78
        and min(red, blue) - green >= 8
        and abs(red - blue) <= 108
    )


def strip_player_chroma_spill(image: Image.Image) -> int:
    pixels = image.load()
    pending: deque[tuple[int, int]] = deque()
    queued: set[tuple[int, int]] = set()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if not is_player_chroma_spill(red, green, blue, alpha):
                continue
            for next_x, next_y in (
                (x - 1, y - 1), (x, y - 1), (x + 1, y - 1),
                (x - 1, y), (x + 1, y),
                (x - 1, y + 1), (x, y + 1), (x + 1, y + 1),
            ):
                if not (0 <= next_x < image.width and 0 <= next_y < image.height) or pixels[next_x, next_y][3] <= 12:
                    pending.append((x, y))
                    queued.add((x, y))
                    break
    cleared = 0
    while pending:
        x, y = pending.popleft()
        if pixels[x, y][3] <= 12:
            continue
        pixels[x, y] = (0, 0, 0, 0)
        cleared += 1
        for next_x, next_y in (
            (x - 1, y - 1), (x, y - 1), (x + 1, y - 1),
            (x - 1, y), (x + 1, y),
            (x - 1, y + 1), (x, y + 1), (x + 1, y + 1),
        ):
            if not (0 <= next_x < image.width and 0 <= next_y < image.height) or (next_x, next_y) in queued:
                continue
            if is_player_chroma_spill(*pixels[next_x, next_y]):
                queued.add((next_x, next_y))
                pending.append((next_x, next_y))
    return cleared


def write_runtime(
    path: Path,
    image: Image.Image,
    background_reference: tuple[int, int, int] | None = None,
) -> None:
    if background_reference is not None:
        clear_background_color_pixels(image, background_reference)
    cleared_spill = strip_player_chroma_spill(image)
    assert_no_magenta(image, path.name)
    assert_clean_runtime_sprite(image, path.name, CANVAS, background_reference)
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    print(f"wrote {path.relative_to(ROOT)} ({image.size[0]}x{image.size[1]}); cleared_spill={cleared_spill}")


def equal_row_splits(length: int, count: int) -> list[int]:
    return [int(round(index * length / count)) for index in range(count + 1)]


def sheet_content_bounds(sheet: Image.Image) -> tuple[int, int, int, int]:
    left = int(sheet.width * LEFT_LABEL_RATIO)
    top = int(sheet.height * TOP_LABEL_RATIO)
    right = sheet.width
    bottom = sheet.height - int(sheet.height * BOTTOM_TRIM_RATIO)
    return left, top, right, bottom


def detect_player_splits(body: Image.Image) -> tuple[list[int], list[int]]:
    from sheet_cut import sprite_density

    col_density = sprite_density(body, "column", 0, body.height)
    col_bounds = find_split_indices(col_density, 5, 0.06)
    row_bounds = equal_row_splits(body.height, 4)
    return col_bounds, row_bounds


def target_name(style: str, slot: str, active: bool) -> str:
    if slot == "portrait":
        return f"{style}.png"
    suffix = "_active" if active else ""
    return f"{style}_{slot}{suffix}.png"


def import_player_sheet(source_path: Path, active: bool) -> None:
    source_path = source_path.resolve()
    if not source_path.exists():
        raise FileNotFoundError(source_path)

    archive_name = "player_active_pack_source.png" if active else "player_passive_pack_source.png"
    archive = PLAYER_DIR / archive_name
    if source_path != archive.resolve():
        archive_source_png(source_path, archive)
        print(f"archived {archive.relative_to(ROOT)}")
    else:
        print(f"using archived {archive.relative_to(ROOT)}")

    source_rgb = Image.open(source_path).convert("RGB")
    background_reference = dominant_border_color(source_rgb)
    sheet = chroma_to_rgba(source_rgb)
    left, top, right, bottom = sheet_content_bounds(sheet)
    body = crop_region(sheet, left, top, right, bottom)
    col_bounds, row_bounds = detect_player_splits(body)
    print(f"detected player splits cols={col_bounds} rows={row_bounds}")

    for row, style in enumerate(STYLE_SLUGS):
        for slot, col in SHEET_COLUMNS:
            if active and slot == "portrait":
                continue
            cell = crop_region(
                body,
                col_bounds[col],
                row_bounds[row],
                col_bounds[col + 1],
                row_bounds[row + 1],
            )
            sprite = extract_subject_components(cell, keep_detached=False)
            runtime = fit_canvas(sprite, CANVAS, padding=1)
            write_runtime(
                PLAYER_DIR / target_name(style, slot, active),
                runtime,
                background_reference,
            )


def process_direction(style: str, direction: str, active: bool) -> None:
    path = PLAYER_DIR / target_name(style, direction, active)
    if not path.exists():
        raise FileNotFoundError(path)
    source = Image.open(path).convert("RGBA")
    runtime = fit_canvas(source, CANVAS, padding=1)
    write_runtime(path, runtime)


def process_portrait(style: str) -> None:
    path = PLAYER_DIR / f"{style}.png"
    if not path.exists():
        raise FileNotFoundError(path)
    source = Image.open(path).convert("RGBA")
    runtime = fit_canvas(source, CANVAS, padding=1)
    write_runtime(path, runtime)


def normalize_existing() -> None:
    for style in STYLE_SLUGS:
        for direction in DIRECTIONS:
            process_direction(style, direction, False)
            if (PLAYER_DIR / target_name(style, direction, True)).exists():
                process_direction(style, direction, True)
    for style in STYLE_SLUGS:
        process_portrait(style)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--passive", type=Path, help="4x5 passive pose sheet")
    parser.add_argument("--active", type=Path, help="4x5 active gun-holding pose sheet (no weapon art)")
    parser.add_argument("--repair-archives", action="store_true", help="Re-encode all pack_source archives as PNG")
    return parser.parse_args(argv)


def main() -> None:
    args = parse_args(sys.argv[1:])
    if args.repair_archives:
        from sheet_cut import repair_pack_archives

        repaired = repair_pack_archives(ROOT / "assets")
        print(f"repaired {repaired} pack archives")
    if args.passive:
        import_player_sheet(args.passive, active=False)
    if args.active:
        import_player_sheet(args.active, active=True)
    if args.passive or args.active or not args.repair_archives:
        normalize_existing()
    print("CRAWL_BRAWL_PLAYER_SPRITES_OK")


if __name__ == "__main__":
    main()
