extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_authored_region_topology_test")


func _count_floor_at_y(grid: WORLD_GRID, y: int) -> int:
	var total := 0
	for x in range(2, grid.width - 2):
		if grid.get_cell(Vector2i(x, y)) == WORLD_GRID.FLOOR:
			total += 1
	return total


func _count_floor_cells(grid: WORLD_GRID) -> int:
	var total := 0
	if grid.uses_sparse_cells():
		for region_value: Variant in grid._region_cells.keys():
			var region: Vector2i = region_value
			var bounds := grid._region_bounds(region)
			for y in range(bounds.position.y, bounds.end.y):
				for x in range(bounds.position.x, bounds.end.x):
					if grid.get_cell(Vector2i(x, y)) == WORLD_GRID.FLOOR:
						total += 1
		return total
	for cell_index in range(grid.cells.size()):
		if int(grid.cells[cell_index]) == WORLD_GRID.FLOOR:
			total += 1
	return total


func _distant_probe(grid: WORLD_GRID) -> Vector2i:
	var bootstrap := grid._bootstrap_bounds_rect()
	for region_value: Variant in grid._region_cells.keys():
		var region: Vector2i = region_value
		var bounds := grid._region_bounds(region)
		if bounds.intersects(bootstrap):
			continue
		return bounds.get_center()
	return Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.72), int(WORLD_GRID.REALM_HEIGHT * 0.66))


func _run_authored_region_topology_test() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(707070, "bastion", false)
	assert(grid.uses_lazy_topology(), "Mega realms should use lazy topology")
	var spine_y := int(floor(float(grid.height) / 2.0))
	var highway_floor := _count_floor_at_y(grid, spine_y)
	var realm_span := maxi(1, grid.width - 4)
	assert(float(highway_floor) / float(realm_span) <= 0.4, "Boot should not carve a horizontal highway across the realm")
	assert(grid._deferred_layout_specs.size() > 0, "Lazy realms should defer bunker bootstrap specs")
	var bootstrap_floor := _count_floor_cells(grid)
	var distant_cell := _distant_probe(grid)
	grid.activate_region_window([distant_cell], 1)
	assert(_count_floor_cells(grid) > bootstrap_floor, "Visiting a distant region should materialize regional topology")
	var repeat_grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	repeat_grid.generate_realm(707070, "bastion", false)
	repeat_grid.activate_region_window([distant_cell], 1)
	assert(_count_floor_cells(repeat_grid) == _count_floor_cells(grid), "Regional topology materialization should stay deterministic per seed")
	print("CRAWL_BRAWL_AUTHORED_REGION_TOPOLOGY_TEST_OK")
	quit(0)
