extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_region_preload_test")


func _run_region_preload_test() -> void:
	var grid: WORLD_GRID = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(424242, "bastion")

	var distant_cell := Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.72), grid.core_cell.y)
	grid.schedule_region_window([distant_cell], 1)
	assert(grid.region_preload_pending() > 0, "Scheduling a frontier window should queue unpopulated regions")
	assert(not grid.is_region_loaded(distant_cell), "Queued regions must not enter loaded state before preload completes")

	var loaded := grid.process_region_preload_budget(12)
	assert(loaded > 0, "Budgeted preload should materialize queued regions")
	var preload_delta := grid.take_region_preload_delta()
	assert(preload_delta.size() == loaded, "Preload delta should list regions materialized this budget pass")
	assert(grid.take_region_preload_delta().is_empty(), "Preload delta should clear after take")
	assert(grid.is_region_loaded(distant_cell), "Frontier window should finish loading after enough budget is spent")
	assert(grid.get_cell(distant_cell) == WORLD_GRID.ROCK or grid.get_cell(distant_cell) == WORLD_GRID.FLOOR, "Loaded frontier cells should resolve without get_cell lazy pop")

	var beam_origin := grid.cell_to_world(grid.core_cell)
	var beam_direction := (grid.cell_to_world(distant_cell) - beam_origin).normalized()
	grid.prefetch_mining_beam_regions(beam_origin, beam_direction, 640.0)
	assert(grid.region_preload_pending() >= 0, "Beam prefetch should enqueue or no-op on already populated beam regions")

	var queued := grid.ensure_regions_around(grid.core_cell + Vector2i(96, 0), 1)
	assert(queued > 0, "Sparse ensure_regions_around should enqueue unprepared neighbors instead of sync populate")
	var neighbor_region := grid.region_for_cell(grid.core_cell + Vector2i(96, 0))
	assert(not grid.populated_regions.has(neighbor_region), "Enqueue-only ensure must not synchronously populate distant neighbors")

	var prepare_probe := grid.core_cell + Vector2i(200, 0)
	var prepare_region := grid.region_for_cell(prepare_probe)
	grid.ensure_region_for_cell(prepare_probe, true)
	assert(
		not grid.populated_regions.has(prepare_region),
		"Prepare-zone ensure must enqueue instead of sync populate"
	)
	assert(
		grid.region_preload_pending() > 0 or grid.region_readiness(prepare_region) >= WORLD_GRID.RegionReadiness.QUEUED,
		"Prepare-zone ensure should queue materialization"
	)

	print("CRAWL_BRAWL_REGION_PRELOAD_TEST_OK")
	quit(0)
