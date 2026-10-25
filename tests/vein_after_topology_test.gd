extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")

const TEST_SEEDS: Array[int] = [90909, 80808, 70707]


func _initialize() -> void:
	call_deferred("_run_vein_after_topology_test")


func _visible_leads(grid: WORLD_GRID) -> int:
	var leads := 0
	for cell_value: Variant in grid.mineral_cells.keys():
		var cell: Vector2i = cell_value
		if not grid.concealed_minerals.has(cell):
			leads += 1
	return leads


func _run_vein_after_topology_test() -> void:
	for seed: int in TEST_SEEDS:
		var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
		grid.generate_realm(seed, "bastion", false)
		grid.configure_discoveries(seed, "bastion")
		for region_y in range(2, grid._region_rows() - 2):
			for region_x in range(2, grid._region_columns() - 2):
				grid.populate_region_exploration(Vector2i(region_x, region_y))
		assert(_visible_leads(grid) > 0, "Materialized regions should expose at least one visible vein lead for seed %d" % seed)
	print("CRAWL_BRAWL_VEIN_AFTER_TOPOLOGY_TEST_OK")
	quit(0)
