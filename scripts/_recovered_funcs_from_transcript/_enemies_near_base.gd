func _enemies_near_base(base_id: String, radius: float = 112.0) -> bool:
	var center: Vector2 = grid.cell_to_world(base_network.get_cell(base_id))
	for spider in enemies:
		if spider.position.distance_to(center) <= radius:
			return true
	return false
