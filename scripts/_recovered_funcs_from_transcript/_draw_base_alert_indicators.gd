func _draw_base_alert_indicators(canvas: CanvasItem) -> void:
	for base_id: String in base_network.active_ids():
		if not _base_is_under_attack(base_id) and float(hud_base_attack_flash.get(base_id, 0.0)) <= 0.0:
			continue
		var cell: Vector2i = base_network.get_cell(base_id)
		var marker := _minimap_edge_marker_for_cell(cell)
		var pulse := 2.2 + sin(Time.get_ticks_msec() * 0.02) * 1.1
		canvas.draw_circle(marker, pulse, Color("ef675f", 0.9))
		_draw_minimap_edge_tick(canvas, marker, Color("ff9c8f"), cell)
