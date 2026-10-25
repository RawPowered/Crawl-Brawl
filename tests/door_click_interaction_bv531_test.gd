extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_door_click_interaction_test")


func _find_two_cell_floor(run: RUN_SCRIPT) -> Vector2i:
	var center: Vector2i = run.grid.world_to_cell(run.player_position)
	for radius in [12, 24, 40]:
		for y in range(center.y - radius, center.y + radius + 1):
			for x in range(center.x - radius, center.x + radius):
				var cell := Vector2i(x, y)
				if run.grid.is_walkable(cell) and run.grid.is_walkable(cell + Vector2i.RIGHT):
					return cell
	return Vector2i(-1, -1)


func _run_door_click_interaction_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen

	var door_cell := _find_two_cell_floor(run)
	assert(door_cell.x >= 0, "Fixture needs two adjacent walkable cells")
	run.structures.clear()
	run._invalidate_structure_spatial_buckets()
	run._rebuild_enemy_blocker_cache()

	var door := RUN_SCRIPT.Structure.new()
	door.kind = RUN_SCRIPT.BUILD_HEAVY_DOORWAY
	door.cell = door_cell
	door.position = run.grid.cell_to_world(door_cell)
	door.size = Vector2i(2, 1)
	door.health = 800.0
	door.max_health = 800.0
	door.is_open = false
	run.structures.append(door)
	run._invalidate_structure_spatial_buckets()
	run._mark_flow_dirty_for_structure(door)

	run.player_position = door.position + Vector2(0, 20)
	var click_world := run._doorway_interaction_rect(door).get_center()
	assert(run._doorway_index_at_world_position(click_world) == 0, "Door footprint should resolve as a clickable world target")
	assert(run._has_nearby_world_click_target(), "Nearby doorway should make the world cursor available")
	assert("DOOR" in str(run._hud_interaction_state().get("text", "")), "Door proximity should expose a CLICK/F interaction prompt")
	assert(run._cell_blocks_enemy(door.cell), "Closed doorway should block enemies before clicking")

	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = run.get_viewport().get_canvas_transform() * click_world
	run._unhandled_input(click)
	assert(door.is_open, "Left-clicking a nearby doorway should open it immediately")
	assert(run.suppress_primary_fire_until_release, "Door click must consume the primary-fire press")
	assert(not run._cell_blocks_enemy(door.cell), "Opening by click must refresh enemy blockers immediately")

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	run._input(release)
	run._unhandled_input(click)
	assert(not door.is_open, "Clicking the doorway again should close it")
	assert(run._cell_blocks_enemy(door.cell), "Closing by click must restore enemy blocking immediately")

	run.player_position = door.position + Vector2(160, 0)
	assert(run._try_handle_world_interaction_click(click_world), "A recognized far doorway click should be consumed instead of firing the weapon")
	assert(not door.is_open, "Out-of-range clicks must not toggle the doorway")
	assert("MOVE CLOSER" in run.discovery_alert, "Out-of-range doorway clicks should explain the range requirement")

	print("CRAWL_BRAWL_DOOR_CLICK_INTERACTION_TEST_OK")
	quit(0)
