extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const TEST_HARNESS := preload("res://tests/test_harness.gd")


func _initialize() -> void:
	call_deferred("_run_breached_save_route_test")


func _run_breached_save_route_test() -> void:
	TEST_HARNESS.reset()
	var seed := 424242
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(seed, "bastion")
	grid.configure_discoveries(seed, "bastion")
	var breach: Vector2i = grid.core_cell + Vector2i(3, 0)
	while not grid.is_start_chamber_wall(breach):
		breach.x += 1
	grid.establish_first_breach(breach)
	var saved_spawn: Array = grid.spawn_cells.duplicate()
	var lane_count: int = grid.active_lane_count
	var visited: Dictionary = {}
	for region_value: Variant in grid.corridor_regions_between(grid.spawn_cell, grid.core_cell, 1).keys():
		visited[region_value] = true
	grid.restore_visited_regions_for_load(visited)
	var before := grid.terrain_signature()
	var restore_grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	restore_grid.generate_realm(seed, "bastion")
	restore_grid.configure_discoveries(seed, "bastion")
	restore_grid.prepare_resume_context(saved_spawn, breach, lane_count)
	restore_grid.restore_visited_regions_for_load(visited)
	TEST_HARNESS.require(
		restore_grid.terrain_signature() == before,
		"Breach resume context must materialize route strips before visited restore"
	)
	TEST_HARNESS.finish(self, "BREACHED_SAVE_ROUTE_TEST_OK")
