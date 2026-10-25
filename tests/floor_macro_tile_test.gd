extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const VISUAL_STYLE := preload("res://systems/realm_visual_style.gd")


func _initialize() -> void:
	call_deferred("_run_floor_macro_tile_test")


func _run_floor_macro_tile_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	for material: Texture2D in [
		run.tunnel_material,
		run.hive_material,
		run.bunker_material,
		run.crystal_material,
		run.foundry_material,
		run.sulfur_material,
		run.iron_material,
	]:
		assert(material != null, "Floor atlases should load for macro sampling")
		assert(material.get_width() % run.MATERIAL_MACRO_SIZE == 0, "Floor atlas width should align to 32px macros")
		assert(material.get_height() % run.MATERIAL_MACRO_SIZE == 0, "Floor atlas height should align to 32px macros")

	var profiled_materials: Array = [
		[run.tunnel_material, VISUAL_STYLE.MATERIAL_TUNNEL],
		[run.hive_material, VISUAL_STYLE.MATERIAL_HIVE],
		[run.bunker_material, VISUAL_STYLE.MATERIAL_BUNKER],
		[run.crystal_material, VISUAL_STYLE.MATERIAL_CRYSTAL],
		[run.foundry_material, VISUAL_STYLE.MATERIAL_FOUNDRY],
		[run.sulfur_material, VISUAL_STYLE.MATERIAL_SULFUR],
		[run.iron_material, VISUAL_STYLE.MATERIAL_IRON],
	]
	for profile_value: Variant in profiled_materials:
		var profile: Array = profile_value
		var material: Texture2D = profile[0]
		var material_id: int = profile[1]
		var reviewed_pool: Array = VISUAL_STYLE.base_variant_pool(material_id)
		for sample_index: int in range(32):
			var macro_cell := Vector2i(sample_index * 2, posmod(sample_index * 14, 38))
			var atlas_index: int = run._macro_variant_index(material, macro_cell, run._material_salt(material))
			assert(reviewed_pool.has(atlas_index), "Runtime floor selection must stay inside its reviewed quiet-base pool")

	assert(run.cave_texture != null, "Cave atlas should load for macro wall sampling")
	assert(run.cave_texture.get_width() % 32 == 0, "Cave atlas width should align to 32px macro patches")
	assert(run.cave_texture.get_height() % 32 == 0, "Cave atlas height should align to 32px macro patches")

	var rock_origin := Vector2i(-1, -1)
	for y in range(run.grid.core_cell.y - 8, run.grid.core_cell.y + 8):
		for x in range(run.grid.core_cell.x - 8, run.grid.core_cell.x + 8):
			var candidate := run._macro_block_origin(Vector2i(x, y))
			if run._macro_block_is_complete_rock(candidate):
				rock_origin = candidate
				break
		if rock_origin.x >= 0:
			break
	if rock_origin.x >= 0:
		var rock_region: Rect2 = run._macro_block_texture_region(run.cave_texture, rock_origin, 41)
		assert(rock_region.size == Vector2(32, 32), "Complete rock macro blocks should sample 32px cave patches")
		assert(rock_region.position.x < 128 and rock_region.position.y < 128, "Rock macros must stay inside the populated 4x4 cave bank")

	var salt: int = run._material_salt(run.tunnel_material)
	var complete_origin := Vector2i(-1, -1)
	for y in range(run.grid.core_cell.y - 2, run.grid.core_cell.y + 4):
		for x in range(run.grid.core_cell.x - 2, run.grid.core_cell.x + 4):
			var candidate := run._macro_block_origin(Vector2i(x, y))
			if run._macro_block_is_complete_floor(candidate):
				complete_origin = candidate
				break
		if complete_origin.x >= 0:
			break
	assert(complete_origin.x >= 0, "Should find a complete floor macro block near core")
	var regions: Array[Rect2] = []
	for offset: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		var cell := complete_origin + offset
		var region: Rect2 = run._floor_texture_region(run.tunnel_material, cell, salt)
		assert(region.size == Vector2(16, 16), "Each floor cell should sample a 16px sub-patch")
		regions.append(region)
	assert(regions[1].position - regions[0].position == Vector2(16, 0), "Right floor cell should use the authored macro's right quadrant")
	assert(regions[2].position - regions[0].position == Vector2(0, 16), "Lower floor cell should use the authored macro's lower quadrant")
	assert(regions[3].position - regions[0].position == Vector2(16, 16), "Diagonal floor cell should use the authored macro's lower-right quadrant")
	var complete_region: Rect2 = run._macro_block_texture_region(run.tunnel_material, complete_origin, salt)
	assert(complete_region.size == Vector2(32, 32), "A complete 2x2 world block should sample one coherent 32px authored macro")
	var backing: Color = run._backing_color_for_source(run.tunnel_material, regions[0])
	assert(backing != Color(), "Patch edge backing should sample from sub-patch source rect")

	print("CRAWL_BRAWL_FLOOR_MACRO_TILE_TEST_OK")
	quit(0)
