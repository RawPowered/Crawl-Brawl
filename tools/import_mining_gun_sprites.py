#!/usr/bin/env python3
"""Extract the authored 5-tier, 8-direction mining-gun sheet for Godot."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw

from sheet_cut import (
    archive_source_png,
    assert_clean_runtime_sprite,
    chroma_to_rgba,
    dominant_border_color,
    extract_subject_components,
    fit_canvas,
)


DIRECTIONS = (
    "down",
    "down_right",
    "right",
    "up_right",
    "up",
    "up_left",
    "left",
    "down_left",
)

# These boundaries deliberately exclude the sheet's left and top labels.
COLUMN_BOUNDS = (185, 350, 511, 680, 840, 995, 1155, 1334, 1536)
ROW_BOUNDS = (60, 230, 415, 605, 800, 1010)
RUNTIME_SIZE = (32, 32)


def extract_sheet(source: Path, output_dir: Path, audit_path: Path) -> list[Path]:
    original = Image.open(source).convert("RGBA")
    if original.size != (1536, 1024):
        raise RuntimeError(f"Expected a 1536x1024 source sheet, got {original.size}")

    cleaned = chroma_to_rgba(original)
    background = dominant_border_color(original)
    output_dir.mkdir(parents=True, exist_ok=True)
    rendered: list[tuple[str, Image.Image]] = []
    written: list[Path] = []

    for tier in range(1, 6):
        top, bottom = ROW_BOUNDS[tier - 1], ROW_BOUNDS[tier]
        for column, direction in enumerate(DIRECTIONS):
            left, right = COLUMN_BOUNDS[column], COLUMN_BOUNDS[column + 1]
            cell = cleaned.crop((left, top, right, bottom))
            subject = extract_subject_components(cell, keep_detached=True)
            sprite = fit_canvas(subject, RUNTIME_SIZE, padding=1)
            label = f"mining_gun_mk{tier}_{direction}"
            assert_clean_runtime_sprite(sprite, label, RUNTIME_SIZE)
            # The flood-fill removes only edge-connected sheet background. This
            # second check catches accidental rectangular crops without treating
            # intentional violet MK4 lighting as chroma.
            if sprite.getchannel("A").getbbox() in ((0, 0, 32, 32), None):
                raise RuntimeError(f"{label} does not have a transparent border")
            output_path = output_dir / f"{label}.png"
            sprite.save(output_path, format="PNG", optimize=True)
            written.append(output_path)
            rendered.append((label, sprite))

    audit_path.parent.mkdir(parents=True, exist_ok=True)
    scale = 4
    label_height = 18
    cell_width = RUNTIME_SIZE[0] * scale
    cell_height = RUNTIME_SIZE[1] * scale + label_height
    sheet = Image.new("RGBA", (cell_width * 8, cell_height * 5), (18, 23, 28, 255))
    draw = ImageDraw.Draw(sheet)
    for index, (label, sprite) in enumerate(rendered):
        column = index % 8
        row = index // 8
        x = column * cell_width
        y = row * cell_height
        enlarged = sprite.resize((cell_width, RUNTIME_SIZE[1] * scale), Image.Resampling.NEAREST)
        sheet.alpha_composite(enlarged, (x, y))
        draw.text((x + 3, y + RUNTIME_SIZE[1] * scale + 2), label.replace("mining_gun_", ""), fill=(210, 230, 235, 255))
    sheet.save(audit_path, format="PNG", optimize=True)
    print(f"Extracted {len(written)} mining-gun sprites; source background {background}")
    print(f"Audit sheet: {audit_path}")
    return written


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    root = args.root.resolve()
    source = args.source.resolve()
    archived = root / "assets" / "art" / "combat" / "sources" / "mining_gun_sheet.png"
    archive_source_png(source, archived)
    extract_sheet(
        archived,
        root / "assets" / "art" / "combat",
        root / "artifacts" / "mining_gun_audit" / "mining_gun_rotation_contact_sheet.png",
    )


if __name__ == "__main__":
    main()
