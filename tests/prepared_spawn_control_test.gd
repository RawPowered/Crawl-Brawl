extends SceneTree

const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	var run = RUN_SCRIPT.new()
	run.run_seed = 771144
	run.grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	run.grid.generate_realm(run.run_seed, "bastion")
	run.grid.configure_discoveries(run.run_seed, "bastion")
	run.base_network = BASE_NETWORK.new()
	run.base_network.configure(run.grid.core_cell, run.grid.width, run.grid.height, run.grid.frontier_sites)
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run.grid.activate_region_window([run.grid.core_cell], 1)

	var distant_cell := Vector2i(int(run.grid.width * 0.78), int(run.grid.height * 0.72))
	var nest := RUN_SCRIPT.BroodNest.new()
	nest.cell = distant_cell
	nest.aggressive = true
	assert(not run.grid.is_region_active(distant_cell), "The distant boss region should begin outside the active simulation ring")
	assert(not run._spawn_nest_boss(nest), "Boss pits must not spawn in unloaded or unprepared regions")
	assert(run.enemies.is_empty(), "A rejected boss spawn must not create an enemy")

	run.grid.activate_region_window([distant_cell], 1)
	run.grid.open_discovery_chamber(distant_cell, 2)
	assert(run.grid.is_spawn_ready(distant_cell), "The prepared active chamber should become spawn-authoritative")
	assert(run._spawn_nest_boss(nest), "A prepared active boss pit should spawn successfully")
	assert(run.enemies.size() == 1, "Successful boss creation should commit exactly one persistent guardian")

	run.grid.activate_region_window([run.grid.core_cell], 1)
	assert(not run._spawn_nest_boss(nest), "Unloading a prepared pit must revoke its spawn authority")
	assert(run.enemies.size() == 1, "Revoked spawn authority must not duplicate the boss")

	run.enemies.clear()
	var edge_cell: Vector2i = run.grid.core_cell + Vector2i(120, 0)
	run.grid.activate_region_window([run.grid.core_cell], 0)
	run.grid.schedule_region_window([edge_cell], 0)
	assert(not run.grid.is_spawn_ready(edge_cell), "Edge fixture must begin outside spawn authority")
	assert(run.grid.region_spawn_retryable(edge_cell), "Stream-edge brood pressure must remain retryable while preload catches up")
	run._begin_hostile_spawn_frame()
	run._queue_broodling_pack(edge_cell, 2)
	run._drain_pending_hostile_spawns(64)
	run._end_hostile_spawn_frame()
	assert(run.enemies.is_empty(), "Queued brood packs must wait for spawn-ready terrain at the stream edge")
	assert(run.pending_hostile_spawns.size() == 2, "Preload-pending brood packs must retry instead of being discarded")

	run.free()
	print("CRAWL_BRAWL_PREPARED_SPAWN_CONTROL_TEST_OK")
	quit(0)
