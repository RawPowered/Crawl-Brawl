class_name BaseNetwork
extends RefCounted

const COMMAND_ID := "command"
const NORTH_ID := "crystal"
const SOUTH_ID := "foundry"
const WEST_ID := "containment"

const STATUS_SITE := "site"
const STATUS_ACTIVATING := "activating"
const STATUS_ACTIVE := "active"
const STATUS_DISABLED := "disabled"

const FRONTIER_COST := 1000
const ACTIVATION_DURATION := 50.0

var bases: Dictionary = {}
var activation_base_id := ""


func configure(command_cell: Vector2i, width: int, height: int, seeded_sites: Dictionary = {}) -> void:
	bases = {
		COMMAND_ID: _record(COMMAND_ID, "COMMAND CORE", "command", command_cell, STATUS_ACTIVE, 100.0),
		NORTH_ID: _record(NORTH_ID, "CRYSTAL RESEARCH STATION", "research", Vector2i(49, 10), STATUS_SITE, 150.0),
		SOUTH_ID: _record(SOUTH_ID, "INDUSTRIAL FOUNDRY", "foundry", Vector2i(59, height - 10), STATUS_SITE, 150.0),
		WEST_ID: _record(WEST_ID, "HIVE CONTAINMENT POST", "containment", Vector2i(18, 10), STATUS_SITE, 150.0),
	}
	for base_id: String in [NORTH_ID, SOUTH_ID, WEST_ID]:
		if seeded_sites.has(base_id):
			bases[base_id]["cell"] = seeded_sites[base_id]
	# Keep authored sites valid if later world dimensions are tuned.
	for base_id: String in bases.keys():
		var record: Dictionary = bases[base_id]
		var cell: Vector2i = record["cell"]
		record["cell"] = Vector2i(clampi(cell.x, 2, width - 3), clampi(cell.y, 2, height - 3))


func _record(id: String, display_name: String, kind: String, cell: Vector2i, status: String, health: float) -> Dictionary:
	return {
		"id": id,
		"name": display_name,
		"kind": kind,
		"cell": cell,
		"status": status,
		"tier": 1,
		"health": health,
		"max_health": health,
		"activation_remaining": 0.0,
		"waves_survived": 0,
		"guardian_cleared": false,
		"revealed": id == COMMAND_ID,
		"specialty_level": 0,
	}


func get_base(base_id: String) -> Dictionary:
	return bases.get(base_id, {})


func get_status(base_id: String) -> String:
	return str(get_base(base_id).get("status", ""))


func get_cell(base_id: String) -> Vector2i:
	return get_base(base_id).get("cell", Vector2i.ZERO)


func active_ids(include_activating: bool = false) -> Array[String]:
	var result: Array[String] = []
	for base_id: String in bases.keys():
		var status: String = get_status(base_id)
		if status == STATUS_ACTIVE or (include_activating and status == STATUS_ACTIVATING):
			result.append(base_id)
	return result


func frontier_active_count() -> int:
	var count: int = 0
	for base_id: String in active_ids():
		if base_id != COMMAND_ID:
			count += 1
	return count


func nearest_interactable(world_position: Vector2, tile_size: int, maximum_distance: float = 54.0) -> String:
	var result: String = ""
	var closest: float = maximum_distance
	for base_id: String in bases.keys():
		if not bool(get_base(base_id).get("revealed", false)):
			continue
		var base_position: Vector2 = Vector2(get_cell(base_id) * tile_size) + Vector2.ONE * float(tile_size) * 0.5
		var distance: float = world_position.distance_to(base_position)
		if distance <= closest:
			closest = distance
			result = base_id
	return result


func nearest_active(cell: Vector2i, include_command: bool = true) -> String:
	var result: String = ""
	var closest: float = INF
	for base_id: String in active_ids():
		if not include_command and base_id == COMMAND_ID:
			continue
		var distance: float = cell.distance_squared_to(get_cell(base_id))
		if distance < closest:
			closest = distance
			result = base_id
	return result


func territory_radius(base_id: String) -> int:
	var tier: int = int(get_base(base_id).get("tier", 1))
	return [10, 13, 16][clampi(tier - 1, 0, 2)]


func owns_cell(base_id: String, cell: Vector2i) -> bool:
	return get_status(base_id) == STATUS_ACTIVE and get_cell(base_id).distance_to(cell) <= float(territory_radius(base_id))


func powered_base_for(cell: Vector2i) -> String:
	var result: String = ""
	var closest: float = INF
	for base_id: String in active_ids():
		if not owns_cell(base_id, cell):
			continue
		var distance: float = get_cell(base_id).distance_squared_to(cell)
		if distance < closest:
			closest = distance
			result = base_id
	return result


func has_operational_network() -> bool:
	return not active_ids(true).is_empty()


func sanitize_activation_state() -> void:
	if activation_base_id.is_empty():
		return
	if get_status(activation_base_id) != STATUS_ACTIVATING:
		activation_base_id = ""


func can_construct_open_world(base_id: String, surveyed_sectors: int, enemies_nearby: bool) -> bool:
	# Exploration + guardian clearance own frontier progression. Encounter history
	# is deliberately absent from this contract.
	return base_id != COMMAND_ID and get_status(base_id) == STATUS_SITE and surveyed_sectors >= 4 and bool(get_base(base_id).get("guardian_cleared", false)) and not enemies_nearby


func can_construct(base_id: String, wave: int, surveyed_sectors: int, enemies_nearby: bool) -> bool:
	# Schema/API compatibility wrapper. `wave` is historical metadata only.
	return can_construct_open_world(base_id, surveyed_sectors, enemies_nearby)


func mark_guardian_cleared(base_id: String) -> void:
	if bases.has(base_id):
		bases[base_id]["guardian_cleared"] = true


func begin_activation(base_id: String) -> bool:
	sanitize_activation_state()
	if base_id == COMMAND_ID or get_status(base_id) != STATUS_SITE or not activation_base_id.is_empty():
		return false
	bases[base_id]["status"] = STATUS_ACTIVATING
	bases[base_id]["activation_remaining"] = ACTIVATION_DURATION
	activation_base_id = base_id
	return true


func tick_activation(delta: float) -> String:
	if activation_base_id.is_empty() or get_status(activation_base_id) != STATUS_ACTIVATING:
		return ""
	var record: Dictionary = bases[activation_base_id]
	record["activation_remaining"] = maxf(0.0, float(record["activation_remaining"]) - delta)
	if float(record["activation_remaining"]) > 0.0:
		return ""
	var completed: String = activation_base_id
	record["status"] = STATUS_ACTIVE
	record["health"] = record["max_health"]
	activation_base_id = ""
	return completed


func damage(base_id: String, amount: float) -> String:
	if not bases.has(base_id):
		return ""
	var record: Dictionary = bases[base_id]
	if str(record["status"]) not in [STATUS_ACTIVE, STATUS_ACTIVATING]:
		return ""
	record["health"] = maxf(0.0, float(record["health"]) - amount)
	if float(record["health"]) > 0.0:
		return "damaged"
	record["status"] = STATUS_DISABLED
	record["activation_remaining"] = 0.0
	if activation_base_id == base_id:
		activation_base_id = ""
	return "disabled"


func repair(base_id: String) -> void:
	if bases.has(base_id):
		bases[base_id]["health"] = bases[base_id]["max_health"]


func reactivate(base_id: String) -> bool:
	if get_status(base_id) != STATUS_DISABLED:
		return false
	bases[base_id]["status"] = STATUS_ACTIVE
	bases[base_id]["health"] = float(bases[base_id]["max_health"]) * 0.65
	return true


func upgrade(base_id: String) -> bool:
	if get_status(base_id) != STATUS_ACTIVE or int(bases[base_id]["tier"]) >= 3:
		return false
	var next_tier: int = int(bases[base_id]["tier"]) + 1
	bases[base_id]["tier"] = next_tier
	bases[base_id]["max_health"] = [150.0, 225.0, 325.0][next_tier - 1] if base_id != COMMAND_ID else 100.0
	bases[base_id]["health"] = bases[base_id]["max_health"]
	return true


func choose_target(spawn_cell: Vector2i, sequence: int, difficulty_id: String) -> String:
	var candidates: Array[String] = active_ids(true)
	if candidates.is_empty():
		return COMMAND_ID
	if not activation_base_id.is_empty():
		return activation_base_id if sequence % 4 != 0 else COMMAND_ID
	if difficulty_id == "explorer" or candidates.size() == 1:
		return nearest_active(spawn_cell)
	# Deterministic distribution keeps target ownership stable and reproducible.
	if difficulty_id == "bastion" and frontier_active_count() < 2:
		return COMMAND_ID if sequence % 3 != 0 else nearest_active(spawn_cell)
	return candidates[posmod(sequence + spawn_cell.x + spawn_cell.y, candidates.size())]


func threat_multiplier() -> float:
	return 1.0 + float(frontier_active_count()) * 0.12


func serialize() -> Dictionary:
	var serialized: Dictionary = {}
	for base_id: String in bases.keys():
		var source: Dictionary = bases[base_id]
		var copy: Dictionary = source.duplicate(true)
		var cell: Vector2i = source["cell"]
		copy["cell"] = [cell.x, cell.y]
		serialized[base_id] = copy
	return {"bases": serialized, "activation_base_id": activation_base_id}


func restore(data: Dictionary) -> bool:
	var incoming: Dictionary = data.get("bases", {})
	if not incoming.has(COMMAND_ID):
		return false
	for base_id: String in incoming.keys():
		var source: Dictionary = incoming[base_id]
		var cell_data: Array = source.get("cell", [])
		if cell_data.size() != 2:
			return false
		var record: Dictionary = source.duplicate(true)
		record["cell"] = Vector2i(int(cell_data[0]), int(cell_data[1]))
		bases[base_id] = record
	activation_base_id = str(data.get("activation_base_id", ""))
	sanitize_activation_state()
	return true
