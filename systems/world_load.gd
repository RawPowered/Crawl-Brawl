class_name WorldLoad
extends RefCounted

const WORLD_GRID := preload("res://systems/world_grid.gd")
const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")
const REALM_SAVE := preload("res://systems/realm_save.gd")

const WORLD_LOAD_BUDGET := 12
const EXTERIOR_HORIZON_CELLS := 100
const EXTERIOR_ENQUEUE_CAP := 1

const GENERAL_LORE_TIPS: Array[String] = [
	"COMMAND: LEADERSHIP IS GONE. I RUN WHAT'S LEFT OF THIS SHIP ALONE.",
	"FLEETS FAILED. ARMIES FAILED. NOW WE SEND ONE VOLUNTEER AT A TIME.",
	"YOUR JOB: CLEAR THE INFESTATION, MAP WHAT YOU CAN, HOLD A FOOTHOLD FOR EARTH.",
	"I DON'T HAVE A PLAYBOOK. THE LAST TEAMS DIDN'T EITHER. FIGURE IT OUT.",
	"THEY WENT DOWN BEFORE YOU. NONE OF THEM FINISHED THE JOB.",
	"DROP POD IS AIMED BELOW THE SURFACE. EXPECT A HARD LANDING IN HOSTILE CAVES.",
	"RUMOR: ONE PRIOR MADE IT FARTHER THAN ANYONE. COMMS DIED. WE ASSUME THEY'RE LOST.",
	"EARTH'S BEST ARE DEAD, QUIET, OR OUT OF OPTIONS. YOU SAID YES ANYWAY.",
	"FORTIFY BEFORE YOU PUSH. THE NEST DOES NOT STAY PASSIVE FOR LONG.",
	"PERSONAL BASE GIVES YOU RECOVERY // CHECKPOINT AT YOUR FIELD HUT",
	"SURVEY DEEP, BUILD SMART // HUMANITY NEEDS SOMETHING THAT LASTS DOWN THERE",
]

const TRAIT_LORE_TIPS: Dictionary = {
	"COPPER RICH": "COMMAND NOTE: METAL-RICH STRATA // PRIORITIZE NEAR-BUNKER MINING",
	"TIGHT PASSES": "COMMAND NOTE: TIGHT CAVES // SEAL FLANKS BEFORE YOU ADVANCE",
	"HEAVY INFESTATION": "COMMAND NOTE: DENSE NEST ACTIVITY // MOVE CAREFULLY",
	"ONSLAGHT INFESTATION": "COMMAND NOTE: DENSE NEST ACTIVITY // MOVE CAREFULLY",
	"EXTINCTION INFESTATION": "COMMAND NOTE: DENSE NEST ACTIVITY // MOVE CAREFULLY",
}

enum Phase { IDENTITY, SURVEY, CALIBRATION, HANDOFF, DONE }

var grid: WORLD_GRID
var mode := "new"
var run_seed := 0
var difficulty_id := ""
var phase := Phase.IDENTITY
var survey_index := 0
var calibration_index := 0
var calibration_total := 0
var save_data: Dictionary = {}
var save_valid := false
var save_error := ""
var tip_index := 0
var tip_timer := 0.0
var handoff_timer := 0.0
var minimum_hold_timer := 0.0
var progress_snapshot: Dictionary = {}
var corridor_cells: Array[Vector2i] = []


func _init(target_grid: WORLD_GRID = null) -> void:
	grid = target_grid


static func create_grid() -> WORLD_GRID:
	return WORLD_GRID.new(WORLD_GRID.REALM_WIDTH, WORLD_GRID.REALM_HEIGHT, WORLD_GRID.REALM_TILE_SIZE)


func begin(mode_id: String, seed_value: int, requested_difficulty: String, payload: Dictionary = {}) -> void:
	mode = mode_id
	run_seed = maxi(1, seed_value & 0x7fffffff)
	difficulty_id = DIFFICULTY_PROFILE.normalize_id(requested_difficulty)
	save_data = payload
	phase = Phase.IDENTITY
	survey_index = 0
	calibration_index = 0
	calibration_total = 0
	tip_index = int(run_seed % maxi(1, GENERAL_LORE_TIPS.size()))
	tip_timer = 0.0
	handoff_timer = 0.0
	minimum_hold_timer = 0.0
	save_valid = true
	save_error = ""
	corridor_cells.clear()
	if grid == null:
		grid = create_grid()
	if mode == "resume":
		_validate_resume_save()
	elif mode in ["new", "restart"]:
		grid.generate_realm(run_seed, difficulty_id)
		grid.configure_discoveries(run_seed, difficulty_id)
		progress_snapshot = _build_progress("identity", 0, 1, _primary_text_for_phase(Phase.IDENTITY))


func _validate_resume_save() -> void:
	save_valid = false
	if save_data.is_empty():
		save_error = "REALM SAVE MISSING // START NEW EXPEDITION"
		return
	var saved_generator := int(save_data.get("generator_version", 0))
	if saved_generator > 0 and saved_generator < WORLD_GRID.GENERATOR_VERSION:
		save_error = "REALM GENERATOR OUTDATED // START NEW EXPEDITION"
		return
	var saved_seed := int(save_data.get("run_seed", 0))
	var saved_realm_id := str(save_data.get("realm_id", ""))
	if saved_seed <= 0 or saved_realm_id != REALM_SAVE.realm_id_for_seed(saved_seed):
		save_error = "REALM IDENTITY MISMATCH // START NEW EXPEDITION"
		return
	if not bool(save_data.get("checkpoint_exists", true)):
		save_error = "NO CHECKPOINT // START NEW EXPEDITION"
		return
	run_seed = saved_seed
	difficulty_id = DIFFICULTY_PROFILE.normalize_id(str(save_data.get("difficulty_id", difficulty_id)))
	var saved_version := int(save_data.get("version", 0))
	grid.generate_realm(run_seed, difficulty_id, saved_version >= 8)
	grid.configure_discoveries(run_seed, difficulty_id)
	save_valid = true
	progress_snapshot = _build_progress("restore", 0, 1, "COMMAND // RESUMING YOUR EXPEDITION // STILL NO WORD FROM HOME")


func resume_terrain_from_save() -> void:
	if not save_valid:
		return
	var saved_spawn := _decode_cells(save_data.get("spawn_cells", []))
	var breach_cell := Vector2i(-1, -1)
	var saved_breach: Variant = save_data.get("first_breach_cell", [])
	if saved_breach is Array and saved_breach.size() == 2:
		breach_cell = Vector2i(int(saved_breach[0]), int(saved_breach[1]))
	var lane_count := maxi(1, int(save_data.get("active_lane_count", saved_spawn.size())))
	grid.prepare_resume_context(saved_spawn, breach_cell, lane_count)
	var saved_visited := _decode_cell_dictionary(save_data.get("visited_regions", save_data.get("loaded_regions", {})))
	grid.restore_visited_regions_for_load(saved_visited)
	var saved_cell_deltas: Variant = save_data.get("cell_deltas", {})
	if saved_cell_deltas is Dictionary:
		grid.restore_cell_deltas(_decode_cell_dictionary(saved_cell_deltas))
	grid.revealed_discoveries = _decode_cell_dictionary(save_data.get("revealed_discoveries", {}))
	grid.mined_minerals = _decode_cell_dictionary(save_data.get("mined_minerals", {}))
	corridor_cells = _resume_corridor_cells(saved_spawn)
	progress_snapshot = _build_progress(
		"restore",
		saved_visited.size(),
		maxi(1, saved_visited.size()),
		"RE-SYNCING YOUR SECTOR // COMMAND IS STILL LISTENING"
	)


func step(delta: float, skip_lore_tips: bool = false) -> Dictionary:
	if not save_valid and mode == "resume":
		progress_snapshot = {"phase": "error", "error": save_error, "done": true}
		return progress_snapshot
	minimum_hold_timer += delta
	match phase:
		Phase.IDENTITY:
			if mode == "resume":
				resume_terrain_from_save()
				phase = Phase.CALIBRATION
				calibration_total = maxi(1, corridor_cells.size())
				calibration_index = 0
				progress_snapshot = _build_progress("restore", 0, calibration_total, "COMMAND // PICKING UP WHERE YOU LEFT OFF")
			else:
				phase = Phase.SURVEY
				survey_index = 0
				progress_snapshot = _build_progress("survey", 0, grid.prepare_zone_region_list().size(), _primary_text_for_phase(Phase.SURVEY))
		Phase.SURVEY:
			survey_index = grid.bulk_materialize_prepare_zone(Callable(), WORLD_LOAD_BUDGET, survey_index)
			var total := grid.prepare_zone_region_list().size()
			var primary := _survey_primary_text(survey_index, total)
			progress_snapshot = _build_progress("survey", survey_index, total, primary)
			if grid.prepare_zone_bulk_is_complete(survey_index):
				phase = Phase.CALIBRATION
				calibration_total = _calibration_steps()
				calibration_index = 0
				progress_snapshot = _build_progress("calibration", 0, calibration_total, _primary_text_for_phase(Phase.CALIBRATION))
		Phase.CALIBRATION:
			if mode == "resume" and calibration_index == 0 and not corridor_cells.is_empty():
				grid.activate_corridor_preload_burst(corridor_cells, 2)
			calibration_index = mini(calibration_total, calibration_index + WORLD_LOAD_BUDGET)
			progress_snapshot = _build_progress(
				"calibration",
				calibration_index,
				maxi(1, calibration_total),
				_primary_text_for_phase(Phase.CALIBRATION)
			)
			if calibration_index >= calibration_total:
				phase = Phase.HANDOFF
				handoff_timer = 0.0
				progress_snapshot = _build_progress("handoff", 1, 1, _primary_text_for_phase(Phase.HANDOFF))
		Phase.HANDOFF:
			handoff_timer += delta
			var min_hold := 1.2 if mode == "new" else 0.6
			if handoff_timer >= 0.8 and minimum_hold_timer >= min_hold:
				phase = Phase.DONE
				progress_snapshot = _build_progress("done", 1, 1, _primary_text_for_phase(Phase.HANDOFF))
				progress_snapshot["done"] = true
		Phase.DONE:
			progress_snapshot["done"] = true
	if not skip_lore_tips:
		tip_timer += delta
		if tip_timer >= 4.5:
			tip_timer = 0.0
			tip_index = (tip_index + 1) % maxi(1, _lore_tip_pool().size())
	progress_snapshot["tip_text"] = _current_lore_tip()
	return progress_snapshot


func is_complete() -> bool:
	return phase == Phase.DONE


func build_handoff() -> Dictionary:
	return {
		"mode": mode,
		"run_seed": run_seed,
		"difficulty_id": difficulty_id,
		"realm_id": REALM_SAVE.realm_id_for_seed(run_seed),
		"grid": grid,
		"terrain_preloaded": true,
		"show_suit_alert": mode in ["new", "restart"],
		"save_data": save_data if mode == "resume" else {},
		"corridor_cells": corridor_cells,
	}


func _calibration_steps() -> int:
	if mode == "resume":
		return maxi(1, corridor_cells.size())
	return maxi(1, ceili(float(grid.prepare_zone_region_list().size()) / 8.0))


func _survey_primary_text(done: int, total: int) -> String:
	if done <= 1:
		return "COMMAND: POD AWAY // TRAJECTORY INTO THE NEST CAVITY"
	if done < int(float(total) * 0.65):
		return "COMMAND: OTHERS DIED HERE // MAP IT, CLEAR IT, HOLD GROUND"
	return "COMMAND: FOOTHOLD PROTOCOL ACTIVE // MAKE THIS RUN COUNT"


func _primary_text_for_phase(target_phase: Phase) -> String:
	match target_phase:
		Phase.IDENTITY:
			return "COMMAND: IT'S YOUR TURN // DEPLOY TO %s" % grid.realm_title
		Phase.SURVEY:
			return "COMMAND: SCANNING YOUR DROP ZONE // STAND BY FOR IMPACT"
		Phase.CALIBRATION:
			if mode == "resume":
				return "COMMAND: SUIT RE-LINK // BACK INTO THE NEST"
			return "COMMAND: SUIT ONLINE // I CAN'T HELP YOU FROM HERE"
		Phase.HANDOFF:
			if mode == "restart":
				return "COMMAND: BACK DOWN // %s // TRY AGAIN" % grid.realm_title
			if mode == "resume":
				return "COMMAND: LINK RESTORED // %s" % grid.realm_title
			return "COMMAND: IMPACT IN T-MINUS // GOOD LUCK — OUT"
	return ""


func _build_progress(phase_id: String, done: int, total: int, primary_text: String) -> Dictionary:
	return {
		"phase": phase_id,
		"done": done,
		"total": maxi(1, total),
		"primary_text": primary_text,
		"realm_title": grid.realm_title,
		"realm_traits": grid.realm_traits.duplicate(),
		"run_seed": run_seed,
		"generator_version": WORLD_GRID.GENERATOR_VERSION,
		"done_flag": false,
	}


func _lore_tip_pool() -> Array[String]:
	var pool: Array[String] = GENERAL_LORE_TIPS.duplicate()
	for trait_value: Variant in grid.realm_traits:
		var trait_text := str(trait_value)
		if TRAIT_LORE_TIPS.has(trait_text):
			pool.append(str(TRAIT_LORE_TIPS[trait_text]))
	return pool


func _current_lore_tip() -> String:
	var pool := _lore_tip_pool()
	if pool.is_empty():
		return "ONE VOLUNTEER // ONE CHANCE // EARTH IS WAITING"
	return pool[tip_index % pool.size()]


func _resume_corridor_cells(saved_spawn: Array) -> Array[Vector2i]:
	var cells: Array[Vector2i] = [grid.core_cell]
	if not saved_spawn.is_empty():
		for cell_value: Variant in saved_spawn:
			if cell_value is Vector2i:
				cells.append(cell_value)
			elif cell_value is Array and cell_value.size() == 2:
				cells.append(Vector2i(int(cell_value[0]), int(cell_value[1])))
	else:
		cells.append(grid.spawn_cell)
	var checkpoint: Variant = save_data.get("checkpoint_position", [])
	if checkpoint is Array and checkpoint.size() == 2:
		cells.append(grid.world_to_cell(Vector2(float(checkpoint[0]), float(checkpoint[1]))))
	return cells


func _decode_cells(raw: Variant) -> Array:
	var decoded: Array = []
	if raw is Array:
		for entry: Variant in raw:
			if entry is Vector2i:
				decoded.append(entry)
			elif entry is Array and entry.size() == 2:
				decoded.append(Vector2i(int(entry[0]), int(entry[1])))
	return decoded


func _decode_cell_dictionary(raw: Variant) -> Dictionary:
	var decoded: Dictionary = {}
	if raw is Dictionary:
		for key: Variant in raw.keys():
			if key is Vector2i:
				decoded[key] = raw[key]
			elif key is String:
				var parts: PackedStringArray = str(key).split(",")
				if parts.size() == 2:
					decoded[Vector2i(int(parts[0]), int(parts[1]))] = raw[key]
	return decoded
