extends SceneTree

const REALM_SAVE := preload("res://systems/realm_save.gd")
const TEST_REALM_ID := "realm_legacy_migration_test"
const LEGACY_KEY_SALT := "CRAWL_BRAWL_REALM_V3"
const PORTABLE_KEY_SALT := "CRAWL_BRAWL_REALM_PORTABLE_V1"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var user_root := ProjectSettings.globalize_path("user://saves").trim_suffix("/").trim_suffix("\\")
	var legacy_root := _legacy_root()
	assert(user_root.simplify_path() != legacy_root.simplify_path(), "Migration coverage requires separate user and legacy roots")
	var original_user_pointer := _read_text(user_root.path_join(REALM_SAVE.ACTIVE_REALM_FILE))
	var legacy_realm_root := legacy_root.path_join(TEST_REALM_ID)
	var user_realm_root := user_root.path_join(TEST_REALM_ID)
	_cleanup_realm(legacy_realm_root)
	_cleanup_realm(user_realm_root)
	assert(DirAccess.make_dir_recursive_absolute(legacy_realm_root) == OK, "The test must create a simulated installation-local realm")

	var primary := {
		"version": REALM_SAVE.SAVE_SCHEMA,
		"realm_id": TEST_REALM_ID,
		"run_seed": 919191,
		"wave": 12,
		"saved_unix": 1,
		"realm_ended": false,
	}
	var backup: Dictionary = primary.duplicate(true)
	backup["wave"] = 11
	var recovery := {
		"version": REALM_SAVE.RECOVERY_SCHEMA,
		"realm_id": TEST_REALM_ID,
		"checkpoint_generation": 3,
	}
	assert(_write_encrypted(legacy_realm_root.path_join(REALM_SAVE.SAVE_FILE), primary, _legacy_password(legacy_root)), "The simulated legacy primary must be created")
	assert(_write_encrypted(legacy_realm_root.path_join(REALM_SAVE.BACKUP_FILE), backup, _legacy_password(legacy_root)), "The simulated legacy backup must be created")
	assert(_write_encrypted(legacy_realm_root.path_join(REALM_SAVE.RECOVERY_FILE), recovery, _legacy_password(legacy_root)), "The simulated legacy recovery journal must be created")

	assert(REALM_SAVE.ensure_storage_ready(), "Realm storage should initialize and migrate legacy data")
	var migrated_primary := _read_encrypted(user_realm_root.path_join(REALM_SAVE.SAVE_FILE), _portable_password())
	var migrated_backup := _read_encrypted(user_realm_root.path_join(REALM_SAVE.BACKUP_FILE), _portable_password())
	var migrated_recovery := _read_encrypted(user_realm_root.path_join(REALM_SAVE.RECOVERY_FILE), _portable_password())
	assert(int(migrated_primary.get("wave", -1)) == 12, "The newest legacy primary should be re-encrypted into user data")
	assert(int(migrated_backup.get("wave", -1)) == 11, "The previous legacy checkpoint should remain available as the portable backup")
	assert(int(migrated_recovery.get("checkpoint_generation", -1)) == 3, "The recovery journal should migrate with the realm")
	assert(FileAccess.file_exists(legacy_realm_root.path_join(REALM_SAVE.SAVE_FILE)), "Migration must never delete the original legacy primary")
	assert(FileAccess.file_exists(legacy_realm_root.path_join(REALM_SAVE.BACKUP_FILE)), "Migration must never delete the original legacy backup")

	_cleanup_realm(legacy_realm_root)
	_cleanup_realm(user_realm_root)
	_restore_pointer(user_root, original_user_pointer)
	print("CRAWL_BRAWL_LEGACY_SAVE_MIGRATION_TEST_OK")
	quit(0)


func _legacy_root() -> String:
	var install_root := ProjectSettings.globalize_path("res://").trim_suffix("/")
	if not OS.has_feature("editor"):
		install_root = OS.get_executable_path().get_base_dir()
	return install_root.path_join("saves")


func _legacy_password(root: String) -> String:
	return (root.trim_suffix("/").trim_suffix("\\") + "|" + OS.get_unique_id() + "|" + LEGACY_KEY_SALT).sha256_text()


func _portable_password() -> String:
	return ("Crawl Brawl|Realm Storage|" + PORTABLE_KEY_SALT).sha256_text()


func _write_encrypted(path: String, data: Dictionary, password: String) -> bool:
	var file := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, password)
	if file == null:
		return false
	file.store_var(data)
	file = null
	return FileAccess.file_exists(path)


func _read_encrypted(path: String, password: String) -> Dictionary:
	var file := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
	if file == null:
		return {}
	var value: Variant = file.get_var()
	file = null
	return value if value is Dictionary else {}


func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	return "" if file == null else file.get_as_text()


func _restore_pointer(root: String, value: String) -> void:
	var path := root.path_join(REALM_SAVE.ACTIVE_REALM_FILE)
	if value.is_empty():
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(value)


func _cleanup_realm(realm_root: String) -> void:
	for file_name: String in [REALM_SAVE.SAVE_FILE, REALM_SAVE.BACKUP_FILE, REALM_SAVE.RECOVERY_FILE]:
		var path := realm_root.path_join(file_name)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
		if FileAccess.file_exists(path + ".tmp"):
			DirAccess.remove_absolute(path + ".tmp")
	if DirAccess.dir_exists_absolute(realm_root):
		DirAccess.remove_absolute(realm_root)
