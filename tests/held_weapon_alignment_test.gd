extends SceneTree

const COMBAT_VFX := preload("res://systems/combat_vfx.gd")


func _initialize() -> void:
	call_deferred("_run_held_weapon_alignment_test")


func _run_held_weapon_alignment_test() -> void:
	for weapon_id: int in range(COMBAT_VFX.HELD_TEXTURE_BY_WEAPON.size()):
		var spec: Dictionary = COMBAT_VFX.held_weapon_spec(weapon_id)
		var grip: Vector2 = spec["grip"]
		var muzzle: Vector2 = spec["muzzle"]
		var size: Vector2 = spec["size"]
		assert(size == COMBAT_VFX.HELD_WEAPON_CANVAS, "Held weapon canvas should stay 24x16")
		assert(grip.x >= 0.0 and grip.y >= 0.0 and grip.x < size.x and grip.y < size.y, "Grip should stay inside held canvas")
		assert(muzzle.x > grip.x, "Muzzle should sit to the right of the grip")
		var barrel := muzzle - grip
		assert(barrel.length_squared() >= 4.0, "Barrel vector should have usable length")
		assert(muzzle.x <= size.x and muzzle.y <= size.y, "Muzzle should stay inside held canvas")

	print("CRAWL_BRAWL_HELD_WEAPON_ALIGNMENT_TEST_OK")
	quit(0)
