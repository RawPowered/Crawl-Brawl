extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_boot_floor_budget_test")


func _count_boot_floor(grid: WORLD_GRID) -> int:
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


func _run_boot_floor_budget_test() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(707070, "bastion", false)
	var boot_floor := _count_boot_floor(grid)
	var realm_cells: int = (grid.width - 2) * (grid.height - 2)
	assert(float(boot_floor) / float(realm_cells) < 0.12, "Boot floor budget should stay sparse without the legacy spine")
	print("CRAWL_BRAWL_BOOT_FLOOR_BUDGET_TEST_OK")
	quit(0)
