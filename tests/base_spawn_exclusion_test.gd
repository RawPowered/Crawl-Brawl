extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WAVE_DIRECTOR := preload("res://systems/wave_director.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	var core_cell: Vector2i = run.grid.core_cell
	var core_radius: int = run.base_network.territory_radius(BASE_NETWORK.COMMAND_ID)
	assert(run._spider_spawn_excluded(run.grid.cell_to_world(core_cell)), "Command Core center must reject hostile spawning")
	assert(run._spider_spawn_excluded(run.grid.cell_to_world(core_cell + Vector2i(core_radius + 1, 0))), "Core spawn padding should cover the notable power-radius edge")

	var hut := RUN_SCRIPT.Structure.new()
	hut.kind = RUN_SCRIPT.BUILD_PERSONAL_BASE
	hut.cell = core_cell + Vector2i(core_radius + 6, 0)
	hut.position = run.grid.cell_to_world(hut.cell)
	hut.size = Vector2i(3, 2)
	hut.health = 360.0
	hut.max_health = 360.0
	run.structures.append(hut)
	var hut_center: Vector2 = run.grid.cell_to_world(hut.cell) + Vector2(hut.size - Vector2i.ONE) * float(run.grid.tile_size) * 0.5
	assert(run._spider_spawn_excluded(hut_center), "Personal Base footprint must reject hostile spawning")
	assert(run._spider_spawn_excluded(hut_center + Vector2(7.5 * run.grid.tile_size, 0)), "Personal Base exclusion must cover its full notable radius")

	var enemy_count: int = run.enemies.size()
	assert(not run._spawn_broodling(hut.cell, 0, false) and run.enemies.size() == enemy_count, "Broodlings must not spawn inside a Personal Base radius")
	assert(not run._spawn_guardian(core_cell) and run.enemies.size() == enemy_count, "Guardians must not spawn inside an active Core radius")
	var nest := RUN_SCRIPT.BroodNest.new()
	nest.cell = hut.cell
	assert(not run._spawn_nest_boss(nest), "Nest bosses must remain suppressed inside a Personal Base radius")

	run.encounters_completed = 4
	run.current_wave_plan = WAVE_DIRECTOR.build_encounter_plan("bastion", 1, 0, 4, run.grid.spawn_cells.size())
	assert(run._spawn_spider(false), "Normal hunting-party spawning should find prepared ground outside protected radii")
	assert(not run._spider_spawn_excluded(run.enemies.back().position), "A normal spider must materialize outside every Core and Personal Base exclusion")
	print("CRAWL_BRAWL_BASE_SPAWN_EXCLUSION_TEST_OK")
	quit(0)
