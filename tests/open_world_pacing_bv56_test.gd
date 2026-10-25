extends SceneTree

const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")
const WAVE_DIRECTOR := preload("res://systems/wave_director.gd")
const BASE_NETWORK := preload("res://systems/base_network.gd")
const WORLD_GRID := preload("res://systems/world_grid.gd")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# Encounter history is metadata, not a difficulty input. Same ecology pressure
	# must produce the same hunting-party plan whether it is contact 1 or 999.
	var first := WAVE_DIRECTOR.build_encounter_plan("bastion", 4, 2, 1, 3)
	var late := WAVE_DIRECTOR.build_encounter_plan("bastion", 4, 2, 999, 3)
	for key: String in ["spawn_count", "spawn_interval", "active_lanes", "boss_count", "broodling_pack", "brood_carriers"]:
		assert(first[key] == late[key], "encounter count must not change open-world hunting-party pacing: %s" % key)
	assert(int(first["boss_count"]) == 0, "periodic encounter bosses must stay retired; guardians are world entities")
	assert(int(first["wave"]) != int(late["wave"]), "legacy encounter history should remain available as metadata")

	# Awareness, not encounter count, owns contact density and cadence.
	assert(DIFFICULTY_PROFILE.encounter_spawn_count("bastion", 4) > DIFFICULTY_PROFILE.encounter_spawn_count("bastion", 0), "awareness should raise hunting-party population")
	assert(DIFFICULTY_PROFILE.encounter_spawn_interval("bastion", 4) <= DIFFICULTY_PROFILE.encounter_spawn_interval("bastion", 0), "awareness should tighten hunting-party entry cadence")

	# Frontier construction is exploration/guardian gated and invariant to any
	# historical wave value passed through the schema-compatibility wrapper.
	var network := BASE_NETWORK.new()
	network.configure(Vector2i(50, 50), 120, 120)
	network.mark_guardian_cleared(BASE_NETWORK.NORTH_ID)
	assert(network.can_construct_open_world(BASE_NETWORK.NORTH_ID, 4, false), "cleared surveyed frontier site should be constructible")
	assert(network.can_construct(BASE_NETWORK.NORTH_ID, 0, 4, false) == network.can_construct(BASE_NETWORK.NORTH_ID, 9999, 4, false), "historical wave count must not affect frontier construction")

	# Active-world budgets remain smaller than the prepared deterministic world.
	assert(WORLD_GRID.MAX_RENDER_REGIONS == 12, "BV5.6 render envelope should stay bounded to 12 regions")
	assert(WORLD_GRID.MAX_SIMULATION_REGIONS == 25, "BV5.6 simulation envelope should stay bounded to a 5x5 regional halo")
	assert(WORLD_GRID.MAX_SIMULATION_REGIONS <= WORLD_GRID.MAX_FLOW_REGIONS, "every simulation-active region must fit flow coverage")

	# Low-frequency ecology remains bounded and may deliberately slow under a
	# pathological frame rather than replaying a backlog and spiraling. BV5.7
	# lowered the authority clock to 10 Hz and a single maximum step per frame.
	assert(is_equal_approx(RUN_SCRIPT.WORLD_ECOLOGY_TICK_INTERVAL, 0.10), "world ecology should tick at the bounded 10 Hz authority rate")
	assert(RUN_SCRIPT.WORLD_ECOLOGY_MAX_STEPS_PER_FRAME == 1, "ecology must never catch up with multiple authority steps in one display frame")

	print("CRAWL_BRAWL_OPEN_WORLD_PACING_BV56_TEST_OK")
	quit(0)
