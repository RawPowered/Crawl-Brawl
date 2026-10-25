extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const FLOW_FIELD := preload("res://systems/flow_field.gd")
const WAVE_DIRECTOR := preload("res://systems/wave_director.gd")


func _initialize() -> void:
	call_deferred("_capture_brood_ecology")


func _capture_brood_ecology() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()
	run.wave = 6
	run.wave_active = true
	run.spawns_remaining = 14
	run.player_position = run.grid.cell_to_world(run.grid.core_cell + Vector2i(-13, 0))
	run.player_camera.position = run.player_position
	run.grid.activate_region_window([run.grid.world_to_cell(run.player_position)], 1)
	run.active_player_region = run.grid.region_for_cell(run.grid.world_to_cell(run.player_position))

	var nest_cell := Vector2i(-1, -1)
	var player_cell: Vector2i = run.grid.world_to_cell(run.player_position)
	for radius in range(4, 15):
		for y in range(player_cell.y - radius, player_cell.y + radius + 1):
			for x in range(player_cell.x - radius, player_cell.x + radius + 1):
				var candidate := Vector2i(x, y)
				if run.grid.can_mine(candidate):
					for direction: Vector2i in FLOW_FIELD.DIRECTIONS:
						if run.grid.is_walkable(candidate + direction):
							nest_cell = candidate
							break
				if nest_cell.x >= 0:
					break
			if nest_cell.x >= 0:
				break
		if nest_cell.x >= 0:
			break
	if nest_cell.x >= 0:
		run._establish_brood_nest(nest_cell, 0.72)

	run.encounters_completed = 7
	run.current_wave_plan = WAVE_DIRECTOR.build_encounter_plan("bastion", 4, 0, 7, run.grid.spawn_cells.size())
	run.spawn_sequence = 3
	run._spawn_spider(false)
	var carrier = run.enemies.back()
	carrier.is_brood_carrier = true
	carrier.hunts_player = false
	carrier.hunts_turrets = false
	carrier.carrier_channel = 3.5
	carrier.position = run.player_position + Vector2(-92, -22)
	for enemy_index in range(7):
		run._spawn_spider(false)
		run.enemies.back().position = run.player_position + Vector2(-130 - enemy_index * 18, -30 + enemy_index % 4 * 18)
	run.paused = true
	for unused in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	var save_error := screenshot.save_png("res://artifacts/patch421_brood_ecology.png")
	if save_error != OK:
		push_error("Brood ecology capture failed: %s" % error_string(save_error))
		quit(1)
		return
	print("CRAWL_BRAWL_BROOD_ECOLOGY_CAPTURE_OK")
	quit(0)
