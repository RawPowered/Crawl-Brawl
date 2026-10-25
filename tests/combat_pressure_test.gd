extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const CombatSpatialScript := preload("res://systems/combat_spatial.gd")
const BaseNetworkScript := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_combat_pressure_test")


func _run_combat_pressure_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.grid.open_cell(run.grid.tutorial_rock)
	run.breached = true
	var materialized_before: int = run.grid.materialized_region_count()
	run._start_wave()
	assert(
		run.grid.materialized_region_count() - materialized_before < 12,
		"Wave start must defer bulk spawn-route materialization during combat pressure"
	)
	run._rebuild_base_flows()

	run.enemies.clear()
	run._spawn_spider(false)
	var spider = run.enemies.back()
	CombatSpatialScript.rebuild_enemy_buckets(run._enemy_spatial_buckets, run.enemies)
	var nearby: Array[int] = CombatSpatialScript.collect_enemy_indices(run._enemy_spatial_buckets, spider.position, 1)
	assert(nearby.has(0), "Spatial buckets should index nearby enemies for bullet queries")

	run.sparks.clear()
	for spark_index in range(500):
		run._burst(run.player_position, Color.WHITE, 1, 10.0)
	assert(run.sparks.size() <= run.MAX_SPARKS, "Spark budget must cap particle count under siege load")

	run.enemies.clear()
	# Exercise the high-population throttle at the awareness tier that actually
	# authorizes that population under the open-world director.
	run.hive_awareness.awareness_points = 92
	run.hive_awareness.awareness_tier = 8
	for spawn_index in range(120):
		run._spawn_spider(spawn_index % 3 == 0)
	assert(run.enemies.size() >= 80, "Pressure setup should reach combat-throttle enemy counts")
	run._rebuild_base_flows()
	assert(run.base_flows.has(BaseNetworkScript.WEST_ID), "Full rebuild should seed frontier flows")
	run.flow_dirty_regions[run.grid.region_for_cell(run.player_position)] = true
	run.base_flow_rebuild_cooldown = 0.0
	run._rebuild_base_flows(false, false)
	assert(run.base_flows.has(BaseNetworkScript.WEST_ID), "Partial combat rebuild should retain untouched frontier flows")
	assert(run.base_flows.has(BaseNetworkScript.COMMAND_ID), "Partial combat rebuild should refresh command routing")

	run.enemies.clear()
	run._spawn_spider(false)
	var nearby_spider = run.enemies.back()
	nearby_spider.counts_for_wave = true
	nearby_spider.position = run.player_position + Vector2(120.0, 0.0)
	var first_count: int = run._ensure_wave_pressure_count()
	var cached_count: int = run._ensure_wave_pressure_count()
	assert(first_count == cached_count, "Pressure counter should cache within the same combat frame")

	run.enemies.clear()
	run._spawn_spider(false)
	var distant_spider = run.enemies.back()
	distant_spider.counts_for_wave = true
	distant_spider.is_explorer = true
	distant_spider.position = run.player_position + Vector2(run.WAVE_RELOCATE_PLAYER_SAFE_RADIUS + 120.0, 0.0)
	run._invalidate_wave_pressure_count()
	assert(run._ensure_wave_pressure_count() == 0, "Distant stragglers without siege routes should not block local spawn pressure")

	print("CRAWL_BRAWL_COMBAT_PRESSURE_TEST_OK")
	quit(0)
