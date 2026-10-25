class_name RealmSave
extends RefCounted

const SAVE_FILE := "world.cbr"
const BACKUP_FILE := "world.backup.cbr"
const RECOVERY_FILE := "recovery.cbr"
const ACTIVE_REALM_FILE := "active_realm.txt"
const SAVE_SCHEMA := 14
const MIN_SUPPORTED_SCHEMA := 3
const RECOVERY_SCHEMA := 1

# Storage revision 2 moves realm data to user:// and uses a stable game key.
# This keeps saves writable in exported builds and allows players to move them
# between install folders or machines. The legacy key remains readable only so
# existing installation-bound saves can be migrated in place.
const STORAGE_REVISION := 2
const PORTABLE_KEY_SALT := "CRAWL_BRAWL_REALM_PORTABLE_V1"
const LEGACY_KEY_SALT := "CRAWL_BRAWL_REALM_V3"

static var _storage_ready := false


static func save_root() -> String:
	return ProjectSettings.globalize_path("user://saves").trim_suffix("/").trim_suffix("\\")


static func legacy_save_root() -> String:
	# Keep this byte-for-byte compatible with the pre-beta root calculation; the
	# exact path was part of the old encryption password.
	var install_root := ProjectSettings.globalize_path("res://").trim_suffix("/")
	if not OS.has_feature("editor"):
		install_root = OS.get_executable_path().get_base_dir()
	return install_root.path_join("saves")


static func ensure_storage_ready() -> bool:
	if _storage_ready:
		return true
	if DirAccess.make_dir_recursive_absolute(save_root()) != OK:
		return false
	# Mark ready before migration so the migration helpers can use normal writes
	# without recursively re-entering this function.
	_storage_ready = true
	_migrate_legacy_install_saves()
	_repair_active_pointer()
	return true


static func realm_id_for_seed(seed: int) -> String:
	return "realm_%08x" % (seed & 0x7fffffff)


static func active_realm_id() -> String:
	if not ensure_storage_ready():
		return ""
	return _read_active_pointer(save_root())


static func has_active_save() -> bool:
	var realm_id := active_realm_id()
	if realm_id.is_empty() or (not FileAccess.file_exists(_save_path(realm_id)) and not FileAccess.file_exists(_backup_path(realm_id))):
		return false
	var data := load_active_save()
	return not data.is_empty() and not bool(data.get("realm_ended", false))


static func set_active_realm(realm_id: String) -> bool:
	if not ensure_storage_ready():
		return false
	realm_id = _sanitize_realm_id(realm_id)
	if realm_id.is_empty() or (not FileAccess.file_exists(_save_path(realm_id)) and not FileAccess.file_exists(_backup_path(realm_id))):
		return false
	var data := _read_encrypted(_save_path(realm_id))
	if data.is_empty():
		data = _read_encrypted(_backup_path(realm_id))
	if data.is_empty() or str(data.get("realm_id", "")) != realm_id:
		return false
	return _write_active_pointer(realm_id)


static func list_realms() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not ensure_storage_ready():
		return result
	var directory := DirAccess.open(save_root())
	if directory == null:
		return result
	for realm_id: String in directory.get_directories():
		var data := _read_encrypted(_save_path(realm_id))
		if data.is_empty():
			data = _read_encrypted(_backup_path(realm_id))
		if data.is_empty() or bool(data.get("realm_ended", false)) or str(data.get("realm_id", "")) != realm_id:
			continue
		result.append({
			"realm_id": realm_id,
			"realm_title": data.get("realm_title", "UNKNOWN REALM"),
			"realm_seed": data.get("run_seed", 0),
			"wave": data.get("wave", 0), # legacy history
			"encounters_completed": data.get("encounters_completed", data.get("wave", 0)),
			"awareness_tier": int(data.get("hive_awareness", {}).get("awareness_tier", 0)) if data.get("hive_awareness", {}) is Dictionary else 0,
			"difficulty_id": data.get("difficulty_id", "bastion"),
			"credits": data.get("scrap", 0),
			"active_bases": _active_base_count(data.get("base_network", {})),
			"saved_unix": data.get("saved_unix", 0),
		})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["saved_unix"]) > int(b["saved_unix"]))
	return result


static func load_active_save() -> Dictionary:
	var realm_id := active_realm_id()
	if realm_id.is_empty():
		return {}
	var data := _read_encrypted(_save_path(realm_id))
	if data.is_empty():
		data = _read_encrypted(_backup_path(realm_id))
	if data.is_empty() or str(data.get("realm_id", "")) != realm_id:
		return {}
	return data


static func _active_base_count(network_data: Dictionary) -> int:
	var count := 0
	var saved_bases: Dictionary = network_data.get("bases", {})
	for base_value: Variant in saved_bases.values():
		var base_record: Dictionary = base_value
		if str(base_record.get("status", "")) == "active":
			count += 1
	return count


static func active_summary() -> Dictionary:
	var data := load_active_save()
	if data.is_empty():
		return {}
	return {
		"realm_id": data.get("realm_id", ""),
		"realm_title": data.get("realm_title", "UNKNOWN REALM"),
		"realm_seed": data.get("run_seed", 0),
		"wave": data.get("wave", 0), # legacy history
		"encounters_completed": data.get("encounters_completed", data.get("wave", 0)),
		"awareness_tier": int(data.get("hive_awareness", {}).get("awareness_tier", 0)) if data.get("hive_awareness", {}) is Dictionary else 0,
		"difficulty_id": data.get("difficulty_id", "bastion"),
	}


static func write_realm(realm_id: String, data: Dictionary) -> bool:
	if not ensure_storage_ready():
		return false
	realm_id = _sanitize_realm_id(realm_id)
	if realm_id.is_empty() or str(data.get("realm_id", "")) != realm_id or int(data.get("version", -1)) != SAVE_SCHEMA:
		return false
	return _write_realm_payload(realm_id, data, true)


static func write_recovery(realm_id: String, data: Dictionary) -> bool:
	if not ensure_storage_ready():
		return false
	realm_id = _sanitize_realm_id(realm_id)
	if realm_id.is_empty() or str(data.get("realm_id", "")) != realm_id or int(data.get("version", -1)) != RECOVERY_SCHEMA:
		return false
	var target_path := _recovery_path(realm_id)
	if not FileAccess.file_exists(_save_path(realm_id)):
		return false
	var temporary_path := target_path + ".tmp"
	_remove_if_present(temporary_path)
	if not _write_encrypted_file(temporary_path, data):
		return false
	var verified := _read_recovery_with_passwords(temporary_path, [_portable_password()])
	if verified.is_empty() or str(verified.get("realm_id", "")) != realm_id:
		_remove_if_present(temporary_path)
		return false
	if FileAccess.file_exists(target_path) and DirAccess.remove_absolute(target_path) != OK:
		_remove_if_present(temporary_path)
		return false
	if DirAccess.rename_absolute(temporary_path, target_path) != OK:
		_remove_if_present(temporary_path)
		return false
	return not _read_recovery(target_path).is_empty()


static func load_recovery(realm_id: String) -> Dictionary:
	if not ensure_storage_ready():
		return {}
	realm_id = _sanitize_realm_id(realm_id)
	if realm_id.is_empty():
		return {}
	var data := _read_recovery(_recovery_path(realm_id))
	if data.is_empty() or str(data.get("realm_id", "")) != realm_id:
		return {}
	return data


static func clear_recovery(realm_id: String) -> bool:
	if not ensure_storage_ready():
		return false
	var path := _recovery_path(_sanitize_realm_id(realm_id))
	return not FileAccess.file_exists(path) or DirAccess.remove_absolute(path) == OK


static func delete_realm(realm_id: String) -> bool:
	if not ensure_storage_ready():
		return false
	realm_id = _sanitize_realm_id(realm_id)
	if realm_id.is_empty():
		return false
	var realm_directory := save_root().path_join(realm_id)
	if not DirAccess.dir_exists_absolute(realm_directory) or realm_directory.get_file() != realm_id:
		return false
	if not _remove_realm_directory(realm_id):
		return false
	if _read_active_pointer(save_root()) == realm_id:
		_clear_active_pointer()
	_repair_active_pointer()
	return true


static func storage_summary() -> Dictionary:
	return {
		"revision": STORAGE_REVISION,
		"save_root": save_root(),
		"legacy_save_root": legacy_save_root(),
		"portable_encryption": true,
		"ready": ensure_storage_ready(),
	}


static func _write_realm_payload(realm_id: String, data: Dictionary, make_active: bool) -> bool:
	var schema := int(data.get("version", -1))
	if schema < MIN_SUPPORTED_SCHEMA or schema > SAVE_SCHEMA:
		return false
	var realm_directory := save_root().path_join(realm_id)
	if DirAccess.make_dir_recursive_absolute(realm_directory) != OK:
		return false
	var target_path := _save_path(realm_id)
	var temporary_path := target_path + ".tmp"
	_remove_if_present(temporary_path)
	if not _write_encrypted_file(temporary_path, data):
		return false
	var temporary_data := _read_encrypted_with_passwords(temporary_path, [_portable_password()])
	if temporary_data.is_empty() or str(temporary_data.get("realm_id", "")) != realm_id:
		_remove_if_present(temporary_path)
		return false
	if FileAccess.file_exists(target_path):
		var previous_data := _read_encrypted(target_path)
		if not previous_data.is_empty() and str(previous_data.get("realm_id", "")) == realm_id:
			var previous_bytes := FileAccess.get_file_as_bytes(target_path)
			if not _write_bytes_atomic(_backup_path(realm_id), previous_bytes):
				_remove_if_present(temporary_path)
				return false
		if DirAccess.remove_absolute(target_path) != OK:
			_remove_if_present(temporary_path)
			return false
	if DirAccess.rename_absolute(temporary_path, target_path) != OK:
		_restore_backup(realm_id, target_path)
		_remove_if_present(temporary_path)
		return false
	var verified := _read_encrypted_with_passwords(target_path, [_portable_password()])
	if verified.is_empty() or str(verified.get("realm_id", "")) != realm_id:
		_remove_if_present(target_path)
		_restore_backup(realm_id, target_path)
		return false
	return not make_active or _write_active_pointer(realm_id)


static func _write_encrypted_file(path: String, data: Dictionary) -> bool:
	var encrypted := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, _portable_password())
	if encrypted == null:
		return false
	encrypted.store_var(data)
	encrypted = null
	return FileAccess.file_exists(path)


static func _write_bytes_atomic(target_path: String, bytes: PackedByteArray) -> bool:
	var temporary_path := target_path + ".tmp"
	_remove_if_present(temporary_path)
	var output := FileAccess.open(temporary_path, FileAccess.WRITE)
	if output == null:
		return false
	output.store_buffer(bytes)
	output = null
	if FileAccess.get_file_as_bytes(temporary_path) != bytes:
		_remove_if_present(temporary_path)
		return false
	if FileAccess.file_exists(target_path) and DirAccess.remove_absolute(target_path) != OK:
		_remove_if_present(temporary_path)
		return false
	if DirAccess.rename_absolute(temporary_path, target_path) != OK:
		_remove_if_present(temporary_path)
		return false
	return FileAccess.get_file_as_bytes(target_path) == bytes


static func _restore_backup(realm_id: String, target_path: String) -> bool:
	var backup_path := _backup_path(realm_id)
	if not FileAccess.file_exists(backup_path):
		return false
	var backup_bytes := FileAccess.get_file_as_bytes(backup_path)
	var restored := FileAccess.open(target_path, FileAccess.WRITE)
	if restored == null:
		return false
	restored.store_buffer(backup_bytes)
	restored = null
	var restored_data := _read_encrypted(target_path)
	return not restored_data.is_empty() and str(restored_data.get("realm_id", "")) == realm_id


static func _write_active_pointer(realm_id: String) -> bool:
	if DirAccess.make_dir_recursive_absolute(save_root()) != OK:
		return false
	var target_path := save_root().path_join(ACTIVE_REALM_FILE)
	var temporary_path := target_path + ".tmp"
	_remove_if_present(temporary_path)
	var pointer := FileAccess.open(temporary_path, FileAccess.WRITE)
	if pointer == null:
		return false
	pointer.store_string(realm_id)
	pointer = null
	if _read_active_pointer_file(temporary_path) != realm_id:
		_remove_if_present(temporary_path)
		return false
	if FileAccess.file_exists(target_path) and DirAccess.remove_absolute(target_path) != OK:
		_remove_if_present(temporary_path)
		return false
	if DirAccess.rename_absolute(temporary_path, target_path) != OK:
		_remove_if_present(temporary_path)
		return false
	return _read_active_pointer_file(target_path) == realm_id


static func _read_active_pointer(root: String) -> String:
	return _read_active_pointer_file(root.path_join(ACTIVE_REALM_FILE))


static func _read_active_pointer_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var pointer := FileAccess.open(path, FileAccess.READ)
	if pointer == null:
		return ""
	return _sanitize_realm_id(pointer.get_as_text().strip_edges())


static func _read_encrypted(path: String) -> Dictionary:
	return _read_encrypted_with_passwords(path, _password_candidates(path))


static func _read_encrypted_with_passwords(path: String, passwords: Array[String]) -> Dictionary:
	if not _has_encrypted_header(path):
		return {}
	for password: String in passwords:
		var encrypted := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
		if encrypted == null:
			continue
		var parsed: Variant
		var first_byte := encrypted.get_8()
		encrypted.seek(0)
		if first_byte == 123: # '{' indicates legacy JSON
			parsed = JSON.parse_string(encrypted.get_as_text())
		else:
			parsed = encrypted.get_var()
		encrypted = null
		if not parsed is Dictionary:
			continue
		var data: Dictionary = parsed
		var schema := int(data.get("version", -1))
		if schema >= MIN_SUPPORTED_SCHEMA and schema <= SAVE_SCHEMA:
			return data
	return {}


static func _read_recovery(path: String) -> Dictionary:
	return _read_recovery_with_passwords(path, _password_candidates(path))


static func _read_recovery_with_passwords(path: String, passwords: Array[String]) -> Dictionary:
	if not _has_encrypted_header(path):
		return {}
	for password: String in passwords:
		var encrypted := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, password)
		if encrypted == null:
			continue
		var parsed: Variant = encrypted.get_var()
		encrypted = null
		if not parsed is Dictionary:
			continue
		var data: Dictionary = parsed
		if int(data.get("version", -1)) == RECOVERY_SCHEMA:
			return data
	return {}


static func _has_encrypted_header(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var header_file := FileAccess.open(path, FileAccess.READ)
	if header_file == null:
		return false
	var valid := header_file.get_buffer(4) == PackedByteArray([0x47, 0x44, 0x45, 0x43]) # GDEC
	header_file = null
	return valid


static func _password_candidates(path: String) -> Array[String]:
	var result: Array[String] = [_portable_password()]
	var possible_roots: Array[String] = [legacy_save_root()]
	var parent_root := path.get_base_dir().get_base_dir().simplify_path()
	if not parent_root.is_empty():
		possible_roots.append(parent_root)
	for root: String in possible_roots:
		var candidate := _legacy_password(root)
		if not result.has(candidate):
			result.append(candidate)
	return result


static func _portable_password() -> String:
	# This key intentionally excludes install path and hardware identifiers.
	# The encrypted file remains opaque to casual editing while becoming portable
	# enough for reinstall, cloud synchronization, and machine migration.
	return ("Crawl Brawl|Realm Storage|" + PORTABLE_KEY_SALT).sha256_text()


static func _legacy_password(root: String) -> String:
	return (root.trim_suffix("/").trim_suffix("\\") + "|" + OS.get_unique_id() + "|" + LEGACY_KEY_SALT).sha256_text()


static func _migrate_legacy_install_saves() -> void:
	var source_root := legacy_save_root()
	var target_root := save_root()
	if source_root.simplify_path() == target_root.simplify_path():
		return
	var source_directory := DirAccess.open(source_root)
	if source_directory == null:
		return
	var current_active := _read_active_pointer(target_root)
	var current_active_valid := not current_active.is_empty() and (FileAccess.file_exists(_save_path(current_active)) or FileAccess.file_exists(_backup_path(current_active)))
	var legacy_active := _read_active_pointer(source_root)
	var available_after_migration: Array[String] = []
	for source_name: String in source_directory.get_directories():
		var realm_id := _sanitize_realm_id(source_name)
		if realm_id.is_empty() or realm_id != source_name:
			continue
		var source_realm_root := source_root.path_join(realm_id)
		var source_primary := source_realm_root.path_join(SAVE_FILE)
		var source_backup := source_realm_root.path_join(BACKUP_FILE)
		var data := _read_encrypted(source_primary)
		if data.is_empty():
			data = _read_encrypted(source_backup)
		if data.is_empty() or str(data.get("realm_id", "")) != realm_id:
			continue
		var target_primary := _save_path(realm_id)
		var target_backup := _backup_path(realm_id)
		var target_data := _read_encrypted(target_primary)
		if target_data.is_empty() or str(target_data.get("realm_id", "")) != realm_id:
			if not _write_realm_payload(realm_id, data, false):
				continue
		available_after_migration.append(realm_id)
		# Preserve a distinct legacy backup when possible. It is re-encrypted with
		# the portable key so both generations survive machine or install changes.
		if not FileAccess.file_exists(target_backup):
			var backup_data := _read_encrypted(source_backup)
			if not backup_data.is_empty() and str(backup_data.get("realm_id", "")) == realm_id:
				_write_encrypted_file(target_backup, backup_data)
		var target_recovery := _recovery_path(realm_id)
		if not FileAccess.file_exists(target_recovery):
			var recovery_data := _read_recovery(source_realm_root.path_join(RECOVERY_FILE))
			if not recovery_data.is_empty() and str(recovery_data.get("realm_id", "")) == realm_id:
				_write_encrypted_file(target_recovery, recovery_data)
	if not current_active_valid and not legacy_active.is_empty():
		if available_after_migration.has(legacy_active) or FileAccess.file_exists(_save_path(legacy_active)) or FileAccess.file_exists(_backup_path(legacy_active)):
			_write_active_pointer(legacy_active)


static func _repair_active_pointer() -> void:
	var active_id := _read_active_pointer(save_root())
	if not active_id.is_empty():
		var active_data := _read_encrypted(_save_path(active_id))
		if active_data.is_empty():
			active_data = _read_encrypted(_backup_path(active_id))
		if not active_data.is_empty() and str(active_data.get("realm_id", "")) == active_id and not bool(active_data.get("realm_ended", false)):
			return
	var best_realm_id := ""
	var best_saved_unix := -1
	var directory := DirAccess.open(save_root())
	if directory == null:
		return
	for realm_name: String in directory.get_directories():
		var realm_id := _sanitize_realm_id(realm_name)
		if realm_id.is_empty() or realm_id != realm_name:
			continue
		var data := _read_encrypted(_save_path(realm_id))
		if data.is_empty():
			data = _read_encrypted(_backup_path(realm_id))
		if data.is_empty() or str(data.get("realm_id", "")) != realm_id or bool(data.get("realm_ended", false)):
			continue
		var saved_unix := int(data.get("saved_unix", 0))
		if best_realm_id.is_empty() or saved_unix > best_saved_unix:
			best_realm_id = realm_id
			best_saved_unix = saved_unix
	if not best_realm_id.is_empty():
		_write_active_pointer(best_realm_id)


static func _save_path(realm_id: String) -> String:
	return save_root().path_join(realm_id).path_join(SAVE_FILE)


static func _backup_path(realm_id: String) -> String:
	return save_root().path_join(realm_id).path_join(BACKUP_FILE)


static func _recovery_path(realm_id: String) -> String:
	return save_root().path_join(realm_id).path_join(RECOVERY_FILE)


static func _remove_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


static func _remove_realm_directory(realm_id: String) -> bool:
	var realm_directory := save_root().path_join(realm_id)
	var directory := DirAccess.open(realm_directory)
	if directory == null:
		return false
	directory.list_dir_begin()
	var entry := directory.get_next()
	while entry != "":
		if entry != "." and entry != "..":
			var entry_path := realm_directory.path_join(entry)
			if directory.current_is_dir():
				directory.list_dir_end()
				return false
			if DirAccess.remove_absolute(entry_path) != OK:
				directory.list_dir_end()
				return false
		entry = directory.get_next()
	directory.list_dir_end()
	return DirAccess.remove_absolute(realm_directory) == OK


static func _clear_active_pointer() -> void:
	var pointer_path := save_root().path_join(ACTIVE_REALM_FILE)
	_remove_if_present(pointer_path)
	_remove_if_present(pointer_path + ".tmp")


static func _sanitize_realm_id(value: String) -> String:
	var result := ""
	for character in value:
		if character.to_lower() in "abcdefghijklmnopqrstuvwxyz0123456789_":
			result += character.to_lower()
	return result
