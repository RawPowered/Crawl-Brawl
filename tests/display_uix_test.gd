extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const DISPLAY_SETTINGS := preload("res://systems/display_settings.gd")
const COMBAT_VFX := preload("res://systems/combat_vfx.gd")


func _initialize() -> void:
	call_deferred("_run_display_uix_test")


func _run_display_uix_test() -> void:
	for resolution: Vector2i in DISPLAY_SETTINGS.RESOLUTIONS:
		assert(resolution.x * 9 == resolution.y * 16, "Every selectable resolution should preserve the 16:9 gameplay canvas")
	DISPLAY_SETTINGS.resolution_index = 2
	DISPLAY_SETTINGS.window_mode_index = 0
	DISPLAY_SETTINGS.ui_density_index = 0
	assert(DISPLAY_SETTINGS.resolution_label() == "1920 × 1080", "Resolution labels should expose the selected output")
	assert(is_equal_approx(DISPLAY_SETTINGS.overlay_scale(), 0.88), "Compact density should use the intended overlay scale")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.show_menu()
	await process_frame
	var menu = main.current_screen
	assert(menu.get_node_or_null("DisplayPanel") != null, "The main menu should expose display and interface controls")
	assert(menu.main_buttons.get_child(0).icon != null, "Main menu actions should use the sliced HUD icon family")
	menu._show_display()
	assert(menu.display_panel.visible and "RESOLUTION" in menu.display_resolution_button.text, "Display settings should open with a readable resolution action")
	menu._hide_display()

	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	assert(run.player_textures.size() == run.PLAYER_STYLE_PATHS.size() and run.player_direction_textures.size() == run.PLAYER_STYLE_SLUGS.size() * run.PLAYER_DIRECTION_NAMES.size() and run.player_active_direction_textures.size() == run.player_direction_textures.size(), "Every active player style and directional sprite must load")
	assert(run.shop_icons.size() == run.SHOP_ICON_NAMES.size() and run.mob_textures.size() == run.MOB_TEXTURE_PATHS.size() and run.turret_textures.size() == run.TURRET_TEXTURE_PATHS.size(), "Every configured shop, mob, and turret sprite must load")
	assert(run.world_textures.size() == run.WORLD_TEXTURE_PATHS.size(), "Every configured world-facing sprite must load")
	assert(run.ui_textures.size() == run.UI_TEXTURE_NAMES.size(), "Packaged HUD atlas sprites must load")
	assert(run._ui_texture("reticle_yellow") != null and run._ui_texture("hud_icon_crosshair") != null, "HUD reticle and icon sprites must decode")
	assert(run._ui_texture("hud_display_panel") != null and run._ui_texture("hud_bar_green") != null, "HUD panel and meter sprites must decode")
	assert(COMBAT_VFX.reticle_hotspot("reticle_cyan").distance_to(Vector2(12.0, 12.0)) <= 3.0, "Reticle hotspots should stay near the optical center")
	assert(run.combat_textures.size() == COMBAT_VFX.all_texture_names().size(), "Every combat FX sprite (projectiles, muzzles, trails, impacts) must decode")
	assert(run._combat_texture("projectile_pistol") != null and run._combat_texture("laser_impact") != null and run._combat_texture("rocket_explosion") != null, "Key projectile and impact sprites must decode")
	assert(is_equal_approx(run.overlay_root.scale.x, 0.88) and run.overlay_root.position.is_equal_approx(Vector2(38.4, 21.6)), "Compact overlays should remain centered inside the 640 × 360 canvas")
	assert(run.world_textures.get("foundry") != null and run.world_textures.get("personal_base") != null and run.world_textures.get("heavy_doorway") != null and run.world_textures.get("barrier") != null and run.world_textures.get("pickup") != null and run.world_textures.get("crate") != null and run.world_textures.get("lamp") != null and run.world_textures.get("eggs") != null and run.world_textures.get("acid") != null and run.world_textures.get("web") != null and run.world_textures.get("grate") != null and run.world_textures.get("rubble") != null and run.world_textures.get("conduit") != null, "World-facing facilities, doorway, barriers, pickups, and ecology props must load separately from shop icons")
	assert(run._barrier_world_tint(run.BUILD_STEEL_BARRIER) != Color.WHITE and run._barrier_world_tint(run.BUILD_BLAST_BARRIER) != run._barrier_world_tint(run.BUILD_STEEL_BARRIER), "Barrier material grades should retain distinct world tints")
	run.current_base_id = run.base_network.COMMAND_ID
	run._open_core_base()
	await process_frame
	assert(run.core_base_panel.get_node("TerminalFrame").size == run.core_base_panel.size, "The requisition terminal artwork should be pinned to the shop panel bounds")
	assert(run.pause_panel.get_node("Frame/FrameArt").size == run.pause_panel.get_node("Frame").size, "The command-module artwork should be pinned to the pause frame bounds")
	assert(run.realm_archive_panel.get_node("FrameArt").size == run.realm_archive_panel.size, "The command-module artwork should be pinned to the save frame bounds")
	assert(run.core_base_title.get_theme_font_size("font_size") == 14, "Compact terminal titles should not dominate high-resolution screens")
	assert(run.core_detail_icon != null and run.core_detail_icon.texture != null, "The selected shop item should receive a large visual inspection icon")
	assert(run.core_detail_body.clip_text and run.core_detail_body.max_lines_visible == 3, "Long shop descriptions should remain inside the compact detail card")
	assert(run.core_service_buttons[0].tooltip_text.is_empty(), "Shop rows should use the compact detail card instead of viewport-scaled native tooltips")
	assert(run.core_tab_buttons["armory"].icon != null and run.core_tab_buttons["materials"].icon != null, "Core departments should be visually identifiable before reading their labels")
	var close_button: Button
	for child: Node in run.core_base_panel.get_children():
		if child is Button and str(child.text) == "CLOSE":
			close_button = child
			break
	assert(close_button != null, "The terminal should retain a dedicated close action")
	assert(close_button.custom_minimum_size.y == 18.0 and close_button.get_theme_font_size("font_size") == 9, "Close should use the compact height and type size instead of the generic overlay minimum")
	var resume: Button = run.pause_panel.get_node("Frame/Buttons/Resume")
	assert(resume.custom_minimum_size == Vector2(236, 23) and resume.get_theme_font_size("font_size") == 8, "Pause actions should align to the command-module action bays")

	print("CRAWL_BRAWL_DISPLAY_UIX_TEST_OK")
	quit(0)
