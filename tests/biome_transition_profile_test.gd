extends SceneTree

const VISUAL_STYLE := preload("res://systems/realm_visual_style.gd")


func _initialize() -> void:
	call_deferred("_run_biome_transition_profile_test")


func _run_biome_transition_profile_test() -> void:
	var edge_colors: Dictionary = {}
	for material_id: int in range(VISUAL_STYLE.MATERIAL_IRON + 1):
		var pool: Array = VISUAL_STYLE.WALL_VARIANT_POOLS[material_id]
		assert(pool.size() == 4, "Each biome should expose four restrained wall-skin macros")
		var unique: Dictionary = {}
		for atlas_index: int in pool:
			assert(atlas_index >= 0 and atlas_index < 100, "Wall skins must address the ornate 10x10 bank")
			unique[atlas_index] = true
		assert(unique.size() == 4, "Wall pools should not contain duplicate weighting")
		var edge_color: Color = VISUAL_STYLE.wall_edge_color(material_id)
		edge_colors[edge_color.to_html(false)] = true
		for sample_index: int in range(32):
			var macro_cell := Vector2i(sample_index * 2, posmod(sample_index * 14, 86))
			var chosen := VISUAL_STYLE.wall_atlas_index(418418, macro_cell, material_id)
			assert(pool.has(chosen), "Wall selection must remain inside its reviewed biome pool")
	assert(edge_colors.size() == VISUAL_STYLE.MATERIAL_IRON + 1, "Every biome should have a distinct wall-edge color")

	var displacements: Dictionary = {}
	var previous := VISUAL_STYLE.boundary_displacement(418418, Vector2i(96, 0), true)
	for sample_y: int in range(1, 160):
		var boundary_cell := Vector2i(96, sample_y)
		var displacement := VISUAL_STYLE.boundary_displacement(418418, boundary_cell, true)
		assert(displacement >= -3 and displacement <= 3, "Biome boundary displacement must stay inside its three-cell budget")
		assert(displacement == VISUAL_STYLE.boundary_displacement(418418, boundary_cell, true), "Boundary displacement must be deterministic")
		assert(absi(displacement - previous) <= 2, "Neighboring boundary samples should remain spatially correlated")
		displacements[displacement] = true
		previous = displacement
	assert(displacements.size() >= 3, "A long biome border should not remain a straight region line")

	var saw_contamination := false
	var saw_quiet := false
	for sample_index: int in range(256):
		var cell := Vector2i(sample_index, posmod(sample_index * 19, 73))
		var contaminated := VISUAL_STYLE.boundary_contamination(418418, cell, VISUAL_STYLE.MATERIAL_HIVE, VISUAL_STYLE.MATERIAL_TUNNEL, sample_index % 4)
		saw_contamination = saw_contamination or contaminated
		saw_quiet = saw_quiet or not contaminated
		assert(contaminated == VISUAL_STYLE.boundary_contamination(418418, cell, VISUAL_STYLE.MATERIAL_HIVE, VISUAL_STYLE.MATERIAL_TUNNEL, sample_index % 4), "Border contamination must be deterministic")
	assert(saw_contamination and saw_quiet, "Border contamination should stay sparse rather than filling every edge cell")
	assert(not VISUAL_STYLE.boundary_contamination(418418, Vector2i(4, 4), VISUAL_STYLE.MATERIAL_HIVE, VISUAL_STYLE.MATERIAL_TUNNEL, 4), "Contamination must not escape the four-cell transition band")
	assert(not VISUAL_STYLE.boundary_contamination(418418, Vector2i(4, 4), VISUAL_STYLE.MATERIAL_HIVE, VISUAL_STYLE.MATERIAL_HIVE, 0), "A biome cannot contaminate itself")

	print("CRAWL_BRAWL_BIOME_TRANSITION_PROFILE_TEST_OK")
	quit(0)
