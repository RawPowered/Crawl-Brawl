extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const FLOW_FIELD := preload("res://systems/flow_field.gd")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const HARNESS := preload("res://tests/test_harness.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	HARNESS.reset()
	var starts: Dictionary = {}
	# 1047514/2274959/3890435/1554330 previously left the chamber with a
	# deferred topology cross-link corridor punched through a "sealed" wall
	# before the player ever reached it (see world_grid.gd _purge_deferred_specs_in_bounds).
	for seed: int in [1103, 2207, 3319, 4421, 1047514, 2274959, 3890435, 1554330]:
		var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
		grid.generate_realm(seed, "bastion")
		starts[grid.core_cell] = true
		HARNESS.require(grid.is_walkable(grid.core_cell), "The randomized Core must be inside its carved chamber")
		HARNESS.require(grid.is_start_chamber_wall(grid.tutorial_rock), "tutorial_rock remains the default hive seal position")
	HARNESS.require(starts.size() > 1, "Different seeds should not reuse one fixed Core location")

	var breach_grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	breach_grid.generate_realm(987654, "bastion")
	var breach: Vector2i = breach_grid.core_cell + Vector2i.RIGHT * WORLD_GRID.START_CHAMBER_WALL_RADIUS
	HARNESS.require(breach_grid.can_mine(breach) or breach_grid.is_walkable(breach), "Chosen starter wall cell must exist")
	if breach_grid.can_mine(breach):
		HARNESS.require(breach_grid.open_cell(breach), "The selected starter wall should mine normally")
	HARNESS.require(breach_grid.establish_first_breach(breach) == Vector2i.RIGHT, "The opening should define the swarm direction")
	HARNESS.require(breach_grid.spawn_cell.distance_to(breach_grid.core_cell) >= WORLD_GRID.START_CHAMBER_WALL_RADIUS + WORLD_GRID.INITIAL_HIVE_OFFSET - 1, "The first spawn must sit well beyond the Command Core")
	HARNESS.require(breach_grid.spawn_cell.x > breach_grid.core_cell.x, "The first spawn must sit beyond the chosen wall")
	var flow = FLOW_FIELD.new()
	flow.rebuild(breach_grid, breach_grid.core_cell)
	HARNESS.require(flow.has_path(breach_grid.spawn_cell), "The first swarm tunnel must connect its spawn to the Core")

	var run = RUN_SCRIPT.new()
	run.grid = breach_grid
	run.run_seed = 987654
	run.player_position = breach_grid.cell_to_world(breach_grid.core_cell)
	var frontier_site: Vector2i = breach_grid.frontier_sites["crystal"]
	var activation_spawn: Vector2i = run._activation_spawn_cell(frontier_site, 0)
	HARNESS.require(activation_spawn.distance_to(frontier_site) >= 14.0, "Frontier defense attackers must spawn beyond the new base doorstep")
	run.free()

	_assert_non_wall_mine_unlock()
	_assert_spider_kill_unlock()
	_assert_hud_scrap_tip_survives_kill()

	HARNESS.finish(self, "CRAWL_BRAWL_RANDOM_START_BREACH_TEST_OK")


func _assert_non_wall_mine_unlock() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(424242, "bastion")
	var run = RUN_SCRIPT.new()
	run.grid = grid
	run.player_position = grid.cell_to_world(grid.core_cell)
	HARNESS.require(not run.breached, "Boot must begin unbreached")
	HARNESS.require(not run.first_mine_earned, "Boot must begin without a scrap mine")
	var outer_rock: Vector2i = _find_non_chamber_rock(grid)
	HARNESS.require(outer_rock != Vector2i(-1, -1), "Test needs a non-chamber rock near the start reserve")
	var seal_before: Vector2i = grid.tutorial_rock
	HARNESS.require(grid.open_cell(outer_rock), "Non-chamber rock should mine")
	run.first_mine_earned = true
	run._register_first_contact(outer_rock)
	HARNESS.require(run.breached, "Mining any rock should register first contact")
	HARNESS.require(run.first_breach_cell == seal_before, "Non-wall unlock must persist the default seal, not the mined cell")
	HARNESS.require(grid.is_walkable(seal_before), "Default seal must be walkable after first contact")
	run.free()


func _assert_spider_kill_unlock() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(525252, "bastion")
	var run = RUN_SCRIPT.new()
	run.grid = grid
	run.player_position = grid.cell_to_world(grid.core_cell)
	var seal: Vector2i = grid.tutorial_rock
	HARNESS.require(grid.is_start_chamber_wall(seal), "Default seal must be a start-chamber wall cell")
	var spider = RUN_SCRIPT.Spider.new()
	spider.role = RUN_SCRIPT.ROLE_BROODLING
	spider.position = run.player_position + Vector2(24, 0)
	spider.health = 1.0
	spider.max_health = 1.0
	run.enemies.append(spider)
	run._kill_spider(0)
	HARNESS.require(run.breached, "Killing a hostile should register first contact")
	HARNESS.require(run.first_breach_cell == seal, "Kill unlock must save the seal cell, never the kill cell")
	HARNESS.require(grid.is_walkable(seal), "Kill unlock must leave the hive seal walkable")
	HARNESS.require(not run.first_mine_earned, "Kill-first unlock must not clear the scrap mine tip flag")
	run.free()


func _assert_hud_scrap_tip_survives_kill() -> void:
	var run = RUN_SCRIPT.new()
	run.base_network = BASE_NETWORK.new()
	run.base_network.configure(Vector2i(32, 32), 64, 64)
	run.breached = true
	run.first_mine_earned = false
	var objective: Dictionary = run._hud_objective_state(0, 0)
	HARNESS.require(str(objective.get("text", "")).begins_with("MINE A WALL"), "Scrap tip must remain after kill-first unlock")
	run.first_mine_earned = true
	objective = run._hud_objective_state(0, 0)
	HARNESS.require(not str(objective.get("text", "")).begins_with("MINE A WALL"), "Scrap tip clears after first mine")
	run.free()


func _find_non_chamber_rock(grid) -> Vector2i:
	for offset: Vector2i in [
		Vector2i(-WORLD_GRID.START_CHAMBER_RESERVE_RADIUS - 2, 0),
		Vector2i(WORLD_GRID.START_CHAMBER_RESERVE_RADIUS + 2, 0),
		Vector2i(0, -WORLD_GRID.START_CHAMBER_RESERVE_RADIUS - 2),
		Vector2i(0, WORLD_GRID.START_CHAMBER_RESERVE_RADIUS + 2),
		Vector2i(-WORLD_GRID.START_CHAMBER_RESERVE_RADIUS - 3, 1),
		Vector2i(WORLD_GRID.START_CHAMBER_RESERVE_RADIUS + 3, -1),
	]:
		var candidate: Vector2i = grid.core_cell + offset
		if grid.can_mine(candidate) and not grid.is_start_chamber_wall(candidate):
			return candidate
	return Vector2i(-1, -1)
