extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_checkpoint_respawn_test")


func _deploy_test_shelter(run) -> RUN_SCRIPT.Structure:
	run.construction_unlocks["personal_base"] = true
	run.deployable_stock["personal_base"] = 1
	run.selected_build = RUN_SCRIPT.BUILD_PERSONAL_BASE
	var placement_cell := Vector2i(-1, -1)
	for y in range(-5, 6):
		for x in range(-5, 6):
			var candidate: Vector2i = run.grid.core_cell + Vector2i(x, y)
			if run._can_place_structure(candidate):
				placement_cell = candidate
				break
		if placement_cell.x >= 0:
			break
	assert(placement_cell.x >= 0, "Command territory should expose a Personal Base pad")
	run._place_structure(placement_cell)
	var shelter_index: int = run._personal_base_index_for_base(BASE_NETWORK.COMMAND_ID)
	assert(shelter_index >= 0, "Personal Base should deploy at Command")
	return run.structures[shelter_index]


func _commit_command_save(run) -> bool:
	run.wave_active = true
	run.spawns_remaining = 40
	run.using_realm_archive = true
	run.current_base_id = BASE_NETWORK.COMMAND_ID
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	return run._commit_realm_save()


func _run_checkpoint_respawn_test() -> void:
	var original_active_realm := REALM_SAVE.active_realm_id()
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var unsaved_run = main.current_screen
	assert(not unsaved_run.checkpoint_exists and not unsaved_run._save_run(), "A new realm should not create an incidental save before the player commits one")
	unsaved_run.player_health = 0.0
	unsaved_run._handle_player_death()
	assert(unsaved_run.game_over and "NO FIELD SAVE" in unsaved_run.game_over_label.text, "Death before the first field save should end the unsaved realm")

	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.wave = 4
	run._spawn_spider(false)
	var checkpoint_enemy_position: Vector2 = run.enemies[0].position
	var shelter: RUN_SCRIPT.Structure = _deploy_test_shelter(run)
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	assert(_commit_command_save(run), "Command Core archive should save without requiring a Personal Base")
	assert(run.checkpoint_exists and run.checkpoint_generation == 1, "A Command Core save should establish the resurrection anchor")
	run.realm_save_cooldown = run._save_cooldown_duration()
	assert(not _commit_command_save(run) and run.checkpoint_generation == 1, "The realm save cooldown should reject immediate repeat saves")
	assert(REALM_SAVE.load_active_save().get("checkpoint_exists", false), "The committed field save should publish the realm to Continue")

	run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE] = 6
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 2
	run.deployable_stock["granite_barrier"] = 1
	var death_position: Vector2 = run.grid.cell_to_world(run.grid.core_cell + Vector2i(7, 0))
	run.player_position = death_position
	run.player_health = 0.0
	run._handle_player_death()
	assert(run.encounter_epoch == 1 and run.player_position.is_equal_approx(run.checkpoint_position), "Death after saving should reload the checkpoint and resurrect at its saved anchor")
	assert(run.material_economy.raw_total() == 0 and run.material_economy.refined_total() == 0 and run._deployable_stock_total() == 0, "Resurrection should clear every backpack material and deployable kit without touching permanent equipment")
	assert(run.recovery_cache.get("active", false) and run._cargo_units(run.recovery_cache["cargo"]) == 11, "Death cargo is materials plus unique kit stacks (starter torches and the granite kit)")
	assert(run.enemies.size() == 1 and not run.enemies[0].position.is_equal_approx(checkpoint_enemy_position), "The restored enemy pressure should return through a different encounter route")
	assert(run.encounter_load_grace >= 8.0, "Death respawn should grant a longer combat grace window")

	run.player_position = run.recovery_cache["position"]
	run._update_recovery_cache(0.1)
	assert(not run.recovery_cache.get("active", true), "Collecting every cached item should clear the death marker")
	assert(int(run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE]) == 6 and int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 2 and int(run.deployable_stock["granite_barrier"]) == 1, "Recovery should restore raw cargo, refined parts, and construction kits")

	assert(run._load_run(), "The original field save should remain readable after recovery")
	run._apply_recovery_journal()
	assert(run._backpack_used() == 0 and not run.recovery_cache.get("active", false), "Quitting before another sleep should not duplicate already recovered cargo from the checkpoint")
	run.recovery_cache = {"active": true, "position": run.player_position + Vector2(200, 0), "remaining": 0.05, "cargo": {"raw": {MATERIAL_ECONOMY.COAL: 1}, "refined": {}, "kits": {}}}
	run._update_recovery_cache(0.1)
	assert(not run.recovery_cache.get("active", true) and run.recovery_cache.get("cargo", {}).is_empty(), "A recovery cache should permanently expire after ten minutes of active play")

	if not original_active_realm.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active_realm), "The checkpoint test should restore the previously active realm pointer")
	print("CRAWL_BRAWL_CHECKPOINT_RESPAWN_TEST_OK")
	quit(0)
