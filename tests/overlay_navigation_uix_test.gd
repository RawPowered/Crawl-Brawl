extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_run_overlay_navigation_uix_test")


func _pause_event() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = &"pause_game"
	event.pressed = true
	return event


func _run_overlay_navigation_uix_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run.current_base_id = run.base_network.COMMAND_ID

	run._open_core_base()
	assert(run.using_core_base and run.core_base_panel.visible, "Core shop should open for the navigation test")
	run._unhandled_input(_pause_event())
	assert(not run.using_core_base and not run.paused, "Escape should close the shop without opening pause or save")
	assert(not run.using_realm_archive, "Escape from the shop must not open the save screen")

	run._unhandled_input(_pause_event())
	assert(run.paused and run.pause_panel.visible, "Escape from gameplay should open pause")
	assert(not run.pause_save_button.disabled and run.pause_save_button.text == "SAVE GAME", "Pause should offer saving at an active Core")

	run.pause_save_button.pressed.emit()
	assert(run.using_realm_archive and run.realm_archive_panel.visible, "Pause Save should open checkpoint slots")
	assert(not run.pause_panel.visible and run.archive_return_to_pause, "Save should remember that it was opened from pause")

	run._unhandled_input(_pause_event())
	assert(not run.using_realm_archive and run.paused and run.pause_panel.visible, "Escape from Save should return to pause")

	run._unhandled_input(_pause_event())
	assert(not run.paused and not run.pause_panel.visible, "Escape from pause should resume gameplay")

	print("CRAWL_BRAWL_OVERLAY_NAVIGATION_UIX_TEST_OK")
	quit(0)
