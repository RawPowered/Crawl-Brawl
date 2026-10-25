extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")


func _initialize() -> void:
	call_deferred("_run_progression_save_test")


func _apply_legacy_progression_fields(run: RUN_SCRIPT, legacy: Dictionary) -> void:
	run.expedition_xp = maxi(0, int(legacy.get("expedition_xp", 0)))
	run.expedition_level = maxi(0, int(legacy.get("expedition_level", legacy.get("upgrade_count", 0))))
	run.skill_points = maxi(0, int(legacy.get("skill_points", legacy.get("pending_upgrade_picks", 0))))
	run.skill_unlocks.clear()
	for saved_unlock: Variant in legacy.get("skill_unlocks", []):
		var unlock_id := str(saved_unlock)
		if PROGRESSION_TREE.node(unlock_id).is_empty() or unlock_id in run.skill_unlocks:
			continue
		run.skill_unlocks.append(unlock_id)
	run.weapon_damage_multiplier = maxf(1.0, float(legacy.get("weapon_damage_multiplier", 1.0)))


func _run_progression_save_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	_apply_legacy_progression_fields(run, {
		"upgrade_count": 3,
		"pending_upgrade_picks": 2,
		"expedition_xp": 44,
		"skill_unlocks": ["overclock", "fortify"],
		"weapon_damage_multiplier": 1.18,
	})
	assert(run.expedition_level == 3 and run.skill_points == 2, "Legacy upgrade_count and pending_upgrade_picks should migrate into expedition progression")
	assert(run.skill_unlocks.size() == 2 and run.weapon_damage_multiplier > 1.17, "Legacy unlock lists and multipliers should survive migration")

	run.checkpoint_exists = true
	run.checkpoint_base_id = BASE_NETWORK.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 2
	run._sync_checkpoint_slot_zero()
	assert(run._save_run(), "Progression state should autosync once a checkpoint exists")
	var saved: Dictionary = REALM_SAVE.load_active_save()
	assert(int(saved.get("version", 0)) == RUN_SCRIPT.SAVE_VERSION, "Realm saves should write the current progression schema")
	assert(int(saved.get("expedition_level", 0)) == 3 and int(saved.get("skill_points", 0)) == 2, "Expedition level and banked SP should round-trip through realm storage")
	assert("overclock" in saved.get("skill_unlocks", []), "Skill unlocks should round-trip through realm storage")
	assert(not saved.has("weapon_damage_multiplier"), "Progression multipliers should derive from skill_unlocks instead of save fields")
	run.weapon_damage_multiplier = 1.0
	run._rebuild_progression_multipliers()
	assert(run.weapon_damage_multiplier > 1.17, "Loaded skill unlocks should rebuild progression multipliers")
	var saved_slots: Variant = saved.get("checkpoint_slots", [])
	assert(saved_slots is Array and saved_slots.size() >= 1, "Checkpoint archive slot 1 should persist in v11 saves")
	assert(int(saved_slots[0].get("generation", 0)) == 2, "Checkpoint slot metadata should round-trip with generation")

	run.expedition_xp = 120
	run.expedition_level = 0
	run.skill_points = 0
	run._reconcile_expedition_xp(-1, false)
	assert(run.expedition_level == 1 and run.expedition_xp == 40 and run.skill_points == 1, "Overflow expedition XP should reconcile into level, banked XP, and SP")

	var repaired: Array[String] = PROGRESSION_TREE.repair_unlock_order(["excavation", "overclock", "fortify"])
	assert(repaired == ["overclock", "fortify", "excavation"], "Load repair should preserve independent Excavation unlocks")
	assert(repaired.has("excavation"), "Excavation should no longer depend on Automation in repaired saves")

	print("CRAWL_BRAWL_PROGRESSION_SAVE_TEST_OK")
	quit(0)
