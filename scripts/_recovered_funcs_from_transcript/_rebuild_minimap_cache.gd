func _rebuild_minimap_cache() -> void:
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	var cache_width := int(map_rect.size.x)
	var cache_height := int(map_rect.size.y)
	var image := Image.create(cache_width, cache_height, false, Image.FORMAT_RGBA8)
	image.fill(Color("071116"))
	var scale_x := float(cache_width) / float(grid.width)
	var scale_y := float(cache_height) / float(grid.height)
	for visited_region_value: Variant in grid.visited_regions.keys():
		var visited_region: Vector2i = visited_region_value
		var region_start := visited_region * WorldGridScript.REGION_SIZE
		var region_end := Vector2i(mini(grid.width, region_start.x + WorldGridScript.REGION_SIZE), mini(grid.height, region_start.y + WorldGridScript.REGION_SIZE))
		for y in range(region_start.y, region_end.y):
			for x in range(region_start.x, region_end.x):
				var map_cell := Vector2i(x, y)
				if not _sector_is_explored(map_cell) or not grid.is_walkable(map_cell):
					continue
				var pixel := Vector2i(clampi(floori(x * scale_x), 0, cache_width - 1), clampi(floori(y * scale_y), 0, cache_height - 1))
				image.set_pixel(pixel.x, pixel.y, _minimap_color_for_cell(map_cell))
	minimap_cache_image = image
	minimap_cache_texture = ImageTexture.create_from_image(image)
	minimap_patch_pending = false
	minimap_cache_dirty = false
