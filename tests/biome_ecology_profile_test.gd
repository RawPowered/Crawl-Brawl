extends SceneTree

const BESTIARY := preload("res://systems/biome_bestiary.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	var unique_weights: Dictionary = {}
	var unique_traits: Dictionary = {}
	var distributions: Dictionary = {}
	for biome_id: int in range(BESTIARY.BIOME_SLUGS.size()):
		var weights: Array = BESTIARY.role_weights(biome_id)
		assert(weights.size() == BESTIARY.ARCHETYPE_COUNT, "Every biome needs four role weights")
		var total := 0
		for weight_value: Variant in weights:
			var weight := int(weight_value)
			assert(weight >= 4 and weight <= 70, "Role weights must preserve mixed encounters")
			total += weight
		assert(total == 100, "Biome role weights should be direct percentages")
		unique_weights[str(weights)] = true

		var ecology: Dictionary = BESTIARY.trait_profile(biome_id)
		var trait_id := BESTIARY.trait_id(biome_id)
		assert(not trait_id.is_empty() and not unique_traits.has(trait_id), "Each biome needs one unique secondary trait")
		unique_traits[trait_id] = true
		assert(float(ecology.get("home_speed_scale", 1.0)) <= 1.12, "Home-ground traits must remain restrained")
		assert(float(ecology.get("structure_damage_scale", 1.0)) <= 1.15, "Sapper damage must remain restrained")
		assert(float(ecology.get("knockback_scale", 1.0)) >= 0.50, "Mass traits must not remove knockback entirely")

		var counts := [0, 0, 0, 0]
		for sequence: int in range(1200):
			var role := BESTIARY.role_for_spawn("bastion", 12, sequence, biome_id, BESTIARY.ARCHETYPE_SKIRMISHER)
			assert(role == BESTIARY.role_for_spawn("bastion", 12, sequence, biome_id, BESTIARY.ARCHETYPE_SKIRMISHER), "Biome composition must be deterministic")
			counts[role] += 1
		distributions[biome_id] = counts
		for count: int in counts:
			assert(count > 0, "Every mature biome composition should retain all four combat silhouettes")

	assert(unique_weights.size() == 7 and unique_traits.size() == 7, "All seven biomes need distinct composition and trait identities")
	assert(int(distributions[WORLD_GRID.BIOME_HIVE][0]) > int(distributions[WORLD_GRID.BIOME_BUNKER][0]), "Hive waves should emphasize skirmishers")
	assert(int(distributions[WORLD_GRID.BIOME_CRYSTAL][1]) > int(distributions[WORLD_GRID.BIOME_TUNNEL][1]), "Crystal waves should emphasize strikers")
	assert(int(distributions[WORLD_GRID.BIOME_SULFUR][2]) > int(distributions[WORLD_GRID.BIOME_HIVE][2]), "Sulfur waves should emphasize artillery")
	assert(int(distributions[WORLD_GRID.BIOME_IRON][3]) > int(distributions[WORLD_GRID.BIOME_HIVE][3]), "Iron waves should emphasize bulwarks")

	for biome_id: int in range(BESTIARY.BIOME_SLUGS.size()):
		assert(BESTIARY.role_for_spawn("bastion", 1, 99, biome_id, BESTIARY.ARCHETYPE_SKIRMISHER) == BESTIARY.ARCHETYPE_SKIRMISHER, "Wave-one ecology must remain readable and skirmisher-only")
		assert(BESTIARY.role_for_spawn("bastion", 12, 99, biome_id, BESTIARY.ARCHETYPE_STRIKER) == BESTIARY.ARCHETYPE_STRIKER, "Director striker beats must survive biome weighting")
		assert(BESTIARY.role_for_spawn("bastion", 12, 99, biome_id, BESTIARY.ARCHETYPE_ARTILLERY) == BESTIARY.ARCHETYPE_ARTILLERY, "Director artillery beats must survive biome weighting")

	var crystal_shot: Dictionary = BESTIARY.spitter_profile(WORLD_GRID.BIOME_CRYSTAL)
	var sulfur_shot: Dictionary = BESTIARY.spitter_profile(WORLD_GRID.BIOME_SULFUR)
	assert(is_equal_approx(float(crystal_shot["speed_scale"]), 1.12), "Crystal artillery should use its restrained prism-shot speed")
	assert(is_equal_approx(float(sulfur_shot["life_scale"]), 1.18) and is_equal_approx(float(sulfur_shot["range_scale"]), 1.14), "Sulfur artillery should use its restrained toxic reach")

	print("CRAWL_BRAWL_BIOME_ECOLOGY_PROFILE_TEST_OK")
	quit(0)
