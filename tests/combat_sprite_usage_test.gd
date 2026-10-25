extends SceneTree

const COMBAT_VFX := preload("res://systems/combat_vfx.gd")


func _initialize() -> void:
	call_deferred("_run_combat_sprite_usage_test")


func _run_combat_sprite_usage_test() -> void:
	var manifest: Array[String] = COMBAT_VFX.all_texture_names()
	var consumed: Array[String] = COMBAT_VFX.all_consumed_texture_names()
	assert(manifest.size() == 48, "Combat manifest should expose forty-eight runtime sprites")
	for texture_id: String in consumed:
		assert(texture_id in manifest, "Consumed combat sprite %s should exist in the manifest" % texture_id)
	for texture_id: String in manifest:
		assert(texture_id in consumed, "Manifest sprite %s should have a documented consumer mapping" % texture_id)

	assert(COMBAT_VFX.impact_texture_id_for_bullet(Color("ffd36b"), "round", false) == "impact_yellow")
	assert(COMBAT_VFX.impact_texture_id_for_bullet(Color("ffb85c"), "round", false) == "impact_orange")
	assert(COMBAT_VFX.impact_texture_id_for_bullet(Color("fff09a"), "round", false) == "impact_cyan")
	assert(COMBAT_VFX.impact_texture_id_for_bullet(Color("a7f4ff"), "round", false) == "impact_gold")
	assert(COMBAT_VFX.impact_texture_id_for_bullet(Color("82e9ff"), "round", false) == "impact_cyan")
	assert(COMBAT_VFX.impact_texture_id_for_bullet(Color("a4e85b"), "round", true) == "acid_splat")
	assert(COMBAT_VFX.impact_texture_id_for_context("rocket_explosion") == "rocket_explosion")
	assert(COMBAT_VFX.held_weapon_texture_id(COMBAT_VFX.WEAPON_PISTOL) == "held_pistol")
	assert(COMBAT_VFX.held_weapon_texture_id(COMBAT_VFX.WEAPON_LASER) == "held_laser")
	assert(COMBAT_VFX.held_weapon_texture_id(COMBAT_VFX.WEAPON_RAILGUN) == "held_railgun")
	assert(COMBAT_VFX.recoil_texture_id(COMBAT_VFX.WEAPON_PISTOL) == "recoil_pistol")
	assert(COMBAT_VFX.reticle_texture_id(true, false, COMBAT_VFX.WEAPON_PISTOL) == "reticle_yellow")
	assert(COMBAT_VFX.reticle_texture_id(false, true, COMBAT_VFX.WEAPON_PISTOL) == "reticle_white")
	assert(COMBAT_VFX.reticle_texture_id(false, false, COMBAT_VFX.WEAPON_RAILGUN) == "reticle_purple")

	print("CRAWL_BRAWL_COMBAT_SPRITE_USAGE_TEST_OK")
	quit(0)
