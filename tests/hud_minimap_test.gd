extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const VISUAL_STYLE := preload("res://systems/realm_visual_style.gd")


func _initialize() -> void:
	call_deferred("_run_hud_minimap_test")


func _run_hud_minimap_test() -> void:
	var last_base_card := Rect2(
		VISUAL_STYLE.HUD_BASE_START + Vector2(3 * VISUAL_STYLE.HUD_BASE_CARD_STEP, 0),
		VISUAL_STYLE.HUD_BASE_CARD_SIZE
	)
	assert(VISUAL_STYLE.HUD_LEFT_PANEL.end.x < VISUAL_STYLE.HUD_BASE_START.x, "Left telemetry must not touch the base network")
	assert(last_base_card.end.x < VISUAL_STYLE.HUD_RIGHT_PANEL.position.x, "Four fixed base cards must fit before Suit telemetry")
	assert(VISUAL_STYLE.HUD_MINIMAP_CARD.end.x <= VISUAL_STYLE.HUD_OBJECTIVE_PANEL.position.x, "The tactical map and objective strip must not overlap")
	assert(VISUAL_STYLE.HUD_OBJECTIVE_PANEL.end.x <= VISUAL_STYLE.HUD_CONTEXT_PANEL.position.x, "Objective and action context must remain separate")
	assert(VISUAL_STYLE.HUD_WEAPON_START.y + VISUAL_STYLE.HUD_WEAPON_CARD_SIZE.y < VISUAL_STYLE.HUD_OBJECTIVE_PANEL.position.y, "Weapon cards must clear the objective strip")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	assert(run._hud_base_order() == [run.base_network.COMMAND_ID, run.base_network.NORTH_ID, run.base_network.SOUTH_ID, run.base_network.WEST_ID], "Base telemetry order must not change as sites are revealed")

	run._rebuild_minimap_cache()
	assert(not run.minimap_cache_dirty and run.minimap_cache_texture != null, "The tactical terrain cache should build once and become reusable")
	var player_cell: Vector2i = run.grid.world_to_cell(run.player_position)
	assert(run.minimap_view_origin == run._minimap_view_origin_for(player_cell), "Minimap origin should center on the player after rebuild")
	var origin_before: Vector2i = run.minimap_view_origin
	var stepped_cell: Vector2i = player_cell + Vector2i(1, 0)
	run._advance_minimap_view(run._minimap_view_origin_for(stepped_cell))
	assert(run.minimap_view_origin == origin_before + Vector2i(1, 0), "Single-cell movement should scroll the minimap window")
	assert(not run.minimap_cache_dirty, "Minimap scroll should avoid scheduling a full rebuild")
	run.player_position = run.grid.cell_to_world(Vector2i(512, -256))
	run._rebuild_minimap_cache()
	var exterior_cell: Vector2i = run.grid.world_to_cell(run.player_position)
	assert(run.minimap_view_origin == run._minimap_view_origin_for(exterior_cell), "Exterior signed coordinates should recenter the minimap window")
	var off_view_cell := exterior_cell + Vector2i(200, 200)
	assert(run._minimap_position_for_cell(off_view_cell) == null, "Off-view cells should not produce minimap marker positions")
	var cmd_cell: Vector2i = run.base_network.get_base(run.base_network.COMMAND_ID)["cell"]
	var cmd_edge: Vector2 = run._minimap_edge_marker_for_cell(cmd_cell)
	var map_rect := VISUAL_STYLE.HUD_MINIMAP_MAP
	assert(cmd_edge != null and cmd_edge != map_rect.get_center(), "Off-screen CMD should produce an edge marker away from center")
	assert(map_rect.has_point(cmd_edge), "CMD edge marker should stay inside the minimap rect")
	var unsurveyed_cell := Vector2i(2, 2)
	run._register_sector(unsurveyed_cell, false)
	assert(not run.minimap_cache_dirty, "Surveying a new sector should patch tactical terrain without a full rebuild")
	run._flush_minimap_patches()
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run._rebuild_minimap_cache()
	if not run.grid.is_walkable(run.grid.tutorial_rock):
		assert(run.grid.open_cell(run.grid.tutorial_rock), "The tutorial rock should open for minimap refresh coverage")
	run._on_terrain_cell_opened(run.grid.tutorial_rock)
	var rock_cell: Vector2i = run.grid.tutorial_rock
	var rock_pixel: Vector2i = run._minimap_local_pixel(rock_cell)
	assert(rock_pixel.x >= 0, "Mined walkable cells within the view window should map to local minimap pixels")
	var terrain_patched: bool = run.minimap_cache_texture != null and run.grid.is_walkable(rock_cell)
	assert(run.minimap_patch_pending or run.minimap_cache_dirty or terrain_patched, "Mining and other terrain edits must refresh tactical terrain")
	run._flush_minimap_patches()

	run._spawn_spider(false)
	var contact = run.enemies.back()
	contact.position = run.grid.cell_to_world(unsurveyed_cell)
	contact.hunts_turrets = false
	assert(not run._minimap_enemy_visible(contact), "Hostiles outside torch vision and base territory must stay hidden")
	contact.hunts_turrets = true
	assert(not run._minimap_enemy_visible(contact), "Turret hunters must not bypass torch/base reveal rules")
	contact.hunts_turrets = false
	contact.position = run.player_position
	assert(run._minimap_enemy_visible(contact), "Hostiles within powered base territory should appear on the minimap")

	assert(run._hud_objective_state(1, 0)["severity"] == "threat", "Base attacks should use threat priority")
	run.first_mine_earned = true
	run.breached = true
	run.wave_active = true
	run.discovery_alert_time = 0.0
	var wave_objective: Dictionary = run._hud_objective_state(0, 0)
	assert("WAVE" not in wave_objective["text"] and "HUNTING PARTY" in wave_objective["text"], "Combat objective should stay player-facing without wave telemetry")
	run.wave_active = false
	var breather_objective: Dictionary = run._hud_objective_state(0, 0)
	assert("WAVE" not in breather_objective["text"] and "EXPLORE" in breather_objective["text"], "Breather objective should omit wave numbers")
	run.set_paused(true)
	assert("HIVE" in run._pause_summary_text() and "HOSTILES" in run._pause_summary_text(), "Pause menu should carry expedition telemetry moved off the HUD")
	run.set_paused(false)
	run.hud_comms_active = {}
	run.hud_comms_queue.clear()
	run.discovery_alert = ""
	run.discovery_alert_time = 0.0
	run.hud_comms_last_posted_text = ""
	assert(run._comms_state_from_text("COMMAND CORE ONLINE")["severity"] == "success", "Positive system feedback should use success priority")
	run._push_comms_alert("COMMAND CORE ONLINE", 1.0)
	assert(str(run.hud_comms_active.get("text", "")) == "COMMAND CORE ONLINE", "Comms queue should retain positive system feedback")
	run._push_comms_alert("INFO // SALVAGE FOUND", 2.0)
	run._push_comms_alert("NETWORK ALERT // BASE UNDER ATTACK", 3.0)
	assert(str(run.hud_comms_active.get("text", "")).contains("UNDER ATTACK"), "Higher-priority comms alerts should preempt lower-priority messages")
	run._register_hud_kill_streak(false)
	run._register_hud_kill_streak(false)
	assert(run.hud_kill_streak >= 2 and run.hud_kill_streak_flash > 0.0, "Player kill streak should flash near the crosshair")
	run.player_position = run.grid.cell_to_world(Vector2i(2, 2))
	var idle_interaction: Dictionary = run._hud_interaction_state()
	assert(idle_interaction["glyph"] == "pack" and "TAB" in idle_interaction["text"] and "SCROLL" in idle_interaction["text"] and "BUILD" in idle_interaction["text"] and "TAB BUILD" not in idle_interaction["text"], "Idle HUD context should show TAB/scroll weapons and numbered build prompts")
	assert(run.operator_loadout.is_cutter_selected(), "New runs should select the cutter so the first LMB mines")
	assert(run.operator_loadout.has_weapon(run.WEAPON_PISTOL) and run.operator_loadout.has_weapon(run.WEAPON_SHOTGUN) and run.operator_loadout.has_weapon(run.WEAPON_LASER), "Starter holster should equip pistol, shotgun, and laser")
	assert(not run.build_mode and not run.build_intent, "Spawn should not open the build hologram until 1-9")
	assert(run.operator_onboard != null and run.operator_onboard.step == run.operator_onboard.STEP_MOVE, "New runs start on the move prompt")
	run._update_onboard()
	assert("WASD" in run.discovery_alert, "Opening tutorial should teach movement before mining")
	run._select_build_slot(0)
	run._update_build_mode()
	assert(run.build_intent and run.build_mode, "Pressing a build key should open hologram setup")
	run._select_build_slot(0)
	run._update_build_mode()
	assert(not run.build_intent and not run.build_mode, "Pressing the same build key again should exit build setup")
	run._select_build_slot(0)
	run._update_build_mode()
	assert(run.build_intent and run.build_mode, "Pressing a build key again should re-enter hologram setup")
	if run.enemies.is_empty():
		run._spawn_spider(false)
	var combat_spider = run.enemies.back()
	combat_spider.position = run.player_position
	run.player_hit_time = 0.12
	run._enemy_spatial_buckets_frame = -1
	run._update_build_mode()
	assert(run.build_mode, "Nearby enemies must not disable build setup")
	run.player_hit_time = 0.0
	run._cycle_weapon(1)
	run._update_build_mode()
	assert(not run.build_intent and not run.build_mode, "Weapon cycle/scroll should exit build setup")
	run._select_build_slot(0)
	run._update_build_mode()
	assert(run.build_intent and run.build_mode, "Build setup should return from 1-9 after weapon cycle")
	run.build_intent = false
	run._update_build_mode()
	run.operator_onboard.advance(true, false, false)
	assert(run.operator_onboard.step == run.operator_onboard.STEP_MINE, "Moving should unlock the mine prompt")
	run.operator_onboard.advance(true, true, false)
	assert(run.operator_onboard.step == run.operator_onboard.STEP_FIRE, "Mining should unlock the gun prompt")
	run.operator_onboard.advance(true, true, true)
	assert(run.operator_onboard.is_done(), "Firing a gun should complete onboard")
	var mixed := {
		"hotbar": [
			{"kind": "mining_tool", "id": "mining_cutter", "build_kind": -1, "count": 1},
			{"kind": "weapon", "id": 0, "build_kind": -1, "count": 1},
			{"kind": "weapon", "id": 1, "build_kind": -1, "count": 1},
			{"kind": "weapon", "id": 2, "build_kind": -1, "count": 1},
			{"kind": "build", "id": "build", "build_kind": 0, "count": 1},
		],
		"backpack": [],
		"hotbar_index": 1,
	}
	run.operator_loadout.deserialize(mixed)
	assert(run.operator_loadout.holster_guns.has(2) and run.operator_loadout.is_cutter_selected(), "Schema-13 mixed hotbar should migrate laser onto the holster, not the build bar")
	assert(str(run.operator_loadout.hotbar[0].get("kind", "")) != "weapon", "Migrated build bar must not keep guns")
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	var core_interaction: Dictionary = run._hud_interaction_state()
	assert(core_interaction["glyph"] == "core" and "CLICK" in core_interaction["text"], "Core proximity should expose the compact visual interaction state")
	assert(run.shop_icons.get("pistol") != null and run.shop_icons.get("command_core") != null, "HUD weapon and base cards require their existing runtime icon assets")
	assert(run._weapon_hud_icon(run.WEAPON_PISTOL) != null and run._holster_cutter_icon() != null, "Holster chips should resolve pistol and cutter sprites")
	assert(run._should_draw_combat_crosshair(), "Field aim should keep an active combat/break reticle")

	run.minimap_cache_texture = null
	run.minimap_cache_dirty = false
	if run.minimap_cache_texture == null:
		run._mark_minimap_dirty(0.0)
	assert(run.minimap_cache_dirty, "Minimap draw path must defer rebuilds instead of syncing cache construction")

	print("CRAWL_BRAWL_HUD_MINIMAP_TEST_OK")
	quit(0)
