extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_nest_placement_test")


func _run_nest_placement_test() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(424242, "bastion")
	grid.configure_discoveries(424242, "bastion")
	grid.materialize_all_discoveries_for_tests()
	var span := grid.realm_span()
	var nest_min := span * WORLD_GRID.DISCOVERY_NEST_MIN_CORE_RATIO
	var nest_spacing := span * WORLD_GRID.DISCOVERY_NEST_SPACING_RATIO
	var nest_cells: Array[Vector2i] = []
	for cell_value: Variant in grid.discovery_cells.keys():
		var cell: Vector2i = cell_value
		if str(grid.discovery_cells[cell]) == "nest":
			nest_cells.append(cell)
	assert(nest_cells.size() == 3, "Bastion should still seed exactly three discovery nests")
	for nest_cell: Vector2i in nest_cells:
		assert(nest_cell.distance_to(grid.core_cell) >= nest_min * 0.82, "Seeded nests should sit in the outer realm band away from Command")
	for left_index in range(nest_cells.size()):
		for right_index in range(left_index + 1, nest_cells.size()):
			assert(nest_cells[left_index].distance_to(nest_cells[right_index]) >= nest_spacing * 0.82, "Seeded nests should keep breathing room between each other")

	print("CRAWL_BRAWL_NEST_PLACEMENT_TEST_OK")
	quit(0)
