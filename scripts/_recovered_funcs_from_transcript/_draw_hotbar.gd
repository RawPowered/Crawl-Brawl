func _draw_hotbar(canvas: CanvasItem) -> void:
	var font: Font = ThemeDB.fallback_font
	if operator_loadout == null:
		return
	var origin := RealmVisualStyleScript.HUD_WEAPON_START
	var card_h: float = RealmVisualStyleScript.HUD_WEAPON_CARD_SIZE.y
	var x := origin.x
	var cutter_rect := Rect2(x, origin.y, RealmVisualStyleScript.HUD_WEAPON_CUTTER_WIDTH, card_h)
	var cutter_on := operator_loadout.is_cutter_selected()
	_draw_holster_chip(canvas, font, cutter_rect, "CUT", cutter_on, true)
	x += RealmVisualStyleScript.HUD_WEAPON_CUTTER_WIDTH + 2.0
	var gun_step: float = RealmVisualStyleScript.HUD_WEAPON_CARD_STEP
	for gun_i in range(operator_loadout.gun_slot_count()):
		var rect := Rect2(x, origin.y, gun_step - 2.0, card_h)
		var wid: int = operator_loadout.holster_guns[gun_i]
		var selected := operator_loadout.holster_index == gun_i + 1
		var label := WEAPON_HUD_LABELS[wid] if wid >= 0 and wid < WEAPON_HUD_LABELS.size() else "-"
		_draw_holster_chip(canvas, font, rect, label, selected, wid >= 0)
		x += gun_step
	x += 6.0
	var pip: float = RealmVisualStyleScript.HUD_WEAPON_BUILD_PIP
	for build_i in range(operator_loadout.build_slot_count()):
		var rect := Rect2(x, origin.y, pip - 1.0, card_h)
		var stack: Dictionary = operator_loadout.hotbar[build_i]
		var selected := build_i == operator_loadout.hotbar_index
		var filled := str(stack.get("kind", OperatorLoadoutScript.KIND_EMPTY)) != OperatorLoadoutScript.KIND_EMPTY
		var slot_texture := "hud_slot_cyan" if selected else ("hud_slot_dark" if filled else "hud_slot_locked")
		if not USE_IMPORTED_HUD_SKINS or not _draw_ui_nine_patch(canvas, slot_texture, rect, 3.0, HUD_CHROME_TINT):
			canvas.draw_rect(rect, Color(0.015, 0.04, 0.05, 0.94) if filled else Color(0.008, 0.018, 0.022, 0.88))
			canvas.draw_rect(rect, RealmVisualStyleScript.CYAN if selected else (Color("38545c") if filled else Color("26383d")), false, 1.0)
		canvas.draw_string(font, rect.position + Vector2(2, 7), str(build_i + 1), HORIZONTAL_ALIGNMENT_LEFT, 10, 6, RealmVisualStyleScript.CYAN if selected else Color("72949a"))
		var count := int(stack.get("count", 0))
		if count > 1:
			canvas.draw_string(font, rect.position + Vector2(1, 18), str(count), HORIZONTAL_ALIGNMENT_LEFT, 12, 6, Color("ffd36b"))
		x += pip
