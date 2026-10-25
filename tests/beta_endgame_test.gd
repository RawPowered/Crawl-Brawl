extends SceneTree

const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const FLOW_FIELD := preload("res://systems/flow_field.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run = RUN_SCRIPT.new()
	run.run_seed = 808080
	run.grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	run.grid.generate_realm(run.run_seed, "bastion")
	run.grid.configure_discoveries(run.run_seed, "bastion")
	run.grid.activate_region_window([run.grid.core_cell], 10)
	run.flow = FLOW_FIELD.new()
	run.player_flow = FLOW_FIELD.new()
	run.base_network = BASE_NETWORK.new()
	run.base_network.configure(run.grid.core_cell, run.grid.width, run.grid.height, run.grid.frontier_sites)
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run.breached = true
	run._rebuild_base_flows()

	run.hive_awareness.awareness_tier = 1
	run._apply_encounter_nest_milestones()
	assert(not run.brood_nests.is_empty(), "Hive Awareness should establish the first distant nest")
	assert(run.brood_nests[0].cell.distance_to(run.grid.core_cell) >= 80.0, "Milestone nests must stay at least eighty cells from the main Core")
	run.hive_awareness.awareness_tier = 6
	run._apply_encounter_nest_milestones()
	assert(run.brood_nests.any(func(nest) -> bool: return nest.is_lair), "High Hive Awareness should reveal the first Spider Lair without a wave-count gate")

	run.nest_kills_total = 10
	run._begin_apex_phase()
	var apex_count := 0
	for nest in run.brood_nests:
		if not nest.apex_id.is_empty():
			apex_count += 1
	assert(apex_count == 5, "The tenth nest kill should establish all Final Five boss nests")

	run.mecha_level = 3
	run._sync_mecha_squad()
	assert(run.mecha_spiders.size() == 3, "Mecha Spider MK3 should deploy three hunters")
	assert(run.surface_portal_cell.x < 0, "Mecha research must not bypass the future Final Five excavation-technology gate")
	var run_source := FileAccess.get_file_as_string("res://scripts/phase0_run.gd")
	assert(not run_source.contains("if mecha_level >= 3:\n\t\t_spawn_surface_portal()"), "The surface shortcut must remain retired until the proper campaign gate is implemented")

	run.free()
	print("CRAWL_BRAWL_BETA_ENDGAME_TEST_OK")
	quit(0)
