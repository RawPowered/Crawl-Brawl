extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const BIOME_BESTIARY := preload("res://systems/biome_bestiary.gd")
const COMBAT_VFX := preload("res://systems/combat_vfx.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var kinetic_motion: PackedFloat32Array = COMBAT_VFX.enemy_projectile_motion(BIOME_BESTIARY.DAMAGE_KINETIC)
	assert(is_equal_approx(kinetic_motion[0], 0.0))
	assert(COMBAT_VFX.hazard_texture_id(BIOME_BESTIARY.DAMAGE_THERMAL) == "hazard_thermal")
	assert(COMBAT_VFX.hazard_texture_id(BIOME_BESTIARY.DAMAGE_SPORE) == "hazard_spore")
	assert(COMBAT_VFX.hazard_texture_id(BIOME_BESTIARY.DAMAGE_VENOM).is_empty())

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	var bare := RUN_SCRIPT.Bullet.new()
	assert(is_equal_approx(bare.age, 0.0))
	assert(is_equal_approx(bare.visual_spin_rate, 0.0))
	assert(is_equal_approx(bare.trail_stretch, 1.0))

	run.fire_patches.clear()
	run.flamethrower_unlocked = true
	run.flame_fuel = 100
	for _i in range(3):
		var hazard := RUN_SCRIPT.FirePatch.new()
		hazard.player_only = true
		hazard.life = 2.0
		hazard.max_life = 2.0
		hazard.source_damage_type = BIOME_BESTIARY.DAMAGE_THERMAL
		run.fire_patches.append(hazard)
	for _i in range(run.FLAMETHROWER_PATCH_CAP):
		var flame := RUN_SCRIPT.FirePatch.new()
		flame.player_only = false
		flame.life = 2.0
		flame.max_life = 2.0
		run.fire_patches.append(flame)
	var hazards_before := 0
	for patch: RUN_SCRIPT.FirePatch in run.fire_patches:
		if patch.player_only:
			hazards_before += 1
	run._fire_flamethrower()
	var hazards_after := 0
	var flame_after := 0
	for patch: RUN_SCRIPT.FirePatch in run.fire_patches:
		if patch.player_only:
			hazards_after += 1
		else:
			flame_after += 1
	assert(hazards_after == hazards_before, "Flamethrower must not evict enemy player_only hazards")
	assert(flame_after <= run.FLAMETHROWER_PATCH_CAP)

	run.enemies.clear()
	run._clear_bullets()
	run.combat_impacts.clear()
	run.sparks.clear()
	run.hive_awareness.awareness_tier = 7
	run.brood_escalation = 2
	run.encounter_load_grace = 0.0
	var spitter := RUN_SCRIPT.Spider.new()
	spitter.role = run.ROLE_SPITTER
	spitter.biome_id = WORLD_GRID.BIOME_HIVE
	spitter.position = run.player_position + Vector2(60.0, 0.0)
	spitter.health = 40.0
	spitter.max_health = 40.0
	spitter.speed = 1.0
	spitter.radius = 5.0
	spitter.hunts_player = true
	spitter.spit_cooldown = 0.0
	run.enemies.append(spitter)
	run._update_enemies(0.01)
	assert(not run.bullets.is_empty(), "Hive spitter should fire")
	var round_bullet: RUN_SCRIPT.Bullet = run.bullets.back()
	assert(round_bullet.visual_spin_rate > 0.0)
	assert(not run.combat_impacts.is_empty(), "Muzzle puff should spawn an impact")
	var muzzle: RUN_SCRIPT.CombatImpact = run.combat_impacts.back()
	assert(muzzle.enemy_pop)
	assert(muzzle.texture_id.find("splat") < 0, "Muzzle must use glob puff, not splat")
	assert(muzzle.texture_id != "impact_acid")

	run.combat_impacts.clear()
	run.sparks.clear()
	run._clear_player_status()
	var impact_count_before := run.combat_impacts.size()
	run._apply_player_dot(4.0, 1.0)
	run._update_player_status(0.2)
	assert(run.combat_impacts.size() == impact_count_before, "DoT tick must not spawn combat impacts")

	run._apply_player_slow(0.7, 1.0)
	run._apply_player_dot(2.0, 1.0)
	assert(run.player_slow_time > 0.0 and run.player_dot_time > 0.0)
	run._clear_runtime_combat_fx()
	assert(is_equal_approx(run.player_slow_time, 0.0))
	assert(is_equal_approx(run.player_dot_time, 0.0))

	print("enemy_projectile_vfx_test OK")
	quit(0)
