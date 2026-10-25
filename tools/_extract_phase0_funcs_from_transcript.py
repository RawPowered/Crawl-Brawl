import json
import os
import re
from typing import Dict, List, Tuple, Optional


TRANSCRIPT_ROOT = os.environ.get("CRAWL_BRAWL_TRANSCRIPTS", "")
OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts", "_recovered_funcs_from_transcript")

TARGETS = [
    "_build_chest_panel",
    "_open_chest",
    "_close_chest",
    "_refresh_chest_panel",
    "_chest_deposit_all",
    "_chest_withdraw_all",
    "_fill_chest_material_list",
    "_nearby_chest",
    "_base_short_name",
    "_hud_base_order",
    "_enemies_near_base",
    "_refresh_bases_under_attack_cache",
    "_base_is_under_attack",
    "_hotbar_slot_label",
    "_draw_holster_chip",
    "_weapon_hud_icon",
    "_holster_cutter_icon",
    "_hotbar_stack_icon",
    "_draw_hotbar",
    "_mark_minimap_dirty",
    "_minimap_view_size",
    "_minimap_view_origin_for",
    "_minimap_local_pixel",
    "_minimap_position_for_cell",
    "_minimap_edge_marker_for_cell",
    "_draw_minimap_edge_tick",
    "_minimap_enemy_visible",
    "_rebuild_minimap_cache",
    "_minimap_color_for_cell",
    "_sector_is_explored",
    "_minimap_terrain_pixel_color",
    "_patch_minimap_cell",
    "_patch_minimap_sector",
    "_patch_minimap_region",
    "_flush_minimap_patches",
    "_draw_minimap",
    "_draw_base_network_cards",
    "_active_turret_hunter_count",
    "_hunters_targeting_cell",
    "_draw_base_alert_indicators",
    "_draw_camera_vignette",
    "_draw_ambient_motes",
]


def ensure_dir(p: str) -> None:
    os.makedirs(p, exist_ok=True)


def iter_json_strings(obj):
    if isinstance(obj, dict):
        for v in obj.values():
            yield from iter_json_strings(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from iter_json_strings(v)
    elif isinstance(obj, str):
        yield obj


def extract_func_block(text: str, func_name: str) -> Optional[str]:
    # Line-based extraction: start at `func <name>` and stop when we hit a new
    # top-level (column-0) line that isn't whitespace/blank and isn't a comment,
    # because transcript snippets sometimes include markdown commentary after
    # the real function ends.
    lines = text.splitlines(True)  # keep line endings
    signature = f"func {func_name}"
    start = None
    for i, line in enumerate(lines):
        # Function signature lines start at column 0 in GDScript.
        if line.startswith(signature):
            start = i
            break
    if start is None:
        return None

    end = start + 1
    while end < len(lines):
        line = lines[end]
        if line.startswith("func "):
            # Next top-level function begins.
            break
        if line.startswith("\t") or line.startswith(" ") or line.strip() == "" or line.startswith("#"):
            end += 1
            continue
        # Any other column-0 line is almost certainly markdown/non-code.
        break

    block = "".join(lines[start:end]).rstrip() + "\n"
    if not block.startswith(signature):
        return None
    return block


def main() -> None:
    if not TRANSCRIPT_ROOT:
        raise SystemExit("Set CRAWL_BRAWL_TRANSCRIPTS to the transcript folder before running this recovery utility.")
    ensure_dir(OUT_DIR)
    # Keep the longest extracted block per func.
    best: Dict[str, Tuple[int, str]] = {}

    jsonl_paths: List[str] = []
    for dp, _, fs in os.walk(TRANSCRIPT_ROOT):
        for f in fs:
            if f.endswith(".jsonl"):
                jsonl_paths.append(os.path.join(dp, f))

    if not jsonl_paths:
        raise SystemExit(f"No transcript jsonl files found under {TRANSCRIPT_ROOT}")

    for transcript_path in jsonl_paths:
        with open(transcript_path, "r", encoding="utf-8", errors="replace") as fh:
            for line in fh:
                try:
                    obj = json.loads(line)
                except Exception:
                    continue
                for s in iter_json_strings(obj):
                    for fn in TARGETS:
                        marker = f"func {fn}"
                        if marker not in s:
                            continue
                        block = extract_func_block(s, fn)
                        if not block:
                            continue
                        if fn not in best or len(block) > best[fn][0]:
                            best[fn] = (len(block), block)

    for fn in TARGETS:
        if fn not in best:
            print(f"MISS {fn}")
            continue
        _, block = best[fn]
        out_path = os.path.join(OUT_DIR, f"{fn}.gd")
        with open(out_path, "w", encoding="utf-8") as w:
            w.write(block)
        print(f"OK {fn} -> {out_path} ({len(block)} chars)")


if __name__ == "__main__":
    main()

