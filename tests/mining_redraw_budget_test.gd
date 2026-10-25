extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_mining_redraw_budget_test")


func _run_mining_redraw_budget_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run: RUN_SCRIPT = main.current_screen
	await process_frame

	for index in range(40):
		run.terrain_chunk_redraw_queue[Vector2i(index - 20, 0)] = true
	assert(
		run.terrain_chunk_redraw_queue.size() >= 40,
		"Fixture should seed a large terrain redraw backlog"
	)

	var target_cell := run.grid.world_to_cell(run.player_position) + Vector2i(8, 0)
	run.mine_target = target_cell
	run.mining_beam_valid = true
	run.mining_beam_end = run.grid.cell_to_world(target_cell)
	run._refresh_mining_beam_regions()
	run.terrain_chunk_redraw_queue[run.grid.region_for_cell(target_cell)] = true

	var before := run.terrain_chunk_redraw_queue.size()
	run._flush_mining_terrain_chunks()
	var flushed := before - run.terrain_chunk_redraw_queue.size()
	assert(
		flushed <= RUN_SCRIPT.MINING_TERRAIN_REDRAW_BUDGET,
		"Mining flush must respect the per-frame redraw budget"
	)
	assert(
		flushed >= 1,
		"Mining flush should redraw at least the beam-adjacent queued region"
	)

	for index in range(50):
		run.terrain_chunk_redraw_queue[Vector2i(index, 1)] = true
	run._prune_terrain_redraw_queue()
	assert(
		run.terrain_chunk_redraw_queue.size() <= RUN_SCRIPT.MAX_TERRAIN_REDRAW_QUEUE,
		"Redraw queue must stay capped after pruning"
	)

	print("CRAWL_BRAWL_MINING_REDRAW_BUDGET_TEST_OK")
	quit(0)
