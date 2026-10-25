extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	var seed := 424242
	var region := Vector2i(24, 3)
	var grid: WorldGrid = _prepared_grid(seed, region)
	var duplicate: WorldGrid = _prepared_grid(seed, region)
	var cells: Array[Vector2i] = []
	for cell_value: Variant in grid.mineral_cells.keys():
		var cell: Vector2i = cell_value
		if grid.region_for_cell(cell) == region:
			cells.append(cell)
	assert(cells.size() >= 4 and cells.size() <= 11, "A region should receive bounded, useful mineral pockets")
	var visible_leads := 0
	var buried_members := 0
	var connected_pair := false
	for cell: Vector2i in cells:
		var exposed: bool = grid._touches_floor(cell)
		if exposed and not grid.is_mineral_concealed(cell) and grid.get_mineral_type(cell) != WORLD_GRID.MINERAL_CACHE:
			visible_leads += 1
		if not exposed:
			buried_members += 1
		for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
			var neighbor := cell + direction
			if grid.get_mineral_type(neighbor) == grid.get_mineral_type(cell):
				connected_pair = true
	assert(visible_leads > 0, "Ordinary mineral veins should advertise at least one visible cave-face lead")
	assert(buried_members > 0, "Mineral seams should extend into interior rock")
	assert(connected_pair, "Minerals should form mineable pockets rather than only isolated edge dots")
	assert(grid.mineral_cells == duplicate.mineral_cells and grid.concealed_minerals == duplicate.concealed_minerals, "Vein placement and concealment should remain seed deterministic")
	print("CRAWL_BRAWL_MINERAL_VEIN_DISTRIBUTION_TEST_OK")
	quit(0)


func _prepared_grid(seed: int, region: Vector2i) -> WorldGrid:
	var grid: WorldGrid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(seed, "onslaught")
	grid.configure_discoveries(seed, "onslaught")
	var center := region * WORLD_GRID.REGION_SIZE + Vector2i.ONE * (WORLD_GRID.REGION_SIZE / 2)
	grid.activate_region_window([center], 0)
	return grid
