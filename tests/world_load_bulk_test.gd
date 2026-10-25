extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const WORLD_LOAD := preload("res://systems/world_load.gd")
const TEST_HARNESS := preload("res://tests/test_harness.gd")
const TEST_BULK_BUDGET := 4096


func _initialize() -> void:
	call_deferred("_run_world_load_bulk_test")


func _run_world_load_bulk_test() -> void:
	TEST_HARNESS.reset()
	var seed := 909090
	var grid_a = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid_a.generate_realm(seed, "bastion")
	grid_a.configure_discoveries(seed, "bastion")
	var regions := grid_a.prepare_zone_region_list()
	TEST_HARNESS.require(regions.size() <= 121 and regions.size() >= 49, "Prepare horizon should stay bounded near the active render window")
	TEST_HARNESS.require(
		grid_a.prepared_cell_bounds().size == Vector2i(WORLD_GRID.INITIAL_PREPARE_SIZE, WORLD_GRID.INITIAL_PREPARE_SIZE),
		"Prepare zone bounds should match INITIAL_PREPARE_SIZE"
	)
	var index := 0
	while not grid_a.prepare_zone_bulk_is_complete(index):
		index = grid_a.bulk_materialize_prepare_zone(Callable(), TEST_BULK_BUDGET, index)
	TEST_HARNESS.require(grid_a.prepare_zone_bulk_is_complete(index), "Bulk load should finish the prepare zone")
	var sample_region: Vector2i = grid_a.region_for_cell(grid_a.core_cell)
	for region: Vector2i in [sample_region, regions[0], regions[regions.size() / 2]]:
		TEST_HARNESS.require(grid_a.region_readiness(region) >= WORLD_GRID.RegionReadiness.PREPARED, "Region should be prepared after bulk")
		TEST_HARNESS.require(not grid_a.visited_regions.has(region), "Bulk load must not mark visited_regions")
	var sig_a := grid_a.terrain_signature()
	var bounds_before := grid_a.prepared_cell_bounds()
	var edge_probe := bounds_before.position + Vector2i(WORLD_GRID.EXPANSION_EDGE_THRESHOLD - 1, 50)
	TEST_HARNESS.require(grid_a.try_expand_prepare_zone(edge_probe), "Prepare horizon should recenter when player nears an edge")
	TEST_HARNESS.require(grid_a.prepared_cell_bounds().size == bounds_before.size, "Rolling prepare horizon must stay bounded instead of growing forever")
	TEST_HARNESS.require(grid_a.prepared_cell_bounds().position != bounds_before.position, "Rolling prepare horizon should move with the player")
	var horizon_pending_before := grid_a.region_preload_pending()
	TEST_HARNESS.require(horizon_pending_before > 0, "Recentering should enqueue newly entered prepare-horizon chunks")
	grid_a.activate_render_window([edge_probe], 1, edge_probe)
	TEST_HARNESS.require(grid_a.region_preload_pending() > 0, "Render activation must preserve low-priority prepare-horizon generation")
	var grid_b = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid_b.generate_realm(seed, "bastion")
	grid_b.configure_discoveries(seed, "bastion")
	var index_b := 0
	while not grid_b.prepare_zone_bulk_is_complete(index_b):
		index_b = grid_b.bulk_materialize_prepare_zone(Callable(), TEST_BULK_BUDGET, index_b)
	TEST_HARNESS.require(sig_a == grid_b.terrain_signature(), "Bulk materialization must stay deterministic")
	var player_cell: Vector2i = grid_a.core_cell + Vector2i(-1, 0)
	var enqueued := grid_a.enqueue_exterior_horizon_prefetch(player_cell, WORLD_LOAD.EXTERIOR_HORIZON_CELLS, WORLD_LOAD.EXTERIOR_ENQUEUE_CAP)
	TEST_HARNESS.require(enqueued <= WORLD_LOAD.EXTERIOR_ENQUEUE_CAP, "Horizon prefetch should respect enqueue cap")
	for region: Vector2i in grid_a.exterior_regions_in_horizon(player_cell, WORLD_LOAD.EXTERIOR_HORIZON_CELLS):
		TEST_HARNESS.require(not grid_a.is_authored_region(region), "Horizon candidates must stay exterior-only")
	var loader = WORLD_LOAD.new(grid_a)
	loader.begin("new", seed, "bastion")
	var last_done := -1
	var last_phase := ""
	while not loader.is_complete():
		var snapshot: Dictionary = loader.step(0.016)
		var phase_id := str(snapshot.get("phase", ""))
		var done := int(snapshot.get("done", 0))
		if phase_id == last_phase:
			TEST_HARNESS.require(done >= last_done, "Progress callbacks must be monotonic within a phase")
		else:
			last_done = -1
		last_phase = phase_id
		last_done = done
	TEST_HARNESS.finish(self, "WORLD_LOAD_BULK_TEST_OK")
