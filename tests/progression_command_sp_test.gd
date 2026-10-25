extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_progression_command_sp_test")


func _run_progression_command_sp_test() -> void:
	assert(PROGRESSION_TREE.frontier_core_upgrade_sp(1) == 1, "Frontier MK upgrades should expose deterministic SP costs")
	assert(PROGRESSION_TREE.sp_cost("personal_base") == 1, "Personal Base blueprint should cost one Skill Point")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	var scrap_before: int = run.scrap
	var xp_before: int = run.expedition_xp
	run.expedition_level = 5
	run.skill_points = 1
	run.construction_unlocks["personal_base"] = false
	run.skill_unlocks.append("fortify")
	run.current_base_id = BASE_NETWORK.COMMAND_ID
	run._purchase_or_craft_personal_base()
	assert(bool(run.construction_unlocks.get("personal_base", false)), "Blueprint research should unlock with a Skill Point")
	assert(run.skill_points == 0 and run.expedition_xp == xp_before and run.scrap == scrap_before, "Personal Base blueprint should spend SP only")

	run.expedition_level = 10
	run.expedition_xp = 250
	run.skill_points = PROGRESSION_TREE.frontier_core_upgrade_sp(1)
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 2
	run.material_economy.refined[MATERIAL_ECONOMY.SILVER_INGOT] = 1
	var sp_before: int = run.skill_points
	assert(run._spend_sp_purchase(PROGRESSION_TREE.frontier_core_upgrade_sp(1), run._base_material_requirements(1)), "Frontier materials plus SP should pass the new purchase gate")
	assert(run.skill_points < sp_before and run.expedition_xp == 250 and run.scrap == scrap_before, "Command upgrades should consume SP and refined parts, not scrap or expedition XP")

	print("CRAWL_BRAWL_PROGRESSION_COMMAND_SP_TEST_OK")
	quit(0)
