extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")


func _initialize() -> void:
	call_deferred("_run_region_foundation_test")


func _run_region_foundation_test() -> void:
	var seed := 417417
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(seed, "bastion")
	grid.configure_discoveries(seed, "bastion")
	assert(grid.cell_deltas.is_empty(), "Fresh deterministic terrain should not contain persistence deltas")

	var origin_cell: Vector2i = grid.core_cell
	grid.activate_region_window([origin_cell], 1)
	assert(grid.loaded_regions.size() <= 9 and grid.is_region_loaded(origin_cell), "The active simulation window should contain at most a 3x3 region ring")
	var distant_cell := Vector2i(5, 5)
	grid.activate_region_window([distant_cell], 1)
	assert(grid.loaded_regions.size() <= 9 and not grid.is_region_loaded(origin_cell), "Moving the active window should unload distant regions")
	assert(grid.is_region_visited(origin_cell) and grid.is_region_visited(distant_cell), "Unloaded regions should remain recorded as explored")
	assert(grid.populated_regions.has(grid.region_for_cell(distant_cell)), "Region streaming should populate exploration content on first load")

	var mined_cell := Vector2i(-1, -1)
	for y in range(1, grid.height - 1):
		for x in range(1, grid.width - 1):
			var candidate := Vector2i(x, y)
			if grid.can_mine(candidate):
				mined_cell = candidate
				break
		if mined_cell.x >= 0:
			break
	assert(mined_cell.x >= 0 and grid.open_cell(mined_cell), "The test realm should provide mutable rock terrain")
	assert(grid.cell_deltas.get(mined_cell, -1) == WORLD_GRID.FLOOR, "Mining should persist only the changed cell")

	var restored = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	restored.generate_realm(seed, "bastion")
	restored.configure_discoveries(seed, "bastion")
	assert(restored.restore_cell_deltas(grid.cell_deltas) == 1, "Version 4 terrain deltas should restore without a full world snapshot")
	assert(restored.is_walkable(mined_cell), "Restored terrain should retain mined passages")

	var legacy_cells: PackedInt32Array = grid.packed_cells()
	var migrated = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	migrated.generate_realm(seed, "bastion")
	migrated.configure_discoveries(seed, "bastion")
	assert(migrated.restore_legacy_cells(legacy_cells), "Version 3 full-cell terrain should migrate")
	assert(migrated.cell_deltas.get(mined_cell, -1) == WORLD_GRID.FLOOR, "Legacy terrain should convert into version 4 deltas")
	assert(REALM_SAVE.SAVE_SCHEMA == 14 and REALM_SAVE.MIN_SUPPORTED_SCHEMA == 3, "Realm storage should write checkpoint version 14 while accepting legacy version 3")

	print("CRAWL_BRAWL_REGION_FOUNDATION_TEST_OK")
	quit(0)
