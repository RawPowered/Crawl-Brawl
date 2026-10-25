extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const WORLD_LOAD := preload("res://systems/world_load.gd")
const TEST_HARNESS := preload("res://tests/test_harness.gd")


func _initialize() -> void:
	call_deferred("_run_authored_no_evict_test")


func _run_authored_no_evict_test() -> void:
	TEST_HARNESS.reset()
	var seed := 818181
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(seed, "bastion")
	grid.configure_discoveries(seed, "bastion")
	var index := 0
	while not grid.prepare_zone_bulk_is_complete(index):
		index = grid.bulk_materialize_prepare_zone(Callable(), 4096, index)
	var sample_region := grid.authored_region_list()[0]
	var signature_before := grid.terrain_signature([grid.core_cell, sample_region * WORLD_GRID.REGION_SIZE])
	grid.activate_region_window([grid.core_cell + Vector2i(120, 40)], 2)
	grid.schedule_region_window([grid.core_cell + Vector2i(-120, -40)], 2)
	var signature_after := grid.terrain_signature([grid.core_cell, sample_region * WORLD_GRID.REGION_SIZE])
	TEST_HARNESS.require(signature_before == signature_after, "Authored interior must survive stream window moves")
	TEST_HARNESS.require(
		grid.region_readiness(sample_region) >= WORLD_GRID.RegionReadiness.PREPARED,
		"Authored region must remain prepared after window move"
	)
	TEST_HARNESS.finish(self, "AUTHORED_NO_EVICT_TEST_OK")
