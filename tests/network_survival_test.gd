extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")
const BASE_NETWORK := preload("res://systems/base_network.gd")


func _initialize() -> void:
	call_deferred("_run_network_survival_test")


func _run_network_survival_test() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen

	run.base_network.bases[BASE_NETWORK.NORTH_ID]["revealed"] = true
	run.base_network.mark_guardian_cleared(BASE_NETWORK.NORTH_ID)
	assert(run.base_network.begin_activation(BASE_NETWORK.NORTH_ID), "Frontier activation should start")
	run.base_network.tick_activation(BASE_NETWORK.ACTIVATION_DURATION)
	assert(run.base_network.get_status(BASE_NETWORK.NORTH_ID) == BASE_NETWORK.STATUS_ACTIVE, "Frontier core should come online")

	run._damage_base(BASE_NETWORK.COMMAND_ID, 99999.0)
	assert(not run.game_over, "Command Core loss should not end the run while another base stays active")
	assert(run.base_network.get_status(BASE_NETWORK.COMMAND_ID) == BASE_NETWORK.STATUS_DISABLED, "Command Core should enter recoverable disabled state")

	run._damage_base(BASE_NETWORK.NORTH_ID, 99999.0)
	assert(run.game_over, "The run should end once every base is offline")
	assert("BASE NETWORK OFFLINE" in run.game_over_label.text, "Defeat copy should reflect total network loss")

	print("CRAWL_BRAWL_NETWORK_SURVIVAL_TEST_OK")
	quit(0)
