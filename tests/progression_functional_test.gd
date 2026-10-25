extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_progression_functional_test")


func _run_progression_functional_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	# Wave XP -> level -> SP
	run.wave = 2
	run.expedition_xp = run._expedition_xp_threshold() - 5
	var level_before: int = run.expedition_level
	var sp_before: int = run.skill_points
	run._award_expedition_xp()
	assert(run.expedition_level > level_before and run.skill_points > sp_before, "Wave completion should level the expedition and bank SP")
	assert(run.expedition_xp < run._expedition_xp_threshold(), "Banked XP should always stay below the next threshold")

	# Tier upgrades spend SP, not expedition XP.
	run.expedition_level = 3
	run.skill_points = 0
	run.expedition_xp = 250
	assert(run._sp_purchase_state(PROGRESSION_TREE.sentry_upgrade_sp(1), {}).begins_with("MISSING"), "Tier upgrades should require banked SP, not expedition XP")

	# Overflow XP reconciles into levels; it does not pay tier upgrades directly.
	run.expedition_level = 0
	run.skill_points = 0
	run.expedition_xp = 120
	run._reconcile_expedition_xp(-1, false)
	assert(run.expedition_level == 1 and run.expedition_xp == 40, "Overflow XP should convert to level and remaining banked XP")

	# SP nodes require expedition level, not raw XP
	run.expedition_level = 0
	run.skill_points = 1
	run.expedition_xp = 200
	assert(not run._unlock_skill_node("overclock"), "SP nodes should stay locked until expedition level requirements are met")
	run.expedition_level = 1
	assert(run._unlock_skill_node("overclock"), "Overclock should unlock once level and SP requirements are satisfied")

	# SP base upgrade spends SP + parts, never scrap or expedition XP
	run.expedition_level = 10
	run.expedition_xp = 200
	run.skill_points = PROGRESSION_TREE.frontier_core_upgrade_sp(1)
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 2
	run.material_economy.refined[MATERIAL_ECONOMY.SILVER_INGOT] = 1
	var scrap_before: int = run.scrap
	assert(run._spend_sp_purchase(PROGRESSION_TREE.frontier_core_upgrade_sp(1), run._base_material_requirements(1)), "Frontier core upgrades should accept SP plus refined parts")
	assert(run.scrap == scrap_before and run.expedition_xp == 200 and run.skill_points == 0, "SP purchases should never deduct scrap or expedition XP")

	# Shop refresh should keep UI state aligned with reconciled XP
	run.expedition_xp = 90
	run.expedition_level = 1
	run.skill_points = 0
	run._open_core_base()
	run._set_core_menu_page("base")
	run._refresh_core_base_panel()
	assert(run.core_action_states[5].begins_with("NEED"), "BASE tab blueprint row should reflect SP gates after XP reconciliation")

	# Automation should gate rocket turret research on CONSTRUCTION.
	run.construction_unlocks["rocket_turret"] = false
	run.scrap = 10000
	run.material_economy.refined[MATERIAL_ECONOMY.STEEL_PLATE] = 5
	run.material_economy.refined[MATERIAL_ECONOMY.TITANIUM_PLATE] = 3
	run.material_economy.refined[MATERIAL_ECONOMY.EXPLOSIVE_COMPOUND] = 2
	run.material_economy.refined[MATERIAL_ECONOMY.CUT_DIAMOND] = 1
	var rocket_slot: int = run.CONSTRUCTION_ORDER.find("rocket_turret")
	run._purchase_or_research_construction(rocket_slot)
	assert(not bool(run.construction_unlocks.get("rocket_turret", false)), "Rocket research should stay locked without Automation")

	# Overflow reconcile should announce the level-up.
	run.expedition_level = 0
	run.skill_points = 0
	run.expedition_xp = run._expedition_xp_threshold() + 20
	run.discovery_alert_time = 0.0
	run._reconcile_expedition_xp(-1, true)
	assert(run.expedition_level >= 1 and run.skill_points >= 1, "Overflow reconcile should convert XP into levels and SP")
	assert(run.discovery_alert_time > 0.0, "Level reconcile should announce level-up progress")

	assert("COMING SOON" not in run._checkpoint_slots_detail(), "Checkpoint copy should expose all archive slots")
	assert("SLOT 2" in run._checkpoint_slots_detail(), "Checkpoint detail should list slot 2 status")

	run.expedition_level = 0
	run.skill_points = 0
	run.expedition_xp = run._expedition_xp_threshold() + 92
	run.xp_highlights.clear()
	var milestone_sp_before: int = run.skill_points
	run._reconcile_expedition_xp(2, true)
	var sp_gained: int = run.skill_points - milestone_sp_before
	assert(sp_gained == 4, "Milestone reconcile should grant bonus SP for each level gained")
	assert(not run.xp_highlights.is_empty() and run.xp_highlights.back().text == "+%d SP" % sp_gained, "Level-up highlight should match actual SP gained")
	assert(run.hud_level_up_flash > 0.0 or run.hud_sp_pulse > 0.0, "Level-up should trigger HUD celebration flash")

	run.wave = 1
	run.expedition_xp = 0
	run.hud_xp_flash = 0.0
	run._award_expedition_xp()
	assert(run.hud_xp_flash > 0.0, "Wave XP gain should flash the in-run XP pip")

	run.expedition_xp = 45
	run.skill_points = 2
	var pause_summary: String = run._pause_summary_text()
	assert("XP 045/" in pause_summary and "SP 02" in pause_summary, "Pause summary should expose banked XP progress and SP")

	print("CRAWL_BRAWL_PROGRESSION_FUNCTIONAL_TEST_OK")
	quit(0)
