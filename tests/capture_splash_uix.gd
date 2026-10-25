extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")

## Frames the splash at its held state, past the intro fade and tagline reveal.
const CAPTURE_AT := 1.9


func _initialize() -> void:
	call_deferred("_capture_splash_uix")


func _capture_splash_uix() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	var splash = main.current_screen
	splash.set_process(false)
	splash.elapsed = CAPTURE_AT
	splash.queue_redraw()
	for unused in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var save_error := root.get_texture().get_image().save_png("res://artifacts/splash_uix.png")
	if save_error != OK:
		push_error("Splash UIX capture failed: %s" % error_string(save_error))
		quit(1)
		return
	print("CRAWL_BRAWL_SPLASH_UIX_CAPTURE_OK")
	quit(0)
