class_name ProgressionTree
extends RefCounted

const UpgradeEconomyScript := preload("res://systems/upgrade_economy.gd")

const BRANCH_ARSENAL := "arsenal"
const BRANCH_BUNKER := "bunker"
const BRANCH_AUTOMATION := "automation"
const BRANCH_COMMAND := "command"

const BRANCH_ORDER: Array[String] = [BRANCH_ARSENAL, BRANCH_BUNKER, BRANCH_AUTOMATION, BRANCH_COMMAND]
const CATEGORY_MINING := "mining"

const BRANCH_LABELS: Dictionary = {
	BRANCH_ARSENAL: "ARSENAL",
	BRANCH_BUNKER: "BUNKER",
	BRANCH_AUTOMATION: "AUTOMATION",
	BRANCH_COMMAND: "COMMAND",
}

const PERMANENT_GATES: Dictionary = {
	BRANCH_ARSENAL: "overclock",
	BRANCH_AUTOMATION: "automation",
	CATEGORY_MINING: "excavation",
}

const NODES: Dictionary = {
	"overclock": {
		"branch": BRANCH_ARSENAL,
		"label": "OVERCLOCK ARSENAL",
		"detail": "Permanently boosts weapon damage and fire rate. Unlocks weapon engineering at ARMORY.",
		"sp_cost": 1,
		"level_req": 1,
		"requires": [],
		"action_slot": 0,
	},
	"fortify": {
		"branch": BRANCH_BUNKER,
		"label": "FORTIFY BUNKER",
		"detail": "Permanently strengthens defenses and restores Core and player health on unlock. No separate engineering gate; effects apply immediately.",
		"sp_cost": 1,
		"level_req": 2,
		"requires": [],
		"action_slot": 1,
	},
	"automation": {
		"branch": BRANCH_AUTOMATION,
		"label": "AUTOMATION",
		"detail": "Permanently increases sentry damage and firing rate. Unlocks Rocket and Laser fabrication at CONSTRUCTION. Rocket and Laser turret upgrades at DEFENSES require Automation; Sentry MK upgrades spend SP plus refined parts without Automation.",
		"sp_cost": 1,
		"level_req": 3,
		"requires": [],
		"action_slot": 2,
	},
	"excavation": {
		"branch": BRANCH_AUTOMATION,
		"label": "EXCAVATION RIG",
		"detail": "Permanently cuts rock 5% faster and unlocks mining-gun upgrades. Either MK2 track enables turret and wall relocation.",
		"sp_cost": 1,
		"level_req": 2,
		"requires": [],
		"action_slot": 3,
	},
	"personal_base": {
		"branch": BRANCH_COMMAND,
		"label": "PERSONAL BASE BLUEPRINT",
		"detail": "Unlocks Personal Base fabrication at the BASE tab. Craft the deployable kit with scrap and refined parts after unlocking.",
		"sp_cost": 1,
		"level_req": 5,
		"requires": ["fortify"],
		"action_slot": 4,
	},
}


static func node_ids() -> Array[String]:
	var ids: Array[String] = []
	for node_id: String in NODES.keys():
		ids.append(node_id)
	ids.sort()
	return ids


static func node(node_id: String) -> Dictionary:
	return NODES.get(node_id, {})


static func branch_label(branch_id: String) -> String:
	return str(BRANCH_LABELS.get(branch_id, branch_id.to_upper()))


static func nodes_for_branch(branch_id: String) -> Array[String]:
	var ids: Array[String] = []
	for node_id: String in progress_node_ids():
		if str(node(node_id).get("branch", "")) == branch_id:
			ids.append(node_id)
	return ids


static func node_for_action_slot(action_slot: int) -> String:
	for node_id: String in NODES.keys():
		if int(NODES[node_id].get("action_slot", -1)) == action_slot:
			return node_id
	return ""


static func progress_node_ids() -> Array[String]:
	var ids: Array[String] = []
	for node_id: String in NODES.keys():
		if int(NODES[node_id].get("action_slot", -1)) >= 0:
			ids.append(node_id)
	ids.sort_custom(func(a: String, b: String) -> bool:
		return action_slot(a) < action_slot(b)
	)
	return ids


static func max_level_requirement() -> int:
	var highest := 0
	for node_id: String in progress_node_ids():
		highest = maxi(highest, int(node(node_id).get("level_req", 1)))
	return highest


static func next_tree_node(skill_unlocks: Array) -> String:
	for node_id: String in progress_node_ids():
		if not is_unlocked(node_id, skill_unlocks):
			return node_id
	return ""


static func next_locked_node(expedition_level: int, skill_unlocks: Array) -> String:
	for node_id: String in progress_node_ids():
		if is_unlocked(node_id, skill_unlocks):
			continue
		if expedition_level < int(node(node_id).get("level_req", 1)):
			return node_id
		for required_id: String in node(node_id).get("requires", []):
			if not is_unlocked(required_id, skill_unlocks):
				return node_id
	return ""


static func unlock_button_label(node_id: String) -> String:
	var record: Dictionary = node(node_id)
	return "[LVL %d] [SP %d] %s" % [
		int(record.get("level_req", 1)),
		int(record.get("sp_cost", 1)),
		record.get("label", node_id),
	]


static func permanent_gate_node(category: String) -> String:
	return str(PERMANENT_GATES.get(category, ""))


static func permanent_upgrade_unlocked(category: String, skill_unlocks: Array) -> bool:
	var gate_id := permanent_gate_node(category)
	return gate_id.is_empty() or is_unlocked(gate_id, skill_unlocks)


static func permanent_gate_reason(category: String) -> String:
	var gate_id := permanent_gate_node(category)
	if gate_id.is_empty():
		return ""
	var record: Dictionary = node(gate_id)
	return "UNLOCK %s AT PROGRESS // LVL %d" % [str(record.get("label", gate_id)), int(record.get("level_req", 1))]


static func is_unlocked(node_id: String, skill_unlocks: Array) -> bool:
	return node_id in skill_unlocks


static func can_unlock(node_id: String, skill_unlocks: Array, skill_points: int, expedition_level: int) -> String:
	var record: Dictionary = node(node_id)
	if record.is_empty():
		return "UNKNOWN NODE"
	if is_unlocked(node_id, skill_unlocks):
		return "ALREADY UNLOCKED"
	if expedition_level < int(record.get("level_req", 1)):
		return "NEED EXPEDITION LEVEL %d" % int(record.get("level_req", 1))
	if skill_points < int(record.get("sp_cost", 1)):
		return "NEED %d SP" % int(record.get("sp_cost", 1))
	for required_id: String in record.get("requires", []):
		if not is_unlocked(required_id, skill_unlocks):
			return "REQUIRES %s" % str(node(required_id).get("label", required_id))
	return "READY"


static func sp_cost(node_id: String) -> int:
	return int(node(node_id).get("sp_cost", 0))


static func action_slot(node_id: String) -> int:
	return int(node(node_id).get("action_slot", -1))


static func frontier_core_upgrade_sp(current_tier: int) -> int:
	return UpgradeEconomyScript.frontier_core_upgrade_sp(current_tier)


static func personal_base_kit_scrap_cost() -> int:
	return 120


static func personal_base_upgrade_sp(current_tier: int) -> int:
	return UpgradeEconomyScript.personal_base_upgrade_sp(current_tier)


static func sentry_upgrade_sp(current_tier: int) -> int:
	return UpgradeEconomyScript.sentry_upgrade_sp(current_tier)


static func repair_unlock_order(unlocks: Array) -> Array[String]:
	var repaired: Array[String] = []
	for node_id: String in progress_node_ids():
		if node_id not in unlocks:
			continue
		var prereqs_ok := true
		for required_id: String in node(node_id).get("requires", []):
			if required_id not in repaired:
				prereqs_ok = false
				break
		if prereqs_ok:
			repaired.append(node_id)
	return repaired
