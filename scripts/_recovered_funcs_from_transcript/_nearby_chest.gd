func _nearby_chest() -> int:
	var best_index := -1
	var best_distance := 48.0
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind not in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
			continue
		if structure.health <= 0.0:
			continue
		var distance := structure.position.distance_to(player_position)
		if distance <= best_distance:
			best_distance = distance
			best_index = structure_index
	return best_index
