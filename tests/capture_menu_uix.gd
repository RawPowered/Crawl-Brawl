extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_capture_menu_uix")


func _capture_menu_uix() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.show_menu()
	for unused in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var save_error := root.get_texture().get_image().save_png("res://artifacts/menu_uix.png")
	if save_error != OK:
		push_error("Menu UIX capture failed: %s" % error_string(save_error))
		quit(1)
		return
	print("CRAWL_BRAWL_MENU_UIX_CAPTURE_OK")
	quit(0)
