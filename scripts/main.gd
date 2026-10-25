extends Node

const MENU_SCREEN := preload("res://scripts/menu_screen.gd")
const SPLASH_SCREEN := preload("res://scripts/splash_screen.gd")
const RUN_SCENE := preload("res://scenes/phase0_run.tscn")
const WORLD_LOAD_SCREEN := preload("res://scripts/world_load_screen.gd")
const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const DISPLAY_SETTINGS := preload("res://systems/display_settings.gd")

const WORLD_LOAD := preload("res://systems/world_load.gd")

var current_screen: Node
var current_difficulty_id := DIFFICULTY_PROFILE.DEFAULT_ID
var pending_restart_seed := 0
var skip_world_load_screen := false


func _ready() -> void:
	DISPLAY_SETTINGS.load_settings()
	DISPLAY_SETTINGS.apply()
	skip_world_load_screen = DisplayServer.get_name() == "headless"
	_configure_input_map()
	show_splash()


## Boots the studio ident. Any screen change cancels it, so tests and tools can
## call show_menu() directly to skip straight to the menu.
func show_splash() -> void:
	_clear_current_screen()
	var splash := SPLASH_SCREEN.new()
	current_screen = splash
	add_child(splash)
	splash.finished.connect(_on_splash_finished.bind(splash))


func _on_splash_finished(splash: Node) -> void:
	if current_screen != splash:
		return
	show_menu()


func show_menu() -> void:
	_clear_current_screen()
	var menu := MENU_SCREEN.new()
	menu.set_selected_difficulty(current_difficulty_id)
	current_screen = menu
	add_child(menu)
	menu.start_requested.connect(start_run)
	menu.resume_requested.connect(resume_run)


func start_run(requested_difficulty_id: String = "") -> void:
	if not requested_difficulty_id.is_empty():
		current_difficulty_id = DIFFICULTY_PROFILE.normalize_id(requested_difficulty_id)
	var seed := pending_restart_seed if pending_restart_seed > 0 else _generate_unique_realm_seed()
	var mode := "restart" if pending_restart_seed > 0 else "new"
	pending_restart_seed = 0
	if skip_world_load_screen:
		_begin_world_load_immediate(mode, seed, current_difficulty_id)
		return
	_begin_world_load(mode, seed, current_difficulty_id)


func resume_run(requested_realm_id: String = "") -> void:
	if not requested_realm_id.is_empty() and not REALM_SAVE.set_active_realm(requested_realm_id):
		show_menu()
		return
	var payload := REALM_SAVE.load_active_save()
	if skip_world_load_screen:
		_begin_world_load_immediate("resume", 0, current_difficulty_id, payload)
		return
	_begin_world_load("resume", 0, current_difficulty_id, payload)


func _begin_world_load_immediate(mode: String, seed: int, difficulty_id: String, save_payload: Dictionary = {}) -> void:
	var loader := WORLD_LOAD.new()
	var grid := WORLD_LOAD.create_grid()
	loader.grid = grid
	loader.begin(mode, seed, difficulty_id, save_payload)
	if not loader.save_valid:
		push_warning(loader.save_error)
		show_menu()
		return
	while not loader.is_complete():
		loader.step(0.25)
	_spawn_run_from_handoff(loader.build_handoff())


func _begin_world_load(mode: String, seed: int, difficulty_id: String, save_payload: Dictionary = {}) -> void:
	_clear_current_screen()
	var load_screen := WORLD_LOAD_SCREEN.new()
	load_screen.configure(mode, seed, difficulty_id, save_payload)
	current_screen = load_screen
	add_child(load_screen)
	load_screen.finished.connect(_on_world_load_finished.bind(load_screen))
	load_screen.load_failed.connect(_on_world_load_failed.bind(load_screen))


func _on_world_load_failed(message: String, load_screen: Node) -> void:
	if current_screen != load_screen:
		return
	push_warning(message)
	show_menu()


func _on_world_load_finished(handoff: Dictionary, load_screen: Node) -> void:
	if current_screen != load_screen:
		return
	_spawn_run_from_handoff(handoff)


func _spawn_run_from_handoff(handoff: Dictionary) -> void:
	_clear_current_screen()
	var run := RUN_SCENE.instantiate()
	run.set_difficulty(str(handoff.get("difficulty_id", current_difficulty_id)))
	if str(handoff.get("mode", "new")) == "resume":
		run.request_saved_run()
	run.accept_load_handoff(handoff)
	current_screen = run
	add_child(run)
	if str(handoff.get("mode", "new")) == "resume" and not run.saved_run_loaded:
		show_menu()
		return
	current_difficulty_id = run.difficulty_id
	run.exit_to_menu.connect(show_menu)
	run.restart_requested.connect(_on_restart_requested)


func _on_restart_requested(requested_difficulty_id: String = "") -> void:
	pending_restart_seed = 0
	if is_instance_valid(current_screen) and current_screen.has_method("get_run_seed"):
		pending_restart_seed = int(current_screen.call("get_run_seed"))
	start_run(requested_difficulty_id)


func _clear_current_screen() -> void:
	if is_instance_valid(current_screen):
		current_screen.queue_free()
		current_screen = null


func _generate_unique_realm_seed() -> int:
	var used_seeds: Dictionary = {}
	for summary: Dictionary in REALM_SAVE.list_realms():
		used_seeds[int(summary.get("realm_seed", 0))] = true
	var candidate := maxi(1, (int(Time.get_ticks_usec()) ^ int(Time.get_unix_time_from_system()) ^ randi()) & 0x7fffffff)
	while used_seeds.has(candidate):
		candidate = 1 if candidate >= 0x7ffffffe else candidate + 1
	return candidate


func _configure_input_map() -> void:
	_add_action("move_left")
	_add_key("move_left", KEY_A)
	_add_key("move_left", KEY_LEFT)
	_add_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)

	_add_action("move_right")
	_add_key("move_right", KEY_D)
	_add_key("move_right", KEY_RIGHT)
	_add_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)

	_add_action("move_up")
	_add_key("move_up", KEY_W)
	_add_key("move_up", KEY_UP)
	_add_joy_axis("move_up", JOY_AXIS_LEFT_Y, -1.0)

	_add_action("move_down")
	_add_key("move_down", KEY_S)
	_add_key("move_down", KEY_DOWN)
	_add_joy_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)

	_add_action("aim_left")
	_add_joy_axis("aim_left", JOY_AXIS_RIGHT_X, -1.0)
	_add_action("aim_right")
	_add_joy_axis("aim_right", JOY_AXIS_RIGHT_X, 1.0)
	_add_action("aim_up")
	_add_joy_axis("aim_up", JOY_AXIS_RIGHT_Y, -1.0)
	_add_action("aim_down")
	_add_joy_axis("aim_down", JOY_AXIS_RIGHT_Y, 1.0)

	_add_action("fire")
	_add_mouse_button("fire", MOUSE_BUTTON_LEFT)
	_add_joy_axis("fire", JOY_AXIS_TRIGGER_RIGHT, 1.0)

	_add_action("mine")
	_add_mouse_button("mine", MOUSE_BUTTON_RIGHT)
	_add_joy_axis("mine", JOY_AXIS_TRIGGER_LEFT, 1.0)

	_add_action("reload")
	_add_key("reload", KEY_R)
	_add_joy_button("reload", JOY_BUTTON_X)

	_add_action("dash")
	_add_key("dash", KEY_SPACE)
	_add_joy_button("dash", JOY_BUTTON_A)

	_add_action("sprint")
	_add_key("sprint", KEY_SHIFT)
	_add_joy_button("sprint", JOY_BUTTON_LEFT_STICK)

	_add_action("inventory")
	_add_key("inventory", KEY_I)
	_add_joy_button("inventory", JOY_BUTTON_BACK)

	_add_action("weapon_1")
	_add_action("weapon_2")
	_add_action("weapon_3")
	_add_action("weapon_4")
	_add_action("weapon_5")

	_add_action("hotbar_1")
	_add_key("hotbar_1", KEY_1)
	_add_action("hotbar_2")
	_add_key("hotbar_2", KEY_2)
	_add_action("hotbar_3")
	_add_key("hotbar_3", KEY_3)
	_add_action("hotbar_4")
	_add_key("hotbar_4", KEY_4)
	_add_action("hotbar_5")
	_add_key("hotbar_5", KEY_5)
	_add_action("hotbar_6")
	_add_key("hotbar_6", KEY_6)
	_add_action("hotbar_7")
	_add_key("hotbar_7", KEY_7)
	_add_action("hotbar_8")
	_add_key("hotbar_8", KEY_8)
	_add_action("hotbar_9")
	_add_key("hotbar_9", KEY_9)

	_add_action("weapon_prev")
	_add_mouse_button("weapon_prev", MOUSE_BUTTON_WHEEL_UP)
	_add_joy_button("weapon_prev", JOY_BUTTON_DPAD_LEFT)
	_add_action("weapon_next")
	_add_mouse_button("weapon_next", MOUSE_BUTTON_WHEEL_DOWN)
	_add_joy_button("weapon_next", JOY_BUTTON_DPAD_RIGHT)

	_add_action("build_toggle")
	_add_key("build_toggle", KEY_TAB)
	_add_joy_button("build_toggle", JOY_BUTTON_Y)

	_add_action("build_prev")
	_add_key("build_prev", KEY_Q)
	_add_joy_button("build_prev", JOY_BUTTON_LEFT_SHOULDER)

	_add_action("build_next")
	_add_key("build_next", KEY_E)
	_add_joy_button("build_next", JOY_BUTTON_RIGHT_SHOULDER)

	_add_action("pause_game")
	_add_key("pause_game", KEY_ESCAPE)
	_add_joy_button("pause_game", JOY_BUTTON_START)

	_add_action("interact")
	_add_key("interact", KEY_F)
	_add_joy_button("interact", JOY_BUTTON_B)


func _add_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)


func _add_key(action: StringName, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)


func _add_mouse_button(action: StringName, button: MouseButton) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)


func _add_joy_button(action: StringName, button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)


func _add_joy_axis(action: StringName, axis: JoyAxis, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action, event)
