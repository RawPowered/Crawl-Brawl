extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const FORTRESS := preload("res://systems/ruined_fortress.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")


func _initialize() -> void:
	call_deferred("_run")


func _locked_count(run) -> int:
	var count := 0
	for weapon_id in [run.WEAPON_SMG, run.WEAPON_RAILGUN, run.WEAPON_FLAMETHROWER]:
		if not run.unlocked_weapons[weapon_id]:
			count += 1
	for construction_id in ["reinforced_barrier", "land_mine", "rocket_turret", "blast_barrier", "laser_turret"]:
		if not bool(run.construction_unlocks.get(construction_id, false)):
			count += 1
	return count


func _run() -> void:
	var unlocks: Array[bool] = [true, true, true, false, false, false]
	var construction := {"reinforced_barrier": false, "land_mine": false, "rocket_turret": false, "blast_barrier": false, "laser_turret": false}
	var common_reward := FORTRESS.choose_locked_reward(123, Vector2i(48, 48), unlocks, construction, 0)
	assert(not common_reward.is_empty() and int(common_reward.get("tier", 99)) == 0, "Low-luck caches should select from still-locked common relics")
	assert(FORTRESS.luck_tier(2, 0, 0) < FORTRESS.luck_tier(14, 20, 4), "Exploration depth and progression should expand the relic luck range")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	var origin_region: Vector2i = run.grid.region_for_cell(run.grid.core_cell)
	var spawned := false
	for region_y in range(1, ceili(float(run.grid.height) / float(WORLD_GRID.REGION_SIZE)) - 1):
		for region_x in range(1, ceili(float(run.grid.width) / float(WORLD_GRID.REGION_SIZE)) - 1):
			var region := Vector2i(region_x, region_y)
			if not FORTRESS.should_spawn(run.run_seed, region, origin_region):
				continue
			var region_center: Vector2i = region * WORLD_GRID.REGION_SIZE + Vector2i(12, 12)
			run.grid.activate_region_window([region_center], 1)
			if run._ensure_ruined_fortress_in_region(region):
				spawned = true
				break
		if spawned:
			break
	assert(spawned, "A deterministic eligible prepared region should materialize a ruined fortress")
	var fortress_chest = null
	var ruin_wall_count := 0
	for structure in run.structures:
		if structure.fortress_chest:
			fortress_chest = structure
		if structure.is_ruin and not structure.fortress_chest:
			ruin_wall_count += 1
	assert(fortress_chest != null and ruin_wall_count >= 10, "A fortress should resemble a broken defensive shell around a salvage chest")
	assert(run.grid.is_region_active(fortress_chest.cell) and not fortress_chest.inventory.is_empty(), "Fortress content must exist only in active prepared terrain and include minor loot")
	var locked_before := _locked_count(run)
	var reward_label: String = run._claim_fortress_reward(fortress_chest)
	assert(not reward_label.is_empty() and fortress_chest.fortress_reward_claimed, "Opening a fortress chest should claim exactly one relic")
	assert(_locked_count(run) == locked_before - 1, "The relic should unlock one item the player did not already own")
	var serialized: Array[Dictionary] = run._serialize_structures()
	run._restore_structures(serialized)
	var restored_cache_count := 0
	for structure in run.structures:
		if structure.fortress_chest and structure.fortress_reward_claimed:
			restored_cache_count += 1
	assert(restored_cache_count == 1, "Fortress chest identity and claimed state should survive structure persistence")
	print("CRAWL_BRAWL_RUINED_FORTRESS_TEST_OK")
	quit(0)
