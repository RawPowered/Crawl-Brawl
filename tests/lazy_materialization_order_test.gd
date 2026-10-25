extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_lazy_materialization_order_test")


func _sample_regions(grid: WORLD_GRID) -> Array[Vector2i]:
	var regions: Array[Vector2i] = []
	var bootstrap := grid._bootstrap_bounds_rect()
	var probe_cells: Array[Vector2i] = [
		Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.42), grid.core_cell.y),
		Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.58), grid.core_cell.y),
		Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.72), int(WORLD_GRID.REALM_HEIGHT * 0.66)),
	]
	for cell: Vector2i in probe_cells:
		if not grid.in_bounds(cell):
			continue
		var region: Vector2i = grid.region_for_cell(cell)
		if regions.has(region):
			continue
		if region == grid.region_for_cell(bootstrap.get_center()):
			continue
		regions.append(region)
	assert(regions.size() >= 2, "Lazy materialization test needs multiple distant regions")
	return regions


func _signature_for_regions(seed: int, regions: Array[Vector2i]) -> int:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(seed, "bastion")
	grid.configure_discoveries(seed, "bastion")
	var visited: Dictionary = {}
	for region: Vector2i in regions:
		visited[region] = true
	grid.restore_visited_regions_for_load(visited)
	return grid.terrain_signature()


func _run_lazy_materialization_order_test() -> void:
	var seed := 515151
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(seed, "bastion")
	assert(grid.uses_lazy_topology(), "Mega realms should use lazy topology for load materialization")

	var regions := _sample_regions(grid)
	var forward_signature := _signature_for_regions(seed, regions)
	var reversed_regions: Array[Vector2i] = regions.duplicate()
	reversed_regions.reverse()
	var reverse_signature := _signature_for_regions(seed, reversed_regions)
	assert(forward_signature == reverse_signature, "Visited-region restore must materialize deterministically regardless of dict order")

	var shuffled_regions: Array[Vector2i] = [regions[1], regions[0]]
	if regions.size() > 2:
		shuffled_regions.append(regions[2])
	var shuffled_signature := _signature_for_regions(seed, shuffled_regions)
	assert(shuffled_signature == forward_signature, "Materialization order should stay stable for the same visited set")

	var mined_cell := Vector2i(-1, -1)
	var bootstrap := grid._bootstrap_bounds_rect()
	for y in range(bootstrap.position.y + 1, bootstrap.end.y - 1):
		for x in range(bootstrap.position.x + 1, bootstrap.end.x - 1):
			var candidate := Vector2i(x, y)
			if grid.can_mine(candidate) and not grid.is_start_chamber_reserved(candidate):
				mined_cell = candidate
				break
		if mined_cell.x >= 0:
			break
	assert(mined_cell.x >= 0, "Bootstrap should expose a mineable rock cell")
	assert(grid.open_cell(mined_cell), "Mining should create a terrain delta")

	var reload = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	reload.generate_realm(seed, "bastion")
	reload.configure_discoveries(seed, "bastion")
	reload.restore_visited_regions_for_load({grid.region_for_cell(mined_cell): true})
	reload.restore_cell_deltas(grid.cell_deltas)
	assert(reload.is_walkable(mined_cell), "Cell deltas must apply after visited-region materialization")

	print("CRAWL_BRAWL_LAZY_MATERIALIZATION_ORDER_TEST_OK")
	quit(0)
