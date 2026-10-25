extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
func _initialize() -> void:
	call_deferred("_run_continuous_breather_test")


func _run_continuous_breather_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.breached = true
	run.wave = 20
	run.wave_active = true
	run.spawns_remaining = 0
	run.wave_reward_claimed = true
	run.enemies.clear()
	run._update_encounter_delivery(0.0)
	assert(not run.wave_active, "Clearing a hunting party should return the world to exploration")

	run._update_encounter_delivery(120.0)
	assert(not run.wave_active, "Time alone must never restart a cleared encounter")
	assert(not run.hive_awareness.encounter_pending, "Time alone must not accumulate encounter pressure")
	run.hive_awareness.register_activity("first_breach", run.active_player_region)
	# BV5.7 requires a small explored footprint plus repeated confirmed contact; one
	# scout report is intentionally no longer equivalent to starting a new wave.
	run.hive_awareness.register_prepared_region(run.active_player_region, false)
	run.hive_awareness.register_prepared_region(run.active_player_region + Vector2i(1, 0), false)
	run.hive_awareness.register_prepared_region(run.active_player_region + Vector2i(2, 0), false)
	run.hive_awareness.report_scout(run.active_player_region)
	run.hive_awareness.report_scout(run.active_player_region + Vector2i(1, 0))
	run._update_encounter_delivery(0.0)
	assert(run.wave_active, "Repeated exploration contact should authorize the next hunting party")

	print("CRAWL_BRAWL_CONTINUOUS_BREATHER_TEST_OK")
	quit(0)
