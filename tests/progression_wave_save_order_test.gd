extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_progression_wave_save_order_test")


func _run_progression_wave_save_order_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.checkpoint_exists = true
	run.checkpoint_base_id = BASE_NETWORK.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 1
	run.wave = 2
	run.expedition_level = 0
	run.skill_points = 0
	run.expedition_xp = run._expedition_xp_threshold() - 5

	run._award_wave_completion(true)
	var xp_after: int = run.expedition_xp
	var level_after: int = run.expedition_level
	var sp_after: int = run.skill_points
	assert(level_after > 0 and sp_after > 0, "Legacy progression award compatibility should grant XP, level, and SP before autosave")

	assert(run._load_run(), "Compatibility autosave should reload cleanly after progression award")
	assert(run.expedition_level == level_after, "Reload should persist expedition level awarded before save")
	assert(run.expedition_xp == xp_after, "Reload should persist banked XP awarded before save")
	assert(run.skill_points == sp_after, "Reload should persist banked SP awarded before save")

	print("CRAWL_BRAWL_PROGRESSION_WAVE_SAVE_ORDER_TEST_OK")
	quit(0)
