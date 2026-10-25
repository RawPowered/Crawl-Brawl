extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const FOUNDRY_UNIT := preload("res://systems/foundry_unit.gd")


func _initialize() -> void:
	call_deferred("_run_foundry_operations_test")


func _run_foundry_operations_test() -> void:
	var economy: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	assert(economy.unlock_foundry() and economy.foundry_batch_duration() == 8.0, "Foundry MK1 should process eight-second common batches")
	economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 6)
	economy.add_raw(MATERIAL_ECONOMY.IRON_ORE, 2)
	economy.add_raw(MATERIAL_ECONOMY.COAL, 4)
	assert(economy.can_refine(MATERIAL_ECONOMY.COPPER_ORE), "Foundry MK1 should accept common Copper")
	assert(not economy.can_refine(MATERIAL_ECONOMY.IRON_ORE), "Industrial Iron should require Foundry MK2")
	assert(economy.queue_refinement(MATERIAL_ECONOMY.COPPER_ORE), "A complete MK1 batch should enter the queue")
	assert(int(economy.raw[MATERIAL_ECONOMY.COPPER_ORE]) == 3 and int(economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 0, "Queued inputs should reserve immediately without instant output")
	economy.tick_foundry(20.0, false)
	assert(economy.active_recipe_remaining == 8.0, "An offline Foundry should preserve its active timer")
	economy.tick_foundry(7.9, true)
	assert(int(economy.foundry_output[MATERIAL_ECONOMY.BRONZE_INGOT]) == 0, "MK1 output should not arrive before eight seconds")
	economy.tick_foundry(0.1, true)
	assert(int(economy.foundry_output[MATERIAL_ECONOMY.BRONZE_INGOT]) == 2 and int(economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 0, "Completed batches should remain in the Foundry output buffer until collected")
	assert(economy.sell_foundry_output() == 0 and economy.foundry_output_total() == 2, "Foundry MK1 should require manual output collection and Core-market travel")

	assert(economy.queue_refinement(MATERIAL_ECONOMY.COPPER_ORE), "A second common batch should queue")
	economy.tick_foundry(2.0, true)
	assert(economy.unlock_foundry() and economy.foundry_batch_duration() == 4.0, "Foundry MK2 should halve batch duration")
	assert(is_equal_approx(economy.active_recipe_remaining, 3.0), "Upgrading should accelerate the active batch without resetting progress")
	economy.tick_foundry(3.0, true)
	assert(int(economy.foundry_output[MATERIAL_ECONOMY.BRONZE_INGOT]) == 4, "The accelerated active batch should complete into the output buffer")
	assert(economy.can_refine(MATERIAL_ECONOMY.IRON_ORE), "Foundry MK2 should unlock industrial recipes")
	assert(not economy.can_refine(MATERIAL_ECONOMY.SULFUR), "Advanced recipes should remain gated until MK3")
	assert(economy.queue_refinement(MATERIAL_ECONOMY.IRON_ORE), "An unlocked industrial recipe should queue")
	economy.tick_foundry(1.5, true)
	var legacy_save: Dictionary = {
		"raw": economy.raw.duplicate(true),
		"refined": economy.refined.duplicate(true),
		"foundry_output": economy.foundry_output.duplicate(true),
		"foundry_tier": economy.foundry_tier,
		"foundry_queue": economy.foundry_queue.duplicate(),
		"active_recipe": economy.active_recipe,
		"active_recipe_remaining": economy.active_recipe_remaining,
		"active_recipe_duration": economy.active_recipe_duration,
	}
	var restored: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	restored.restore(legacy_save)
	assert(restored.active_recipe == MATERIAL_ECONOMY.IRON_ORE and is_equal_approx(restored.active_recipe_remaining, 2.5), "Legacy save payloads should still restore active Foundry work")
	var modern_save: Dictionary = economy.serialize()
	assert(not modern_save.has("active_recipe") and not modern_save.has("foundry_queue") and not modern_save.has("foundry_output"), "Modern saves should omit legacy global Foundry production")
	var modern_restore: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	modern_restore.restore(modern_save)
	assert(modern_restore.active_recipe.is_empty() and modern_restore.queue_size() == 0 and modern_restore.foundry_output_total() == 0, "Modern saves should not resurrect ghost global Foundry state")
	restored.tick_foundry(2.5, true)
	assert(int(restored.foundry_output[MATERIAL_ECONOMY.STEEL_PLATE]) == 1, "Restored Foundry work should complete exactly once into persistent output storage")
	var collected := restored.collect_foundry_output(2)
	assert(int(collected.get(MATERIAL_ECONOMY.BRONZE_INGOT, 0)) == 2 and int(restored.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 2 and restored.foundry_output_total() == 3, "Collection should move only the number of output units that fit")
	assert(restored.sell_foundry_output() == 86 and restored.foundry_output_total() == 0 and int(restored.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 2, "MK2 teleport sale should liquidate only buffered output and retain carried components")

	var foundry_structure := RUN_SCRIPT.Structure.new()
	foundry_structure.kind = RUN_SCRIPT.BUILD_FOUNDRY
	foundry_structure.level = 1
	FOUNDRY_UNIT.ensure_state(foundry_structure)
	assert(FOUNDRY_UNIT.queue_limit(1) == 6 and FOUNDRY_UNIT.output_limit(1) == 20, "MK1 facilities should expose modest queue and storage limits")
	assert(FOUNDRY_UNIT.queue_limit(3) == 28 and FOUNDRY_UNIT.output_limit(3) == 96, "MK3 facilities should expose the largest queue and storage limits")
	var facility_economy: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	facility_economy.foundry_tier = 1
	facility_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	facility_economy.add_raw(MATERIAL_ECONOMY.COAL, 2)
	assert(FOUNDRY_UNIT.queue_refinement(foundry_structure, facility_economy, MATERIAL_ECONOMY.COPPER_ORE), "Per-facility queues should accept complete recipes")
	FOUNDRY_UNIT.tick(foundry_structure, facility_economy, 8.1, true)
	assert(FOUNDRY_UNIT.output_total(foundry_structure) == 2 and FOUNDRY_UNIT.fuel_remaining(foundry_structure) == 0 and int(facility_economy.raw[MATERIAL_ECONOMY.COAL]) == 1, "Each batch should consume one coal to run")
	facility_economy.raw[MATERIAL_ECONOMY.COAL] = 0
	foundry_structure.foundry_state[FOUNDRY_UNIT.STATE_COAL_FUEL] = 0
	assert(not FOUNDRY_UNIT.queue_refinement(foundry_structure, facility_economy, MATERIAL_ECONOMY.COPPER_ORE), "A Foundry without coal should not queue new work")
	facility_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	facility_economy.add_raw(MATERIAL_ECONOMY.COAL, 1)
	assert(FOUNDRY_UNIT.queue_refinement(foundry_structure, facility_economy, MATERIAL_ECONOMY.COPPER_ORE), "Backpack coal should satisfy batch fuel when queueing")
	var output: Dictionary = FOUNDRY_UNIT.output_dict(foundry_structure)
	output[MATERIAL_ECONOMY.STONE_BLOCK] = FOUNDRY_UNIT.output_limit(1) - 2
	assert(FOUNDRY_UNIT.output_full(foundry_structure), "A full buffer should stop further intake")
	facility_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	facility_economy.add_raw(MATERIAL_ECONOMY.COAL, 1)
	assert(not FOUNDRY_UNIT.queue_refinement(foundry_structure, facility_economy, MATERIAL_ECONOMY.COPPER_ORE), "A full buffer should block additional queueing")

	foundry_structure.level = 2
	facility_economy.foundry_tier = 2
	FOUNDRY_UNIT.ensure_state(foundry_structure)
	foundry_structure.foundry_state[FOUNDRY_UNIT.STATE_QUEUE] = []
	foundry_structure.foundry_state[FOUNDRY_UNIT.STATE_ACTIVE_RECIPE] = ""
	foundry_structure.foundry_state[FOUNDRY_UNIT.STATE_ACTIVE_REMAINING] = 0.0
	foundry_structure.foundry_state[FOUNDRY_UNIT.STATE_ACTIVE_DURATION] = 0.0
	for material_id: String in MATERIAL_ECONOMY.REFINED_ORDER:
		FOUNDRY_UNIT.output_dict(foundry_structure)[material_id] = 0
	facility_economy.raw[MATERIAL_ECONOMY.IRON_ORE] = 2
	facility_economy.raw[MATERIAL_ECONOMY.COAL] = 0
	foundry_structure.foundry_state[FOUNDRY_UNIT.STATE_COAL_FUEL] = 2
	assert(FOUNDRY_UNIT.queue_refinement(foundry_structure, facility_economy, MATERIAL_ECONOMY.IRON_ORE), "Industrial recipes should consume recipe coal from the facility buffer")
	assert(int(facility_economy.raw[MATERIAL_ECONOMY.IRON_ORE]) == 0 and FOUNDRY_UNIT.fuel_remaining(foundry_structure) == 0, "Recipe and batch fuel coal should both come from the facility buffer")

	var legacy_target := RUN_SCRIPT.Structure.new()
	legacy_target.kind = RUN_SCRIPT.BUILD_FOUNDRY
	legacy_target.level = 1
	FOUNDRY_UNIT.ensure_state(legacy_target)
	FOUNDRY_UNIT.output_dict(legacy_target)[MATERIAL_ECONOMY.BRONZE_INGOT] = 1
	var legacy_economy: MATERIAL_ECONOMY = MATERIAL_ECONOMY.new()
	legacy_economy.foundry_tier = 1
	legacy_economy.foundry_output[MATERIAL_ECONOMY.SILVER_INGOT] = 2
	legacy_economy.foundry_queue.append(MATERIAL_ECONOMY.COPPER_ORE)
	legacy_economy.active_recipe = MATERIAL_ECONOMY.GOLD_ORE
	FOUNDRY_UNIT.migrate_legacy_state(legacy_target, legacy_economy)
	assert(int(FOUNDRY_UNIT.output_dict(legacy_target)[MATERIAL_ECONOMY.BRONZE_INGOT]) == 1, "Migration should not overwrite existing per-facility buffers")
	assert(legacy_economy.foundry_output_total() == 0 and legacy_economy.queue_size() == 0 and legacy_economy.active_recipe.is_empty(), "Migration should always clear legacy global Foundry state")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.selected_build = RUN_SCRIPT.BUILD_BARRICADE
	for spawn_cell: Vector2i in run.grid.spawn_cells:
		run.player_position = run.grid.cell_to_world(spawn_cell)
		assert(not run._can_place_structure(spawn_cell), "No registered enemy spawn cell may accept a player structure")
	run.player_position = run.grid.cell_to_world(run.grid.core_cell)
	run.material_economy.foundry_tier = 1
	run.material_economy.add_raw(MATERIAL_ECONOMY.COAL, 6)
	run.deployable_stock["foundry"] = 1
	run.selected_build = RUN_SCRIPT.BUILD_FOUNDRY
	var placement_cell := Vector2i(-1, -1)
	for y in range(-5, 6):
		for x in range(-5, 6):
			var candidate: Vector2i = run.grid.core_cell + Vector2i(x, y)
			if run._can_place_structure(candidate):
				placement_cell = candidate
				break
		if placement_cell.x >= 0:
			break
	assert(placement_cell.x >= 0, "The Command Core should expose a valid 2x2 Foundry service pad")
	run._place_structure(placement_cell)
	assert(run._foundry_index() >= 0 and run._foundry_powered(run._foundry_index()), "The placed Foundry should join Command power")
	run.material_economy.add_raw(MATERIAL_ECONOMY.COAL, 2)
	assert(run._foundry_operational(run._foundry_index()), "A powered Foundry needs coal before it can run")
	assert(int(run.deployable_stock["foundry"]) == 0, "Placement should consume the carried Foundry kit")
	var second_cell := placement_cell + Vector2i(3, 0)
	if run._can_place_structure(second_cell):
		run.deployable_stock["foundry"] = 1
		run._place_structure(second_cell)
		assert(run._foundry_count() == 2, "A second kit should allow another Foundry in powered territory")
	assert(run.structures[run._foundry_index()].size == Vector2i(2, 2), "The physical Foundry should retain its 2x2 footprint")
	run.material_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	run.material_economy.add_raw(MATERIAL_ECONOMY.COAL, 2)
	var foundry_index: int = run._foundry_index()
	run.player_position = run.structures[foundry_index].position
	run._open_foundry()
	assert(run.using_foundry and run.foundry_panel.visible and "INDUSTRIAL FOUNDRY" in run.foundry_title.text, "Interacting with the facility should open its own production console")
	assert(run.foundry_action_buttons.size() == 6 and "QUEUE NEXT" in run.foundry_action_buttons[0].text and "COLLECT OUTPUT" in run.foundry_action_buttons[2].text and "COAL FUEL" in run.foundry_action_buttons[5].text, "The Foundry console should expose production, collection, upgrade, teleport, and fuel purchase actions")
	assert(run.foundry_machine_icon.texture != null and run.foundry_recipe_input_icons[0].texture != null and run.foundry_recipe_output_icon.texture != null, "The Foundry should visualize the selected recipe as input, process, and output")
	run._execute_foundry_action(0)
	var active_foundry: RUN_SCRIPT.Structure = run._active_foundry()
	assert(FOUNDRY_UNIT.queue_size(active_foundry) == 1 and int(run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE]) == 0, "The dedicated console should reserve and queue a selected batch")
	FOUNDRY_UNIT.output_dict(active_foundry)[MATERIAL_ECONOMY.BRONZE_INGOT] = 4
	run.material_economy.raw[MATERIAL_ECONOMY.COAL] = 0
	run.material_economy.raw[MATERIAL_ECONOMY.GOLD_ORE] = run._backpack_capacity() - 2
	run._refresh_foundry_panel()
	assert("2 FIT" in run.foundry_action_buttons[2].text, "The collection row should expose current backpack-limited transfer capacity")
	assert(run.foundry_buffer_icons[0].texture != null and run.foundry_buffer_counts[0].text == "x4", "Buffered output should be visible as a material slot instead of text only")
	run._execute_foundry_action(2)
	assert(int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 2 and FOUNDRY_UNIT.output_total(active_foundry) == 2, "Collection should fill available backpack space and leave overflow safely buffered")
	run._refresh_foundry_live_progress()
	assert(run.foundry_action_buttons[2].disabled, "Collection should disable when the backpack has no remaining capacity without waiting for another terminal")
	active_foundry.level = 2
	run.material_economy.foundry_tier = 2
	run.scrap = 5000
	FOUNDRY_UNIT.output_dict(active_foundry)[MATERIAL_ECONOMY.BRONZE_INGOT] = 2
	run._refresh_foundry_panel()
	var carried_bronze_before := int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT])
	var teleport_scrap_before: int = int(run.scrap)
	run._execute_foundry_action(4)
	assert(run.scrap == teleport_scrap_before + 44 and FOUNDRY_UNIT.output_total(active_foundry) == 0 and int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == carried_bronze_before, "MK2 teleport sale should sell only Foundry output and retain the backpack")
	run._close_foundry()
	assert(not run.using_foundry and not run.foundry_panel.visible, "The dedicated Foundry console should close cleanly")
	run.current_base_id = run.base_network.COMMAND_ID
	run._open_core_base()
	run._set_core_menu_page("materials")
	assert("FOUNDRY KIT" in run.core_service_buttons[2].text, "The Core Materials page should allow fabricating additional Foundry kits")
	run.deployable_stock["foundry"] = RUN_SCRIPT.FOUNDRY_KIT_STOCK_CAP
	run.backpack_tier = 1
	run.scrap = 5000
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 20
	run.material_economy.refined[MATERIAL_ECONOMY.STONE_BLOCK] = 20
	run._fabricate_foundry_kit()
	assert(int(run.deployable_stock["foundry"]) == RUN_SCRIPT.FOUNDRY_KIT_STOCK_CAP, "Foundry kit fabrication should respect the stock cap")
	run.deployable_stock["foundry"] = 0
	for slot_i in range(run.operator_loadout.HOTBAR_SIZE):
		run.operator_loadout.set_slot("hotbar", slot_i, run.operator_loadout.make_stack(run.operator_loadout.KIND_BLOCK, "granite", 1))
	for slot_i in range(run.operator_loadout.BACKPACK_SIZE):
		run.operator_loadout.set_slot("backpack", slot_i, run.operator_loadout.make_stack(run.operator_loadout.KIND_BLOCK, "granite", 1))
	run._fabricate_foundry_kit()
	assert(int(run.deployable_stock["foundry"]) == 0, "Foundry kit fabrication should honor a full stack grid")
	for slot_i in range(run.operator_loadout.HOTBAR_SIZE):
		run.operator_loadout.clear_slot("hotbar", slot_i)
	for slot_i in range(run.operator_loadout.BACKPACK_SIZE):
		run.operator_loadout.clear_slot("backpack", slot_i)
	run._sync_deployable_mirror()
	run._close_core_base()
	run.material_economy.raw[MATERIAL_ECONOMY.COAL] = 0
	FOUNDRY_UNIT.ensure_state(active_foundry)
	active_foundry.foundry_state[FOUNDRY_UNIT.STATE_COAL_FUEL] = 0
	run.scrap = RUN_SCRIPT.FOUNDRY_FUEL_BUNDLE_COST
	run._open_foundry_at(foundry_index)
	assert(run._purchase_foundry_fuel(true), "Foundry panel should issue coal into an empty powered buffer")
	assert(FOUNDRY_UNIT.fuel_remaining(active_foundry) == RUN_SCRIPT.FOUNDRY_FUEL_BUNDLE, "Purchased coal should land in the facility buffer")
	assert(int(run.material_economy.raw.get(MATERIAL_ECONOMY.COAL, 0)) == 0, "Purchased coal should not enter the sellable pack while a powered Foundry exists")
	run.material_economy.add_raw(MATERIAL_ECONOMY.COAL, 5)
	assert(run._load_foundry_fuel(), "Manual load should move pack coal into the facility buffer")
	assert(int(run.material_economy.raw.get(MATERIAL_ECONOMY.COAL, 0)) == 0, "Loaded coal should leave the sellable field pack")
	var buffered_before_sell := FOUNDRY_UNIT.fuel_remaining(active_foundry)
	run.material_economy.add_raw(MATERIAL_ECONOMY.COPPER_ORE, 3)
	run.material_economy.sell_raw_quick()
	assert(FOUNDRY_UNIT.fuel_remaining(active_foundry) == buffered_before_sell, "Quick sale should not liquidate Foundry buffer coal")
	run._close_foundry()
	var destroyed_foundry = run.structures[run._foundry_index()]
	run._on_structure_destroyed(destroyed_foundry)
	run.structures.erase(destroyed_foundry)
	assert(int(run.deployable_stock["foundry"]) >= 1 and not run._foundry_operational(run._foundry_index()), "Destroying the facility should pause production and recover a rebuild kit")

	run.material_economy.foundry_tier = 1
	for material_id: String in run.material_economy.RAW_ORDER:
		run.material_economy.raw[material_id] = 0
	for material_id: String in run.material_economy.REFINED_ORDER:
		run.material_economy.refined[material_id] = 0
	run.scrap = RUN_SCRIPT.FOUNDRY_FUEL_BUNDLE_COST
	assert(run._foundry_fuel_purchase_room() >= RUN_SCRIPT.FOUNDRY_FUEL_BUNDLE, "Pre-deploy fuel purchase should leave pack space for a coal bundle")
	assert(run._purchase_foundry_fuel(), "Command Core logistics should sell Foundry coal fuel")
	assert(int(run.material_economy.raw.get(MATERIAL_ECONOMY.COAL, 0)) == RUN_SCRIPT.FOUNDRY_FUEL_BUNDLE, "Purchased Foundry coal should enter the field pack when no powered facility exists")

	print("CRAWL_BRAWL_FOUNDRY_OPERATIONS_TEST_OK")
	quit(0)
