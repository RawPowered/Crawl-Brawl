func _draw_minimap(canvas: CanvasItem) -> void:
	var font: Font = ThemeDB.fallback_font
	var card := RealmVisualStyleScript.HUD_MINIMAP_CARD
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	if not USE_IMPORTED_HUD_SKINS or not _draw_ui_nine_patch(canvas, "hud_display_panel", card, 8.0, HUD_CHROME_TINT):
		if not _draw_ui_texture_rect(canvas, "hud_window_square", card):
			canvas.draw_rect(card, Color(0.005, 0.018, 0.024, 0.95))
			canvas.draw_rect(card, RealmVisualStyleScript.PANEL_BORDER, false, 1.0)
	canvas.draw_rect(Rect2(card.position, Vector2(card.size.x, 2)), RealmVisualStyleScript.CYAN)
	canvas.draw_string(
		font,
		card.position + Vector2(5, 14),
		"TACTICAL MAP // %02d/%02d" % [explored_sectors.size(), total_survey_sectors],
		HORIZONTAL_ALIGNMENT_LEFT,
		card.size.x - 10,
		8,
		Color("a9cbd1")
	)
	canvas.draw_rect(map_rect, Color("071116"))
	if minimap_cache_texture == null:
		_mark_minimap_dirty(0.0)
	if minimap_cache_texture != null:
		canvas.draw_texture_rect(minimap_cache_texture, map_rect, false)
	var sweep_x := map_rect.position.x + map_rect.size.x * hud_minimap_sweep
	canvas.draw_line(Vector2(sweep_x, map_rect.position.y), Vector2(sweep_x, map_rect.end.y), Color(0.55, 0.9, 1.0, 0.18), 1.0)
	if hud_minimap_bloom > 0.0:
		var bloom_pos = _minimap_position_for_cell(hud_minimap_bloom_cell)
		if bloom_pos != null:
			canvas.draw_circle(bloom_pos, 4.0 + hud_minimap_bloom * 3.0, Color("8eeaff", hud_minimap_bloom * 0.55))
	for spider: Spider in enemies:
		if not _minimap_enemy_visible(spider):
			continue
		var enemy_pos = _minimap_position_for_cell(grid.world_to_cell(spider.position))
		if enemy_pos == null:
			continue
		canvas.draw_circle(enemy_pos, 1.6, Color("ef675f", 0.95))
	for base_id: String in _hud_base_order():
		var record: Dictionary = base_network.get_base(base_id)
		if not bool(record.get("revealed", false)):
			continue
		var cell: Vector2i = record["cell"]
		var marker = _minimap_position_for_cell(cell)
		var color := RealmVisualStyleScript.CYAN if base_id == BaseNetworkScript.COMMAND_ID else Color("72e8ff")
		if marker == null:
			marker = _minimap_edge_marker_for_cell(cell)
			_draw_minimap_edge_tick(canvas, marker, color, cell)
		else:
			canvas.draw_rect(Rect2(marker - Vector2(1.5, 1.5), Vector2(3, 3)), color)
	var player_marker = _minimap_position_for_cell(grid.world_to_cell(player_position))
	if player_marker != null:
		canvas.draw_circle(player_marker, 2.2, Color("dff8fb"))
