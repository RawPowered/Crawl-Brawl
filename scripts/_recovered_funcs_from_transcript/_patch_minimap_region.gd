func _patch_minimap_region(region: Vector2i) -> void:
	if minimap_cache_image == null:
		_mark_minimap_dirty()
		return
	var region_start := region * WorldGridScript.REGION_SIZE
	var region_end := Vector2i(
		mini(grid.width, region_start.x + WorldGridScript.REGION_SIZE),
		mini(grid.height, region_start.y + WorldGridScript.REGION_SIZE)
	)
	for y in range(maxi(0, region_start.y), region_end.y):
		for x in range(maxi(0, region_start.x), region_end.x):
			var map_cell := Vector2i(x, y)
			if not _sector_is_explored(map_cell) or not grid.is_walkable(map_cell):
				continue
			_patch_minimap_cell(map_cell)
