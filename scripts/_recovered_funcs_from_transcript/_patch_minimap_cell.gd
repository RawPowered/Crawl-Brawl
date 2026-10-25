func _patch_minimap_cell(cell: Vector2i) -> void:
	if minimap_cache_texture == null:
		_mark_minimap_dirty(0.0)
		return
	var image := minimap_cache_texture.get_image()
	if image == null:
		_mark_minimap_dirty(0.0)
		return
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	var cache_width := int(map_rect.size.x)
	var cache_height := int(map_rect.size.y)
	var scale_x := float(cache_width) / float(grid.width)
	var scale_y := float(cache_height) / float(grid.height)
	var pixel := Vector2i(clampi(floori(cell.x * scale_x), 0, cache_width - 1), clampi(floori(cell.y * scale_y), 0, cache_height - 1))
	image.set_pixel(pixel.x, pixel.y, _minimap_color_for_cell(cell))
	minimap_cache_texture.update(image)
