extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_lazy_discovery_test")


func _run_lazy_discovery_test() -> void:
	assert(WORLD_GRID.REALM_WIDTH >= WORLD_GRID.LAZY_TOPOLOGY_MIN_WIDTH, "The current realm should enable lazy discoveries")
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(919191, "bastion")
	grid.configure_discoveries(919191, "bastion")
	assert(grid.uses_lazy_discoveries(), "Mega realms should defer discovery placement until region load")
	assert(grid.discovery_cells.is_empty(), "Lazy discovery planning should not place cells at boot")
	assert(grid.mineral_cells.is_empty(), "Lazy discovery planning should not place minerals at boot")

	var distant_cell := Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.78), int(WORLD_GRID.REALM_HEIGHT * 0.62))
	var distant_region := grid.region_for_cell(distant_cell)
	grid.activate_region_window([distant_cell], 1)
	assert(grid.is_region_loaded(distant_cell), "Region streaming should load the visited window")
	assert(grid._discovery_materialized.has(distant_region), "Visited regions should materialize their discovery plan")
	assert(not grid.discovery_cells.is_empty() or not grid.mineral_cells.is_empty(), "Loaded regions should seed local discoveries")

	var visited: Dictionary = grid.visited_regions.duplicate()
	var restored = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	restored.generate_realm(919191, "bastion")
	restored.configure_discoveries(919191, "bastion")
	restored.restore_discoveries_for_visited_regions(visited)
	restored.activate_region_window([distant_cell], 1)

	var reference = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	reference.generate_realm(919191, "bastion")
	reference.configure_discoveries(919191, "bastion")
	reference.restore_discoveries_for_visited_regions(visited)
	reference.activate_region_window([distant_cell], 1)
	assert(restored.discovery_cells.size() == reference.discovery_cells.size(), "Save restore should replay visited discovery materialization")
	assert(restored.mineral_cells.size() == reference.mineral_cells.size(), "Save restore should replay visited mineral materialization")

	var repeat_grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	repeat_grid.generate_realm(919191, "bastion")
	repeat_grid.configure_discoveries(919191, "bastion")
	repeat_grid.activate_region_window([distant_cell], 1)
	assert(repeat_grid.discovery_cells.size() == grid.discovery_cells.size(), "Lazy discovery materialization should stay deterministic per seed")
	assert(repeat_grid.mineral_cells.size() == grid.mineral_cells.size(), "Lazy mineral materialization should stay deterministic per seed")

	print("CRAWL_BRAWL_LAZY_DISCOVERY_TEST_OK")
	quit(0)
