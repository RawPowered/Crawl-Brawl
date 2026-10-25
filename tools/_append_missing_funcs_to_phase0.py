import re
import pathlib


PHASE0_RUN = r"D:\PROJECTS\Crawl Brawl\scripts\phase0_run.gd"
RECOVERED_DIR = r"D:\PROJECTS\Crawl Brawl\scripts\_recovered_funcs_from_transcript"


FUNCS_TO_ADD = [
    "_weapon_hud_icon",
    "_holster_cutter_icon",
    "_hotbar_stack_icon",
    "_build_chest_panel",
    "_refresh_chest_panel",
    "_chest_deposit_all",
    "_chest_withdraw_all",
    "_fill_chest_material_list",
    "_open_chest",
    "_close_chest",
    "_nearby_chest",
    "_base_short_name",
    "_hud_base_order",
    "_enemies_near_base",
    "_refresh_bases_under_attack_cache",
    "_base_is_under_attack",
    "_active_turret_hunter_count",
    "_hunters_targeting_cell",
    "_draw_base_network_cards",
    "_draw_base_alert_indicators",
    "_hotbar_slot_label",
    "_draw_holster_chip",
    "_draw_hotbar",
    "_mark_minimap_dirty",
    "_minimap_position_for_cell",
    "_minimap_edge_marker_for_cell",
    "_draw_minimap_edge_tick",
    "_minimap_enemy_visible",
    "_draw_minimap",
]


def main() -> None:
    phase_text = pathlib.Path(PHASE0_RUN).read_text(encoding="utf-8", errors="replace")
    existing = set(re.findall(r"^func\s+(_[A-Za-z0-9_]+)\b", phase_text, flags=re.M))

    extra_blocks = []
    if "_draw_camera_vignette" not in existing:
        extra_blocks.append(
            "func _draw_camera_vignette(canvas: CanvasItem, visible_rect: Rect2) -> void:\n"
            "\t# Five cheap hard-edged bands echo the menu's deep framing without a shader.\n"
            "\tfor band in range(5):\n"
            "\t\tvar inset := float(band * 7)\n"
            "\t\tvar alpha := 0.052 - float(band) * 0.007\n"
            "\t\tvar inner := visible_rect.grow(-inset)\n"
            "\t\tvar strip_color := Color(0.002, 0.008, 0.013, alpha)\n"
            "\t\tcanvas.draw_rect(Rect2(inner.position, Vector2(inner.size.x, 7)), strip_color)\n"
            "\t\tcanvas.draw_rect(Rect2(inner.position + Vector2(0, inner.size.y - 7), Vector2(inner.size.x, 7)), strip_color)\n"
            "\t\tcanvas.draw_rect(Rect2(inner.position, Vector2(7, inner.size.y)), strip_color)\n"
            "\t\tcanvas.draw_rect(Rect2(inner.position + Vector2(inner.size.x - 7, 0), Vector2(7, inner.size.y)), strip_color)\n"
        )
    if "_torch_reveals_position" not in existing:
        extra_blocks.append(
            "func _torch_reveals_position(_world_pos: Vector2) -> bool:\n"
            "\t# Minimal safe fallback; if torch-vision exists elsewhere, replace this.\n"
            "\treturn false\n"
        )

    to_add = []
    for fn in FUNCS_TO_ADD:
        if fn in existing:
            continue
        p = pathlib.Path(RECOVERED_DIR) / f"{fn}.gd"
        if not p.exists():
            raise SystemExit(f"Missing extracted file for {fn}: {p}")
        to_add.append(p.read_text(encoding="utf-8", errors="replace").rstrip() + "\n")

    if not to_add and not extra_blocks:
        print("nothing to append")
        return

    new_text = phase_text.rstrip() + "\n\n" + "\n\n".join(to_add + extra_blocks)
    pathlib.Path(PHASE0_RUN).write_text(new_text, encoding="utf-8")
    print(f"appended funcs={len(to_add)} extra={len(extra_blocks)}")


if __name__ == "__main__":
    main()

