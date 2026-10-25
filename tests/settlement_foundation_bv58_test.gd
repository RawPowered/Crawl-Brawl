extends SceneTree

const RUN_SCRIPT := preload("res://scripts/phase0_run.gd")
const SETTLEMENT := preload("res://systems/settlement_progression.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# The crash opening should create bounded, authored pressure without restoring
	# the old tower-defense wave clock or bypassing the hostile spawn-frame budget.
	assert(RUN_SCRIPT.OPENING_CONTACT_PACKS.size() == 2, "The opening should use two readable contact beats")
	assert(RUN_SCRIPT.OPENING_CONTACT_PACKS[0] >= 3, "The first breach must feel dangerous, not empty")
	assert(RUN_SCRIPT.OPENING_CONTACT_PACKS[0] + RUN_SCRIPT.OPENING_CONTACT_PACKS[1] <= 8, "Opening pressure must remain bounded for frame pacing")
	assert(RUN_SCRIPT.OPENING_CONTACT_DELAYS[0] <= 3.0, "First contact should follow the breach quickly")

	# First-settlement contract: merchant is an early campaign milestone, not the
	# surface/endgame unlock. Two placed lights prove the pocket can be maintained.
	assert(RUN_SCRIPT.BUILD_MERCHANT_STORE == 16, "Merchant Store needs a stable structure kind for saves")
	assert(SETTLEMENT.MERCHANT_STORE_FOOTPRINT == Vector2i(4, 3), "First store should be a meaningful enterable structure footprint")
	assert(SETTLEMENT.MERCHANT_STORE_SAFE_RADIUS_CELLS >= 8.0, "Merchant Store needs its own settlement protection radius")
	assert(SETTLEMENT.merchant_invite_gate(false, false, 0) != "READY", "Merchant cannot descend before the landing seal is breached")
	assert(SETTLEMENT.merchant_invite_gate(true, false, 2) != "READY", "Merchant cannot descend during initial tunnel contact")
	assert(SETTLEMENT.merchant_invite_gate(true, true, 1) != "READY", "Merchant requires two deployed Field Lanterns")
	assert(SETTLEMENT.merchant_invite_gate(true, true, 2) == "READY", "Merchant invitation should unlock after contact and lighting are stable")

	var run_source := FileAccess.get_file_as_string("res://scripts/phase0_run.gd")
	assert(run_source.contains("_queue_broodling_pack(spawn_cell, pack_size, false"), "Opening contact must use the bounded hostile spawn queue")
	assert(run_source.contains("\"opening_contact\""), "Opening hostile requests need a source tag so the settlement gate cannot open before queued contact is released")
	assert(run_source.contains("structure.kind == BUILD_MERCHANT_STORE"), "Merchant Store must participate in structure protection/interaction paths")
	assert(run_source.contains("merchant_store_session"), "Merchant Store needs a distinct safe-interior session")
	assert(not run_source.contains("if mecha_level >= 3:\n\t\t_spawn_surface_portal()"), "Mecha MK3 must not incorrectly unlock the surface")
	assert(not run_source.contains("beta_teaser_active = true"), "The retired beta surface portal must not remain interactable")
	var hud_source := FileAccess.get_file_as_string("res://systems/run_components/run_hud_presentation.gd")
	assert(not hud_source.contains("ENTER SURFACE PORTAL"), "HUD must not advertise the retired surface shortcut")
	assert(hud_source.contains("INVITE VOLUNTEER MERCHANT"), "HUD should guide the first-settlement invitation milestone")
	assert(hud_source.contains("ENTER MERCHANT STORE"), "HUD should expose the first enterable settlement structure")

	print("CRAWL_BRAWL_SETTLEMENT_FOUNDATION_BV58_TEST_OK")
	quit(0)
