class_name MenuScreen
extends Control

signal start_requested(difficulty_id: String)
signal resume_requested(realm_id: String)

const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const DISPLAY_SETTINGS := preload("res://systems/display_settings.gd")
const TEXTURE_LOADER := preload("res://systems/texture_loader.gd")
const CURSOR_TEXTURE_PATH := "res://assets/art/ui/cursor_pointer.svg"
const SIDEBAR_FRAME_PATH := "res://assets/art/ui/menu_sidebar_frame.png"
const LOGO_MENU_PATH := "res://assets/branding/crawl_brawl_logo_menu.png"
const LOGO_FULL_PATH := "res://assets/branding/crawl_brawl_logo.png"
const STUDIO_LOGO_PATH := "res://assets/branding/gatogodmode_logo.png"
const BETA_TAGLINE := "OFFLINE PRIVATE EXCLUSIVE BETA"
const MENU_ICON_PATHS := {
	"NEW": "res://assets/art/ui/hud_icon_crosshair.png",
	"CONTINUE": "res://assets/art/ui/hud_icon_briefcase.png",
	"DIFFICULTY": "res://assets/art/ui/hud_icon_warning.png",
	"DISPLAY": "res://assets/art/ui/hud_icon_factory.png",
	"HOW": "res://assets/art/ui/hud_icon_crosshair.png",
	"QUIT": "res://assets/art/ui/hud_icon_warning.png",
}

# The sidebar art carries its own border, so content sits inside these bounds.
const SIDEBAR_RECT := Rect2(6, 6, 300, 348)
const CONTENT_X := 26
const CONTENT_W := 254
const LOGO_TOP := 20
const LOGO_H := 84

var help_panel: Control
var help_controls_scroll: ScrollContainer
var help_loop_scroll: ScrollContainer
var realm_panel: Control
var display_panel: Control
var main_buttons: VBoxContainer
var continue_button: Button
var difficulty_button: Button
var difficulty_summary: Label
var display_resolution_button: Button
var display_mode_button: Button
var display_density_button: Button
var display_summary: Label
var selected_difficulty_id := DIFFICULTY_PROFILE.DEFAULT_ID
var delete_confirm_dialog: ConfirmationDialog
var realm_status_label: Label
var pending_delete_realm_id := ""


func set_selected_difficulty(requested_id: String) -> void:
	selected_difficulty_id = DIFFICULTY_PROFILE.normalize_id(requested_id)
	_refresh_difficulty_display()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_install_custom_cursor()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_background()
	_build_main_menu()
	_build_help_panel()
	_build_realm_panel()
	_build_display_panel()
	main_buttons.get_child(0).grab_focus()


func _install_custom_cursor() -> void:
	# Keep the menu compilable before a clean source package has generated
	# its local .godot import cache. Falling back to the system cursor is safe.
	var cursor_resource: Resource = ResourceLoader.load(CURSOR_TEXTURE_PATH)
	var cursor_texture := cursor_resource as Texture2D
	if cursor_texture == null:
		return
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(2, 2))
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_POINTING_HAND, Vector2(2, 2))


func _build_background() -> void:
	var background := TextureRect.new()
	background.texture = _load_png_texture("res://assets/art/menu_background.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var shade := ColorRect.new()
	shade.color = Color(0.008, 0.018, 0.025, 0.52)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _build_sidebar_frame() -> void:
	var sidebar := TextureRect.new()
	sidebar.name = "MenuSidebarFrame"
	sidebar.texture = _load_png_texture(SIDEBAR_FRAME_PATH)
	if sidebar.texture == null:
		sidebar.queue_free()
		_build_sidebar_fallback()
		return
	# EXPAND_IGNORE_SIZE keeps the texture's own resolution out of the layout,
	# otherwise the frame renders at its full source size instead of this slot.
	sidebar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sidebar.stretch_mode = TextureRect.STRETCH_SCALE
	sidebar.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sidebar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sidebar)
	sidebar.position = SIDEBAR_RECT.position
	sidebar.size = SIDEBAR_RECT.size


func _build_sidebar_fallback() -> void:
	var fallback_panel := ColorRect.new()
	fallback_panel.name = "MenuSidebarFrame"
	fallback_panel.position = SIDEBAR_RECT.position
	fallback_panel.size = SIDEBAR_RECT.size
	fallback_panel.color = Color(0.008, 0.018, 0.024, 0.78)
	fallback_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fallback_panel)
	var panel_edge := ColorRect.new()
	panel_edge.position = Vector2(SIDEBAR_RECT.end.x - 2, SIDEBAR_RECT.position.y)
	panel_edge.size = Vector2(2, SIDEBAR_RECT.size.y)
	panel_edge.color = Color(0.34, 0.82, 0.9, 0.42)
	panel_edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel_edge)


func _load_png_texture(resource_path: String) -> Texture2D:
	return TEXTURE_LOADER.load_png(resource_path)


func _build_main_menu() -> void:
	_build_sidebar_frame()

	var logo := TextureRect.new()
	logo.name = "MenuLogo"
	logo.texture = _load_png_texture(LOGO_MENU_PATH)
	if logo.texture == null:
		logo.texture = _load_png_texture(LOGO_FULL_PATH)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)
	logo.position = Vector2(CONTENT_X, LOGO_TOP)
	logo.size = Vector2(CONTENT_W, LOGO_H)

	var status := Label.new()
	status.text = BETA_TAGLINE
	status.position = Vector2(CONTENT_X, LOGO_TOP + LOGO_H + 2)
	status.size = Vector2(CONTENT_W, 12)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 8)
	status.add_theme_color_override("font_color", Color("c8a6f2"))
	add_child(status)

	main_buttons = VBoxContainer.new()
	main_buttons.position = Vector2(CONTENT_X, LOGO_TOP + LOGO_H + 18)
	main_buttons.size = Vector2(CONTENT_W, 200)
	main_buttons.add_theme_constant_override("separation", 3)
	add_child(main_buttons)

	var begin := _make_button("NEW REALM")
	begin.pressed.connect(func() -> void: start_requested.emit(selected_difficulty_id))
	main_buttons.add_child(begin)
	if REALM_SAVE.has_active_save():
		continue_button = _make_button("CONTINUE EXPEDITION")
		continue_button.pressed.connect(_show_realms)
		main_buttons.add_child(continue_button)

	difficulty_button = _make_button("DIFFICULTY")
	difficulty_button.pressed.connect(_cycle_difficulty)
	main_buttons.add_child(difficulty_button)

	var display := _make_button("DISPLAY & INTERFACE")
	display.pressed.connect(_show_display)
	main_buttons.add_child(display)

	var how_to := _make_button("HOW TO PLAY")
	how_to.pressed.connect(_show_help)
	main_buttons.add_child(how_to)

	var quit := _make_button("QUIT TO DESKTOP")
	quit.pressed.connect(func() -> void: get_tree().quit())
	main_buttons.add_child(quit)

	var profile_card := Panel.new()
	profile_card.name = "ExpeditionProfileCard"
	profile_card.position = Vector2(318, 252)
	profile_card.size = Vector2(308, 96)
	profile_card.add_theme_stylebox_override(
		"panel", _button_style(Color(0.018, 0.055, 0.068, 0.9), Color(0.21, 0.56, 0.63, 0.75))
	)
	add_child(profile_card)

	var profile_accent := ColorRect.new()
	profile_accent.position = Vector2.ZERO
	profile_accent.size = Vector2(3, 96)
	profile_accent.color = Color("55dff5")
	profile_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	profile_card.add_child(profile_accent)

	var profile_heading := Label.new()
	profile_heading.text = "EXPEDITION PROFILE"
	profile_heading.position = Vector2(14, 8)
	profile_heading.size = Vector2(284, 14)
	profile_heading.add_theme_font_size_override("font_size", 8)
	profile_heading.add_theme_color_override("font_color", Color("6f8f98"))
	profile_card.add_child(profile_heading)

	difficulty_summary = Label.new()
	difficulty_summary.position = Vector2(14, 24)
	difficulty_summary.size = Vector2(284, 66)
	difficulty_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	difficulty_summary.add_theme_font_size_override("font_size", 8)
	difficulty_summary.add_theme_color_override("font_color", Color("d8e4e6"))
	profile_card.add_child(difficulty_summary)
	_refresh_difficulty_display()

	var studio_logo := TextureRect.new()
	studio_logo.name = "StudioLogo"
	studio_logo.texture = _load_png_texture(STUDIO_LOGO_PATH)
	studio_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	studio_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	studio_logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	studio_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(studio_logo)
	studio_logo.position = Vector2(SIDEBAR_RECT.get_center().x - 84, 270)
	studio_logo.size = Vector2(168, 36)

	var footer := Label.new()
	footer.text = "OFFLINE REALMS  //  FIELD-SAVE  //  GAMEPAD READY"
	# Clear of the frame's bottom-left corner bracket, which reaches x=30 at y=326.
	footer.position = Vector2(CONTENT_X + 8, 310)
	footer.size = Vector2(CONTENT_W - 16, 12)
	footer.add_theme_font_size_override("font_size", 7)
	footer.add_theme_color_override("font_color", Color("81979d"))
	add_child(footer)


func _build_help_panel() -> void:
	help_panel = ColorRect.new()
	help_panel.position = Vector2(18, 18)
	help_panel.size = Vector2(604, 324)
	help_panel.color = Color(0.015, 0.03, 0.038, 0.97)
	help_panel.visible = false
	add_child(help_panel)
	var help_accent := ColorRect.new()
	help_accent.size = Vector2(604, 3)
	help_accent.color = Color("55dff5")
	help_panel.add_child(help_accent)

	var heading := Label.new()
	heading.text = "FIELD MANUAL"
	heading.position = Vector2(24, 14)
	heading.size = Vector2(300, 28)
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", Color("8eeaff"))
	help_panel.add_child(heading)

	var controls_title := Label.new()
	controls_title.text = "CONTROLS"
	controls_title.position = Vector2(26, 44)
	controls_title.add_theme_font_size_override("font_size", 9)
	controls_title.add_theme_color_override("font_color", Color("5c7b82"))
	help_panel.add_child(controls_title)

	help_controls_scroll = ScrollContainer.new()
	help_controls_scroll.position = Vector2(26, 58)
	help_controls_scroll.size = Vector2(268, 208)
	help_controls_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	help_panel.add_child(help_controls_scroll)

	var loop_card := ColorRect.new()
	loop_card.position = Vector2(306, 44)
	loop_card.size = Vector2(284, 222)
	loop_card.color = Color("0b1c24")
	help_panel.add_child(loop_card)

	var loop_title := Label.new()
	loop_title.text = "EXPEDITION LOOP"
	loop_title.position = Vector2(12, 8)
	loop_title.add_theme_font_size_override("font_size", 9)
	loop_title.add_theme_color_override("font_color", Color("5c7b82"))
	loop_card.add_child(loop_title)

	help_loop_scroll = ScrollContainer.new()
	help_loop_scroll.position = Vector2(8, 26)
	help_loop_scroll.size = Vector2(268, 188)
	help_loop_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	loop_card.add_child(help_loop_scroll)

	var back := _make_button("BACK")
	back.position = Vector2(440, 278)
	back.size = Vector2(150, 32)
	back.pressed.connect(_hide_help)
	help_panel.add_child(back)
	_refresh_help_panel()


func _help_body_font_size() -> int:
	return 7 if DISPLAY_SETTINGS.ui_density() == "COMPACT" else 8


func _refresh_help_panel() -> void:
	if not is_instance_valid(help_controls_scroll) or not is_instance_valid(help_loop_scroll):
		return
	for child in help_controls_scroll.get_children():
		child.queue_free()
	for child in help_loop_scroll.get_children():
		child.queue_free()

	var controls_grid := GridContainer.new()
	controls_grid.columns = 2
	controls_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_grid.add_theme_constant_override("h_separation", 10)
	controls_grid.add_theme_constant_override("v_separation", 1)
	help_controls_scroll.add_child(controls_grid)

	var body_font := _help_body_font_size()
	var controls_list := [
		["MOVE", "WASD / L STICK"],
		["AIM", "MOUSE / R STICK"],
		["FIRE", "LMB / R TRIG"],
		["MINE", "RMB / L TRIG"],
		["DASH", "SPACE / A"],
		["SPRINT", "SHIFT / L3"],
		["RELOAD", "R / X"],
		["WEAPONS", "1-5 / WHEEL"],
		["BUILD / CANCEL", "TAB / Y"],
		["CYCLE BUILD", "Q / E / BUMPERS"],
		["CORE / FOUNDRY / VAULT", "CLICK TARGET"],
		["PERSONAL BASE HEAL", "F / B AT HUT"],
		["CORE TERMINAL", "ARROWS + ENTER / A"],
		["BACKPACK", "I / SELECT"],
		["VAULT QUICK DUMP", "HOLD R NEAR VAULT"],
		["PAUSE / CLOSE UI", "ESC / START / F"],
	]
	for pair in controls_list:
		var action_lbl := Label.new()
		action_lbl.text = pair[0]
		action_lbl.custom_minimum_size = Vector2(112, 0)
		action_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		action_lbl.add_theme_font_size_override("font_size", body_font)
		action_lbl.add_theme_color_override("font_color", Color("81979d"))
		controls_grid.add_child(action_lbl)
		var bind_lbl := Label.new()
		bind_lbl.text = pair[1]
		bind_lbl.custom_minimum_size = Vector2(136, 0)
		bind_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bind_lbl.add_theme_font_size_override("font_size", body_font)
		bind_lbl.add_theme_color_override("font_color", Color("dce7e8"))
		controls_grid.add_child(bind_lbl)

	var loop_text := RichTextLabel.new()
	loop_text.bbcode_enabled = true
	loop_text.fit_content = true
	loop_text.scroll_active = false
	loop_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loop_text.custom_minimum_size = Vector2(252, 0)
	loop_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loop_text.text = (
		"[color=#a7eefa]1[/color]  Explore sectors and mine ore into your pack.\n"
		+ "[color=#a7eefa]2[/color]  [b]Click[/b] an active Core, Foundry, or Vault to interact.\n"
		+ "[color=#a7eefa]3[/color]  [color=#f0d47b]MATERIALS[/color] deposits cargo or queues refinement.\n"
		+ "[color=#a7eefa]4[/color]  [color=#f0d47b]PROGRESS[/color] spends [color=#f0d47b]Skill Points[/color] from levels on branch nodes and base blueprints.\n"
		+ "[color=#a7eefa]5[/color]  After unlocking Personal Base at [color=#f0d47b]PROGRESS[/color], craft the kit at [color=#f0d47b]BASE[/color] with scrap and parts.\n"
		+ "[color=#a7eefa]6[/color]  Press [b]ESC[/b] at any active Core to open the archive and save.\n"
		+ "[color=#a7eefa]7[/color]  Unlock Personal Base at [color=#f0d47b]PROGRESS[/color] for free [b]F[/b] healing at the hut.\n"
		+ "[color=#a7eefa]8[/color]  Frontier Cores unlock after four surveyed sectors and clearing the site guardian.\n"
		+ "[color=#a7eefa]9[/color]  The realm continues while at least one Core stays active; death or Continue returns you to your last saved Core.\n"
		+ "[color=#a7eefa]10[/color]  Checkpoint Slot 1 saves now; Slots 2-3 unlock at higher expedition levels.\n"
		+ "[color=#a7eefa]11[/color]  [color=#f0d47b]ARMORY[/color], [color=#f0d47b]MINING[/color], and deployable kits still use scrap plus refined parts.\n\n"
		+ "[color=#ef8b72]Frontier Core:[/color] $1000   [color=#ef8b72]Hive Awareness:[/color] exploration actions escalate pressure\n"
		+ "[color=#81979d]No field save means death ends the realm. After saving, death resurrects you and drops your pack at a recovery marker for ten minutes.[/color]"
	)
	loop_text.add_theme_font_size_override("normal_font_size", body_font)
	help_loop_scroll.add_child(loop_text)


func _build_realm_panel() -> void:
	realm_panel = ColorRect.new()
	realm_panel.position = Vector2(18, 18)
	realm_panel.size = Vector2(604, 324)
	realm_panel.color = Color(0.012, 0.026, 0.034, 0.985)
	realm_panel.visible = false
	add_child(realm_panel)
	var realm_accent := ColorRect.new()
	realm_accent.size = Vector2(604, 3)
	realm_accent.color = Color("55dff5")
	realm_panel.add_child(realm_accent)
	var heading := Label.new()
	heading.text = "SAVED REALMS"
	heading.position = Vector2(24, 16)
	heading.size = Vector2(430, 32)
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("8eeaff"))
	realm_panel.add_child(heading)
	var subheading := Label.new()
	subheading.text = "Choose an expedition. Every realm keeps its own protected local world."
	subheading.position = Vector2(26, 49)
	subheading.size = Vector2(550, 20)
	subheading.add_theme_font_size_override("font_size", 9)
	subheading.add_theme_color_override("font_color", Color("9eb2b8"))
	realm_panel.add_child(subheading)
	var realm_scroll := ScrollContainer.new()
	realm_scroll.name = "RealmScroll"
	realm_scroll.position = Vector2(26, 76)
	realm_scroll.size = Vector2(550, 194)
	realm_panel.add_child(realm_scroll)
	var realm_list := VBoxContainer.new()
	realm_list.name = "RealmList"
	realm_list.custom_minimum_size = Vector2(530, 190)
	realm_list.add_theme_constant_override("separation", 5)
	realm_scroll.add_child(realm_list)
	realm_status_label = Label.new()
	realm_status_label.position = Vector2(26, 248)
	realm_status_label.size = Vector2(550, 18)
	realm_status_label.add_theme_font_size_override("font_size", 8)
	realm_status_label.add_theme_color_override("font_color", Color("ef8b72"))
	realm_panel.add_child(realm_status_label)
	var back := _make_button("BACK")
	back.position = Vector2(26, 274)
	back.size = Vector2(150, 32)
	back.pressed.connect(_hide_realms)
	realm_panel.add_child(back)
	delete_confirm_dialog = ConfirmationDialog.new()
	delete_confirm_dialog.title = "DELETE REALM"
	delete_confirm_dialog.ok_button_text = "DELETE"
	delete_confirm_dialog.cancel_button_text = "CANCEL"
	delete_confirm_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	delete_confirm_dialog.confirmed.connect(_execute_pending_delete)
	add_child(delete_confirm_dialog)
	_refresh_realm_list()


func _refresh_realm_list() -> void:
	if not is_instance_valid(realm_panel):
		return
	var realm_list := realm_panel.get_node("RealmScroll/RealmList") as VBoxContainer
	for child in realm_list.get_children():
		child.queue_free()
	var realms: Array[Dictionary] = REALM_SAVE.list_realms()
	if realms.is_empty():
		realm_status_label.text = "NO SAVED REALMS // START A NEW EXPEDITION"
	else:
		realm_status_label.text = ""
	for realm_index in range(realms.size()):
		var summary: Dictionary = realms[realm_index]
		var difficulty_name: String = str(DIFFICULTY_PROFILE.get_profile(str(summary.get("difficulty_id", "bastion")))["name"])
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(530, 46)
		row.add_theme_constant_override("separation", 6)
		var realm_button := _make_button(
			"%s  //  AWARENESS MK%d  //  %s\nSEED %08X  //  $%d  //  %d ACTIVE BASE%s" % [
				str(summary["realm_title"]), int(summary.get("awareness_tier", 0)), difficulty_name,
				int(summary["realm_seed"]), int(summary.get("credits", 0)),
				int(summary.get("active_bases", 1)), "" if int(summary.get("active_bases", 1)) == 1 else "S"
			]
		)
		realm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		realm_button.custom_minimum_size = Vector2(430, 46)
		realm_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		realm_button.add_theme_font_size_override("font_size", 10)
		realm_button.pressed.connect(_request_realm.bind(str(summary["realm_id"])))
		row.add_child(realm_button)
		var delete_button := _make_button("DELETE")
		delete_button.custom_minimum_size = Vector2(88, 46)
		delete_button.add_theme_color_override("font_color", Color("ffb0a0"))
		delete_button.add_theme_color_override("font_hover_color", Color("ffd0c8"))
		delete_button.add_theme_stylebox_override("normal", _button_style(Color(0.12, 0.04, 0.04, 0.94), Color("a04848")))
		delete_button.add_theme_stylebox_override("hover", _button_style(Color(0.2, 0.05, 0.05, 0.98), Color("ef6868")))
		delete_button.add_theme_stylebox_override("focus", _button_style(Color(0.2, 0.05, 0.05, 0.98), Color("ff8a8a")))
		delete_button.pressed.connect(_confirm_delete_realm.bind(summary))
		row.add_child(delete_button)
		realm_list.add_child(row)


func _sync_continue_button() -> void:
	var should_show := REALM_SAVE.has_active_save()
	if should_show and continue_button == null:
		continue_button = _make_button("CONTINUE EXPEDITION")
		continue_button.pressed.connect(_show_realms)
		main_buttons.add_child(continue_button)
		main_buttons.move_child(continue_button, 1)
	elif not should_show and continue_button != null:
		continue_button.queue_free()
		continue_button = null


func _confirm_delete_realm(summary: Dictionary) -> void:
	pending_delete_realm_id = str(summary["realm_id"])
	var realm_title := str(summary.get("realm_title", "UNKNOWN REALM"))
	delete_confirm_dialog.dialog_text = "Permanently delete \"%s\"?\nAwareness MK%d // SEED %08X\nThis removes the realm, backup, and recovery data." % [
		realm_title, int(summary.get("awareness_tier", 0)), int(summary.get("realm_seed", 0))]
	delete_confirm_dialog.popup_centered()


func _execute_pending_delete() -> void:
	var realm_id := pending_delete_realm_id
	pending_delete_realm_id = ""
	if realm_id.is_empty():
		return
	_execute_delete_realm(realm_id)


func _execute_delete_realm(realm_id: String) -> void:
	if not REALM_SAVE.delete_realm(realm_id):
		realm_status_label.text = "DELETE FAILED // REALM DATA MAY BE PARTIALLY REMOVED"
		return
	_refresh_realm_list()
	_sync_continue_button()
	if REALM_SAVE.list_realms().is_empty():
		_hide_realms()


func _build_display_panel() -> void:
	display_panel = ColorRect.new()
	display_panel.name = "DisplayPanel"
	display_panel.position = Vector2(18, 18)
	display_panel.size = Vector2(604, 324)
	display_panel.color = Color(0.012, 0.026, 0.034, 0.985)
	display_panel.visible = false
	add_child(display_panel)
	var accent := ColorRect.new()
	accent.size = Vector2(604, 3)
	accent.color = Color("55dff5")
	display_panel.add_child(accent)
	var heading := Label.new()
	heading.text = "DISPLAY & INTERFACE"
	heading.position = Vector2(24, 16)
	heading.size = Vector2(430, 32)
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("8eeaff"))
	display_panel.add_child(heading)
	var subheading := Label.new()
	subheading.text = "Choose a crisp 16:9 output and comfortable terminal density."
	subheading.position = Vector2(26, 48)
	subheading.size = Vector2(550, 20)
	subheading.add_theme_font_size_override("font_size", 9)
	subheading.add_theme_color_override("font_color", Color("9eb2b8"))
	display_panel.add_child(subheading)

	display_resolution_button = _make_button("")
	display_resolution_button.position = Vector2(26, 78)
	display_resolution_button.size = Vector2(270, 34)
	display_resolution_button.pressed.connect(func() -> void:
		DISPLAY_SETTINGS.cycle_resolution()
		_refresh_display_panel()
	)
	display_panel.add_child(display_resolution_button)
	display_mode_button = _make_button("")
	display_mode_button.position = Vector2(26, 119)
	display_mode_button.size = Vector2(270, 34)
	display_mode_button.pressed.connect(func() -> void:
		DISPLAY_SETTINGS.cycle_window_mode()
		_refresh_display_panel()
	)
	display_panel.add_child(display_mode_button)
	display_density_button = _make_button("")
	display_density_button.position = Vector2(26, 160)
	display_density_button.size = Vector2(270, 34)
	display_density_button.pressed.connect(func() -> void:
		DISPLAY_SETTINGS.cycle_ui_density()
		_refresh_display_panel()
	)
	display_panel.add_child(display_density_button)

	var summary_card := ColorRect.new()
	summary_card.position = Vector2(316, 78)
	summary_card.size = Vector2(260, 116)
	summary_card.color = Color("0b2831")
	display_panel.add_child(summary_card)
	display_summary = Label.new()
	display_summary.position = Vector2(14, 12)
	display_summary.size = Vector2(232, 92)
	display_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	display_summary.add_theme_font_size_override("font_size", 9)
	display_summary.add_theme_color_override("font_color", Color("c8d8dc"))
	display_summary.clip_text = true
	display_summary.max_lines_visible = 7
	summary_card.add_child(display_summary)

	var apply_button := _make_button("APPLY & SAVE")
	apply_button.position = Vector2(316, 207)
	apply_button.size = Vector2(260, 34)
	apply_button.pressed.connect(_apply_display_settings)
	display_panel.add_child(apply_button)
	var back := _make_button("BACK")
	back.position = Vector2(26, 265)
	back.size = Vector2(150, 32)
	back.pressed.connect(_hide_display)
	display_panel.add_child(back)
	_refresh_display_panel()


func _refresh_display_panel() -> void:
	if not is_instance_valid(display_resolution_button):
		return
	display_resolution_button.text = "RESOLUTION  //  %s" % DISPLAY_SETTINGS.resolution_label()
	display_mode_button.text = "WINDOW MODE  //  %s" % DISPLAY_SETTINGS.window_mode()
	display_density_button.text = "INTERFACE  //  %s" % DISPLAY_SETTINGS.ui_density()
	display_summary.text = (
		"COMPACT scales gameplay overlays to 84% and uses tighter terminal type.\n\n"
		+ "STANDARD retains the full 640 × 360 interface footprint.\n\n"
		+ "APPLY saves this profile for future launches."
	)


func _apply_display_settings() -> void:
	DISPLAY_SETTINGS.save_settings()
	DISPLAY_SETTINGS.apply()
	_refresh_display_panel()
	if is_instance_valid(help_panel) and help_panel.visible:
		_refresh_help_panel()


func _make_button(text_value: String) -> Button:
	var button := Button.new()
	button.text = text_value
	for prefix: String in MENU_ICON_PATHS:
		if text_value.begins_with(prefix):
			button.icon = _load_png_texture(str(MENU_ICON_PATHS[prefix]))
			break
	button.custom_minimum_size = Vector2(CONTENT_W, 22)
	button.add_theme_font_size_override("font_size", 10)
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_color_override("font_color", Color("dcecef"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_focus_color", Color("ffffff"))
	button.add_theme_stylebox_override("normal", _button_style(Color(0.035, 0.09, 0.11, 0.92), Color("3b7280")))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.04, 0.18, 0.21, 0.96), Color("71d8ef")))
	button.add_theme_stylebox_override("focus", _button_style(Color(0.04, 0.18, 0.21, 0.96), Color("8eeaff")))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.02, 0.25, 0.28, 1.0), Color("b4f4ff")))
	return button


func _cycle_difficulty() -> void:
	selected_difficulty_id = DIFFICULTY_PROFILE.next_id(selected_difficulty_id)
	_refresh_difficulty_display()


func _refresh_difficulty_display() -> void:
	var profile := DIFFICULTY_PROFILE.get_profile(selected_difficulty_id)
	if is_instance_valid(difficulty_button):
		difficulty_button.text = "DIFFICULTY: %s" % profile["name"]
	if is_instance_valid(difficulty_summary):
		var first_contact := DIFFICULTY_PROFILE.encounter_spawn_count(selected_difficulty_id, 0)
		var interval := DIFFICULTY_PROFILE.encounter_spawn_interval(selected_difficulty_id, 0)
		var rate := 1.0 / interval
		difficulty_summary.text = (
			"%s\n" % str(profile["name"]).to_upper()
			+ "FIRST CONTACT  //  %d HOSTILES\n" % first_contact
			+ "ENTRY RATE  //  %.1f / SEC\n" % rate
			+ str(profile["description"])
		)


func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	return style


func _show_help() -> void:
	main_buttons.visible = false
	_refresh_help_panel()
	help_panel.visible = true
	help_panel.get_child(help_panel.get_child_count() - 1).grab_focus()


func _show_realms() -> void:
	main_buttons.visible = false
	_refresh_realm_list()
	realm_panel.visible = true
	var realm_list := realm_panel.get_node("RealmScroll/RealmList") as VBoxContainer
	if realm_list.get_child_count() > 0:
		(realm_list.get_child(0) as Control).get_child(0).grab_focus()


func _show_display() -> void:
	main_buttons.visible = false
	display_panel.visible = true
	_refresh_display_panel()
	display_resolution_button.grab_focus()


func _hide_realms() -> void:
	realm_panel.visible = false
	main_buttons.visible = true
	main_buttons.get_child(0).grab_focus()


func _hide_display() -> void:
	display_panel.visible = false
	main_buttons.visible = true
	main_buttons.get_child(0).grab_focus()


func _request_realm(realm_id: String) -> void:
	resume_requested.emit(realm_id)


func _hide_help() -> void:
	help_panel.visible = false
	main_buttons.visible = true
	main_buttons.get_child(0).grab_focus()
