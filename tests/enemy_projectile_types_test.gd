extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const BIOME_BESTIARY := preload("res://systems/biome_bestiary.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const DIFFICULTY := preload("res://systems/difficulty_profile.gd")
const WAVE_DIRECTOR := preload("res://systems/wave_director.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert_type_map()
	_assert_l2_absolutes()
	_assert_level_ramps()
	await _assert_runtime_cap_and_pressure()
	print("CRAWL_BRAWL_ENEMY_PROJECTILE_TYPES_TEST_OK")
	quit(0)


func _assert_type_map() -> void:
	assert(BIOME_BESTIARY.damage_type_for_biome(WORLD_GRID.BIOME_TUNNEL) == BIOME_BESTIARY.DAMAGE_SPORE)
	assert(BIOME_BESTIARY.damage_type_for_biome(WORLD_GRID.BIOME_HIVE) == BIOME_BESTIARY.DAMAGE_VENOM)
	assert(BIOME_BESTIARY.damage_type_for_biome(WORLD_GRID.BIOME_BUNKER) == BIOME_BESTIARY.DAMAGE_ARC)
	assert(BIOME_BESTIARY.damage_type_for_biome(WORLD_GRID.BIOME_CRYSTAL) == BIOME_BESTIARY.DAMAGE_ARC)
	assert(BIOME_BESTIARY.damage_type_for_biome(WORLD_GRID.BIOME_FOUNDRY) == BIOME_BESTIARY.DAMAGE_THERMAL)
	assert(BIOME_BESTIARY.damage_type_for_biome(WORLD_GRID.BIOME_SULFUR) == BIOME_BESTIARY.DAMAGE_CORROSIVE)
	assert(BIOME_BESTIARY.damage_type_for_biome(WORLD_GRID.BIOME_IRON) == BIOME_BESTIARY.DAMAGE_KINETIC)
	assert(BIOME_BESTIARY.projectile_level_for_pressure(1) == 1)
	assert(BIOME_BESTIARY.projectile_level_for_pressure(4) == 2)
	assert(BIOME_BESTIARY.projectile_level_for_pressure(6) == 3)
	assert(BIOME_BESTIARY.projectile_level_for_pressure(7) == 4)


func _assert_l2_absolutes() -> void:
	var expected := {
		BIOME_BESTIARY.DAMAGE_SPORE: {"damage": 8.25, "speed_scale": 0.72, "hit_radius": 4.2, "splash_radius": 28.0, "cooldown": 2.70},
		BIOME_BESTIARY.DAMAGE_VENOM: {"damage": 9.9, "speed_scale": 0.95, "hit_radius": 3.0, "splash_radius": 0.0, "cooldown": 1.85},
		BIOME_BESTIARY.DAMAGE_ARC: {"damage": 9.35, "speed_scale": 1.28, "hit_radius": 2.25, "splash_radius": 14.0, "cooldown": 2.05},
		BIOME_BESTIARY.DAMAGE_THERMAL: {"damage": 12.1, "speed_scale": 0.88, "hit_radius": 3.45, "splash_radius": 22.0, "cooldown": 2.40},
		BIOME_BESTIARY.DAMAGE_CORROSIVE: {"damage": 11.0, "speed_scale": 0.90, "hit_radius": 3.6, "splash_radius": 18.0, "cooldown": 2.35},
		BIOME_BESTIARY.DAMAGE_KINETIC: {"damage": 14.85, "speed_scale": 0.70, "hit_radius": 2.7, "splash_radius": 8.0, "cooldown": 2.85},
	}
	for damage_type: StringName in expected.keys():
		var combat: Dictionary = BIOME_BESTIARY.projectile_combat_profile(damage_type, 2, {})
		var want: Dictionary = expected[damage_type]
		for key: String in want.keys():
			assert(
				is_equal_approx(float(combat[key]), float(want[key])),
				"L2 %s.%s expected %s got %s" % [damage_type, key, want[key], combat[key]]
			)


func _assert_level_ramps() -> void:
	var venom_l2: Dictionary = BIOME_BESTIARY.projectile_combat_profile(BIOME_BESTIARY.DAMAGE_VENOM, 2, {})
	var venom_l4: Dictionary = BIOME_BESTIARY.projectile_combat_profile(BIOME_BESTIARY.DAMAGE_VENOM, 4, {})
	assert(float(venom_l4["cooldown"]) < float(venom_l2["cooldown"]), "L4 cooldown should be faster than L2")
	assert(float(venom_l4["hit_radius"]) > float(venom_l2["hit_radius"]), "L4 aoe should exceed L2")
	assert(float(venom_l4["cooldown"]) >= BIOME_BESTIARY.MIN_SPIT_COOLDOWN, "Cooldownoldown floor must hold")
	var bunker_arc: Dictionary = BIOME_BESTIARY.projectile_combat_profile(
		BIOME_BESTIARY.DAMAGE_ARC, 2, BIOME_BESTIARY.trait_profile(WORLD_GRID.BIOME_BUNKER)
	)
	var crystal_arc: Dictionary = BIOME_BESTIARY.projectile_combat_profile(
		BIOME_BESTIARY.DAMAGE_ARC, 2, BIOME_BESTIARY.trait_profile(WORLD_GRID.BIOME_CRYSTAL)
	)
	assert(float(crystal_arc["speed_scale"]) > float(bunker_arc["speed_scale"]), "Crystal ecology should stack on arc speed")


func _assert_runtime_cap_and_pressure() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	var bastion: Dictionary = DIFFICULTY.get_profile("bastion")
	assert(int(bastion["spitter_start"]) == 3, "Bastion spitters unlock at pressure 3")

	run.enemies.clear()
	run._clear_bullets()
	run.hive_awareness.awareness_tier = 0
	run.brood_escalation = 0
	assert(run._combat_pressure_level() == 1, "Fresh bastion pressure should sit at L1 band")
	var early := RUN_SCRIPT.Spider.new()
	early.role = run.ROLE_SPITTER
	early.biome_id = WORLD_GRID.BIOME_HIVE
	early.position = run.player_position + Vector2(60.0, 0.0)
	early.health = 40.0
	early.max_health = 40.0
	early.speed = 1.0
	early.radius = 5.0
	early.hunts_player = true
	early.spit_cooldown = 0.0
	run.enemies.append(early)
	run.encounter_load_grace = 0.0
	run._update_enemies(0.01)
	assert(not run.bullets.is_empty(), "Spitters may fire whenever their role is present")
	var venom_round: RUN_SCRIPT.Bullet = run.bullets.back()
	assert(venom_round.damage_type == BIOME_BESTIARY.DAMAGE_VENOM)
	assert(venom_round.projectile_level == 1)

	run._clear_bullets()
	for _i in range(30):
		var filler := RUN_SCRIPT.Spider.new()
		filler.role = run.ROLE_SPITTER
		filler.biome_id = WORLD_GRID.BIOME_IRON
		filler.position = run.player_position + Vector2(50.0 + float(_i), 0.0)
		filler.health = 20.0
		filler.max_health = 20.0
		filler.speed = 1.0
		filler.radius = 5.0
		filler.hunts_player = true
		filler.spit_cooldown = 0.0
		run.enemies.append(filler)
	run._update_enemies(0.01)
	assert(run._enemy_bullet_count <= run.MAX_ENEMY_BULLETS, "Enemy bullet counter must respect hard cap")
	assert(run.bullets.size() <= run.MAX_ENEMY_BULLETS + 8, "Friendly rounds may exist but enemy count is capped")
	var enemy_rounds := 0
	for bullet: RUN_SCRIPT.Bullet in run.bullets:
		if bullet.enemy_round:
			enemy_rounds += 1
	assert(enemy_rounds <= run.MAX_ENEMY_BULLETS, "In-flight enemy rounds must stay <= 24")
	assert(enemy_rounds == run._enemy_bullet_count, "O(1) enemy bullet counter must match live rounds")

	var spawn_damage := venom_round.damage
	var pressure_now := run._combat_pressure_level()
	var hit_multiplier := float(run.difficulty["enemy_damage"]) * WAVE_DIRECTOR.enemy_damage_pressure(pressure_now)
	assert(hit_multiplier > 0.0, "Hit path still multiplies difficulty × pressure once")
	assert(is_equal_approx(spawn_damage, float(BIOME_BESTIARY.projectile_combat_profile(BIOME_BESTIARY.DAMAGE_VENOM, 1, {})["damage"])), "Spawn damage is type×L only; pressure multiplies later at hit")
