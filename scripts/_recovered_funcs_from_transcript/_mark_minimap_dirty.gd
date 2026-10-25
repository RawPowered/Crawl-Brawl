func _mark_minimap_dirty(delay: float = MINIMAP_REBUILD_DELAY) -> void:
	minimap_cache_dirty = true
	minimap_rebuild_cooldown = delay
