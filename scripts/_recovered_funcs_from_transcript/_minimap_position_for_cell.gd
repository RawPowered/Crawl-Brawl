func _minimap_position_for_cell(cell: Vector2i) -> Vector2:
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	return map_rect.position + Vector2((float(cell.x) + 0.5) * map_rect.size.x / float(grid.width), (float(cell.y) + 0.5) * map_rect.size.y / float(grid.height))
