extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const COMBAT_VFX := preload("res://systems/combat_vfx.gd")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_runtime_asset_integrity_test")


func _run_runtime_asset_integrity_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	assert(run.runtime_assets_valid, "Runtime asset validation should pass: %s" % ", ".join(run.runtime_asset_failures))
	assert(run.combat_textures.size() == COMBAT_VFX.all_texture_names().size(), "Every combat texture should decode")
	for weapon_id: int in range(COMBAT_VFX.HELD_TEXTURE_BY_WEAPON.size()):
		var held_id: String = COMBAT_VFX.held_weapon_texture_id(weapon_id)
		var held_texture: Texture2D = run.combat_textures.get(held_id)
		assert(held_texture != null, "Held weapon texture should load: %s" % held_id)
		assert(
			held_texture.get_width() == int(COMBAT_VFX.HELD_WEAPON_CANVAS.x)
			and held_texture.get_height() == int(COMBAT_VFX.HELD_WEAPON_CANVAS.y),
			"Held weapon %s should be 24x16" % held_id
		)

	assert(run._player_chroma_spill_pixels() == 0, "Player sprites should contain no magenta-sheet fringe")
	for texture_key: String in run.player_direction_textures:
		_assert_clean_player_sprite(run.player_direction_textures.get(texture_key), texture_key)
	for texture_key: String in run.player_active_direction_textures:
		_assert_clean_player_sprite(run.player_active_direction_textures.get(texture_key), "%s_active" % texture_key)

	print("CRAWL_BRAWL_ASSETS_OK")
	quit(0)


func _assert_clean_player_sprite(texture: Texture2D, label: String) -> void:
	assert(texture != null and texture.get_width() == 28 and texture.get_height() == 30, "Player sprite should be 28x30: %s" % label)
	var image := texture.get_image()
	assert(image != null and not image.is_empty(), "Player sprite should decode: %s" % label)
	var visible := 0
	var border_visible := 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a <= 0.01:
				continue
			visible += 1
			if x == 0 or y == 0 or x == image.get_width() - 1 or y == image.get_height() - 1:
				border_visible += 1
	var coverage := float(visible) / float(image.get_width() * image.get_height())
	assert(coverage >= 0.08 and coverage <= 0.78, "Player sprite %s has suspicious alpha coverage: %.1f%%" % [label, coverage * 100.0])
	assert(border_visible == 0, "Player sprite %s should have a transparent one-pixel border" % label)
