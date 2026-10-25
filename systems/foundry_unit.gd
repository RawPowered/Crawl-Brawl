class_name FoundryUnit
extends RefCounted

const BATCH_DURATIONS: Array[float] = [0.0, 8.0, 4.0, 2.0]
const QUEUE_LIMITS: Array[int] = [0, 6, 14, 28]
const OUTPUT_LIMITS: Array[int] = [0, 20, 48, 96]

const STATE_OUTPUT := "output"
const STATE_QUEUE := "queue"
const STATE_ACTIVE_RECIPE := "active_recipe"
const STATE_ACTIVE_REMAINING := "active_recipe_remaining"
const STATE_ACTIVE_DURATION := "active_recipe_duration"
const STATE_COAL_FUEL := "coal_fuel"
const FUEL_CAPS: Array[int] = [0, 24, 48, 96]
const FUEL_PER_BATCH := 1


static func batch_duration(tier: int) -> float:
	return BATCH_DURATIONS[clampi(tier, 0, 3)]


static func queue_limit(tier: int) -> int:
	return QUEUE_LIMITS[clampi(tier, 0, 3)]


static func output_limit(tier: int) -> int:
	return OUTPUT_LIMITS[clampi(tier, 0, 3)]


static func fuel_capacity(tier: int) -> int:
	return FUEL_CAPS[clampi(tier, 0, 3)]


static func fuel_remaining(structure: Object) -> int:
	ensure_state(structure)
	return maxi(0, int(structure.foundry_state.get(STATE_COAL_FUEL, 0)))


static func fuel_space(structure: Object) -> int:
	return maxi(0, fuel_capacity(structure.level) - fuel_remaining(structure))


static func has_runtime_fuel(structure: Object, economy: MaterialEconomy) -> bool:
	if coal_available(structure, economy) >= FUEL_PER_BATCH:
		return true
	if not active_recipe(structure).is_empty():
		return true
	return false


static func coal_available(structure: Object, economy: MaterialEconomy) -> int:
	return fuel_remaining(structure) + int(economy.raw.get(MaterialEconomy.COAL, 0))


static func make_empty_output() -> Dictionary:
	var output: Dictionary = {}
	for material_id: String in MaterialEconomy.REFINED_ORDER:
		output[material_id] = 0
	return output


static func ensure_state(structure: Object) -> void:
	if not structure.foundry_state is Dictionary or structure.foundry_state.is_empty():
		structure.foundry_state = {
			STATE_OUTPUT: make_empty_output(),
			STATE_QUEUE: [],
			STATE_ACTIVE_RECIPE: "",
			STATE_ACTIVE_REMAINING: 0.0,
			STATE_ACTIVE_DURATION: 0.0,
			STATE_COAL_FUEL: 0,
		}


static func output_dict(structure: Object) -> Dictionary:
	ensure_state(structure)
	return structure.foundry_state[STATE_OUTPUT]


static func output_total(structure: Object) -> int:
	var total := 0
	for amount: Variant in output_dict(structure).values():
		total += int(amount)
	return total


static func output_full(structure: Object) -> bool:
	return output_total(structure) >= output_limit(structure.level)


static func queue_size(structure: Object) -> int:
	ensure_state(structure)
	var state: Dictionary = structure.foundry_state
	return int(state[STATE_QUEUE].size()) + (0 if str(state[STATE_ACTIVE_RECIPE]).is_empty() else 1)


static func queue_full(structure: Object) -> bool:
	return queue_size(structure) >= queue_limit(structure.level)


static func active_recipe(structure: Object) -> String:
	ensure_state(structure)
	return str(structure.foundry_state[STATE_ACTIVE_RECIPE])


static func active_recipe_remaining(structure: Object) -> float:
	ensure_state(structure)
	return float(structure.foundry_state[STATE_ACTIVE_REMAINING])


static func active_progress(structure: Object) -> float:
	ensure_state(structure)
	var duration := float(structure.foundry_state[STATE_ACTIVE_DURATION])
	if duration <= 0.0 or active_recipe(structure).is_empty():
		return 0.0
	return clampf(1.0 - active_recipe_remaining(structure) / duration, 0.0, 1.0)


static func output_sale_value(structure: Object) -> int:
	return _processed_stock_value(output_dict(structure))


static func output_manifest(structure: Object) -> String:
	var output: Dictionary = output_dict(structure)
	return "Bronze %d Ag %d Au %d Steel %d Ti %d\nStone %d Reinforced %d\nCore %d Optic %d Explosive %d Cut %d" % [
		output[MaterialEconomy.BRONZE_INGOT], output[MaterialEconomy.SILVER_INGOT], output[MaterialEconomy.GOLD_INGOT],
		output[MaterialEconomy.STEEL_PLATE], output[MaterialEconomy.TITANIUM_PLATE], output[MaterialEconomy.STONE_BLOCK],
		output[MaterialEconomy.REINFORCED_BLOCK], output[MaterialEconomy.CRYSTAL_CORE], output[MaterialEconomy.OPTIC_CORE],
		output[MaterialEconomy.EXPLOSIVE_COMPOUND], output[MaterialEconomy.CUT_DIAMOND],
	]


static func can_queue_refinement(structure: Object, economy: MaterialEconomy, raw_id: String) -> bool:
	if structure.level < economy.recipe_required_tier(raw_id):
		return false
	var requirements: Dictionary = economy.recipe_requirements(raw_id)
	if requirements.is_empty():
		return false
	for material_id: String in requirements.keys():
		if material_available(structure, economy, material_id) < int(requirements[material_id]):
			return false
	return true


static func material_available(structure: Object, economy: MaterialEconomy, material_id: String) -> int:
	if material_id == MaterialEconomy.COAL:
		return coal_available(structure, economy)
	return int(economy.raw.get(material_id, 0))


static func consume_coal(structure: Object, economy: MaterialEconomy, amount: int) -> bool:
	if amount <= 0:
		return true
	if coal_available(structure, economy) < amount:
		return false
	var from_buffer := mini(fuel_remaining(structure), amount)
	var from_pack := amount - from_buffer
	ensure_state(structure)
	if from_buffer > 0:
		structure.foundry_state[STATE_COAL_FUEL] = fuel_remaining(structure) - from_buffer
	if from_pack > 0:
		economy.raw[MaterialEconomy.COAL] = int(economy.raw.get(MaterialEconomy.COAL, 0)) - from_pack
	return true


static func queue_refinement(structure: Object, economy: MaterialEconomy, raw_id: String) -> bool:
	if queue_full(structure) or output_full(structure) or not has_runtime_fuel(structure, economy) or not can_queue_refinement(structure, economy, raw_id):
		return false
	var requirements: Dictionary = economy.recipe_requirements(raw_id)
	for material_id: String in requirements.keys():
		var amount: int = int(requirements[material_id])
		if material_id == MaterialEconomy.COAL:
			if not consume_coal(structure, economy, amount):
				return false
		else:
			economy.raw[material_id] = int(economy.raw[material_id]) - amount
	ensure_state(structure)
	structure.foundry_state[STATE_QUEUE].append(raw_id)
	_start_next_refinement(structure, economy)
	return true


static func queue_all_available(structure: Object, economy: MaterialEconomy) -> int:
	var queued := 0
	while not queue_full(structure) and not output_full(structure):
		var raw_id := economy.next_recipe(structure.level)
		if raw_id.is_empty() or not queue_refinement(structure, economy, raw_id):
			break
		queued += 1
	return queued


static func tick(structure: Object, economy: MaterialEconomy, delta: float, operational: bool) -> Dictionary:
	var completed: Dictionary = {}
	if not operational or structure.level <= 0 or delta <= 0.0:
		return completed
	ensure_state(structure)
	if output_full(structure):
		return completed
	_start_next_refinement(structure, economy)
	var remaining_delta := delta
	while remaining_delta > 0.0 and not active_recipe(structure).is_empty():
		if output_full(structure):
			break
		var state: Dictionary = structure.foundry_state
		var elapsed := minf(remaining_delta, float(state[STATE_ACTIVE_REMAINING]))
		state[STATE_ACTIVE_REMAINING] = float(state[STATE_ACTIVE_REMAINING]) - elapsed
		remaining_delta -= elapsed
		if float(state[STATE_ACTIVE_REMAINING]) > 0.0001:
			break
		var recipe_id := active_recipe(structure)
		var output_id := economy.recipe_output(recipe_id)
		var output_amount := economy.recipe_output_amount(recipe_id, structure.level)
		if not output_id.is_empty():
			var output: Dictionary = state[STATE_OUTPUT]
			var projected := output_total(structure) + output_amount
			if projected > output_limit(structure.level):
				state[STATE_ACTIVE_REMAINING] = 0.0001
				break
			output[output_id] = int(output[output_id]) + output_amount
			completed[output_id] = int(completed.get(output_id, 0)) + output_amount
		state[STATE_ACTIVE_RECIPE] = ""
		state[STATE_ACTIVE_REMAINING] = 0.0
		state[STATE_ACTIVE_DURATION] = 0.0
		_start_next_refinement(structure, economy)
	return completed


static func upgrade(structure: Object, economy: MaterialEconomy) -> bool:
	if structure.level >= economy.foundry_tier or structure.level >= 3:
		return false
	var old_duration := batch_duration(structure.level)
	structure.level += 1
	var new_duration := batch_duration(structure.level)
	ensure_state(structure)
	var state: Dictionary = structure.foundry_state
	if not str(state[STATE_ACTIVE_RECIPE]).is_empty() and old_duration > 0.0:
		state[STATE_ACTIVE_REMAINING] = float(state[STATE_ACTIVE_REMAINING]) * new_duration / old_duration
		state[STATE_ACTIVE_DURATION] = new_duration
	return true


static func collect_output(structure: Object, economy: MaterialEconomy, max_units: int) -> Dictionary:
	var collected: Dictionary = {}
	var remaining := maxi(0, max_units)
	var output: Dictionary = output_dict(structure)
	for material_id: String in MaterialEconomy.REFINED_ORDER:
		if remaining <= 0:
			break
		var available := int(output.get(material_id, 0))
		var moved := mini(available, remaining)
		if moved <= 0:
			continue
		output[material_id] = available - moved
		economy.refined[material_id] = int(economy.refined[material_id]) + moved
		collected[material_id] = moved
		remaining -= moved
	return collected


static func sell_output(structure: Object) -> int:
	if structure.level < 2:
		return 0
	var payout := output_sale_value(structure)
	if payout <= 0:
		return 0
	var output: Dictionary = output_dict(structure)
	for material_id: String in MaterialEconomy.REFINED_ORDER:
		output[material_id] = 0
	return payout


static func serialize_state(structure: Object) -> Dictionary:
	ensure_state(structure)
	var state: Dictionary = structure.foundry_state
	return {
		STATE_OUTPUT: state[STATE_OUTPUT].duplicate(true),
		STATE_QUEUE: state[STATE_QUEUE].duplicate(),
		STATE_ACTIVE_RECIPE: state[STATE_ACTIVE_RECIPE],
		STATE_ACTIVE_REMAINING: state[STATE_ACTIVE_REMAINING],
		STATE_ACTIVE_DURATION: state[STATE_ACTIVE_DURATION],
		STATE_COAL_FUEL: fuel_remaining(structure),
	}


static func restore_state(structure: Object, saved_value: Variant, tier: int, economy: MaterialEconomy = null) -> void:
	structure.foundry_state = {
		STATE_OUTPUT: make_empty_output(),
		STATE_QUEUE: [],
		STATE_ACTIVE_RECIPE: "",
		STATE_ACTIVE_REMAINING: 0.0,
		STATE_ACTIVE_DURATION: 0.0,
		STATE_COAL_FUEL: 0,
	}
	if not saved_value is Dictionary:
		return
	var saved: Dictionary = saved_value
	var output: Dictionary = structure.foundry_state[STATE_OUTPUT]
	var saved_output: Dictionary = saved.get(STATE_OUTPUT, {})
	for material_id: String in MaterialEconomy.REFINED_ORDER:
		output[material_id] = maxi(0, int(saved_output.get(material_id, 0)))
	structure.foundry_state[STATE_QUEUE].clear()
	var recipe_checker := economy if economy != null else MaterialEconomy.new()
	for queued_value: Variant in saved.get(STATE_QUEUE, []):
		var queued_id := str(queued_value)
		if recipe_checker.recipe_output(queued_id).is_empty():
			continue
		if queue_size(structure) >= queue_limit(tier):
			break
		structure.foundry_state[STATE_QUEUE].append(queued_id)
	var recipe := str(saved.get(STATE_ACTIVE_RECIPE, ""))
	if recipe_checker.recipe_output(recipe).is_empty():
		recipe = ""
	structure.foundry_state[STATE_ACTIVE_RECIPE] = recipe
	var duration := maxf(0.0, float(saved.get(STATE_ACTIVE_DURATION, batch_duration(tier))))
	structure.foundry_state[STATE_ACTIVE_DURATION] = duration
	structure.foundry_state[STATE_ACTIVE_REMAINING] = clampf(float(saved.get(STATE_ACTIVE_REMAINING, duration)), 0.0, duration)
	if not recipe.is_empty() and duration <= 0.0:
		structure.foundry_state[STATE_ACTIVE_DURATION] = batch_duration(tier)
		structure.foundry_state[STATE_ACTIVE_REMAINING] = batch_duration(tier)
	structure.foundry_state[STATE_COAL_FUEL] = clampi(int(saved.get(STATE_COAL_FUEL, 0)), 0, fuel_capacity(tier))
	if economy != null:
		_start_next_refinement(structure, economy)


static func migrate_legacy_state(structure: Object, economy: MaterialEconomy) -> void:
	var has_legacy := economy.foundry_output_total() > 0 or economy.queue_size() > 0 or not economy.active_recipe.is_empty()
	if not has_legacy:
		return
	if output_total(structure) == 0 and queue_size(structure) == 0 and active_recipe(structure).is_empty():
		ensure_state(structure)
		var state: Dictionary = structure.foundry_state
		for material_id: String in MaterialEconomy.REFINED_ORDER:
			state[STATE_OUTPUT][material_id] = maxi(0, int(economy.foundry_output.get(material_id, 0)))
		state[STATE_QUEUE] = economy.foundry_queue.duplicate()
		state[STATE_ACTIVE_RECIPE] = economy.active_recipe
		state[STATE_ACTIVE_DURATION] = economy.active_recipe_duration
		state[STATE_ACTIVE_REMAINING] = economy.active_recipe_remaining
		if not str(state[STATE_ACTIVE_RECIPE]).is_empty() and float(state[STATE_ACTIVE_DURATION]) <= 0.0:
			state[STATE_ACTIVE_DURATION] = batch_duration(structure.level)
			state[STATE_ACTIVE_REMAINING] = batch_duration(structure.level)
		_start_next_refinement(structure, economy)
	economy.clear_legacy_foundry_production()


static func load_fuel_from_backpack(structure: Object, economy: MaterialEconomy, max_units: int = -1) -> int:
	var space := fuel_space(structure)
	if space <= 0:
		return 0
	var available := int(economy.raw.get(MaterialEconomy.COAL, 0))
	if available <= 0:
		return 0
	var limit := available if max_units < 0 else mini(available, maxi(0, max_units))
	var moved := mini(space, limit)
	if moved <= 0:
		return 0
	economy.raw[MaterialEconomy.COAL] = available - moved
	ensure_state(structure)
	structure.foundry_state[STATE_COAL_FUEL] = fuel_remaining(structure) + moved
	return moved


static func add_fuel(structure: Object, amount: int) -> int:
	if amount <= 0:
		return 0
	ensure_state(structure)
	var moved := mini(fuel_space(structure), amount)
	if moved <= 0:
		return 0
	structure.foundry_state[STATE_COAL_FUEL] = fuel_remaining(structure) + moved
	return moved


static func _reserve_batch_fuel(structure: Object, economy: MaterialEconomy) -> bool:
	return consume_coal(structure, economy, FUEL_PER_BATCH)


static func _start_next_refinement(structure: Object, economy: MaterialEconomy = null) -> void:
	ensure_state(structure)
	var state: Dictionary = structure.foundry_state
	if not str(state[STATE_ACTIVE_RECIPE]).is_empty() or state[STATE_QUEUE].is_empty() or structure.level <= 0:
		return
	if economy != null and not _reserve_batch_fuel(structure, economy):
		return
	state[STATE_ACTIVE_RECIPE] = state[STATE_QUEUE].pop_front()
	state[STATE_ACTIVE_DURATION] = batch_duration(structure.level)
	state[STATE_ACTIVE_REMAINING] = float(state[STATE_ACTIVE_DURATION])


static func _processed_stock_value(stock: Dictionary) -> int:
	var values := {
		MaterialEconomy.BRONZE_INGOT: 22, MaterialEconomy.SILVER_INGOT: 38, MaterialEconomy.GOLD_INGOT: 65,
		MaterialEconomy.CRYSTAL_CORE: 85, MaterialEconomy.CUT_DIAMOND: 150, MaterialEconomy.STONE_BLOCK: 12,
		MaterialEconomy.REINFORCED_BLOCK: 28, MaterialEconomy.STEEL_PLATE: 42, MaterialEconomy.TITANIUM_PLATE: 95,
		MaterialEconomy.EXPLOSIVE_COMPOUND: 58, MaterialEconomy.OPTIC_CORE: 72,
	}
	var value := 0
	for material_id: String in MaterialEconomy.REFINED_ORDER:
		value += int(stock.get(material_id, 0)) * int(values.get(material_id, 0))
	return value
