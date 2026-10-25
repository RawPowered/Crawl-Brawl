extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_realm_archive_test")


func _run_realm_archive_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)

	assert(run._can_open_realm_archive(), "Command Core vicinity should expose the archive menu")
	assert(run._can_commit_realm_save(), "Saving should not require a Personal Base")

	run.wave_active = true
	run.spawns_remaining = 120
	run.realm_save_cooldown = 0.0
	assert(run._can_commit_realm_save(), "Archive save should work at Command Core even during an active surge")

	run._open_realm_archive()
	assert(run.using_realm_archive and run.paused and run.realm_archive_panel.visible, "Save action should pause and show the dedicated panel")
	assert(not run.realm_archive_save_button.disabled, "Save button should be enabled when requirements are met")
	assert(run.realm_archive_title.text == "SAVE GAME", "Save flow should use a direct player-facing title")
	assert(run.realm_archive_save_button.text.begins_with("SLOT 1"), "Checkpoint actions should use compact slot labels")

	var generation_before: int = run.checkpoint_generation
	run._try_commit_realm_save_at_archive()
	assert(run.checkpoint_exists and run.checkpoint_generation == generation_before + 1, "Archive save should commit checkpoint slot 1")
	assert(run.realm_save_cooldown > 0.0, "Archive save should start the archive cooldown")

	run._close_realm_archive()
	assert(not run.using_realm_archive and not run.paused, "Closing archive should resume the expedition")

	run._open_core_base()
	run._set_core_menu_page("base")
	run._refresh_core_base_panel()
	for slot_index in range(run.core_service_buttons.size()):
		var button: Button = run.core_service_buttons[slot_index]
		if not button.visible:
			continue
		assert(not button.text.contains("[SAVE]"), "BASE tab should no longer expose save as a shop row")

	print("CRAWL_BRAWL_REALM_ARCHIVE_TEST_OK")
	quit(0)
