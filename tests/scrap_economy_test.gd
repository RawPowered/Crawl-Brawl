extends SceneTree

const SCRAP_ECONOMY := preload("res://systems/scrap_economy.gd")
const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_run_scrap_economy_test")


func _run_scrap_economy_test() -> void:
	assert(SCRAP_ECONOMY.kill_reward(false, false) == SCRAP_ECONOMY.KILL_SMALL, "Small player kills should use the shared reward contract")
	assert(SCRAP_ECONOMY.kill_reward(true, false) == SCRAP_ECONOMY.KILL_BIG, "Big player kills should use the shared reward contract")
	assert(SCRAP_ECONOMY.kill_reward(false, true) == ceili(float(SCRAP_ECONOMY.KILL_SMALL) * SCRAP_ECONOMY.KILL_SENTRY_RATIO), "Sentry kills should use one ratio instead of hard-coded half pay")
	assert(SCRAP_ECONOMY.wave_reward(1, 1.0) == 33, "Wave rewards should scale from the shared base/per constants")
	assert(SCRAP_ECONOMY.wave_reward(10, 1.15) == roundi(float(30 + 10 * 3) * 1.15), "Difficulty multipliers should still apply through wave_reward")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	assert(run.scrap == SCRAP_ECONOMY.START, "New realms should start at the authored scrap balance")

	print("CRAWL_BRAWL_SCRAP_ECONOMY_TEST_OK")
	quit(0)
