extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")


func _initialize() -> void:
	call_deferred("_run_wave_save_fidelity_test")


func _run_wave_save_fidelity_test() -> void:
	var original_active_realm := REALM_SAVE.active_realm_id()
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.breached = true
	run.wave = 12
	run.wave_active = true
	run.spawns_remaining = 18
	run.spawn_sequence = 4
	run.current_wave_plan = {
		"spawn_count": 24,
		"broodling_pack": 2,
		"broodling_period": 4,
		"active_lanes": 2,
		"boss_count": 1,
	}
	run.checkpoint_exists = true
	run.checkpoint_base_id = run.base_network.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 1

	run.enemies.clear()
	var guardian := RUN_SCRIPT.Spider.new()
	guardian.role = RUN_SCRIPT.ROLE_GUARDIAN
	guardian.big = true
	guardian.position = run.player_position + Vector2(40.0, 0.0)
	guardian.max_health = 1000.0
	guardian.health = 420.0
	guardian.next_summon_ratio = 0.25
	guardian.counts_for_wave = false
	run.enemies.append(guardian)

	var broodling := RUN_SCRIPT.Spider.new()
	broodling.role = RUN_SCRIPT.ROLE_BROODLING
	broodling.position = run.player_position + Vector2(24.0, 0.0)
	broodling.max_health = 20.0
	broodling.health = 20.0
	broodling.counts_for_wave = false
	run.enemies.append(broodling)

	var wave_spider := RUN_SCRIPT.Spider.new()
	wave_spider.role = RUN_SCRIPT.ROLE_SWARM
	wave_spider.position = run.player_position + Vector2(60.0, 0.0)
	wave_spider.max_health = 60.0
	wave_spider.health = 60.0
	wave_spider.counts_for_wave = true
	wave_spider.biome_id = 4
	run.enemies.append(wave_spider)

	var enemy_count_before: int = run.enemies.size()
	assert(run._save_run(false, true), "Mid-delivery checkpoint should persist active encounter state")
	assert(run._load_run(), "Mid-wave checkpoint should reload cleanly")
	assert(run.enemies.size() == enemy_count_before, "Reload should not duplicate or drop saved hostiles")
	assert(is_equal_approx(run.enemies[0].next_summon_ratio, 0.25), "Guardian summon thresholds should survive reload")
	assert(not run.enemies[1].counts_for_wave, "Broodlings should remain non-blocking wave extras after reload")
	assert(not run.enemies[2].counts_for_wave, "Restored hunting-party hostiles should normalize out of retired wave-membership state")
	assert(run.enemies[2].biome_id == 4, "Hostiles must retain their spawn-biome identity across saves")
	assert(run.wave_active and run.spawns_remaining == mini(18, run.hive_awareness.encounter_party_size()), "Active hunting-party delivery should resume from the saved remainder (clamped to party quota)")

	run.hive_awareness.awareness_points = 92
	run.hive_awareness.awareness_tier = 8
	var party_cap: int = run.hive_awareness.encounter_party_size()
	run.spawns_remaining = 18
	assert(run._save_run(false, true), "Encounter clamp test should persist mid-delivery state")
	assert(run._load_run(), "Encounter clamp test should reload cleanly")
	assert(run.spawns_remaining == mini(18, party_cap), "Reload should clamp spawns_remaining to the encounter party quota")

	run.encounter_load_grace = 0.5
	var health_before: float = run.player_health
	run._update_enemies(0.25)
	assert(is_equal_approx(run.player_health, health_before), "Reload grace should suppress immediate contact damage")
	assert(run.enemies.size() == enemy_count_before, "Reload grace should suppress duplicate guardian brood bursts")

	if not original_active_realm.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active_realm), "Wave save test should restore the prior active realm pointer")

	print("CRAWL_BRAWL_WAVE_SAVE_FIDELITY_TEST_OK")
	quit(0)
