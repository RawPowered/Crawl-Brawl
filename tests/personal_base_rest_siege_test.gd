extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_personal_base_rest_siege_test")


func _run_personal_base_rest_siege_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.breached = true
	run.wave_active = true
	run.wave = 12
	run.construction_unlocks["personal_base"] = true
	run.deployable_stock["personal_base"] = 1
	run.selected_build = run.BUILD_PERSONAL_BASE
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
	run.enemies.append(run.Spider.new())
	run.enemies[0].position = run.structures[shelter_index].position + Vector2(24, 0)

	run.player_position = run.structures[shelter_index].position
	run._try_rest_at_personal_base(shelter_index)
	assert(run.sleeping, "Personal Base rest should work during an active siege")

	print("CRAWL_BRAWL_PERSONAL_BASE_REST_SIEGE_TEST_OK")
	quit(0)
