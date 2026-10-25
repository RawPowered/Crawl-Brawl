extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run_region_density_playability_test")


func _run_region_density_playability_test() -> void:
	var grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	grid.generate_realm(424242, "bastion", false)
	for region_y in range(2, grid._region_rows() - 2, 2):
		for region_x in range(2, grid._region_columns() - 2, 2):
			var region := Vector2i(region_x, region_y)
			if grid._is_landmark_region(region):
				continue
			grid.populate_region_exploration(region)
			var bounds := grid._region_bounds(region)
			var walkable := grid._count_region_walkable(region)
			var area := bounds.size.x * bounds.size.y
			assert(walkable >= WORLD_GRID.REGION_MIN_WALKABLE, "Authored region should meet minimum walkable density")
			assert(float(walkable) / float(maxi(1, area)) <= WORLD_GRID.REGION_MAX_FLOOR_RATIO + 0.05, "Authored region floor ratio should stay bounded")
	print("CRAWL_BRAWL_REGION_DENSITY_PLAYABILITY_TEST_OK")
	quit(0)
