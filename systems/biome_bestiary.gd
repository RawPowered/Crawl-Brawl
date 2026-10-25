class_name BiomeBestiary
extends RefCounted

const WorldGridScript := preload("res://systems/world_grid.gd")
const DifficultyProfileScript := preload("res://systems/difficulty_profile.gd")

const ARCHETYPE_SKIRMISHER := 0
const ARCHETYPE_STRIKER := 1
const ARCHETYPE_ARTILLERY := 2
const ARCHETYPE_BULWARK := 3
const ARCHETYPE_COUNT := 4

const ARCHETYPE_NAMES: Array[String] = [
	"skirmisher", "striker", "artillery", "bulwark",
]

const BIOME_SLUGS: Array[String] = [
	"tunnel", "hive", "bunker", "crystal", "foundry", "sulfur", "iron",
]

# Skirmisher / striker / artillery / bulwark weights. The encounter pressure director
# still guarantees its authored specialist beats; these profiles shape the
# remaining slots and make each spawn lane field a recognizable ecology.
const ROLE_WEIGHTS: Dictionary = {
	WorldGridScript.BIOME_TUNNEL: [56, 24, 14, 6],
	WorldGridScript.BIOME_HIVE: [62, 22, 12, 4],
	WorldGridScript.BIOME_BUNKER: [40, 20, 30, 10],
	WorldGridScript.BIOME_CRYSTAL: [38, 36, 18, 8],
	WorldGridScript.BIOME_FOUNDRY: [34, 20, 22, 24],
	WorldGridScript.BIOME_SULFUR: [40, 18, 34, 8],
	WorldGridScript.BIOME_IRON: [38, 18, 18, 26],
}

const TRAIT_PROFILES: Dictionary = {
	WorldGridScript.BIOME_TUNNEL: {
		"id": "stone_brace", "label": "STONE BRACE", "knockback_scale": 0.78,
	},
	WorldGridScript.BIOME_HIVE: {
		"id": "brood_rush", "label": "BROOD RUSH", "home_speed_scale": 1.08,
	},
	WorldGridScript.BIOME_BUNKER: {
		"id": "sapper_protocol", "label": "SAPPER PROTOCOL", "structure_damage_scale": 1.15,
	},
	WorldGridScript.BIOME_CRYSTAL: {
		"id": "prism_shot", "label": "PRISM SHOT", "projectile_speed_scale": 1.12,
		"projectile_color": Color("82e9ff"),
	},
	WorldGridScript.BIOME_FOUNDRY: {
		"id": "heat_stride", "label": "HEAT STRIDE", "home_speed_scale": 1.12,
	},
	WorldGridScript.BIOME_SULFUR: {
		"id": "toxic_reach", "label": "TOXIC REACH", "projectile_life_scale": 1.18,
		"spit_range_scale": 1.14, "projectile_color": Color("d4ef62"),
	},
	WorldGridScript.BIOME_IRON: {
		"id": "magnetic_mass", "label": "MAGNETIC MASS", "knockback_scale": 0.52,
	},
}

const DISPLAY_NAMES: Dictionary = {
	WorldGridScript.BIOME_TUNNEL: {
		ARCHETYPE_SKIRMISHER: "TUNNEL GNAWER",
		ARCHETYPE_STRIKER: "CAVE POUNCER",
		ARCHETYPE_ARTILLERY: "SPORE LAUNCHER",
		ARCHETYPE_BULWARK: "BEDROCK HULK",
	},
	WorldGridScript.BIOME_HIVE: {
		ARCHETYPE_SKIRMISHER: "BROOD MITE",
		ARCHETYPE_STRIKER: "HIVE STALKER",
		ARCHETYPE_ARTILLERY: "VENOM SPITTER",
		ARCHETYPE_BULWARK: "CHITIN BRUTE",
	},
	WorldGridScript.BIOME_BUNKER: {
		ARCHETYPE_SKIRMISHER: "SCRAP RUNNER",
		ARCHETYPE_STRIKER: "JUMPJET DRONE",
		ARCHETYPE_ARTILLERY: "ARC RELAY CRAWLER",
		ARCHETYPE_BULWARK: "PLATE WALKER",
	},
	WorldGridScript.BIOME_CRYSTAL: {
		ARCHETYPE_SKIRMISHER: "SHARD CRAWLER",
		ARCHETYPE_STRIKER: "PRISM HOPPER",
		ARCHETYPE_ARTILLERY: "CRYSTAL SIPHON",
		ARCHETYPE_BULWARK: "GEODE SENTINEL",
	},
	WorldGridScript.BIOME_FOUNDRY: {
		ARCHETYPE_SKIRMISHER: "CINDER SKITTER",
		ARCHETYPE_STRIKER: "SLAG LEAPER",
		ARCHETYPE_ARTILLERY: "EMBER SPITTER",
		ARCHETYPE_BULWARK: "FORGE GOLEM",
	},
	WorldGridScript.BIOME_SULFUR: {
		ARCHETYPE_SKIRMISHER: "BOG LEECH",
		ARCHETYPE_STRIKER: "ACID HOPPER",
		ARCHETYPE_ARTILLERY: "GAS BLISTER",
		ARCHETYPE_BULWARK: "SULFUR SHELL",
	},
	WorldGridScript.BIOME_IRON: {
		ARCHETYPE_SKIRMISHER: "RUST SCARAB",
		ARCHETYPE_STRIKER: "DRILL WORM",
		ARCHETYPE_ARTILLERY: "MAGNET PULSER",
		ARCHETYPE_BULWARK: "IRONCLAD BRUTE",
	},
}

const LEGACY_ROLE_TEXTURES: Dictionary = {
	0: "res://assets/art/mobs/swarmer_runtime.png",
	1: "res://assets/art/mobs/leaper_runtime.png",
	2: "res://assets/art/mobs/spitter_runtime.png",
	3: "res://assets/art/mobs/brute_runtime.png",
}

const DAMAGE_KINETIC := &"kinetic"
const DAMAGE_CORROSIVE := &"corrosive"
const DAMAGE_VENOM := &"venom"
const DAMAGE_THERMAL := &"thermal"
const DAMAGE_ARC := &"arc"
const DAMAGE_SPORE := &"spore"

const DAMAGE_TYPE_BY_BIOME: Array[StringName] = [
	DAMAGE_SPORE, DAMAGE_VENOM, DAMAGE_ARC, DAMAGE_ARC,
	DAMAGE_THERMAL, DAMAGE_CORROSIVE, DAMAGE_KINETIC,
]

# dmg_mult, speed_mult, hit_radius_mult, splash_px, cooldown_sec, engage_mult
const TYPE_COMBAT: Dictionary = {
	DAMAGE_SPORE: [0.75, 0.72, 1.40, 28.0, 2.70, 1.05],
	DAMAGE_VENOM: [0.90, 0.95, 1.00, 0.0, 1.85, 1.00],
	DAMAGE_ARC: [0.85, 1.28, 0.75, 14.0, 2.05, 1.10],
	DAMAGE_THERMAL: [1.10, 0.88, 1.15, 22.0, 2.40, 0.95],
	DAMAGE_CORROSIVE: [1.00, 0.90, 1.20, 18.0, 2.35, 1.08],
	DAMAGE_KINETIC: [1.35, 0.70, 0.90, 8.0, 2.85, 1.00],
}

# dmg, speed, aoe, cooldown — index 0 unused; L1..L4 at 1..4
const LEVEL_COMBAT: Array = [
	[],
	[0.85, 0.90, 0.95, 1.18],
	[1.00, 1.00, 1.00, 1.00],
	[1.20, 1.08, 1.12, 0.88],
	[1.45, 1.15, 1.25, 0.78],
]

const PROJECTILE_BASE_DAMAGE := 11.0
const PROJECTILE_BASE_HIT_RADIUS := 3.0
const PROJECTILE_BASE_ENGAGE := 178.0
const PROJECTILE_BASE_LIFE := 2.4
const MIN_SPIT_COOLDOWN := 1.0


static func biome_slug(biome_id: int) -> String:
	var index := clampi(biome_id, 0, BIOME_SLUGS.size() - 1)
	return BIOME_SLUGS[index]


static func archetype_for_role(role: int) -> int:
	match role:
		1:
			return ARCHETYPE_STRIKER
		2:
			return ARCHETYPE_ARTILLERY
		3:
			return ARCHETYPE_BULWARK
		_:
			return ARCHETYPE_SKIRMISHER


static func role_weights(biome_id: int) -> Array:
	return ROLE_WEIGHTS.get(clampi(biome_id, 0, BIOME_SLUGS.size() - 1), ROLE_WEIGHTS[WorldGridScript.BIOME_TUNNEL])


static func role_for_pressure(difficulty_id: String, pressure_level: int, sequence: int, biome_id: int, director_role: int) -> int:
	# Preserve the pressure director's guaranteed leaper/spitter beats. Biome weights
	# only reshape ordinary swarm slots, so awareness pressure stays legible.
	if director_role != ARCHETYPE_SKIRMISHER:
		return clampi(director_role, ARCHETYPE_SKIRMISHER, ARCHETYPE_BULWARK)
	var profile: Dictionary = DifficultyProfileScript.get_profile(difficulty_id)
	var weights: Array = role_weights(biome_id)
	var pressure := maxi(1, pressure_level)
	var eligible := [true, pressure >= int(profile["leaper_start"]), pressure >= int(profile["spitter_start"]), pressure >= 6]
	var total := 0
	for role: int in range(ARCHETYPE_COUNT):
		if bool(eligible[role]):
			total += int(weights[role])
	if total <= 0:
		return ARCHETYPE_SKIRMISHER
	var difficulty_salt := int(difficulty_id.hash())
	var roll := posmod(sequence * 73856093 ^ pressure * 19349663 ^ biome_id * 83492791 ^ difficulty_salt, total)
	for role: int in range(ARCHETYPE_COUNT):
		if not bool(eligible[role]):
			continue
		var weight := int(weights[role])
		if roll < weight:
			return role
		roll -= weight
	return ARCHETYPE_SKIRMISHER


static func role_for_spawn(difficulty_id: String, wave: int, sequence: int, biome_id: int, director_role: int) -> int:
	# Legacy compatibility wrapper; live runtime uses role_for_pressure().
	return role_for_pressure(difficulty_id, wave, sequence, biome_id, director_role)


static func trait_profile(biome_id: int) -> Dictionary:
	return TRAIT_PROFILES.get(clampi(biome_id, 0, BIOME_SLUGS.size() - 1), TRAIT_PROFILES[WorldGridScript.BIOME_TUNNEL])


static func trait_id(biome_id: int) -> String:
	return str(trait_profile(biome_id)["id"])


static func home_speed_scale(biome_id: int, on_home_ground: bool) -> float:
	if not on_home_ground:
		return 1.0
	return float(trait_profile(biome_id).get("home_speed_scale", 1.0))


static func structure_damage_scale(biome_id: int) -> float:
	return float(trait_profile(biome_id).get("structure_damage_scale", 1.0))


static func knockback_scale(biome_id: int) -> float:
	return float(trait_profile(biome_id).get("knockback_scale", 1.0))


static func damage_type_for_biome(biome_id: int) -> StringName:
	var index := clampi(biome_id, 0, DAMAGE_TYPE_BY_BIOME.size() - 1)
	if biome_id < 0:
		index = 0
	return DAMAGE_TYPE_BY_BIOME[index]


static func projectile_level_for_pressure(pressure: int) -> int:
	if pressure <= 2:
		return 1
	if pressure <= 4:
		return 2
	if pressure <= 6:
		return 3
	return 4


static func projectile_combat_profile(damage_type: StringName, level: int, ecology: Dictionary = {}) -> Dictionary:
	var type_row: Array = TYPE_COMBAT.get(damage_type, TYPE_COMBAT[DAMAGE_VENOM])
	var safe_level := clampi(level, 1, 4)
	var level_row: Array = LEVEL_COMBAT[safe_level]
	var dmg_mult := float(type_row[0]) * float(level_row[0])
	var speed_mult := float(type_row[1]) * float(level_row[1]) * float(ecology.get("projectile_speed_scale", 1.0))
	var aoe_mult := float(level_row[2])
	var hit_radius := PROJECTILE_BASE_HIT_RADIUS * float(type_row[2]) * aoe_mult
	var splash_radius := float(type_row[3]) * aoe_mult
	var cooldown := maxf(MIN_SPIT_COOLDOWN, float(type_row[4]) * float(level_row[3]))
	var engage_range := PROJECTILE_BASE_ENGAGE * float(type_row[5]) * float(ecology.get("spit_range_scale", 1.0))
	var life := PROJECTILE_BASE_LIFE * float(ecology.get("projectile_life_scale", 1.0))
	return {
		"damage_type": damage_type,
		"projectile_level": safe_level,
		"damage": PROJECTILE_BASE_DAMAGE * dmg_mult,
		"speed_scale": speed_mult,
		"hit_radius": hit_radius,
		"splash_radius": splash_radius,
		"cooldown": cooldown,
		"engage_range": engage_range,
		"life": life,
	}


static func spitter_profile(biome_id: int) -> Dictionary:
	var ecology: Dictionary = trait_profile(biome_id)
	var damage_type := damage_type_for_biome(biome_id)
	return {
		"speed_scale": float(ecology.get("projectile_speed_scale", 1.0)),
		"life_scale": float(ecology.get("projectile_life_scale", 1.0)),
		"range_scale": float(ecology.get("spit_range_scale", 1.0)),
		"color": ecology.get("projectile_color", Color("a4e85b")),
		"damage_type": damage_type,
	}


static func texture_path(biome_id: int, archetype: int) -> String:
	var slug := biome_slug(biome_id)
	var archetype_name := ARCHETYPE_NAMES[clampi(archetype, 0, ARCHETYPE_NAMES.size() - 1)]
	return "res://assets/art/mobs/biomes/%s/%s_runtime.png" % [slug, archetype_name]


static func texture_path_for_role(biome_id: int, role: int) -> String:
	return texture_path(biome_id, archetype_for_role(role))


static func display_name(biome_id: int, archetype: int) -> String:
	var biome_names: Dictionary = DISPLAY_NAMES.get(biome_id, DISPLAY_NAMES[WorldGridScript.BIOME_TUNNEL])
	return str(biome_names.get(archetype, "UNKNOWN THREAT"))


static func display_name_for_role(biome_id: int, role: int) -> String:
	return display_name(biome_id, archetype_for_role(role))


static func uses_biome_texture(role: int) -> bool:
	return role >= 0 and role <= 3


static func legacy_texture_path(role: int) -> String:
	return str(LEGACY_ROLE_TEXTURES.get(role, LEGACY_ROLE_TEXTURES[0]))
