extends SceneTree

const HARNESS := preload("res://tests/test_harness.gd")

const CORE_TESTS: Array[String] = [
	"res://tests/smoke_test.gd",
	"res://tests/mob_locomotion_test.gd",
	"res://tests/mob_flow_behavior_test.gd",
	"res://tests/mob_routing_stability_bv5_test.gd",
	"res://tests/mob_routing_stability_bv52_test.gd",
	"res://tests/chunk_simulation_bv53_test.gd",
	"res://tests/door_click_interaction_bv531_test.gd",
	"res://tests/streaming_siege_bv54_test.gd",
	"res://tests/frame_budget_bv55_test.gd",
	"res://tests/open_world_pacing_bv56_test.gd",
	"res://tests/open_world_pacing_bv57_test.gd",
	"res://tests/settlement_foundation_bv58_test.gd",
	"res://tests/combat_pressure_test.gd",
	"res://tests/economy_pacing_test.gd",
	"res://tests/player_armor_test.gd",
	"res://tests/display_uix_test.gd",
	"res://tests/floor_macro_tile_test.gd",
	"res://tests/biome_formation_profile_test.gd",
	"res://tests/biome_transition_profile_test.gd",
	"res://tests/biome_atmosphere_profile_test.gd",
	"res://tests/mining_crosshair_test.gd",
	"res://tests/mining_redraw_budget_test.gd",
	"res://tests/mining_gun_asset_test.gd",
	"res://tests/mining_relocation_test.gd",
	"res://tests/runtime_asset_integrity_test.gd",
	"res://tests/biome_bestiary_test.gd",
	"res://tests/enemy_projectile_types_test.gd",
	"res://tests/enemy_projectile_sprint_b_test.gd",
	"res://tests/biome_ecology_profile_test.gd",
	"res://tests/held_weapon_alignment_test.gd",
	"res://tests/realm_visual_test.gd",
	"res://tests/combat_sprite_usage_test.gd",
	"res://tests/combat_impact_test.gd",
	"res://tests/sentry_sp_upgrade_test.gd",
	"res://tests/progression_command_sp_test.gd",
	"res://tests/progression_functional_test.gd",
	"res://tests/progression_menu_unlock_test.gd",
	"res://tests/progression_wave_save_order_test.gd",
	"res://tests/progression_level_gates_test.gd",
	"res://tests/progression_sp_gates_test.gd",
	"res://tests/progression_save_test.gd",
	"res://tests/personal_base_sp_upgrade_test.gd",
	"res://tests/route_tactics_test.gd",
	"res://tests/terrain_preservation_test.gd",
	"res://tests/lazy_sparse_cells_test.gd",
	"res://tests/authored_region_topology_test.gd",
	"res://tests/lazy_region_topology_test.gd",
	"res://tests/route_connectivity_test.gd",
	"res://tests/topology_idempotency_test.gd",
	"res://tests/boot_floor_budget_test.gd",
	"res://tests/world_seed_determinism_test.gd",
	"res://tests/vein_after_topology_test.gd",
	"res://tests/region_density_playability_test.gd",
	"res://tests/region_preload_test.gd",
	"res://tests/hive_awareness_test.gd",
	"res://tests/biome_scout_alert_test.gd",
	"res://tests/map_coordinate_uix_test.gd",
	"res://tests/world_address_test.gd",
	"res://tests/infinite_region_stream_test.gd",
	"res://tests/open_world_boundary_test.gd",
	"res://tests/stream_window_budget_test.gd",
	"res://tests/render_window_throttle_test.gd",
	"res://tests/terrain_chunk_render_test.gd",
	"res://tests/terrain_seam_render_test.gd",
	"res://tests/mineral_vein_distribution_test.gd",
	"res://tests/prepared_spawn_control_test.gd",
	"res://tests/hostile_spawn_admission_test.gd",
	"res://tests/base_spawn_exclusion_test.gd",
	"res://tests/field_hut_checkpoint_test.gd",
	"res://tests/ruined_fortress_test.gd",
	"res://tests/lazy_materialization_order_test.gd",
	"res://tests/lazy_save_lifecycle_test.gd",
	"res://tests/lazy_nest_save_lifecycle_test.gd",
	"res://tests/lazy_frontier_reload_test.gd",
	"res://tests/lazy_discovery_test.gd",
	"res://tests/realm_save_roundtrip_test.gd",
	"res://tests/save_state_stability_test.gd",
	"res://tests/wave_save_fidelity_test.gd",
	"res://tests/flow_local_rebuild_test.gd",
	"res://tests/brood_ecology_test.gd",
	"res://tests/nest_placement_test.gd",
	"res://tests/world_load_bulk_test.gd",
	"res://tests/generator_version_gate_test.gd",
	"res://tests/breached_save_route_test.gd",
	"res://tests/authored_no_evict_test.gd",
	"res://tests/hud_minimap_test.gd",
	"res://tests/continuous_breather_test.gd",
	"res://tests/checkpoint_respawn_test.gd",
]


func _initialize() -> void:
	call_deferred("_run_batch")


func _run_batch() -> void:
	HARNESS.reset()
	var failures: Array[String] = []
	for script_path: String in CORE_TESTS:
		var result: Dictionary = HARNESS.run_script(script_path)
		if bool(result["ok"]):
			print("OK  %s" % script_path.get_file())
			continue
		failures.append(script_path.get_file())
		print("FAIL %s" % script_path.get_file())
		for line: String in str(result["output"]).split("\n"):
			if HARNESS.error_present(line):
				print("  %s" % line.strip_edges())
	if not failures.is_empty():
		HARNESS.fail("Regression batch failed: %s" % ", ".join(failures))
		HARNESS.finish(self, "")
		return
	HARNESS.finish(self, "CRAWL_BRAWL_REGRESSION_BATCH_OK")
