extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_terrain_seam_render_test")


func _run_terrain_seam_render_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	var uniform_floor_origin := Vector2i(-1, -1)
	for y in range(run.grid.core_cell.y - 4, run.grid.core_cell.y + 6):
		for x in range(run.grid.core_cell.x - 4, run.grid.core_cell.x + 6):
			var candidate := run._macro_block_origin(Vector2i(x, y))
			if run._macro_block_is_complete_floor(candidate) and run._macro_block_has_uniform_floor_material(candidate):
				uniform_floor_origin = candidate
				break
		if uniform_floor_origin.x >= 0:
			break
	assert(uniform_floor_origin.x >= 0, "Active realm should expose a uniform complete floor macro block")

	var player_cell: Vector2i = run.grid.world_to_cell(run.player_position)
	var prepared_before: Dictionary = run.grid.loaded_regions.duplicate()
	run.grid.schedule_region_window([player_cell], 1)
	run.grid.process_region_preload_budget(0)
	assert(not run.grid.stream_window_regions().is_empty(), "Region scheduling should populate the stream window")
	run._sync_terrain_chunk_layers()
	assert(
		run.terrain_chunk_layers.size() == run.grid.stream_window_regions().size(),
		"Retained terrain chunks should mirror the active stream window"
	)
	assert(
		run.terrain_chunk_layers.size() <= run.grid.loaded_regions.size(),
		"Render chunks should stay within prepared simulation regions"
	)

	var narrow_window: Dictionary = run.grid.stream_window_regions().duplicate()
	run.grid.schedule_region_window([player_cell], 2)
	run.grid.process_region_preload_budget(0)
	var expanded_window: Dictionary = run.grid.stream_window_regions().duplicate()
	assert(expanded_window.size() > narrow_window.size(), "Expanding the stream radius should add regions")
	var border_region: Vector2i = Vector2i.ZERO
	var added_region: Vector2i = Vector2i.ZERO
	for region_value: Variant in expanded_window.keys():
		if narrow_window.has(region_value):
			continue
		added_region = region_value
		for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor := added_region + direction
			if narrow_window.has(neighbor):
				border_region = neighbor
				break
		if border_region != Vector2i.ZERO:
			break
	assert(added_region != Vector2i.ZERO, "Expanded stream window should add at least one region")
	assert(border_region != Vector2i.ZERO, "Added stream regions should touch an existing border region")
	run.terrain_chunk_redraw_queue.clear()
	assert(
		run._sync_terrain_chunk_layers(),
		"Stream window expansion should request a burst terrain flush"
	)
	assert(
		run.terrain_chunk_redraw_queue.has(border_region),
		"Pre-existing border regions must invalidate when the stream window expands"
	)
	run._flush_terrain_chunk_redraws(maxi(run.terrain_chunk_redraw_queue.size(), 1))
	assert(
		run.terrain_chunk_redraw_queue.is_empty(),
		"Burst flush should clear the terrain redraw queue after a stream window change"
	)
	run._queue_visual_redraw()
	assert(
		run.terrain_chunk_redraw_queue.is_empty(),
		"Stable-window redraw should not leave a backlog after stream expansion flush"
	)
	for region_value: Variant in expanded_window.keys():
		assert(
			run.terrain_chunk_layers.has(region_value) and is_instance_valid(run.terrain_chunk_layers[region_value]),
			"Every stream region should retain a valid terrain chunk after burst flush"
		)

	var left_region: Vector2i = run.grid.region_for_cell(player_cell)
	var right_region := left_region + Vector2i.RIGHT
	assert(expanded_window.has(left_region) and expanded_window.has(right_region), "Player should sit between two stream regions")
	var border_column := right_region.x * WORLD_GRID.REGION_SIZE
	var left_bounds: Rect2i = run._terrain_chunk_draw_bounds(left_region)
	var right_bounds: Rect2i = run._terrain_chunk_draw_bounds(right_region)
	assert(left_bounds.has_point(Vector2i(border_column - 1, player_cell.y)), "Left region bleed should cover the column before the border")
	assert(right_bounds.has_point(Vector2i(border_column, player_cell.y)), "Right region bleed should cover the border column")
	var merged_bounds: Rect2i = run._terrain_stream_draw_bounds()
	assert(
		merged_bounds.has_point(Vector2i(border_column - 1, player_cell.y))
		and merged_bounds.has_point(Vector2i(border_column, player_cell.y)),
		"Merged stream draw bounds should cover both sides of an inter-region border"
	)

	run.terrain_chunk_redraw_queue.clear()
	var prepared_now := run.grid.process_region_preload_budget(1)
	if prepared_now > 0:
		for region_value: Variant in run.grid.loaded_regions.keys():
			if prepared_before.has(region_value):
				continue
			run._invalidate_visual_region(region_value * WORLD_GRID.REGION_SIZE)
			assert(
				run.terrain_chunk_redraw_queue.has(region_value),
				"Newly prepared regions must invalidate their retained terrain chunk"
			)
			break

	print("CRAWL_BRAWL_TERRAIN_SEAM_RENDER_TEST_OK")
	quit(0)
