extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_flamethrower_phase4_test")


func _run_flamethrower_phase4_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.flamethrower_unlocked = true
	run.unlocked_weapons[RUN_SCRIPT.WEAPON_FLAMETHROWER] = true
	run.current_weapon = RUN_SCRIPT.WEAPON_FLAMETHROWER
	run.flame_fuel = 10
	run.aim_direction = Vector2.RIGHT
	var target: RUN_SCRIPT.Spider = RUN_SCRIPT.Spider.new()
	target.position = run._player_muzzle_position() + Vector2(24, 0)
	target.health = 100.0
	target.max_health = 100.0
	target.radius = 4.0
	run.enemies.append(target)
	run._fire_flamethrower()
	assert(run.flame_fuel == 5 and run.fire_patches.size() == 1, "Each flame burst should consume five fuel and create one bounded fire patch")
	assert(target.health < 100.0, "A target inside the short forward flame cone should take direct damage")
	var patch: RUN_SCRIPT.FirePatch = run.fire_patches[0]
	patch.life = patch.max_life - 0.3
	run.player_position = patch.position
	var health_before: float = run.player_health
	run._update_fire_patches(0.25)
	assert(run.player_health < health_before, "Standing in an armed fire patch should damage the player")
	patch.life = 0.01
	run._update_fire_patches(0.1)
	assert(run.fire_patches.is_empty(), "Expired fire patches should be removed")
	run.flame_fuel = 0
	run.scrap = RUN_SCRIPT.FLAMETHROWER_FUEL_BUNDLE_COST
	run._purchase_supply(8)
	assert(run.flame_fuel == RUN_SCRIPT.FLAMETHROWER_FUEL_BUNDLE and run.scrap == 0, "Supplies should refill Flame Fuel using the authored bundle price")

	print("CRAWL_BRAWL_FLAMETHROWER_PHASE4_TEST_OK")
	quit(0)
