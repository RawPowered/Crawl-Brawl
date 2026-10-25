extends SceneTree

const REALM_SAVE := preload("res://systems/realm_save.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var original_active := REALM_SAVE.active_realm_id()
	var test_id := "realm_save_contract_test"
	var root := REALM_SAVE.save_root()
	assert(bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false)), "The Beta build should use a branded OS user-data directory")
	assert(str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")) == "Crawl Brawl", "The custom user-data directory name must remain stable for saves and cloud sync")
	assert(root == ProjectSettings.globalize_path("user://saves").trim_suffix("/").trim_suffix("\\"), "Realm saves must use the writable user-data directory")
	assert(root.simplify_path() != REALM_SAVE.legacy_save_root().simplify_path(), "Portable realm saves must be separate from the installation directory")
	var realm_dir := root.path_join(test_id)
	var primary := realm_dir.path_join(REALM_SAVE.SAVE_FILE)
	var backup := realm_dir.path_join(REALM_SAVE.BACKUP_FILE)
	var pointer := root.path_join(REALM_SAVE.ACTIVE_REALM_FILE)
	_cleanup(primary, backup, realm_dir)

	var first := {"version": REALM_SAVE.SAVE_SCHEMA, "realm_id": test_id, "run_seed": 123, "wave": 7, "checkpoint_exists": true, "realm_ended": false}
	var second: Dictionary = first.duplicate(true)
	second["wave"] = 8
	assert(REALM_SAVE.write_realm(test_id, first), "Version 10 saves must pass the storage contract")
	assert(REALM_SAVE.write_realm(test_id, second), "A second save must rotate the verified primary into backup")
	assert(int(REALM_SAVE.load_active_save().get("wave", -1)) == 8, "The active pointer must load the newest verified save")

	var corrupt := FileAccess.open(primary, FileAccess.WRITE)
	assert(corrupt != null, "The test primary should be writable")
	corrupt.store_string("corrupt")
	corrupt = null
	assert(int(REALM_SAVE.load_active_save().get("wave", -1)) == 7, "A corrupt primary must recover from the previous verified backup")

	assert(REALM_SAVE.delete_realm(test_id), "delete_realm should remove the saved realm directory")
	assert(not DirAccess.dir_exists_absolute(realm_dir), "The realm directory should be removed after deletion")
	assert(not FileAccess.file_exists(primary) and not FileAccess.file_exists(backup), "Primary and backup files should be removed with the realm")
	assert(REALM_SAVE.active_realm_id() != test_id, "Deleting the active realm should clear or repoint the active pointer")

	_cleanup(primary, backup, realm_dir)
	if not original_active.is_empty():
		assert(REALM_SAVE.set_active_realm(original_active), "The previous active realm pointer must be restored")
	elif FileAccess.file_exists(pointer):
		DirAccess.remove_absolute(pointer)
	print("CRAWL_BRAWL_REALM_SAVE_ROUNDTRIP_TEST_OK")
	quit(0)


func _cleanup(primary: String, backup: String, realm_dir: String) -> void:
	for path: String in [primary, backup, realm_dir.path_join(REALM_SAVE.RECOVERY_FILE), primary + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	if DirAccess.dir_exists_absolute(realm_dir):
		DirAccess.remove_absolute(realm_dir)
