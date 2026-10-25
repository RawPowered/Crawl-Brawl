extends SceneTree

const COMBAT_VFX := preload("res://systems/combat_vfx.gd")


func _initialize() -> void:
	call_deferred("_run_mining_gun_asset_test")


func _run_mining_gun_asset_test() -> void:
	var seen: Dictionary = {}
	for tier: int in range(1, 6):
		for direction_name: String in COMBAT_VFX.MINING_GUN_DIRECTIONS:
			var texture_id := COMBAT_VFX.mining_gun_texture_id(tier, direction_name)
			assert(not seen.has(texture_id), "Mining gun texture ids must be unique")
			seen[texture_id] = true
			var texture: Texture2D = load("res://assets/art/combat/%s.png" % texture_id)
			assert(texture != null, "Mining gun texture should load: %s" % texture_id)
			assert(texture.get_width() == 32 and texture.get_height() == 32, "Mining gun texture should be 32x32: %s" % texture_id)
			var image := texture.get_image()
			var visible := 0
			var border_visible := 0
			for y: int in range(32):
				for x: int in range(32):
					if image.get_pixel(x, y).a <= 0.01:
						continue
					visible += 1
					if x == 0 or y == 0 or x == 31 or y == 31:
						border_visible += 1
			assert(visible > 40, "Mining gun should contain visible authored pixels: %s" % texture_id)
			assert(border_visible == 0, "Mining gun should retain a transparent border: %s" % texture_id)
	assert(seen.size() == 40, "Five tiers by eight directions should produce 40 mining gun textures")
	assert(COMBAT_VFX.mining_gun_direction(Vector2.RIGHT) == "right", "Right aim should select right sprite")
	assert(COMBAT_VFX.mining_gun_direction(Vector2(-1, -1)) == "up_left", "Diagonal aim should select authored up-left sprite")
	assert(COMBAT_VFX.mining_gun_direction(Vector2.DOWN) == "down", "Down aim should select down sprite")

	print("CRAWL_BRAWL_MINING_GUN_ASSET_TEST_OK")
	quit(0)
