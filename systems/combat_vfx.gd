class_name CombatVfx
extends RefCounted

const WEAPON_PISTOL := 0
const WEAPON_SHOTGUN := 1
const WEAPON_LASER := 2
const WEAPON_SMG := 3
const WEAPON_RAILGUN := 4
const WEAPON_FLAMETHROWER := 5

const TEXTURE_NAMES: Array[String] = [
	"projectile_pistol", "projectile_shotgun", "projectile_smg", "projectile_railgun", "projectile_sentry",
	"projectile_impact_generic",
	"muzzle_pistol", "muzzle_shotgun", "muzzle_smg", "muzzle_railgun", "muzzle_flamethrower", "muzzle_sentry",
	"laser_muzzle", "laser_segment", "laser_impact",
	"flame_stream_a", "flame_stream_b", "flame_patch", "flame_ember",
	"rocket_body", "rocket_trail", "rocket_explosion",
	"laser_turret_head", "laser_turret_trail",
	"acid_glob", "acid_trail", "acid_splat",
	"tunnel_spore_glob", "tunnel_spore_trail", "tunnel_spore_splat",
	"hive_venom_glob", "hive_venom_trail", "hive_venom_splat",
	"bunker_arc_glob", "bunker_arc_trail", "bunker_arc_splat",
	"crystal_arc_glob", "crystal_arc_trail", "crystal_arc_splat",
	"foundry_thermal_glob", "foundry_thermal_trail", "foundry_thermal_splat",
	"sulfur_corrosive_glob", "sulfur_corrosive_trail", "sulfur_corrosive_splat",
	"iron_kinetic_glob", "iron_kinetic_trail", "iron_kinetic_splat",
	"enemy_lob_glob", "enemy_lob_trail", "enemy_lob_splat",
	"enemy_cyst_glob", "enemy_cyst_trail", "enemy_cyst_splat",
	"hazard_thermal", "hazard_thermal_ember", "hazard_spore", "hazard_spore_puff",
	"status_venom_rim", "status_dot_pulse",
	"impact_gold", "impact_orange", "impact_yellow", "impact_cyan", "impact_acid", "impact_rocket", "impact_laser", "impact_rock", "impact_metal",
	"recoil_pistol", "recoil_shotgun", "recoil_laser", "recoil_smg", "recoil_railgun", "recoil_flamethrower",
	"held_pistol", "held_shotgun", "held_laser", "held_smg", "held_railgun", "held_flamethrower",
]

const ENEMY_PROJECTILE_PREFIX_BY_BIOME: Array[String] = [
	"tunnel_spore", "hive_venom", "bunker_arc", "crystal_arc",
	"foundry_thermal", "sulfur_corrosive", "iron_kinetic",
]

const CONSUMER_PROJECTILE: Array[String] = [
	"projectile_pistol", "projectile_shotgun", "projectile_smg", "projectile_railgun", "projectile_sentry",
	"acid_glob", "rocket_body", "laser_turret_head",
	"tunnel_spore_glob", "hive_venom_glob", "bunker_arc_glob", "crystal_arc_glob",
	"foundry_thermal_glob", "sulfur_corrosive_glob", "iron_kinetic_glob",
	"enemy_lob_glob", "enemy_cyst_glob",
]
const CONSUMER_TRAIL: Array[String] = [
	"acid_trail", "rocket_trail", "laser_turret_trail",
	"tunnel_spore_trail", "hive_venom_trail", "bunker_arc_trail", "crystal_arc_trail",
	"foundry_thermal_trail", "sulfur_corrosive_trail", "iron_kinetic_trail",
	"enemy_lob_trail", "enemy_cyst_trail",
]
const CONSUMER_MUZZLE: Array[String] = [
	"muzzle_pistol", "muzzle_shotgun", "muzzle_smg", "muzzle_railgun", "muzzle_flamethrower", "muzzle_sentry",
	"laser_muzzle",
]
const CONSUMER_BEAM: Array[String] = ["laser_segment"]
const CONSUMER_FLAME: Array[String] = [
	"flame_stream_a", "flame_stream_b", "flame_patch", "flame_ember",
	"hazard_thermal", "hazard_thermal_ember", "hazard_spore", "hazard_spore_puff",
]
const CONSUMER_STATUS: Array[String] = ["status_venom_rim", "status_dot_pulse"]
const CONSUMER_IMPACT: Array[String] = [
	"projectile_impact_generic", "laser_impact", "rocket_explosion", "acid_splat",
	"tunnel_spore_splat", "hive_venom_splat", "bunker_arc_splat", "crystal_arc_splat",
	"foundry_thermal_splat", "sulfur_corrosive_splat", "iron_kinetic_splat",
	"enemy_lob_splat", "enemy_cyst_splat",
	"impact_gold", "impact_orange", "impact_yellow", "impact_cyan", "impact_acid", "impact_rocket", "impact_laser", "impact_rock", "impact_metal",
]
const CONSUMER_RECOIL: Array[String] = [
	"recoil_pistol", "recoil_shotgun", "recoil_laser", "recoil_smg", "recoil_railgun", "recoil_flamethrower",
]
const CONSUMER_HELD: Array[String] = [
	"held_pistol", "held_shotgun", "held_laser", "held_smg", "held_railgun", "held_flamethrower",
]
const CONSUMER_RETICLE: Array[String] = ["reticle_yellow", "reticle_cyan", "reticle_purple", "reticle_white"]

const RETICLE_HOTSPOT_BY_ID := {
	"reticle_cyan": Vector2(11.02, 10.39),
	"reticle_yellow": Vector2(10.49, 10.91),
	"reticle_purple": Vector2(9.71, 10.24),
	"reticle_white": Vector2(10.96, 11.50),
}

const HELD_TEXTURE_BY_WEAPON: Array[String] = [
	"held_pistol", "held_shotgun", "held_laser", "held_smg", "held_railgun", "held_flamethrower",
]

const MINING_GUN_DIRECTIONS: Array[String] = [
	"down", "down_right", "right", "up_right", "up", "up_left", "left", "down_left",
]

const MINING_GUN_CANVAS := Vector2(32, 32)

const HELD_WEAPON_CANVAS := Vector2(24, 16)

const HELD_WEAPON_GRIP_BY_WEAPON: Array[Vector2] = [
	Vector2(6, 8), Vector2(6, 8), Vector2(6, 8), Vector2(6, 8), Vector2(6, 8), Vector2(6, 8),
]

const HELD_WEAPON_MUZZLE_BY_WEAPON: Array[Vector2] = [
	Vector2(14, 4), Vector2(12, 2), Vector2(15, 3), Vector2(14, 6), Vector2(19, 5), Vector2(18, 12),
]

const RECOIL_TEXTURE_BY_WEAPON: Array[String] = [
	"recoil_pistol", "recoil_shotgun", "recoil_laser", "recoil_smg", "recoil_railgun", "recoil_flamethrower",
]

const MUZZLE_TEXTURE_BY_WEAPON: Array[String] = [
	"muzzle_pistol", "muzzle_shotgun", "laser_muzzle", "muzzle_smg", "muzzle_railgun", "muzzle_flamethrower",
]


static func all_texture_names() -> Array[String]:
	var ids: Array[String] = TEXTURE_NAMES.duplicate()
	for tier: int in range(1, 6):
		for direction: String in MINING_GUN_DIRECTIONS:
			ids.append(mining_gun_texture_id(tier, direction))
	return ids


static func all_consumed_texture_names() -> Array[String]:
	var ids: Array[String] = []
	for group: Array in [
		CONSUMER_PROJECTILE, CONSUMER_TRAIL, CONSUMER_MUZZLE, CONSUMER_BEAM,
		CONSUMER_FLAME, CONSUMER_STATUS, CONSUMER_IMPACT, CONSUMER_RECOIL, CONSUMER_HELD,
	]:
		for texture_id: String in group:
			if texture_id not in ids:
				ids.append(texture_id)
	for tier: int in range(1, 6):
		for direction: String in MINING_GUN_DIRECTIONS:
			ids.append(mining_gun_texture_id(tier, direction))
	return ids


static func mining_gun_texture_id(tier: int, direction: String) -> String:
	var safe_direction := direction if direction in MINING_GUN_DIRECTIONS else "right"
	return "mining_gun_mk%d_%s" % [clampi(tier, 1, 5), safe_direction]


static func mining_gun_direction(direction: Vector2) -> String:
	if direction.length_squared() <= 0.0001:
		return "right"
	var octant := posmod(roundi(direction.angle() / (PI * 0.25)), 8)
	return ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"][octant]


static func enemy_projectile_prefix(biome_id: int) -> String:
	var index := clampi(biome_id, 0, ENEMY_PROJECTILE_PREFIX_BY_BIOME.size() - 1)
	if biome_id < 0:
		index = 0
	return ENEMY_PROJECTILE_PREFIX_BY_BIOME[index]


static func enemy_projectile_texture_id(biome_id: int, part: String) -> String:
	var safe_part := part
	if safe_part != "glob" and safe_part != "trail" and safe_part != "splat":
		safe_part = "glob"
	return "%s_%s" % [enemy_projectile_prefix(biome_id), safe_part]


## PackedFloat32Array: [spin_rate, wobble_amp, trail_stretch]
static func enemy_projectile_motion(damage_type: StringName, is_special_lob: bool = false, is_cyst: bool = false) -> PackedFloat32Array:
	if is_cyst or is_special_lob:
		return PackedFloat32Array([1.6, 1.1, 1.25])
	match String(damage_type):
		"spore":
			return PackedFloat32Array([1.8, 2.2, 1.05])
		"venom":
			return PackedFloat32Array([3.4, 1.0, 1.2])
		"arc":
			return PackedFloat32Array([0.4, 0.8, 1.55])
		"thermal":
			return PackedFloat32Array([2.0, 2.0, 1.2])
		"corrosive":
			return PackedFloat32Array([2.8, 1.8, 1.25])
		"kinetic":
			return PackedFloat32Array([0.0, 0.0, 1.05])
		_:
			return PackedFloat32Array([1.5, 1.0, 1.1])


static func hazard_texture_id(damage_type: StringName) -> String:
	match String(damage_type):
		"thermal":
			return "hazard_thermal"
		"spore":
			return "hazard_spore"
		_:
			return ""


static func hazard_accent_texture_id(damage_type: StringName) -> String:
	match String(damage_type):
		"thermal":
			return "hazard_thermal_ember"
		"spore":
			return "hazard_spore_puff"
		_:
			return ""


static func hazard_fallback_color(damage_type: StringName) -> Color:
	match String(damage_type):
		"thermal":
			return Color(1.0, 0.42, 0.08, 0.45)
		"spore":
			return Color(0.72, 0.68, 0.28, 0.45)
		_:
			return Color(0.55, 0.85, 0.25, 0.4)


static func impact_texture_id_for_bullet(color: Color, projectile_kind: String, enemy_round: bool) -> String:
	if enemy_round:
		return "acid_splat"
	match projectile_kind:
		"rocket":
			return "impact_rocket"
		"laser_turret":
			return "impact_laser"
	if color.is_equal_approx(Color("ffd36b")):
		return "impact_yellow"
	if color.is_equal_approx(Color("ffb85c")):
		return "impact_orange"
	if color.is_equal_approx(Color("fff09a")):
		return "impact_cyan"
	if color.is_equal_approx(Color("a7f4ff")):
		return "impact_gold"
	if color.is_equal_approx(Color("82e9ff")):
		return "impact_cyan"
	if color.is_equal_approx(Color("69efff")):
		return "impact_laser"
	return "projectile_impact_generic"


static func impact_texture_id_for_context(context: String) -> String:
	match context:
		"rocket_explosion":
			return "rocket_explosion"
		"mining":
			return "impact_rock"
		"structure":
			return "impact_metal"
		"turret_muzzle_orange":
			return "impact_orange"
		_:
			return "projectile_impact_generic"


static func impact_size(texture_id: String) -> Vector2:
	match texture_id:
		"rocket_explosion":
			return Vector2(20, 20)
		"acid_splat", "tunnel_spore_splat", "hive_venom_splat", "bunker_arc_splat", "crystal_arc_splat", "foundry_thermal_splat", "sulfur_corrosive_splat", "iron_kinetic_splat":
			return Vector2(12, 12)
		"enemy_lob_splat", "enemy_cyst_splat":
			return Vector2(18, 18)
		"laser_impact":
			return Vector2(12, 12)
		"impact_rock", "impact_metal":
			return Vector2(10, 10)
		"status_venom_rim", "status_dot_pulse":
			return Vector2(18, 18)
		_:
			return Vector2(8, 8)


static func impact_duration(texture_id: String) -> float:
	match texture_id:
		"rocket_explosion":
			return 0.35
		"impact_rock":
			return 0.28
		"acid_splat", "tunnel_spore_splat", "hive_venom_splat", "bunker_arc_splat", "crystal_arc_splat", "foundry_thermal_splat", "sulfur_corrosive_splat", "iron_kinetic_splat", "enemy_lob_splat", "enemy_cyst_splat":
			return 0.24
		_:
			return 0.22


static func recoil_texture_id(weapon_id: int) -> String:
	if weapon_id < 0 or weapon_id >= RECOIL_TEXTURE_BY_WEAPON.size():
		return ""
	if weapon_id == WEAPON_LASER:
		return ""
	return RECOIL_TEXTURE_BY_WEAPON[weapon_id]


static func held_weapon_texture_id(weapon_id: int) -> String:
	if weapon_id < 0 or weapon_id >= HELD_TEXTURE_BY_WEAPON.size():
		return ""
	return HELD_TEXTURE_BY_WEAPON[weapon_id]


static func held_weapon_spec(weapon_id: int) -> Dictionary:
	var safe_id := clampi(weapon_id, 0, HELD_TEXTURE_BY_WEAPON.size() - 1)
	return {
		"texture": HELD_TEXTURE_BY_WEAPON[safe_id],
		"size": HELD_WEAPON_CANVAS,
		"grip": HELD_WEAPON_GRIP_BY_WEAPON[safe_id],
		"muzzle": HELD_WEAPON_MUZZLE_BY_WEAPON[safe_id],
	}


static func muzzle_texture_id(weapon_id: int) -> String:
	if weapon_id < 0 or weapon_id >= MUZZLE_TEXTURE_BY_WEAPON.size():
		return ""
	return MUZZLE_TEXTURE_BY_WEAPON[weapon_id]


static func reticle_texture_id(build_mode: bool, mining: bool, weapon_id: int) -> String:
	if build_mode:
		return "reticle_yellow"
	if mining:
		return "reticle_white"
	match weapon_id:
		WEAPON_FLAMETHROWER:
			return "reticle_yellow"
		WEAPON_RAILGUN:
			return "reticle_purple"
	return "reticle_cyan"


static func reticle_hotspot(texture_id: String) -> Vector2:
	return RETICLE_HOTSPOT_BY_ID.get(texture_id, Vector2(12.0, 12.0))
