#!/usr/bin/env python3
"""Import ChatGPT combat VFX and branding PNGs into runtime assets."""

from __future__ import annotations

from pathlib import Path

import math

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
DOWNLOADS = Path.home() / "Downloads"
COMBAT_DIR = ROOT / "assets" / "art" / "combat"
SHOP_DIR = ROOT / "assets" / "art" / "shop"
UI_DIR = ROOT / "assets" / "art" / "ui"
BRANDING_DIR = ROOT / "assets" / "branding"
IMPORT_DIR = COMBAT_DIR / "import"
UI_IMPORT_DIR = UI_DIR / "import"
CHROMA_KEY = (255, 0, 255)
CHROMA_TOLERANCE = 48

# Grid dims are (cols, rows) matching each sheet's ACTUAL visual layout, read
# left-to-right, top-to-bottom. Earlier crops used transposed dims (e.g. coded
# as 2x3 for a sheet that is really 3x2), so crop_grid_cell sliced diagonal
# fragments of neighboring sprites instead of whole ones -- every resulting
# sprite came out as a near-blank sliver. Verified by eye against each sheet.
COMBAT_SHEETS: dict[str, tuple[int, int, list[tuple[str, tuple[int, int]]]]] = {
    "ChatGPT Image Aug 7, 2026, 09_15_39 PM (1).png": (
        3,
        2,
        [
            ("projectile_pistol", (12, 6)),
            ("projectile_shotgun", (8, 8)),
            ("projectile_smg", (10, 6)),
            ("projectile_railgun", (16, 6)),
            ("projectile_sentry", (10, 6)),
            ("projectile_impact_generic", (8, 8)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_39 PM (2).png": (
        3,
        2,
        [
            ("muzzle_pistol", (14, 10)),
            ("muzzle_shotgun", (18, 14)),
            ("muzzle_smg", (12, 10)),
            ("muzzle_railgun", (16, 12)),
            ("muzzle_flamethrower", (20, 12)),
            ("muzzle_sentry", (12, 10)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_39 PM (3).png": (
        3,
        1,
        [
            ("laser_muzzle", (12, 12)),
            ("laser_segment", (16, 4)),
            ("laser_impact", (12, 12)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_39 PM (4).png": (
        2,
        2,
        [
            ("flame_stream_a", (24, 12)),
            ("flame_stream_b", (24, 12)),
            ("flame_patch", (20, 20)),
            ("flame_ember", (8, 8)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_40 PM (5).png": (
        3,
        1,
        [
            ("rocket_body", (12, 6)),
            ("rocket_trail", (14, 6)),
            ("rocket_explosion", (20, 20)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_40 PM (6).png": (
        2,
        1,
        [
            ("laser_turret_head", (10, 4)),
            ("laser_turret_trail", (14, 4)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_40 PM (7).png": (
        3,
        1,
        [
            ("acid_glob", (10, 10)),
            ("acid_trail", (12, 4)),
            ("acid_splat", (12, 12)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_40 PM (8).png": (
        3,
        3,
        [
            ("impact_gold", (8, 8)),
            ("impact_orange", (8, 8)),
            ("impact_yellow", (8, 8)),
            ("impact_cyan", (8, 8)),
            ("impact_acid", (8, 8)),
            ("impact_rocket", (8, 8)),
            ("impact_laser", (8, 8)),
            ("impact_rock", (8, 8)),
            ("impact_metal", (8, 8)),
        ],
    ),
    "ChatGPT Image Aug 7, 2026, 09_15_40 PM (9).png": (
        3,
        2,
        [
            ("recoil_pistol", (16, 16)),
            ("recoil_shotgun", (16, 16)),
            ("recoil_laser", (16, 16)),
            ("recoil_smg", (16, 16)),
            ("recoil_railgun", (16, 16)),
            ("recoil_flamethrower", (16, 16)),
        ],
    ),
}

HELD_WEAPON_CANVAS = (24, 16)
HELD_WEAPONS: list[tuple[str, str, tuple[int, int], tuple[int, int]]] = [
    ("held_pistol", "pistol.png", (6, 10), (20, 8)),
    ("held_shotgun", "shotgun.png", (6, 10), (22, 8)),
    ("held_laser", "laser.png", (6, 10), (21, 8)),
    ("held_smg", "smg.png", (6, 10), (20, 8)),
    ("held_railgun", "railgun.png", (6, 10), (23, 8)),
    ("held_flamethrower", "flamethrower.png", (6, 10), (22, 9)),
]

BRANDING_FILES = {
    "ChatGPT Image Aug 7, 2026, 07_44_59 PM (1).png": ("crawl_brawl_logo.png", None),
    "ChatGPT Image Aug 7, 2026, 07_44_59 PM (2).png": ("crawl_brawl_icon.png", (256, 256)),
    "ChatGPT Image Aug 7, 2026, 07_48_22 PM.png": ("crawl_brawl_logo_menu.png", "menu"),
    "GatoGodModeGames.png": ("gatogodmode_logo.png", "studio"),
}

# Menu chrome is baked to twice its on-screen slot so the runtime only downscales.
UI_FILES = {
    "ChatGPT Image Aug 7, 2026, 09_43_29 PM.png": ("menu_sidebar_frame.png", (600, 696)),
}

MASTER_SHEET_NAME = "ChatGPT Image Aug 7, 2026, 11_08_26 PM.png"

# Explicit full-sheet coordinates. The numbered groups in the source are not
# uniform grids, so dividing broad regions produced fragments of neighboring
# sprites. Target sizes are only used for standalone icons and reticles.
UI_MASTER_SPRITES: dict[str, tuple[tuple[int, int, int, int], tuple[int, int] | None]] = {
    "hud_panel_teal": ((14, 384, 100, 430), None),
    "hud_panel_cyan": ((101, 385, 188, 429), None),
    "hud_panel_muted": ((189, 384, 276, 430), None),
    "hud_panel_wide_teal": ((14, 430, 137, 476), None),
    "hud_panel_wide_cyan": ((137, 430, 225, 476), None),
    "hud_panel_square": ((225, 430, 277, 476), None),
    "hud_slot_dark": ((472, 384, 589, 416), None),
    "hud_slot_cyan": ((472, 416, 589, 447), None),
    "hud_slot_locked": ((472, 447, 589, 478), None),
    "hud_display_panel": ((799, 380, 1020, 534), None),
    "hud_window_square": ((293, 223, 453, 383), None),
    "hud_bar_green": ((302, 388, 370, 408), None),
    "hud_bar_cyan": ((403, 388, 472, 408), None),
    "hud_bar_amber": ((302, 451, 370, 473), None),
    "hud_icon_crosshair": ((439, 496, 461, 518), (16, 16)),
    "hud_icon_factory": ((478, 496, 500, 518), (16, 16)),
    "hud_icon_briefcase": ((518, 496, 540, 518), (16, 16)),
    "hud_icon_warning": ((439, 520, 461, 542), (16, 16)),
    "reticle_cyan": ((727, 538, 757, 576), (24, 24)),
    "reticle_yellow": ((774, 538, 803, 576), (24, 24)),
    "reticle_purple": ((821, 538, 851, 576), (24, 24)),
    "reticle_white": ((916, 538, 945, 576), (24, 24)),
}


def source_path(name: str, import_dir: Path = IMPORT_DIR) -> Path:
    # The archived copy wins so a re-import is reproducible and cannot be
    # hijacked by a same-named file that was re-saved in Downloads.
    archived = import_dir / name.replace(", ", "_").replace(" ", "_")
    if archived.exists():
        return archived
    download = DOWNLOADS / name
    if download.exists():
        return download
    raise FileNotFoundError(name)


def ensure_dirs() -> None:
    for path in (COMBAT_DIR, UI_DIR, BRANDING_DIR, IMPORT_DIR, UI_IMPORT_DIR):
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
    return image.crop((left, top, right, bottom))


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


def fit_sprite(cell: Image.Image, target_size: tuple[int, int]) -> Image.Image:
    rgba = chroma_to_rgba(cell)
    bbox = rgba.getbbox()
    if bbox is None:
        return Image.new("RGBA", target_size, (0, 0, 0, 0))
    cropped = rgba.crop(bbox)
    fitted = Image.new("RGBA", target_size, (0, 0, 0, 0))
    scale = min(target_size[0] / cropped.width, target_size[1] / cropped.height)
    resized = cropped.resize(
        (max(1, int(round(cropped.width * scale))), max(1, int(round(cropped.height * scale)))),
        Image.Resampling.NEAREST,
    )
    offset = ((target_size[0] - resized.width) // 2, (target_size[1] - resized.height) // 2)
    fitted.paste(resized, offset, resized)
    return fitted


def weapon_endpoints(image: Image.Image) -> tuple[tuple[int, int], tuple[int, int]]:
    rgba = image.convert("RGBA")
    points = [(x, y) for y in range(rgba.height) for x in range(rgba.width) if rgba.getpixel((x, y))[3] > 20]
    if len(points) < 2:
        return (0, 0), (1, 0)
    min_x = min(x for x, _ in points)
    max_x = max(x for x, _ in points)
    left = [point for point in points if point[0] <= min_x + 1]
    right = [point for point in points if point[0] >= max_x - 1]
    grip = (min_x, sum(y for _, y in left) // len(left))
    muzzle = (max_x, sum(y for _, y in right) // len(right))
    return grip, muzzle


def orient_weapon_muzzle_right(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    grip, muzzle = weapon_endpoints(rgba)
    dx = float(muzzle[0] - grip[0])
    dy = float(muzzle[1] - grip[1])
    if abs(dx) < 0.01 and abs(dy) < 0.01:
        return rgba
    angle_deg = math.degrees(math.atan2(dy, dx))
    if abs(angle_deg) < 0.5:
        return rgba
    return rgba.rotate(-angle_deg, expand=True, resample=Image.Resampling.NEAREST, fillcolor=(0, 0, 0, 0))


def measure_grip_muzzle(image: Image.Image) -> tuple[tuple[int, int], tuple[int, int]]:
    return weapon_endpoints(image)


def fit_held_weapon(source: Path, grip: tuple[int, int], muzzle: tuple[int, int]):
    rgba = trim_transparent(chroma_to_rgba(Image.open(source)))
    bbox = rgba.getbbox()
    if bbox is None:
        empty = Image.new("RGBA", HELD_WEAPON_CANVAS, (0, 0, 0, 0))
        return empty, grip, muzzle
    cropped = orient_weapon_muzzle_right(rgba.crop(bbox))
    cropped = trim_transparent(cropped)
    source_grip, source_muzzle = weapon_endpoints(cropped)
    target_grip = (6, 8)
    target_muzzle_x = 20
    span_x = max(1, target_muzzle_x - target_grip[0])
    span_y = max(1, HELD_WEAPON_CANVAS[1] - 4)
    barrel_len = max(1, source_muzzle[0] - source_grip[0])
    scale = min(span_x / barrel_len, span_y / cropped.height)
    resized = cropped.resize(
        (max(1, int(round(cropped.width * scale))), max(1, int(round(cropped.height * scale)))),
        Image.Resampling.NEAREST,
    )
    weapon_grip, _weapon_muzzle = weapon_endpoints(resized)
    canvas = Image.new("RGBA", HELD_WEAPON_CANVAS, (0, 0, 0, 0))
    paste_at = (target_grip[0] - weapon_grip[0], target_grip[1] - weapon_grip[1])
    canvas.paste(resized, paste_at, resized)
    measured_grip, measured_muzzle = measure_grip_muzzle(canvas)
    return canvas, measured_grip, measured_muzzle


def import_held_weapons() -> None:
    measured: list[tuple[str, tuple[int, int], tuple[int, int]]] = []
    for target_name, shop_name, grip, muzzle in HELD_WEAPONS:
        source = SHOP_DIR / shop_name
        if not source.exists():
            raise FileNotFoundError(source)
        sprite, measured_grip, measured_muzzle = fit_held_weapon(source, grip, muzzle)
        save_png(COMBAT_DIR / f"{target_name}.png", sprite)
        save_png(COMBAT_DIR / f"{target_name}_source.png", Image.open(source).convert("RGBA"))
        measured.append((target_name, measured_grip, measured_muzzle))
    for target_name, measured_grip, measured_muzzle in measured:
        print(f"held geometry {target_name}: grip={measured_grip} muzzle={measured_muzzle}")


def import_combat_sheets() -> None:
    for source_name, (cols, rows, cells) in COMBAT_SHEETS.items():
        archive_source(source_name)
        sheet = Image.open(source_path(source_name))
        for index, (target_name, target_size) in enumerate(cells):
            col = index % cols
            row = index // cols
            cell = crop_grid_cell(sheet, col, row, cols, rows)
            sprite = fit_sprite(key_magenta_with_spill(cell), target_size)
            save_png(COMBAT_DIR / f"{target_name}.png", sprite)
            save_png(COMBAT_DIR / f"{target_name}_source.png", cell.convert("RGBA"))


def save_windows_ico(path: Path, source: Image.Image) -> None:
    rgba = source.convert("RGBA")
    # Godot's Windows exporter requires every size in this set.
    sizes = [256, 128, 64, 48, 32, 16]
    rgba.save(path, format="ICO", sizes=[(size, size) for size in sizes])


def key_near_black(image: Image.Image, tolerance: int = 24) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            if red <= tolerance and green <= tolerance and blue <= tolerance:
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def trim_transparent(image: Image.Image, padding: int = 2) -> Image.Image:
    bbox = image.getbbox()
    if bbox is None:
        return image
    left, top, right, bottom = bbox
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(image.width, right + padding)
    bottom = min(image.height, bottom + padding)
    return image.crop((left, top, right, bottom))


def alpha_from_glow(image: Image.Image, boost: float = 1.35, floor: int = 14) -> Image.Image:
    """Derive alpha from luminance so a glow-on-black logo keeps its soft halo.

    A hard black key would cut the halo into a visible rectangle on any
    non-black panel, so brightness becomes opacity instead. The floor drops
    compression noise in the black field that would otherwise defeat trimming.
    """
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    span = max(1, 255 - floor)
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, _alpha = pixels[x, y]
            luminance = max(red, green, blue)
            if luminance <= floor:
                pixels[x, y] = (0, 0, 0, 0)
                continue
            scaled = 255.0 * (luminance - floor) / span
            pixels[x, y] = (red, green, blue, min(255, int(round(scaled * boost))))
    return rgba


def resize_branding_image(image: Image.Image, resize: object) -> Image.Image:
    rgba = image.convert("RGBA")
    if resize is None:
        return rgba
    if resize == "studio":
        keyed = trim_transparent(alpha_from_glow(rgba), padding=0)
        target_width = 512
        target_height = max(1, int(round(keyed.height * (target_width / keyed.width))))
        return keyed.resize((target_width, target_height), Image.Resampling.LANCZOS)
    if resize == "menu":
        target_width = 768
        target_height = max(1, int(round(rgba.height * (target_width / rgba.width))))
        scaled = rgba.resize((target_width, target_height), Image.Resampling.LANCZOS)
        return trim_transparent(key_near_black(scaled))
    if isinstance(resize, tuple) and len(resize) == 2:
        return rgba.resize(resize, Image.Resampling.LANCZOS)
    raise ValueError(f"Unsupported branding resize rule: {resize!r}")


def import_branding() -> None:
    for source_name, (target_name, resize) in BRANDING_FILES.items():
        archive_source(source_name)
        source_image = Image.open(source_path(source_name))
        image = resize_branding_image(source_image, resize)
        save_png(BRANDING_DIR / target_name, image)
        save_png(BRANDING_DIR / target_name.replace(".png", "_source.png"), source_image.convert("RGBA"))
    icon_path = BRANDING_DIR / "crawl_brawl_icon.png"
    if icon_path.exists():
        save_windows_ico(BRANDING_DIR / "crawl_brawl.ico", Image.open(icon_path))


def key_magenta_with_spill(image: Image.Image, hard: int = 55, soft: int = 150) -> Image.Image:
    """Key magenta with a soft edge so anti-aliased pixels lose their pink fringe."""
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    span = max(1, soft - hard)
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            magentaness = min(red, blue) - green
            if magentaness >= soft and red > 110 and blue > 110:
                pixels[x, y] = (0, 0, 0, 0)
            elif magentaness > hard:
                fade = (magentaness - hard) / span
                pixels[x, y] = (
                    min(red, green),
                    green,
                    min(blue, green),
                    int(round(alpha * (1.0 - fade))),
                )
    return rgba


def archive_ui_source(name: str) -> None:
    source = source_path(name, UI_IMPORT_DIR)
    target = UI_IMPORT_DIR / name.replace(", ", "_").replace(" ", "_")
    if source.resolve() != target.resolve() and not target.exists():
        Image.open(source).save(target, format="PNG")
        print(f"archived {target.relative_to(ROOT)}")


def import_ui() -> None:
    for source_name, (target_name, target_size) in UI_FILES.items():
        archive_ui_source(source_name)
        source_image = Image.open(source_path(source_name, UI_IMPORT_DIR))
        rgba = trim_transparent(key_magenta_with_spill(source_image), padding=0)
        rgba = rgba.resize(target_size, Image.Resampling.LANCZOS)
        save_png(UI_DIR / target_name, rgba)
        save_png(UI_DIR / target_name.replace(".png", "_source.png"), source_image.convert("RGBA"))


def import_ui_master_sheet() -> None:
    archive_ui_source(MASTER_SHEET_NAME)
    sheet = Image.open(source_path(MASTER_SHEET_NAME, UI_IMPORT_DIR))
    save_png(UI_DIR / "hud_master_sheet_source.png", sheet.convert("RGBA"))
    for target_name, (crop_box, target_size) in UI_MASTER_SPRITES.items():
        region = sheet.crop(crop_box)
        if target_size is None:
            rgba = trim_transparent(key_magenta_with_spill(region), padding=0)
        else:
            rgba = fit_sprite(key_magenta_with_spill(region), target_size)
        save_png(UI_DIR / f"{target_name}.png", rgba)
        save_png(UI_DIR / f"{target_name}_source.png", region.convert("RGBA"))


def main() -> None:
    ensure_dirs()
    import_combat_sheets()
    import_held_weapons()
    import_branding()
    import_ui()
    import_ui_master_sheet()


if __name__ == "__main__":
    main()
