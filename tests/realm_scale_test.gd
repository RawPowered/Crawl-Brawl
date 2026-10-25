extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_realm_scale_test")


func _run_realm_scale_test() -> void:
	assert(WORLD_GRID.REALM_WIDTH == 512 and WORLD_GRID.REALM_HEIGHT == 288, "The expedition realm should use the fixed 512x288 bump")
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(424242, "bastion")
	grid.configure_discoveries(424242, "bastion")
	assert(grid.width == 512 and grid.height == 288, "New realms should boot at the expanded fixed size")
	assert(grid._discovery_resource_cells() == int(float(WORLD_GRID.REALM_WIDTH * WORLD_GRID.REALM_HEIGHT) * WORLD_GRID.DISCOVERY_RESOURCE_AREA_RATIO), "Resource counts should scale with expanded realm area")

	var distant_cell := Vector2i(int(WORLD_GRID.REALM_WIDTH * 0.72), int(WORLD_GRID.REALM_HEIGHT * 0.18))
	var distant_region := grid.region_for_cell(distant_cell)
	var minerals_before: int = grid.mineral_cells.size()
	grid.activate_region_window([distant_cell], 2)
	assert(grid.region_biome(distant_region) >= WORLD_GRID.BIOME_TUNNEL, "Each region should resolve a biome id")
	assert(grid.mineral_cells.size() >= minerals_before, "Lazy region loading should seed local exploration deposits")

	grid.materialize_all_discoveries_for_tests()
	var nest_cells: Array[Vector2i] = []
	for cell_value: Variant in grid.discovery_cells.keys():
		var cell: Vector2i = cell_value
		if str(grid.discovery_cells[cell]) == "nest":
			nest_cells.append(cell)
	assert(nest_cells.size() == 3, "The expanded realm should still seed three discovery nests")
	for nest_cell: Vector2i in nest_cells:
		assert(nest_cell.distance_to(grid.core_cell) >= grid.realm_span() * WORLD_GRID.DISCOVERY_NEST_MIN_CORE_RATIO * 0.82, "Expanded realms should keep nests in the outer band")

	grid.activate_prepare_zone()
	assert(grid.prepared_cell_bounds().size == Vector2i(WORLD_GRID.INITIAL_PREPARE_SIZE, WORLD_GRID.INITIAL_PREPARE_SIZE), "Prepare zone should anchor on the command core")
	assert(grid.prepare_zone_region_list().size() <= 121, "Prepare horizon should remain bounded for infinite streaming")

	var legacy_width := WORLD_GRID.LEGACY_REALM_WIDTH
	var legacy_height := WORLD_GRID.LEGACY_REALM_HEIGHT
	var legacy_cells: Array = []
	legacy_cells.resize(legacy_width * legacy_height)
	legacy_cells.fill(WORLD_GRID.ROCK)
	legacy_cells[12 * legacy_width + 18] = WORLD_GRID.FLOOR
	var upscale_grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	upscale_grid.generate_realm(515151, "bastion")
	assert(upscale_grid.restore_cells_upscaled(legacy_cells, legacy_width, legacy_height), "Legacy terrain snapshots should upscale into the expanded realm")
	assert(upscale_grid.get_cell(Vector2i(48, 32)) == WORLD_GRID.FLOOR, "Upscaled terrain should land on the nearest expanded cell anchor")

	var run = RUN_SCRIPT.new()
	var legacy_save := {
		"version": 11,
		"checkpoint_position": [64.0, 54.0],
		"cell_deltas": {"32,27": WORLD_GRID.FLOOR},
		"spawn_cells": [[16, 12]],
	}
	assert(run._save_needs_realm_upscale(legacy_save), "Pre-v12 saves should be treated as legacy realm snapshots")
	run._apply_realm_upscale_to_save(legacy_save, run._saved_realm_dimensions(legacy_save))
	assert(int(legacy_save.get("realm_width", 0)) == WORLD_GRID.REALM_WIDTH, "Legacy saves should promote realm width on load")
	var legacy_checkpoint: Array = legacy_save["checkpoint_position"]
	assert(is_equal_approx(float(legacy_checkpoint[0]), 64.0 * float(WORLD_GRID.REALM_WIDTH) / float(WORLD_GRID.LEGACY_REALM_WIDTH)), "Legacy checkpoint positions should scale with the realm bump")
	assert(is_equal_approx(float(legacy_checkpoint[1]), 54.0 * float(WORLD_GRID.REALM_HEIGHT) / float(WORLD_GRID.LEGACY_REALM_HEIGHT)), "Legacy checkpoint positions should scale with the realm bump")
	assert(legacy_save["cell_deltas"].has("85,72"), "Legacy encoded cell dictionaries should scale with the realm bump")
	assert(legacy_save["spawn_cells"][0] == [43, 32], "Legacy spawn cells should scale with the realm bump")

	var phase_a_save := {
		"version": 12,
		"realm_width": WORLD_GRID.PHASE_A_REALM_WIDTH,
		"realm_height": WORLD_GRID.PHASE_A_REALM_HEIGHT,
		"checkpoint_position": [96.0, 54.0],
		"spawn_cells": [[24, 18]],
	}
	assert(run._save_needs_realm_upscale(phase_a_save), "Phase A saves should promote into the Phase B realm size")
	run._apply_realm_upscale_to_save(phase_a_save, run._saved_realm_dimensions(phase_a_save))
	var phase_a_checkpoint: Array = phase_a_save["checkpoint_position"]
	assert(is_equal_approx(float(phase_a_checkpoint[0]), 128.0), "Phase A checkpoint positions should scale into the Phase B realm")
	assert(is_equal_approx(float(phase_a_checkpoint[1]), 72.0), "Phase A checkpoint positions should scale into the Phase B realm")
	assert(phase_a_save["spawn_cells"][0] == [32, 24], "Phase A spawn cells should scale into the Phase B realm")

	print("CRAWL_BRAWL_REALM_SCALE_TEST_OK")
	quit(0)
