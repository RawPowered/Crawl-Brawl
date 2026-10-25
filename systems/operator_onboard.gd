class_name OperatorOnboard
extends RefCounted

## First-run crash prompts: orient inside the sealed landing pocket, breach, then survive contact.

const STEP_MOVE := 0
const STEP_MINE := 1
const STEP_FIRE := 2
const STEP_DONE := 3

const PROMPT_MOVE := "IMPACT COMPLETE // SEALED TUNNEL POCKET // WASD MOVE // MOUSE AIM"
const PROMPT_MINE := "CUTTER READY // BREACHING THE LANDING SEAL WILL DRAW CONTACT // LMB MINES"
const PROMPT_FIRE := "CONTACT // TAB CYCLES GUNS // LMB SHOOTS // HOLD THE POCKET"
const PROMPT_TORCH := "FIELD LANTERN KIT READY // SELECT SLOT // RMB PLACE // [I] PACK"

var step := STEP_MOVE
var torch_hint_pending := false


func is_done() -> bool:
	return step >= STEP_DONE


func force_done() -> void:
	step = STEP_DONE


func restore(saved_step: int, breached: bool, first_mine: bool) -> void:
	if saved_step < 0:
		step = STEP_DONE if (breached or first_mine) else STEP_MOVE
		return
	step = clampi(saved_step, STEP_MOVE, STEP_DONE)


func serialize() -> int:
	return step


func is_prompt(text: String) -> bool:
	return text == PROMPT_MOVE or text == PROMPT_MINE or text == PROMPT_FIRE


func prompt(wall_ahead: bool, hostile_near: bool) -> String:
	match step:
		STEP_MOVE:
			return PROMPT_MOVE
		STEP_MINE:
			return PROMPT_MINE if wall_ahead else ""
		STEP_FIRE:
			return PROMPT_FIRE if hostile_near else ""
	return ""


func advance(player_moved: bool, mined: bool, gun_fired: bool) -> bool:
	if step >= STEP_DONE:
		return false
	if step == STEP_MOVE and player_moved:
		step = STEP_MINE
	elif step == STEP_MINE and mined:
		step = STEP_FIRE
	elif step == STEP_FIRE and gun_fired:
		step = STEP_DONE
		return true
	return false


func consume_torch_hint() -> bool:
	if not torch_hint_pending:
		return false
	torch_hint_pending = false
	return true
