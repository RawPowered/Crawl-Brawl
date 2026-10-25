extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")


func _initialize() -> void:
	call_deferred("_run_progression_tree_test")


func _run_progression_tree_test() -> void:
	assert(PROGRESSION_TREE.node_ids().size() == 5, "Progression tree should expose five unlock nodes including Personal Base blueprint")
	assert(PROGRESSION_TREE.can_unlock("overclock", [], 1, 1) == "READY", "One SP and level 1 should unlock Overclock")
	assert(PROGRESSION_TREE.can_unlock("overclock", [], 0, 1) == "NEED 1 SP", "Unlocks should require banked skill points")
	assert(PROGRESSION_TREE.can_unlock("overclock", ["overclock"], 1, 1) == "ALREADY UNLOCKED", "Duplicate unlocks should be blocked")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	var damage_before: float = run.weapon_damage_multiplier
	run.expedition_level = 1
	run.skill_points = 1
	assert(run._unlock_skill_node("overclock"), "Spending SP should apply the Overclock branch")
	assert(run.weapon_damage_multiplier > damage_before, "Overclock should raise the weapon multiplier")
	assert(run.skill_points == 0 and "overclock" in run.skill_unlocks, "Unlocking should consume SP and record the node")

	run.expedition_xp = run._expedition_xp_threshold()
	run.wave = 3
	var level_before: int = run.expedition_level
	var sp_before: int = run.skill_points
	run._award_expedition_xp()
	assert(run.expedition_level > level_before, "Filled XP should advance expedition level")
	assert(run.skill_points > sp_before, "Leveling should grant at least one skill point")

	print("CRAWL_BRAWL_PROGRESSION_TREE_TEST_OK")
	quit(0)
