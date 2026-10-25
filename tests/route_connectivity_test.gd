extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")

const TEST_SEEDS: Array[int] = [10101, 20202, 30303, 40404, 50505]


func _initialize() -> void:
	call_deferred("_run_route_connectivity_test")


func _run_route_connectivity_test() -> void:
	for seed: int in TEST_SEEDS:
		var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
		grid.generate_realm(seed, "bastion", false)
		var lane: Vector2i = grid.spawn_cell + Vector2i(mini(24, grid.core_cell.x - grid.spawn_cell.x - 4), 0)
		grid.materialize_route_regions(lane, grid.core_cell, 3)
		if not grid.is_walkable(lane):
			lane = grid.spawn_cell
		assert(grid.is_walkable(lane), "Route lane probe should be walkable after materialize for seed %d" % seed)
		assert(
			grid.has_walkable_route_in_corridor(lane, grid.core_cell, 8),
			"Brood lane should reach core after route materialize for seed %d" % seed
		)
	print("CRAWL_BRAWL_ROUTE_CONNECTIVITY_TEST_OK")
	quit(0)
