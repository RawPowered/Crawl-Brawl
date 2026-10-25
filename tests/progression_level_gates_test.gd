extends SceneTree

const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")


func _initialize() -> void:
	call_deferred("_run_progression_level_gates_test")


func _run_progression_level_gates_test() -> void:
	assert(PROGRESSION_TREE.max_level_requirement() == 5, "The shipped tree should cap branch unlocks at expedition level 5")
	assert(PROGRESSION_TREE.can_unlock("overclock", [], 1, 0) == "NEED EXPEDITION LEVEL 1", "Overclock should unlock at level 1")
	assert(PROGRESSION_TREE.can_unlock("overclock", [], 1, 1) == "READY", "Level 1 should expose Overclock")
	assert(PROGRESSION_TREE.can_unlock("fortify", [], 1, 1) == "NEED EXPEDITION LEVEL 2", "Fortify should wait for level 2")
	assert(PROGRESSION_TREE.can_unlock("automation", [], 1, 3) == "READY", "Automation should unlock at level 3")
	assert(PROGRESSION_TREE.can_unlock("excavation", [], 1, 1) == "NEED EXPEDITION LEVEL 2", "Excavation should wait only until level 2")
	assert(PROGRESSION_TREE.can_unlock("excavation", [], 1, 2) == "READY", "Excavation should unlock at level 2 without Automation")
	assert(PROGRESSION_TREE.can_unlock("personal_base", ["fortify"], 1, 5) == "READY", "Personal Base should unlock at level 5 after Fortify")
	assert(PROGRESSION_TREE.next_tree_node(["overclock"]) == "fortify", "The roadmap should follow branch order")
	assert(PROGRESSION_TREE.next_locked_node(1, ["overclock"]) == "fortify", "Fortify should remain level-gated below expedition level 2")

	print("CRAWL_BRAWL_PROGRESSION_LEVEL_GATES_TEST_OK")
	quit(0)
