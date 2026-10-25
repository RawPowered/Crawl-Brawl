class_name FlowField
extends RefCounted

const WorldGridScript := preload("res://systems/world_grid.gd")

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.UP,
]

var distance := PackedInt32Array()
var target := Vector2i.ZERO
var grid: WorldGridScript
var last_visit_count := 0
var _region_distance: Dictionary = {}
var _uses_regional_maps := false


func rebuild(world_grid: WorldGridScript, target_cell: Vector2i, allowed_regions: Dictionary = {}) -> void:
	_rebuild_internal(world_grid, target_cell, Callable(), allowed_regions)


func rebuild_with_blocker(world_grid: WorldGridScript, target_cell: Vector2i, blocked: Callable, allowed_regions: Dictionary = {}) -> void:
	_rebuild_internal(world_grid, target_cell, blocked, allowed_regions)


func _uses_sparse_flow(world_grid: WorldGridScript) -> bool:
	return world_grid.uses_sparse_cells()


func _region_local_index(cell: Vector2i) -> int:
	return posmod(cell.x, WorldGridScript.REGION_SIZE) + posmod(cell.y, WorldGridScript.REGION_SIZE) * WorldGridScript.REGION_SIZE


func _ensure_region_map(region: Vector2i) -> PackedInt32Array:
	if not _region_distance.has(region):
		var region_map := PackedInt32Array()
		region_map.resize(WorldGridScript.REGION_SIZE * WorldGridScript.REGION_SIZE)
		region_map.fill(-1)
		_region_distance[region] = region_map
	return _region_distance[region]


func _get_distance(cell: Vector2i) -> int:
	if _uses_regional_maps:
		var region := grid.region_for_cell(cell)
		if not _region_distance.has(region):
			return -1
		return int(_region_distance[region][_region_local_index(cell)])
	if not grid.in_bounds(cell) or distance.is_empty():
		return -1
	return distance[grid.index(cell)]


func _set_distance(cell: Vector2i, value: int) -> void:
	if _uses_regional_maps:
		var region := grid.region_for_cell(cell)
		var region_map := _ensure_region_map(region)
		region_map[_region_local_index(cell)] = value
		return
	distance[grid.index(cell)] = value


func _rebuild_internal(world_grid: WorldGridScript, target_cell: Vector2i, blocked: Callable, allowed_regions: Dictionary = {}) -> void:
	grid = world_grid
	target = target_cell
	last_visit_count = 0
	_uses_regional_maps = _uses_sparse_flow(world_grid)
	if _uses_regional_maps:
		_region_distance.clear()
	else:
		distance.resize(grid.width * grid.height)
		distance.fill(-1)
	if not _is_passable(target_cell, blocked, allowed_regions):
		return

	var frontier: Array[Vector2i] = [target_cell]
	var head := 0
	_set_distance(target_cell, 0)
	last_visit_count = 1
	while head < frontier.size():
		var current := frontier[head]
		head += 1
		var next_distance := _get_distance(current) + 1
		for direction in DIRECTIONS:
			var neighbor := current + direction
			if not _is_passable(neighbor, blocked, allowed_regions):
				continue
			if _get_distance(neighbor) >= 0:
				continue
			_set_distance(neighbor, next_distance)
			frontier.append(neighbor)
			last_visit_count += 1


func _is_passable(cell: Vector2i, blocked: Callable, allowed_regions: Dictionary = {}) -> bool:
	if grid == null or not grid.in_bounds(cell) or not grid.is_walkable(cell):
		return false
	if not allowed_regions.is_empty() and not allowed_regions.has(grid.region_for_cell(cell)):
		return false
	return blocked.is_null() or not bool(blocked.call(cell))


func has_path(from_cell: Vector2i) -> bool:
	return grid != null and grid.in_bounds(from_cell) and _get_distance(from_cell) >= 0


func next_cell(from_cell: Vector2i) -> Vector2i:
	return best_passable_next(from_cell, Callable())


func best_passable_next(from_cell: Vector2i, blocked: Callable) -> Vector2i:
	## Prefer downhill. If blocked, allow sideways/uphill escape. Never foot-aim unless trapped.
	if not has_path(from_cell):
		return from_cell
	var current_distance := _get_distance(from_cell)
	if current_distance <= 0:
		return from_cell
	var downhill := from_cell
	var downhill_distance := current_distance
	var escape := from_cell
	var escape_distance := 1_000_000_000
	for direction in DIRECTIONS:
		var candidate := from_cell + direction
		if not _is_passable(candidate, blocked):
			continue
		var candidate_distance := _get_distance(candidate)
		if candidate_distance < 0:
			continue
		if candidate_distance < downhill_distance:
			downhill_distance = candidate_distance
			downhill = candidate
		if candidate_distance < escape_distance:
			escape_distance = candidate_distance
			escape = candidate
	if downhill != from_cell:
		return downhill
	return escape


func ranked_passable_neighbors(from_cell: Vector2i, blocked: Callable) -> Array[Vector2i]:
	## Passable neighbors sorted by flow distance ascending (downhill first, then escape).
	var ranked: Array[Vector2i] = []
	var distances: Array[int] = []
	if not has_path(from_cell):
		return ranked
	for direction in DIRECTIONS:
		var candidate := from_cell + direction
		if not _is_passable(candidate, blocked):
			continue
		var candidate_distance := _get_distance(candidate)
		if candidate_distance < 0:
			continue
		var insert_at := distances.size()
		for i in range(distances.size()):
			if candidate_distance < distances[i]:
				insert_at = i
				break
		ranked.insert(insert_at, candidate)
		distances.insert(insert_at, candidate_distance)
	return ranked
