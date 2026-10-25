extends SceneTree

const HIVE_AWARENESS := preload("res://systems/hive_awareness.gd")
const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")
const WAVE_DIRECTOR := preload("res://systems/wave_director.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var awareness = HIVE_AWARENESS.new()
	var origin := Vector2i.ZERO
	assert(awareness.register_prepared_region(origin, false)["accepted"], "The prepared origin should register without creating pressure")
	assert(not awareness.encounter_pending, "Elapsed time and origin boot must not create an encounter")
	assert(not awareness.can_release_encounter(true, false, 0, true), "An encounter requires player-created pressure")

	# BV5.7: passive travel does not itself increase awareness and a scout is not
	# dispatched until the operator has established a small exploration footprint.
	awareness.register_activity("first_breach", origin)
	awareness.register_prepared_region(Vector2i(1, 0), true)
	assert(awareness.peek_scout_request().x < -1000000, "Two surveyed regions should still be a protected exploration window")
	awareness.register_prepared_region(Vector2i(2, 0), true)
	assert(awareness.peek_scout_request() == Vector2i(2, 0), "The third surveyed region may dispatch the first scout")
	assert(awareness.consume_scout_request(Vector2i(2, 0)), "The queued scout request should be consumable")
	awareness.report_scout(Vector2i(2, 0))
	assert(not awareness.encounter_pending, "One scout report must not immediately authorize a hunting party")
	assert(awareness.exploration_pressure == 3, "The first report should create partial contact pressure")

	# A second independent contact, separated by more exploration, is required.
	awareness.register_prepared_region(Vector2i(3, 0), true)
	assert(awareness.peek_scout_request().x < -1000000, "Early scout contacts should be separated by more than one new region")
	awareness.register_prepared_region(Vector2i(4, 0), true)
	assert(awareness.peek_scout_request() == Vector2i(4, 0), "The fifth surveyed region should permit the second scout contact")
	assert(awareness.consume_scout_request(Vector2i(4, 0)), "The second queued scout should be consumable")
	awareness.report_scout(Vector2i(4, 0))
	assert(awareness.encounter_pending, "Two successful early reports may authorize the first hunting party")
	assert(not awareness.can_release_encounter(true, false, 2, true), "Streaming work must block encounter release")
	assert(not awareness.can_release_encounter(true, false, 0, false), "Unprepared terrain must block encounter release")
	assert(awareness.can_release_encounter(true, false, 0, true), "A settled stream and prepared region should release the encounter")
	assert(awareness.consume_encounter(), "Encounter pressure should be consumable exactly once")
	assert(awareness.encounter_cooldown_remaining >= 60.0, "Early hunting parties require a substantial recovery window")
	assert(not awareness.encounter_pending, "Consuming an encounter should clear its pending state")

	# Even if enough new pressure is created during recovery, delivery stays gated.
	awareness.register_activity("scout_report", Vector2i(5, 0))
	awareness.register_activity("scout_report", Vector2i(6, 0))
	assert(awareness.encounter_pending, "Meaningful repeated contact may accumulate while the hive recovers")
	assert(not awareness.can_release_encounter(true, false, 0, true), "Encounter cooldown must prevent back-to-back hunting parties")
	awareness.tick(awareness.encounter_cooldown_remaining + 0.1)
	assert(awareness.can_release_encounter(true, false, 0, true), "A pressure-backed encounter may release after recovery")
	awareness.consume_encounter()

	# A killed/lost scout is delayed information and contributes partial pressure,
	# rather than instantly creating another mini-wave.
	awareness.mark_scout_missing(Vector2i(7, 0))
	var missing_delay := float(awareness.missing_scouts[0]["remaining"])
	awareness.tick_missing_scouts(missing_delay - 0.1)
	assert(not awareness.encounter_pending, "A missing scout must retain its delayed escalation")
	awareness.tick_missing_scouts(0.2)
	assert(awareness.exploration_pressure > 0, "An overdue scout should eventually contribute search pressure")
	assert(not awareness.encounter_pending, "One overdue scout alone should not launch another early hunting party")

	# Pure exploration no longer raises awareness. Settlements/guardians/reports do.
	var points_before := awareness.awareness_points
	for region_x in range(8, 14):
		awareness.register_prepared_region(Vector2i(region_x, 0), true)
	assert(awareness.awareness_points == points_before, "Crossing chunk boundaries must not act as a hidden difficulty timer")
	awareness.register_activity("settlement", Vector2i(10, 0))
	awareness.register_activity("guardian", Vector2i(11, 0))
	assert(awareness.awareness_points > points_before, "Meaningful settlement/combat events should still teach the hive")

	var cap_before := HIVE_AWARENESS.new().population_cap(1, 1, 280)
	var cap_after := awareness.population_cap(2, 12, 280)
	assert(cap_after > cap_before, "Established bases and a mature threat state may increase the hostile population budget")
	var scout_names: Dictionary = {}
	for biome_id in range(7):
		var profile: Dictionary = HIVE_AWARENESS.scout_profile(biome_id)
		scout_names[str(profile["name"])] = true
	assert(scout_names.size() == 7, "Every biome should expose a distinct scout identity")

	awareness.mark_world_gate("alpha_core")
	awareness.mark_scout_missing(Vector2i(13, 0))
	var restored = HIVE_AWARENESS.new()
	restored.restore(awareness.serialize())
	assert(restored.awareness_points == awareness.awareness_points, "Awareness must survive realm saves")
	assert(restored.surveyed_regions.has(Vector2i(13, 0)), "Surveyed-region dedupe must survive realm saves")
	assert(bool(restored.world_gate_progress.get("alpha_core", false)), "Boss world-gate progress must survive realm saves")
	assert(restored.missing_scouts.size() >= 1, "Missing-scout investigations must survive realm saves")
	assert(is_equal_approx(restored.encounter_cooldown_remaining, awareness.encounter_cooldown_remaining), "Encounter recovery must survive realm saves")

	assert(
		DIFFICULTY_PROFILE.encounter_spawn_count("bastion", 8) < DIFFICULTY_PROFILE.wave_spawn_count("bastion", 12),
		"Tier-scoped encounters must stay smaller than legacy wave-12 quotas"
	)
	awareness.awareness_tier = 8
	var encounter_plan: Dictionary = WAVE_DIRECTOR.build_encounter_plan("bastion", 8, 0, 12, 3)
	assert(int(encounter_plan["spawn_count"]) <= 44, "Encounter plans must scale from Hive tier, not encounter count")
	assert(awareness.encounter_party_size() <= 18, "Live hunting parties must stay within the BV5.7 bounded regional quota")

	print("CRAWL_BRAWL_HIVE_AWARENESS_TEST_OK")
	quit(0)
