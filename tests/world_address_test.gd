extends SceneTree

const WORLD_ADDRESS := preload("res://systems/world_address.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var cases: Array[Dictionary] = [
		{"cell": 0, "region": 0, "local": 0},
		{"cell": 23, "region": 0, "local": 23},
		{"cell": 24, "region": 1, "local": 0},
		{"cell": -1, "region": -1, "local": 23},
		{"cell": -24, "region": -1, "local": 0},
		{"cell": -25, "region": -2, "local": 23},
	]
	for record: Dictionary in cases:
		assert(WORLD_ADDRESS.floor_div(record["cell"], 24) == record["region"], "Signed region division must floor across the origin")
		assert(WORLD_ADDRESS.floor_mod(record["cell"], 24) == record["local"], "Signed local cells must remain inside the region")

	var extreme := 9_223_372_036_000_000
	var split := WORLD_ADDRESS.split_cell(extreme, -extreme)
	var rebuilt := WORLD_ADDRESS.compose_cell(split["region_x"], split["region_y"], split["local_x"], split["local_y"])
	assert(rebuilt["x"] == extreme and rebuilt["y"] == -extreme, "World addressing must remain exact far beyond 32-bit Vector2i range")
	print("CRAWL_BRAWL_WORLD_ADDRESS_TEST_OK")
	quit(0)
