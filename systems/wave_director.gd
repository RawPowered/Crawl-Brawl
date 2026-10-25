class_name WaveDirector
extends RefCounted

const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")

const ROLE_SWARM := 0
const ROLE_LEAPER := 1
const ROLE_SPITTER := 2
const CONTINUOUS_PRESSURE_WAVE := 20


static func build_encounter_plan(difficulty_id: String, awareness_tier: int, brood_escalation: int, encounter_number: int, available_lanes: int = 3) -> Dictionary:
	# Open-world hunting parties are sized by current ecology pressure. The encounter
	# number is retained only as historical/debug metadata for save compatibility.
	var profile: Dictionary = DIFFICULTY_PROFILE.get_profile(difficulty_id)
	var tier: int = clampi(awareness_tier, 0, 8)
	var pressure: int = maxi(tier + 1, brood_escalation + 1)
	var lane_count := 1
	if tier >= 3:
		lane_count = 2
	if tier >= 6:
		lane_count = 3
	lane_count = mini(lane_count, maxi(1, available_lanes))

	# Bosses/guardians are world entities (guardian sites, brood bases, apex gates),
	# not periodic wave slots. Hunting parties therefore never create a boss solely
	# because N encounters have occurred.
	var boss_count := 0
	var spawn_count := DIFFICULTY_PROFILE.encounter_spawn_count(difficulty_id, tier)
	return {
		"wave": encounter_number, # legacy/debug field only
		"encounter": encounter_number,
		"pressure": pressure,
		"awareness_tier": tier,
		"phase": 1 + tier / 2,
		"title": encounter_title(tier, lane_count, boss_count),
		"spawn_count": spawn_count,
		"spawn_interval": DIFFICULTY_PROFILE.encounter_spawn_interval(difficulty_id, tier),
		"active_lanes": lane_count,
		"boss_count": boss_count,
		"burst_size": int(profile["burst_size"]) + mini(2, tier / 3),
		"burst_gap_multiplier": float(profile["burst_gap_multiplier"]),
		"broodling_pack": broodling_pack_size_for_tier(tier, difficulty_id),
		"broodling_period": maxi(4, 8 - tier / 2),
		"brood_carriers": brood_carrier_count_for_tier(tier, difficulty_id, encounter_number),
		"brood_carrier_slot": maxi(2, floori(float(spawn_count) * 0.34)),
	}


static func encounter_title(tier: int, lane_count: int, boss_count: int) -> String:
	if boss_count > 0:
		return "BREACH COMMAND" if boss_count == 1 else "BROOD COMMAND"
	if tier <= 1:
		return "FIRST CONTACT"
	if lane_count == 1:
		return "TUNNEL SURGE"
	if lane_count == 2:
		return "CROSSFIRE"
	if tier >= 6:
		return "THREE-FRONT SIEGE"
	return "PRECURSOR SWARM"


# Legacy wave-indexed helpers kept for static ecology curve tests only.
# Live encounters use build_encounter_plan() keyed to Hive Awareness tier.
# Deprecated: build_plan(), continuous_surge_gap() — do not call from runtime.


static func build_plan(difficulty_id: String, wave_number: int, available_lanes: int = 3) -> Dictionary:
	var profile: Dictionary = DIFFICULTY_PROFILE.get_profile(difficulty_id)
	var wave: int = maxi(1, wave_number)
	var lane_count := 1
	if wave >= int(profile["second_lane_wave"]):
		lane_count = 2
	if wave >= int(profile["third_lane_wave"]):
		lane_count = 3
	lane_count = mini(lane_count, maxi(1, available_lanes))

	var boss_count := 0
	if wave % 5 == 0:
		boss_count = mini(4, 1 + floori(float(wave - 5) / 10.0) + int(profile["boss_bonus"]))

	return {
		"wave": wave,
		"phase": 1 + floori(float(wave - 1) / 5.0),
		"title": wave_title(wave, lane_count, boss_count),
		"spawn_count": DIFFICULTY_PROFILE.wave_spawn_count(difficulty_id, wave),
		"spawn_interval": DIFFICULTY_PROFILE.spawn_interval(difficulty_id, wave),
		"active_lanes": lane_count,
		"boss_count": boss_count,
		"burst_size": int(profile["burst_size"]) + mini(3, floori(float(wave - 1) / 7.0)),
		"burst_gap_multiplier": float(profile["burst_gap_multiplier"]),
		"broodling_pack": broodling_pack_size(wave, difficulty_id),
		"broodling_period": maxi(3, 7 - floori(float(wave - 1) / 6.0)),
		"brood_carriers": brood_carrier_count(wave, difficulty_id),
		"brood_carrier_slot": maxi(2, floori(float(DIFFICULTY_PROFILE.wave_spawn_count(difficulty_id, wave)) * 0.34)),
	}


static func broodling_pack_size_for_tier(tier: int, difficulty_id: String) -> int:
	if tier < 3:
		return 0
	if difficulty_id == "extinction":
		return mini(4, 1 + tier / 2)
	if difficulty_id == "onslaught":
		return mini(3, 1 + tier / 3)
	return mini(3, tier / 3)


static func brood_carrier_count_for_tier(tier: int, difficulty_id: String, encounter_number: int) -> int:
	# Carrier eligibility follows ecology pressure, not every Nth encounter. Runtime
	# admission still prevents duplicate active carriers and respects nest caps.
	var first_tier := 4
	if difficulty_id == "onslaught":
		first_tier = 3
	elif difficulty_id == "extinction":
		first_tier = 2
	return 1 if tier >= first_tier else 0


static func wave_title(wave: int, lane_count: int, boss_count: int) -> String:
	if boss_count > 0:
		return "BREACH COMMAND" if boss_count == 1 else "BROOD COMMAND"
	if wave <= 2:
		return "FIRST CONTACT"
	if lane_count == 1:
		return "TUNNEL SURGE"
	if lane_count == 2:
		return "CROSSFIRE"
	if wave % 5 == 4:
		return "PRECURSOR SWARM"
	return "THREE-FRONT SIEGE"


static func role_for_pressure(difficulty_id: String, pressure_level: int, sequence: int) -> int:
	var profile: Dictionary = DIFFICULTY_PROFILE.get_profile(difficulty_id)
	var pressure := maxi(1, pressure_level)
	var spitter_period := maxi(2, int(profile["spitter_period"]) - floori(float(pressure - 1) / 10.0))
	var leaper_period := maxi(2, int(profile["leaper_period"]) - floori(float(pressure - 1) / 12.0))
	if pressure >= int(profile["spitter_start"]) and sequence % spitter_period == spitter_period - 1:
		return ROLE_SPITTER
	if pressure >= int(profile["leaper_start"]) and sequence % leaper_period == leaper_period - 1:
		return ROLE_LEAPER
	return ROLE_SWARM


static func role_for_spawn(difficulty_id: String, wave: int, sequence: int) -> int:
	# Legacy compatibility wrapper; live runtime calls role_for_pressure().
	return role_for_pressure(difficulty_id, wave, sequence)


static func spawn_delay(plan: Dictionary, sequence: int) -> float:
	var delay := float(plan.get("spawn_interval", 0.34))
	var burst_size := maxi(2, int(plan.get("burst_size", 4)))
	if sequence > 0 and sequence % burst_size == 0:
		delay *= float(plan.get("burst_gap_multiplier", 1.35))
	return delay


static func is_boss_slot(plan: Dictionary, sequence: int, bosses_remaining: int) -> bool:
	if bosses_remaining <= 0:
		return false
	var total := maxi(1, int(plan["spawn_count"]))
	var boss_total := maxi(1, int(plan["boss_count"]))
	var spacing := maxi(1, floori(float(total) / float(boss_total)))
	return sequence == 0 or sequence % spacing == 0 or total - sequence <= bosses_remaining


static func enemy_health_for_pressure(pressure_level: int) -> float:
	var pressure := maxi(1, pressure_level)
	return 1.0 + float(maxi(0, pressure - 5)) * 0.035 + float(maxi(0, pressure - 12)) * 0.025


static func enemy_damage_for_pressure(pressure_level: int) -> float:
	var pressure := maxi(1, pressure_level)
	return 1.0 + float(maxi(0, pressure - 8)) * 0.018


static func enemy_health_pressure(wave: int) -> float:
	# Legacy compatibility wrapper; the numeric input is interpreted as pressure.
	return enemy_health_for_pressure(wave)


static func enemy_damage_pressure(wave: int) -> float:
	# Legacy compatibility wrapper; the numeric input is interpreted as pressure.
	return enemy_damage_for_pressure(wave)


static func broodling_pack_size(wave: int, difficulty_id: String) -> int:
	var start_wave := 8
	if difficulty_id == "onslaught":
		start_wave = 6
	elif difficulty_id == "extinction":
		start_wave = 4
	if wave < start_wave:
		return 0
	return mini(6, 2 + floori(float(wave - start_wave) / 5.0))


static func brood_carrier_count(wave: int, difficulty_id: String) -> int:
	var first_carrier_wave := 6
	var period := 3
	if difficulty_id == "onslaught":
		first_carrier_wave = 5
		period = 3
	elif difficulty_id == "extinction":
		first_carrier_wave = 4
		period = 2
	if wave < first_carrier_wave:
		return 0
	return 1 if (wave - first_carrier_wave) % period == 0 else 0


static func should_offer_upgrade(wave: int) -> bool:
	if wave <= 5:
		return true
	if wave <= 14:
		return wave % 2 == 0
	return wave % 3 == 0


# Deprecated: open-world pacing no longer uses inter-wave surge timers.
static func uses_continuous_pressure(wave: int) -> bool:
	return wave >= CONTINUOUS_PRESSURE_WAVE


static func continuous_surge_gap(difficulty_id: String, wave: int) -> float:
	var base_gap := 16.0
	if difficulty_id == "onslaught":
		base_gap = 13.0
	elif difficulty_id == "extinction":
		base_gap = 10.0
	return maxf(8.0, base_gap - float(maxi(0, wave - CONTINUOUS_PRESSURE_WAVE)) * 0.05)
