extends SceneTree

const UPGRADE_ECONOMY := preload("res://systems/upgrade_economy.gd")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")


func _initialize() -> void:
	call_deferred("_run_economy_pacing_test")


func _run_economy_pacing_test() -> void:
	assert(PROGRESSION_TREE.sentry_upgrade_sp(1) == 1, "Early sentry tiers should stay affordable at one SP")
	assert(PROGRESSION_TREE.sentry_upgrade_sp(3) == 2, "MK3 sentry should cost two SP")
	assert(PROGRESSION_TREE.frontier_core_upgrade_sp(1) == 1, "Frontier MK2 should cost one SP")
	assert(PROGRESSION_TREE.frontier_core_upgrade_sp(2) == 2, "Frontier MK3 should cost two SP")
	assert(PROGRESSION_TREE.personal_base_upgrade_sp(1) == 1, "Personal base tiers should stay at one SP")

	var sentry_sp_total: int = PROGRESSION_TREE.sentry_upgrade_sp(1) + PROGRESSION_TREE.sentry_upgrade_sp(2) + PROGRESSION_TREE.sentry_upgrade_sp(3)
	assert(sentry_sp_total == 4, "Full sentry ladder should cost four SP across three upgrades")

	var mk4_parts: Dictionary = UPGRADE_ECONOMY.turret_mk4_material_totals()
	assert(int(mk4_parts[MATERIAL_ECONOMY.BRONZE_INGOT]) == 2, "MK4 sentry should require two bronze across the ladder")
	assert(int(mk4_parts[MATERIAL_ECONOMY.CUT_DIAMOND]) == 1, "MK4 sentry should require one cut diamond")

	assert(UPGRADE_ECONOMY.construction_research_cost("rocket_turret") == 3200, "Rocket research should stay in the rebalanced band")
	assert(UPGRADE_ECONOMY.construction_craft_cost("laser_turret") == 360, "Laser craft should stay in the rebalanced band")
	assert(UPGRADE_ECONOMY.scrap_co_pay("mining") == 0, "Mining upgrades should not expose hidden scrap co-pays")
	var mining_mk2: Dictionary = UPGRADE_ECONOMY.mining_upgrade_requirements(true, 1)
	assert(mining_mk2 == {MATERIAL_ECONOMY.BRONZE_INGOT: 1}, "Mining MK2 should be achievable with one bronze ingot")
	var mining_mk5: Dictionary = UPGRADE_ECONOMY.mining_upgrade_requirements(false, 4)
	assert(int(mining_mk5.get(MATERIAL_ECONOMY.GOLD_INGOT, 0)) == 2 and int(mining_mk5.get(MATERIAL_ECONOMY.CUT_DIAMOND, 0)) == 1, "Mining MK5 should retain an endgame material gate")

	var frontier_mk2_req: Dictionary = UPGRADE_ECONOMY.frontier_core_material_requirements(1)
	assert(int(frontier_mk2_req[MATERIAL_ECONOMY.BRONZE_INGOT]) == 2 and int(frontier_mk2_req[MATERIAL_ECONOMY.SILVER_INGOT]) == 1, "Frontier MK2 should require bronze and silver")
	var frontier_mk3_req: Dictionary = UPGRADE_ECONOMY.frontier_core_material_requirements(2)
	assert(int(frontier_mk3_req[MATERIAL_ECONOMY.GOLD_INGOT]) == 2 and int(frontier_mk3_req[MATERIAL_ECONOMY.CUT_DIAMOND]) == 1, "Frontier MK3 should require gold and cut diamond")

	print("CRAWL_BRAWL_ECONOMY_PACING_TEST_OK")
	quit(0)
