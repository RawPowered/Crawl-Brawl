extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_personal_base_kit_test")


func _run_personal_base_kit_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.expedition_level = 1
	run.expedition_xp = 0
	run.skill_points = 0
	run.skill_unlocks.append("personal_base")
	run._sync_progression_unlocks()
	run.current_base_id = BASE_NETWORK.COMMAND_ID
	run.scrap = PROGRESSION_TREE.personal_base_kit_scrap_cost()
	run.material_economy.refined[MATERIAL_ECONOMY.STONE_BLOCK] = 2
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 1
	run._purchase_or_craft_personal_base()
	assert(int(run.deployable_stock.get("personal_base", 0)) == 1, "An unlocked blueprint should fabricate a Personal Base kit without spending XP")
	assert(run.expedition_xp == 0 and run.skill_points == 0, "Kit fabrication should not touch expedition XP or Skill Points")

	print("CRAWL_BRAWL_PERSONAL_BASE_KIT_TEST_OK")
	quit(0)
