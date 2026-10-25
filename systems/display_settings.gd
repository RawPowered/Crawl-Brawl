class_name DisplaySettings
extends RefCounted

const CONFIG_PATH := "user://display.cfg"
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
]
const WINDOW_MODES: Array[String] = ["WINDOWED", "BORDERLESS", "FULLSCREEN"]
const UI_DENSITIES: Array[String] = ["COMPACT", "STANDARD"]

static var resolution_index := 0
static var window_mode_index := 0
static var ui_density_index := 0
static var _loaded := false


static func load_settings() -> void:
	if _loaded:
		return
	_loaded = true
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	resolution_index = clampi(int(config.get_value("display", "resolution_index", resolution_index)), 0, RESOLUTIONS.size() - 1)
	window_mode_index = clampi(int(config.get_value("display", "window_mode_index", window_mode_index)), 0, WINDOW_MODES.size() - 1)
	ui_density_index = clampi(int(config.get_value("display", "ui_density_index", ui_density_index)), 0, UI_DENSITIES.size() - 1)


static func save_settings() -> bool:
	var config := ConfigFile.new()
	config.set_value("display", "resolution_index", resolution_index)
	config.set_value("display", "window_mode_index", window_mode_index)
	config.set_value("display", "ui_density_index", ui_density_index)
	return config.save(CONFIG_PATH) == OK


static func apply() -> void:
	load_settings()
	if DisplayServer.get_name().to_lower() == "headless":
		return
	var mode := WINDOW_MODES[window_mode_index]
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	if mode == "FULLSCREEN":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if mode == "BORDERLESS":
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		var screen_rect := DisplayServer.screen_get_usable_rect()
		DisplayServer.window_set_position(screen_rect.position)
		DisplayServer.window_set_size(screen_rect.size)
		return
	var target_size := RESOLUTIONS[resolution_index]
	var usable_rect := DisplayServer.screen_get_usable_rect()
	target_size.x = mini(target_size.x, usable_rect.size.x)
	target_size.y = mini(target_size.y, usable_rect.size.y)
	DisplayServer.window_set_size(target_size)
	DisplayServer.window_set_position(usable_rect.position + (usable_rect.size - target_size) / 2)


static func cycle_resolution(direction: int = 1) -> void:
	resolution_index = posmod(resolution_index + direction, RESOLUTIONS.size())


static func cycle_window_mode(direction: int = 1) -> void:
	window_mode_index = posmod(window_mode_index + direction, WINDOW_MODES.size())


static func cycle_ui_density(direction: int = 1) -> void:
	ui_density_index = posmod(ui_density_index + direction, UI_DENSITIES.size())


static func resolution_label() -> String:
	var resolution := RESOLUTIONS[resolution_index]
	return "%d × %d" % [resolution.x, resolution.y]


static func window_mode() -> String:
	return WINDOW_MODES[window_mode_index]


static func ui_density() -> String:
	return UI_DENSITIES[ui_density_index]


static func is_compact() -> bool:
	return ui_density() == "COMPACT"


static func overlay_scale() -> float:
	return 0.88 if is_compact() else 1.0


static func font_title() -> int:
	return 14 if is_compact() else 16


static func font_status() -> int:
	return 9 if is_compact() else 10


static func font_body() -> int:
	return font_status()


static func font_tab() -> int:
	return 8 if is_compact() else 9


static func font_service() -> int:
	return font_tab()


static func font_caption() -> int:
	return 7 if is_compact() else 8


static func font_hud_primary() -> int:
	return 13 if is_compact() else 14


static func font_hud_secondary() -> int:
	return 9 if is_compact() else 10


static func font_hud_tertiary() -> int:
	return 8 if is_compact() else 9


static func font_hud_comms() -> int:
	return font_caption()
