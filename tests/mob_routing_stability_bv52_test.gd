extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID_SCRIPT := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_mob_routing_stability_bv52_test")


func _make_open_patch(run: RUN_SCRIPT, center: Vector2i, radius: int = 4) -> void:
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var cell := Vector2i(x, y)
			if run.grid.in_bounds(cell):
				run.grid.set_cell(cell, WORLD_GRID_SCRIPT.FLOOR)


func _run_mob_routing_stability_bv52_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	await process_frame

	var center := run.grid.world_to_cell(run.player_position)
	_make_open_patch(run, center)

	# BV5.2: the lightweight viability probe must be genuinely read-only. The
	# pressure/spawn accounting path is not allowed to construct fallback routes.
	var spider := RUN_SCRIPT.Spider.new()
	spider.position = run.grid.cell_to_world(center)
	spider.radius = 5.0
	spider.fallback_route_from = Vector2i(101, 102)
	spider.fallback_route_next = Vector2i(103, 104)
	spider.fallback_route_previous = Vector2i(105, 106)
	spider.fallback_route_target = Vector2i(107, 108)
	var before_from := spider.fallback_route_from
	var before_next := spider.fallback_route_next
	var before_previous := spider.fallback_route_previous
	var before_target := spider.fallback_route_target
	assert(
		run._local_route_viable_read_only(spider, center, center + Vector2i.RIGHT, spider.radius),
		"Open adjacent terrain should be recognized as a lightweight viable route"
	)
	assert(spider.fallback_route_from == before_from, "Read-only route viability must not rewrite fallback_route_from")
	assert(spider.fallback_route_next == before_next, "Read-only route viability must not rewrite fallback_route_next")
	assert(spider.fallback_route_previous == before_previous, "Read-only route viability must not rewrite fallback_route_previous")
	assert(spider.fallback_route_target == before_target, "Read-only route viability must not rewrite fallback_route_target")

	# BV5.2: relevant terrain mutation preserves the old correctness contract --
	# all route-cache entries are stale -- but clears the dictionary in one operation.
	var route_region := run.grid.region_for_cell(center)
	run.grid._spawn_lane_corridors.clear()
	var route_corridor: Dictionary = {}
	route_corridor[route_region] = true
	run.grid._spawn_lane_corridors[center] = route_corridor
	run.grid._walkable_route_cache.clear()
	for index in range(512):
		run.grid._walkable_route_cache[index] = true
	run.grid.invalidate_walkable_route_cache_for_cell(center)
	assert(run.grid._walkable_route_cache.is_empty(), "Relevant terrain mutation must invalidate the cached walkable routes")

	# BV5.2: consecutive stuck recovery attempts retain a lateral side briefly.
	spider.position = run.grid.cell_to_world(center)
	spider.recovery_side_sign = 1.0
	spider.recovery_side_lock_until_tick = run._combat_frame_tick + 100
	var recovery_start := spider.position
	var mission := run.grid.cell_to_world(center + Vector2i(4, 0))
	run._recover_stuck_spider_to(spider, Vector2.RIGHT, mission)
	assert(spider.position.y > recovery_start.y, "Recovery side lock should keep the committed lateral escape instead of flipping sides")
	assert(spider.recovery_side_sign > 0.0, "Recovery should retain its committed side sign")

	# BV5.2: a terrain-open event reaches the mutation renderer immediately and
	# marks lighting once for the actual mutation, independent of mining input rate.
	run._visual_dirty_mask = 0
	run.terrain_mutation_patch_cells.clear()
	run._on_terrain_cell_opened(center)
	assert(run.terrain_mutation_patch_cells.has(center), "Opened terrain must enter the immediate mutation-patch renderer")
	assert((run._visual_dirty_mask & RUN_SCRIPT.VIS_DIRTY_LIGHTING) != 0, "Terrain mutation must dirty lighting exactly from the mutation event")

	print("CRAWL_BRAWL_MOB_ROUTING_STABILITY_BV52_TEST_OK")
	quit(0)
