extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const CrawlBrawlRunScript := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_kill_loot_test")


func _run_kill_loot_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: CrawlBrawlRunScript = main.current_screen

	run._spawn_spider(false)
	var player_kill: CrawlBrawlRunScript.Spider = run.enemies[0]
	player_kill.health = 1.0
	player_kill.last_damaged_by_sentry = false
	var reserve_before: int = run.reserve_ammo
	var pickups_before: int = run.pickups.size()
	run._kill_spider(0)
	assert(run.reserve_ammo == reserve_before, "Small player kills should no longer inject pistol reserve ammo")

	run._spawn_spider(true)
	var big_kill: CrawlBrawlRunScript.Spider = run.enemies[0]
	big_kill.health = 1.0
	big_kill.last_damaged_by_sentry = false
	reserve_before = run.reserve_ammo
	run._kill_spider(0)
	assert(run.reserve_ammo == reserve_before + run.KILL_AMMO_BOUNTY_BIG, "Big player kills should award the reduced pistol bounty")

	run._spawn_spider(false)
	var turret_kill: CrawlBrawlRunScript.Spider = run.enemies[0]
	turret_kill.health = 1.0
	turret_kill.last_damaged_by_sentry = true
	reserve_before = run.reserve_ammo
	pickups_before = run.pickups.size()
	run._kill_spider(0)
	assert(run.reserve_ammo == reserve_before and run.pickups.size() == pickups_before, "Turret kills should never spawn or grant pistol ammo loot")

	print("CRAWL_BRAWL_KILL_LOOT_TEST_OK")
	quit(0)
