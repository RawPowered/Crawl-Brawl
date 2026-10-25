class_name UpgradeEconomy
extends RefCounted

const MaterialEconomyScript := preload("res://systems/material_economy.gd")


static func sentry_upgrade_sp(current_tier: int) -> int:
	match clampi(current_tier, 1, 3):
		1, 2:
			return 1
		_:
			return 2


static func frontier_core_upgrade_sp(current_tier: int) -> int:
	return 1 if clampi(current_tier, 1, 2) == 1 else 2


static func personal_base_upgrade_sp(current_tier: int) -> int:
	return 1


static func frontier_core_material_requirements(current_tier: int) -> Dictionary:
	if clampi(current_tier, 1, 2) == 1:
		return {MaterialEconomyScript.BRONZE_INGOT: 2, MaterialEconomyScript.SILVER_INGOT: 1}
	return {MaterialEconomyScript.GOLD_INGOT: 2, MaterialEconomyScript.CUT_DIAMOND: 1}


static func personal_base_upgrade_requirements(current_tier: int) -> Dictionary:
	const ShelterUnitScript := preload("res://systems/shelter_unit.gd")
	return ShelterUnitScript.upgrade_requirements(current_tier)


static func turret_material_requirements(current_tier: int, _kind: int = 0) -> Dictionary:
	match clampi(current_tier, 1, 3):
		1:
			return {MaterialEconomyScript.BRONZE_INGOT: 1}
		2:
			return {MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.BRONZE_INGOT: 1}
		_:
			return {MaterialEconomyScript.GOLD_INGOT: 1, MaterialEconomyScript.CUT_DIAMOND: 1}
	return {}


static func turret_mk4_material_totals() -> Dictionary:
	return {
		MaterialEconomyScript.BRONZE_INGOT: 2,
		MaterialEconomyScript.SILVER_INGOT: 1,
		MaterialEconomyScript.GOLD_INGOT: 1,
		MaterialEconomyScript.CUT_DIAMOND: 1,
	}


static func mining_upgrade_requirements(speed_upgrade: bool, current_tier: int) -> Dictionary:
	if speed_upgrade:
		match clampi(current_tier, 1, 4):
			1:
				return {MaterialEconomyScript.BRONZE_INGOT: 1}
			2:
				return {MaterialEconomyScript.BRONZE_INGOT: 1, MaterialEconomyScript.SILVER_INGOT: 1}
			3:
				return {MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.GOLD_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
			_:
				return {MaterialEconomyScript.GOLD_INGOT: 2, MaterialEconomyScript.CRYSTAL_CORE: 2, MaterialEconomyScript.CUT_DIAMOND: 1}
	match clampi(current_tier, 1, 4):
		1:
			return {MaterialEconomyScript.BRONZE_INGOT: 1}
		2:
			return {MaterialEconomyScript.BRONZE_INGOT: 1, MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
		3:
			return {MaterialEconomyScript.SILVER_INGOT: 2, MaterialEconomyScript.GOLD_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
		_:
			return {MaterialEconomyScript.GOLD_INGOT: 2, MaterialEconomyScript.CRYSTAL_CORE: 2, MaterialEconomyScript.CUT_DIAMOND: 1}
	return {}


static func construction_research_cost(construction_id: String) -> int:
	return int({
		"reinforced_barrier": 250,
		"blast_barrier": 800,
		"land_mine": 500,
		"rocket_turret": 1200,
		"laser_turret": 1800,
		"chest_small": 0,
		"chest_medium": 0,
		"chest_large": 0,
		"heavy_doorway": 350,
	}.get(construction_id, 0))


static func construction_craft_cost(construction_id: String) -> int:
	return int({
		"granite_barrier": 15,
		"steel_barrier": 30,
		"reinforced_barrier": 40,
		"blast_barrier": 70,
		"land_mine": 25,
		"rocket_turret": 150,
		"laser_turret": 225,
		"chest_small": 60,
		"chest_medium": 140,
		"chest_large": 300,
		"heavy_doorway": 100,
	}.get(construction_id, 0))


static func construction_research_requirements(construction_id: String) -> Dictionary:
	match construction_id:
		"reinforced_barrier":
			return {MaterialEconomyScript.STONE_BLOCK: 2, MaterialEconomyScript.STEEL_PLATE: 1}
		"blast_barrier":
			return {MaterialEconomyScript.REINFORCED_BLOCK: 3, MaterialEconomyScript.TITANIUM_PLATE: 1, MaterialEconomyScript.EXPLOSIVE_COMPOUND: 1}
		"land_mine":
			return {MaterialEconomyScript.STEEL_PLATE: 2, MaterialEconomyScript.EXPLOSIVE_COMPOUND: 1}
		"rocket_turret":
			return {MaterialEconomyScript.STEEL_PLATE: 3, MaterialEconomyScript.EXPLOSIVE_COMPOUND: 2}
		"laser_turret":
			return {MaterialEconomyScript.TITANIUM_PLATE: 2, MaterialEconomyScript.OPTIC_CORE: 2, MaterialEconomyScript.CRYSTAL_CORE: 2, MaterialEconomyScript.CUT_DIAMOND: 1}
		"heavy_doorway":
			# The first functional gate belongs to early industry, not end-game metal.
			return {MaterialEconomyScript.STONE_BLOCK: 2, MaterialEconomyScript.BRONZE_INGOT: 1}
	return {}


static func construction_craft_requirements(construction_id: String) -> Dictionary:
	match construction_id:
		"granite_barrier":
			return {MaterialEconomyScript.STONE_BLOCK: 1}
		"steel_barrier":
			return {MaterialEconomyScript.STONE_BLOCK: 1, MaterialEconomyScript.STEEL_PLATE: 1}
		"reinforced_barrier":
			return {MaterialEconomyScript.REINFORCED_BLOCK: 1, MaterialEconomyScript.STEEL_PLATE: 1}
		"blast_barrier":
			return {MaterialEconomyScript.REINFORCED_BLOCK: 2, MaterialEconomyScript.TITANIUM_PLATE: 1}
		"land_mine":
			return {MaterialEconomyScript.STEEL_PLATE: 1, MaterialEconomyScript.EXPLOSIVE_COMPOUND: 1}
		"rocket_turret":
			return {MaterialEconomyScript.STEEL_PLATE: 2, MaterialEconomyScript.EXPLOSIVE_COMPOUND: 2}
		"laser_turret":
			return {MaterialEconomyScript.TITANIUM_PLATE: 2, MaterialEconomyScript.OPTIC_CORE: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
		"chest_small":
			return {MaterialEconomyScript.STONE_BLOCK: 2}
		"chest_medium":
			return {MaterialEconomyScript.STONE_BLOCK: 5, MaterialEconomyScript.REINFORCED_BLOCK: 2}
		"chest_large":
			return {MaterialEconomyScript.REINFORCED_BLOCK: 8, MaterialEconomyScript.STEEL_PLATE: 4}
		"heavy_doorway":
			return {MaterialEconomyScript.STONE_BLOCK: 4, MaterialEconomyScript.BRONZE_INGOT: 1}
	return {}


static func doorway_upgrade_cost(current_level: int) -> int:
	match clampi(current_level, 1, 3):
		1: return 200
		2: return 500
	return 0


static func doorway_upgrade_requirements(current_level: int) -> Dictionary:
	match clampi(current_level, 1, 3):
		1:
			return {MaterialEconomyScript.REINFORCED_BLOCK: 2, MaterialEconomyScript.STEEL_PLATE: 1}
		2:
			return {MaterialEconomyScript.REINFORCED_BLOCK: 5, MaterialEconomyScript.TITANIUM_PLATE: 2, MaterialEconomyScript.STEEL_PLATE: 2}
	return {}


static func scrap_co_pay(_category: String) -> int:
	return 0
