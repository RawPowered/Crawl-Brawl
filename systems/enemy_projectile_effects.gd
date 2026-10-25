class_name EnemyProjectileEffects
extends RefCounted

## Typed enemy-projectile status, structure bias, and hazard rules (Sprint B).
## Instant hit damage still flows through phase0_run; this module owns effect math.

const MAX_ENEMY_HAZARD_PATCHES := 8
const MAX_SPECIAL_LOBS_PER_ENCOUNTER := 1

const VENOM_SLOW_MULT := 0.72
const VENOM_SLOW_DURATION := 1.6
const VENOM_DOT_DPS := 2.2
const VENOM_DOT_DURATION := 2.4

const CORROSIVE_DOT_DPS := 3.0
const CORROSIVE_DOT_DURATION := 2.8
const CORROSIVE_STRUCTURE_MULT := 1.55

const ARC_STRUCTURE_MULT := 1.35
const ARC_SPLASH_STRUCTURE_FRAC := 0.45

const KINETIC_STRUCTURE_MULT := 0.85

const HAZARD_LIFE := 2.2
const HAZARD_THERMAL_DPS := 4.5
const HAZARD_SPORE_DPS := 3.0
const HAZARD_GRACE := 0.2

const LOB_SPEED_MULT := 0.55
const LOB_HIT_RADIUS_MULT := 1.30
const LOB_DAMAGE_MULT := 1.20
const LOB_SPLASH_MULT := 1.25
const LOB_LIFE_MULT := 1.35
const LOB_COOLDOWN := 3.8
const LOB_ENGAGE := 132.0

const CYST_SPEED_MULT := 0.62
const CYST_HIT_RADIUS_MULT := 1.45
const CYST_DAMAGE_MULT := 1.35
const CYST_SPLASH_MULT := 1.40
const CYST_LIFE_MULT := 1.5
const CYST_COOLDOWN := 4.2
const CYST_ENGAGE := 150.0
const CYST_SECONDARY_DOT_FRAC := 0.30


static func structure_damage_multiplier(damage_type: StringName) -> float:
	match damage_type:
		&"corrosive":
			return CORROSIVE_STRUCTURE_MULT
		&"arc":
			return ARC_STRUCTURE_MULT
		&"kinetic":
			return KINETIC_STRUCTURE_MULT
		_:
			return 1.0


static func hits_structures(damage_type: StringName) -> bool:
	return damage_type in [&"corrosive", &"arc", &"kinetic", &"thermal", &"spore"]


static func structure_priority(damage_type: StringName) -> bool:
	## Arc/corrosive actively seek turrets/bases; others only collide if they pass through.
	return damage_type in [&"corrosive", &"arc"]


static func applies_player_slow(damage_type: StringName) -> bool:
	return damage_type == &"venom"


static func player_dot_spec(damage_type: StringName, is_cyst: bool = false) -> Dictionary:
	match damage_type:
		&"venom":
			var dps := VENOM_DOT_DPS
			var duration := VENOM_DOT_DURATION
			if is_cyst:
				dps += CORROSIVE_DOT_DPS * CYST_SECONDARY_DOT_FRAC
				duration = maxf(duration, CORROSIVE_DOT_DURATION)
			return {"dps": dps, "duration": duration}
		&"corrosive":
			return {"dps": CORROSIVE_DOT_DPS, "duration": CORROSIVE_DOT_DURATION}
		_:
			return {}


static func spawns_hazard(damage_type: StringName) -> bool:
	return damage_type in [&"thermal", &"spore"]


static func hazard_spec(damage_type: StringName, splash_radius: float) -> Dictionary:
	var radius := maxf(14.0, splash_radius * 0.85)
	match damage_type:
		&"thermal":
			return {"dps": HAZARD_THERMAL_DPS, "radius": radius, "life": HAZARD_LIFE}
		&"spore":
			return {"dps": HAZARD_SPORE_DPS, "radius": radius * 1.1, "life": HAZARD_LIFE + 0.3}
		_:
			return {}


static func lob_profile_scale() -> Dictionary:
	return {
		"speed_mult": LOB_SPEED_MULT,
		"hit_radius_mult": LOB_HIT_RADIUS_MULT,
		"damage_mult": LOB_DAMAGE_MULT,
		"splash_mult": LOB_SPLASH_MULT,
		"life_mult": LOB_LIFE_MULT,
		"cooldown": LOB_COOLDOWN,
		"engage": LOB_ENGAGE,
	}


static func cyst_profile_scale() -> Dictionary:
	return {
		"speed_mult": CYST_SPEED_MULT,
		"hit_radius_mult": CYST_HIT_RADIUS_MULT,
		"damage_mult": CYST_DAMAGE_MULT,
		"splash_mult": CYST_SPLASH_MULT,
		"life_mult": CYST_LIFE_MULT,
		"cooldown": CYST_COOLDOWN,
		"engage": CYST_ENGAGE,
	}
