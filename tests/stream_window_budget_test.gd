extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const TEST_HARNESS := preload("res://tests/test_harness.gd")


func _initialize() -> void:
	call_deferred("_run_stream_window_budget_test")


func _run_stream_window_budget_test() -> void:
	TEST_HARNESS.reset()
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(808080, "bastion", true)
	grid.configure_prepare_zone(grid.core_cell)

	var focus := grid.core_cell
	for step in range(50):
		focus += Vector2i(WORLD_GRID.REGION_SIZE, 0)
		var bounds := Rect2i(focus - Vector2i(96, 96), Vector2i(192, 192))
		var desired := grid.compute_desired_render_regions(bounds, [focus], 2, focus)
		TEST_HARNESS.require(
			desired.size() <= WORLD_GRID.MAX_RENDER_REGIONS,
			"Desired render window must respect MAX_RENDER_REGIONS"
		)
		grid.apply_render_window(desired, focus)
		TEST_HARNESS.require(
			grid.stream_window_regions().size() <= WORLD_GRID.MAX_RENDER_REGIONS,
			"Active render window must stay capped after repeated travel"
		)

	print("CRAWL_BRAWL_STREAM_WINDOW_BUDGET_TEST_OK")
	quit(0)
