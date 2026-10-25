extends SceneTree

const MOB_LOCOMOTION := preload("res://systems/mob_locomotion.gd")
const MAIN_SCENE := preload("res://scenes/main.tscn")


func _initialize() -> void:
	call_deferred("_run_mob_locomotion_test")


func _run_mob_locomotion_test() -> void:
	var near := MOB_LOCOMOTION.travel_scale(80.0, 90.0, 8, false, false)
	var mid := MOB_LOCOMOTION.travel_scale(190.0, 210.0, 8, false, false)
	var far := MOB_LOCOMOTION.travel_scale(320.0, 340.0, 8, false, false)
	assert(near == 1.0, "Mobs near the player and core should move at authored speed")
	assert(mid > near and far > mid, "Catch-up speed should ramp smoothly instead of snapping at a hidden threshold")
	assert(MOB_LOCOMOTION.travel_scale(320.0, 90.0, 8, false, false) == 1.0, "Mobs near the core should not get distant catch-up speed")
	assert(MOB_LOCOMOTION.travel_scale(320.0, 340.0, 8, true, false) == MOB_LOCOMOTION.RECALL_SPEED_SCALE, "Recalled stragglers should use one fixed sweep speed")
	assert(MOB_LOCOMOTION.travel_scale(80.0, 90.0, 8, false, true) == MOB_LOCOMOTION.CARRIER_TRAVEL_SCALE, "Brood carriers should use one fixed travel boost")

	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main.start_run("bastion")
	await process_frame
	var run = main.current_screen
	run.wave = 4
	run._spawn_spider(false)
	var swarm: Object = run.enemies.back()
	var expected_swarm_speed: float = MOB_LOCOMOTION.swarm_speed(swarm.role == run.ROLE_SPITTER, run.wave, float(run.difficulty["enemy_speed"]))
	assert(is_equal_approx(swarm.speed, expected_swarm_speed), "Spawned swarm speed should match the locomotion contract")
	var brood_spawn_cell: Vector2i = run._prepared_spider_spawn_cell_near(run.grid.core_cell, 7, 24, 5701)
	assert(brood_spawn_cell != Vector2i(-1, -1) and run._spawn_broodling(brood_spawn_cell, 0, false), "Broodling locomotion fixture should spawn outside the new base exclusion radius")
	var broodling = run.enemies.back()
	assert(broodling.speed > expected_swarm_speed, "Broodlings should remain faster than wave swarmers by design")

	run.enemies.clear()
	# Carrier locomotion is the subject of this test; prepare deterministic nest
	# sockets so random lazy discovery order cannot turn it into a spawn-control test.
	run.grid.materialize_all_discoveries_for_tests()
	run.spawn_sequence = int(run.current_wave_plan.get("brood_carrier_slot", 0))
	run.brood_carriers_remaining = 1
	run._spawn_spider(false)
	var carrier = run.enemies.back()
	assert(carrier.is_brood_carrier, "Carrier setup should still succeed without permanent base-speed inflation")
	run._demote_brood_carrier(carrier)
	assert(is_equal_approx(carrier.speed, MOB_LOCOMOTION.swarm_speed(carrier.role == run.ROLE_SPITTER, run.wave, float(run.difficulty["enemy_speed"]))), "Demoted carriers should revert to normal authored speed")

	print("CRAWL_BRAWL_MOB_LOCOMOTION_TEST_OK")
	quit(0)
