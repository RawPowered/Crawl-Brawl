extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const WAVE_DIRECTOR := preload("res://systems/wave_director.gd")


func _initialize() -> void:
	call_deferred("_run_brood_ecology_test")


func _require(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
		return false
	return true


func _run_brood_ecology_test() -> void:
	if not _require(WAVE_DIRECTOR.brood_carrier_count(5, "bastion") == 0, "Bastion should preserve the first boss as the nest-system threshold"):
		return
	if not _require(WAVE_DIRECTOR.brood_carrier_count(6, "bastion") == 1, "The first Bastion carrier should follow the wave-five boss"):
		return
	if not _require(WAVE_DIRECTOR.brood_carrier_count(7, "bastion") == 0 and WAVE_DIRECTOR.brood_carrier_count(9, "bastion") == 1, "Bastion carriers should recur without appearing every wave"):
		return
	if not _require(WAVE_DIRECTOR.brood_carrier_count(4, "extinction") == 1, "Extinction should introduce brood ecology earlier"):
		return

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	if not _require(run.world_textures.get("brood_nest") != null and run.world_textures.get("brood_carrier") != null, "Brood ecology must load dedicated nest and carrier art"):
		return
	run.grid.activate_region_window([run.grid.core_cell], 2)
	var loaded_before: int = run.grid.loaded_regions.size()
	var far_site: Vector2i = run._choose_far_brood_nest_site(20.0, 8.0, 991)
	if not _require(far_site.x >= 0, "Far nest site selection should succeed within the active stream window"):
		return
	if not _require(run.grid.loaded_regions.size() == loaded_before, "Far nest site selection must not expand beyond the active stream window"):
		return
	run.brood_nests.clear()

	run.grid.open_cell(run.grid.tutorial_rock)
	run._rebuild_base_flows()
	run.grid.activate_region_window(run.grid.spawn_cells, 2)
	run.encounters_completed = 7
	run.current_wave_plan = WAVE_DIRECTOR.build_encounter_plan("bastion", 4, 0, 7, run.grid.spawn_cells.size())
	run.brood_carriers_remaining = int(run.current_wave_plan.get("brood_carriers", 0))
	if not _require(run.brood_carriers_remaining == 1, "Tier-four encounter seven should schedule one brood carrier"):
		return
	run.spawn_sequence = int(run.current_wave_plan["brood_carrier_slot"])
	run._spawn_spider(false)
	var carrier = run.enemies.back()
	if not _require(carrier.is_brood_carrier and carrier.carrier_target_cell.x >= 0, "A scheduled carrier should claim a connected procedural nest socket"):
		return
	if not _require(not carrier.hunts_player and not carrier.hunts_turrets and not carrier.is_explorer, "Carriers should commit to nesting instead of conflicting combat tactics"):
		return

	var approach: Vector2i = run._brood_nest_approach(carrier.carrier_target_cell)
	carrier.position = run.grid.cell_to_world(approach)
	carrier.carrier_channel = run.BROOD_CARRIER_CHANNEL - 0.1
	if not _require(run._update_brood_carrier(carrier, 0.2), "A surviving carrier should establish its nest after the telegraphed channel"):
		return
	if not _require(run.brood_nests.size() == 1 and run.brood_nests[0].maturity < 1.0, "A new nest should incubate before joining wave traffic"):
		return
	run.enemies.clear()

	var nest = run.brood_nests[0]
	nest.maturity = 0.99
	run._update_brood_nests(1.0)
	if not _require(nest.maturity >= 1.0 and run.grid.spawn_cells.has(nest.cell), "A mature nest should become a spawn source"):
		return
	run.grid.activate_lanes(2)
	if not _require(run.grid.get_weighted_spawn_cell(0) == run.grid.spawn_cell and run.grid.get_weighted_spawn_cell(1) == nest.cell, "The original hive should retain half the weighted traffic while nests create flanks"):
		return

	nest.spawn_cooldown = 0.0
	run._update_brood_nests(0.1)
	if not _require(not run.enemies.is_empty() and run._wave_blocking_enemy_count() == 0, "Local nest pulses must add pressure without trapping wave completion"):
		return

	run.wave_active = true
	run.enemies.clear()
	var regional_cap: int = run.hive_awareness.regional_population_cap()
	for fill_index in range(regional_cap):
		run._spawn_broodling(nest.cell, fill_index, false)
	nest.spawn_cooldown = 0.0
	var enemies_before: int = run.enemies.size()
	run._update_brood_nests(0.1)
	if not _require(run.enemies.size() == enemies_before, "Nest pulses must respect the regional population cap during an active party"):
		return

	var nest_cell: Vector2i = nest.cell
	run._damage_brood_nest(0, 9999.0, false)
	if not _require(run.destroyed_brood_nests.has(nest_cell), "Destroying a nest should persist its purged state"):
		return
	if not _require(run._brood_nest_index_at_cell(nest_cell) < 0, "Destroying a nest should remove that exact chamber from the live nest roster"):
		return
	if not _require(not run.grid.spawn_cells.has(nest_cell), "Destroying a nest should close its spawn front"):
		return

	run.enemies.clear()
	run.wave_active = true
	var straggler := RUN_SCRIPT.Spider.new()
	straggler.is_explorer = true
	straggler.counts_for_wave = true
	straggler.target_base_id = run.base_network.COMMAND_ID
	straggler.position = run.player_position + Vector2(run.WAVE_RELOCATE_PLAYER_SAFE_RADIUS + 40.0, 0.0)
	run.enemies.append(straggler)
	run._recall_wave_stragglers()
	if not _require(not straggler.is_explorer and straggler.cleanup_recalled, "Cleanup should recall expedition stragglers into a visible siege route"):
		return

	print("CRAWL_BRAWL_BROOD_ECOLOGY_TEST_OK")
	quit(0)
