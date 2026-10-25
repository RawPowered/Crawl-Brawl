extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_shop_economy_test")


func _clear_inventory(run) -> void:
	for material_id: String in run.material_economy.RAW_ORDER:
		run.material_economy.raw[material_id] = 0
	for material_id: String in run.material_economy.REFINED_ORDER:
		run.material_economy.refined[material_id] = 0
	for stock_id: String in run.deployable_stock.keys():
		run.set_kit_stock(stock_id, 0)


func _run_shop_economy_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	_clear_inventory(run)
	run._open_core_base()
	run._set_core_menu_page("construction")
	assert("LASER TURRET" in run.core_service_buttons[7].text, "The Laser Turret fabrication row must not be overwritten by kit information")

	var raw_before: int = int(run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE])
	run._spawn_pickup(run.player_position, MATERIAL_ECONOMY.COPPER_ORE, 3, Vector2.ZERO)
	run._process(0.1)
	assert(run.pickups.is_empty(), "A pickup touching the player should be swallowed while the shop is open")
	assert(int(run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE]) == raw_before + 3, "Shop-time pickups should enter the real inventory immediately")

	_clear_inventory(run)
	run.set_kit_stock("rocket_turret", 2)
	run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE] = 4
	assert(run._backpack_used() == 4, "Backpack material load should ignore kit stack slots")

	# Kits use free stack slots; material capacity is independent.
	_clear_inventory(run)
	run.backpack_tier = 1
	run.scrap = 25
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 1
	run.material_economy.refined[MATERIAL_ECONOMY.GOLD_INGOT] = 77
	run._purchase_or_research_construction(1)
	assert(run.kit_count("granite_barrier") == 1 and run._backpack_used() == 77, "Fabrication should consume craft materials and grant a kit stack")

	# Fill every gear slot so craft cannot accept a new kit stack.
	_clear_inventory(run)
	run.scrap = 25
	run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT] = 1
	run.material_economy.refined[MATERIAL_ECONOMY.GOLD_INGOT] = 10
	var Loadout := preload("res://systems/operator_loadout.gd")
	for slot_i in range(Loadout.BACKPACK_SIZE):
		run.operator_loadout.set_slot("backpack", slot_i, Loadout.make_stack(Loadout.KIND_DEPLOYABLE, "chest_small", Loadout.STACK_MAX))
	for slot_i in range(Loadout.HOTBAR_SIZE):
		run.operator_loadout.set_slot("hotbar", slot_i, Loadout.make_stack(Loadout.KIND_DEPLOYABLE, "chest_medium", Loadout.STACK_MAX))
	run._sync_deployable_mirror()
	var kits_before: int = run.kit_count("granite_barrier")
	run._purchase_or_research_construction(1)
	assert(run.kit_count("granite_barrier") == kits_before, "Over-slot fabrication must not create a kit")
	assert(run.scrap == 25 and int(run.material_economy.refined[MATERIAL_ECONOMY.BRONZE_INGOT]) == 1, "Blocked fabrication must deduct neither credits nor components")

	assert(run._deployable_storage_upgrade_cost(0) == 65 and run._deployable_storage_upgrade_cost(1) == 120, "Deployable storage upgrades should use the intended first and second prices")
	assert(run._deployable_storage_upgrade_requirements(0).has(MATERIAL_ECONOMY.BRONZE_INGOT), "The first storage upgrade should require Bronze")
	assert(run._deployable_storage_upgrade_requirements(1).has(MATERIAL_ECONOMY.CRYSTAL_CORE), "The second storage upgrade should require advanced components")
	for stock_id: String in run.DEPLOYABLE_STORAGE_ORDER:
		run.construction_unlocks[stock_id] = true
		run.deployable_storage_tiers[stock_id] = 2
	run.deployable_storage_tiers["chest_small"] = 0
	run.storage_upgrade_focus_index = run.DEPLOYABLE_STORAGE_ORDER.find("chest_small")
	assert(run._storage_deployable_focus_id() == "chest_small", "Storage upgrades should include vault kits as well as defense kits")

	var chest = RUN_SCRIPT.Structure.new()
	chest.kind = RUN_SCRIPT.BUILD_CHEST_SMALL
	chest.chest_capacity = 100
	chest.inventory = {MATERIAL_ECONOMY.COPPER_ORE: 4, MATERIAL_ECONOMY.STEEL_PLATE: 2}
	run.structures.append(chest)
	run.material_economy.foundry_tier = 1
	run._set_core_menu_page("storage")
	assert("6 TOTAL UNITS STORED" in run.core_service_buttons[3].text, "The Storage page should total the real contents of placed vaults")

	_clear_inventory(run)
	run.material_economy.foundry_tier = 1
	run.deployable_stock["chest_small"] = run._deployable_cap("chest_small")
	var chest_stock_before: int = int(run.deployable_stock["chest_small"])
	run._purchase_or_craft_storage(0)
	assert(int(run.deployable_stock["chest_small"]) == chest_stock_before, "Vault fabrication must respect its upgraded stock cap")

	# Ammunition uses weapon reserves, so a full material pack must not block a
	# regional ammo service, and the service must clamp at the reserve cap.
	_clear_inventory(run)
	run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE] = run._backpack_capacity()
	run.current_base_id = BASE_NETWORK.NORTH_ID
	run.base_network.bases[BASE_NETWORK.NORTH_ID]["status"] = BASE_NETWORK.STATUS_ACTIVE
	run.scrap = 35
	run.railgun_reserve = run.AMMO_RESERVE_CAPS[run.WEAPON_RAILGUN] - 2
	run.laser_energy = 50.0
	run._purchase_regional_service()
	assert(run.scrap == 0 and run.railgun_reserve == run.AMMO_RESERVE_CAPS[run.WEAPON_RAILGUN] and run.laser_energy == 100.0, "Regional ammo service should ignore pack load and never exceed reserve caps")

	_clear_inventory(run)
	run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE] = 5
	run._open_backpack()
	var reload_event := InputEventAction.new()
	reload_event.action = "reload"
	reload_event.pressed = true
	run._unhandled_input(reload_event)
	assert(int(run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE]) == 5, "Reload while the backpack is open must not discard raw ore")
	run._close_backpack()

	print("CRAWL_BRAWL_SHOP_ECONOMY_TEST_OK")
	quit(0)
