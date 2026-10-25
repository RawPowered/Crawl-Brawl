extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(535353, "bastion", true)
	grid.configure_discoveries(535353, "bastion")
	var initial_bounds := grid.prepared_cell_bounds()
	assert(initial_bounds.size == Vector2i(WORLD_GRID.INITIAL_PREPARE_SIZE, WORLD_GRID.INITIAL_PREPARE_SIZE), "prepare horizon size contract")
	assert(grid.prepare_zone_region_list().size() <= 121, "prepare horizon must stay bounded")
	var near_edge := initial_bounds.position + Vector2i(WORLD_GRID.EXPANSION_EDGE_THRESHOLD - 1, int(initial_bounds.size.y / 2))
	assert(grid.try_expand_prepare_zone(near_edge), "horizon should recenter near edge")
	assert(grid.prepared_cell_bounds().size == initial_bounds.size, "horizon must not grow")

	# Prepared generation is not the same as active simulation.
	var far_region := grid.region_for_cell(grid.prepared_cell_bounds().position + Vector2i(WORLD_GRID.REGION_SIZE, WORLD_GRID.REGION_SIZE))
	grid.populate_region_exploration(far_region)
	assert(grid.region_readiness(far_region) == WORLD_GRID.RegionReadiness.PREPARED, "prepared chunk must not become simulation-active")

	# Direct activation remains a compact compatibility path for tests/tools.
	var far_center := far_region * WORLD_GRID.REGION_SIZE + Vector2i.ONE * (WORLD_GRID.REGION_SIZE / 2)
	grid.activate_region_window([far_center], 1)
	assert(grid.is_region_active(far_center), "requested chunk should become active")
	var other_region := far_region + Vector2i(8, 0)
	var other_center := other_region * WORLD_GRID.REGION_SIZE + Vector2i.ONE * (WORLD_GRID.REGION_SIZE / 2)
	grid.activate_region_window([other_center], 1)
	assert(not grid.loaded_regions.has(far_region), "old active chunk should leave simulation set")

	# Production render activation owns a larger one-ring simulation halo.
	var production := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	production.generate_realm(646464, "bastion", true)
	production.configure_discoveries(646464, "bastion")
	var prep_index := 0
	while not production.prepare_zone_bulk_is_complete(prep_index):
		prep_index = production.bulk_materialize_prepare_zone(Callable(), 4096, prep_index)
	var focus := production.core_cell
	var view_bounds := Rect2i(focus - Vector2i(16, 16), Vector2i(32, 32))
	production.activate_render_window_for_bounds(view_bounds, 1, focus)
	var render_regions: Dictionary = production.stream_window_regions()
	var simulation_regions: Dictionary = production.simulation_window_regions()
	assert(not render_regions.is_empty(), "production render window must be populated")
	assert(simulation_regions.size() >= render_regions.size(), "simulation halo must contain the render window")
	assert(simulation_regions.size() <= WORLD_GRID.MAX_SIMULATION_REGIONS, "simulation halo must stay capped")
	var has_simulation_only := false
	for region_value: Variant in simulation_regions.keys():
		if not render_regions.has(region_value):
			has_simulation_only = true
			break
	assert(has_simulation_only, "production simulation should extend beyond visible render chunks")

	# Flow-corridor bookkeeping must work at signed coordinates beyond the legacy
	# realm rectangle and scale in regions rather than scanning every world tile.
	var infinite_from := Vector2i(-WORLD_GRID.REGION_SIZE * 20, WORLD_GRID.REALM_HEIGHT + WORLD_GRID.REGION_SIZE * 12)
	var infinite_to := infinite_from + Vector2i(WORLD_GRID.REGION_SIZE * 8, WORLD_GRID.REGION_SIZE * 3)
	var infinite_corridor: Dictionary = production.corridor_regions_between(infinite_from, infinite_to, 2)
	assert(infinite_corridor.has(production.region_for_cell(infinite_from)), "infinite flow corridor must keep signed source region")
	assert(infinite_corridor.has(production.region_for_cell(infinite_to)), "infinite flow corridor must keep destination beyond legacy realm bounds")
	assert(infinite_corridor.size() < 64, "flow corridor cost must scale by regions, not by individual cells")

	var src := FileAccess.get_file_as_string("res://scripts/phase0_run.gd")
	assert(src.find("grid.prefetch_mining_beam_regions") < 0, "mining must not trigger region generation prefetch")
	assert(src.find("var budget := 0 if mining_busy") >= 0, "mining must pause background region generation")
	assert(src.find("if player_moving and _stream_center_tick % 3 == 0") >= 0, "render window refresh must follow travel instead of mining input")
	assert(src.find("terrain_chunk_committed.erase(regions[0])") < 0, "single-cell mining must not force immediate full chunk raster")
	assert(src.find("TERRAIN_MUTATION_SECTOR_SIZE := 8") >= 0, "mining overlay must use bounded 8x8 mutation sectors")
	assert(src.find("if not grid.loaded_regions.has(spider_region)") >= 0, "off-simulation mobs must hibernate")
	assert(src.find("BACKGROUND_HOSTILE_DESPAWN_SEC := 12.0") >= 0, "incidental off-simulation hostiles need a bounded retirement policy")
	assert(src.find("func _simulation_enemy_count() -> int") >= 0, "spawn population must count simulation-active mobs rather than the entire world")
	assert(src.find("gameplay_telemetry.note_mining_commit") >= 0, "mining transaction latency must be captured for the next source handoff")
	var place_start := src.find("func _place_block_from_hotbar")
	var place_end := src.find("func ", place_start + 5)
	var place_block := src.substr(place_start, place_end - place_start)
	assert(place_block.find("_invalidate_visual_region(cell)") < 0, "block placement must rely on the terrain signal exactly once")

	var grid_src := FileAccess.get_file_as_string("res://systems/world_grid.gd")
	var sparse_set_start := grid_src.find("func set_cell")
	var signal_pos := grid_src.find("terrain_cell_changed.emit(cell)", sparse_set_start)
	var invalidate_pos := grid_src.find("invalidate_walkable_route_cache_for_cell(cell)", sparse_set_start)
	assert(signal_pos >= 0 and invalidate_pos > signal_pos, "terrain visual signal must be queued before route-cache maintenance")

	var telemetry_src := FileAccess.get_file_as_string("res://systems/gameplay_telemetry.gd")
	assert(telemetry_src.find('SUMMARY_RELATIVE_PATH := "diagnostics/LAST_SESSION.json"') >= 0, "last-session diagnostics must survive the source-only launcher handoff")
	assert(telemetry_src.find("func note_mining_commit") >= 0, "diagnostics must separate open-cell cost from the full mining transaction")

	var presentation := FileAccess.get_file_as_string("res://systems/run_components/run_world_presentation.gd")
	var opened_start := presentation.find("func _on_terrain_cell_opened")
	var opened_end := presentation.find("func ", opened_start + 5)
	var opened_block := presentation.substr(opened_start, opened_end - opened_start)
	assert(opened_block.find("_invalidate_visual_region(cell)") < 0, "terrain mutation visual invalidation must happen once via grid signal")
	print("CRAWL_BRAWL_CHUNK_SIMULATION_BV53_TEST_OK")
	quit(0)
