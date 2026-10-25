class_name SplashScreen
extends Control

## Studio ident shown once at boot. Everything is drawn procedurally so the
## effects match the run renderer's look without pulling in extra scenes.

signal finished

const TEXTURE_LOADER := preload("res://systems/texture_loader.gd")
const STUDIO_LOGO_PATH := "res://assets/branding/gatogodmode_logo.png"

const TAGLINE_TEXT := "OFFLINE PRIVATE EXCLUSIVE BETA"
const SKIP_HINT_TEXT := "PRESS ANY KEY"

const FADE_IN := 0.65
const TAGLINE_DELAY := 0.85
const TAGLINE_FADE := 0.55
const HOLD_UNTIL := 3.1
const FADE_OUT := 0.55
const SKIP_FADE := 0.22

const VIOLET := Color("a35cf0")
const VIOLET_DEEP := Color("5a1f9c")
const CYAN := Color("55dff5")
const TAGLINE_COLOR := Color("d9c2ff")

const LOGO_WIDTH_RATIO := 0.68
const EMBER_COUNT := 30
const SCANLINE_STEP := 3.0

var elapsed := 0.0
var fade_out_started := -1.0
var fade_out_duration := FADE_OUT
var studio_texture: Texture2D
var embers: PackedFloat32Array = PackedFloat32Array()
var emitted_finished := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	studio_texture = TEXTURE_LOADER.load_png(STUDIO_LOGO_PATH)
	_seed_embers()
	set_process(true)


## Each ember packs x, y, speed, radius, and a phase offset.
func _seed_embers() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 0x6A70
	embers.resize(EMBER_COUNT * 5)
	for index in range(EMBER_COUNT):
		var base := index * 5
		embers[base] = rng.randf()
		embers[base + 1] = rng.randf()
		embers[base + 2] = rng.randf_range(0.012, 0.05)
		embers[base + 3] = rng.randf_range(0.5, 1.7)
		embers[base + 4] = rng.randf_range(0.0, TAU)


func _process(delta: float) -> void:
	elapsed += delta
	if fade_out_started < 0.0 and elapsed >= HOLD_UNTIL:
		_begin_fade_out(FADE_OUT)
	if fade_out_started >= 0.0 and not emitted_finished:
		if elapsed - fade_out_started >= fade_out_duration:
			emitted_finished = true
			set_process(false)
			finished.emit()
			return
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if fade_out_started >= 0.0:
		return
	var pressed: bool = (
		(event is InputEventKey and event.pressed and not event.echo)
		or (event is InputEventMouseButton and event.pressed)
		or (event is InputEventJoypadButton and event.pressed)
	)
	if not pressed:
		return
	accept_event()
	_begin_fade_out(SKIP_FADE)


func _begin_fade_out(duration: float) -> void:
	fade_out_started = elapsed
	fade_out_duration = maxf(0.05, duration)


func _intro_ratio() -> float:
	return ease(clampf(elapsed / FADE_IN, 0.0, 1.0), 0.35)


func _outro_ratio() -> float:
	if fade_out_started < 0.0:
		return 1.0
	return 1.0 - clampf((elapsed - fade_out_started) / fade_out_duration, 0.0, 1.0)


func _master_alpha() -> float:
	return _intro_ratio() * _outro_ratio()


## Brief chromatic tear on entry, plus rare flickers while the logo holds.
func _glitch_strength() -> float:
	if elapsed < FADE_IN:
		return 1.0 - clampf(elapsed / FADE_IN, 0.0, 1.0)
	var flicker := sin(elapsed * 37.0) * sin(elapsed * 11.3)
	return 0.32 if flicker > 0.93 else 0.0


func _draw() -> void:
	var view := Rect2(Vector2.ZERO, size)
	draw_rect(view, Color.BLACK, true)

	var master := _master_alpha()
	if master <= 0.001:
		return

	var logo_rect := _logo_rect()
	_draw_bloom(logo_rect, master)
	_draw_embers(master)
	_draw_logo(logo_rect, master)
	_draw_sweep(logo_rect, master)
	_draw_tagline(logo_rect, master)
	_draw_scanlines(view, master)
	_draw_vignette(view)


func _logo_rect() -> Rect2:
	var target_width := size.x * LOGO_WIDTH_RATIO
	var aspect := 2.64
	if studio_texture != null and studio_texture.get_height() > 0:
		aspect = float(studio_texture.get_width()) / float(studio_texture.get_height())
	# Settle from a slight overshoot, then breathe while holding.
	var settle := lerpf(0.94, 1.0, _intro_ratio())
	var breathe := 1.0 + 0.006 * sin(elapsed * 2.1)
	var width := target_width * settle * breathe
	var height := width / aspect
	var center := Vector2(size.x * 0.5, size.y * 0.44)
	return Rect2(center - Vector2(width, height) * 0.5, Vector2(width, height))


func _draw_bloom(logo_rect: Rect2, master: float) -> void:
	var pulse := 0.5 + 0.5 * sin(elapsed * 1.7)
	var center := logo_rect.get_center()
	for step in range(6, 0, -1):
		var spread := logo_rect.size * (0.55 + 0.16 * step)
		var alpha := master * (0.045 + 0.02 * pulse) * (1.0 - float(step) / 7.0)
		var tint := VIOLET_DEEP
		tint.a = alpha
		draw_rect(Rect2(center - spread * 0.5, spread), tint, true)


func _draw_logo(logo_rect: Rect2, master: float) -> void:
	if studio_texture == null:
		_draw_logo_fallback(logo_rect, master)
		return
	var glitch := _glitch_strength()
	if glitch > 0.0:
		var offset := Vector2(3.5 * glitch, 0.0)
		var violet_ghost := VIOLET
		violet_ghost.a = master * 0.5 * glitch
		draw_texture_rect(studio_texture, Rect2(logo_rect.position - offset, logo_rect.size), false, violet_ghost)
		var cyan_ghost := CYAN
		cyan_ghost.a = master * 0.35 * glitch
		draw_texture_rect(studio_texture, Rect2(logo_rect.position + offset, logo_rect.size), false, cyan_ghost)
	draw_texture_rect(studio_texture, logo_rect, false, Color(1.0, 1.0, 1.0, master))


func _draw_logo_fallback(logo_rect: Rect2, master: float) -> void:
	var font := get_theme_default_font()
	if font == null:
		return
	var label := "GATO GOD MODE GAMES"
	var font_size := 20
	var text_width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var origin := Vector2(logo_rect.get_center().x - text_width * 0.5, logo_rect.get_center().y)
	draw_string(font, origin, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(1.0, 1.0, 1.0, master))


## A single specular bar wipes down the logo once the intro settles.
func _draw_sweep(logo_rect: Rect2, master: float) -> void:
	const SWEEP_START := 1.05
	const SWEEP_TIME := 0.85
	if elapsed < SWEEP_START or elapsed > SWEEP_START + SWEEP_TIME:
		return
	var progress := (elapsed - SWEEP_START) / SWEEP_TIME
	var band_height := logo_rect.size.y * 0.22
	var travel := logo_rect.size.y + band_height * 2.0
	var top := logo_rect.position.y - band_height + travel * progress
	var edge_fade := sin(progress * PI)
	var slices := 5
	for slice in range(slices):
		var slice_height := band_height / float(slices)
		var slice_top := top + slice_height * slice
		if slice_top < logo_rect.position.y or slice_top > logo_rect.end.y:
			continue
		var falloff := 1.0 - absf(float(slice) / float(slices - 1) - 0.5) * 2.0
		var tint := CYAN
		tint.a = master * 0.16 * edge_fade * falloff
		draw_rect(Rect2(logo_rect.position.x, slice_top, logo_rect.size.x, slice_height), tint, true)


func _draw_tagline(logo_rect: Rect2, master: float) -> void:
	var font := get_theme_default_font()
	if font == null:
		return
	var reveal := clampf((elapsed - TAGLINE_DELAY) / TAGLINE_FADE, 0.0, 1.0)
	if reveal <= 0.0:
		return
	var pulse := 0.86 + 0.14 * sin(elapsed * 2.6)
	var alpha := master * reveal * pulse
	var font_size := 11
	var text_width := font.get_string_size(TAGLINE_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var baseline_y := logo_rect.end.y + 26.0 - 6.0 * (1.0 - reveal)
	var origin := Vector2(size.x * 0.5 - text_width * 0.5, baseline_y)

	var glow := VIOLET
	glow.a = alpha * 0.35
	draw_string(font, origin + Vector2(0, 1), TAGLINE_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, glow)
	var body := TAGLINE_COLOR
	body.a = alpha
	draw_string(font, origin, TAGLINE_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, body)

	var tick := CYAN
	tick.a = alpha * 0.8
	var tick_y := baseline_y - font_size * 0.35
	var gap := 12.0
	var tick_len := 18.0 * reveal
	draw_line(Vector2(origin.x - gap - tick_len, tick_y), Vector2(origin.x - gap, tick_y), tick, 1.0)
	var right := origin.x + text_width + gap
	draw_line(Vector2(right, tick_y), Vector2(right + tick_len, tick_y), tick, 1.0)

	if fade_out_started < 0.0 and elapsed > TAGLINE_DELAY + 1.0:
		var hint_alpha := master * 0.22 * (0.6 + 0.4 * sin(elapsed * 3.1))
		var hint_size := 7
		var hint_width := font.get_string_size(SKIP_HINT_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, hint_size).x
		draw_string(
			font,
			Vector2(size.x * 0.5 - hint_width * 0.5, size.y - 18.0),
			SKIP_HINT_TEXT,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			hint_size,
			Color(0.72, 0.78, 0.86, hint_alpha)
		)


func _draw_embers(master: float) -> void:
	for index in range(EMBER_COUNT):
		var base := index * 5
		var speed := embers[base + 2]
		var rise := fposmod(embers[base + 1] - elapsed * speed, 1.0)
		var phase := embers[base + 4]
		var drift := sin(elapsed * 0.8 + phase) * 0.012
		var point := Vector2((embers[base] + drift) * size.x, rise * size.y)
		# Fade at both ends of the travel so motes never pop in or out.
		var travel_fade := sin(rise * PI)
		var tint := VIOLET
		tint.a = master * 0.4 * travel_fade * (0.5 + 0.5 * sin(elapsed * 2.4 + phase))
		draw_circle(point, embers[base + 3], tint)


func _draw_scanlines(view: Rect2, master: float) -> void:
	var drift := fposmod(elapsed * 9.0, SCANLINE_STEP)
	var line_color := Color(0.55, 0.75, 0.95, master * 0.05)
	var y := drift
	while y < view.size.y:
		draw_line(Vector2(0.0, y), Vector2(view.size.x, y), line_color, 1.0)
		y += SCANLINE_STEP


func _draw_vignette(view: Rect2) -> void:
	var steps := 14
	var band := view.size.y * 0.16 / float(steps)
	for step in range(steps):
		var alpha := 0.05 * (1.0 - float(step) / float(steps))
		var shade := Color(0.0, 0.0, 0.0, alpha)
		draw_rect(Rect2(0.0, band * step, view.size.x, band), shade, true)
		draw_rect(Rect2(0.0, view.size.y - band * (step + 1), view.size.x, band), shade, true)
