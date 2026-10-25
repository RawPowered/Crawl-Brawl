extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const BIOME_BESTIARY := preload("res://systems/biome_bestiary.gd")
const EFFECTS := preload("res://systems/enemy_projectile_effects.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(EFFECTS.structure_priority(BIOME_BESTIARY.DAMAGE_ARC))
	assert(EFFECTS.structure_priority(BIOME_BESTIARY.DAMAGE_CORROSIVE))
	assert(not EFFECTS.structure_priority(BIOME_BESTIARY.DAMAGE_VENOM))
	assert(EFFECTS.spawns_hazard(BIOME_BESTIARY.DAMAGE_THERMAL))
	assert(EFFECTS.spawns_hazard(BIOME_BESTIARY.DAMAGE_SPORE))
	assert(not EFFECTS.spawns_hazard(BIOME_BESTIARY.DAMAGE_KINETIC))
	var venom_dot: Dictionary = EFFECTS.player_dot_spec(BIOME_BESTIARY.DAMAGE_VENOM, false)
	var cyst_dot: Dictionary = EFFECTS.player_dot_spec(BIOME_BESTIARY.DAMAGE_VENOM, true)
	assert(float(cyst_dot["dps"]) > float(venom_dot["dps"]), "Cyst should add corrosive secondary DoT")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	run._clear_player_status()
	run._apply_player_slow(EFFECTS.VENOM_SLOW_MULT, 1.0)
	run._apply_player_dot(EFFECTS.VENOM_DOT_DPS, 1.0)
	assert(is_equal_approx(run.player_slow_mult, EFFECTS.VENOM_SLOW_MULT))
	assert(run.player_dot_time > 0.0)
	var health_before := run.player_health
	run.player_invulnerability = 1.0
	run._update_player_status(0.5)
	assert(run.player_health < health_before, "DoT must tick through invulnerability")
	assert(run.player_slow_time > 0.0)

	run.enemies.clear()
	run._clear_bullets()
	run.fire_patches.clear()
	run.hive_awareness.awareness_tier = 7
	run.brood_escalation = 2
	run._encounter_special_lob_used = 0
	run.encounter_load_grace = 0.0

	var foundry_spitter := RUN_SCRIPT.Spider.new()
	foundry_spitter.role = run.ROLE_SPITTER
	foundry_spitter.biome_id = WORLD_GRID.BIOME_FOUNDRY
	foundry_spitter.position = run.player_position + Vector2(70.0, 0.0)
	foundry_spitter.health = 40.0
	foundry_spitter.max_health = 40.0
	foundry_spitter.speed = 1.0
	foundry_spitter.radius = 5.0
	foundry_spitter.hunts_player = true
	foundry_spitter.spit_cooldown = 0.0
	run.enemies.append(foundry_spitter)
	run._update_enemies(0.01)
	assert(not run.bullets.is_empty(), "Foundry spitter should fire thermal")
	var thermal: RUN_SCRIPT.Bullet = run.bullets.back()
	assert(thermal.damage_type == BIOME_BESTIARY.DAMAGE_THERMAL)
	thermal.position = run.player_position
	thermal.explosion_radius = 22.0
	run._resolve_enemy_projectile_hit(thermal, 1.0, 1.0, true)
	var hazard_count := 0
	for patch: RUN_SCRIPT.FirePatch in run.fire_patches:
		if patch.player_only:
			hazard_count += 1
	assert(hazard_count >= 1, "Thermal hit should spawn a player-only hazard")

	for _i in range(12):
		var filler := RUN_SCRIPT.FirePatch.new()
		filler.player_only = true
		filler.life = 2.0
		filler.max_life = 2.0
		filler.radius = 16.0
		filler.damage_per_second = 1.0
		run._enqueue_enemy_hazard_patch(filler)
	var capped := 0
	for patch: RUN_SCRIPT.FirePatch in run.fire_patches:
		if patch.player_only:
			capped += 1
	assert(capped <= EFFECTS.MAX_ENEMY_HAZARD_PATCHES, "Enemy hazards must stay capped")

	run._clear_bullets()
	run.enemies.clear()
	run._encounter_special_lob_used = 0
	var brute := RUN_SCRIPT.Spider.new()
	brute.role = run.ROLE_BRUTE
	brute.biome_id = WORLD_GRID.BIOME_IRON
	brute.position = run.player_position + Vector2(90.0, 0.0)
	brute.health = 200.0
	brute.max_health = 200.0
	brute.speed = 1.0
	brute.radius = 8.0
	brute.hunts_player = true
	brute.spit_cooldown = 0.0
	run.enemies.append(brute)
	var pressure := run._combat_pressure_level()
	assert(pressure >= 6, "Test setup should unlock bulwark lob pressure")
	run._try_fire_bulwark_lob(brute, run.player_position, 90.0, pressure)
	assert(run._encounter_special_lob_used == 1, "First special lob should consume encounter budget")
	assert(not run.bullets.is_empty() and run.bullets.back().is_special_lob)
	var prior_count := run.bullets.size()
	run._try_fire_bulwark_lob(brute, run.player_position, 90.0, pressure)
	assert(run.bullets.size() == prior_count, "Second special lob in same encounter must be refused")

	# Structure bias: corrosive damages sentry via priority hit path
	run._clear_bullets()
	var sentry := RUN_SCRIPT.Structure.new()
	sentry.kind = run.BUILD_SENTRY
	sentry.position = run.player_position + Vector2(40.0, 0.0)
	sentry.health = 50.0
	sentry.max_health = 50.0
	run.structures.append(sentry)
	run._invalidate_structure_spatial_buckets()
	var corrosive := RUN_SCRIPT.Bullet.new()
	corrosive.enemy_round = true
	corrosive.damage_type = BIOME_BESTIARY.DAMAGE_CORROSIVE
	corrosive.damage = 20.0
	corrosive.radius = 3.0
	corrosive.position = sentry.position
	corrosive.source_biome_id = WORLD_GRID.BIOME_SULFUR
	corrosive.velocity = Vector2.RIGHT
	assert(run._try_enemy_bullet_structure_hit(corrosive, 1.0, 1.0), "Corrosive should hit nearby sentry")
	assert(sentry.health < 50.0, "Corrosive structure bias should reduce sentry HP")

	print("CRAWL_BRAWL_ENEMY_PROJECTILE_SPRINT_B_TEST_OK")
	quit(0)
