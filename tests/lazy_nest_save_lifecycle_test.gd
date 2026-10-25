extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")


func _initialize() -> void:
	call_deferred("_run_lazy_nest_save_lifecycle_test")


func _find_nest_cell(run: RUN_SCRIPT) -> Vector2i:
	for region_value: Variant in run.grid._discovery_plan.keys():
		var assignments: Array = run.grid._discovery_plan[region_value]
		if not assignments.has("nest"):
			continue
		var region: Vector2i = region_value
		run.grid.populate_region_exploration(region)
		for cell_value: Variant in run.grid.discovery_cells.keys():
			if str(run.grid.discovery_cells[cell_value]) == "nest":
				return cell_value
	return Vector2i(-1, -1)


func _run_lazy_nest_save_lifecycle_test() -> void:
	var original_active_realm := REALM_SAVE.active_realm_id()
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	var nest_cell := _find_nest_cell(run)
	assert(nest_cell.x >= 0, "Seeded realms should expose at least one nest discovery")
	run.grid.activate_region_window([nest_cell], 2)
	run.grid.open_discovery_chamber(nest_cell, 1)
	run.breached = true
	run.wave = 4
	run._resolve_mining_discovery(nest_cell)
	assert(run.brood_nests.size() >= 1, "Exposed nest discoveries should establish a brood nest")
	assert(str(run.grid.revealed_discoveries.get(nest_cell, "")) == "nest", "Nest discoveries should remain revealed for save")
	run.brood_nests[0].maturity = 1.0
	assert(run.grid.register_spawn_cell(nest_cell), "Mature nest fronts should register as spawn lanes before checkpointing")

	run.checkpoint_exists = true
	run.checkpoint_base_id = run.base_network.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 1
	assert(run._save_run(false, true), "Nest state should checkpoint to the protected realm save")

	assert(run._load_run(), "Nest checkpoint should reload cleanly")
	assert(run.brood_nests.size() >= 1, "Reload should restore brood nest records")
	assert(str(run.grid.revealed_discoveries.get(nest_cell, "")) == "nest", "Reload should preserve revealed nest discoveries")
	assert(run.grid.spawn_cells.has(nest_cell), "Reload must preserve mature nest spawn lanes")

	if not original_active_realm.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active_realm), "Nest lifecycle test should restore the previous active realm pointer")

	print("CRAWL_BRAWL_LAZY_NEST_SAVE_LIFECYCLE_TEST_OK")
	quit(0)
