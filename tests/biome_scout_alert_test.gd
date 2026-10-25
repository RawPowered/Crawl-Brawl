extends SceneTree

const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const FLOW_FIELD := preload("res://systems/flow_field.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const HIVE_AWARENESS := preload("res://systems/hive_awareness.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run = RUN_SCRIPT.new()
	run.run_seed = 880021
	run.grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	run.grid.generate_realm(run.run_seed, "bastion")
	run.grid.configure_discoveries(run.run_seed, "bastion")
	run.grid.activate_region_window([run.grid.core_cell], 2)
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run.active_player_region = run.grid.region_for_cell(run.grid.core_cell)
	run.base_network = BASE_NETWORK.new()
	run.base_network.configure(run.grid.core_cell, run.grid.width, run.grid.height, run.grid.frontier_sites)
	run.flow = FLOW_FIELD.new()
	run.flow.rebuild(run.grid, run.grid.core_cell)
	run.player_flow = FLOW_FIELD.new()
	run.player_flow.rebuild(run.grid, run.grid.core_cell)
	run._rebuild_base_flows()

	run.hive_awareness.pending_scout_regions.append(run.active_player_region)
	assert(run._try_spawn_pending_scout(run.active_player_region), "A prepared explored biome should dispatch a scout")
	assert(run.enemies.size() == 1 and run.enemies[0].is_scout, "The biome scout should be transient and explicitly tagged")
	var expected_profile: Dictionary = HIVE_AWARENESS.scout_profile(run.grid.region_biome(run.active_player_region))
	assert(run.enemies[0].scout_name == str(expected_profile["name"]), "Scout identity should come from the current biome")
	assert(run.enemies[0].role == int(expected_profile["role"]), "Scout behavior role should come from the current biome")

	run.enemies[0].scout_contact = true
	run.enemies[0].scout_report_elapsed = 5.9
	run._update_scouts(0.2)
	assert(run.enemies[0].scout_reported, "A surviving scout with a prepared route should report the settlement")
	assert(not run.hive_awareness.encounter_pending, "One scout report should warn the hive without immediately launching a hunting party")
	assert(run.hive_awareness.exploration_pressure == 3, "A scout report should add partial contact pressure")
	# A second independent report is enough to cross the early pressure threshold.
	run.hive_awareness.report_scout(run.active_player_region + Vector2i(1, 0))
	assert(run.hive_awareness.encounter_pending, "Repeated confirmed contact should still mobilize a hunting party")

	run.free()
	print("CRAWL_BRAWL_BIOME_SCOUT_ALERT_TEST_OK")
	quit(0)
