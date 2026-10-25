class_name MobLocomotion
extends RefCounted

# Smooth catch-up for distant mobs. Avoids the old hard 180/220px switch that felt random.
const CATCHUP_PLAYER_START := 120.0
const CATCHUP_PLAYER_RANGE := 120.0
const CATCHUP_CORE_START := 160.0
const CATCHUP_CORE_RANGE := 120.0
const CATCHUP_MAX_BONUS := 0.42
const CATCHUP_PRESSURE_BONUS := 0.010
const CATCHUP_PRESSURE_CAP := 0.28
const CATCHUP_WAVE_BONUS := CATCHUP_PRESSURE_BONUS # legacy alias
const CATCHUP_WAVE_CAP := CATCHUP_PRESSURE_CAP # legacy alias
const RECALL_SPEED_SCALE := 1.55
const CARRIER_TRAVEL_SCALE := 1.35

const SWARM_BASE := 24.0
const SPITTER_BASE := 21.0
const BRUTE_BASE := 18.0
const BROODLING_BASE := 42.0
const GUARDIAN_BASE := 13.0
const PRESSURE_SPEED_CAP := 14.0
const BRUTE_PRESSURE_SCALE := 0.4
const BROODLING_PRESSURE_SCALE := 1.2
const BROODLING_PRESSURE_CAP := 22.0
const GUARDIAN_PRESSURE_SCALE := 0.3
const GUARDIAN_PRESSURE_CAP := 6.0
# Legacy aliases for old tools/tests; live runtime uses the pressure names above.
const WAVE_SPEED_CAP := PRESSURE_SPEED_CAP
const BRUTE_WAVE_SCALE := BRUTE_PRESSURE_SCALE
const BROODLING_WAVE_SCALE := BROODLING_PRESSURE_SCALE
const BROODLING_WAVE_CAP := BROODLING_PRESSURE_CAP
const GUARDIAN_WAVE_SCALE := GUARDIAN_PRESSURE_SCALE
const GUARDIAN_WAVE_CAP := GUARDIAN_PRESSURE_CAP


static func swarm_speed_for_pressure(is_spitter: bool, pressure_level: int, difficulty_speed: float) -> float:
	var base := SPITTER_BASE if is_spitter else SWARM_BASE
	return (base + minf(float(maxi(1, pressure_level)) * 0.8, PRESSURE_SPEED_CAP)) * difficulty_speed


static func brute_speed_for_pressure(pressure_level: int, difficulty_speed: float) -> float:
	return (BRUTE_BASE + float(maxi(1, pressure_level)) * BRUTE_PRESSURE_SCALE) * difficulty_speed


static func broodling_speed_for_pressure(pressure_level: int, difficulty_speed: float) -> float:
	return (BROODLING_BASE + minf(float(maxi(1, pressure_level)) * BROODLING_PRESSURE_SCALE, BROODLING_PRESSURE_CAP)) * difficulty_speed


static func guardian_speed_for_pressure(pressure_level: int, difficulty_speed: float) -> float:
	return (GUARDIAN_BASE + minf(float(maxi(1, pressure_level)) * GUARDIAN_PRESSURE_SCALE, GUARDIAN_PRESSURE_CAP)) * difficulty_speed


static func travel_scale_for_pressure(player_distance: float, core_distance: float, pressure_level: int, is_carrier: bool) -> float:
	if is_carrier:
		return CARRIER_TRAVEL_SCALE
	var far_player := _smooth_step(CATCHUP_PLAYER_START, CATCHUP_PLAYER_START + CATCHUP_PLAYER_RANGE, player_distance)
	var far_core := _smooth_step(CATCHUP_CORE_START, CATCHUP_CORE_START + CATCHUP_CORE_RANGE, core_distance)
	var far_factor := far_player * far_core
	var pressure_bonus := minf(CATCHUP_PRESSURE_CAP, float(maxi(1, pressure_level)) * CATCHUP_PRESSURE_BONUS)
	return 1.0 + far_factor * (CATCHUP_MAX_BONUS + pressure_bonus)


static func swarm_speed(is_spitter: bool, wave: int, difficulty_speed: float) -> float:
	return swarm_speed_for_pressure(is_spitter, wave, difficulty_speed)


static func brute_speed(wave: int, difficulty_speed: float) -> float:
	return brute_speed_for_pressure(wave, difficulty_speed)


static func broodling_speed(wave: int, difficulty_speed: float) -> float:
	return broodling_speed_for_pressure(wave, difficulty_speed)


static func guardian_speed(wave: int, difficulty_speed: float) -> float:
	return guardian_speed_for_pressure(wave, difficulty_speed)


static func nest_defender_speed(brood_escalation: int, difficulty_speed: float) -> float:
	return (20.0 + minf(float(brood_escalation) * 1.5, 12.0)) * difficulty_speed


static func travel_scale(player_distance: float, core_distance: float, wave: int, cleanup_recalled: bool, is_carrier: bool) -> float:
	if cleanup_recalled:
		return RECALL_SPEED_SCALE
	return travel_scale_for_pressure(player_distance, core_distance, wave, is_carrier)


static func _smooth_step(edge0: float, edge1: float, x: float) -> float:
	var t := clampf((x - edge0) / maxf(0.001, edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
