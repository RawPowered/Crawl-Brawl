extends SceneTree

const VISUAL_STYLE := preload("res://systems/realm_visual_style.gd")


func _initialize() -> void:
	call_deferred("_run_biome_formation_profile_test")


func _run_biome_formation_profile_test() -> void:
	assert(VISUAL_STYLE.FORMATION_STAMPS.size() == 8, "Phase 2 should expose eight irregular formation silhouettes")
	for stamp_value: Variant in VISUAL_STYLE.FORMATION_STAMPS:
		var stamp: Array = stamp_value
		assert(stamp.size() >= 5 and stamp.size() <= 10, "Formation stamps should stay at meso scale")
		assert(stamp.has(Vector2i.ZERO), "Every formation stamp needs a stable anchor")
		var min_cell := Vector2i(999, 999)
		var max_cell := Vector2i(-999, -999)
		for offset: Vector2i in stamp:
			min_cell = Vector2i(mini(min_cell.x, offset.x), mini(min_cell.y, offset.y))
			max_cell = Vector2i(maxi(max_cell.x, offset.x), maxi(max_cell.y, offset.y))
		var bounds_area := (max_cell.x - min_cell.x + 1) * (max_cell.y - min_cell.y + 1)
		assert(stamp.size() < bounds_area, "Formation silhouettes must not be filled rectangles")

	var saw_quiet_region := false
	var saw_standard_region := false
	var saw_dense_region := false
	for material_id: int in range(VISUAL_STYLE.MATERIAL_IRON + 1):
		var pool: Array = VISUAL_STYLE.FORMATION_VARIANT_POOLS[material_id]
		assert(pool.size() == 8, "Every biome should expose eight reviewed formation macros")
		var unique: Dictionary = {}
		for atlas_index: int in pool:
			assert(atlas_index >= 0 and atlas_index < 100, "Formation macros must address the 10x10 ornate bank")
			unique[atlas_index] = true
		assert(unique.size() == 8, "Formation pools should not hide duplicate weighting")
		for region_index: int in range(64):
			var region := Vector2i(region_index % 8, region_index / 8)
			var count := VISUAL_STYLE.formation_count_for_region(418418, region, material_id)
			saw_quiet_region = saw_quiet_region or count == 0
			saw_standard_region = saw_standard_region or count == 2
			saw_dense_region = saw_dense_region or count == 3
			var anchor := region * 24 + Vector2i(8, 8)
			var atlas_index := VISUAL_STYLE.formation_atlas_index(418418, anchor, material_id, region_index)
			assert(pool.has(atlas_index), "Formation selection must stay inside its reviewed biome pool")
	assert(saw_quiet_region and saw_standard_region and saw_dense_region, "Seeded budgets should produce quiet, standard, and dense regions")

	var adjacent_difference := 0.0
	var distant_difference := 0.0
	for sample_index: int in range(96):
		var cell := Vector2i(sample_index * 3, posmod(sample_index * 17, 211))
		var center := VISUAL_STYLE.formation_field(418418, cell, VISUAL_STYLE.MATERIAL_CRYSTAL)
		adjacent_difference += absf(center - VISUAL_STYLE.formation_field(418418, cell + Vector2i.RIGHT, VISUAL_STYLE.MATERIAL_CRYSTAL))
		distant_difference += absf(center - VISUAL_STYLE.formation_field(418418, cell + Vector2i(36, 36), VISUAL_STYLE.MATERIAL_CRYSTAL))
	assert(adjacent_difference < distant_difference, "Formation fields should correlate neighbors more strongly than distant cells")

	print("CRAWL_BRAWL_BIOME_FORMATION_PROFILE_TEST_OK")
	quit(0)
