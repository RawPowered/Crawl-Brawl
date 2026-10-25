func _draw_holster_chip(canvas: CanvasItem, font: Font, rect: Rect2, label: String, selected: bool, filled: bool, icon: Texture2D = null, count: int = 0, show_index: bool = false) -> void:
	var slot_texture := "hud_slot_cyan" if selected else ("hud_slot_dark" if filled else "hud_slot_locked")
	if not USE_IMPORTED_HUD_SKINS or not _draw_ui_nine_patch(canvas, slot_texture, rect, 3.0, HUD_CHROME_TINT):
		canvas.draw_rect(rect, Color(0.02, 0.06, 0.08, 0.96) if selected else (Color(0.015, 0.04, 0.05, 0.94) if filled else Color(0.008, 0.018, 0.022, 0.88)))
		canvas.draw_rect(rect, RealmVisualStyleScript.CYAN if selected else (Color("4a6e78") if filled else Color("26383d")), false, 2.0 if selected else 1.0)
	if selected:
		canvas.draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2)), RealmVisualStyleScript.CYAN)
	if icon != null:
		var pad := 3.0 if not show_index else 4.0
		var icon_size := minf(rect.size.x, rect.size.y) - pad
		var icon_rect := Rect2(rect.get_center() - Vector2(icon_size, icon_size) * 0.5 + Vector2(0, 1), Vector2(icon_size, icon_size))
		canvas.draw_texture_rect(icon, icon_rect, false, Color.WHITE if selected else Color(0.82, 0.9, 0.92, 0.94))
	elif filled:
		canvas.draw_string(font, rect.position + Vector2(3, 8), label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 4, 7, Color("dff8fb") if selected else Color("77949b"))
	if show_index:
		canvas.draw_string(font, rect.position + Vector2(1, 6), label, HORIZONTAL_ALIGNMENT_LEFT, 10, 6, RealmVisualStyleScript.CYAN if selected else Color("72949a"))
	if count > 1:
		canvas.draw_string(font, rect.position + Vector2(rect.size.x - 12, rect.size.y - 3), str(count), HORIZONTAL_ALIGNMENT_RIGHT, 12, 6, Color("ffd36b"))
