extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_capture_overlay_menus_uix")


func _save_frame(path: String) -> bool:
	for unused in range(3):
		await process_frame
	var save_error := root.get_texture().get_image().save_png(path)
	if save_error != OK:
		push_error("Overlay UIX capture failed for %s: %s" % [path, error_string(save_error)])
		return false
	return true


func _capture_overlay_menus_uix() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run.player_camera.position = run.player_position
	run.current_base_id = run.base_network.COMMAND_ID
	run.scrap = 1845
	run.skill_points = 2

	run._open_core_base()
	run._set_core_menu_page("armory")
	if not await _save_frame("res://artifacts/shop_menu_uix.png"):
		quit(1)
		return

	run._close_core_base()
	run.set_paused(true)
	if not await _save_frame("res://artifacts/pause_menu_uix.png"):
		quit(1)
		return

	run.pause_save_button.pressed.emit()
	if not await _save_frame("res://artifacts/save_menu_uix.png"):
		quit(1)
		return

	print("CRAWL_BRAWL_OVERLAY_MENUS_UIX_CAPTURE_OK")
	quit(0)
