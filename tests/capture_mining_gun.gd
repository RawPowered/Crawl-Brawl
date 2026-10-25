extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_capture_mining_gun")


func _capture_mining_gun() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	var setup := _find_wall_setup(run)
	assert(not setup.is_empty(), "Capture realm should expose a floor beside mineable rock")
	var floor_cell: Vector2i = setup["floor"]
	var wall_cell: Vector2i = setup["wall"]
	run.player_position = run.grid.cell_to_world(floor_cell)
	run.player_camera.position = run.player_position
	run.aim_direction = (run.grid.cell_to_world(wall_cell) - run.player_position).normalized()
	run.mining_speed_tier = 2
	run.mining_emitter_tier = 2
	run.mine_target = wall_cell
	run.mine_progress = run._mining_cycle_duration() * 0.58
	run.mining_feedback_time = 0.09
	run.mining_beam_valid = true
	run.mining_beam_end = run.grid.cell_to_world(wall_cell) - run.aim_direction * 7.0
	Input.action_press("mine")
	run.paused = true
	run._queue_visual_redraw()
	for unused: int in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var save_error := root.get_texture().get_image().save_png("res://artifacts/mining_gun_render_check.png")
	Input.action_release("mine")
	if save_error == OK:
		print("CRAWL_BRAWL_MINING_GUN_CAPTURE_OK")
	quit(0 if save_error == OK else 1)


func _find_wall_setup(run: RUN_SCRIPT) -> Dictionary:
	for y: int in range(1, run.grid.height - 1):
		for x: int in range(1, run.grid.width - 1):
			var wall := Vector2i(x, y)
			if not run.grid.can_mine(wall):
				continue
			for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var floor := wall + offset
				if run.grid.is_walkable(floor):
					return {"floor": floor, "wall": wall}
	return {}
