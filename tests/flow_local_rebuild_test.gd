extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BaseNetworkScript := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_flow_local_rebuild_test")


func _run_flow_local_rebuild_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()
	assert(run.base_flows.has(BaseNetworkScript.WEST_ID), "Full rebuild should seed all base flows")

	var west_cell: Vector2i = run.base_network.get_cell(BaseNetworkScript.WEST_ID)
	var west_region: Vector2i = run.grid.region_for_cell(west_cell)
	var carrier_target := Vector2i(48, 48)
	run.brood_carrier_flows[carrier_target] = run.flow
	var dirty_only := {west_region: true}
	run.flow_dirty_regions = dirty_only.duplicate()
	run.base_flow_rebuild_cooldown = 0.0
	run._rebuild_base_flows(false, false, true)

	assert(run.base_flows.has(BaseNetworkScript.COMMAND_ID), "Partial rebuild should refresh command routing")
	assert(run.base_flows.has(BaseNetworkScript.WEST_ID), "Partial rebuild should refresh dirty-adjacent base flows")
	assert(run.brood_carrier_flows.has(carrier_target), "Partial rebuild must preserve brood carrier flow cache")

	run.flow_dirty_regions.clear()
	run.flow_dirty_regions[run.grid.region_for_cell(run.grid.core_cell)] = true
	run._rebuild_base_flows(false, false, true)
	assert(run.base_flows.has(BaseNetworkScript.NORTH_ID), "Untouched bases should remain after scoped partial rebuild")

	print("CRAWL_BRAWL_FLOW_LOCAL_REBUILD_TEST_OK")
	quit(0)
