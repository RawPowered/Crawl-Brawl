extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_run_route_tactics_test")


func _run_route_tactics_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	# Open the initial siege route so frontier expedition flows are reachable.
	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()
	assert(run.explorer_flows.size() == 3, "The swarm should maintain independent routes to all three Frontier sites")

	run.wave = 4
	run.spawn_sequence = 0
	run._spawn_spider(false)
	var raider = run.enemies.back()
	assert(raider.is_explorer, "Every wave should contain a deterministic expedition cohort")
	assert(not raider.hunts_player, "Expedition mobs should not abandon their route for the player's position")
	assert(raider.explorer_legs_remaining >= 2, "Expedition mobs should visit multiple strategic waypoints")

	var route_target: Vector2 = run.grid.cell_to_world(run.explorer_targets[raider.explorer_route_index])
	var distance_before: float = raider.position.distance_to(route_target)
	run.player_position = raider.position + Vector2(0.0, 20.0)
	run._update_enemies(0.25)
	assert(raider.position.distance_to(route_target) < distance_before, "A nearby player should not pull expedition traffic off its strategic route")

	run.wave = 8
	run.spawn_sequence = 1
	run._spawn_spider(false)
	var hunter = run.enemies.back()
	assert(hunter.hunts_player and not hunter.is_explorer, "Dedicated stalkers should remain a separate tactical cohort")

	print("CRAWL_BRAWL_INDEPENDENT_ROUTE_TACTICS_TEST_OK")
	quit(0)
