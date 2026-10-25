extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const VISUAL_STYLE := preload("res://systems/realm_visual_style.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_realm_visual_test")


func _run_realm_visual_test() -> void:
	var cell := Vector2i(37, 22)
	var first_hash := VISUAL_STYLE.stable_cell_hash(418418, cell, 9)
	assert(first_hash == VISUAL_STYLE.stable_cell_hash(418418, cell, 9), "Visual dressing hashes must be deterministic")
	assert(first_hash != VISUAL_STYLE.stable_cell_hash(418419, cell, 9), "Realm seeds should produce different dressing layouts")
	for material_id: int in range(VISUAL_STYLE.MATERIAL_IRON + 1):
		var pool: Array = VISUAL_STYLE.base_variant_pool(material_id)
		assert(pool.size() == 12, "Each biome should expose one concise weighted base pool")
		var unique: Dictionary = {}
		for atlas_index: int in pool:
			assert(atlas_index >= 0 and atlas_index < 100, "Base pools must address valid 10x10 atlas macros")
			unique[atlas_index] = true
		assert(unique.size() == 6, "Each biome should use six reviewed quiet-base macros")
		var first_index := VISUAL_STYLE.base_atlas_index(418418, cell, material_id, 7)
		assert(first_index == VISUAL_STYLE.base_atlas_index(418418, cell, material_id, 7), "Base atlas selection must be deterministic")
		assert(unique.has(first_index), "Base atlas selection must stay inside the reviewed pool")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	await process_frame
	await process_frame
	var run = main.current_screen
	assert(run.cave_texture != null and run.hive_material != null and run.tunnel_material != null and run.bunker_material != null, "The realm should load every reused environment atlas")
	assert(run.crystal_material != null and run.foundry_material != null and run.sulfur_material != null and run.iron_material != null, "The realm should load every biome floor atlas")
	for material: Texture2D in [
		run.tunnel_material,
		run.hive_material,
		run.bunker_material,
		run.crystal_material,
		run.foundry_material,
		run.sulfur_material,
		run.iron_material,
		run.cave_texture,
	]:
		assert(material.get_width() % 32 == 0 and material.get_height() % 32 == 0, "Environment atlases should use 32px macro patches")
	assert(run.formation_materials.size() == VISUAL_STYLE.MATERIAL_IRON + 1, "Every biome should load a separate ornate formation atlas")
	for material_id: int in range(VISUAL_STYLE.MATERIAL_IRON + 1):
		var formation_texture: Texture2D = run.formation_materials.get(material_id)
		assert(formation_texture != null and formation_texture.get_size() == Vector2(320, 320), "Formation banks should retain the 10x10 authored macro contract")

	var player_cell: Vector2i = run.grid.world_to_cell(run.player_position)
	var player_region: Vector2i = run.grid.region_for_cell(player_cell)
	run.visual_prop_cache.erase(player_region)
	run.visual_formation_cache.erase(player_region)
	run.visual_landmark_cache.erase(player_region)
	for _settle in range(8):
		run._visual_formations_for_region(player_region)
		run._visual_props_for_region(player_region)
		if run.visual_prop_cache.has(player_region):
			break
		await process_frame
	assert(run.visual_prop_cache.has(player_region), "Player-region dressing should settle into cache")
	var initial_props: Array = run._visual_props_for_region(player_region).duplicate(true)
	assert(not initial_props.is_empty() and initial_props.size() < 100, "Active-region dressing should be present but restrained")
	run.visual_prop_cache.erase(player_region)
	assert(initial_props == run._visual_props_for_region(player_region), "Regenerated region dressing should remain identical")

	var formation_record_count := 0
	for region_value: Variant in run.grid.loaded_regions.keys():
		var region: Vector2i = region_value
		if run.grid.region_readiness(region) < WORLD_GRID.RegionReadiness.PREPARED:
			continue
		var first_formations: Dictionary = run._visual_formations_for_region(region).duplicate(true)
		if not run.visual_formation_cache.has(region):
			continue
		run.visual_formation_cache.erase(region)
		var regenerated_formations: Dictionary = run._visual_formations_for_region(region)
		assert(run.visual_formation_cache.has(region), "Prepared formation budgets should settle into cache")
		assert(first_formations == regenerated_formations, "Regenerated biome formations should remain deterministic")
		formation_record_count += regenerated_formations.size()
		for formation_value: Variant in regenerated_formations.values():
			var formation: Dictionary = formation_value
			var material_id := int(formation["material_id"])
			assert(VISUAL_STYLE.FORMATION_VARIANT_POOLS[material_id].has(int(formation["atlas_index"])), "Runtime formations must stay inside their reviewed ornate pool")
			assert(float(formation["strength"]) >= 0.46 and float(formation["strength"]) <= 0.65, "Formation overlays should remain subordinate to gameplay")
	assert(formation_record_count > 0, "The active region window should contain at least one meso-scale formation")

	for region_value: Variant in run.grid.loaded_regions.keys():
		var region: Vector2i = region_value
		if run.grid.region_readiness(region) < WORLD_GRID.RegionReadiness.PREPARED:
			continue
		var first_landmarks: Array = run._visual_landmarks_for_region(region).duplicate(true)
		if not run.visual_landmark_cache.has(region):
			continue
		run.visual_landmark_cache.erase(region)
		var regenerated_landmarks: Array = run._visual_landmarks_for_region(region)
		assert(first_landmarks == regenerated_landmarks, "Regenerated landmark compositions should remain deterministic")
		var landmark_anchors: Dictionary = {}
		for landmark_value: Variant in regenerated_landmarks:
			var landmark: Dictionary = landmark_value
			landmark_anchors[landmark["landmark_anchor"]] = true
			assert(bool(landmark["landmark"]), "Landmark props must retain authored-group identity")
			assert(landmark.has("material_id") and landmark.has("offset"), "Landmark props must carry biome lighting and sub-cell placement data")
		assert(landmark_anchors.size() <= 2, "No streamed region should exceed the landmark budget")

	var saw_visual_boundary_override := false
	for region_value: Variant in run.grid.region_biomes.keys():
		var region: Vector2i = region_value
		for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
			var neighbor_region := region + direction
			if not run.grid.region_biomes.has(neighbor_region):
				continue
			if run.grid.region_biome(region) == run.grid.region_biome(neighbor_region):
				continue
			var region_start: Vector2i = region * int(run.grid.REGION_SIZE)
			for tangent: int in range(4, run.grid.REGION_SIZE - 4):
				for normal_offset: int in range(-3, 4):
					var probe := Vector2i(region_start.x + run.grid.REGION_SIZE + normal_offset, region_start.y + tangent)
					if direction == Vector2i.DOWN:
						probe = Vector2i(region_start.x + tangent, region_start.y + run.grid.REGION_SIZE + normal_offset)
					if not run.grid.in_bounds(probe):
						continue
					var logical_biome: int = int(run.grid.region_biome(run.grid.region_for_cell(probe)))
					if run._visual_biome_for_cell(probe) != logical_biome:
						saw_visual_boundary_override = true
						break
				if saw_visual_boundary_override:
					break
			if saw_visual_boundary_override:
				break
		if saw_visual_boundary_override:
			break
	assert(saw_visual_boundary_override, "At least one logical biome border should receive a displaced or contaminated visual cell")

	var saw_biome_wall := false
	for region_value: Variant in run.grid.loaded_regions.keys():
		var region: Vector2i = region_value
		var region_start: Vector2i = region * int(run.grid.REGION_SIZE)
		var region_end: Vector2i = region_start + Vector2i.ONE * int(run.grid.REGION_SIZE)
		for y: int in range(maxi(0, region_start.y), mini(run.grid.height, region_end.y)):
			for x: int in range(maxi(0, region_start.x), mini(run.grid.width, region_end.x)):
				var probe := Vector2i(x, y)
				if run.grid.get_cell(probe) != run.grid.ROCK or not run._has_floor_neighbor(probe):
					continue
				var wall_material_id: int = int(run._wall_material_id_for_cell(probe))
				assert(wall_material_id >= VISUAL_STYLE.MATERIAL_TUNNEL and wall_material_id <= VISUAL_STYLE.MATERIAL_IRON, "Exposed rock should inherit a valid adjacent biome wall identity")
				saw_biome_wall = true
				break
			if saw_biome_wall:
				break
		if saw_biome_wall:
			break
	assert(saw_biome_wall, "The active region window should expose at least one biome-aware wall")

	var distant_cell := Vector2i(5, 5)
	run.grid.activate_region_window([distant_cell], 1)
	run._prune_visual_prop_cache()
	assert(not run.visual_prop_cache.has(player_region), "Visual caches should drop regions outside the active window")
	assert(not run.visual_formation_cache.has(player_region), "Formation caches should drop regions outside the active window")
	assert(not run.visual_landmark_cache.has(player_region), "Landmark caches should drop regions outside the active window")
	assert(not run.visual_biome_cache.has(player_region), "Visual boundary caches should drop regions outside the active window")

	print("CRAWL_BRAWL_REALM_VISUAL_TEST_OK")
	quit(0)
