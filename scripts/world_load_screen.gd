class_name WorldLoadScreen
extends Control

signal finished(handoff: Dictionary)
signal load_failed(message: String)

const WORLD_LOAD := preload("res://systems/world_load.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const SIDEBAR_FRAME_PATH := "res://assets/art/ui/menu_sidebar_frame.png"
const TEXTURE_LOADER := preload("res://systems/texture_loader.gd")

const BASE_COLOR := Color("02040d")
const CYAN := Color("a7eefa")
const CYAN_BRIGHT := Color("55dff5")
const VIOLET := Color("a35cf0")
const TAGLINE_COLOR := Color("d9c2ff")
const FOOTER_COLOR := Color("8ec4cf")
const BETA_TAGLINE := "OFFLINE PRIVATE EXCLUSIVE BETA"
const FADE_OUT := 0.55
const SKIP_HOLD := 1.5
const SKIP_GRACE_NEW := 2.0

var loader: WORLD_LOAD
var mode := "new"
var run_seed := 0
var difficulty_id := ""
var save_payload: Dictionary = {}
var progress: Dictionary = {}
var fade_started := -1.0
var skip_hold := 0.0
var skip_lore := false
var comms_alpha := 1.0
var comms_previous := ""
var embers: PackedFloat32Array = PackedFloat32Array()
var sidebar_texture: Texture2D


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sidebar_texture = TEXTURE_LOADER.load_png(SIDEBAR_FRAME_PATH)
	_seed_embers()
	loader = WORLD_LOAD.new()
	if mode == "resume" and save_payload.is_empty():
		save_payload = REALM_SAVE.load_active_save()
	loader.begin(mode, run_seed, difficulty_id, save_payload)
	if not loader.save_valid and mode == "resume":
		load_failed.emit(str(loader.save_error))
		return
	set_process(true)


func configure(new_mode: String, seed_value: int, requested_difficulty: String, payload: Dictionary = {}) -> void:
	mode = new_mode
	run_seed = seed_value
	difficulty_id = requested_difficulty
	save_payload = payload


func _seed_embers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed if run_seed != 0 else 0x6A71
	embers.resize(24 * 5)
	for index in range(24):
		var base := index * 5
		embers[base] = rng.randf()
		embers[base + 1] = rng.randf()
		embers[base + 2] = rng.randf_range(0.012, 0.04)
		embers[base + 3] = rng.randf_range(0.5, 1.4)
		embers[base + 4] = rng.randf_range(0.0, TAU)


func _process(delta: float) -> void:
	if loader == null:
		return
	if fade_started >= 0.0:
		if fade_started + FADE_OUT <= _elapsed():
			finished.emit(loader.build_handoff())
			set_process(false)
			return
		queue_redraw()
		return
	skip_lore = _update_skip_hold(delta)
	progress = loader.step(delta, skip_lore)
	if str(progress.get("phase", "")) == "error":
		load_failed.emit(str(progress.get("error", "LOAD FAILED")))
		set_process(false)
		return
	var primary := str(progress.get("primary_text", ""))
	if primary != comms_previous and not primary.is_empty():
		comms_previous = primary
		comms_alpha = 0.0
	comms_alpha = minf(1.0, comms_alpha + delta / 0.33)
	if loader.is_complete():
		fade_started = _elapsed()
	queue_redraw()


func _elapsed() -> float:
	return Time.get_ticks_msec() / 1000.0


func _update_skip_hold(delta: float) -> bool:
	var skip_allowed := mode == "resume" or _elapsed() >= SKIP_GRACE_NEW
	if not skip_allowed:
		return false
	var held := (
		Input.is_action_pressed("move_left")
		or Input.is_action_pressed("move_right")
		or Input.is_action_pressed("move_up")
		or Input.is_action_pressed("move_down")
		or Input.is_action_pressed("fire")
		or Input.is_action_pressed("mine")
		or Input.is_action_pressed("pause_game")
		or Input.is_action_pressed("interact")
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	)
	if held:
		skip_hold += delta
	else:
		skip_hold = 0.0
	return skip_hold >= SKIP_HOLD


func _unhandled_input(event: InputEvent) -> void:
	if fade_started >= 0.0:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		accept_event()


func _draw() -> void:
	var view := Rect2(Vector2.ZERO, size)
	draw_rect(view, BASE_COLOR, true)
	_draw_starfield()
	_draw_embers()
	if sidebar_texture != null:
		var frame := Rect2(size.x * 0.5 - 170.0, 42.0, 340.0, 360.0)
		draw_texture_rect(sidebar_texture, frame, false, Color(1.0, 1.0, 1.0, 0.92))
	_draw_header()
	_draw_comms()
	_draw_progress()
	_draw_lore_tip()
	_draw_footer()
	_draw_scanlines(view)
	if fade_started >= 0.0:
		var fade := clampf((_elapsed() - fade_started) / FADE_OUT, 0.0, 1.0)
		draw_rect(view, Color(BASE_COLOR, fade), true)


func _draw_header() -> void:
	var font := get_theme_default_font()
	if font == null or loader == null or loader.grid == null:
		return
	var center_x := size.x * 0.5
	var title := str(progress.get("realm_title", loader.grid.realm_title))
	draw_string(font, Vector2(center_x - font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22).x * 0.5, 92.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, CYAN_BRIGHT)
	var traits: Array = progress.get("realm_traits", loader.grid.realm_traits)
	var traits_line := " // ".join(traits) if not traits.is_empty() else ""
	if not traits_line.is_empty():
		var traits_width := font.get_string_size(traits_line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10).x
		draw_string(font, Vector2(center_x - traits_width * 0.5, 118.0), traits_line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, TAGLINE_COLOR)
	var seed_line := "SEED %08X // GEN v%d" % [int(progress.get("run_seed", run_seed)), int(progress.get("generator_version", 2))]
	var seed_width := font.get_string_size(seed_line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9).x
	draw_string(font, Vector2(center_x - seed_width * 0.5, 136.0), seed_line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, FOOTER_COLOR)


func _draw_comms() -> void:
	var font := get_theme_default_font()
	if font == null:
		return
	var line := str(progress.get("primary_text", ""))
	if line.is_empty():
		return
	var width := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12).x
	var color := Color(CYAN, comms_alpha)
	draw_string(font, Vector2(size.x * 0.5 - width * 0.5, 188.0), line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, color)


func _draw_progress() -> void:
	var bar := Rect2(size.x * 0.5 - 180.0, 214.0, 360.0, 10.0)
	draw_rect(bar, Color(0.05, 0.12, 0.16, 0.9), true)
	var done := float(progress.get("done", 0))
	var total := maxf(1.0, float(progress.get("total", 1)))
	var ratio := clampf(done / total, 0.0, 1.0)
	var fill := Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y))
	draw_rect(fill, Color(VIOLET, 0.85), true)
	draw_rect(bar, Color(CYAN, 0.35), false, 1.0)
	var font := get_theme_default_font()
	if font == null:
		return
	var phase_id := str(progress.get("phase", "survey")).to_upper()
	var label := "%s // %d / %d" % [phase_id, int(done), int(total)]
	var label_width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9).x
	draw_string(font, Vector2(size.x * 0.5 - label_width * 0.5, 236.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, FOOTER_COLOR)


func _draw_lore_tip() -> void:
	if skip_lore:
		return
	var font := get_theme_default_font()
	if font == null:
		return
	var tip := str(progress.get("tip_text", ""))
	if tip.is_empty():
		return
	var wrap_width := 420.0
	var tip_width := font.get_string_size(tip, HORIZONTAL_ALIGNMENT_CENTER, wrap_width, 10).x
	draw_string(font, Vector2(size.x * 0.5 - tip_width * 0.5, 286.0), tip, HORIZONTAL_ALIGNMENT_CENTER, wrap_width, 10, Color(CYAN, 0.82))


func _draw_footer() -> void:
	var font := get_theme_default_font()
	if font == null:
		return
	var expect := "ONE VOLUNTEER // ONE CHANCE // EARTH IS WAITING"
	var expect_width := font.get_string_size(expect, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9).x
	draw_string(font, Vector2(size.x * 0.5 - expect_width * 0.5, 332.0), expect, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, FOOTER_COLOR)
	var beta_width := font.get_string_size(BETA_TAGLINE, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8).x
	draw_string(font, Vector2(size.x * 0.5 - beta_width * 0.5, 352.0), BETA_TAGLINE, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color(TAGLINE_COLOR, 0.75))
	if mode == "resume" or _elapsed() >= SKIP_GRACE_NEW:
		var hint := "HOLD ANY KEY // SKIP LORE TIPS"
		var hint_width := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8).x
		draw_string(font, Vector2(size.x * 0.5 - hint_width * 0.5, 372.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color(TAGLINE_COLOR, 0.55))


func _draw_starfield() -> void:
	for star_index in range(48):
		var px := posmod(star_index * 83 + 29, int(size.x))
		var py := posmod(star_index * 47 + star_index * star_index, int(maxi(1.0, size.y - 40))) + 20.0
		var star_size := 2.0 if star_index % 11 == 0 else 1.0
		draw_rect(Rect2(px, py, star_size, star_size), Color("bceeff") if star_index % 5 else Color("d8c7ff"))


func _draw_embers() -> void:
	var tick := _elapsed()
	for index in range(embers.size() / 5):
		var base := index * 5
		var px: float = fposmod(embers[base] + tick * embers[base + 2], 1.0) * size.x
		var py: float = fposmod(embers[base + 1] - tick * embers[base + 2] * 0.7, 1.0) * size.y
		var radius := embers[base + 3]
		var alpha := 0.12 + 0.08 * sin(tick * 3.0 + embers[base + 4])
		draw_circle(Vector2(px, py), radius, Color(VIOLET, alpha))


func _draw_scanlines(view: Rect2) -> void:
	var step := 3.0
	var y := view.position.y
	while y < view.end.y:
		draw_line(Vector2(view.position.x, y), Vector2(view.end.x, y), Color(0.0, 0.0, 0.0, 0.08), 1.0)
		y += step
