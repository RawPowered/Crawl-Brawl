class_name RuinedFortress
extends RefCounted

const REGION_CHANCE_DIVISOR := 6

const REWARD_DEFS: Array[Dictionary] = [
	{"id": "weapon:3", "tier": 0, "label": "SMG"},
	{"id": "build:reinforced_barrier", "tier": 0, "label": "REINFORCED BARRIER KIT"},
	{"id": "build:land_mine", "tier": 1, "label": "LAND MINE KIT"},
	{"id": "weapon:4", "tier": 2, "label": "RAILGUN"},
	{"id": "build:rocket_turret", "tier": 2, "label": "ROCKET TURRET KIT"},
	{"id": "build:blast_barrier", "tier": 2, "label": "BLAST BARRIER KIT"},
	{"id": "weapon:5", "tier": 3, "label": "FLAMETHROWER"},
	{"id": "build:laser_turret", "tier": 3, "label": "LASER TURRET KIT"},
]


static func _hash(seed: int, x: int, y: int, salt: int = 0) -> int:
	var value := seed ^ (x * 92821) ^ (y * 68917) ^ salt
	value = value ^ (value >> 13)
	value *= 1274126177
	return value ^ (value >> 16)


static func should_spawn(seed: int, region: Vector2i, origin_region: Vector2i) -> bool:
	var distance := absi(region.x - origin_region.x) + absi(region.y - origin_region.y)
	if distance < 2:
		return false
	return posmod(_hash(seed, region.x, region.y, 0x46f07e55), REGION_CHANCE_DIVISOR) == 0


static func luck_tier(region_distance: int, expedition_level: int, awareness_tier: int) -> int:
	var depth_luck := maxi(0, region_distance - 1) / 4
	var progress_luck := maxi(0, expedition_level) / 10
	var pressure_luck := maxi(0, awareness_tier) / 2
	return clampi(depth_luck + progress_luck + pressure_luck, 0, 3)


static func _is_locked(reward: Dictionary, unlocked_weapons: Array[bool], construction_unlocks: Dictionary) -> bool:
	var reward_id := str(reward.get("id", ""))
	if reward_id.begins_with("weapon:"):
		var weapon_id := int(reward_id.trim_prefix("weapon:"))
		return weapon_id >= 0 and weapon_id < unlocked_weapons.size() and not unlocked_weapons[weapon_id]
	if reward_id.begins_with("build:"):
		return not bool(construction_unlocks.get(reward_id.trim_prefix("build:"), false))
	return false


static func choose_locked_reward(seed: int, cell: Vector2i, unlocked_weapons: Array[bool], construction_unlocks: Dictionary, max_luck_tier: int) -> Dictionary:
	var locked: Array[Dictionary] = []
	var eligible: Array[Dictionary] = []
	for reward: Dictionary in REWARD_DEFS:
		if not _is_locked(reward, unlocked_weapons, construction_unlocks):
			continue
		locked.append(reward)
		if int(reward.get("tier", 0)) <= max_luck_tier:
			eligible.append(reward)
	if eligible.is_empty() and not locked.is_empty():
		var lowest_tier := 99
		for reward: Dictionary in locked:
			lowest_tier = mini(lowest_tier, int(reward.get("tier", 0)))
		for reward: Dictionary in locked:
			if int(reward.get("tier", 0)) == lowest_tier:
				eligible.append(reward)
	if eligible.is_empty():
		return {}
	var index := posmod(_hash(seed, cell.x, cell.y, 0x2b116b31), eligible.size())
	return eligible[index].duplicate(true)


static func minor_loot(seed: int, region: Vector2i, max_luck_tier: int) -> Dictionary:
	var common: Array[String] = ["granite", "basalt", "coal", "iron_ore", "copper_ore"]
	var uncommon: Array[String] = ["quartz", "silver_ore", "sulfur", "energy_crystal", "titanium_ore"]
	var first_index := posmod(_hash(seed, region.x, region.y, 0x19d24a17), common.size())
	var second_pool := uncommon if max_luck_tier >= 1 else common
	var second_index := posmod(_hash(seed, region.x, region.y, 0x6a3c194d), second_pool.size())
	var loot := {common[first_index]: 8 + max_luck_tier * 3}
	var second_id: String = second_pool[second_index]
	loot[second_id] = int(loot.get(second_id, 0)) + 3 + max_luck_tier * 2
	return loot
