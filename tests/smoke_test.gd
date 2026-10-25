extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")
const WAVE_DIRECTOR := preload("res://systems/wave_director.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const PROGRESSION_TREE := preload("res://systems/progression_tree.gd")
const UPGRADE_ECONOMY := preload("res://systems/upgrade_economy.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")
const MenuScreenScript := preload("res://scripts/menu_screen.gd")
const SplashScreenScript := preload("res://scripts/splash_screen.gd")
const CrawlBrawlRunScript := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run_smoke_test")


func _turret_los_probe(run: CrawlBrawlRunScript, sentry_position: Vector2, distance: float) -> Vector2:
	for direction: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		var candidate := sentry_position + direction * distance
		if run._clear_line_of_sight(candidate, sentry_position):
			return candidate
	assert(false, "Equipment hunter tests need a clear line-of-sight probe axis")
	return sentry_position


func _tunnel_material_probe(run: CrawlBrawlRunScript) -> Vector2i:
	var spine_y := int(floor(float(run.grid.height) / 2.0))
	var start_x := run.grid._scaled_layout(20)
	var end_x := run.grid.width - run.grid._scaled_layout(40)
	for x in range(start_x, end_x):
		var cell := Vector2i(x, spine_y)
		if run.grid.is_walkable(cell) and run._material_for_cell(cell) == run.tunnel_material:
			return cell
	for y in range(2, run.grid.height - 2):
		for x in range(start_x, end_x):
			var cell := Vector2i(x, y)
			if run.grid.is_walkable(cell) and run._material_for_cell(cell) == run.tunnel_material:
				return cell
	assert(false, "Smoke test needs at least one tunnel crust floor cell")
	return Vector2i.ZERO


func _structure_placement_cell_valid(run: CrawlBrawlRunScript, cell: Vector2i) -> bool:
	if run.grid.cell_to_world(cell).distance_to(run.player_position) > 96.0:
		return false
	for base_id: String in run.base_network.bases.keys():
		if cell.distance_to(run.base_network.get_cell(base_id)) < 2.0:
			return false
	return true


func _frontier_territory_cell(run: CrawlBrawlRunScript, base_id: String, preferred_offset: Vector2i) -> Vector2i:
	var base_cell := run.base_network.get_cell(base_id)
	var preferred := base_cell + preferred_offset
	if run.grid.is_walkable(preferred) and run.base_network.owns_cell(base_id, preferred) and _structure_placement_cell_valid(run, preferred):
		return preferred
	var territory_radius: int = run.base_network.territory_radius(base_id)
	for radius in range(1, territory_radius + 1):
		for dx in range(-radius, radius + 1):
			for dy in range(-radius, radius + 1):
				if maxi(absi(dx), absi(dy)) != radius:
					continue
				var cell := base_cell + Vector2i(dx, dy)
				if run.grid.is_walkable(cell) and run.base_network.owns_cell(base_id, cell) and _structure_placement_cell_valid(run, cell):
					return cell
	assert(false, "Frontier territory tests need a walkable powered cell")
	return base_cell


func _run_smoke_test() -> void:
	var main_scene: PackedScene = load("res://scenes/main.tscn")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame

	assert(main.current_screen is SplashScreenScript, "Project should boot into the studio splash")
	main.show_menu()
	await process_frame
	assert(main.current_screen is MenuScreenScript, "The splash should hand off to the start menu")
	var menu: MenuScreenScript = main.current_screen
	menu.set_selected_difficulty("onslaught")
	assert(menu.selected_difficulty_id == "onslaught", "Difficulty should be selectable before a run")
	main.start_run("onslaught")
	await process_frame
	var run: CrawlBrawlRunScript = main.current_screen
	assert(run != null, "Start action should create the Phase 0 run")
	assert(run.difficulty_id == "onslaught", "Selected difficulty should reach the run")
	assert(run.world_layer != null, "World rendering should have an independent layer")
	assert(run.actor_layer != null, "Actors should have an independent layer")
	assert(run.effects_layer != null, "Combat effects should have an independent layer")
	assert(run.lighting_layer != null, "Lighting and atmosphere should have an independent layer")
	assert(run.hud_draw != null, "HUD drawing should have an independent layer")
	assert(run.player_camera != null, "The expedition map should have a player-follow camera")
	assert(run.base_network != null, "Phase 4.5 should initialize a multi-Core defense network")
	assert(run.material_economy != null, "Patch 4.7 should initialize a raw and refined material economy")
	assert(run.base_network.bases.size() == 4, "The campaign should include one Command Core and three Frontier Sites")
	assert(run.grid.width == WORLD_GRID.REALM_WIDTH and run.grid.height == WORLD_GRID.REALM_HEIGHT, "Patch 5 should expand the realm to 512x288 while keeping legacy resource density")
	assert(run.grid.get_cell(run.grid.tutorial_rock) == WORLD_GRID.ROCK, "Tutorial rock should begin sealing the hive route")
	assert(run.grid.loaded_regions.size() > 0, "The realm should stream 24x24 regions around active entry points")
	assert(run.realm_id == REALM_SAVE.realm_id_for_seed(run.run_seed), "Every expedition should receive a stable realm identity")
	assert(run.grid.realm_traits.size() == 3, "The realm seed should expose geology, topology, and infestation traits")
	var sprint_start: Vector2 = run.player_position
	var sprint_energy_start: float = run.sprint_energy
	Input.action_press("move_left")
	Input.action_press("sprint")
	run._update_player(0.1)
	Input.action_release("sprint")
	Input.action_release("move_left")
	assert(run.sprinting and run.player_position.distance_to(sprint_start) > 10.0 and run.sprint_energy < sprint_energy_start, "Patch 4.13 sprint should accelerate traversal while consuming visible energy")
	run._update_player(1.0)
	run._update_player(1.0)
	assert(run.sprint_energy > sprint_energy_start - 3.0, "Sprint energy should recharge after its recovery delay")
	run.player_invulnerability = 0.0
	run._hurt_player(1.0, run.player_position + Vector2.RIGHT)
	assert(run.player_hit_time > 0.0 and run.player_hit_recoil.x < 0.0, "Player damage should trigger directional sprite recoil instead of only changing a number")
	run.player_invulnerability = 0.0
	var hud_canvas := run.get_node("HUDLayer") as CanvasLayer
	assert(hud_canvas != null, "HUD should be isolated in a CanvasLayer")
	assert(hud_canvas.layer > 0, "HUD must render above world lighting")
	assert(run.pause_panel.get_parent() == run.overlay_root, "Pause UI should live in the isolated HUD canvas")
	assert(run.core_base_scrap_label != null and run.core_base_network_label != null, "Phase 4.6 should separate funds and network condition in the Core Base UI")
	assert(run.core_tab_buttons.size() == run.SHOP_PAGES.size(), "Every configured Core terminal department should expose one navigation tab")
	assert(run.core_detail_title != null and run.core_detail_body != null and run.core_detail_state != null, "Patch 4.10 should give every shop item a dedicated effect and readiness panel")
	run._open_core_base()
	if run.core_menu_page != "armory":
		run._set_core_menu_page("armory")
	assert("PISTOL" in run.core_service_buttons[0].text and "RAILGUN" in run.core_service_buttons[4].text, "The Armory should expose every weapon as a specific comparable row")
	assert("CURRENT" in run.core_action_details[0] and "NEXT" in run.core_action_details[0], "Weapon rows should compare the current and next mark before purchase")
	assert("MAG" in run._weapon_stat_summary(0, 3) and run._weapon_mag_capacity(0, 4) > run._weapon_mag_capacity(0, 1), "Pistol marks should include a real capacity progression beyond generic damage")
	assert(run._weapon_shotgun_pellets(4) > run._weapon_shotgun_pellets(1), "Shotgun marks should add readable pellet progression")
	assert(run._weapon_laser_drain(4) < run._weapon_laser_drain(1), "Laser marks should improve capacitor efficiency")
	assert(run._weapon_smg_spread(4) < run._weapon_smg_spread(1), "SMG marks should improve accuracy")
	assert(run._weapon_railgun_pierce(4) > run._weapon_railgun_pierce(1), "Railgun marks should improve target penetration")
	run._set_core_menu_page("supplies")
	assert("PISTOL CARTRIDGES x60" in run.core_service_buttons[0].text and "SHOTGUN SHELLS x24" in run.core_service_buttons[1].text, "Supplies should expose exact ammunition quantities instead of one generic restock")
	assert(run.core_action_states[3].begins_with("LOCKED") and run.core_action_states[4].begins_with("LOCKED"), "Ammo for unresearched weapons should remain visibly locked")
	run._set_core_menu_page("mining")
	assert("CUTTER SPEED" in run.core_service_buttons[0].text and "EMITTER SIZE" in run.core_service_buttons[1].text, "Mining progression should separate cutting speed from emitter size")
	assert(run._mining_cycle_duration(4) < run._mining_cycle_duration(1), "Cutter upgrades should reduce mining cycle time")
	assert(run._mining_beam_reach(4) > run._mining_beam_reach(1) and run._mining_beam_width(4) > run._mining_beam_width(1), "Emitter upgrades should increase reach and visible beam size")
	var late_speed_req: Dictionary = run._mining_upgrade_requirements(true, 4)
	assert(int(late_speed_req.get(MATERIAL_ECONOMY.GOLD_INGOT, 0)) >= 2, "Late mining upgrades should require high-tier refined parts")
	var pre_purchase_scrap: int = run.scrap
	var pre_purchase_refined: Dictionary = run.material_economy.refined.duplicate()
	run.expedition_level = 4
	run.skill_points = 1
	run.skill_unlocks.append("automation")
	run._unlock_skill_node("excavation")
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 2
	run.material_economy.refined[MATERIAL_ECONOMY.CRYSTAL_CORE] = 1
	var mining_tier_before: int = run.mining_speed_tier
	run._purchase_mining_upgrade(true)
	assert(run.mining_speed_tier == mining_tier_before + 1 and run.scrap == pre_purchase_scrap, "A cutter purchase should install one tier and spend refined parts only")
	assert(int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 1 and int(run.material_economy.refined[MATERIAL_ECONOMY.CRYSTAL_CORE]) == 1, "The accessible MK2 cutter purchase should cost one bronze ingot")
	run.mining_speed_tier = mining_tier_before
	run.scrap = pre_purchase_scrap
	run.material_economy.refined = pre_purchase_refined
	run._set_core_menu_page("style")
	assert(run.core_action_states[0] == "EQUIPPED" and "FOUNDRY SUIT" in run.core_service_buttons[1].text, "Style should expose the equipped state and distinct unlockable survivor sprites")
	assert(run.player_textures.size() == 4 and run.player_direction_textures.size() == 16 and run.player_active_direction_textures.size() == 16 and run.shop_icons.size() == run.SHOP_ICON_NAMES.size(), "Every configured player frame and shop sprite should decode")
	assert(run.turret_textures.size() == 3, "Patch 4.15.1 should decode distinct runtime art for Sentry, Rocket Turret, and Laser Turret")
	for player_texture: Texture2D in run.player_textures:
		assert(player_texture != null and player_texture.get_width() == 28 and player_texture.get_height() == 30, "Every player style should resolve as a clean 28x30 alpha sprite")
	run.aim_direction = Vector2.UP
	assert(run._player_direction_name() == "up", "Vertical aim should select a real upward-facing survivor frame")
	run.aim_direction = Vector2.LEFT
	assert(run._player_direction_name() == "left", "Horizontal aim should select a real left-facing survivor frame")
	var left_tool_pose: Dictionary = run._player_tool_pose()
	var left_muzzle: Vector2 = run._player_muzzle_position()
	assert(left_tool_pose["texture"] != null and left_muzzle.distance_to(Vector2(left_tool_pose["mount"])) >= 8.5, "The weapon PNG and gameplay muzzle should share one mount transform")
	assert(left_muzzle.x < run.player_position.x - 5.0, "The resolved muzzle should sit at the visible left-facing gun barrel instead of the player's mid-body")
	assert(run.core_service_buttons[1].icon != null, "Style rows should display the actual survivor sprite")
	run._set_core_menu_page("materials")
	assert("SELL NOW" in run.core_service_buttons[4].text and "RAW INVENTORY" in run.core_service_buttons[5].text and "PROCESSED INVENTORY" in run.core_service_buttons[6].text, "Materials should support immediate raw sales while separating raw cargo from spendable processed stock")
	assert("PACK" in run.core_base_scrap_label.text and "CONTRACT" in run.core_base_scrap_label.text, "Materials should distinguish carried load from raw-cargo contract value")
	run._set_core_menu_page("construction")
	assert("GRANITE BARRIER" in run.core_service_buttons[run.CONSTRUCTION_ORDER.find("granite_barrier")].text and "ROCKET TURRET" in run.core_service_buttons[run.CONSTRUCTION_ORDER.find("rocket_turret")].text and "LASER TURRET" in run.core_service_buttons[run.CONSTRUCTION_ORDER.find("laser_turret")].text, "Construction should expose barriers, mines, Rocket Turrets, and Laser Turrets as exact research or fabrication rows")
	assert(run.shop_icons.get("rocket_turret") != null and run.shop_icons.get("laser_turret") != null and run.shop_icons.get("land_mine") != null and run.shop_icons.get("backpack") != null, "Advanced defenses and backpack progression should have packaged alpha sprites")
	run._set_core_menu_page("style")
	assert("BACKPACK" in run.core_service_buttons[5].text and "PACK LOAD" in run.core_service_buttons[6].text, "The Style department should expose backpack capacity and its next persistent upgrade")
	assert(run._backpack_capacity(4) == 260 and run._backpack_capacity(1) == 80, "Backpack progression should increase field capacity from 80 to 260")
	run._close_core_base()
	run._open_backpack()
	assert(run.backpack_open and run.backpack_panel.visible and "UNITS" in run.backpack_capacity_label.text and "FREE" in run.backpack_capacity_label.text, "I/Select should open a field backpack with live used-versus-capacity inventory")
	assert(run.backpack_slot_icons.size() > 0 and run.backpack_slot_icons.size() == run.backpack_slot_counts.size(), "The backpack should expose material, ammunition, and deployable inventory slots")
	run._close_backpack()
	assert(run.cave_texture != null, "Runtime PNG decoding should provide the cave texture")
	assert(run.hive_material != null, "Phase 2 should decode the hive material without an import cache")
	assert(run.tunnel_material != null, "Phase 2 should decode the tunnel material without an import cache")
	assert(run.bunker_material != null, "Phase 2 should decode the bunker material without an import cache")
	assert(run.mob_textures.size() == 6, "Patch 4.11 should decode one runtime sprite for every enemy role")
	assert(run.biome_mob_textures.size() == 28, "Each biome should expose four archetype runtime sprites")
	for role in [0, 1, 2, 3, 4, 5]:
		var mob_texture: Texture2D = run.mob_textures.get(role)
		assert(mob_texture != null and mob_texture.get_width() > 0 and mob_texture.get_height() > 0, "Every enemy role should resolve a non-empty clean-launch PNG")
	assert(run._mob_sprite_size(4).x < run._mob_sprite_size(0).x, "Broodling art should remain the smallest threat silhouette")
	assert(run._mob_sprite_size(5).x > run._mob_sprite_size(3).x, "Guardian art should carry the largest boss silhouette")
	run.laser_energy = 100.0
	run.laser_visual_phase = 0.0
	run._fire_laser(0.1)
	assert(run.laser_active and run.laser_visual_phase > 0.0, "Patch 4.13 Laser fire should drive a persistent high-energy visual phase")
	assert(run.laser_end.distance_to(run._player_muzzle_position()) <= 176.1, "Combat Laser range should be measured from the animated weapon muzzle")
	var macro_left: Rect2 = run._floor_texture_region(run.tunnel_material, Vector2i(20, 10), 43)
	var macro_right: Rect2 = run._floor_texture_region(run.tunnel_material, Vector2i(21, 10), 43)
	assert(macro_right.position.x - macro_left.position.x == 16.0 or macro_right.position == macro_left.position, "Floor atlases should preserve stable 16-pixel tile sampling")
	assert(macro_left.size == Vector2(16, 16), "Tile material sampling must preserve the collision-grid pixel scale")
	assert(run._material_for_cell(run.grid.spawn_cell) == run.hive_material, "The spawn chamber should use the hive visual language")
	assert(run._material_for_cell(_tunnel_material_probe(run)) == run.tunnel_material, "The approach should use the excavated tunnel material")
	assert(run._material_for_cell(run.grid.core_cell) == run.bunker_material, "Core Security should use the bunker material")
	assert(run.world_layer.draw_callback.is_valid(), "World layer should have a live draw callback")
	assert(run.hud_draw.draw_callback.is_valid(), "HUD layer should have a live draw callback")
	run.world_layer.visible = false
	assert(run.hud_draw.visible, "World rendering must be independently switchable without hiding the HUD")
	run.world_layer.visible = true
	assert(run.get_wave_spawn_count(1) == 18, "Onslaught Wave 1 should schedule 18 hostiles")
	assert(is_equal_approx(run.get_spawn_interval(1), 0.25), "Onslaught should spawn four hostiles per second")
	assert(run.get_wave_spawn_count(2) > run.get_wave_spawn_count(1), "Wave size should grow over time")
	assert(run.get_spawn_interval(2) < run.get_spawn_interval(1), "Spawn intervals should tighten over time")
	var early_encounter: Dictionary = WAVE_DIRECTOR.build_encounter_plan("bastion", 1, 0, 2, 3)
	var late_encounter: Dictionary = WAVE_DIRECTOR.build_encounter_plan("bastion", 6, 2, 12, 3)
	assert(int(late_encounter["spawn_count"]) > int(early_encounter["spawn_count"]), "Higher awareness should schedule larger hunting parties")
	assert(float(late_encounter["spawn_interval"]) <= float(early_encounter["spawn_interval"]), "Higher pressure should tighten encounter pacing")
	var mining_neighbor := Vector2i(-1, -1)
	for neighbor_direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if run.grid.is_walkable(run.grid.tutorial_rock + neighbor_direction):
			mining_neighbor = run.grid.tutorial_rock + neighbor_direction
			break
	assert(mining_neighbor != Vector2i(-1, -1), "Tutorial rock should expose a walkable mining approach")
	run.player_position = run.grid.cell_to_world(mining_neighbor)
	run.aim_direction = (run.grid.cell_to_world(run.grid.tutorial_rock) - run.player_position).normalized()
	var mining_hit: Dictionary = run._resolve_mining_hit()
	assert(not mining_hit.is_empty() and Vector2i(mining_hit["cell"]) == run.grid.tutorial_rock, "Mining ray should resolve the first mineable rock along the muzzle line")
	assert(Vector2(mining_hit["end"]).distance_to(run._player_muzzle_position(true)) <= run._mining_beam_reach(), "Mining visuals must terminate within the installed emitter's actionable reach")
	run.paused = true

	assert(run.grid.open_cell(run.grid.tutorial_rock), "Tutorial rock should be mineable")
	run.breached = true
	run._rebuild_base_flows()
	assert(run.flow.has_path(run.grid.spawn_cell), "Mining should connect the hive to the Core")

	run._spawn_spider(false)
	assert(run.enemies.size() == 1, "Spider spawn should be live")
	run._spawn_bullet(run.enemies[0].position, Vector2.RIGHT, 1.0, false)
	run._update_bullets(0.0)
	assert(run.enemies[0].hit_reaction > 0.0 and run.enemies[0].hit_recoil_direction == Vector2.RIGHT, "Enemy sprites should recoil directionally when struck")
	var old_position: Vector2 = run.enemies[0].position
	run._update_enemies(0.25)
	assert(run.enemies[0].position != old_position, "Spider should follow the shared flow field")
	run.wave = 8
	run.spawn_sequence = 1
	run._spawn_spider(false)
	var predator = run.enemies.back()
	assert(predator.hunts_player, "Mature waves should include mobs that deliberately hunt the player")

	run.player_position = run.grid.cell_to_world(run.grid.core_cell + Vector2i(-2, 0))
	run.selected_build = 1
	run._place_structure(run.grid.core_cell + Vector2i(-3, 0))
	assert(run.structures.size() == 1, "A sentry should be placeable inside the bunker")
	assert(run.structures[0].health == 72.0, "Early sentries should begin vulnerable enough to require maintenance")
	run.enemies[0].position = run.structures[0].position + Vector2(-48, 0)
	run._update_structures(1.0)
	assert(run.bullets.size() >= 1, "Sentry should acquire a spider and fire")
	var sentry_health_before: float = run.structures[0].health
	run.enemies[0].position = run.structures[0].position + Vector2(-4, 0)
	run.enemies[0].attack_cooldown = 0.0
	run._update_enemies(0.01)
	assert(run.structures[0].health < sentry_health_before, "Mobs should damage exposed sentries from the early game onward")

	# Dedicated equipment hunters must divert toward sentries, and higher turret
	# tiers must project a larger aggression radius.
	run.enemies.clear()
	run.wave = 5
	run._spawn_spider(true)
	var hunter = run.enemies[0]
	assert(hunter.hunts_turrets, "Brutes should deliberately hunt defensive equipment")
	run._update_structures(0.0)
	var sentry := run.structures[0]
	var hunter_probe := _turret_los_probe(run, sentry.position, 120.0)
	run.structures[0].level = 1
	hunter.position = hunter_probe
	assert(run._turret_target_for(hunter) == -1, "An MK 1 sentry should not pull distant equipment hunters")
	run.structures[0].level = 4
	assert(run._turret_target_for(hunter) == 0, "A powerful sentry should provoke hunters from farther away")
	assert(hunter.target_turret_cell == run.structures[0].cell, "A hunter should retain its selected turret target")
	assert(run._active_turret_hunter_count() == 1, "The HUD should report active turret locks")
	assert(run._hunters_targeting_cell(run.structures[0].cell) == 1, "A targeted sentry should expose its attacker count for visual telegraphing")
	var survey_cell := run.grid.world_to_cell(run.player_position)
	run._update_exploration()
	assert(run._sector_is_explored(survey_cell), "The current survey sector should be visible on the tightened minimap")
	assert(not run._sector_is_explored(Vector2i(0, 0)), "Unsurveyed map sectors should remain hidden from the minimap")

	run._clear_bullets()
	run.current_weapon = 1
	run.shotgun_magazine = 6
	run._fire_shotgun()
	assert(run.bullets.size() == 7, "Shotgun should emit a seven-pellet spread")

	var damage_before: float = run.weapon_damage_multiplier
	run.skill_points = 1
	run._unlock_skill_node("overclock")
	assert(run.weapon_damage_multiplier > damage_before, "Overclock should improve weapon damage")

	run.set_difficulty("bastion")
	run.wave = 3
	run.spawn_sequence = 3
	run._spawn_spider(false)
	assert(run.enemies.back().role == 1, "Phase 1 waves should introduce leapers")
	run.spawn_sequence = 5
	run._spawn_spider(false)
	assert(run.enemies.back().role == 2, "Phase 1 waves should introduce spitters")

	assert(DIFFICULTY_PROFILE.wave_spawn_count("explorer", 1) == 12, "Explorer spawn count should be stable")
	assert(DIFFICULTY_PROFILE.wave_spawn_count("bastion", 1) == 15, "Bastion spawn count should be stable")
	assert(DIFFICULTY_PROFILE.wave_spawn_count("extinction", 1) == 22, "Extinction spawn count should be stable")
	assert(DIFFICULTY_PROFILE.spawn_interval("extinction", 50) >= 0.12, "Spawn rate should respect the safety floor")

	var phase_two_grid: WORLD_GRID = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	phase_two_grid.generate_realm(424242, "bastion")
	phase_two_grid.configure_discoveries(424242, "bastion")
	var duplicate_grid: WORLD_GRID = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	duplicate_grid.generate_realm(424242, "bastion")
	duplicate_grid.configure_discoveries(424242, "bastion")
	phase_two_grid.materialize_all_discoveries_for_tests()
	duplicate_grid.materialize_all_discoveries_for_tests()
	phase_two_grid.materialize_all_regions_for_tests()
	duplicate_grid.materialize_all_regions_for_tests()
	var alternate_grid: WORLD_GRID = WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)
	alternate_grid.generate_realm(424243, "bastion")
	alternate_grid.materialize_all_regions_for_tests()
	assert(phase_two_grid.packed_cells() == duplicate_grid.packed_cells(), "The same realm seed should reproduce identical topology")
	assert(phase_two_grid.packed_cells() != alternate_grid.packed_cells(), "Different realm seeds should produce different topology")
	assert(phase_two_grid.ensure_regions_around(phase_two_grid.core_cell, 1) > 0, "Approaching a new area should stream its surrounding regions")
	phase_two_grid.process_region_preload_budget(9999)
	assert(phase_two_grid.is_region_loaded(phase_two_grid.core_cell), "The current region should report loaded after streaming")
	for site_cell_value: Variant in phase_two_grid.frontier_sites.values():
		assert(phase_two_grid.is_walkable(site_cell_value), "Every seeded Frontier Site must land on walkable floor")
	assert(phase_two_grid.discovery_cells.size() >= 9, "Seeded mining should place nests, ambushes, and guardians across the larger map")
	assert(phase_two_grid.mineral_cells.size() >= 35, "The expedition map should seed a deep mineral economy")
	assert(phase_two_grid.concealed_minerals.size() > 0 and phase_two_grid.concealed_minerals == duplicate_grid.concealed_minerals, "Concealed deposits should be seed-driven and reproducible")
	for cache_cell_value: Variant in phase_two_grid.mineral_cells.keys():
		var cache_cell: Vector2i = cache_cell_value
		if str(phase_two_grid.mineral_cells[cache_cell]) == WORLD_GRID.MINERAL_CACHE:
			assert(phase_two_grid.is_mineral_concealed(cache_cell), "Buried supply caches should remain visually hidden until mined")
	var first_discovery: Vector2i = phase_two_grid.discovery_cells.keys()[0]
	var first_discovery_type := phase_two_grid.reveal_discovery(first_discovery)
	assert(not first_discovery_type.is_empty(), "Mining a discovery cell should reveal its encounter")
	assert(phase_two_grid.reveal_discovery(first_discovery).is_empty(), "A discovery should trigger only once")
	var lane_discovery := Vector2i(-1, -1)
	for cell_value: Variant in phase_two_grid.discovery_cells.keys():
		if str(phase_two_grid.discovery_cells[cell_value]) == "nest":
			lane_discovery = cell_value
			break
	assert(lane_discovery.x >= 0, "Materialized realms should seed at least one nest discovery")
	phase_two_grid.open_discovery_chamber(lane_discovery, 1)
	assert(phase_two_grid.register_spawn_cell(lane_discovery), "Discovered nests should become real spawn routes")
	phase_two_grid.activate_lanes(2)
	assert(phase_two_grid.get_active_spawn_cell(1) == lane_discovery, "Discovered nests should become real spawn routes")
	run.grid.revealed_discoveries[lane_discovery] = "nest"
	assert(run._material_for_cell(lane_discovery) == run.hive_material, "Revealed mining chambers should become visibly infested")

	var early_plan: Dictionary = WAVE_DIRECTOR.build_encounter_plan("bastion", 0, 0, 2, 3)
	var late_plan: Dictionary = WAVE_DIRECTOR.build_encounter_plan("bastion", 6, 2, 12, 3)
	assert(int(early_plan["active_lanes"]) == 1, "Early encounters should teach one route first")
	assert(int(late_plan["active_lanes"]) == 3, "High-awareness encounters should pressure every discovered route")
	assert(int(late_plan["broodling_pack"]) > 0, "Late waves should add overwhelming broodling layers")
	assert(WAVE_DIRECTOR.enemy_health_pressure(21) > WAVE_DIRECTOR.enemy_health_pressure(8), "Late enemies should outscale the opening curve")
	assert(not WAVE_DIRECTOR.should_offer_upgrade(20), "Late progression should not grant an upgrade after every wave")

	run.enemies.clear()
	run.wave = 10
	var guardian_spawn_cell: Vector2i = run._prepared_spider_spawn_cell_near(run.grid.core_cell, 13, 24, 8819)
	assert(guardian_spawn_cell != Vector2i(-1, -1) and run._spawn_guardian(guardian_spawn_cell), "Guardian fixture should spawn outside protected base radii")
	assert(run.enemies[0].max_health > 1000.0, "Mined guardians should be much harder to kill than wave Brutes")
	run.enemies[0].health = run.enemies[0].max_health * 0.70
	run._update_enemies(0.01)
	assert(run.enemies.size() >= 11, "Damaged guardians should release a broodling layer")

	var mineral_cell: Vector2i = phase_two_grid.mineral_cells.keys()[0]
	var mineral_type: String = phase_two_grid.collect_mineral(mineral_cell)
	assert(not mineral_type.is_empty(), "A seeded mineral seam should pay out when mined")
	assert(phase_two_grid.collect_mineral(mineral_cell).is_empty(), "A mineral seam should pay only once")
	assert(phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_SILVER), "The mine should contain silver ore")
	assert(phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_GOLD), "The mine should contain gold ore")
	assert(phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_GRANITE) and phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_BASALT), "Every realm should contain structural stone for barrier fabrication")
	assert(phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_IRON) and phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_TITANIUM), "Every realm should contain long-term metal progression")
	assert(phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_QUARTZ) and phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_SULFUR) and phase_two_grid.mineral_cells.values().has(WORLD_GRID.MINERAL_COAL), "Every realm should seed optic and explosive processing inputs")

	var pistol_before_cache: int = run.reserve_ammo
	var shells_before_cache: int = run.shotgun_reserve
	var smg_before_cache: int = run.smg_reserve
	var rail_before_cache: int = run.railgun_reserve
	run._spawn_supply_cache_pickups(run.player_position)
	assert(run.pickups.size() == 4 and run._pickup_icon(run.pickups[0].kind) != null, "A mined supply cache should spawn four visible collectible ammunition sprites")
	run._update_pickups(0.01)
	assert(run.pickups.is_empty(), "Nearby supply sprites should be physically collected by the player")
	assert(run.reserve_ammo == pistol_before_cache + 18 and run.shotgun_reserve == shells_before_cache + 6 and run.smg_reserve == smg_before_cache + 30 and run.railgun_reserve == rail_before_cache + 2, "Each cache pickup should grant its displayed ammunition pool only after collection")
	var pre_pack_raw: Dictionary = run.material_economy.raw.duplicate(true)
	var pre_pack_tier: int = run.backpack_tier
	run.backpack_tier = 1
	var capacity_gap: int = maxi(0, run._backpack_capacity() - run._backpack_used())
	run.material_economy.add_raw(MATERIAL_ECONOMY.GRANITE, capacity_gap)
	run._spawn_pickup(run.player_position, MATERIAL_ECONOMY.QUARTZ, 1, Vector2.ZERO)
	run._update_pickups(0.01)
	assert(run.pickups.size() == 1 and "BACKPACK FULL" in run.discovery_alert, "A full backpack should leave mined cargo in the world instead of deleting it")
	run.pickups.clear()
	run.material_economy.raw = pre_pack_raw
	run.backpack_tier = pre_pack_tier

	var economy: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	economy.add_raw(MATERIAL_ECONOMY.ROUGH_DIAMOND, 1)
	assert(economy.contract_value() == 60, "Contract refining should expose a deterministic cash value before deposit")
	var quick_sale_economy: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	quick_sale_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	quick_sale_economy.add_raw(MATERIAL_ECONOMY.ROUGH_DIAMOND, 1)
	assert(quick_sale_economy.raw_quick_sale_value() == 39 and quick_sale_economy.sell_raw_quick() == 39 and quick_sale_economy.raw_total() == 0, "Immediate base liquidation should pay exactly 65% and clear sold backpack cargo")
	assert(economy.begin_contract(), "Raw cargo should be depositable into contract refining")
	assert(economy.tick_contract(MATERIAL_ECONOMY.CONTRACT_DURATION) == 60, "A completed contract should return spendable credits")
	assert(economy.foundry_upgrade_cost(0) == 500, "The first player-owned Foundry should cost $500")
	assert(economy.unlock_foundry(), "The owned Foundry should unlock self-refining")
	economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	assert(economy.refine(MATERIAL_ECONOMY.COPPER_ORE) == MATERIAL_ECONOMY.BRONZE_INGOT, "Three copper ore should refine into one bronze ingot")
	assert(economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] == 2, "Foundry MK1 should grant bonus common-metal yield")
	economy.add_raw(MATERIAL_ECONOMY.IRON_ORE, 2)
	economy.add_raw(MATERIAL_ECONOMY.COAL, 1)
	assert(not economy.can_refine(MATERIAL_ECONOMY.IRON_ORE), "Foundry MK1 should gate industrial Iron processing")
	assert(economy.unlock_foundry(), "Foundry MK2 should unlock industrial recipes")
	assert(economy.refine(MATERIAL_ECONOMY.IRON_ORE) == MATERIAL_ECONOMY.STEEL_PLATE and economy.refined[MATERIAL_ECONOMY.STEEL_PLATE] == 1, "Iron plus Coal should produce one Steel Plate for construction")
	economy.add_raw(MATERIAL_ECONOMY.SULFUR, 2)
	economy.add_raw(MATERIAL_ECONOMY.COAL, 2)
	assert(not economy.can_refine(MATERIAL_ECONOMY.SULFUR), "Foundry MK2 should gate advanced Sulfur processing")
	assert(economy.unlock_foundry(), "Foundry MK3 should unlock advanced recipes")
	assert(economy.refine(MATERIAL_ECONOMY.SULFUR) == MATERIAL_ECONOMY.EXPLOSIVE_COMPOUND, "Sulfur plus Coal should produce Rocket Turret and Land Mine explosive compound")
	assert("Copper" in economy.raw_manifest() and "Cut" in economy.refined_manifest(), "Inventory manifests should use player-readable material names")
	var restored_economy: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	restored_economy.restore(economy.serialize())
	assert(restored_economy.foundry_tier == 3 and restored_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] == 2, "Foundry and material stock should survive a save round trip")

	var pre_construction_scrap: int = run.scrap
	var pre_construction_refined: Dictionary = run.material_economy.refined.duplicate(true)
	var pre_construction_raw: Dictionary = run.material_economy.raw.duplicate(true)
	var pre_construction_unlocks: Dictionary = run.construction_unlocks.duplicate(true)
	var pre_construction_stock: Dictionary = run.deployable_stock.duplicate(true)
	var pre_backpack_tier: int = run.backpack_tier
	run.backpack_tier = 4
	for stock_id: String in run.deployable_stock.keys():
		run.deployable_stock[stock_id] = 0
	run.material_economy.raw = {}
	for material_id: String in run.material_economy.refined.keys():
		run.material_economy.refined[material_id] = 0
	run.scrap = 10000
	run.material_economy.refined[MATERIAL_ECONOMY.STEEL_PLATE] = 8
	run.material_economy.refined[MATERIAL_ECONOMY.TITANIUM_PLATE] = 6
	run.material_economy.refined[MATERIAL_ECONOMY.EXPLOSIVE_COMPOUND] = 6
	run.material_economy.refined[MATERIAL_ECONOMY.CUT_DIAMOND] = 2
	run.construction_unlocks["rocket_turret"] = false
	var rocket_turret_slot: int = run.CONSTRUCTION_ORDER.find("rocket_turret")
	var rocket_research_cost: int = UPGRADE_ECONOMY.construction_research_cost("rocket_turret")
	run._purchase_or_research_construction(rocket_turret_slot)
	assert(run.construction_unlocks["rocket_turret"] and run.scrap == 10000 - rocket_research_cost, "Rocket Turret research should deduct its exact research gate and permanently unlock fabrication")
	var pack_before_rocket: int = run._backpack_used()
	var rocket_craft_requirements: Dictionary = run._construction_craft_requirements("rocket_turret")
	var rocket_craft_material_units := 0
	for amount: Variant in rocket_craft_requirements.values():
		rocket_craft_material_units += int(amount)
	var rocket_craft_cost: int = run._construction_craft_cost("rocket_turret")
	assert(run._deployable_craft_state("rocket_turret", rocket_craft_cost, rocket_craft_requirements) == "READY", "Rocket Turret fabrication should be ready before crafting")
	run._purchase_or_research_construction(rocket_turret_slot)
	assert(run.deployable_stock["rocket_turret"] == 1, "Crafting should create exactly one carried Rocket Turret kit")
	assert(run._backpack_used() == pack_before_rocket - rocket_craft_material_units, "Rocket Turret fabrication should spend craft materials without kit weight")
	var structure_count_before_rocket: int = run.structures.size()
	run.selected_build = CrawlBrawlRunScript.BUILD_ROCKET_TURRET
	run.player_position = run.grid.cell_to_world(run.grid.core_cell + Vector2i(-5, 0))
	run._place_structure(run.grid.core_cell + Vector2i(-5, 1))
	assert(run.structures.size() == structure_count_before_rocket + 1 and run.structures.back().kind == CrawlBrawlRunScript.BUILD_ROCKET_TURRET and run.deployable_stock["rocket_turret"] == 0, "Field placement should consume one kit and create the advertised advanced turret")
	run.structures.pop_back()
	run.scrap = pre_construction_scrap
	run.material_economy.refined = pre_construction_refined
	run.material_economy.raw = pre_construction_raw
	run.construction_unlocks = pre_construction_unlocks
	run.deployable_stock = pre_construction_stock
	run.backpack_tier = pre_backpack_tier

	var saved_structures: Array = run.structures.duplicate()
	var saved_player_position: Vector2 = run.player_position
	var saved_selected_build: int = run.selected_build
	var placement_unlocks: Dictionary = run.construction_unlocks.duplicate(true)
	var placement_stock: Dictionary = run.deployable_stock.duplicate(true)
	var placement_kinds: Array[int] = [CrawlBrawlRunScript.BUILD_GRANITE_BARRIER, CrawlBrawlRunScript.BUILD_REINFORCED_BARRIER, CrawlBrawlRunScript.BUILD_BLAST_BARRIER, CrawlBrawlRunScript.BUILD_LAND_MINE, CrawlBrawlRunScript.BUILD_ROCKET_TURRET, CrawlBrawlRunScript.BUILD_LASER_TURRET]
	var placement_ids: Array[String] = ["granite_barrier", "reinforced_barrier", "blast_barrier", "land_mine", "rocket_turret", "laser_turret"]
	run.structures.clear()
	for placement_id: String in placement_ids:
		run.construction_unlocks[placement_id] = true
		run.deployable_stock[placement_id] = 1
	for placement_index in range(placement_kinds.size()):
		var placement_cell := Vector2i(-1, -1)
		for cell_y in range(1, run.grid.height - 1):
			if placement_cell.x >= 0:
				break
			for cell_x in range(1, run.grid.width - 1):
				var candidate_cell := Vector2i(cell_x, cell_y)
				run.player_position = run.grid.cell_to_world(candidate_cell)
				if run._can_place_structure(candidate_cell):
					placement_cell = candidate_cell
					break
		assert(placement_cell.x >= 0, "Every fabricated defense should find at least one valid field placement cell")
		run.selected_build = placement_kinds[placement_index]
		var stock_id: String = placement_ids[placement_index]
		var structure_count_before: int = run.structures.size()
		run._place_structure(placement_cell)
		assert(run.structures.size() == structure_count_before + 1 and run.structures.back().kind == placement_kinds[placement_index], "%s should create its advertised world structure" % stock_id)
		assert(int(run.deployable_stock[stock_id]) == 0, "%s placement should consume exactly one carried kit" % stock_id)
	var invalid_cell: Vector2i = run.structures[0].cell
	run.selected_build = CrawlBrawlRunScript.BUILD_GRANITE_BARRIER
	run.deployable_stock["granite_barrier"] = 1
	var invalid_structure_count: int = run.structures.size()
	run._place_structure(invalid_cell)
	assert(run.structures.size() == invalid_structure_count and int(run.deployable_stock["granite_barrier"]) == 1, "Invalid occupied-cell placement should consume neither the kit nor create a structure")
	run.structures.clear()
	for saved_structure: Variant in saved_structures:
		run.structures.append(saved_structure)
	run.player_position = saved_player_position
	run.selected_build = saved_selected_build
	run.construction_unlocks = placement_unlocks
	run.deployable_stock = placement_stock

	run.scrap = 1000
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run.material_economy.refined[MATERIAL_ECONOMY.SILVER_INGOT] = 4
	run.material_economy.refined[MATERIAL_ECONOMY.CRYSTAL_CORE] = 4
	run.material_economy.refined[MATERIAL_ECONOMY.GOLD_INGOT] = 4
	run.material_economy.refined[MATERIAL_ECONOMY.CUT_DIAMOND] = 4
	run._purchase_weapon_unlock()
	assert(run.unlocked_weapons[3], "Core Base research should unlock the SMG")
	run._purchase_weapon_unlock()
	assert(run.unlocked_weapons[4], "Core Base research should unlock the railgun")
	var style_credits_before: int = run.scrap
	var style_bronze_before: int = int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT])
	run._purchase_or_equip_style(1)
	assert(run.player_style_id == 1 and run.unlocked_player_styles[1], "The Foundry Suit should unlock and equip as a persistent look")
	assert(run.player_strength_multiplier > 1.0 and run.player_defense_multiplier < 1.0, "Equipping Foundry Suit should apply bronze-tier strength and defense boosts")
	assert(run.scrap == style_credits_before - 250 and int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == style_bronze_before - 1, "A suit unlock should deduct its displayed credits and component exactly once")
	run._purchase_or_equip_style(0)
	assert(run.player_style_id == 0 and run.scrap == style_credits_before - 250, "Switching to an owned style should be free and preserve combat currency")
	assert(run.player_strength_multiplier == 1.0 and run.player_defense_multiplier == 1.0, "Switching back to Survey Suit should restore baseline armor multipliers")
	var pistol_reserve_before: int = run.reserve_ammo
	var supply_credits_before: int = run.scrap
	run._purchase_supply(0)
	assert(run.reserve_ammo == pistol_reserve_before + 60 and run.scrap == supply_credits_before - 12, "A Pistol supply purchase should deduct $12 and add exactly 60 cartridges")
	run.laser_energy = 100.0
	var full_laser_credits: int = run.scrap
	run._purchase_supply(2)
	assert(run.scrap == full_laser_credits, "A full Laser capacitor should not consume credits")
	run.current_weapon = 4
	run.railgun_magazine = 3
	run._clear_bullets()
	run._fire_railgun()
	assert(run.bullets.size() == 1 and run.bullets[0].pierce_remaining == 3, "The railgun should fire a heavy piercing slug")
	run.current_weapon = 3
	run.expedition_level = 1
	run.skill_points = 2
	run._unlock_skill_node("overclock")
	run._unlock_skill_node("automation")
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 8
	run.material_economy.refined[MATERIAL_ECONOMY.SILVER_INGOT] = 4
	run.material_economy.refined[MATERIAL_ECONOMY.CRYSTAL_CORE] = 4
	var weapon_tier_before: int = run.weapon_tiers[3]
	var smg_interval_before: float = run._weapon_fire_interval(3)
	run._purchase_weapon_upgrade()
	assert(run.weapon_tiers[3] == weapon_tier_before + 1 and run._weapon_fire_interval(3) < smg_interval_before, "Core Base armory should improve the selected weapon's advertised handling")
	var pistol_tier_before: int = run.weapon_tiers[0]
	var smg_tier_before: int = run.weapon_tiers[3]
	var smg_capacity_before: int = run._weapon_mag_capacity(3)
	run._purchase_weapon_upgrade_for(3)
	assert(run.weapon_tiers[3] == smg_tier_before + 1 and run.weapon_tiers[0] == pistol_tier_before and run._weapon_mag_capacity(3) > smg_capacity_before, "A catalog purchase should upgrade only the explicit weapon and apply its advertised capacity increase")
	var failed_purchase_credits: int = run.scrap
	var failed_purchase_tier: int = run.weapon_tiers[0]
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 0
	run._set_core_menu_page("armory")
	assert(run.core_service_buttons[0].disabled and run.core_action_states[0].begins_with("MISSING"), "An unaffordable shop upgrade should be visibly blocked instead of presenting a non-working purchase button")
	run._purchase_weapon_upgrade_for(0)
	assert(run.scrap == failed_purchase_credits and run.weapon_tiers[0] == failed_purchase_tier, "A missing-component purchase should be atomic and leave credits and item state unchanged")
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run._set_core_menu_page("armory")
	assert(not run.core_service_buttons[0].disabled and run.core_action_states[0] == "READY", "A funded shop upgrade should expose an active purchase button")
	run.structures[0].health = 20.0
	var sentry_level_before: int = run.structures[0].level
	run.structures[0].level = 1
	sentry_level_before = run.structures[0].level
	run.skill_points = PROGRESSION_TREE.sentry_upgrade_sp(sentry_level_before)
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run._purchase_turret_upgrade()
	assert(run.turret_selection_active, "Defense engineering should enter explicit turret-selection mode")
	assert(run.turret_selection_indices[run.turret_selection_cursor] == 0, "The selected turret should have a stable map index")
	var turret_click := InputEventMouseButton.new()
	turret_click.button_index = MOUSE_BUTTON_LEFT
	turret_click.pressed = true
	turret_click.position = run.get_viewport().get_canvas_transform() * run.structures[0].position
	assert(run._world_position_from_viewport(turret_click.position).distance_to(run.structures[0].position) < 0.1, "Turret selection must convert the real viewport click into the correct world target")
	assert("CURRENT" in run._turret_upgrade_summary(run.structures[0]) and "NEXT" in run._turret_upgrade_summary(run.structures[0]), "Turret engineering should expose exact current-to-next damage, rate, durability, and aggression")
	run._unhandled_input(turret_click)
	assert(run.structures[0].level == sentry_level_before + 1, "Core Base engineering should upgrade an already placed sentry")
	assert(not run.turret_selection_active and run.using_core_base and run.core_base_panel.visible, "A successful turret upgrade should always return to the Defenses terminal")
	run.structures[0].level = 1
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 0
	run._purchase_turret_upgrade()
	assert(not run.turret_selection_active and run.using_core_base, "A blocked turret upgrade should remain in the shop and never trap the player in world-selection mode")
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run.structures[0].health = 10.0
	run._purchase_repairs()
	assert(run.structures[0].health == run.structures[0].max_health, "Paid repairs should restore damaged equipment")

	var network: BASE_NETWORK = BASE_NETWORK.new()
	network.configure(run.grid.core_cell, run.grid.width, run.grid.height)
	assert(network.frontier_active_count() == 0, "A new expedition should begin with no active Frontier Cores")
	assert(BASE_NETWORK.FRONTIER_COST == 1000, "Every Frontier Core should require a $1000 investment")
	network.mark_guardian_cleared(BASE_NETWORK.NORTH_ID)
	assert(network.can_construct(BASE_NETWORK.NORTH_ID, 5, 4, false), "A cleared Frontier Site should become buildable at its progression gate")
	assert(network.begin_activation(BASE_NETWORK.NORTH_ID), "A Frontier Core should enter its vulnerable activation state")
	assert(network.choose_target(network.get_cell(BASE_NETWORK.NORTH_ID), 1, "bastion") == BASE_NETWORK.NORTH_ID, "Activation attackers should prioritize the unfinished Frontier Core")
	var activation_result := network.tick_activation(BASE_NETWORK.ACTIVATION_DURATION)
	assert(activation_result == BASE_NETWORK.NORTH_ID, "Surviving the activation timer should bring the regional Core online")
	assert(network.owns_cell(BASE_NETWORK.NORTH_ID, network.get_cell(BASE_NETWORK.NORTH_ID) + Vector2i(9, 0)), "An MK 1 Frontier Core should power its ten-cell territory")
	assert(not network.owns_cell(BASE_NETWORK.NORTH_ID, network.get_cell(BASE_NETWORK.NORTH_ID) + Vector2i(11, 0)), "An MK 1 territory should not silently exceed its radius")
	assert(network.damage(BASE_NETWORK.NORTH_ID, 9999.0) == "disabled", "A destroyed Frontier Core should be disabled instead of ending the run")
	assert(network.reactivate(BASE_NETWORK.NORTH_ID), "A disabled Frontier Core should be recoverable")
	var restored_network: BASE_NETWORK = BASE_NETWORK.new()
	restored_network.configure(run.grid.core_cell, run.grid.width, run.grid.height)
	assert(restored_network.restore(network.serialize()), "Versioned base records should survive a save round trip")
	assert(restored_network.get_status(BASE_NETWORK.NORTH_ID) == BASE_NETWORK.STATUS_ACTIVE, "Restored Frontier Core state should remain active")

	run.base_network.bases[BASE_NETWORK.NORTH_ID]["revealed"] = true
	run.base_network.mark_guardian_cleared(BASE_NETWORK.NORTH_ID)
	assert(run.base_network.begin_activation(BASE_NETWORK.NORTH_ID), "The live run should begin a Frontier Core activation")
	run.base_network.tick_activation(BASE_NETWORK.ACTIVATION_DURATION)
	run._rebuild_base_flows()
	assert(run.base_flows.has(BASE_NETWORK.NORTH_ID), "An active Frontier Core should own a cached enemy flow field")
	run.player_position = run.grid.cell_to_world(run.base_network.get_cell(BASE_NETWORK.NORTH_ID) + Vector2i(-2, 0))
	run.selected_build = 1
	run.scrap = 1000
	var frontier_sentry_cell: Vector2i = _frontier_territory_cell(run, BASE_NETWORK.NORTH_ID, Vector2i(-3, 0))
	var frontier_structure_count: int = run.structures.size()
	run._place_structure(frontier_sentry_cell)
	assert(run.structures.size() == frontier_structure_count + 1, "Frontier sentry placement should succeed on seeded territory")
	assert(run.structures.back().base_id == BASE_NETWORK.NORTH_ID and run.structures.back().powered, "A sentry inside Frontier territory should join that local network")

	run.wave = 5
	run.explored_sectors[Vector2i(1, 1)] = true
	run.checkpoint_exists = true
	run.checkpoint_base_id = BASE_NETWORK.COMMAND_ID
	run.checkpoint_position = run.player_position
	run.checkpoint_generation = 1
	assert(run._save_run(false, true), "A completed Personal Base checkpoint should write an encrypted per-realm save")
	assert(REALM_SAVE.has_active_save(), "The writable user-data store should retain an active Continue realm")
	assert(REALM_SAVE.save_root() == ProjectSettings.globalize_path("user://saves").trim_suffix("/").trim_suffix("\\"), "Realm data should live in the portable writable user-data saves directory")
	assert(bool(REALM_SAVE.storage_summary().get("portable_encryption", false)), "Realm storage should use machine-independent portable encryption")
	var saved_summary: Dictionary = REALM_SAVE.active_summary()
	assert(str(saved_summary.get("realm_id", "")) == run.realm_id, "The protected save should retain its realm identity")
	var realm_catalog: Array[Dictionary] = REALM_SAVE.list_realms()
	assert(not realm_catalog.is_empty() and realm_catalog[0].has("credits") and realm_catalog[0].has("active_bases"), "Realm selection cards should expose useful expedition progress before loading")
	var protected_save: Dictionary = REALM_SAVE.load_active_save()
	assert(protected_save.has("player_style_id") and protected_save.has("unlocked_player_styles"), "Protected realm saves should retain cosmetic unlock and equipped state")
	assert(protected_save.has("sprint_energy") and protected_save.has("pickups"), "Patch 4.13 saves should retain traversal energy and uncollected field drops")
	assert(protected_save.has("mining_speed_tier") and protected_save.has("mining_emitter_tier"), "Patch 4.14 saves should retain both mining progression tracks")
	assert(protected_save.has("backpack_tier") and protected_save.has("construction_unlocks") and protected_save.has("deployable_stock"), "Patch 4.15 saves should retain backpack progression, defense research, and carried deployment kits")

	print("CRAWL_BRAWL_PATCH4151_FIELD_INVENTORY_TURRET_FIX_SMOKE_TEST_OK")
	quit(0)
