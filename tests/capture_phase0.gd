extends SceneTree

const CrawlBrawlRunScript := preload("res://scripts/phase0_run.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await RenderingServer.frame_post_draw
	var menu_image := root.get_texture().get_image()
	var menu_error := menu_image.save_png("res://artifacts/patch414_main_menu.png")
	if menu_error != OK:
		push_error("Menu screenshot save failed: %s" % error_string(menu_error))
	main.start_run()
	await process_frame
	var run: CrawlBrawlRunScript = main.current_screen

	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()
	run.breached = true
	run.wave = 8
	run.wave_active = true
	run.spawns_remaining = 0
	run.scrap = 230
	run.unlocked_player_styles[2] = true
	run.player_style_id = 2
	var frontier_id: String = BASE_NETWORK.NORTH_ID
	run.base_network.bases[frontier_id]["revealed"] = true
	run.base_network.mark_guardian_cleared(frontier_id)
	run.base_network.begin_activation(frontier_id)
	run.base_network.tick_activation(BASE_NETWORK.ACTIVATION_DURATION)
	run._rebuild_base_flows()
	var frontier_cell: Vector2i = run.base_network.get_cell(frontier_id)
	run.player_position = run.grid.cell_to_world(frontier_cell + Vector2i(-2, 0))
	run.player_camera.position = run.player_position
	run.selected_build = 1
	run._place_structure(frontier_cell + Vector2i(-4, -2))
	run._place_structure(frontier_cell + Vector2i(-4, 2))
	run.selected_build = 0
	run._place_structure(frontier_cell + Vector2i(-5, 0))

	for spider_index in range(17):
		run._spawn_spider(spider_index == 0)
		var x: int = frontier_cell.x - 18 + spider_index
		if x > frontier_cell.x - 6:
			x = frontier_cell.x - 6 - (spider_index % 4)
		run.enemies[spider_index].position = run.grid.cell_to_world(Vector2i(x, frontier_cell.y - 1 + spider_index % 3))
		run.enemies[spider_index].target_base_id = frontier_id
		if spider_index < 4:
			run.enemies[spider_index].hunts_turrets = true
			run.enemies[spider_index].target_turret_cell = run.structures[0].cell
	for brood_index in range(4):
		run._spawn_broodling(frontier_cell + Vector2i(-8, 2), brood_index)
		run.enemies.back().position = run.grid.cell_to_world(frontier_cell + Vector2i(-9 - brood_index, 3))
	run.structures[0].health = run.structures[0].max_health * 0.28

	run.aim_direction = Vector2.LEFT
	run.player_moving = true
	run.player_move_direction = Vector2.LEFT
	run.sprinting = true
	run.sprint_energy = 58.0
	run.locomotion_phase = 1.4
	run.player_hit_time = 0.12
	run.player_hit_recoil = Vector2(3.0, -1.0)
	run.damage_flash = 0.16
	run.current_weapon = 2
	run.shoot_cooldown = 0.0
	run.laser_active = true
	run.laser_visual_phase = 1.35
	run.laser_end = run.grid.cell_to_world(frontier_cell + Vector2i(-12, 0))
	run.mine_target = frontier_cell + Vector2i(-3, -3)
	run.mine_progress = 0.31
	run.mining_feedback_time = 0.09
	run.mining_beam_valid = true
	run.mining_beam_end = run.grid.cell_to_world(run.mine_target) - run.aim_direction * 7.0
	run.mining_impact_pulse = 0.18
	run.mining_impact_position = run.grid.cell_to_world(run.mine_target)
	run._spawn_supply_cache_pickups(run.player_position + Vector2(-38, 24))
	Input.action_press("mine")
	run._spawn_bullet(run.grid.cell_to_world(frontier_cell + Vector2i(-15, -1)), Vector2.RIGHT, 11.0, false, true, 3.0, 0.0, Color("a4e85b"), 2.4)
	run._burst(run.grid.cell_to_world(frontier_cell + Vector2i(-6, 0)), Color("ffd56a"), 18, 60.0)
	var guardian_cell := frontier_cell + Vector2i(-10, 2)
	run.grid.revealed_discoveries[guardian_cell] = "guardian"
	run.grid.open_discovery_chamber(guardian_cell, 2)
	run._spawn_guardian(guardian_cell)
	run.paused = true

	for frame in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var error := image.save_png("res://artifacts/patch414_player_gameplay.png")
	Input.action_release("mine")

	run.enemies.clear()
	run.wave_active = false
	run.current_base_id = frontier_id
	run.scrap = 4875
	run.material_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 12)
	run.material_economy.add_raw(MATERIAL_ECONOMY.SILVER_ORE, 7)
	run.material_economy.add_raw(MATERIAL_ECONOMY.GOLD_ORE, 4)
	run.material_economy.add_raw(MATERIAL_ECONOMY.ENERGY_CRYSTAL, 5)
	run.material_economy.add_raw(MATERIAL_ECONOMY.ROUGH_DIAMOND, 2)
	run.material_economy.add_raw(MATERIAL_ECONOMY.GRANITE, 8)
	run.material_economy.add_raw(MATERIAL_ECONOMY.BASALT, 6)
	run.material_economy.add_raw(MATERIAL_ECONOMY.IRON_ORE, 4)
	run.material_economy.add_raw(MATERIAL_ECONOMY.TITANIUM_ORE, 2)
	run.material_economy.add_raw(MATERIAL_ECONOMY.QUARTZ, 4)
	run.material_economy.add_raw(MATERIAL_ECONOMY.SULFUR, 4)
	run.material_economy.add_raw(MATERIAL_ECONOMY.COAL, 8)
	run.material_economy.foundry_tier = 1
	run.backpack_tier = 4
	run._open_core_base()
	run._set_core_menu_page("materials")
	await process_frame
	await RenderingServer.frame_post_draw
	var materials_error := root.get_texture().get_image().save_png("res://artifacts/patch414_materials_catalog.png")

	run._set_core_menu_page("armory")
	await process_frame
	await RenderingServer.frame_post_draw
	var armory_error := root.get_texture().get_image().save_png("res://artifacts/patch414_armory_catalog.png")

	run._set_core_menu_page("supplies")
	await process_frame
	await RenderingServer.frame_post_draw
	var supplies_error := root.get_texture().get_image().save_png("res://artifacts/patch414_supplies_catalog.png")

	run._set_core_menu_page("mining")
	await process_frame
	await RenderingServer.frame_post_draw
	var mining_error := root.get_texture().get_image().save_png("res://artifacts/patch414_mining_catalog.png")

	run.construction_unlocks["reinforced_barrier"] = true
	run.construction_unlocks["land_mine"] = true
	run._set_core_menu_page("construction")
	await process_frame
	await RenderingServer.frame_post_draw
	var construction_error := root.get_texture().get_image().save_png("res://artifacts/patch415_construction_catalog.png")

	run._set_core_menu_page("style")
	await process_frame
	await RenderingServer.frame_post_draw
	var style_error := root.get_texture().get_image().save_png("res://artifacts/patch414_style_catalog.png")
	run._close_core_base()
	run._open_backpack()
	await process_frame
	await RenderingServer.frame_post_draw
	var backpack_error := root.get_texture().get_image().save_png("res://artifacts/patch4151_field_backpack.png")
	run._close_backpack()
	run._open_core_base()

	run._set_core_menu_page("defenses")
	run.scrap = maxi(run.scrap, 500)
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = maxi(1, int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]))
	run._purchase_turret_upgrade()
	await process_frame
	await RenderingServer.frame_post_draw
	var selection_error := root.get_texture().get_image().save_png("res://artifacts/patch4151_turret_selection.png")
	var all_ok := menu_error == OK and error == OK and materials_error == OK and armory_error == OK and supplies_error == OK and mining_error == OK and construction_error == OK and style_error == OK and backpack_error == OK and selection_error == OK
	if all_ok:
		print("CRAWL_BRAWL_PATCH4151_FIELD_INVENTORY_TURRET_FIX_CAPTURE_OK")
	else:
		push_error("Patch 4.15.1 screenshot capture failed")
	quit(0 if all_ok else 1)
