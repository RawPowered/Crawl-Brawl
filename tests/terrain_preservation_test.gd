extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_terrain_preservation_test")


func _run_terrain_preservation_test() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(909090, "bastion")
	assert(grid.uses_lazy_topology(), "Mega realms should use lazy topology")

	var bootstrap := grid._bootstrap_bounds_rect()
	var mined_cell := Vector2i(-1, -1)
	for y in range(bootstrap.position.y + 1, bootstrap.end.y - 1):
		for x in range(bootstrap.position.x + 1, bootstrap.end.x - 1):
			var candidate := Vector2i(x, y)
			if grid.can_mine(candidate) and not grid.is_start_chamber_reserved(candidate):
				mined_cell = candidate
				break
		if mined_cell.x >= 0:
			break
	assert(mined_cell.x >= 0, "Bootstrap should expose a mineable rock cell")
	assert(grid.open_cell(mined_cell), "Player mining should open bootstrap rock")
	assert(grid.is_walkable(mined_cell), "Mined cell should stay walkable before distant materialization")

	var distant_cell := Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.72), grid.core_cell.y)
	grid.activate_region_window([distant_cell], 1)
	assert(grid.is_walkable(mined_cell), "Distant region materialization must not re-seal player-mined cells")

	var flank_cell := Vector2i(mined_cell.x + 1, mined_cell.y)
	if grid.in_bounds(flank_cell) and grid.can_mine(flank_cell):
		assert(grid.open_cell(flank_cell), "Adjacent mining should stay available after region sync")
		grid.activate_region_window([flank_cell], 1)
		assert(grid.is_walkable(flank_cell), "Synced regions must preserve adjacent mined openings")

	print("CRAWL_BRAWL_TERRAIN_PRESERVATION_TEST_OK")
	quit(0)
