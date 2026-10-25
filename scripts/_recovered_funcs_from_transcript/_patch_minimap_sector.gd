func _patch_minimap_sector(sector: Vector2i) -> void:
	if minimap_cache_image == null:
		_mark_minimap_dirty()
		return
	var sector_start := sector * 12
	for y in range(sector_start.y, sector_start.y + 12):
		for x in range(sector_start.x, sector_start.x + 12):
			var map_cell := Vector2i(x, y)
			if not grid.in_bounds(map_cell) or not grid.is_walkable(map_cell):
				continue
			_patch_minimap_cell(map_cell)
