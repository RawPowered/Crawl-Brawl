extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run")


func _find_field_site(run) -> Vector2i:
	var columns := ceili(float(run.grid.width) / float(WORLD_GRID.REGION_SIZE))
	var rows := ceili(float(run.grid.height) / float(WORLD_GRID.REGION_SIZE))
	for region_y in range(rows):
		for region_x in range(columns):
			var region := Vector2i(region_x, region_y)
			if region == run.grid.region_for_cell(run.grid.core_cell):
				continue
			var region_center: Vector2i = region * WORLD_GRID.REGION_SIZE + Vector2i(12, 12)
			run.grid.activate_region_window([region_center], 1)
			for y in range(2, WORLD_GRID.REGION_SIZE - 3):
				for x in range(2, WORLD_GRID.REGION_SIZE - 4):
					var candidate: Vector2i = region * WORLD_GRID.REGION_SIZE + Vector2i(x, y)
					if not run.base_network.powered_base_for(candidate).is_empty():
						continue
					run.player_position = run.grid.cell_to_world(candidate)
					if run._can_place_structure(candidate):
						return candidate
	return Vector2i(-1, -1)


func _run() -> void:
	var original_active_realm := REALM_SAVE.active_realm_id()
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.construction_unlocks["personal_base"] = true
	run.deployable_stock["personal_base"] = 1
	run.selected_build = RUN_SCRIPT.BUILD_PERSONAL_BASE
	var field_cell := _find_field_site(run)
	assert(field_cell != Vector2i(-1, -1), "A prepared region outside Core territory should expose valid hut ground")
	run.player_position = run.grid.cell_to_world(field_cell)
	run._place_structure(field_cell)
	var shelter_index: int = run._personal_base_index_for_anchor_id("hut:%d:%d" % [field_cell.x, field_cell.y])
	assert(shelter_index >= 0, "Field hut should deploy without a Core owner")
	var shelter = run.structures[shelter_index]
	assert(shelter.base_id.is_empty() and shelter.powered, "A field hut must operate without granting Core territory")
	run.player_health = 25.0
	run.sprint_energy = 10.0
	run._try_rest_at_personal_base(shelter_index)
	assert(run.sleeping, "An unowned field hut should permit rest")
	for unused in range(16):
		if not run.sleeping:
			break
		run._update_sleep_sequence(1.0)
	assert(not run.sleeping and run.player_health >= 99.0 and run.sprint_energy >= 99.0, "Field rest should restore suit and energy")
	assert(run.checkpoint_exists and run.checkpoint_base_id == "hut:%d:%d" % [field_cell.x, field_cell.y], "Resting should establish the field hut as the active checkpoint")
	assert(REALM_SAVE.load_active_save().get("checkpoint_base_id", "") == run.checkpoint_base_id, "The field checkpoint should be committed to protected realm storage")
	assert(run._load_run(), "A realm saved at an unowned hut should reload")
	assert(run.checkpoint_base_id == "hut:%d:%d" % [field_cell.x, field_cell.y], "Reload should retain the hut checkpoint identity")
	assert(run._personal_base_index_for_anchor_id(run.checkpoint_base_id) >= 0, "Reload should restore the checkpoint hut before resolving spawn")
	if not original_active_realm.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active_realm), "Field hut test should restore the prior active realm")
	print("CRAWL_BRAWL_FIELD_HUT_CHECKPOINT_TEST_OK")
	quit(0)
