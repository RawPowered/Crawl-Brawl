extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")


func _initialize() -> void:
	call_deferred("_run_torch_phase1_test")


func _run_torch_phase1_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	assert(RUN_SCRIPT.BUILD_TORCH in run._available_build_types(), "Torch Mk1 should be selectable whenever its baseline blueprint is available")

	run.scrap = 120
	run._purchase_supply(7)
	assert(run.kit_count(RUN_SCRIPT.TORCH_STOCK_ID) >= 1 and run.scrap == 90, "A Torch Kit should cost its contract price and enter stack inventory")
	run.set_kit_stock(RUN_SCRIPT.TORCH_STOCK_ID, 4)
	run.selected_build = RUN_SCRIPT.BUILD_TORCH
	var placed_cells: Array[Vector2i] = []
	for y in range(run.grid.height):
		for x in range(run.grid.width):
			var candidate := Vector2i(x, y)
			run.player_position = run.grid.cell_to_world(candidate)
			if run._can_place_structure(candidate):
				run._place_structure(candidate)
				placed_cells.append(candidate)
				if placed_cells.size() == 4:
					break
		if placed_cells.size() == 4:
			break
	assert(placed_cells.size() == 4, "Torch placement should not be limited by the old 3-deploy network cap")
	assert(run._torch_deployed_count() == 4, "Four torches should remain deployed when inventory allows")
	for structure: RUN_SCRIPT.Structure in run.structures:
		if structure.kind == RUN_SCRIPT.BUILD_TORCH:
			assert(is_equal_approx(structure.max_health, RUN_SCRIPT.TORCH_DURABILITY[1]), "Torch Mk1 should use its authored durability")
	var torch: RUN_SCRIPT.Structure
	for structure: RUN_SCRIPT.Structure in run.structures:
		if structure.kind == RUN_SCRIPT.BUILD_TORCH:
			torch = structure
			break
	var saboteur: RUN_SCRIPT.Spider = RUN_SCRIPT.Spider.new()
	saboteur.role = RUN_SCRIPT.ROLE_SWARM
	saboteur.position = torch.position
	run.enemies.append(saboteur)
	assert(run._torch_contact_count(torch) == 1 and run._torch_reveals_position(saboteur.position), "A Torch should reveal nearby hostile contacts")
	assert(run._minimap_enemy_visible(saboteur), "A Torch-revealed hostile should be shown on the minimap")
	assert(run._torch_target_for(saboteur) == run.structures.find(torch), "A normal hostile in local sabotage range should choose the Torch")
	run._update_structures(0.1)
	assert("TORCH CONTACT" in run.discovery_alert, "Torch contact should publish a paced tactical alert")
	var broodling: RUN_SCRIPT.Spider = RUN_SCRIPT.Spider.new()
	broodling.role = RUN_SCRIPT.ROLE_BROODLING
	broodling.position = torch.position
	assert(run._torch_target_for(broodling) < 0, "Broodlings should retain swarm routing instead of dogpiling ward targets")
	var calibration_torch: RUN_SCRIPT.Structure = run.structures[run._next_lantern_upgrade_index()]
	run.scrap = 100
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 1
	run.material_economy.refined[MATERIAL_ECONOMY.CRYSTAL_CORE] = 1
	run._prepare_lantern_upgrade()
	assert(run.lantern_upgrade_target_cell == calibration_torch.cell and run.scrap == 10, "Foundry calibration should charge the authored Mk2 materials and bind one Torch target")
	run._apply_prepared_lantern_upgrade(calibration_torch)
	assert(calibration_torch.level == 2 and calibration_torch.lantern_color_id == 1 and is_equal_approx(calibration_torch.max_health, RUN_SCRIPT.TORCH_DURABILITY[2]), "Applying a prepared calibration should create the cyan Lantern Mk2 with its new durability")

	print("CRAWL_BRAWL_TORCH_PHASE1_TEST_OK")
	quit(0)
