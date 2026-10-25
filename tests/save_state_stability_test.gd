extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")


func _initialize() -> void:
	call_deferred("_run_save_state_stability_test")


func _structure(kind: int, cell: Vector2i, health: float) -> RUN_SCRIPT.Structure:
	var result := RUN_SCRIPT.Structure.new()
	result.kind = kind
	result.cell = cell
	result.position = Vector2(cell)
	result.health = health
	result.max_health = health
	return result


func _run_save_state_stability_test() -> void:
	var original_active_realm := REALM_SAVE.active_realm_id()
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.structures.clear()
	run.material_economy.foundry_tier = 2

	var sentry := _structure(RUN_SCRIPT.BUILD_SENTRY, Vector2i(1, 1), 61.0)
	sentry.level = 4
	sentry.cooldown = 0.73
	sentry.aim_direction = Vector2(3.0, 4.0).normalized()
	sentry.base_id = "stale_power_link"
	sentry.powered = true
	run.structures.append(sentry)

	var chest := _structure(RUN_SCRIPT.BUILD_CHEST_SMALL, Vector2i(3, 1), 88.0)
	chest.chest_capacity = 999
	chest.inventory = {
		MATERIAL_ECONOMY.COPPER_ORE: 7,
		MATERIAL_ECONOMY.BRONZE_INGOT: 2,
		"invalid_material": 40,
		MATERIAL_ECONOMY.COAL: -3,
	}
	run.structures.append(chest)

	var door := _structure(RUN_SCRIPT.BUILD_HEAVY_DOORWAY, Vector2i(5, 1), 720.0)
	door.level = 3
	door.rotated = true
	door.size = Vector2i(2, 4)
	door.is_open = true
	run.structures.append(door)

	var foundry := _structure(RUN_SCRIPT.BUILD_FOUNDRY, Vector2i(8, 1), 350.0)
	foundry.level = 2
	foundry.size = Vector2i(2, 2)
	run.structures.append(foundry)

	var lantern := _structure(RUN_SCRIPT.BUILD_TORCH, Vector2i(11, 1), 140.0)
	lantern.level = 3
	lantern.lantern_color_id = 2
	run.structures.append(lantern)

	var encoded: Array[Dictionary] = run._serialize_structures()
	encoded.append({"kind": 999, "cell": [12, 1], "health": 10.0})
	encoded.append({"kind": RUN_SCRIPT.BUILD_FOUNDRY, "cell": [8, 1], "health": 10.0})
	encoded.append({"kind": RUN_SCRIPT.BUILD_BARRICADE, "cell": [-100, -100], "health": 10.0})
	run._restore_structures(encoded)

	assert(run.structures.size() == 5, "Restore should reject unknown, duplicate, and out-of-bounds structures")
	assert(is_equal_approx(run.structures[0].cooldown, 0.73) and run.structures[0].aim_direction.is_equal_approx(Vector2(0.6, 0.8)), "Turret cooldown and facing should survive a structure round trip")
	assert(run.structures[0].base_id != "stale_power_link", "Structure power should be recalculated from the restored base network")
	assert(run.structures[1].chest_capacity == 100, "Chest capacity should restore from its structure class, not mutable save data")
	assert(int(run.structures[1].inventory.get(MATERIAL_ECONOMY.COPPER_ORE, 0)) == 7 and int(run.structures[1].inventory.get(MATERIAL_ECONOMY.BRONZE_INGOT, 0)) == 2, "Valid raw and refined chest cargo should survive restoration")
	assert(not run.structures[1].inventory.has("invalid_material") and not run.structures[1].inventory.has(MATERIAL_ECONOMY.COAL), "Invalid and negative chest entries should not enter the live economy")
	assert(run.structures[2].size == Vector2i(2, 4) and run.structures[2].is_open, "Door level, orientation, footprint, and open state should restore together")
	assert(run.structures[3].kind == RUN_SCRIPT.BUILD_FOUNDRY and run.structures[3].level == 2 and run.structures[3].size == Vector2i(2, 2), "Exactly one Foundry should restore at its economy tier")
	assert(run.structures[4].kind == RUN_SCRIPT.BUILD_TORCH and run.structures[4].level == 3 and run.structures[4].lantern_color_id == 2, "Lantern tier and selected color must survive a structure round trip")

	run.checkpoint_exists = true
	run.checkpoint_base_id = run.base_network.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 1
	run.flame_fuel = 127
	run.flamethrower_unlocked = true
	run.scrap = 4242
	assert(run._save_run(), "Gameplay progress should autosync once a checkpoint exists")
	var resynced: Dictionary = REALM_SAVE.load_active_save()
	assert(int(resynced.get("scrap", -1)) == 4242, "Autosync writes should persist live progression")
	assert(run._save_run(false, true), "A completed checkpoint should write the protected structure state")
	assert(run._save_run(false, true), "A second checkpoint write should rotate a verified primary into the backup slot")
	var primary_path := REALM_SAVE.save_root().path_join(run.realm_id).path_join(REALM_SAVE.SAVE_FILE)
	var corrupted := FileAccess.open(primary_path, FileAccess.WRITE)
	assert(corrupted != null, "The fallback test should be able to replace its own test primary")
	corrupted.store_string("intentional test corruption")
	corrupted = null
	var recovered: Dictionary = REALM_SAVE.load_active_save()
	assert(not recovered.is_empty() and recovered.get("realm_id", "") == run.realm_id and recovered.get("structures", []).size() == 5, "An unreadable primary should load the previous verified backup")
	assert(run._load_run() and run.structures.size() == 5 and run.flame_fuel == 127 and run.flamethrower_unlocked and run.scrap == 4242, "The live run should recover structures and reserved fire-tech state from the backup without a partial state")
	assert(run._save_run(false, true) and run._save_run(false, true), "Recovery should re-establish both a valid primary and a valid backup")
	if not original_active_realm.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active_realm), "The save test should restore the player's previously active realm pointer")

	print("CRAWL_BRAWL_SAVE_STATE_STABILITY_TEST_OK")
	quit(0)
