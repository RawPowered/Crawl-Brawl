extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_mob_routing_stability_bv5_test")


func _find_two_cell_floor(run: RUN_SCRIPT) -> Vector2i:
	var center: Vector2i = run.grid.world_to_cell(run.player_position)
	for radius in [12, 24, 40]:
		for y in range(center.y - radius, center.y + radius + 1):
			for x in range(center.x - radius, center.x + radius):
				var cell := Vector2i(x, y)
				if run.grid.is_walkable(cell) and run.grid.is_walkable(cell + Vector2i.RIGHT):
					return cell
	return Vector2i(-1, -1)


func _run_mob_routing_stability_bv5_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	var door_cell := _find_two_cell_floor(run)
	assert(door_cell.x >= 0, "Fixture needs two adjacent walkable cells")

	# Isolate the routing fixture from authored ruins/storage that may exist in a
	# seeded realm. Base-network structures are tracked separately.
	run.structures.clear()
	run._invalidate_structure_spatial_buckets()
	run._rebuild_enemy_blocker_cache()

	var door := RUN_SCRIPT.Structure.new()
	door.kind = RUN_SCRIPT.BUILD_HEAVY_DOORWAY
	door.cell = door_cell
	door.position = run.grid.cell_to_world(door_cell)
	door.size = Vector2i(2, 1)
	door.health = 800.0
	door.max_health = 800.0
	door.is_open = false
	run.structures.append(door)
	run._invalidate_structure_spatial_buckets()
	run._mark_flow_dirty_for_structure(door)

	assert(run._cell_blocks_enemy(door_cell), "Closed doorway must enter the live enemy blocker cache immediately")
	assert(run._nearby_structure(door.position, 20.0) == run.structures.size() - 1, "Closed doorway should be a nearby attackable blocker")
	var far_door_cell_position := run.grid.cell_to_world(door_cell + Vector2i.RIGHT)
	assert(run._nearby_structure(far_door_cell_position, 10.0) == run.structures.size() - 1, "Doorway contact should use the nearest footprint cell, not only the anchor")

	run._ensure_structure_spatial_buckets()
	var cache_build_frame := run._structure_spatial_buckets_frame
	run._combat_frame_tick += 1
	run._ensure_structure_spatial_buckets()
	assert(run._structure_spatial_buckets_frame == cache_build_frame, "Static structure buckets should persist across combat frames")

	door.is_open = true
	run._mark_flow_dirty_for_structure(door)
	assert(not run._cell_blocks_enemy(door_cell), "Opening a doorway must remove its cells from the live enemy blocker cache")
	assert(run._nearby_structure(door.position, 10.0) == -1, "Open doorway should not trap mobs in an attack loop at the threshold")

	door.is_open = false
	run._mark_flow_dirty_for_structure(door)
	assert(run._cell_blocks_enemy(door_cell), "Closing a doorway must restore blocking immediately")

	print("CRAWL_BRAWL_MOB_ROUTING_STABILITY_BV5_TEST_OK")
	quit(0)
