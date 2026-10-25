class_name BiomeWallEconomy
extends RefCounted

## Converts ordinary biome wall mass into a consistent economy loop.
## Natural walls become either reusable wall blocks (Mining MK2+) or biome salvage.
## Recovered wall blocks can be placed again, recycled into raw feedstock, or sold.

const MaterialEconomyScript := preload("res://systems/material_economy.gd")
const WorldGridScript := preload("res://systems/world_grid.gd")

const PROFILES: Dictionary = {
	WorldGridScript.BIOME_TUNNEL: {
		"label": "TUNNEL CRUST",
		"primary": MaterialEconomyScript.GRANITE,
		"secondary": MaterialEconomyScript.COPPER_ORE,
		"secondary_period": 4,
		"recycle_divisor": 4,
		"sale": 3,
	},
	WorldGridScript.BIOME_HIVE: {
		"label": "HIVE BAND",
		"primary": MaterialEconomyScript.BASALT,
		"secondary": MaterialEconomyScript.SULFUR,
		"secondary_period": 6,
		"recycle_divisor": 5,
		"sale": 4,
	},
	WorldGridScript.BIOME_BUNKER: {
		"label": "BUNKER SHELL",
		"primary": MaterialEconomyScript.GRANITE,
		"secondary": MaterialEconomyScript.IRON_ORE,
		"secondary_period": 5,
		"recycle_divisor": 4,
		"sale": 4,
	},
	WorldGridScript.BIOME_CRYSTAL: {
		"label": "CRYSTAL CAVERN",
		"primary": MaterialEconomyScript.QUARTZ,
		"secondary": MaterialEconomyScript.ENERGY_CRYSTAL,
		"secondary_period": 5,
		"recycle_divisor": 5,
		"sale": 6,
	},
	WorldGridScript.BIOME_FOUNDRY: {
		"label": "FOUNDRY DEPTHS",
		"primary": MaterialEconomyScript.IRON_ORE,
		"secondary": MaterialEconomyScript.COAL,
		"secondary_period": 4,
		"recycle_divisor": 3,
		"sale": 5,
	},
	WorldGridScript.BIOME_SULFUR: {
		"label": "SULFUR BOG",
		"primary": MaterialEconomyScript.SULFUR,
		"secondary": MaterialEconomyScript.COAL,
		"secondary_period": 4,
		"recycle_divisor": 4,
		"sale": 5,
	},
	WorldGridScript.BIOME_IRON: {
		"label": "IRON STRATA",
		"primary": MaterialEconomyScript.IRON_ORE,
		"secondary": MaterialEconomyScript.TITANIUM_ORE,
		"secondary_period": 7,
		"recycle_divisor": 6,
		"sale": 6,
	},
}


static func profile(biome_id: int) -> Dictionary:
	var selected: Dictionary = PROFILES.get(biome_id, PROFILES[WorldGridScript.BIOME_TUNNEL])
	return selected.duplicate(true)


static func biome_label(biome_id: int) -> String:
	return str(profile(biome_id).get("label", "WALL"))


static func natural_salvage(biome_id: int, cell: Vector2i, run_seed: int) -> Dictionary:
	## A mined natural wall always contributes one common biome material. A
	## deterministic fraction also contributes one secondary biome resource.
	var wall_profile: Dictionary = profile(biome_id)
	var result: Dictionary = {}
	var primary: String = str(wall_profile.get("primary", MaterialEconomyScript.GRANITE))
	var secondary: String = str(wall_profile.get("secondary", ""))
	result[primary] = 1
	var period: int = maxi(1, int(wall_profile.get("secondary_period", 5)))
	if not secondary.is_empty() and _cell_roll(cell, biome_id, run_seed) % period == 0:
		result[secondary] = int(result.get(secondary, 0)) + 1
	return result


static func recycle_manifest(biome_id: int, block_count: int) -> Dictionary:
	## Recycling deliberately produces common material at 1:1 plus a modest
	## secondary yield. The Foundry remains the conversion step into components.
	var count: int = maxi(0, block_count)
	if count <= 0:
		return {}
	var wall_profile: Dictionary = profile(biome_id)
	var result: Dictionary = {}
	var primary: String = str(wall_profile.get("primary", MaterialEconomyScript.GRANITE))
	var secondary: String = str(wall_profile.get("secondary", ""))
	result[primary] = count
	var divisor: int = maxi(1, int(wall_profile.get("recycle_divisor", 4)))
	var secondary_units: int = floori(float(count) / float(divisor))
	if secondary_units > 0 and not secondary.is_empty():
		result[secondary] = int(result.get(secondary, 0)) + secondary_units
	return result


static func manifest_units(manifest: Dictionary) -> int:
	var total: int = 0
	for material_id: Variant in manifest.keys():
		total += maxi(0, int(manifest[material_id]))
	return total


static func block_sale_value(biome_id: int, block_count: int = 1) -> int:
	return maxi(0, block_count) * maxi(0, int(profile(biome_id).get("sale", 0)))


static func _cell_roll(cell: Vector2i, biome_id: int, run_seed: int) -> int:
	var mixed: int = int(run_seed)
	mixed = mixed ^ (cell.x * 73856093)
	mixed = mixed ^ (cell.y * 19349663)
	mixed = mixed ^ ((biome_id + 1) * 83492791)
	return posmod(mixed, 2147483647)
