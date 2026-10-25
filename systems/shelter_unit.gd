class_name ShelterUnit
extends RefCounted

const HEAL_RATES: Array[float] = [0.0, 48.0, 88.0, 150.0]
const ENERGY_RATES: Array[float] = [0.0, 36.0, 58.0, 92.0]
const REST_DURATIONS: Array[float] = [0.0, 1.85, 1.35, 0.95]
const COOLDOWNS: Array[float] = [0.0, 300.0, 210.0, 120.0]
const UPGRADE_REQUIREMENTS: Array[Dictionary] = [
	{},
	{},
	{MaterialEconomy.STONE_BLOCK: 2, MaterialEconomy.BRONZE_INGOT: 1},
	{MaterialEconomy.STEEL_PLATE: 2, MaterialEconomy.REINFORCED_BLOCK: 1},
]


static func clamp_tier(tier: int) -> int:
	return clampi(tier, 1, 3)


static func heal_rate(tier: int) -> float:
	return HEAL_RATES[clamp_tier(tier)]


static func energy_rate(tier: int) -> float:
	return ENERGY_RATES[clamp_tier(tier)]


static func rest_duration(tier: int) -> float:
	return REST_DURATIONS[clamp_tier(tier)]


static func cooldown(tier: int) -> float:
	return COOLDOWNS[clamp_tier(tier)]


static func upgrade_requirements(tier: int) -> Dictionary:
	return UPGRADE_REQUIREMENTS[clamp_tier(tier)].duplicate(true) if clamp_tier(tier) < 3 else {}


static func ready(structure: Object) -> bool:
	return float(structure.cooldown) <= 0.0


static func apply_rest(structure: Object, health: float, energy: float, delta: float) -> Dictionary:
	var tier := clamp_tier(int(structure.level))
	return {
		"health": minf(100.0, health + heal_rate(tier) * delta),
		"energy": minf(100.0, energy + energy_rate(tier) * delta),
	}


static func begin_cooldown(structure: Object) -> void:
	structure.cooldown = cooldown(clamp_tier(int(structure.level)))
