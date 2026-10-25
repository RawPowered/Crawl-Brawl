class_name MaterialEconomy
extends RefCounted

const COPPER_ORE := "copper_ore"
const SILVER_ORE := "silver_ore"
const GOLD_ORE := "gold_ore"
const ENERGY_CRYSTAL := "energy_crystal"
const ROUGH_DIAMOND := "rough_diamond"
const GRANITE := "granite"
const BASALT := "basalt"
const QUARTZ := "quartz"
const IRON_ORE := "iron_ore"
const TITANIUM_ORE := "titanium_ore"
const SULFUR := "sulfur"
const COAL := "coal"

const BRONZE_INGOT := "bronze_ingot"
const SILVER_INGOT := "silver_ingot"
const GOLD_INGOT := "gold_ingot"
const CRYSTAL_CORE := "crystal_core"
const CUT_DIAMOND := "cut_diamond"
const STONE_BLOCK := "stone_block"
const REINFORCED_BLOCK := "reinforced_block"
const STEEL_PLATE := "steel_plate"
const TITANIUM_PLATE := "titanium_plate"
const EXPLOSIVE_COMPOUND := "explosive_compound"
const OPTIC_CORE := "optic_core"

func foundry_upgrade_cost(tier: int) -> int:
	# Industry is the bridge between mining and construction; keep each tier
	# reachable inside normal play instead of requiring long cash-only grinds.
	match tier:
		0: return 300
		1: return 900
		2: return 2200
	return 0

const CONTRACT_DURATION := 24.0
const FoundryUnitScript := preload("res://systems/foundry_unit.gd")
const FOUNDRY_BATCH_DURATIONS: Array[float] = FoundryUnitScript.BATCH_DURATIONS
const FOUNDRY_QUEUE_LIMIT := 64

const RAW_ORDER: Array[String] = [COPPER_ORE, SILVER_ORE, GOLD_ORE, ENERGY_CRYSTAL, ROUGH_DIAMOND, GRANITE, BASALT, QUARTZ, IRON_ORE, TITANIUM_ORE, SULFUR, COAL]
const REFINED_ORDER: Array[String] = [BRONZE_INGOT, SILVER_INGOT, GOLD_INGOT, CRYSTAL_CORE, CUT_DIAMOND, STONE_BLOCK, REINFORCED_BLOCK, STEEL_PLATE, TITANIUM_PLATE, EXPLOSIVE_COMPOUND, OPTIC_CORE]

var raw: Dictionary = {}
var refined: Dictionary = {}
var foundry_output: Dictionary = {}
var foundry_tier := 0
var foundry_queue: Array[String] = []
var active_recipe := ""
var active_recipe_remaining := 0.0
var active_recipe_duration := 0.0
var contract_manifest: Dictionary = {}
var contract_remaining := 0.0
var contract_payout := 0


func _init() -> void:
	_reset_inventory()


func _reset_inventory() -> void:
	for material_id: String in RAW_ORDER:
		raw[material_id] = 0
	for material_id: String in REFINED_ORDER:
		refined[material_id] = 0
		foundry_output[material_id] = 0


func add_raw(material_id: String, amount: int) -> void:
	if raw.has(material_id):
		raw[material_id] = int(raw[material_id]) + maxi(0, amount)


func raw_total() -> int:
	var total := 0
	for amount: Variant in raw.values():
		total += int(amount)
	return total


func refined_total() -> int:
	var total := 0
	for amount: Variant in refined.values():
		total += int(amount)
	return total


func foundry_output_total() -> int:
	var total := 0
	for amount: Variant in foundry_output.values():
		total += int(amount)
	return total


func inventory_units() -> int:
	return raw_total() + refined_total()


func contract_active() -> bool:
	return contract_remaining > 0.0


func contract_value() -> int:
	var values := {
		COPPER_ORE: 5, SILVER_ORE: 11, GOLD_ORE: 18, ENERGY_CRYSTAL: 24, ROUGH_DIAMOND: 45,
		GRANITE: 3, BASALT: 5, QUARTZ: 9, IRON_ORE: 8, TITANIUM_ORE: 22, SULFUR: 7, COAL: 4,
	}
	var value := 0
	for material_id: String in RAW_ORDER:
		value += int(raw[material_id]) * int(values.get(material_id, 0))
	return value


func raw_quick_sale_value() -> int:
	# Immediate liquidation trades margin for instant credits and freed pack space.
	return floori(float(contract_value()) * 0.65)


func sell_raw_quick() -> int:
	var payout: int = raw_quick_sale_value()
	if payout <= 0:
		return 0
	for material_id: String in RAW_ORDER:
		raw[material_id] = 0
	return payout


func begin_contract() -> bool:
	if contract_active() or raw_total() <= 0:
		return false
	contract_manifest = raw.duplicate(true)
	contract_payout = contract_value()
	for material_id: String in RAW_ORDER:
		raw[material_id] = 0
	contract_remaining = CONTRACT_DURATION
	return true


func tick_contract(delta: float) -> int:
	if not contract_active():
		return 0
	contract_remaining = maxf(0.0, contract_remaining - delta)
	if contract_remaining > 0.0:
		return 0
	var payout := contract_payout
	contract_manifest.clear()
	contract_payout = 0
	return payout


func unlock_foundry() -> bool:
	if foundry_tier >= 3:
		return false
	var old_duration := foundry_batch_duration()
	foundry_tier += 1
	var new_duration := foundry_batch_duration()
	if not active_recipe.is_empty() and old_duration > 0.0:
		active_recipe_remaining *= new_duration / old_duration
		active_recipe_duration = new_duration
	return true


func foundry_batch_duration(tier_override: int = -1) -> float:
	var tier := foundry_tier if tier_override < 0 else tier_override
	return FoundryUnitScript.batch_duration(tier)


func recipe_required_tier(raw_id: String) -> int:
	match raw_id:
		COPPER_ORE, SILVER_ORE, GRANITE:
			return 1
		GOLD_ORE, BASALT, IRON_ORE, QUARTZ, ENERGY_CRYSTAL:
			return 2
		TITANIUM_ORE, SULFUR, ROUGH_DIAMOND:
			return 3
	return 99


func queue_size() -> int:
	return foundry_queue.size() + (0 if active_recipe.is_empty() else 1)


func queue_full() -> bool:
	return queue_size() >= FOUNDRY_QUEUE_LIMIT


func queue_refinement(raw_id: String) -> bool:
	if queue_full() or not can_refine(raw_id):
		return false
	var requirements: Dictionary = recipe_requirements(raw_id)
	for material_id: String in requirements.keys():
		raw[material_id] = int(raw[material_id]) - int(requirements[material_id])
	foundry_queue.append(raw_id)
	_start_next_refinement()
	return true


func queue_all_available() -> int:
	var queued := 0
	while not queue_full():
		var raw_id := next_recipe()
		if raw_id.is_empty() or not queue_refinement(raw_id):
			break
		queued += 1
	return queued


func tick_foundry(delta: float, operational: bool) -> Dictionary:
	var completed: Dictionary = {}
	if not operational or foundry_tier <= 0 or delta <= 0.0:
		return completed
	_start_next_refinement()
	var remaining_delta := delta
	while remaining_delta > 0.0 and not active_recipe.is_empty():
		var elapsed := minf(remaining_delta, active_recipe_remaining)
		active_recipe_remaining -= elapsed
		remaining_delta -= elapsed
		if active_recipe_remaining > 0.0001:
			break
		var output_id := recipe_output(active_recipe)
		var output_amount := recipe_output_amount(active_recipe)
		if not output_id.is_empty():
			foundry_output[output_id] = int(foundry_output[output_id]) + output_amount
			completed[output_id] = int(completed.get(output_id, 0)) + output_amount
		active_recipe = ""
		active_recipe_remaining = 0.0
		active_recipe_duration = 0.0
		_start_next_refinement()
	return completed


func active_progress() -> float:
	if active_recipe.is_empty() or active_recipe_duration <= 0.0:
		return 0.0
	return clampf(1.0 - active_recipe_remaining / active_recipe_duration, 0.0, 1.0)


func _start_next_refinement() -> void:
	if not active_recipe.is_empty() or foundry_queue.is_empty() or foundry_tier <= 0:
		return
	active_recipe = foundry_queue.pop_front()
	active_recipe_duration = foundry_batch_duration()
	active_recipe_remaining = active_recipe_duration


func next_recipe(tier_override: int = -1) -> String:
	for material_id: String in RAW_ORDER:
		if can_refine(material_id, tier_override):
			return material_id
	return ""


func can_refine(raw_id: String, tier_override: int = -1) -> bool:
	var tier := foundry_tier if tier_override < 0 else tier_override
	if tier < recipe_required_tier(raw_id):
		return false
	var requirements: Dictionary = recipe_requirements(raw_id)
	if requirements.is_empty():
		return false
	for material_id: String in requirements.keys():
		if int(raw.get(material_id, 0)) < int(requirements[material_id]):
			return false
	return true


func refine(raw_id: String) -> String:
	if not can_refine(raw_id):
		return ""
	var output_id := recipe_output(raw_id)
	var requirements: Dictionary = recipe_requirements(raw_id)
	for material_id: String in requirements.keys():
		raw[material_id] = int(raw[material_id]) - int(requirements[material_id])
	refined[output_id] = int(refined[output_id]) + recipe_output_amount(raw_id)
	return output_id


func recipe_raw_cost(raw_id: String) -> int:
	return int(recipe_requirements(raw_id).get(raw_id, 0))


func recipe_requirements(raw_id: String) -> Dictionary:
	match raw_id:
		COPPER_ORE:
			return {COPPER_ORE: 3}
		SILVER_ORE, GOLD_ORE, ENERGY_CRYSTAL:
			return {raw_id: 2}
		ROUGH_DIAMOND:
			return {ROUGH_DIAMOND: 1}
		GRANITE:
			return {GRANITE: 3}
		BASALT:
			return {BASALT: 3}
		QUARTZ:
			return {QUARTZ: 2}
		IRON_ORE:
			return {IRON_ORE: 2, COAL: 1}
		TITANIUM_ORE:
			return {TITANIUM_ORE: 2, COAL: 2}
		SULFUR:
			return {SULFUR: 2, COAL: 2}
	return {}


func recipe_output(raw_id: String) -> String:
	match raw_id:
		COPPER_ORE:
			return BRONZE_INGOT
		SILVER_ORE:
			return SILVER_INGOT
		GOLD_ORE:
			return GOLD_INGOT
		ENERGY_CRYSTAL:
			return CRYSTAL_CORE
		ROUGH_DIAMOND:
			return CUT_DIAMOND
		GRANITE:
			return STONE_BLOCK
		BASALT:
			return REINFORCED_BLOCK
		QUARTZ:
			return OPTIC_CORE
		IRON_ORE:
			return STEEL_PLATE
		TITANIUM_ORE:
			return TITANIUM_PLATE
		SULFUR:
			return EXPLOSIVE_COMPOUND
	return ""


func recipe_output_amount(raw_id: String, tier_override: int = -1) -> int:
	var tier := foundry_tier if tier_override < 0 else tier_override
	# The owned Foundry recovers an extra common-metal ingot per batch.
	if tier > 0 and raw_id in [COPPER_ORE, SILVER_ORE, GOLD_ORE, GRANITE]:
		return 2
	return 1


func refined_sale_value() -> int:
	return _processed_stock_value(refined)


func foundry_output_sale_value() -> int:
	return _processed_stock_value(foundry_output)


func _processed_stock_value(stock: Dictionary) -> int:
	var values := {
		BRONZE_INGOT: 22, SILVER_INGOT: 38, GOLD_INGOT: 65, CRYSTAL_CORE: 85, CUT_DIAMOND: 150,
		STONE_BLOCK: 12, REINFORCED_BLOCK: 28, STEEL_PLATE: 42, TITANIUM_PLATE: 95,
		EXPLOSIVE_COMPOUND: 58, OPTIC_CORE: 72,
	}
	var value := 0
	for material_id: String in REFINED_ORDER:
		value += int(stock.get(material_id, 0)) * int(values.get(material_id, 0))
	return value


func sell_refined() -> int:
	var payout := refined_sale_value()
	if payout <= 0:
		return 0
	for material_id: String in REFINED_ORDER:
		refined[material_id] = 0
	return payout


func collect_foundry_output(max_units: int) -> Dictionary:
	var collected: Dictionary = {}
	var remaining := maxi(0, max_units)
	for material_id: String in REFINED_ORDER:
		if remaining <= 0:
			break
		var available := int(foundry_output.get(material_id, 0))
		var moved := mini(available, remaining)
		if moved <= 0:
			continue
		foundry_output[material_id] = available - moved
		refined[material_id] = int(refined[material_id]) + moved
		collected[material_id] = moved
		remaining -= moved
	return collected


func sell_foundry_output() -> int:
	if foundry_tier < 2:
		return 0
	var payout := foundry_output_sale_value()
	if payout <= 0:
		return 0
	for material_id: String in REFINED_ORDER:
		foundry_output[material_id] = 0
	return payout


func has_refined(requirements: Dictionary) -> bool:
	for material_id: String in requirements.keys():
		if int(refined.get(material_id, 0)) < int(requirements[material_id]):
			return false
	return true


func spend_refined(requirements: Dictionary) -> bool:
	if not has_refined(requirements):
		return false
	for material_id: String in requirements.keys():
		refined[material_id] = int(refined[material_id]) - int(requirements[material_id])
	return true


func short_raw_manifest() -> String:
	return "ORE %d  STONE %d  TECH %d" % [int(raw[COPPER_ORE]) + int(raw[SILVER_ORE]) + int(raw[GOLD_ORE]) + int(raw[IRON_ORE]) + int(raw[TITANIUM_ORE]), int(raw[GRANITE]) + int(raw[BASALT]) + int(raw[COAL]), int(raw[ENERGY_CRYSTAL]) + int(raw[ROUGH_DIAMOND]) + int(raw[QUARTZ]) + int(raw[SULFUR])]


func short_refined_manifest() -> String:
	return "METAL %d  BLOCK %d  TECH %d" % [int(refined[BRONZE_INGOT]) + int(refined[SILVER_INGOT]) + int(refined[GOLD_INGOT]) + int(refined[STEEL_PLATE]) + int(refined[TITANIUM_PLATE]), int(refined[STONE_BLOCK]) + int(refined[REINFORCED_BLOCK]), int(refined[CRYSTAL_CORE]) + int(refined[CUT_DIAMOND]) + int(refined[EXPLOSIVE_COMPOUND]) + int(refined[OPTIC_CORE])]


func raw_manifest() -> String:
	return "Copper %d Silver %d Gold %d Iron %d Titanium %d\nGranite %d Basalt %d Quartz %d Sulfur %d Coal %d\nCrystal %d Diamond %d" % [raw[COPPER_ORE], raw[SILVER_ORE], raw[GOLD_ORE], raw[IRON_ORE], raw[TITANIUM_ORE], raw[GRANITE], raw[BASALT], raw[QUARTZ], raw[SULFUR], raw[COAL], raw[ENERGY_CRYSTAL], raw[ROUGH_DIAMOND]]


func refined_manifest() -> String:
	return "Bronze %d Ag %d Au %d Steel %d Ti %d\nStone %d Reinforced %d\nCore %d Optic %d Explosive %d Cut %d" % [refined[BRONZE_INGOT], refined[SILVER_INGOT], refined[GOLD_INGOT], refined[STEEL_PLATE], refined[TITANIUM_PLATE], refined[STONE_BLOCK], refined[REINFORCED_BLOCK], refined[CRYSTAL_CORE], refined[OPTIC_CORE], refined[EXPLOSIVE_COMPOUND], refined[CUT_DIAMOND]]


func foundry_output_manifest() -> String:
	return "Bronze %d Ag %d Au %d Steel %d Ti %d\nStone %d Reinforced %d\nCore %d Optic %d Explosive %d Cut %d" % [foundry_output[BRONZE_INGOT], foundry_output[SILVER_INGOT], foundry_output[GOLD_INGOT], foundry_output[STEEL_PLATE], foundry_output[TITANIUM_PLATE], foundry_output[STONE_BLOCK], foundry_output[REINFORCED_BLOCK], foundry_output[CRYSTAL_CORE], foundry_output[OPTIC_CORE], foundry_output[EXPLOSIVE_COMPOUND], foundry_output[CUT_DIAMOND]]


func clear_legacy_foundry_production() -> void:
	for material_id: String in REFINED_ORDER:
		foundry_output[material_id] = 0
	foundry_queue.clear()
	active_recipe = ""
	active_recipe_remaining = 0.0
	active_recipe_duration = 0.0


func serialize() -> Dictionary:
	return {
		"raw": raw.duplicate(true),
		"refined": refined.duplicate(true),
		"foundry_tier": foundry_tier,
		"contract_manifest": contract_manifest.duplicate(true),
		"contract_remaining": contract_remaining,
		"contract_payout": contract_payout,
	}


func restore(data: Dictionary) -> void:
	_reset_inventory()
	var saved_raw: Dictionary = data.get("raw", {})
	var saved_refined: Dictionary = data.get("refined", {})
	var saved_foundry_output: Dictionary = data.get("foundry_output", {})
	for material_id: String in RAW_ORDER:
		raw[material_id] = maxi(0, int(saved_raw.get(material_id, 0)))
	for material_id: String in REFINED_ORDER:
		# BV4 migration: older chest Withdraw All wrote refined cargo into the raw
		# dictionary. Recover those units on load instead of silently discarding them.
		var misplaced_refined: int = maxi(0, int(saved_raw.get(material_id, 0)))
		refined[material_id] = maxi(0, int(saved_refined.get(material_id, 0))) + misplaced_refined
		foundry_output[material_id] = maxi(0, int(saved_foundry_output.get(material_id, 0)))
	foundry_tier = clampi(int(data.get("foundry_tier", 0)), 0, 3)
	foundry_queue.clear()
	for queued_value: Variant in data.get("foundry_queue", []):
		var queued_id := str(queued_value)
		if not recipe_output(queued_id).is_empty() and foundry_queue.size() < FOUNDRY_QUEUE_LIMIT:
			foundry_queue.append(queued_id)
	active_recipe = str(data.get("active_recipe", ""))
	if recipe_output(active_recipe).is_empty():
		active_recipe = ""
	active_recipe_duration = maxf(0.0, float(data.get("active_recipe_duration", foundry_batch_duration())))
	active_recipe_remaining = clampf(float(data.get("active_recipe_remaining", active_recipe_duration)), 0.0, active_recipe_duration)
	if not active_recipe.is_empty() and active_recipe_duration <= 0.0:
		active_recipe_duration = foundry_batch_duration()
		active_recipe_remaining = active_recipe_duration
	_start_next_refinement()
	contract_manifest = data.get("contract_manifest", {}).duplicate(true)
	contract_remaining = maxf(0.0, float(data.get("contract_remaining", 0.0)))
	contract_payout = maxi(0, int(data.get("contract_payout", 0)))


# Consume up to `amount` raw units from inventory, returning how many were consumed.
func consume_raw_any(amount: int) -> int:
	var remaining := amount
	for material_id: String in RAW_ORDER:
		var have: int = int(raw.get(material_id, 0))
		var take := mini(have, remaining)
		if take > 0:
			raw[material_id] = have - take
			remaining -= take
		if remaining <= 0:
			break
	return amount - remaining


# Consume up to `amount` refined units from inventory, returning how many were consumed.
func consume_refined_any(amount: int) -> int:
	var remaining := amount
	for material_id: String in REFINED_ORDER:
		var have: int = int(refined.get(material_id, 0))
		var take := mini(have, remaining)
		if take > 0:
			refined[material_id] = have - take
			remaining -= take
		if remaining <= 0:
			break
	return amount - remaining


# Add `amount` refined units to a specific slot (or fallback to STONE_BLOCK).
func add_refined(material_id: String, amount: int) -> void:
	if refined.has(material_id):
		refined[material_id] = int(refined[material_id]) + maxi(0, amount)
