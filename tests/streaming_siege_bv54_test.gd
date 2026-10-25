extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const FLOW_FIELD := preload("res://systems/flow_field.gd")
const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run")


func _same_keys(left: Dictionary, right: Dictionary) -> bool:
	if left.size() != right.size():
		return false
	for key: Variant in left.keys():
		if not right.has(key):
			return false
	return true


func _run() -> void:
	# A corridor preload is preparation only; it must never take render/simulation
	# ownership away from the current camera window.
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(545454, "bastion", true)
	grid.configure_discoveries(545454, "bastion")
	var prep_index := 0
	while not grid.prepare_zone_bulk_is_complete(prep_index):
		prep_index = grid.bulk_materialize_prepare_zone(Callable(), 4096, prep_index)
	var focus := grid.core_cell
	var bounds := Rect2i(focus - Vector2i(18, 12), Vector2i(36, 24))
	grid.activate_render_window_for_bounds(bounds, 1, focus)
	var render_before: Dictionary = grid.stream_window_regions().duplicate()
	var simulation_before: Dictionary = grid.simulation_window_regions().duplicate()
	var corridor_far := focus + Vector2i(WORLD_GRID.REGION_SIZE * 4, WORLD_GRID.REGION_SIZE * 2)
	grid.activate_corridor_preload_burst([grid.spawn_cell, focus, corridor_far], 2)
	assert(_same_keys(render_before, grid.stream_window_regions()), "corridor preload must not replace the render window")
	assert(_same_keys(simulation_before, grid.simulation_window_regions()), "corridor preload must not replace the simulation window")

	# Live defenses should not erase the terrain navigation field. The field points
	# through the defense, while the blocker cache identifies that next cell as the
	# breach target for combat.
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	run.structures.clear()
	run._invalidate_structure_spatial_buckets()
	var source := run.grid.world_to_cell(run.player_position)
	var middle := source + Vector2i.RIGHT
	var target := source + Vector2i(2, 0)
	run.grid.set_cell(source, WORLD_GRID.FLOOR)
	run.grid.set_cell(middle, WORLD_GRID.FLOOR)
	run.grid.set_cell(target, WORLD_GRID.FLOOR)
	var barrier := RUN_SCRIPT.Structure.new()
	barrier.kind = RUN_SCRIPT.BUILD_STEEL_BARRIER
	barrier.cell = middle
	barrier.position = run.grid.cell_to_world(middle)
	barrier.size = Vector2i.ONE
	barrier.health = 500.0
	barrier.max_health = 500.0
	run.structures.append(barrier)
	run._rebuild_enemy_blocker_cache()
	assert(run._enemy_blocking_structure_index(middle) == 0, "blocker cache should map footprint cells directly to structure indices")
	var allowed := run.grid.expand_regions({run.grid.region_for_cell(source): true, run.grid.region_for_cell(target): true}, 1)
	var terrain_flow := FLOW_FIELD.new()
	terrain_flow.rebuild(run.grid, target, allowed)
	assert(terrain_flow.has_path(source), "terrain flow should remain valid through a player-built blocker")
	assert(terrain_flow.next_cell(source) == middle, "terrain flow should identify the blocking defense as the next siege step")

	# Dynamic structure edits update blockers immediately but should not schedule an
	# expensive terrain BFS rebuild.
	run.terrain_flow_dirty = false
	run.flow_dirty_regions.clear()
	var old_epoch := run.flow_epoch
	run._mark_flow_dirty_for_structure(barrier)
	assert(not run.terrain_flow_dirty, "structure changes must not dirty terrain-only regional flows")
	assert(run.flow_dirty_regions.is_empty(), "structure changes must not enqueue terrain-flow regions")
	assert(run.flow_epoch == old_epoch + 1, "structure changes should invalidate lightweight route viability caches")

	# Mining keeps the terrain flow dirty but defers regional BFS until the cutter
	# is released; the cell itself is already live immediately.
	run.mining_beam_valid = true
	run.terrain_flow_dirty = true
	run.terrain_flow_rebuild_cooldown = 0.01
	run._update_terrain_debounce(0.02)
	assert(run.terrain_flow_dirty, "regional flow rebuild should remain pending during mining")
	assert(run.terrain_flow_rebuild_cooldown > 0.0, "mining should re-arm a short flow defer instead of rebuilding in the mining frame")

	var telemetry_src := FileAccess.get_file_as_string("res://systems/gameplay_telemetry.gd")
	assert(telemetry_src.find("func note_flow_breach") >= 0, "telemetry should distinguish intentional siege breaches from fallback routing")
	print("CRAWL_BRAWL_STREAMING_SIEGE_BV54_TEST_OK")
	quit(0)
