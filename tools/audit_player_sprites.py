#!/usr/bin/env python3
"""Build a magnified player-sprite contact sheet and report chroma spill."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
PLAYER_DIR = ROOT / "assets" / "art" / "player"
OUTPUT = ROOT / "artifacts" / "player_sprite_audit" / "player_sprite_contact_sheet.png"
STYLES = ("survey", "foundry", "containment", "veteran")
DIRECTIONS = ("down", "right", "up", "left")


def is_magenta_spill(red: int, green: int, blue: int, alpha: int) -> bool:
    """Catch source-background pinks without classifying neutral dark armor."""
    return (
        alpha > 12
        and red >= 20
        and blue >= 20
        and green <= min(red, blue) * 0.78
        and min(red, blue) - green >= 8
        and abs(red - blue) <= 108
    )


def stats(image: Image.Image) -> tuple[int, int, int]:
    visible = spill = border = 0
    rgba = image.convert("RGBA")
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = rgba.getpixel((x, y))
            if alpha <= 12:
                continue
            visible += 1
            if x == 0 or y == 0 or x == rgba.width - 1 or y == rgba.height - 1:
                border += 1
            if is_magenta_spill(red, green, blue, alpha):
                for next_x, next_y in (
                    (x - 1, y - 1), (x, y - 1), (x + 1, y - 1),
                    (x - 1, y), (x + 1, y),
                    (x - 1, y + 1), (x, y + 1), (x + 1, y + 1),
                ):
                    if not (0 <= next_x < rgba.width and 0 <= next_y < rgba.height) or rgba.getpixel((next_x, next_y))[3] <= 12:
                        spill += 1
                        break
    return visible, spill, border


def main() -> None:
    scale = 6
    cell_width = 28 * scale
    cell_height = 30 * scale + 20
    sheet = Image.new("RGBA", (cell_width * 8, cell_height * 4), (16, 21, 25, 255))
    draw = ImageDraw.Draw(sheet)
    total_spill = 0
    for row, style in enumerate(STYLES):
        for direction_index, direction in enumerate(DIRECTIONS):
            for active_index, suffix in enumerate(("", "_active")):
                column = direction_index * 2 + active_index
                name = f"{style}_{direction}{suffix}"
                path = PLAYER_DIR / f"{name}.png"
                image = Image.open(path).convert("RGBA")
                visible, spill, border = stats(image)
                total_spill += spill
                print(f"{name}: visible={visible} magenta_spill={spill} border={border}")
                x = column * cell_width
                y = row * cell_height
                # Checkerboard makes leaked opaque pixels and clipped borders obvious.
                checker = Image.new("RGBA", image.size, (0, 0, 0, 0))
                checker_draw = ImageDraw.Draw(checker)
                for cy in range(0, image.height, 2):
                    for cx in range(0, image.width, 2):
                        shade = (54, 62, 68, 255) if (cx // 2 + cy // 2) % 2 == 0 else (30, 36, 41, 255)
                        checker_draw.rectangle((cx, cy, cx + 1, cy + 1), fill=shade)
                checker.alpha_composite(image)
                sheet.alpha_composite(checker.resize((28 * scale, 30 * scale), Image.Resampling.NEAREST), (x, y))
                draw.text((x + 3, y + 30 * scale + 3), f"{style[:4]} {direction[:2]} {'A' if suffix else 'P'} m{spill}", fill=(222, 236, 240, 255))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(OUTPUT, format="PNG", optimize=True)
    print(f"TOTAL_MAGENTA_SPILL={total_spill}")
    print(f"AUDIT={OUTPUT}")


if __name__ == "__main__":
    main()
