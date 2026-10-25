extends SceneTree

const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run = RUN_SCRIPT.new()
	run.grid = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	var positive := run._map_coordinate_text(Vector2i(1284, 337))
	assert("+001284" in positive and "+000337" in positive, "The tactical map should show signed global cell coordinates")
	assert("+0053" in positive and "+0014" in positive, "The tactical map should show the matching signed region coordinates")
	var negative := run._map_coordinate_text(Vector2i(-1, -25))
	assert("-000001" in negative and "-000025" in negative, "The coordinate UI must preserve negative global cells")
	assert("-0001" in negative and "-0002" in negative, "Negative cells must use floor-divided region coordinates")
	run.free()
	print("CRAWL_BRAWL_MAP_COORDINATE_UIX_TEST_OK")
	quit(0)
