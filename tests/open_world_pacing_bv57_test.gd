extends SceneTree

const HIVE_AWARENESS := preload("res://systems/hive_awareness.gd")
const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# Early exploration is protected from hidden difficulty growth.
	var awareness = HIVE_AWARENESS.new()
	assert(HIVE_AWARENESS.TIER_THRESHOLDS[1] >= 8, "The first Hive Awareness tier must not arrive after only a few passive events")
	assert(HIVE_AWARENESS.MIN_REGIONS_FOR_HUNTING_PARTY >= 3, "Hunting parties require an established exploration footprint")
	assert(awareness.encounter_threshold() >= 6, "One early scout report must be insufficient to authorize a hunting party")
	assert(awareness.encounter_party_size() == 4, "The first hunting party should be a small contact group")
	assert(awareness.encounter_recovery_seconds() >= 60.0, "New games need a meaningful build/explore recovery window")

	# Nests begin after the opening phase and mature slowly enough to be discovered,
	# prepared for and attacked instead of immediately becoming a spawn conveyor.
	assert(RUN_SCRIPT.NEST_MILESTONE_AWARENESS_TIERS[0] >= 2, "The first remote brood milestone must not be tier I")
	assert(RUN_SCRIPT.BROOD_NEST_INCUBATION >= 90.0, "New brood nests need a readable incubation period")
	assert(RUN_SCRIPT.BROOD_NEST_AGGRO_RADIUS <= 150.0, "Brood bases should require deliberate proximity before awakening")

	# Background ecology is bounded to one authority step. A slow display frame may
	# slow simulation but may never repay multiple overdue ticks in a burst.
	assert(is_equal_approx(RUN_SCRIPT.WORLD_ECOLOGY_TICK_INTERVAL, 0.10), "BV5.7 ecology authority should run at 10 Hz")
	assert(RUN_SCRIPT.WORLD_ECOLOGY_MAX_STEPS_PER_FRAME == 1, "BV5.7 ecology catch-up must be one step maximum")

	# Source-level contracts for the measured DEV009 frame-spike causes.
	var run_source := FileAccess.get_file_as_string("res://scripts/phase0_run.gd")
	var world_source := FileAccess.get_file_as_string("res://systems/run_components/run_world_presentation.gd")
	var hud_source := FileAccess.get_file_as_string("res://systems/run_components/run_hud_presentation.gd")
	assert(run_source.contains("if _visible_terrain_raster_pending():"), "Ecology should yield to an already-pending visible terrain raster")
	assert(run_source.contains("terrain_raster_scheduled_this_frame"), "The runtime should prevent terrain and lighting heavy draws from stacking")
	assert(run_source.contains("ecology_tick_ran_this_frame"), "Lighting should also yield on ecology authority frames so heavy phases cannot stack")
	assert(not run_source.contains("_ecology_profile_call("), "Ecology profiling should not allocate per-tick Callable/lambda wrappers")
	assert(not run_source.contains("_service_visual_region_builds(visual_budget)"), "Decorative presentation caches should not be eagerly built during live streaming")
	assert(not run_source.contains("_service_visual_region_builds(1)"), "Run bootstrap must not synchronously build a decorative region before exploration begins")
	assert(world_source.contains("_chunk_formations_cache = {} if lean_draw"), "Lean terrain must bypass formation-cache generation")
	assert(world_source.contains("if _terrain_chunk_draw_lean:"), "Lean terrain should use a reduced active-play material path")
	assert(world_source.contains("if not (floor_down or floor_up or floor_right or floor_left):"), "Wall edges should reuse cardinal adjacency instead of rescanning eight neighbors")
	assert(hud_source.contains("host.visual_prop_cache.get(region, [])"), "Lighting must consume cached props instead of synthesizing decorative caches")

	print("CRAWL_BRAWL_OPEN_WORLD_PACING_BV57_TEST_OK")
	quit(0)
