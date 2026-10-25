extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_mining_crosshair_test")


func _run_mining_crosshair_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	assert(run._should_draw_combat_crosshair(), "Combat crosshair should show during normal aim")
	assert(run._should_draw_held_weapon(), "Held weapon should show during normal aim")

	run.aim_direction = Vector2(-1, -1).normalized()
	assert(not run._player_weapon_draws_behind(), "Held weapon should stay in front while aiming")
	run.aim_direction = Vector2.LEFT
	assert(not run._player_weapon_draws_behind(), "Left aim should keep the weapon in front of the body")

	Input.action_press("fire")
	await process_frame
	assert(not run._should_draw_combat_crosshair(), "Combat crosshair should hide while mining")
	assert(run._should_draw_held_weapon(), "Mining gun should remain visible in the player's hands")
	assert(run._should_draw_mining_gun(), "Mining input should select the dedicated mining-gun sprite")
	run.mining_beam_valid = false
	assert(run._should_draw_held_weapon(), "Mining gun should remain visible while aiming over open air")
	var mining_pose: Dictionary = run._player_tool_pose(true)
	assert(Vector2(mining_pose["muzzle"]).distance_to(Vector2(mining_pose["mount"])) >= 13.5, "Mining beam should originate at the authored gun barrel")
	run.player_position = Vector2(100, 100)
	run.aim_direction = Vector2.DOWN
	var close_feedback := run._mining_feedback_position(run.player_position + Vector2.DOWN * 12.0)
	assert((close_feedback - run.player_position).dot(run.aim_direction) >= 27.9, "Close down-facing mining feedback must be pushed beyond the player silhouette")
	Input.action_release("fire")
	await process_frame
	assert(run._should_draw_combat_crosshair(), "Combat crosshair should return after mining ends")
	assert(run._should_draw_held_weapon(), "Held weapon should return after mining ends")

	print("CRAWL_BRAWL_MINING_CROSSHAIR_TEST_OK")
	quit(0)
