extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")


func _initialize() -> void:
	call_deferred("_run_sentry_sp_upgrade_test")


func _run_sentry_sp_upgrade_test() -> void:
	assert(PROGRESSION_TREE.sentry_upgrade_sp(1) == 1, "MK1 sentry upgrades should cost one Skill Point")
	assert(PROGRESSION_TREE.sentry_upgrade_sp(3) == 2, "Late sentry tiers should scale SP predictably")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.selected_build = 1
	run._place_structure(run.grid.core_cell + Vector2i(-3, 0))
	assert(run.structures.size() == 1 and run.structures[0].kind == 1, "A sentry should be placeable at the Command Core")
	run.structures[0].level = 1
	run.structures[0].powered = true
	run.structures[0].base_id = run.current_base_id

	var scrap_before: int = run.scrap
	var xp_before: int = run.expedition_xp
	var sp_cost: int = PROGRESSION_TREE.sentry_upgrade_sp(1)
	run.skill_points = sp_cost - 1
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run._purchase_turret_upgrade()
	assert(not run.turret_selection_active, "Sentry upgrades should stay blocked when SP is short")

	run.skill_points = sp_cost
	run._purchase_turret_upgrade()
	assert(run.turret_selection_active, "Funded sentry upgrades should enter world selection without Automation unlock")
	run._confirm_turret_upgrade()
	assert(run.structures[0].level == 2, "Sentry MK upgrades should apply after spending SP and components")
	assert(run.skill_points == 0 and run.scrap == scrap_before and run.expedition_xp == xp_before, "Sentry upgrades should consume SP and refined parts only")

	var tier_two_cost: int = PROGRESSION_TREE.sentry_upgrade_sp(2)
	run.skill_points = tier_two_cost
	run.material_economy.refined[MATERIAL_ECONOMY.SILVER_INGOT] = 1
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 1
	run._purchase_turret_upgrade()
	assert(run.turret_selection_active, "Each sentry tier should expose its own SP cost")
	run._confirm_turret_upgrade()
	assert(run.structures[0].level == 3 and run.skill_points == 0, "Later sentry tiers should remain purchasable after earlier upgrades")

	print("CRAWL_BRAWL_SENTRY_SP_UPGRADE_TEST_OK")
	quit(0)
