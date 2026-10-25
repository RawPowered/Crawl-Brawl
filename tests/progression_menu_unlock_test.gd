extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_progression_menu_unlock_test")


func _run_progression_menu_unlock_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.current_base_id = BASE_NETWORK.COMMAND_ID
	run._open_core_base()
	run._set_core_menu_page("progress")

	var ladder: Array[Dictionary] = [
		{"level": 1, "slot": 0, "node_id": "overclock", "multiplier": "weapon_damage_multiplier"},
		{"level": 2, "slot": 1, "node_id": "fortify", "multiplier": "fortification_multiplier"},
		{"level": 3, "slot": 2, "node_id": "automation", "multiplier": "sentry_damage_multiplier"},
		{"level": 2, "slot": 3, "node_id": "excavation", "multiplier": "mining_cycle_multiplier"},
		{"level": 5, "slot": 4, "node_id": "personal_base", "multiplier": ""},
	]

	for step: Dictionary in ladder:
		run.expedition_level = int(step["level"])
		run.skill_points = 1
		run._refresh_core_base_panel()
		var node_id: String = str(step["node_id"])
		assert(not run.core_service_buttons[int(step["slot"])].disabled, "%s should be purchasable from the Progress menu at level %d" % [node_id, step["level"]])
		assert(run.core_action_states[int(step["slot"])] == "READY", "%s row should read READY before purchase" % node_id)
		var before: float = run.get(str(step["multiplier"])) if not str(step["multiplier"]).is_empty() else 0.0
		run._execute_core_action(int(step["slot"]))
		assert(PROGRESSION_TREE.is_unlocked(node_id, run.skill_unlocks), "%s should unlock through menu slot %d" % [node_id, step["slot"]])
		assert(run.core_action_states[int(step["slot"])] == "OWNED", "%s row should read OWNED after purchase" % node_id)
		assert(run.core_service_buttons[int(step["slot"])].disabled, "%s row should disable after purchase" % node_id)
		if node_id == "personal_base":
			assert(bool(run.construction_unlocks.get("personal_base", false)), "Personal Base blueprint should unlock from the Progress menu")
		elif node_id == "excavation":
			assert(run.mining_cycle_multiplier < 1.0, "Excavation should apply its mining multiplier when purchased from the menu")
		else:
			assert(run.get(str(step["multiplier"])) > before, "%s should apply its multiplier when purchased from the menu" % node_id)

	run.expedition_level = 2
	run.skill_points = 0
	run.skill_unlocks.clear()
	run.skill_unlocks.append("overclock")
	run._rebuild_progression_multipliers()
	run._refresh_core_base_panel()
	assert(run.core_action_states[1] == "NEED 1 SP", "Level-gated nodes should expose missing SP in the Progress menu")
	assert(run.core_service_buttons[1].disabled, "Progress purchases should stay blocked without banked SP")

	run.skill_unlocks.clear()
	run.expedition_level = 5
	run.skill_points = 1
	run._rebuild_progression_multipliers()
	run._refresh_core_base_panel()
	assert(run.core_action_states[4] == "REQUIRES FORTIFY BUNKER", "Personal Base should stay blocked at level 5 without Fortify")
	assert(run.core_service_buttons[4].disabled, "Personal Base purchase should stay disabled without Fortify")

	run.skill_unlocks.clear()
	run.expedition_level = 2
	run.skill_points = 1
	run._rebuild_progression_multipliers()
	run._refresh_core_base_panel()
	assert(run.core_action_states[3] == "READY", "Excavation should be available at level 2 without Automation")
	assert(not run.core_service_buttons[3].disabled, "Excavation purchase should be enabled without Automation")

	print("CRAWL_BRAWL_PROGRESSION_MENU_UNLOCK_TEST_OK")
	quit(0)
