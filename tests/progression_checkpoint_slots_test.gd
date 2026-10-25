extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_progression_checkpoint_slots_test")


func _run_progression_checkpoint_slots_test() -> void:
	assert(REALM_SAVE.SAVE_SCHEMA == 14, "Holster split advances the realm save schema to version 14")
	assert(RUN_SCRIPT.MAX_CHECKPOINT_SLOTS == 3, "The checkpoint archive should reserve three slots")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	assert(run.checkpoint_slots.is_empty(), "A fresh realm should start with no checkpoint archive rows")
	run.expedition_level = 5
	assert(run._checkpoint_slot_open(0), "Slot 1 should always be open")
	assert(not run._checkpoint_slot_open(1), "Slot 2 should stay locked below level 10")
	assert("LOCKED" in run._checkpoint_slot_label(1), "Slot 2 should show its level gate before unlock")

	var legacy_save := {
		"version": 10,
		"realm_id": run.realm_id,
		"run_seed": run.run_seed,
		"checkpoint_exists": true,
		"checkpoint_base_id": BASE_NETWORK.COMMAND_ID,
		"checkpoint_position": [128.0, 256.0],
		"checkpoint_generation": 2,
	}
	run._migrate_checkpoint_slots(legacy_save)
	assert(run.checkpoint_slots.size() == 3, "Checkpoint migration should reserve all archive slots")
	assert(int(run.checkpoint_slots[0].get("generation", 0)) == 2, "Migrated slot metadata should preserve generation")

	run.checkpoint_exists = true
	run.checkpoint_base_id = BASE_NETWORK.COMMAND_ID
	run.checkpoint_position = Vector2(140.0, 260.0)
	run.checkpoint_generation = 3
	run._sync_checkpoint_slot_zero()
	assert(int(run.checkpoint_slots[0].get("generation", 0)) == 3, "Slot 1 should track the latest committed generation")

	run.expedition_level = 10
	run.realm_save_cooldown = 0.0
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	assert(run._commit_realm_save_to_slot(1), "Slot 2 should accept archive writes at expedition level 10")
	assert(not run.checkpoint_slots[1].is_empty(), "Slot 2 should persist stored archive metadata")
	assert(run.checkpoint_base_id == BASE_NETWORK.COMMAND_ID, "Archive slot writes should not move the active anchor")

	run.checkpoint_slots[1]["base_id"] = BASE_NETWORK.NORTH_ID
	run.checkpoint_slots[1]["position"] = [512.0, 256.0]
	run.checkpoint_slots[1]["generation"] = 7
	assert(run._activate_checkpoint_slot(1), "Stored archive slots should be activatable at the Core")
	assert(run.checkpoint_base_id == BASE_NETWORK.NORTH_ID, "Activation should move the respawn anchor to the stored slot")
	assert(int(run.checkpoint_slots[0].get("generation", 0)) == 7, "Slot 1 should mirror the activated anchor")

	print("CRAWL_BRAWL_PROGRESSION_CHECKPOINT_SLOTS_TEST_OK")
	quit(0)
