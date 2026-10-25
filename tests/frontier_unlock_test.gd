extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_frontier_unlock_test")


func _run_frontier_unlock_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	var site_id := BASE_NETWORK.NORTH_ID
	run.base_network.bases[site_id]["revealed"] = true
	run.base_network.mark_guardian_cleared(site_id)
	run.wave = 0 # historical field must not gate construction
	run.wave_active = true
	for sector_index in range(4):
		run.explored_sectors[Vector2i(sector_index, 0)] = true
	run.scrap = 1200
	run.player_position = run.grid.cell_to_world(run.base_network.get_cell(site_id))

	assert(run.base_network.can_construct_open_world(site_id, run.explored_sectors.size(), run._enemies_blocking_construction(site_id)), "Frontier unlock should depend on exploration + guardian clearance, not encounter history")
	run._interact_with_base(site_id)
	assert(run.base_network.get_status(site_id) == BASE_NETWORK.STATUS_ACTIVATING, "Paying $1000 should begin the activation timer even while a hunting party is being delivered")

	run.base_network.tick_activation(BASE_NETWORK.ACTIVATION_DURATION)
	assert(run.base_network.get_status(site_id) == BASE_NETWORK.STATUS_ACTIVE, "Completing activation should bring the regional core online")

	run.realm_save_cooldown = 0.0
	run._open_realm_archive()
	assert(run.using_realm_archive, "Archive should open at an active frontier core")
	run._try_commit_realm_save_at_archive()
	assert(run.checkpoint_base_id == site_id, "Saving at a frontier core should anchor respawns to that base")
	assert(run.checkpoint_position.is_equal_approx(run._checkpoint_anchor_position(site_id)), "Continue loads should spawn at the last saved base anchor")

	print("CRAWL_BRAWL_FRONTIER_UNLOCK_TEST_OK")
	quit(0)
