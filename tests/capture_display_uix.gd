extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const DISPLAY_SETTINGS := preload("res://systems/display_settings.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")


func _initialize() -> void:
	call_deferred("_capture_display_uix")


func _capture_display_uix() -> void:
	DISPLAY_SETTINGS.load_settings()
	DISPLAY_SETTINGS.resolution_index = 0
	DISPLAY_SETTINGS.window_mode_index = 0
	DISPLAY_SETTINGS.ui_density_index = 0
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.current_base_id = run.base_network.COMMAND_ID
	run.scrap = 845
	run.material_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 8)
	run.material_economy.add_raw(MATERIAL_ECONOMY.IRON_ORE, 5)
	run.material_economy.add_raw(MATERIAL_ECONOMY.COAL, 5)
	run._open_core_base()
	run._set_core_menu_page("materials")
	for unused in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var save_error := root.get_texture().get_image().save_png("res://artifacts/patch419_display_uix.png")
	if save_error != OK:
		push_error("Display UIX capture failed: %s" % error_string(save_error))
		quit(1)
		return
	print("CRAWL_BRAWL_DISPLAY_UIX_CAPTURE_OK")
	quit(0)
