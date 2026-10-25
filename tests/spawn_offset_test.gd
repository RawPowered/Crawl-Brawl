extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_spawn_offset_test")


func _run_spawn_offset_test() -> void:
	var grid := WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(135791, "bastion")
	var breach: Vector2i = grid.core_cell + Vector2i.LEFT * WORLD_GRID.START_CHAMBER_WALL_RADIUS
	grid.establish_first_breach(breach)
	var spawn_at := grid.spawn_cell
	var axis := Vector2(grid.core_cell - spawn_at).normalized()
	var center := grid.cell_to_world(spawn_at)
	var straight_count := 0
	for sequence in range(12):
		var pos := grid.offset_spawn_position(spawn_at, sequence)
		var offset := pos - center
		if offset.length() < 4.0:
			straight_count += 1
			continue
		var axis_alignment := absf(offset.normalized().dot(axis))
		assert(axis_alignment < 0.92, "Wave spawns should flank the tunnel axis instead of stacking straight ahead")
	assert(straight_count < 4, "Most wave spawns should pick a lateral offset")

	print("CRAWL_BRAWL_SPAWN_OFFSET_TEST_OK")
	quit(0)
