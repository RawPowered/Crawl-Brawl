func _flush_minimap_patches() -> void:
	if not minimap_patch_pending or minimap_cache_texture == null or minimap_cache_image == null:
		return
	if (_combat_frame_tick - _minimap_flush_frame) < 2:
		return
	_minimap_flush_frame = _combat_frame_tick
	minimap_cache_texture.update(minimap_cache_image)
	minimap_patch_pending = false
