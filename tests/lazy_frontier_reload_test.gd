extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")


func _initialize() -> void:
	call_deferred("_run_lazy_frontier_reload_test")


func _run_lazy_frontier_reload_test() -> void:
	var original_active_realm := REALM_SAVE.active_realm_id()
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	var site_id := BASE_NETWORK.NORTH_ID
	var site_cell: Vector2i = run.base_network.get_cell(site_id)
	run.base_network.bases[site_id]["revealed"] = true
	run.base_network.mark_guardian_cleared(site_id)
	run.wave = 6
	run.breached = true
	for sector_index in range(6):
		run.explored_sectors[Vector2i(sector_index, 0)] = true
	run.scrap = 1400
	run.player_position = run.grid.cell_to_world(site_cell)
	run.grid.activate_region_window([site_cell], run._region_stream_radius())
	run._interact_with_base(site_id)
	assert(run.base_network.get_status(site_id) == BASE_NETWORK.STATUS_ACTIVATING, "Frontier activation should begin from a prepared site")
	run.base_network.tick_activation(BASE_NETWORK.ACTIVATION_DURATION)
	assert(run.base_network.get_status(site_id) == BASE_NETWORK.STATUS_ACTIVE, "Frontier core should finish activation before save")

	run.realm_save_cooldown = 0.0
	run.checkpoint_exists = true
	run.checkpoint_base_id = site_id
	run.checkpoint_position = run._checkpoint_anchor_position(site_id)
	run.checkpoint_generation = 1
	assert(run._save_run(false, true), "Active frontier state should checkpoint cleanly")

	var distant_cell := Vector2i(int(run.grid.width * 0.78), run.grid.core_cell.y)
	run.player_position = run.grid.cell_to_world(distant_cell)
	run.grid.activate_region_window([distant_cell], run._region_stream_radius())
	assert(not run.grid.is_region_loaded(site_cell), "Moving away should unload the frontier region from the active window")

	assert(run._load_run(), "Frontier checkpoint should reload after region unload")
	assert(run.base_network.get_status(site_id) == BASE_NETWORK.STATUS_ACTIVE, "Reload should restore an active frontier core")
	assert(run.checkpoint_base_id == site_id, "Reload should keep the frontier respawn anchor")
	assert(
		run.grid.has_walkable_route(site_cell, run.grid.core_cell) or run.grid.is_region_visited(site_cell),
		"Reload must preserve frontier territory and route integrity"
	)

	if not original_active_realm.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active_realm), "Frontier reload test should restore the previous active realm pointer")

	print("CRAWL_BRAWL_LAZY_FRONTIER_RELOAD_TEST_OK")
	quit(0)
