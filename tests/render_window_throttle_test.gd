extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_render_window_throttle_test")


func _run_render_window_throttle_test() -> void:
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(919191, "bastion", true)
	grid.configure_prepare_zone(grid.core_cell)
	var noop := func(_progress: Dictionary) -> void:
		pass
	var bulk_index := 0
	while not grid.prepare_zone_bulk_is_complete(bulk_index):
		bulk_index = grid.bulk_materialize_prepare_zone(noop, 9999, bulk_index)

	var focus := grid.core_cell
	var bounds := Rect2i(focus - Vector2i(96, 96), Vector2i(192, 192))
	var centers: Array = [focus]
	var desired := grid.compute_desired_render_regions(bounds, centers, 2, focus)
	grid.apply_render_window(desired, focus)
	var first_size := grid.stream_window_regions().size()
	assert(first_size >= 1, "Initial render apply should activate the focused region")

	for step in range(10):
		desired = grid.compute_desired_render_regions(bounds, centers, 2, focus)
		var diff := grid.apply_render_window(desired, focus)
		assert(diff.added.is_empty(), "Identical render signature should not add regions on repeat apply")
		assert(diff.removed.is_empty(), "Identical render signature should not remove regions on repeat apply")
		assert(grid.stream_window_regions().size() == first_size, "Render window size should stay stable when desired set is unchanged")

	focus += Vector2i(WORLD_GRID.REGION_SIZE * 2, 0)
	bounds = Rect2i(focus - Vector2i(96, 96), Vector2i(192, 192))
	centers = [focus]
	desired = grid.compute_desired_render_regions(bounds, centers, 2, focus)
	var travel_diff := grid.apply_render_window(desired, focus)
	assert(not travel_diff.added.is_empty() or not travel_diff.removed.is_empty(), "Travel should slide the render window")

	print("CRAWL_BRAWL_RENDER_WINDOW_THROTTLE_TEST_OK")
	quit(0)
