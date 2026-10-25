extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const FLOW_FIELD := preload("res://systems/flow_field.gd")
const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# BV5.5: active-world budgets are hard invariants. Even a legacy caller that
	# hands the grid a 7x7 render set cannot leave more than the configured local
	# render/simulation envelope alive.
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(5550055, "bastion", true)
	grid.configure_discoveries(5550055, "bastion")
	var prep_index := 0
	while not grid.prepare_zone_bulk_is_complete(prep_index):
		prep_index = grid.bulk_materialize_prepare_zone(Callable(), 4096, prep_index)
	var focus := grid.core_cell
	var focus_region := grid.region_for_cell(focus)
	var huge: Dictionary = {}
	for y in range(-3, 4):
		for x in range(-3, 4):
			huge[focus_region + Vector2i(x, y)] = true
	grid.apply_render_window(huge, focus)
	assert(grid.stream_window_regions().size() <= WORLD_GRID.MAX_RENDER_REGIONS, "render window must be hard-capped")
	assert(grid.simulation_window_regions().size() <= WORLD_GRID.MAX_SIMULATION_REGIONS, "simulation request window must be hard-capped")
	assert(grid.loaded_regions.size() <= WORLD_GRID.MAX_SIMULATION_REGIONS, "loaded simulation regions must be hard-capped")
	assert(WORLD_GRID.MAX_SIMULATION_REGIONS <= WORLD_GRID.MAX_FLOW_REGIONS, "every active simulation region must fit inside full regional-flow coverage")

	# Preparation requests are not simulation ownership. Far ecology/frontier
	# helpers may prepare chunks without silently growing loaded_regions.
	var local_render := {focus_region: true}
	grid.apply_render_window(local_render, focus)
	var loaded_before: Dictionary = grid.loaded_regions.duplicate()
	var far_cell := focus + Vector2i(WORLD_GRID.REGION_SIZE * 4, 0)
	grid.ensure_regions_around(far_cell, 1)
	assert(grid.loaded_regions.size() == loaded_before.size(), "ensure_regions_around must not grow simulation ownership in sparse streaming")
	for region_value: Variant in loaded_before.keys():
		assert(grid.loaded_regions.has(region_value), "prepare-only request must preserve the active simulation set")

	# BV5.5: one regional-flow exit decision is committed for the time a mob stays
	# in the same source cell. The second call should reuse the exact cached step
	# rather than reranking neighbors/clearance again.
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	var source := run.grid.world_to_cell(run.player_position)
	var target := source + Vector2i(3, 0)
	for x in range(source.x - 1, target.x + 2):
		for y in range(source.y - 2, source.y + 3):
			run.grid.set_cell(Vector2i(x, y), WORLD_GRID.FLOOR)
	var allowed := run.grid.expand_regions({run.grid.region_for_cell(source): true, run.grid.region_for_cell(target): true}, 1)
	var flow := FLOW_FIELD.new()
	flow.rebuild(run.grid, target, allowed)
	var spider := RUN_SCRIPT.Spider.new()
	spider.position = run.grid.cell_to_world(source)
	spider.radius = 5.0
	var first := run._flow_route_step_for_spider(spider, flow, source, "bv55_target", spider.radius)
	assert(first != source, "regional flow should produce a committed next step on open terrain")
	assert(spider.flow_step_from == source, "flow-step cache should remember its source cell")
	assert(spider.flow_step_next == first, "flow-step cache should remember the chosen exit")
	var second := run._flow_route_step_for_spider(spider, flow, source, "bv55_target", spider.radius)
	assert(second == first, "same-cell flow step must remain stable until target/epoch/cell changes")

	print("CRAWL_BRAWL_FRAME_BUDGET_BV55_TEST_OK")
	quit(0)
