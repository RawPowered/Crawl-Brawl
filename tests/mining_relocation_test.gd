extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_mining_relocation_test")


func _run_mining_relocation_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	var cells := _find_relocation_pair(run)
	assert(cells.size() == 2, "Test realm should expose adjacent relocation cells")
	var source: Vector2i = cells[0]
	var destination: Vector2i = cells[1]
	var sentry := RUN_SCRIPT.Structure.new()
	sentry.kind = RUN_SCRIPT.BUILD_SENTRY
	sentry.cell = source
	sentry.position = run.grid.cell_to_world(source)
	sentry.health = 37.0
	sentry.max_health = 72.0
	sentry.level = 3
	sentry.cooldown = 0.42
	run.structures.append(sentry)
	run.player_position = run.grid.cell_to_world(source) + Vector2(0, 16)

	run.mining_speed_tier = 1
	run.mining_emitter_tier = 1
	assert(not run._begin_structure_relocation(0), "MK1 mining gun must not relocate structures")
	run.mining_speed_tier = 2
	assert(run._begin_structure_relocation(0), "Either mining track reaching MK2 should enable relocation")
	assert(not run._place_relocated_structure(Vector2i(-1, -1)), "Invalid relocation must be rejected")
	assert(sentry.cell == source and is_equal_approx(sentry.health, 37.0), "Rejected relocation must leave source and condition unchanged")
	assert(run._place_relocated_structure(destination), "Valid relocation should place the acquired turret")
	assert(sentry.cell == destination and sentry.position == run.grid.cell_to_world(destination), "Relocation should move the existing structure")
	assert(sentry.level == 3 and is_equal_approx(sentry.health, 37.0) and is_equal_approx(sentry.cooldown, 0.42), "Relocation should preserve tier, health, and live turret state")
	assert(run.relocating_structure_index == -1, "Successful placement should clear relocation state")

	var chest := RUN_SCRIPT.Structure.new()
	chest.kind = RUN_SCRIPT.BUILD_CHEST_SMALL
	chest.cell = source
	chest.position = run.grid.cell_to_world(source)
	run.structures.append(chest)
	assert(not run._begin_structure_relocation(1), "Mining relocation should exclude storage and production structures")

	print("CRAWL_BRAWL_MINING_RELOCATION_TEST_OK")
	quit(0)


func _find_relocation_pair(run: RUN_SCRIPT) -> Array[Vector2i]:
	for y: int in range(2, run.grid.height - 2):
		for x: int in range(2, run.grid.width - 3):
			var source := Vector2i(x, y)
			var destination := source + Vector2i.RIGHT
			if not run.grid.is_walkable(source) or not run.grid.is_walkable(destination):
				continue
			var safe := true
			for candidate: Vector2i in [source, destination]:
				for base_id: String in run.base_network.bases.keys():
					if candidate.distance_to(run.base_network.get_cell(base_id)) < 2.0:
						safe = false
				if candidate in run.grid.spawn_cells or run._brood_nest_index_at_cell(candidate) >= 0:
					safe = false
			if safe:
				return [source, destination]
	return []
