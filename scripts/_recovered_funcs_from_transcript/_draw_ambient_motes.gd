func _draw_ambient_motes(canvas: CanvasItem, visible_rect: Rect2) -> void:
	if not player_moving and _camera_stable_frames >= 2:
		return
	# Deterministic biome motes add motion without allocating or simulating particles.
