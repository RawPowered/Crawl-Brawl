extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const FLOW_FIELD := preload("res://systems/flow_field.gd")


func _initialize() -> void:
	call_deferred("_run_regional_flow_field_test")


func _run_regional_flow_field_test() -> void:
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(919191, "bastion")
	var flow := FLOW_FIELD.new()
	var core_only := {grid.region_for_cell(grid.core_cell): true}
	flow.rebuild(grid, grid.core_cell, core_only)
	assert(flow.last_visit_count > 0, "Regional flow fields should still build a local distance map")
	assert(not flow.has_path(grid.spawn_cell), "A core-only window should not reach the sealed hive route")

	grid.open_cell(grid.tutorial_rock)
	var route_regions: Dictionary = grid.expand_regions(
		grid.corridor_regions_between(grid.spawn_cell, grid.core_cell, 4),
		1
	)
	route_regions[grid.region_for_cell(grid.core_cell)] = true
	route_regions[grid.region_for_cell(grid.spawn_cell)] = true
	flow.rebuild(grid, grid.core_cell, route_regions)
	assert(flow.has_path(grid.spawn_cell), "Regional flow fields should reach the hive once the siege corridor is included")

	var exterior_cell := Vector2i(512, -256)
	grid.activate_region_window([exterior_cell], 1)
	var exterior_regions := grid.expand_regions({grid.region_for_cell(exterior_cell): true}, 1)
	exterior_regions[grid.region_for_cell(grid.core_cell)] = true
	flow.rebuild(grid, exterior_cell, exterior_regions)
	assert(not flow.has_path(grid.spawn_cell) or flow.last_visit_count > 0, "Exterior signed coordinates should build region-local distance maps without OOB")

	print("CRAWL_BRAWL_REGIONAL_FLOW_FIELD_TEST_OK")
	quit(0)
