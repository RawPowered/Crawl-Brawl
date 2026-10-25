extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_lazy_region_topology_test")


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


func _distant_topology_probe(grid: WORLD_GRID) -> Vector2i:
	var bootstrap := grid._bootstrap_bounds_rect()
	for region_y in range(grid._region_rows()):
		for region_x in range(grid._region_columns()):
			var region := Vector2i(region_x, region_y)
			var bounds := grid._region_bounds(region)
			if bounds.intersects(bootstrap):
				continue
			return bounds.get_center()
	return Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.82), int(WORLD_GRID.REALM_HEIGHT * 0.72))


func _run_lazy_region_topology_test() -> void:
	assert(WORLD_GRID.REALM_WIDTH >= WORLD_GRID.LAZY_TOPOLOGY_MIN_WIDTH, "The current realm should enable lazy topology")
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(818181, "bastion", false)
	assert(grid.uses_lazy_topology(), "Mega realms should defer distant branch topology")
	var bootstrap_floor := _count_floor_cells(grid)
	assert(grid._deferred_layout_specs.size() > 0, "Lazy realms should keep bunker bootstrap deferred at boot")
	var distant_cell := _distant_topology_probe(grid)
	grid.activate_region_window([distant_cell], 1)
	var distant_floor := _count_floor_cells(grid)
	assert(distant_floor > bootstrap_floor, "Visiting a distant region should materialize its regional topology")
	assert(grid.is_region_loaded(distant_cell), "Distant region streaming should mark the active window")
	var repeat_grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	repeat_grid.generate_realm(818181, "bastion", false)
	repeat_grid.activate_region_window([distant_cell], 1)
	assert(_count_floor_cells(repeat_grid) == distant_floor, "Lazy topology materialization should stay deterministic per seed")
	print("CRAWL_BRAWL_LAZY_REGION_TOPOLOGY_TEST_OK")
	quit(0)
