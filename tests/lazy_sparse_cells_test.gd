extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_lazy_sparse_cells_test")


func _run_lazy_sparse_cells_test() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(616161, "bastion")
	assert(grid.uses_sparse_cells(), "Mega realms should use sparse region cell storage")
	assert(grid.cells.is_empty(), "Sparse realms should not allocate a full cell buffer at boot")
	assert(grid.materialized_region_count() < grid._region_rows() * grid._region_columns(), "Sparse realms should only allocate visited bootstrap and frontier regions at boot")

	var distant_cell := Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.74), int(WORLD_GRID.REALM_HEIGHT * 0.66))
	assert(grid.get_cell(distant_cell) == WORLD_GRID.ROCK, "Unvisited regions should read as rock without allocating storage")
	grid.activate_region_window([distant_cell], 1)
	assert(grid.get_cell(distant_cell) == WORLD_GRID.FLOOR or grid.get_cell(distant_cell) == WORLD_GRID.ROCK, "Visited regions should materialize local terrain on demand")

	var mined_cell := Vector2i(-1, -1)
	var bootstrap := grid._bootstrap_bounds_rect()
	for y in range(bootstrap.position.y + 1, bootstrap.end.y - 1):
		for x in range(bootstrap.position.x + 1, bootstrap.end.x - 1):
			var candidate := Vector2i(x, y)
			if grid.can_mine(candidate) and not grid.is_start_chamber_reserved(candidate):
				mined_cell = candidate
				break
		if mined_cell.x >= 0:
			break
	assert(mined_cell.x >= 0, "Bootstrap region should expose at least one mineable rock cell")
	assert(grid.cell_deltas.is_empty(), "Region materialization should not leave stray terrain deltas")
	assert(grid.open_cell(mined_cell), "Sparse realms should still allow mining deltas")
	assert(grid.cell_deltas.size() == 1, "Sparse mining should persist only changed cells")

	var restored = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	restored.generate_realm(616161, "bastion")
	assert(restored.restore_cell_deltas(grid.cell_deltas) == 1, "Sparse realms should restore version 4 terrain deltas")
	assert(restored.is_walkable(mined_cell), "Restored sparse terrain should retain mined passages")

	var packed := grid.packed_cells()
	assert(packed.size() == WORLD_GRID.REALM_WIDTH * WORLD_GRID.REALM_HEIGHT, "Packed snapshots should still expose a full realm buffer for legacy callers")

	print("CRAWL_BRAWL_LAZY_SPARSE_CELLS_TEST_OK")
	quit(0)
