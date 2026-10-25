extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_progression_sp_gates_test")


func _run_progression_sp_gates_test() -> void:
	assert(PROGRESSION_TREE.node_ids().size() == 5, "Progression tree should expose five unlock nodes including Personal Base blueprint")
	assert(not PROGRESSION_TREE.permanent_upgrade_unlocked(PROGRESSION_TREE.BRANCH_ARSENAL, []), "Armory engineering should stay locked until Overclock is unlocked")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	var scrap_before: int = run.scrap
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run.current_base_id = BASE_NETWORK.COMMAND_ID
	run._purchase_weapon_upgrade_for(0)
	assert(run.weapon_tiers[0] == 1 and run.scrap == scrap_before, "Weapon MK upgrades should require Overclock before spending materials")

	run.expedition_level = 1
	run.skill_points = 1
	assert(run._unlock_skill_node("overclock"), "Overclock should unlock armory permanent engineering")
	scrap_before = run.scrap
	var tier_before: int = run.weapon_tiers[0]
	run._purchase_weapon_upgrade_for(0)
	assert(run.weapon_tiers[0] > tier_before, "Overclock should allow weapon MK upgrades without scrap")
	assert(run.scrap == scrap_before, "Weapon MK upgrades should consume refined parts only")

	run.expedition_level = 1
	run.skill_points = 1
	assert(run._unlock_skill_node("excavation") == false, "Excavation should stay locked before expedition level 2")
	run.expedition_level = 2
	run.skill_points = 1
	var mining_duration_before: float = run._mining_cycle_duration()
	assert(run._unlock_skill_node("excavation"), "Excavation Rig should unlock at level 2 without Automation")
	assert(run._mining_cycle_duration() < mining_duration_before, "Excavation should grant a permanent mining speed bonus")
	scrap_before = run.scrap
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run.material_economy.refined[MATERIAL_ECONOMY.CRYSTAL_CORE] = 2
	var mining_before: int = run.mining_speed_tier
	run._purchase_mining_upgrade(true)
	assert(run.mining_speed_tier > mining_before and run.scrap == scrap_before, "Mining upgrades should spend materials only after Excavation Rig")

	print("CRAWL_BRAWL_PROGRESSION_SP_GATES_TEST_OK")
	quit(0)
