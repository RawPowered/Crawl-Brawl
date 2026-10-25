class_name CombatSpatial
extends RefCounted

const CELL_SIZE := 48.0


static func bucket_key(at_position: Vector2) -> Vector2i:
	return Vector2i(floori(at_position.x / CELL_SIZE), floori(at_position.y / CELL_SIZE))


static func rebuild_enemy_buckets(buckets: Dictionary, enemies: Array) -> void:
	buckets.clear()
	for enemy_index in range(enemies.size()):
		var spider: Object = enemies[enemy_index]
		var key := bucket_key(spider.position)
		if not buckets.has(key):
			buckets[key] = []
		buckets[key].append(enemy_index)


static func rebuild_structure_buckets(buckets: Dictionary, structures: Array) -> void:
	buckets.clear()
	for structure_index in range(structures.size()):
		var structure: Object = structures[structure_index]
		var key := bucket_key(structure.position)
		if not buckets.has(key):
			buckets[key] = []
		buckets[key].append(structure_index)


static func collect_enemy_indices(buckets: Dictionary, at_position: Vector2, neighbor_radius: int = 1) -> Array[int]:
	var result: Array[int] = []
	var center := bucket_key(at_position)
	for ox in range(-neighbor_radius, neighbor_radius + 1):
		for oy in range(-neighbor_radius, neighbor_radius + 1):
			var key := center + Vector2i(ox, oy)
			if not buckets.has(key):
				continue
			for enemy_index: int in buckets[key]:
				result.append(enemy_index)
	return result


static func collect_structure_indices(buckets: Dictionary, at_position: Vector2, neighbor_radius: int = 1) -> Array[int]:
	var result: Array[int] = []
	var center := bucket_key(at_position)
	for ox in range(-neighbor_radius, neighbor_radius + 1):
		for oy in range(-neighbor_radius, neighbor_radius + 1):
			var key := center + Vector2i(ox, oy)
			if not buckets.has(key):
				continue
			for structure_index: int in buckets[key]:
				result.append(structure_index)
	return result


static func enemy_near_position(buckets: Dictionary, at_position: Vector2, radius: float, enemies: Array) -> bool:
	var probe_radius := maxi(1, ceili(radius / CELL_SIZE) + 1)
	for enemy_index: int in collect_enemy_indices(buckets, at_position, probe_radius):
		var spider: Object = enemies[enemy_index]
		if at_position.distance_to(spider.position) <= radius:
			return true
	return false


static func nearest_enemy_index(
	buckets: Dictionary,
	at_position: Vector2,
	max_distance: float,
	enemies: Array,
	neighbor_radius: int = 2
) -> int:
	var best_index := -1
	var best_distance := max_distance
	for enemy_index: int in collect_enemy_indices(buckets, at_position, neighbor_radius):
		var spider: Object = enemies[enemy_index]
		var distance: float = at_position.distance_to(spider.position)
		if distance < best_distance:
			best_distance = distance
			best_index = enemy_index
	return best_index
