extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const MATERIAL_ECONOMY := preload("res://systems/material_economy.gd")


func _initialize() -> void:
	call_deferred("_run_uix_polish_test")


func _run_uix_polish_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.show_menu()
	await process_frame
	var menu = main.current_screen
	assert(menu.get_node_or_null("ExpeditionProfileCard") != null, "Main menu should present difficulty details inside a dedicated expedition profile card")
	assert("FIRST CONTACT" in menu.difficulty_summary.text and "ENTRY RATE" in menu.difficulty_summary.text and "WAVE" not in menu.difficulty_summary.text, "Difficulty card should expose open-world contact pacing without wave terminology")

	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.selected_build = RUN_SCRIPT.BUILD_SENTRY
	run.scrap = 100
	run.build_target = run.grid.core_cell + Vector2i(-3, 0)
	run.build_mode = true
	await process_frame
	assert(run._build_role_label(RUN_SCRIPT.BUILD_SENTRY) == "DEFENSE" and run._build_range(RUN_SCRIPT.BUILD_SENTRY) == 128.0, "Build mode should expose visual role and range data for placement feedback")
	run.build_mode = false
	run._open_core_base()
	assert(run.core_tab_buttons.size() == run.SHOP_PAGES.size(), "Every configured Core terminal department should expose one navigation tab")
	assert(run.core_base_panel.get_node_or_null("ServiceScroll") != null, "Shop actions should live in a bounded scroll region")
	assert(run.core_detail_title.clip_text and run.core_detail_body.clip_text and run.core_detail_state.clip_text, "Shop details should never draw outside their card")
	run._set_core_menu_page("construction")
	assert(run.extra_action_button2.visible, "Construction's ninth action should remain reachable")
	assert(not run.core_detail_state.text.is_empty() and not run.core_detail_state.text.begins_with("STATUS"), "Shop detail card should show the purchase state without a redundant status prefix")

	for material_id: String in run.material_economy.RAW_ORDER:
		run.material_economy.raw[material_id] = 0
	for material_id: String in run.material_economy.REFINED_ORDER:
		run.material_economy.refined[material_id] = 0
	run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE] = 3
	var chest = RUN_SCRIPT.Structure.new()
	chest.kind = RUN_SCRIPT.BUILD_CHEST_SMALL
	chest.position = run.player_position
	chest.chest_capacity = 100
	run.structures.append(chest)
	run._close_core_base()
	run._open_chest(run.structures.size() - 1)
	assert("FIELD PACK" in run.chest_player_heading.text and "VAULT CARGO" in run.chest_vault_heading.text, "Chest transfer sides should be clearly labeled")
	assert(run.chest_actions.size() == 2 and run.chest_actions[0] is Button, "Chest bulk transfers should be real clickable buttons")
	assert(not run.chest_actions[0].disabled and run.chest_actions[1].disabled, "Chest action states should reflect available cargo")
	run.chest_actions[0].pressed.emit()
	assert(int(run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE]) == 0 and int(chest.inventory[MATERIAL_ECONOMY.COPPER_ORE]) == 3, "Deposit button should transfer pack cargo")
	assert(run.chest_actions[0].disabled and not run.chest_actions[1].disabled, "Chest buttons should refresh after a transfer")
	run.chest_actions[1].pressed.emit()
	assert(int(run.material_economy.raw[MATERIAL_ECONOMY.COPPER_ORE]) == 3 and chest.inventory.is_empty(), "Withdraw button should transfer vault cargo")

	print("CRAWL_BRAWL_UIX_MENU_SHOP_CHEST_TEST_OK")
	quit(0)
