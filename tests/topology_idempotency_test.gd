extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_topology_idempotency_test")


func _region_floor_count(grid: WORLD_GRID, region: Vector2i) -> int:
	var total := 0
	var bounds := grid._region_bounds(region)
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			if grid.get_cell(Vector2i(x, y)) == WORLD_GRID.FLOOR:
				total += 1
	return total


func _run_topology_idempotency_test() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(616161, "bastion", false)
	var region := Vector2i(8, 4)
	grid.populate_region_exploration(region)
	var first_count := _region_floor_count(grid, region)
	grid.populate_region_exploration(region)
	assert(_region_floor_count(grid, region) == first_count, "Repopulate must not add duplicate topology floor")
	print("CRAWL_BRAWL_TOPOLOGY_IDEMPOTENCY_TEST_OK")
	quit(0)
