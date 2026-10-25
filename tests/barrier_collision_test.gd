extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_barrier_collision_test")


func _run_barrier_collision_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()

	run.selected_build = RUN_SCRIPT.BUILD_BARRICADE
	run.build_orientation = false
	var barrier_cell := Vector2i(-1, -1)
	for y in range(run.grid.height):
		for x in range(run.grid.width):
			var candidate := Vector2i(x, y)
			run.player_position = run.grid.cell_to_world(candidate + Vector2i(0, 2))
			if run._can_place_structure(candidate):
				barrier_cell = candidate
				break
		if barrier_cell.x >= 0:
			break
	assert(barrier_cell.x >= 0, "The test realm should expose at least one valid barricade cell")
	run._place_structure(barrier_cell)
	var barrier := run.structures.back()
	assert(run._structure_blocks_enemy(barrier), "Barriers should block enemy occupancy")

	run._spawn_spider(false)
	var spider: RUN_SCRIPT.Spider = run.enemies.back()
	spider.position = run.grid.cell_to_world(barrier_cell + Vector2i(-1, 0))
	run._move_spider(spider, Vector2.RIGHT, 1.0, 0.25, 1.0)
	assert(run.grid.world_to_cell(spider.position) != barrier_cell, "Spiders should stop at deployed barriers instead of walking through them")

	var wall_cell := Vector2i(-1, -1)
	var floor_offset := Vector2i.ZERO
	for y in range(1, run.grid.height - 1):
		for x in range(1, run.grid.width - 1):
			var candidate := Vector2i(x, y)
			if not run.grid.can_mine(candidate):
				continue
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if run.grid.is_walkable(candidate + direction):
					wall_cell = candidate
					floor_offset = direction
					break
			if wall_cell.x >= 0:
				break
		if wall_cell.x >= 0:
			break
	assert(wall_cell.x >= 0, "The test realm should expose a rock wall beside walkable floor")
	var floor_cell := wall_cell + floor_offset
	spider.position = run.grid.cell_to_world(floor_cell)
	var knock_direction := Vector2(-floor_offset.x, -floor_offset.y)
	run._apply_enemy_knockback(spider, knock_direction, 34.0)
	assert(run.grid.world_to_cell(spider.position) != wall_cell - floor_offset, "Knockback should not shove spiders through a single rock wall tile")

	var open_door := RUN_SCRIPT.Structure.new()
	open_door.kind = RUN_SCRIPT.BUILD_HEAVY_DOORWAY
	open_door.cell = barrier_cell + Vector2i(0, 2)
	open_door.size = Vector2i(2, 1)
	open_door.is_open = true
	run.structures.append(open_door)
	assert(not run._structure_blocks_enemy(open_door), "Open doorways should remain passable")

	print("CRAWL_BRAWL_BARRIER_COLLISION_TEST_OK")
	quit(0)
