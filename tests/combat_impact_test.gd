extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const COMBAT_VFX := preload("res://systems/combat_vfx.gd")


func _initialize() -> void:
	call_deferred("_run_combat_impact_test")


func _run_combat_impact_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	assert(run.USE_IMPORTED_COMBAT_FX and run.USE_IMPORTED_RETICLES, "Combat wiring tests expect imported combat FX and reticles")

	run._combat_feedback(run.player_position, Vector2.RIGHT, "rocket_explosion", Color("ff9b45"), 10, 80.0, true)
	assert(not run.combat_impacts.is_empty(), "Rocket explosion feedback should spawn a combat impact overlay")
	assert(run.combat_impacts.back().texture_id == "rocket_explosion")

	run.combat_impacts.clear()
	run._combat_feedback(run.player_position + Vector2(24, 0), Vector2.RIGHT, "acid_splat", Color("9de85d"), 8, 36.0)
	assert(run.combat_impacts.back().texture_id == "acid_splat")

	run.combat_impacts.clear()
	run.mining_impact_pulse = 0.28
	run.mining_impact_position = run.player_position + Vector2(0, 20)
	run._combat_feedback(run.mining_impact_position, Vector2.RIGHT, "impact_rock", Color("e5b56f"), 12, 60.0, true)
	assert(run.combat_impacts.back().texture_id == "impact_rock")

	run.combat_impacts.clear()
	run._spawn_combat_impact("muzzle_sentry", run.player_position + Vector2(-20, 0), Vector2.RIGHT, Vector2(12, 10), 0.08)
	assert(run.combat_impacts.back().texture_id == "muzzle_sentry")

	var sentry_bullet: RUN_SCRIPT.Bullet = RUN_SCRIPT.Bullet.new()
	sentry_bullet.color = Color("82e9ff")
	assert(COMBAT_VFX.impact_texture_id_for_bullet(sentry_bullet.color, "round", false) == "impact_cyan")
	var laser_bullet: RUN_SCRIPT.Bullet = RUN_SCRIPT.Bullet.new()
	laser_bullet.projectile_kind = "laser_turret"
	assert(COMBAT_VFX.impact_texture_id_for_bullet(laser_bullet.color, laser_bullet.projectile_kind, false) == "impact_laser")

	assert(COMBAT_VFX.reticle_texture_id(false, false, run.WEAPON_FLAMETHROWER) == "reticle_yellow")
	assert(run._crosshair_reticle_texture_id() in ["reticle_cyan", "reticle_yellow", "reticle_white"], "Field reticle should be combat, mine, or place")

	print("CRAWL_BRAWL_COMBAT_IMPACT_TEST_OK")
	quit(0)
