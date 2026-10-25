class_name RealmVisualStyle
extends RefCounted

const MATERIAL_TUNNEL := 0
const MATERIAL_HIVE := 1
const MATERIAL_BUNKER := 2
const MATERIAL_CRYSTAL := 3
const MATERIAL_FOUNDRY := 4
const MATERIAL_SULFUR := 5
const MATERIAL_IRON := 6

# Phase 1 quiet-base profiles. Each biome exposes six reviewed atlas macros
# through a 12-entry weighted pool: 4/3/2/1/1/1. The calmest material carries
# one third of placements while distinctive atlas cells remain reserved for
# later formation/detail layers instead of leaking into the base floor.
const BASE_VARIANT_POOLS := {
	MATERIAL_TUNNEL: [16, 16, 16, 16, 35, 35, 35, 37, 37, 33, 82, 56],
	MATERIAL_HIVE: [34, 34, 34, 34, 17, 17, 17, 35, 35, 74, 44, 86],
	MATERIAL_BUNKER: [0, 0, 0, 0, 1, 1, 1, 19, 19, 10, 15, 9],
	MATERIAL_CRYSTAL: [0, 0, 0, 0, 1, 1, 1, 80, 80, 10, 96, 78],
	MATERIAL_FOUNDRY: [20, 20, 20, 20, 2, 2, 2, 0, 0, 77, 71, 88],
	MATERIAL_SULFUR: [98, 98, 98, 98, 80, 80, 80, 39, 39, 99, 6, 10],
	MATERIAL_IRON: [90, 90, 90, 90, 99, 99, 99, 87, 87, 78, 74, 31],
}

const FORMATION_VARIANT_POOLS := {
	MATERIAL_TUNNEL: [41, 50, 55, 51, 6, 42, 10, 43],
	MATERIAL_HIVE: [90, 31, 70, 21, 13, 40, 3, 53],
	MATERIAL_BUNKER: [35, 89, 26, 31, 32, 56, 24, 28],
	MATERIAL_CRYSTAL: [97, 49, 2, 15, 9, 86, 91, 14],
	MATERIAL_FOUNDRY: [82, 14, 29, 97, 49, 36, 95, 13],
	MATERIAL_SULFUR: [7, 60, 91, 19, 21, 50, 25, 27],
	MATERIAL_IRON: [15, 14, 19, 63, 69, 8, 11, 98],
}

# Offsets are in 2x2 terrain-macro units. The eight silhouettes deliberately
# mix veins, branches, fans, and irregular patches; none is a filled rectangle.
const FORMATION_STAMPS := [
	[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)],
	[Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, -1), Vector2i(-1, 1)],
	[Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(-1, 1), Vector2i(1, -1)],
	[Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
	[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1)],
	[Vector2i(-1, -2), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
	[Vector2i(0, -2), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
]

const WALL_VARIANT_POOLS := {
	MATERIAL_TUNNEL: [41, 50, 55, 51],
	MATERIAL_HIVE: [13, 40, 3, 53],
	MATERIAL_BUNKER: [35, 89, 26, 31],
	MATERIAL_CRYSTAL: [2, 15, 9, 14],
	MATERIAL_FOUNDRY: [14, 29, 97, 49],
	MATERIAL_SULFUR: [60, 19, 21, 50],
	MATERIAL_IRON: [15, 14, 63, 69],
}

const WALL_EDGE_COLORS := {
	MATERIAL_TUNNEL: Color("8a7568"),
	MATERIAL_HIVE: Color("9b638f"),
	MATERIAL_BUNKER: Color("638892"),
	MATERIAL_CRYSTAL: Color("65bfd2"),
	MATERIAL_FOUNDRY: Color("bd7448"),
	MATERIAL_SULFUR: Color("9aaa47"),
	MATERIAL_IRON: Color("9a654e"),
}

const PROP_NONE := 0
const PROP_LAMP := 1
const PROP_CRATE := 2
const PROP_RUBBLE := 3
const PROP_WEB := 4
const PROP_EGGS := 5
const PROP_ACID := 6
const PROP_GRATE := 7
const PROP_CONDUIT := 8
const PROP_CRYSTAL_SHARD := 9
const PROP_SULFUR_VENT := 10
const PROP_SLAG_HEAP := 11

# Phase 4 atmosphere stays sparse and materially specific. Density is measured
# per thousand 40px draw-time sample points, not per terrain cell.
const ATMOSPHERE_MOTE_DENSITIES := {
	MATERIAL_TUNNEL: 42,
	MATERIAL_HIVE: 96,
	MATERIAL_BUNKER: 28,
	MATERIAL_CRYSTAL: 76,
	MATERIAL_FOUNDRY: 54,
	MATERIAL_SULFUR: 105,
	MATERIAL_IRON: 38,
}

const ATMOSPHERE_MOTE_COLORS := {
	MATERIAL_TUNNEL: Color("9b8f82"),
	MATERIAL_HIVE: Color("bc79b6"),
	MATERIAL_BUNKER: Color("7699a0"),
	MATERIAL_CRYSTAL: Color("79d9ee"),
	MATERIAL_FOUNDRY: Color("db8150"),
	MATERIAL_SULFUR: Color("b7cb54"),
	MATERIAL_IRON: Color("a27463"),
}

const BIOME_LIGHT_COLORS := {
	MATERIAL_TUNNEL: Color("e0a861"),
	MATERIAL_HIVE: Color("cb72c8"),
	MATERIAL_BUNKER: Color("73c8d7"),
	MATERIAL_CRYSTAL: Color("80e7ff"),
	MATERIAL_FOUNDRY: Color("ff884c"),
	MATERIAL_SULFUR: Color("c6e252"),
	MATERIAL_IRON: Color("d4805d"),
}

const BIOME_AMBIENT_GRADES := {
	MATERIAL_TUNNEL: Color("382f2a"),
	MATERIAL_HIVE: Color("3b233c"),
	MATERIAL_BUNKER: Color("18343b"),
	MATERIAL_CRYSTAL: Color("163946"),
	MATERIAL_FOUNDRY: Color("422419"),
	MATERIAL_SULFUR: Color("34401a"),
	MATERIAL_IRON: Color("39251f"),
}

# Two authored arrangements per biome. Cell offsets establish the silhouette;
# small pixel offsets stop props from snapping to a visible grid while keeping
# collision and navigation unchanged.
const LANDMARK_COMPOSITIONS := {
	MATERIAL_TUNNEL: [
		[{"kind": PROP_RUBBLE, "cell_offset": Vector2i(-1, 0), "pixel_offset": Vector2(-3, 3)}, {"kind": PROP_CRATE, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(2, 1)}, {"kind": PROP_LAMP, "cell_offset": Vector2i(1, -1), "pixel_offset": Vector2(4, -2)}],
		[{"kind": PROP_RUBBLE, "cell_offset": Vector2i(-1, 1), "pixel_offset": Vector2(-4, 1)}, {"kind": PROP_RUBBLE, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(1, 3)}, {"kind": PROP_CRATE, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, -1)}],
	],
	MATERIAL_HIVE: [
		[{"kind": PROP_EGGS, "cell_offset": Vector2i(-1, 0), "pixel_offset": Vector2(-3, 2)}, {"kind": PROP_EGGS, "cell_offset": Vector2i(0, 1), "pixel_offset": Vector2(2, 4)}, {"kind": PROP_WEB, "cell_offset": Vector2i(1, -1), "pixel_offset": Vector2(4, -3)}, {"kind": PROP_ACID, "cell_offset": Vector2i(1, 1), "pixel_offset": Vector2(-2, 2)}],
		[{"kind": PROP_WEB, "cell_offset": Vector2i(-1, -1), "pixel_offset": Vector2(-4, -2)}, {"kind": PROP_EGGS, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(1, 3)}, {"kind": PROP_ACID, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, 1)}],
	],
	MATERIAL_BUNKER: [
		[{"kind": PROP_CONDUIT, "cell_offset": Vector2i(-1, 0), "pixel_offset": Vector2(-4, 1)}, {"kind": PROP_GRATE, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(1, 3)}, {"kind": PROP_CONDUIT, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, 1)}, {"kind": PROP_LAMP, "cell_offset": Vector2i(1, -1), "pixel_offset": Vector2(3, -3)}],
		[{"kind": PROP_CRATE, "cell_offset": Vector2i(-1, 1), "pixel_offset": Vector2(-3, 3)}, {"kind": PROP_GRATE, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(0, 2)}, {"kind": PROP_LAMP, "cell_offset": Vector2i(1, -1), "pixel_offset": Vector2(4, -2)}],
	],
	MATERIAL_CRYSTAL: [
		[{"kind": PROP_CRYSTAL_SHARD, "cell_offset": Vector2i(-1, 1), "pixel_offset": Vector2(-4, 3)}, {"kind": PROP_CRYSTAL_SHARD, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(1, -2)}, {"kind": PROP_CRYSTAL_SHARD, "cell_offset": Vector2i(1, 1), "pixel_offset": Vector2(4, 4)}],
		[{"kind": PROP_CRYSTAL_SHARD, "cell_offset": Vector2i(-1, 0), "pixel_offset": Vector2(-3, 0)}, {"kind": PROP_CRYSTAL_SHARD, "cell_offset": Vector2i(0, -1), "pixel_offset": Vector2(1, -4)}, {"kind": PROP_CRYSTAL_SHARD, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, 2)}, {"kind": PROP_CRYSTAL_SHARD, "cell_offset": Vector2i(0, 1), "pixel_offset": Vector2(-1, 4)}],
	],
	MATERIAL_FOUNDRY: [
		[{"kind": PROP_SLAG_HEAP, "cell_offset": Vector2i(-1, 1), "pixel_offset": Vector2(-4, 3)}, {"kind": PROP_GRATE, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(0, 2)}, {"kind": PROP_CONDUIT, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, -1)}],
		[{"kind": PROP_CONDUIT, "cell_offset": Vector2i(-1, 0), "pixel_offset": Vector2(-4, 1)}, {"kind": PROP_SLAG_HEAP, "cell_offset": Vector2i(0, 1), "pixel_offset": Vector2(1, 4)}, {"kind": PROP_SLAG_HEAP, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, 1)}, {"kind": PROP_GRATE, "cell_offset": Vector2i(0, -1), "pixel_offset": Vector2(1, -3)}],
	],
	MATERIAL_SULFUR: [
		[{"kind": PROP_SULFUR_VENT, "cell_offset": Vector2i(-1, 0), "pixel_offset": Vector2(-4, 1)}, {"kind": PROP_ACID, "cell_offset": Vector2i(0, 1), "pixel_offset": Vector2(0, 4)}, {"kind": PROP_SULFUR_VENT, "cell_offset": Vector2i(1, -1), "pixel_offset": Vector2(4, -3)}],
		[{"kind": PROP_ACID, "cell_offset": Vector2i(-1, 1), "pixel_offset": Vector2(-3, 4)}, {"kind": PROP_SULFUR_VENT, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(1, 1)}, {"kind": PROP_SULFUR_VENT, "cell_offset": Vector2i(1, 1), "pixel_offset": Vector2(4, 3)}, {"kind": PROP_ACID, "cell_offset": Vector2i(1, -1), "pixel_offset": Vector2(2, -3)}],
	],
	MATERIAL_IRON: [
		[{"kind": PROP_RUBBLE, "cell_offset": Vector2i(-1, 0), "pixel_offset": Vector2(-4, 2)}, {"kind": PROP_SLAG_HEAP, "cell_offset": Vector2i(0, 1), "pixel_offset": Vector2(1, 4)}, {"kind": PROP_GRATE, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, 1)}],
		[{"kind": PROP_SLAG_HEAP, "cell_offset": Vector2i(-1, 1), "pixel_offset": Vector2(-3, 4)}, {"kind": PROP_RUBBLE, "cell_offset": Vector2i(0, 0), "pixel_offset": Vector2(1, 2)}, {"kind": PROP_RUBBLE, "cell_offset": Vector2i(1, 0), "pixel_offset": Vector2(4, -1)}, {"kind": PROP_GRATE, "cell_offset": Vector2i(0, -1), "pixel_offset": Vector2(0, -3)}],
	],
}

const VOID := Color("071015")
const PANEL_BG := Color(0.008, 0.025, 0.032, 0.94)
const PANEL_BORDER := Color("315864")
const CYAN := Color("55dff5")
const CYAN_TEXT := Color("8eeaff")
const AMBER := Color("ffae4f")
const ACID := Color("8fe742")

# One 640x360 safe-area contract keeps the immediate HUD aligned at every
# supported output resolution. Runtime scaling belongs to DisplaySettings.
const HUD_LEFT_PANEL := Rect2(5, 5, 124, 40)
const HUD_RIGHT_PANEL := Rect2(492, 5, 143, 44)
const HUD_BASE_START := Vector2(134, 5)
const HUD_BASE_CARD_SIZE := Vector2(52, 40)
const HUD_BASE_CARD_STEP := 55
const HUD_MINIMAP_CARD := Rect2(5, 256, 144, 99)
const HUD_MINIMAP_MAP := Rect2(10, 273, 134, 74)
const HUD_WEAPON_START := Vector2(162, 305)
const HUD_WEAPON_CARD_SIZE := Vector2(26, 22)
const HUD_WEAPON_CARD_STEP := 26
const HUD_WEAPON_CUTTER_WIDTH := 24.0
const HUD_WEAPON_BUILD_PIP := 16.0
const HUD_OBJECTIVE_PANEL := Rect2(150, 329, 340, 28)
const HUD_CONTEXT_PANEL := Rect2(494, 329, 141, 28)
const HUD_PACK_LINE_WIDTH := 120
const PAUSE_FRAME := Rect2(152, 48, 336, 264)


static func stable_cell_hash(realm_seed: int, cell: Vector2i, salt: int = 0) -> int:
	var value: int = realm_seed ^ (cell.x * 73856093) ^ (cell.y * 19349663) ^ (salt * 83492791)
	value = value ^ (value >> 13)
	value *= 1274126177
	return value ^ (value >> 16)


static func base_variant_pool(material_id: int) -> Array:
	return BASE_VARIANT_POOLS.get(material_id, BASE_VARIANT_POOLS[MATERIAL_TUNNEL])


static func base_atlas_index(realm_seed: int, macro_cell: Vector2i, material_id: int, salt: int = 0) -> int:
	var pool: Array = base_variant_pool(material_id)
	if pool.is_empty():
		return 0
	var choice := posmod(stable_cell_hash(realm_seed, macro_cell, 211 + material_id * 31 + salt), pool.size())
	return int(pool[choice])


static func _hash_unit(realm_seed: int, cell: Vector2i, salt: int) -> float:
	return float(posmod(stable_cell_hash(realm_seed, cell, salt), 10000)) / 9999.0


static func value_noise(realm_seed: int, cell: Vector2i, scale: int, salt: int) -> float:
	var safe_scale := maxi(1, scale)
	var sample := Vector2(cell) / float(safe_scale)
	var origin := Vector2i(floori(sample.x), floori(sample.y))
	var blend := sample - Vector2(origin)
	blend = Vector2(blend.x * blend.x * (3.0 - 2.0 * blend.x), blend.y * blend.y * (3.0 - 2.0 * blend.y))
	var top := lerpf(
		_hash_unit(realm_seed, origin, salt),
		_hash_unit(realm_seed, origin + Vector2i.RIGHT, salt),
		blend.x
	)
	var bottom := lerpf(
		_hash_unit(realm_seed, origin + Vector2i.DOWN, salt),
		_hash_unit(realm_seed, origin + Vector2i.ONE, salt),
		blend.x
	)
	return lerpf(top, bottom, blend.y)


static func formation_field(realm_seed: int, cell: Vector2i, material_id: int) -> float:
	var low := value_noise(realm_seed, cell, 36, 307 + material_id * 17)
	var medium := value_noise(realm_seed, cell, 12, 401 + material_id * 23)
	return low * 0.42 + medium * 0.58


static func formation_count_for_region(realm_seed: int, region: Vector2i, material_id: int) -> int:
	var roll := posmod(stable_cell_hash(realm_seed, region, 503 + material_id * 19), 100)
	if roll < 15:
		return 0
	if roll < 80:
		return 2
	return 3


static func formation_stamp_index(realm_seed: int, anchor: Vector2i, material_id: int) -> int:
	return posmod(stable_cell_hash(realm_seed, anchor, 601 + material_id * 29), FORMATION_STAMPS.size())


static func formation_stamp(stamp_index: int) -> Array:
	return FORMATION_STAMPS[posmod(stamp_index, FORMATION_STAMPS.size())]


static func formation_atlas_index(realm_seed: int, anchor: Vector2i, material_id: int, component_index: int) -> int:
	var pool: Array = FORMATION_VARIANT_POOLS.get(material_id, FORMATION_VARIANT_POOLS[MATERIAL_TUNNEL])
	var choice := posmod(stable_cell_hash(realm_seed, anchor, 701 + material_id * 31 + component_index * 7), pool.size())
	return int(pool[choice])


static func formation_prop_kind(realm_seed: int, anchor: Vector2i, material_id: int) -> int:
	var roll := posmod(stable_cell_hash(realm_seed, anchor, 809 + material_id * 37), 100)
	match material_id:
		MATERIAL_HIVE:
			return PROP_EGGS if roll < 45 else (PROP_WEB if roll < 78 else PROP_ACID)
		MATERIAL_BUNKER:
			return PROP_GRATE if roll < 52 else PROP_CONDUIT
		MATERIAL_CRYSTAL:
			return PROP_CRYSTAL_SHARD
		MATERIAL_FOUNDRY:
			return PROP_SLAG_HEAP if roll < 55 else (PROP_GRATE if roll < 78 else PROP_CONDUIT)
		MATERIAL_SULFUR:
			return PROP_SULFUR_VENT if roll < 58 else PROP_ACID
		MATERIAL_IRON:
			return PROP_RUBBLE if roll < 55 else PROP_SLAG_HEAP
		_:
			return PROP_RUBBLE if roll < 72 else (PROP_CRATE if roll < 92 else PROP_LAMP)


static func formation_prop_offset(realm_seed: int, anchor: Vector2i, material_id: int) -> Vector2:
	var hash := stable_cell_hash(realm_seed, anchor, 907 + material_id * 41)
	return Vector2(float(posmod(hash, 5) - 2), float(posmod(hash / 7, 5) - 2))


static func boundary_displacement(realm_seed: int, boundary_cell: Vector2i, vertical: bool) -> int:
	var salt := 1201 if vertical else 1217
	var field := value_noise(realm_seed, boundary_cell, 9, salt)
	return clampi(roundi((field - 0.5) * 6.0), -3, 3)


static func boundary_contamination(
	realm_seed: int,
	cell: Vector2i,
	material_a: int,
	material_b: int,
	distance_to_border: int
) -> bool:
	if distance_to_border < 0 or distance_to_border > 3 or material_a == material_b:
		return false
	var low_id := mini(material_a, material_b)
	var high_id := maxi(material_a, material_b)
	var field := value_noise(realm_seed, cell, 5, 1301 + low_id * 47 + high_id * 71)
	var threshold := 0.78 + float(distance_to_border) * 0.055
	return field > threshold


static func wall_atlas_index(realm_seed: int, macro_cell: Vector2i, material_id: int) -> int:
	var pool: Array = WALL_VARIANT_POOLS.get(material_id, WALL_VARIANT_POOLS[MATERIAL_TUNNEL])
	var choice := posmod(stable_cell_hash(realm_seed, macro_cell, 1409 + material_id * 53), pool.size())
	return int(pool[choice])


static func wall_edge_color(material_id: int) -> Color:
	return WALL_EDGE_COLORS.get(material_id, WALL_EDGE_COLORS[MATERIAL_TUNNEL])


static func mote_density(material_id: int) -> int:
	return int(ATMOSPHERE_MOTE_DENSITIES.get(material_id, ATMOSPHERE_MOTE_DENSITIES[MATERIAL_TUNNEL]))


static func mote_color(material_id: int) -> Color:
	return ATMOSPHERE_MOTE_COLORS.get(material_id, ATMOSPHERE_MOTE_COLORS[MATERIAL_TUNNEL])


static func biome_light_color(material_id: int) -> Color:
	return BIOME_LIGHT_COLORS.get(material_id, BIOME_LIGHT_COLORS[MATERIAL_TUNNEL])


static func ambient_grade_color(material_id: int) -> Color:
	return BIOME_AMBIENT_GRADES.get(material_id, BIOME_AMBIENT_GRADES[MATERIAL_TUNNEL])


static func landmark_count_for_region(realm_seed: int, region: Vector2i, material_id: int) -> int:
	var roll := posmod(stable_cell_hash(realm_seed, region, 1601 + material_id * 59), 100)
	if roll < 70:
		return 0
	if roll < 96:
		return 1
	return 2


static func landmark_variant(realm_seed: int, anchor: Vector2i, material_id: int, landmark_index: int = 0) -> int:
	var variants: Array = LANDMARK_COMPOSITIONS.get(material_id, LANDMARK_COMPOSITIONS[MATERIAL_TUNNEL])
	return posmod(stable_cell_hash(realm_seed, anchor, 1709 + material_id * 61 + landmark_index * 13), variants.size())


static func landmark_composition(material_id: int, variant: int) -> Array:
	var variants: Array = LANDMARK_COMPOSITIONS.get(material_id, LANDMARK_COMPOSITIONS[MATERIAL_TUNNEL])
	return variants[posmod(variant, variants.size())]


static func decoration_for_cell(realm_seed: int, cell: Vector2i, material_id: int, near_wall: bool, biome_id: int = -1) -> int:
	var roll := posmod(stable_cell_hash(realm_seed, cell, 41 + material_id * 17 + maxi(0, biome_id) * 29), 1000)
	if biome_id >= 0:
		match biome_id:
			MATERIAL_CRYSTAL:
				if roll < 24:
					return PROP_CRYSTAL_SHARD
				if near_wall and roll < 42:
					return PROP_CONDUIT
			MATERIAL_FOUNDRY:
				if roll < 22:
					return PROP_GRATE
				if roll < 38:
					return PROP_SLAG_HEAP
				if near_wall and roll < 52:
					return PROP_CONDUIT
			MATERIAL_SULFUR:
				if roll < 26:
					return PROP_SULFUR_VENT
				if roll < 44:
					return PROP_ACID
				if near_wall and roll < 62:
					return PROP_EGGS
			MATERIAL_IRON:
				if roll < 18:
					return PROP_RUBBLE
				if roll < 34:
					return PROP_GRATE
				if near_wall and roll < 48:
					return PROP_SLAG_HEAP
	match material_id:
		MATERIAL_HIVE:
			if roll < 24:
				return PROP_ACID
			if roll < 47:
				return PROP_EGGS
			if near_wall and roll < 70:
				return PROP_WEB
		MATERIAL_BUNKER:
			if roll < 20:
				return PROP_GRATE
			if near_wall and roll < 38:
				return PROP_CONDUIT
		_:
			if near_wall and roll < 8:
				return PROP_LAMP
			if roll < 18:
				return PROP_CRATE
			if roll < 43:
				return PROP_RUBBLE
	return PROP_NONE


static func prop_variant(realm_seed: int, cell: Vector2i) -> int:
	return posmod(stable_cell_hash(realm_seed, cell, 97), 4)
