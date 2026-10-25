extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_open_world_boundary_test")


func _run_open_world_boundary_test() -> void:
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(707070, "bastion", true)
	grid.configure_discoveries(707070, "bastion")
	assert(not grid._uses_authored_bedrock_rim(), "Infinite sparse realms should not use the legacy bedrock box")

	var south_rim := Vector2i(grid.core_cell.x, grid.height - 1)
	grid.ensure_region_for_cell(south_rim)
	grid.populate_region_exploration(grid.region_for_cell(south_rim))
	assert(grid.get_cell(south_rim) != WORLD_GRID.BEDROCK, "Former south bedrock rim must not block travel in infinite mode")

	var player_cell := grid.core_cell + Vector2i(0, 36)
	var ahead_region := grid.region_for_cell(player_cell) + Vector2i(0, 1)
	var ahead_cell := ahead_region * WORLD_GRID.REGION_SIZE + Vector2i(WORLD_GRID.REGION_SIZE / 2, WORLD_GRID.REGION_SIZE / 2)
	grid.ensure_region_for_cell(player_cell)
	grid.ensure_region_for_cell(ahead_cell, true)
	assert(
		not grid.populated_regions.has(grid.region_for_cell(ahead_cell)),
		"Ahead ensure should enqueue instead of sync populate"
	)
	grid.populate_region_exploration(grid.region_for_cell(player_cell))
	grid.populate_region_exploration(grid.region_for_cell(ahead_cell))
	assert(grid.region_readiness(grid.region_for_cell(player_cell)) == WORLD_GRID.RegionReadiness.PREPARED, "Prepared terrain must remain non-ticking until a simulation ticket reaches it")
	assert(grid.region_readiness(grid.region_for_cell(ahead_cell)) == WORLD_GRID.RegionReadiness.PREPARED, "Ahead generation must not imply active simulation")
	assert(grid.is_walkable(ahead_cell), "Region seam ahead should expose walkable floor instead of a hard wall")

	var view_bounds := Rect2i(player_cell - Vector2i(24, 24), Vector2i(48, 48))
	var added := grid.activate_render_window_for_bounds(view_bounds, 1, player_cell)
	assert(grid.is_region_active(player_cell), "Visible player terrain should enter the simulation window")
	assert(grid.is_region_active(ahead_cell), "The simulation halo should keep the lookahead region ticking")
	assert(added >= 1, "Viewport render activation should cover visible prepared regions")
	assert(grid.stream_window_regions().has(grid.region_for_cell(player_cell)), "Player region should enter the render window")
	assert(grid.stream_window_regions().has(grid.region_for_cell(ahead_cell)), "Lookahead region should enter the render window")

	print("CRAWL_BRAWL_OPEN_WORLD_BOUNDARY_TEST_OK")
	quit(0)
