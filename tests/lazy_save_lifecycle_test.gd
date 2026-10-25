extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")


func _initialize() -> void:
	call_deferred("_run_lazy_save_lifecycle_test")


func _find_mineable_cell(run: RUN_SCRIPT) -> Vector2i:
	var bootstrap := run.grid._bootstrap_bounds_rect()
	for y in range(bootstrap.position.y + 1, bootstrap.end.y - 1):
		for x in range(bootstrap.position.x + 1, bootstrap.end.x - 1):
			var candidate := Vector2i(x, y)
			if run.grid.can_mine(candidate) and not run.grid.is_start_chamber_reserved(candidate):
				return candidate
	return Vector2i(-1, -1)


func _run_lazy_save_lifecycle_test() -> void:
	var original_active_realm := REALM_SAVE.active_realm_id()
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	assert(run.grid.uses_lazy_topology(), "Lifecycle save test expects lazy topology realms")

	var mined_cell := _find_mineable_cell(run)
	assert(mined_cell.x >= 0, "Fresh run should expose a mineable bootstrap cell")
	assert(run.grid.open_cell(mined_cell), "Player mining should open bootstrap rock")
	assert(run.grid.is_walkable(mined_cell), "Mined cell should stay walkable before save")

	var distant_cell := Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.68), run.grid.core_cell.y)
	run.grid.activate_region_window([distant_cell], 1)
	assert(run.grid.is_walkable(mined_cell), "Distant streaming must not re-seal mined bootstrap cells")

	run.checkpoint_exists = true
	run.checkpoint_base_id = run.base_network.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 1
	assert(run._save_run(false, true), "Mined terrain should checkpoint to the protected realm save")
	assert(run.grid.cell_deltas.has(mined_cell), "Checkpoint save should persist terrain deltas")

	var saved: Dictionary = REALM_SAVE.load_active_save()
	assert(int(saved.get("generator_version", 0)) == WORLD_GRID.GENERATOR_VERSION, "Checkpoint save should record the generator contract version")
	assert(int(saved.get("terrain_delta_count", -1)) >= 1, "Checkpoint save should record terrain delta count")

	assert(run._load_run(), "Lazy realm checkpoint should reload cleanly")
	assert(run.grid.is_walkable(mined_cell), "Reload must preserve player-mined tunnels")
	assert(run.grid.cell_deltas.has(mined_cell), "Reload should restore sparse terrain deltas")

	run.grid.activate_region_window([distant_cell], 2)
	assert(run.grid.is_walkable(mined_cell), "Post-reload region streaming must preserve mined tunnels")

	if not original_active_realm.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active_realm), "Lifecycle test should restore the previous active realm pointer")

	print("CRAWL_BRAWL_LAZY_SAVE_LIFECYCLE_TEST_OK")
	quit(0)
