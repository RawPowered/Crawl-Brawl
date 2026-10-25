extends SceneTree


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run()
	var run = null
	for _frame in range(12):
		await process_frame
		run = main.current_screen
		if run == null or run.grid == null:
			continue
		run._sync_terrain_chunk_layers()
		if run.terrain_chunk_layers.size() == run.grid.stream_window_regions().size() and not run.terrain_chunk_layers.is_empty():
			break
	assert(run != null and run.grid != null, "Run screen should be ready after boot frames")
	assert(not run.terrain_chunk_layers.is_empty(), "Prepared terrain should create retained render chunks")
	assert(
		run.terrain_chunk_layers.size() == run.grid.stream_window_regions().size(),
		"Retained terrain chunks should mirror the active stream window"
	)
	assert(run.grid.stream_window_regions().size() >= 1, "Viewport render should activate at least one stream region at boot")
	assert(
		run.terrain_chunk_layers.size() <= maxi(run.grid.loaded_regions.size(), run.grid.stream_window_regions().size()),
		"Render chunks should stay within the active stream window"
	)
	var target: Vector2i = run.grid.tutorial_rock
	var target_region: Vector2i = run.grid.region_for_cell(target)
	run.terrain_chunk_redraw_queue.clear()
	if not run.grid.is_walkable(target):
		assert(run.grid.open_cell(target), "Fixture should open the initial mineable wall")
	run.terrain_chunk_redraw_queue.clear()
	run._mark_terrain_cell_dirty(target)
	assert(run.terrain_chunk_redraw_queue.has(target_region), "Mining should invalidate its owning render chunk")
	run._queue_visual_redraw()
	await process_frame
	assert(not run.terrain_chunk_redraw_queue.has(target_region), "One dirty terrain chunk should rebuild on the next frame")
	print("CRAWL_BRAWL_TERRAIN_CHUNK_RENDER_TEST_OK")
	quit(0)
