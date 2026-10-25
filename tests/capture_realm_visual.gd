extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_capture_realm_visual")


func _capture_realm_visual() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()
	run.breached = true
	run.wave = 8
	run.wave_active = true
	run.spawns_remaining = 0
	run.player_position = run.grid.cell_to_world(run.grid.core_cell + Vector2i(-11, 0))
	run.player_camera.position = run.player_position
	run.grid.activate_region_window([run.grid.world_to_cell(run.player_position)], 1)
	run.active_player_region = run.grid.region_for_cell(run.grid.world_to_cell(run.player_position))
	for enemy_index in range(8):
		run._spawn_spider(enemy_index == 0)
		run.enemies.back().position = run.grid.cell_to_world(run.grid.core_cell + Vector2i(-15 - enemy_index, -2 + enemy_index % 4))
	run.paused = true
	for unused in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	var save_error := screenshot.save_png("res://artifacts/patch418_realm_visual.png")
	if save_error != OK:
		push_error("Realm visual capture failed: %s" % error_string(save_error))
		quit(1)
		return
	print("CRAWL_BRAWL_REALM_VISUAL_CAPTURE_OK")
	quit(0)
