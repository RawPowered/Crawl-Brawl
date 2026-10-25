func _minimap_edge_marker_for_cell(cell: Vector2i) -> Vector2:
	var in_view = _minimap_position_for_cell(cell)
	if in_view != null:
		return in_view
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	var center := map_rect.get_center()
	var player_cell := grid.world_to_cell(player_position)
	var delta := Vector2(cell - player_cell)
	if delta.length_squared() < 0.001:
		return center
	var dir := delta.normalized()
	var half := map_rect.size * 0.5 - Vector2(2.5, 2.5)
	var scale_x := half.x / absf(dir.x) if absf(dir.x) > 0.0001 else INF
	var scale_y := half.y / absf(dir.y) if absf(dir.y) > 0.0001 else INF
	return center + dir * minf(scale_x, scale_y)
