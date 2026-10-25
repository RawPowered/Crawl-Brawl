extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const FLOW_FIELD := preload("res://systems/flow_field.gd")


func _initialize() -> void:
	call_deferred("_run_flow_field_test")


func _run_flow_field_test() -> void:
	var grid := WORLD_GRID.new(12, 8, 16)
	for x in range(grid.width):
		for y in range(grid.height):
			grid.set_cell(Vector2i(x, y), WORLD_GRID.FLOOR)
	grid.set_cell(Vector2i(5, 2), WORLD_GRID.ROCK)
	grid.set_cell(Vector2i(5, 3), WORLD_GRID.ROCK)
	grid.set_cell(Vector2i(5, 4), WORLD_GRID.ROCK)

	var flow := FLOW_FIELD.new()
	var target := Vector2i(10, 3)
	flow.rebuild(grid, target)
	var fork := Vector2i(2, 3)
	assert(flow.has_path(fork), "Flow field should reach fork cells")
	var first := flow.next_cell(fork)
	var second := flow.next_cell(fork)
	assert(first == second, "Flow steps should be deterministic at equal-cost forks")
	assert(first != fork, "Flow field should advance toward the target")

	# Escape: when the only downhill neighbor is blocked, take sideways/uphill instead of self.
	var blocked_flow := FLOW_FIELD.new()
	blocked_flow.rebuild(grid, target)
	var trapped := Vector2i(4, 3)
	assert(blocked_flow.has_path(trapped), "Escape probe cell should be on the field")
	var downhill := blocked_flow.best_passable_next(trapped, Callable())
	assert(downhill != trapped, "Unblocked field should still step downhill")
	var wall_block := func(cell: Vector2i) -> bool:
		return cell == downhill
	var escaped := blocked_flow.best_passable_next(trapped, wall_block)
	assert(escaped != trapped and escaped != downhill, "Blocked downhill should escape sideways/uphill, not foot-aim")
	var ranked: Array = blocked_flow.ranked_passable_neighbors(trapped, wall_block)
	assert(not ranked.is_empty() and ranked[0] == escaped, "Ranked neighbors should prefer the escape step")

	print("CRAWL_BRAWL_FLOW_FIELD_TEST_OK")
	quit(0)
