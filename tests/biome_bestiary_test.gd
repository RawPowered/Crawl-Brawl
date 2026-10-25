extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const BIOME_BESTIARY := preload("res://systems/biome_bestiary.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const ARCHETYPE_SIZES: Array[Vector2i] = [
	Vector2i(22, 21),
	Vector2i(27, 21),
	Vector2i(24, 24),
	Vector2i(40, 32),
]


func _initialize() -> void:
	call_deferred("_run_biome_bestiary_test")


func _run_biome_bestiary_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	assert(BIOME_BESTIARY.archetype_for_role(run.ROLE_SWARM) == BIOME_BESTIARY.ARCHETYPE_SKIRMISHER)
	assert(BIOME_BESTIARY.archetype_for_role(run.ROLE_LEAPER) == BIOME_BESTIARY.ARCHETYPE_STRIKER)
	assert(BIOME_BESTIARY.archetype_for_role(run.ROLE_SPITTER) == BIOME_BESTIARY.ARCHETYPE_ARTILLERY)
	assert(BIOME_BESTIARY.archetype_for_role(run.ROLE_BRUTE) == BIOME_BESTIARY.ARCHETYPE_BULWARK)

	for biome_id: int in range(BIOME_BESTIARY.BIOME_SLUGS.size()):
		for archetype: int in range(BIOME_BESTIARY.ARCHETYPE_COUNT):
			var resource_path := BIOME_BESTIARY.texture_path(biome_id, archetype)
			var texture: Texture2D = run.biome_mob_textures.get(resource_path)
			assert(texture != null and texture.get_width() > 0, "Biome mob texture should load: %s" % resource_path)
			_assert_clean_sprite(texture, ARCHETYPE_SIZES[archetype], resource_path)
			assert(not BIOME_BESTIARY.display_name(biome_id, archetype).is_empty(), "Biome mob display name should exist")

	_assert_clean_sprite(run.mob_textures.get(run.ROLE_BROODLING), Vector2i(13, 11), "broodling")
	_assert_clean_sprite(run.world_textures.get("brood_carrier"), Vector2i(24, 20), "brood carrier")
	_assert_clean_sprite(run.mob_textures.get(run.ROLE_GUARDIAN), Vector2i(58, 54), "guardian")

	run._spawn_spider(false)
	assert(run.enemies.size() > 0, "Spawned enemy should exist")
	var spider: RUN_SCRIPT.Spider = run.enemies[run.enemies.size() - 1]
	assert(spider.biome_id >= WORLD_GRID.BIOME_TUNNEL, "Spawned enemy should resolve a biome id")
	var mob_texture: Texture2D = run._mob_texture_for_spider(spider)
	assert(mob_texture != null, "Biome-aware mob texture should resolve for wave spawn")
	var spawn_biome_id: int = spider.biome_id
	var spawn_trait_id: String = run._spider_trait_id(spider)
	var expected_path := BIOME_BESTIARY.texture_path_for_role(spawn_biome_id, spider.role)
	var expected_texture: Texture2D = run.biome_mob_textures.get(expected_path)
	for region_value: Variant in run.grid.region_biomes.keys():
		var region: Vector2i = region_value
		if run.grid.region_biome(region) == spawn_biome_id:
			continue
		spider.position = run.grid.cell_to_world(region * int(run.grid.REGION_SIZE) + Vector2i.ONE * 2)
		break
	assert(spider.biome_id == spawn_biome_id, "Crossing a biome border must not rewrite spawn-biome identity")
	assert(run._mob_texture_for_spider(spider) == expected_texture, "A traveling hostile must retain its spawn-biome sprite")
	assert(run._spider_trait_id(spider) == spawn_trait_id, "A traveling hostile must retain its spawn-biome trait")

	run.enemies.clear()
	run._clear_bullets()
	var prism_spitter := RUN_SCRIPT.Spider.new()
	prism_spitter.role = run.ROLE_SPITTER
	prism_spitter.biome_id = WORLD_GRID.BIOME_CRYSTAL
	prism_spitter.position = run.player_position + Vector2(80.0, 0.0)
	prism_spitter.health = 40.0
	prism_spitter.max_health = 40.0
	prism_spitter.speed = 1.0
	prism_spitter.radius = 5.0
	prism_spitter.hunts_player = true
	prism_spitter.spit_cooldown = 0.0
	run.enemies.append(prism_spitter)
	run.encounter_load_grace = 0.0
	run._update_enemies(0.01)
	assert(not run.bullets.is_empty(), "Biome artillery should emit its profiled projectile")
	var prism_round: RUN_SCRIPT.Bullet = run.bullets.back()
	assert(prism_round.enemy_round and prism_round.source_biome_id == WORLD_GRID.BIOME_CRYSTAL, "Enemy projectiles should retain their source ecology")
	assert(prism_round.damage_type == BIOME_BESTIARY.DAMAGE_ARC, "Crystal artillery should fire arc damage")
	var pressure := run._combat_pressure_level()
	var level := BIOME_BESTIARY.projectile_level_for_pressure(pressure)
	var ecology: Dictionary = BIOME_BESTIARY.trait_profile(WORLD_GRID.BIOME_CRYSTAL)
	var combat: Dictionary = BIOME_BESTIARY.projectile_combat_profile(BIOME_BESTIARY.DAMAGE_ARC, level, ecology)
	assert(is_equal_approx(prism_round.velocity.length(), 86.0 * float(combat["speed_scale"])), "Crystal prism shot should apply type×L×ecology speed")
	assert(is_equal_approx(prism_round.damage, float(combat["damage"])), "Crystal prism shot should bake type×L damage at spawn")
	assert(prism_round.color.is_equal_approx(Color("82e9ff")), "Biome projectile tint should preserve a common silhouette while identifying its ecology")
	assert(prism_round.projectile_level == level, "Projectile level should match combat pressure band")

	print("CRAWL_BRAWL_BIOME_BESTIARY_TEST_OK")
	quit(0)


func _assert_clean_sprite(texture: Texture2D, expected_size: Vector2i, label: String) -> void:
	assert(texture != null, "Sprite should load: %s" % label)
	assert(
		texture.get_width() == expected_size.x and texture.get_height() == expected_size.y,
		"Sprite %s should be %dx%d, got %dx%d" % [
			label,
			expected_size.x,
			expected_size.y,
			texture.get_width(),
			texture.get_height(),
		]
	)
	var image := texture.get_image()
	assert(image != null and not image.is_empty(), "Sprite should decode: %s" % label)
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
	assert(coverage >= 0.04 and coverage <= 0.82, "Sprite %s has suspicious alpha coverage: %.1f%%" % [label, coverage * 100.0])
	assert(border_visible == 0, "Sprite %s should have a transparent one-pixel border" % label)
