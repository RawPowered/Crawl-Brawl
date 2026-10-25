extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(90210, "bastion", true)
	grid.configure_discoveries(90210, "bastion")
	assert(not grid._uses_authored_bedrock_rim(), "Infinite sparse streaming should not apply the legacy bedrock box")
	var south_rim := Vector2i(grid.core_cell.x, grid.height - 1)
	grid.ensure_region_for_cell(south_rim)
	grid.populate_region_exploration(grid.region_for_cell(south_rim))
	assert(grid.get_cell(south_rim) != WORLD_GRID.BEDROCK, "Authored south edge should not remain sealed bedrock in infinite mode")
	var right_region := Vector2i(ceili(float(grid.width) / float(WORLD_GRID.REGION_SIZE)) + 2, grid.region_for_cell(grid.core_cell).y)
	var right_center := right_region * WORLD_GRID.REGION_SIZE + Vector2i.ONE * (WORLD_GRID.REGION_SIZE / 2)
	grid.activate_region_window([right_center], 1)
	assert(grid.is_region_active(right_center), "A region beyond the authored right edge should become active")
	assert(grid.is_walkable(right_center), "Infinite chunks should contain deterministic connected cave topology")
	assert(grid.is_walkable(right_region * WORLD_GRID.REGION_SIZE + Vector2i(0, WORLD_GRID.REGION_SIZE / 2)), "Adjacent infinite chunks should share an open seam")

	var negative_region := Vector2i(-3, -2)
	var negative_center := negative_region * WORLD_GRID.REGION_SIZE + Vector2i.ONE * (WORLD_GRID.REGION_SIZE / 2)
	grid.activate_region_window([negative_center], 1)
	assert(grid.is_region_active(negative_center) and grid.is_walkable(negative_center), "Signed negative regions should generate and activate")
	grid.set_cell(negative_center, WORLD_GRID.ROCK)
	assert(grid.cell_deltas.has(negative_center), "Exterior terrain edits should use the sparse delta journal")
	grid.activate_region_window([right_center], 1)
	assert(not grid._region_cells.has(negative_region), "Inactive exterior chunk terrain should hibernate instead of accumulating forever")
	grid.activate_region_window([negative_center], 1)
	assert(grid.get_cell(negative_center) == WORLD_GRID.ROCK, "A hibernated exterior chunk should restore its terrain delta when revisited")
	var biome := grid.region_biome(negative_region)
	var comparison := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	comparison.generate_realm(90210, "bastion", true)
	comparison.configure_discoveries(90210, "bastion")
	comparison.activate_region_window([negative_center], 1)
	assert(comparison.get_cell(negative_center) == WORLD_GRID.FLOOR and comparison.region_biome(negative_region) == biome, "Infinite baseline topology and biome identity must be seed deterministic")
	print("CRAWL_BRAWL_INFINITE_REGION_STREAM_TEST_OK")
	quit(0)
