extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const UPGRADE_ECONOMY := preload("res://systems/upgrade_economy.gd")


func _initialize() -> void:
	call_deferred("_run_personal_base_sp_upgrade_test")


func _run_personal_base_sp_upgrade_test() -> void:
	assert(PROGRESSION_TREE.personal_base_upgrade_sp(1) == 1, "Personal Base MK upgrades should cost one SP per tier")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.construction_unlocks["personal_base"] = true
	run.deployable_stock["personal_base"] = 1
	run.selected_build = run.BUILD_PERSONAL_BASE
	run.current_base_id = BASE_NETWORK.COMMAND_ID
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
	run.player_position = run.grid.cell_to_world(placement_cell)
	run._place_structure(placement_cell)
	var shelter_index: int = run._personal_base_index_for_base(BASE_NETWORK.COMMAND_ID)
	assert(shelter_index >= 0, "The test should deploy a powered Personal Base")
	run.structures[shelter_index].level = 1

	var xp_before: int = run.expedition_xp
	var scrap_before: int = run.scrap
	run.skill_points = 0
	run._upgrade_personal_base()
	assert(run.structures[shelter_index].level == 1, "Personal Base upgrades should stay blocked when SP is short")

	run.skill_points = PROGRESSION_TREE.personal_base_upgrade_sp(1)
	run._upgrade_personal_base()
	assert(run.structures[shelter_index].level == 2, "Personal Base MK upgrades should apply after spending SP")
	assert(run.skill_points == 0 and run.expedition_xp == xp_before and run.scrap == scrap_before, "Personal Base tier upgrades should consume SP only")

	var tier_two_req: Dictionary = UPGRADE_ECONOMY.personal_base_upgrade_requirements(2)
	run.skill_points = PROGRESSION_TREE.personal_base_upgrade_sp(2)
	for material_id: String in tier_two_req.keys():
		run.material_economy.refined[material_id] = int(tier_two_req[material_id])
	run._upgrade_personal_base()
	assert(run.structures[shelter_index].level == 3 and run.skill_points == 0, "Later Personal Base tiers should remain purchasable with SP and parts")

	print("CRAWL_BRAWL_PERSONAL_BASE_SP_UPGRADE_TEST_OK")
	quit(0)
