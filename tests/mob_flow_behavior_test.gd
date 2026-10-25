extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_run_mob_flow_behavior_test")


func _run_mob_flow_behavior_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.grid.open_cell(run.grid.tutorial_rock)
	run.breached = true
	run._rebuild_base_flows()

	run.wave = 4
	run.spawn_sequence = 0
	run._spawn_spider(false)
	var raider = run.enemies.back()
	assert(raider.is_explorer and not raider.hunts_player, "Expedition cohort should stay mission-focused")
	var mission_cell: Vector2i = run.grid.world_to_cell(run._spider_combat_target_position(raider))
	var raider_cell: Vector2i = run.grid.world_to_cell(raider.position)
	var player_cell: Vector2i = run.grid.world_to_cell(run.player_position)
	var step_toward_player: Vector2i = run._greedy_step_toward(raider_cell, player_cell)
	var step_toward_mission: Vector2i = run._greedy_step_toward(raider_cell, mission_cell)
	assert(step_toward_mission != raider_cell or step_toward_player == raider_cell, "Fallback routing should prefer the expedition waypoint over the player")
	assert(mission_cell == run.explorer_targets[raider.explorer_route_index], "Expedition combat target should track the active waypoint")

	run.spawn_sequence = 1
	run._spawn_spider(false)
	var hunter = run.enemies.back()
	hunter.hunts_player = true
	hunter.is_explorer = false
	hunter.counts_for_wave = true
	hunter.locomotion_stall = 1.5
	run.player_position = hunter.position + Vector2(96.0, 0.0)
	run._refresh_player_flow()
	var hunter_cell: Vector2i = run.grid.world_to_cell(hunter.position)
	assert(run.player_flow.has_path(hunter_cell), "Hunter should retain player-flow routing after refresh")
	assert(run._spider_has_viable_route(hunter), "Hunter on player flow must not count as unreachable")
	assert(run._reposition_unreachable_wave_spiders() == 0, "Viable hunters should never hard-relocate")

	run.player_flow_stale = false
	var mine_probe: Vector2i = player_cell + Vector2i(2, 0)
	if run.grid.in_bounds(mine_probe) and run.grid.can_mine(mine_probe):
		run.grid.open_cell(mine_probe)
		run._on_terrain_cell_opened(mine_probe)
		assert(run.player_flow_stale, "Mining near the player should invalidate stale player flow")

	print("CRAWL_BRAWL_MOB_FLOW_BEHAVIOR_TEST_OK")
	quit(0)
