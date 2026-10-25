class_name PlayerArmor
extends RefCounted

const STRENGTH_BY_STYLE: Array[float] = [1.0, 1.06, 1.12, 1.20]
const DEFENSE_BY_STYLE: Array[float] = [1.0, 0.94, 0.88, 0.80]
const TIER_LABELS: Array[String] = ["BASELINE", "BRONZE", "SILVER", "DIAMOND"]


static func clamp_style(style_id: int) -> int:
	return clampi(style_id, 0, STRENGTH_BY_STYLE.size() - 1)


static func strength_multiplier(style_id: int) -> float:
	return STRENGTH_BY_STYLE[clamp_style(style_id)]


static func defense_multiplier(style_id: int) -> float:
	return DEFENSE_BY_STYLE[clamp_style(style_id)]


static func tier_label(style_id: int) -> String:
	return TIER_LABELS[clamp_style(style_id)]


static func strength_percent(style_id: int) -> int:
	return roundi((strength_multiplier(style_id) - 1.0) * 100.0)


static func defense_percent(style_id: int) -> int:
	return roundi((1.0 - defense_multiplier(style_id)) * 100.0)


static func stat_line(style_id: int) -> String:
	var strength_bonus := strength_percent(style_id)
	var defense_bonus := defense_percent(style_id)
	if strength_bonus <= 0 and defense_bonus <= 0:
		return "BASELINE STR // BASELINE DEF"
	return "+%d%% STR // -%d%% INCOMING DMG" % [strength_bonus, defense_bonus]


static func pause_line(style_id: int) -> String:
	return "ARMOR %s // STR x%.2f // DEF x%.2f" % [
		tier_label(style_id), strength_multiplier(style_id), defense_multiplier(style_id)]
