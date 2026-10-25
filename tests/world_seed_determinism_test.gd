extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")

const TEST_SEEDS: Array[int] = [111, 222222, 3333333]


func _initialize() -> void:
	call_deferred("_run_world_seed_determinism_test")


func _materialize_all(grid: WORLD_GRID) -> void:
	for region_y in range(grid._region_rows()):
		for region_x in range(grid._region_columns()):
			grid.populate_region_exploration(Vector2i(region_x, region_y))


func _run_world_seed_determinism_test() -> void:
	assert(WORLD_GRID.GENERATOR_VERSION == 2, "Legacy spine extraction should bump generator version to 2")
	for seed: int in TEST_SEEDS:
		var grid_a = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
		grid_a.generate_realm(seed, "bastion", false)
		grid_a.configure_discoveries(seed, "bastion")
		_materialize_all(grid_a)
		var sig_a := grid_a.terrain_signature()
		var grid_b = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
		grid_b.generate_realm(seed, "bastion", false)
		grid_b.configure_discoveries(seed, "bastion")
		_materialize_all(grid_b)
		assert(grid_b.terrain_signature() == sig_a, "Identical seeds must produce identical terrain signatures")
	print("CRAWL_BRAWL_WORLD_SEED_DETERMINISM_TEST_OK")
	quit(0)
