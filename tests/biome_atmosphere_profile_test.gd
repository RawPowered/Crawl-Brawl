extends SceneTree

const VISUAL_STYLE := preload("res://systems/realm_visual_style.gd")


func _initialize() -> void:
	var mote_colors: Dictionary = {}
	var light_colors: Dictionary = {}
	var grade_colors: Dictionary = {}
	var valid_props := {
		VISUAL_STYLE.PROP_LAMP: true,
		VISUAL_STYLE.PROP_CRATE: true,
		VISUAL_STYLE.PROP_RUBBLE: true,
		VISUAL_STYLE.PROP_WEB: true,
		VISUAL_STYLE.PROP_EGGS: true,
		VISUAL_STYLE.PROP_ACID: true,
		VISUAL_STYLE.PROP_GRATE: true,
		VISUAL_STYLE.PROP_CONDUIT: true,
		VISUAL_STYLE.PROP_CRYSTAL_SHARD: true,
		VISUAL_STYLE.PROP_SULFUR_VENT: true,
		VISUAL_STYLE.PROP_SLAG_HEAP: true,
	}
	for material_id: int in range(VISUAL_STYLE.MATERIAL_IRON + 1):
		var density := VISUAL_STYLE.mote_density(material_id)
		assert(density >= 20 and density <= 120, "Biome motes must remain low density")
		mote_colors[VISUAL_STYLE.mote_color(material_id).to_html(false)] = true
		light_colors[VISUAL_STYLE.biome_light_color(material_id).to_html(false)] = true
		grade_colors[VISUAL_STYLE.ambient_grade_color(material_id).to_html(false)] = true
		var compositions: Array = VISUAL_STYLE.LANDMARK_COMPOSITIONS[material_id]
		assert(compositions.size() == 2, "Every biome must expose two authored landmark silhouettes")
		for composition_value: Variant in compositions:
			var composition: Array = composition_value
			assert(composition.size() >= 3 and composition.size() <= 4, "Landmarks should read as concise multi-prop groups")
			for component_value: Variant in composition:
				var component: Dictionary = component_value
				assert(valid_props.has(int(component["kind"])), "Landmarks may only use supported runtime props")
				var cell_offset: Vector2i = component["cell_offset"]
				var pixel_offset: Vector2 = component["pixel_offset"]
				assert(maxi(absi(cell_offset.x), absi(cell_offset.y)) <= 1, "Landmark footprints must remain locally bounded")
				assert(maxf(absf(pixel_offset.x), absf(pixel_offset.y)) <= 4.0, "Prop offsets must not obscure navigation ownership")
	assert(mote_colors.size() == 7, "All seven biome mote palettes should be visibly distinct")
	assert(light_colors.size() == 7, "All seven biome light palettes should be visibly distinct")
	assert(grade_colors.size() == 7, "All seven biome ambient grades should be visibly distinct")

	var saw_counts := {0: false, 1: false, 2: false}
	for material_id: int in range(VISUAL_STYLE.MATERIAL_IRON + 1):
		for region_x: int in range(-64, 65):
			var region := Vector2i(region_x, material_id * 13 - 41)
			var count := VISUAL_STYLE.landmark_count_for_region(418418, region, material_id)
			assert(count >= 0 and count <= 2, "A region may contain at most two hero landmarks")
			assert(count == VISUAL_STYLE.landmark_count_for_region(418418, region, material_id), "Landmark budgets must be deterministic")
			saw_counts[count] = true
	assert(bool(saw_counts[0]) and bool(saw_counts[1]) and bool(saw_counts[2]), "Seeded landmark budgets should exercise quiet, single, and rare double placements")

	print("CRAWL_BRAWL_BIOME_ATMOSPHERE_PROFILE_TEST_OK")
	quit(0)
