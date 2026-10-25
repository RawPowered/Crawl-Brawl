extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")


func _initialize() -> void:
	call_deferred("_run_progression_suite_test")


func _run_progression_suite_test() -> void:
	assert(PROGRESSION_TREE.node_ids().size() == 5, "Progression tree should expose five unlock nodes")
	assert(REALM_SAVE.SAVE_SCHEMA == RUN_SCRIPT.SAVE_VERSION, "Gameplay and realm storage schemas should match")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	# Phase 1: level -> SP, node apply
	var damage_before: float = run.weapon_damage_multiplier
	run.expedition_level = 1
	run.skill_points = 1
	assert(run._unlock_skill_node("overclock"), "Suite should unlock Overclock with banked SP")
	assert(run.weapon_damage_multiplier > damage_before and run.skill_points == 0, "Overclock should apply and consume SP")
	run.expedition_xp = run._expedition_xp_threshold()
	run.wave = 3
	var level_before: int = run.expedition_level
	run._award_expedition_xp()
	assert(run.expedition_level > level_before, "Wave XP should advance expedition level")

	# Phase 2: personal base blueprint via SP
	var scrap_before: int = run.scrap
	run.expedition_level = 5
	run.expedition_xp = 0
	run.skill_points = 1
	run.construction_unlocks["personal_base"] = false
	run.skill_unlocks.clear()
	run.skill_unlocks.append("fortify")
	run.current_base_id = BASE_NETWORK.COMMAND_ID
	run._purchase_or_craft_personal_base()
	assert(bool(run.construction_unlocks.get("personal_base", false)) and run.skill_points == 0, "Personal Base blueprint should spend SP at level 5 with Fortify unlocked")

	run.skill_unlocks.append("personal_base")
	run.construction_unlocks["personal_base"] = true
	run.scrap = 500
	run.material_economy.refined[MATERIAL_ECONOMY.STONE_BLOCK] = 2
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 1
	var kit_scrap_before: int = run.scrap
	run._purchase_or_craft_personal_base()
	assert(int(run.deployable_stock.get("personal_base", 0)) == 1 and run.scrap == kit_scrap_before - PROGRESSION_TREE.personal_base_kit_scrap_cost(), "Personal Base kits should craft with scrap and parts only")

	# Phase 3: SP gates on permanent upgrades
	run.skill_unlocks.append("overclock")
	run._rebuild_progression_multipliers()
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	var tier_before: int = run.weapon_tiers[0]
	var weapon_scrap_before: int = run.scrap
	run._purchase_weapon_upgrade_for(0)
	assert(run.weapon_tiers[0] > tier_before and run.scrap == weapon_scrap_before, "Overclock should unlock scrap-free weapon engineering")

	run.expedition_level = 4
	run.skill_points = 2
	run.skill_unlocks.append("automation")
	assert(run._unlock_skill_node("excavation"), "Suite should unlock Excavation Rig")
	var mining_before: int = run.mining_speed_tier
	run.material_economy.refined[MATERIAL_ECONOMY.CRYSTAL_CORE] = 2
	run._purchase_mining_upgrade(true)
	assert(run.mining_speed_tier > mining_before, "Excavation Rig should unlock mining upgrades")

	# Phase 4: checkpoint slot archive
	run.expedition_level = 5
	assert(not run._checkpoint_slot_open(1), "Checkpoint slot 2 should stay locked below level 10")
	run.checkpoint_exists = true
	run.checkpoint_base_id = BASE_NETWORK.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 1
	run._sync_checkpoint_slot_zero()
	assert(run.checkpoint_slots.size() == 3, "Checkpoint archive should reserve all three slots")
	assert(not run.checkpoint_slots[0].is_empty(), "Slot 1 should mirror the active checkpoint")

	# Phase 5: save migration + round trip
	run.expedition_level = 3
	run.skill_points = 1
	run.skill_unlocks.clear()
	run.skill_unlocks.append("overclock")
	run.skill_unlocks.append("excavation")
	run.expedition_xp = 12
	assert(run._save_run(), "Full progression stack should autosync to realm storage")
	var saved: Dictionary = REALM_SAVE.load_active_save()
	assert(int(saved.get("expedition_level", 0)) == 3 and int(saved.get("skill_points", 0)) == 1, "Suite save should persist expedition progression")
	assert(saved.get("skill_unlocks", []).has("excavation"), "Suite save should persist branch unlocks")
	assert(saved.get("checkpoint_slots", []) is Array and not saved["checkpoint_slots"].is_empty(), "Suite save should persist checkpoint archive rows")

	print("CRAWL_BRAWL_PROGRESSION_SUITE_TEST_OK")
	quit(0)
