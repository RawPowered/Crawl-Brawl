extends SceneTree

const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run = RUN_SCRIPT.new()
	run.run_seed = 515151
	run.grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	run.grid.generate_realm(run.run_seed, "bastion")
	run.grid.configure_discoveries(run.run_seed, "bastion")
	run.grid.materialize_all_discoveries_for_tests()
	run.base_network = BASE_NETWORK.new()
	run.base_network.configure(run.grid.core_cell, run.grid.width, run.grid.height, run.grid.frontier_sites)
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run._rebuild_base_flows()

	var nest_cell := Vector2i(-1, -1)
	for cell_value: Variant in run.grid.discovery_cells.keys():
		var candidate: Vector2i = cell_value
		if str(run.grid.discovery_cells[candidate]) == "nest":
			nest_cell = candidate
			break
	assert(nest_cell.x >= 0, "The seeded realm should provide a brood-base site")
	run._establish_brood_nest(nest_cell, 1.0)
	assert(run.brood_nests.size() == 1 and run.brood_nests[0].max_health >= run.BROOD_NEST_HEALTH, "A brood base should expose durable health")
	run.player_position = run.grid.cell_to_world(run._brood_nest_approach(nest_cell))
	run._update_brood_nests(0.1)
	assert(run.brood_nests[0].aggressive and run.brood_nests[0].boss_spawned, "Approaching a brood base should wake its defenses and Alpha")
	assert(run.enemies.any(func(spider) -> bool: return spider.brood_nest_cell == nest_cell), "The awakened base should own a persistent boss defender")

	run._damage_brood_nest(0, 999999.0, false)
	assert(run.brood_escalation == 1, "Destroying a brood base should permanently raise brood pressure")
	assert(not run.brood_nests.is_empty() and run.brood_nests[0].cell.distance_to(nest_cell) >= 24.0, "The stronger replacement base should relocate far from the destroyed site")
	assert(run.brood_nests[0].max_health > run.BROOD_NEST_HEALTH, "The relocated brood base should return stronger")

	run.free()
	print("CRAWL_BRAWL_BROOD_BASE_ESCALATION_TEST_OK")
	quit(0)
