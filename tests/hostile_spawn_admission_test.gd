extends SceneTree

const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	var run = RUN_SCRIPT.new()
	run.run_seed = 551177
	run.grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	run.grid.generate_realm(run.run_seed, "bastion")
	run.grid.configure_discoveries(run.run_seed, "bastion")
	run.base_network = BASE_NETWORK.new()
	run.base_network.configure(run.grid.core_cell, run.grid.width, run.grid.height, run.grid.frontier_sites)
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	var spawn_cell: Vector2i = run.grid.core_cell + Vector2i(36, 0)
	run.grid.activate_region_window([spawn_cell], 1)
	run.grid.open_discovery_chamber(spawn_cell, 2)
	assert(run._spider_spawn_allowed_cell(spawn_cell), "Fixture needs prepared ground outside the command-base exclusion")

	run._begin_hostile_spawn_frame()
	run._queue_broodling_pack(spawn_cell, 6)
	assert(run.enemies.is_empty() and run.pending_hostile_spawns.size() == 6, "A live-frame brood burst should queue instead of constructing immediately")
	run._drain_pending_hostile_spawns(64)
	run._end_hostile_spawn_frame()
	assert(run.enemies.size() == 2 and run.pending_hostile_spawns.size() == 4, "One frame must admit no more than two hostile entities")
	for unused in range(2):
		run._begin_hostile_spawn_frame()
		run._drain_pending_hostile_spawns(64)
		run._end_hostile_spawn_frame()
	assert(run.enemies.size() == 6 and run.pending_hostile_spawns.is_empty(), "Queued pressure should spread across frames without losing the intended pack")

	var before_direct: int = run.enemies.size()
	run._begin_hostile_spawn_frame()
	assert(run._spawn_broodling(spawn_cell, 20, false), "First direct producer should receive admission")
	assert(run._spawn_broodling(spawn_cell, 21, false), "Second direct producer should receive admission")
	assert(not run._spawn_broodling(spawn_cell, 22, false), "A conflicting third producer must defer instead of spiking the frame")
	run._end_hostile_spawn_frame()
	assert(run.enemies.size() == before_direct + 2, "Direct spawn conflicts must obey the shared frame budget")

	var sparse_grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	sparse_grid.generate_realm(551178, "bastion")
	sparse_grid.configure_discoveries(551178, "bastion")
	run.grid = sparse_grid
	run.base_network.configure(sparse_grid.core_cell, sparse_grid.width, sparse_grid.height, sparse_grid.frontier_sites)
	run.player_position = sparse_grid.cell_to_world(sparse_grid.core_cell)
	sparse_grid.activate_region_window([sparse_grid.core_cell], 1)
	var distant_lane := sparse_grid.spawn_cell + Vector2i(180, 0)
	var wave_spawn := run._resolve_wave_spawn_cell(0)
	if wave_spawn.x >= 0:
		var player_cell := sparse_grid.world_to_cell(run.player_position)
		assert(
			wave_spawn.distance_to(player_cell) <= 22,
			"Sparse wave spawn resolution must stay on prepared local fallback, not distant lanes"
		)
		assert(
			wave_spawn != distant_lane or run._spider_spawn_allowed_cell(distant_lane),
			"Distant weighted lanes must not bypass prepared-only spawn authority"
		)
	else:
		assert(wave_spawn == Vector2i(-1, -1), "Unprepared sparse exterior must defer wave spawn instead of sync lane carving")

	run.free()
	print("CRAWL_BRAWL_HOSTILE_SPAWN_ADMISSION_TEST_OK")
	quit(0)
