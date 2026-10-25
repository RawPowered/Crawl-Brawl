extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const PLAYER_ARMOR := preload("res://systems/player_armor.gd")


func _initialize() -> void:
	call_deferred("_run_player_armor_test")


func _run_player_armor_test() -> void:
	assert(PLAYER_ARMOR.strength_multiplier(0) == 1.0 and PLAYER_ARMOR.defense_multiplier(0) == 1.0, "Survey Suit should stay baseline")
	assert(PLAYER_ARMOR.strength_multiplier(1) == 1.06 and PLAYER_ARMOR.defense_multiplier(1) == 0.94, "Bronze-tier Foundry Suit should expose the lowest paid boost")
	assert(PLAYER_ARMOR.strength_multiplier(2) == 1.12 and PLAYER_ARMOR.defense_multiplier(2) == 0.88, "Silver-tier Containment Suit should outscale bronze")
	assert(PLAYER_ARMOR.strength_multiplier(3) == 1.20 and PLAYER_ARMOR.defense_multiplier(3) == 0.80, "Diamond-tier Frontier Veteran should expose the strongest boost")
	assert(PLAYER_ARMOR.tier_label(3) == "DIAMOND", "Frontier Veteran should map to the diamond armor tier")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	assert(run.player_strength_multiplier == 1.0 and run.player_defense_multiplier == 1.0, "A new run should start on baseline armor multipliers")

	var survey_scale: float = run._weapon_damage_scale(0)
	run.player_style_id = 3
	run.unlocked_player_styles[3] = true
	run._rebuild_player_armor_multipliers()
	assert(run._weapon_damage_scale(0) > survey_scale, "Equipping a higher-tier suit should raise weapon damage scaling")

	run.player_health = 100.0
	run.player_style_id = 0
	run._rebuild_player_armor_multipliers()
	run._hurt_player(10.0)
	var survey_damage: float = 100.0 - run.player_health
	run.player_health = 100.0
	run.player_invulnerability = 0.0
	run.player_style_id = 3
	run._rebuild_player_armor_multipliers()
	run._hurt_player(10.0)
	assert(run.player_health > 100.0 - survey_damage, "Higher-tier armor should reduce incoming damage")

	run.player_style_id = 1
	run.unlocked_player_styles[1] = true
	run._purchase_or_equip_style(1)
	assert(run.player_strength_multiplier == PLAYER_ARMOR.strength_multiplier(1), "Equipping a suit should refresh armor multipliers immediately")

	print("CRAWL_BRAWL_PLAYER_ARMOR_TEST_OK")
	quit(0)
