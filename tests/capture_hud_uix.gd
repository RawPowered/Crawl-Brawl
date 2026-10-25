extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_capture_hud_uix")


func _capture_hud_uix() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()
	run.breached = true
	run.wave = 9
	run.wave_active = true
	run.spawns_remaining = 18
	run.score = 38450
	run.scrap = 1285
	run.player_health = 72.0
	run.sprint_energy = 44.0
	run.current_weapon = run.WEAPON_SMG
	run.unlocked_weapons[run.WEAPON_SMG] = true
	for base_id: String in run._hud_base_order():
		run.base_network.bases[base_id]["revealed"] = true
	run.base_network.bases[run.base_network.NORTH_ID]["status"] = run.base_network.STATUS_ACTIVE
	run.base_network.bases[run.base_network.NORTH_ID]["health"] = 112.0
	run.base_network.bases[run.base_network.SOUTH_ID]["status"] = run.base_network.STATUS_ACTIVATING
	run.base_network.bases[run.base_network.SOUTH_ID]["activation_remaining"] = 31.0
	run.base_network.activation_base_id = run.base_network.SOUTH_ID
	run.base_network.bases[run.base_network.WEST_ID]["status"] = run.base_network.STATUS_DISABLED
	run.player_position = run.grid.cell_to_world(run.grid.core_cell + Vector2i(-11, 0))
	run.player_camera.position = run.player_position
	run.grid.activate_region_window([run.grid.world_to_cell(run.player_position)], 1)
	run.active_player_region = run.grid.region_for_cell(run.grid.world_to_cell(run.player_position))
	run._register_sector(run.grid.world_to_cell(run.player_position), false)
	for enemy_index in range(8):
		run._spawn_spider(enemy_index == 0)
		run.enemies.back().position = run.grid.cell_to_world(run.grid.core_cell + Vector2i(-15 - enemy_index, -2 + enemy_index % 4))
	run.paused = true
	for unused in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	var save_error := screenshot.save_png("res://artifacts/patch420_hud_uix.png")
	if save_error != OK:
		push_error("HUD UIX capture failed: %s" % error_string(save_error))
		quit(1)
		return
	print("CRAWL_BRAWL_HUD_UIX_CAPTURE_OK")
	quit(0)
