#!/usr/bin/env python3
"""Shared helpers for ChatGPT sprite sheet slicing and chroma cleanup."""

from __future__ import annotations

from collections import Counter, deque
from pathlib import Path

from PIL import Image

CHROMA_KEY = (255, 0, 255)
CHROMA_TOLERANCE = 48
LABEL_MIN = 210
BACKGROUND_DISTANCE = 92
BACKGROUND_FRINGE_DISTANCE = 124


def is_chroma_pixel(red: int, green: int, blue: int) -> bool:
    key_r, key_g, key_b = CHROMA_KEY
    return (
        abs(red - key_r) <= CHROMA_TOLERANCE
        and abs(green - key_g) <= CHROMA_TOLERANCE
        and abs(blue - key_b) <= CHROMA_TOLERANCE
    )


def is_magenta_background_family(red: int, green: int, blue: int) -> bool:
    """Broad family used only for edge-connected source-sheet cleanup."""
    return (
        red >= 120
        and blue >= 105
        and green <= 150
        and red - green >= 55
        and blue - green >= 50
    )


def color_distance(left: tuple[int, int, int], right: tuple[int, int, int]) -> float:
    return (
        (left[0] - right[0]) ** 2
        + (left[1] - right[1]) ** 2
        + (left[2] - right[2]) ** 2
    ) ** 0.5


def dominant_border_color(image: Image.Image) -> tuple[int, int, int]:
    """Return the dominant quantized perimeter color of an AI source sheet."""
    rgb = image.convert("RGB")
    border: list[tuple[int, int, int]] = []
    for x in range(rgb.width):
        border.append(rgb.getpixel((x, 0)))
        border.append(rgb.getpixel((x, rgb.height - 1)))
    for y in range(rgb.height):
        border.append(rgb.getpixel((0, y)))
        border.append(rgb.getpixel((rgb.width - 1, y)))
    quantized = Counter((red // 8, green // 8, blue // 8) for red, green, blue in border)
    bucket, _count = quantized.most_common(1)[0]
    members = [
        color
        for color in border
        if (color[0] // 8, color[1] // 8, color[2] // 8) == bucket
    ]
    return tuple(sum(color[index] for color in members) // len(members) for index in range(3))


def _matches_sheet_background(
    color: tuple[int, int, int],
    reference: tuple[int, int, int],
    distance: float,
) -> bool:
    red, green, blue = color
    return is_magenta_background_family(red, green, blue) and color_distance(color, reference) <= distance


def is_label_pixel(red: int, green: int, blue: int) -> bool:
    return red > LABEL_MIN and green > LABEL_MIN and blue > LABEL_MIN


def chroma_to_rgba(image: Image.Image) -> Image.Image:
    """Remove the edge-connected magenta sheet background without eating purple art.

    Generated sheets do not use literal #ff00ff: their perimeter colors vary by
    dozens of RGB values. Sampling the actual perimeter and flood-filling only
    connected background pixels is both more tolerant and safer for purple mobs.
    """
    rgba = image.convert("RGBA")
    reference = dominant_border_color(image)
    pixels = rgba.load()
    pending: deque[tuple[int, int]] = deque()
    visited: set[tuple[int, int]] = set()

    for x in range(rgba.width):
        pending.append((x, 0))
        pending.append((x, rgba.height - 1))
    for y in range(rgba.height):
        pending.append((0, y))
        pending.append((rgba.width - 1, y))

    while pending:
        x, y = pending.popleft()
        if (x, y) in visited:
            continue
        visited.add((x, y))
        red, green, blue, _alpha = pixels[x, y]
        if not _matches_sheet_background((red, green, blue), reference, BACKGROUND_DISTANCE):
            continue
        pixels[x, y] = (0, 0, 0, 0)
        for next_x, next_y in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= next_x < rgba.width and 0 <= next_y < rgba.height:
                pending.append((next_x, next_y))

    # Remove the compressed pink fringe immediately bordering the cleared field.
    # This is intentionally a single pass so purple subject colors remain intact.
    fringe: list[tuple[int, int]] = []
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha <= 0 or not _matches_sheet_background(
                (red, green, blue), reference, BACKGROUND_FRINGE_DISTANCE
            ):
                continue
            for next_x, next_y in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= next_x < rgba.width and 0 <= next_y < rgba.height:
                    if pixels[next_x, next_y][3] <= 0:
                        fringe.append((x, y))
                        break
    for x, y in fringe:
        pixels[x, y] = (0, 0, 0, 0)
    return rgba


def strip_label_pixels(image: Image.Image) -> Image.Image:
    cleaned = image.copy()
    pixels = cleaned.load()
    for y in range(cleaned.height):
        for x in range(cleaned.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha <= 0:
                continue
            if is_label_pixel(red, green, blue):
                pixels[x, y] = (0, 0, 0, 0)
    return cleaned


def sprite_density(image: Image.Image, axis: str, start: int, end: int) -> list[int]:
    pixels = image.load()
    width, height = image.size
    density: list[int] = []
    if axis == "column":
        for x in range(width):
            count = 0
            for y in range(start, end):
                red, green, blue, alpha = pixels[x, y]
                if alpha <= 0 or is_label_pixel(red, green, blue):
                    continue
                count += 1
            density.append(count)
        return density
    for y in range(height):
        count = 0
        for x in range(start, end):
            red, green, blue, alpha = pixels[x, y]
            if alpha <= 0 or is_label_pixel(red, green, blue):
                continue
            count += 1
        density.append(count)
    return density


def find_split_index(density: list[int], start: int, end: int) -> int:
    if start >= end:
        return start
    best_value = 10**9
    best_index = (start + end) // 2
    for index in range(start, end):
        if density[index] < best_value:
            best_value = density[index]
            best_index = index
    return best_index


def find_split_indices(density: list[int], count: int, margin_ratio: float = 0.08) -> list[int]:
    if count <= 1:
        return [0, len(density)]
    bounds = [0]
    for slot in range(1, count):
        expected = len(density) * slot // count
        half_window = max(2, int(len(density) * margin_ratio))
        zone_start = max(bounds[-1] + 1, expected - half_window)
        zone_end = min(len(density) - 1, expected + half_window)
        bounds.append(find_split_index(density, zone_start, max(zone_start + 1, zone_end)))
    bounds.append(len(density))
    return bounds


def left_label_boundary(image: Image.Image, top: int, bottom: int) -> int:
    density = sprite_density(image, "column", top, bottom)
    search_end = max(8, int(len(density) * 0.24))
    split = find_split_index(density, 0, search_end)
    return max(0, split + 1)


def top_label_boundary(image: Image.Image, left: int) -> int:
    density = sprite_density(image, "row", left, image.width)
    search_end = max(8, int(len(density) * 0.18))
    split = find_split_index(density, 0, search_end)
    return max(0, split + 1)


def crop_region(image: Image.Image, left: int, top: int, right: int, bottom: int) -> Image.Image:
    return image.crop((left, top, right, bottom))


def extract_sprite(image: Image.Image, remove_label_pixels: bool = True) -> Image.Image:
    body = strip_label_pixels(image) if remove_label_pixels else image.copy()
    bbox = body.getbbox()
    if bbox is None:
        return body
    return body.crop(bbox)


def _bbox_gap(left: tuple[int, int, int, int], right: tuple[int, int, int, int]) -> float:
    horizontal = max(0, max(left[0], right[0]) - min(left[2], right[2]))
    vertical = max(0, max(left[1], right[1]) - min(left[3], right[3]))
    return (horizontal * horizontal + vertical * vertical) ** 0.5


def extract_subject_components(image: Image.Image, keep_detached: bool = True) -> Image.Image:
    """Keep the main sprite and nearby detached effects, while dropping sheet labels."""
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    visited: set[tuple[int, int]] = set()
    components: list[tuple[list[tuple[int, int]], tuple[int, int, int, int]]] = []

    for y in range(rgba.height):
        for x in range(rgba.width):
            if (x, y) in visited or pixels[x, y][3] <= 0:
                continue
            pending: deque[tuple[int, int]] = deque([(x, y)])
            visited.add((x, y))
            points: list[tuple[int, int]] = []
            min_x = max_x = x
            min_y = max_y = y
            while pending:
                current_x, current_y = pending.popleft()
                points.append((current_x, current_y))
                min_x = min(min_x, current_x)
                max_x = max(max_x, current_x)
                min_y = min(min_y, current_y)
                max_y = max(max_y, current_y)
                for next_x, next_y in (
                    (current_x - 1, current_y - 1),
                    (current_x, current_y - 1),
                    (current_x + 1, current_y - 1),
                    (current_x - 1, current_y),
                    (current_x + 1, current_y),
                    (current_x - 1, current_y + 1),
                    (current_x, current_y + 1),
                    (current_x + 1, current_y + 1),
                ):
                    if not (0 <= next_x < rgba.width and 0 <= next_y < rgba.height):
                        continue
                    if (next_x, next_y) in visited or pixels[next_x, next_y][3] <= 0:
                        continue
                    visited.add((next_x, next_y))
                    pending.append((next_x, next_y))
            components.append((points, (min_x, min_y, max_x + 1, max_y + 1)))

    if not components:
        return rgba
    main_points, main_bbox = max(components, key=lambda component: len(component[0]))
    keep_distance = max(6.0, max(rgba.width, rgba.height) * 0.08)
    min_effect_area = max(3, int(len(main_points) * 0.00035))
    kept = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
    kept_pixels = kept.load()
    kept_boxes: list[tuple[int, int, int, int]] = []
    for points, bbox in components:
        if points is main_points or (
            keep_detached
            and len(points) >= min_effect_area
            and _bbox_gap(main_bbox, bbox) <= keep_distance
        ):
            kept_boxes.append(bbox)
            for point_x, point_y in points:
                kept_pixels[point_x, point_y] = pixels[point_x, point_y]
    left = min(box[0] for box in kept_boxes)
    top = min(box[1] for box in kept_boxes)
    right = max(box[2] for box in kept_boxes)
    bottom = max(box[3] for box in kept_boxes)
    return kept.crop((left, top, right, bottom))


def fit_canvas(image: Image.Image, canvas: tuple[int, int], padding: int = 0) -> Image.Image:
    bbox = image.getbbox()
    if bbox is None:
        return Image.new("RGBA", canvas, (0, 0, 0, 0))
    cropped = image.crop(bbox)
    fitted = Image.new("RGBA", canvas, (0, 0, 0, 0))
    usable_width = max(1, canvas[0] - padding * 2)
    usable_height = max(1, canvas[1] - padding * 2)
    scale = min(usable_width / cropped.width, usable_height / cropped.height)
    resized = cropped.resize(
        (max(1, int(round(cropped.width * scale))), max(1, int(round(cropped.height * scale)))),
        Image.Resampling.NEAREST,
    )
    offset = ((canvas[0] - resized.width) // 2, (canvas[1] - resized.height) // 2)
    fitted.paste(resized, offset, resized)
    return fitted


def count_background_color_pixels(
    image: Image.Image,
    reference: tuple[int, int, int],
    tolerance: float = BACKGROUND_DISTANCE,
) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha <= 0:
            continue
        if _matches_sheet_background((red, green, blue), reference, tolerance):
            count += 1
    return count


def clear_background_color_pixels(
    image: Image.Image,
    reference: tuple[int, int, int],
    tolerance: float = BACKGROUND_DISTANCE,
) -> int:
    """Clear isolated source-background remnants left after crop and resize."""
    pixels = image.load()
    cleared = 0
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha <= 0:
                continue
            if _matches_sheet_background((red, green, blue), reference, tolerance):
                pixels[x, y] = (0, 0, 0, 0)
                cleared += 1
    return cleared


def assert_clean_runtime_sprite(
    image: Image.Image,
    label: str,
    expected_size: tuple[int, int],
    background_reference: tuple[int, int, int] | None = None,
) -> None:
    if image.size != expected_size:
        raise RuntimeError(f"{label} expected {expected_size}, got {image.size}")
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise RuntimeError(f"{label} has no visible pixels")
    visible = sum(1 for value in alpha.getdata() if value > 0)
    coverage = visible / float(image.width * image.height)
    if coverage < 0.04:
        raise RuntimeError(f"{label} is suspiciously empty ({coverage:.1%} coverage)")
    if coverage > 0.82:
        raise RuntimeError(f"{label} is suspiciously rectangular ({coverage:.1%} coverage)")
    if background_reference is not None:
        remaining = count_background_color_pixels(image, background_reference)
        if remaining > 0:
            raise RuntimeError(f"{label} retains {remaining} source-background pixels")


def count_magenta_pixels(image: Image.Image) -> int:
    count = 0
    for red, green, blue, alpha in image.convert("RGBA").getdata():
        if alpha <= 0:
            continue
        if is_chroma_pixel(red, green, blue):
            count += 1
    return count


def assert_no_magenta(image: Image.Image, label: str) -> None:
    remaining = count_magenta_pixels(image)
    if remaining > 0:
        raise RuntimeError(f"{label} still has {remaining} magenta pixels after chroma key")


def archive_source_png(source_path: Path, archive_path: Path) -> None:
    source_path = source_path.resolve()
    archive_path = archive_path.resolve()
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    archive_path.parent.mkdir(parents=True, exist_ok=True)
    Image.open(source_path).convert("RGBA").save(archive_path, format="PNG", optimize=True)


def repair_pack_archives(root: Path) -> int:
    repaired = 0
    for path in sorted(root.rglob("*pack_source.png")):
        header = path.read_bytes()[:8]
        if header.startswith(b"\x89PNG\r\n\x1a\n"):
            continue
        archive_source_png(path, path)
        repaired += 1
        print(f"repaired {path}")
    return repaired
