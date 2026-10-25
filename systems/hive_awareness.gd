class_name HiveAwareness
extends RefCounted

# Open-world encounter authority. Time may pace an already-authorized spawn,
# but it never creates threat or starts an encounter by itself.
const SAVE_VERSION := 2
const MAX_TIER := 8
# BV5.7: awareness is a long-horizon ecology signal, not an exploration stopwatch.
# Early tiers deliberately require several meaningful contacts so a new operator has
# time to mine, build and scout before the hive starts sustaining large responses.
const TIER_THRESHOLDS: Array[int] = [0, 8, 18, 32, 50, 72, 100, 132, 168]
const MIN_REGIONS_FOR_HUNTING_PARTY := 3
const EARLY_SCOUT_REGION_INTERVAL := 2
const LATE_SCOUT_REGION_INTERVAL := 1

const ACTIVITY_WEIGHTS := {
	# Passive travel/surveying no longer snowballs threat merely because the player
	# is exploring. The hive learns primarily from witnessed or destructive events.
	"first_breach": {"awareness": 1, "pressure": 0},
	"region": {"awareness": 0, "pressure": 0},
	"survey": {"awareness": 0, "pressure": 0},
	"scout_report": {"awareness": 2, "pressure": 3},
	"missing_scout": {"awareness": 2, "pressure": 3},
	"discovery": {"awareness": 1, "pressure": 0},
	"settlement": {"awareness": 3, "pressure": 2},
	"guardian": {"awareness": 2, "pressure": 1},
	"boss": {"awareness": 5, "pressure": 2},
}

const SCOUT_PROFILES := {
	0: {"name": "DUST STALKER", "role": 0},
	1: {"name": "BROOD RUNNER", "role": 1},
	2: {"name": "SIGNAL SCRAPER", "role": 3},
	3: {"name": "PRISM SKITTER", "role": 2},
	4: {"name": "EMBER COURIER", "role": 1},
	5: {"name": "GAS WHISPER", "role": 2},
	6: {"name": "MAGNET SEEKER", "role": 3},
}

var awareness_points := 0
var awareness_tier := 0
var exploration_pressure := 0
var encounter_pending := false
var surveyed_regions: Dictionary = {}
var alerted_regions: Dictionary = {}
var world_gate_progress: Dictionary = {}
var pending_scout_regions: Array[Vector2i] = []
var missing_scouts: Array[Dictionary] = []
var scout_in_flight := false
var last_scout_survey_count := 0
var encounter_cooldown_remaining := 0.0


func register_prepared_region(region: Vector2i, award_pressure: bool = true) -> Dictionary:
	if surveyed_regions.has(region):
		return {"accepted": false, "tier_changed": false, "encounter_pending": encounter_pending}
	surveyed_regions[region] = true
	alerted_regions[region] = maxi(1, int(alerted_regions.get(region, 0)))
	if not award_pressure:
		return {"accepted": true, "tier_changed": false, "encounter_pending": encounter_pending}
	# Only one scout investigation may be outstanding at a time. Early exploration
	# gets two new regions between scout contacts; mature hives investigate every
	# new region. This prevents crossing a few chunk boundaries from spawning a
	# conveyor belt of scouts and immediate hunting parties.
	var survey_count := surveyed_regions.size()
	var scout_interval := LATE_SCOUT_REGION_INTERVAL if awareness_tier >= 4 else EARLY_SCOUT_REGION_INTERVAL
	if (
		survey_count >= MIN_REGIONS_FOR_HUNTING_PARTY
		and not scout_in_flight
		and pending_scout_regions.is_empty()
		and missing_scouts.is_empty()
		and survey_count - last_scout_survey_count >= scout_interval
	):
		pending_scout_regions.append(region)
		last_scout_survey_count = survey_count
	return register_activity("region", region)


static func scout_profile(biome_id: int) -> Dictionary:
	return SCOUT_PROFILES.get(biome_id, SCOUT_PROFILES[0]).duplicate()


func peek_scout_request() -> Vector2i:
	return pending_scout_regions[0] if not pending_scout_regions.is_empty() else Vector2i(-2147483648, -2147483648)


func consume_scout_request(region: Vector2i) -> bool:
	var index := pending_scout_regions.find(region)
	if index < 0:
		return false
	pending_scout_regions.remove_at(index)
	scout_in_flight = true
	return true


func report_scout(region: Vector2i) -> Dictionary:
	scout_in_flight = false
	alerted_regions[region] = maxi(int(alerted_regions.get(region, 0)), awareness_tier + 2)
	return register_activity("scout_report", region)


func mark_scout_missing(region: Vector2i) -> void:
	scout_in_flight = false
	for record: Dictionary in missing_scouts:
		if record.get("region", Vector2i.ZERO) == region:
			return
	missing_scouts.append({
		"region": region,
		"remaining": maxf(18.0, 36.0 - float(awareness_tier) * 2.0),
	})


func tick_missing_scouts(delta: float) -> Array[Vector2i]:
	var escalated: Array[Vector2i] = []
	if delta <= 0.0:
		return escalated
	for record_index in range(missing_scouts.size() - 1, -1, -1):
		var record: Dictionary = missing_scouts[record_index]
		record["remaining"] = maxf(0.0, float(record.get("remaining", 0.0)) - delta)
		if float(record["remaining"]) > 0.0:
			continue
		var region: Vector2i = record.get("region", Vector2i.ZERO)
		register_activity("missing_scout", region)
		escalated.append(region)
		missing_scouts.remove_at(record_index)
	return escalated


func tick(delta: float) -> void:
	if delta <= 0.0:
		return
	encounter_cooldown_remaining = maxf(0.0, encounter_cooldown_remaining - delta)


func register_activity(activity: String, region: Vector2i = Vector2i.ZERO) -> Dictionary:
	var weights: Dictionary = ACTIVITY_WEIGHTS.get(activity, ACTIVITY_WEIGHTS["survey"])
	var previous_tier := awareness_tier
	awareness_points += maxi(0, int(weights.get("awareness", 0)))
	exploration_pressure += maxi(0, int(weights.get("pressure", 0)))
	awareness_tier = _tier_for_points(awareness_points)
	if activity != "survey" or alerted_regions.has(region):
		alerted_regions[region] = maxi(int(alerted_regions.get(region, 0)), awareness_tier + 1)
	if exploration_pressure >= encounter_threshold():
		encounter_pending = true
	return {
		"accepted": true,
		"tier_changed": awareness_tier != previous_tier,
		"encounter_pending": encounter_pending,
	}


func can_release_encounter(breached: bool, encounter_active: bool, streaming_pending: int, region_ready: bool) -> bool:
	return (
		breached
		and encounter_pending
		and not encounter_active
		and encounter_cooldown_remaining <= 0.0
		and surveyed_regions.size() >= MIN_REGIONS_FOR_HUNTING_PARTY
		and streaming_pending <= 0
		and region_ready
	)


func consume_encounter() -> bool:
	if not encounter_pending:
		return false
	exploration_pressure = maxi(0, exploration_pressure - encounter_threshold())
	encounter_pending = false
	# Cooldown only limits repeated responses; it never creates threat. A player may
	# keep exploring/building during recovery without an invisible clock spawning
	# enemies when the timer ends.
	encounter_cooldown_remaining = encounter_recovery_seconds()
	return true


func encounter_threshold() -> int:
	# Pressure must be accumulated by multiple meaningful events. One scout report
	# is information, not an automatic full hunting party.
	if awareness_tier >= 6:
		return 4
	if awareness_tier >= 3:
		return 5
	return 6


func encounter_recovery_seconds() -> float:
	if awareness_tier >= 6:
		return 38.0
	if awareness_tier >= 4:
		return 48.0
	if awareness_tier >= 2:
		return 58.0
	return 70.0


func encounter_party_size() -> int:
	# Early contacts are scouting/hunting groups, not miniature tower-defense waves.
	return clampi(4 + awareness_tier * 2, 4, 18)


func population_cap(active_bases: int, prepared_region_count: int, hard_cap: int) -> int:
	var cap := 20 + awareness_tier * 8
	cap += maxi(0, active_bases - 1) * 6
	cap += mini(10, maxi(0, prepared_region_count - 1))
	return clampi(cap, 20, hard_cap)


func regional_population_cap() -> int:
	return clampi(8 + awareness_tier * 3, 8, 32)


func threat_label() -> String:
	if encounter_pending:
		return "TRACKED"
	if awareness_tier >= 6:
		return "EXTREME"
	if awareness_tier >= 4:
		return "HIGH"
	if awareness_tier >= 2:
		return "ELEVATED"
	return "LOW"


func tier_label() -> String:
	const ROMAN: Array[String] = ["0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII"]
	return ROMAN[clampi(awareness_tier, 0, ROMAN.size() - 1)]


func mark_world_gate(boss_id: String) -> void:
	if boss_id.is_empty():
		return
	world_gate_progress[boss_id] = true
	register_activity("boss")


func serialize() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"awareness_points": awareness_points,
		"awareness_tier": awareness_tier,
		"exploration_pressure": exploration_pressure,
		"encounter_pending": encounter_pending,
		"surveyed_regions": _encode_regions(surveyed_regions),
		"alerted_regions": _encode_region_levels(alerted_regions),
		"world_gate_progress": world_gate_progress.duplicate(true),
		"pending_scout_regions": _encode_region_array(pending_scout_regions),
		"missing_scouts": _encode_missing_scouts(),
		"scout_in_flight": scout_in_flight,
		"last_scout_survey_count": last_scout_survey_count,
		"encounter_cooldown_remaining": encounter_cooldown_remaining,
	}


func restore(saved: Variant, legacy_wave: int = 0) -> void:
	awareness_points = maxi(0, legacy_wave * 2)
	awareness_tier = _tier_for_points(awareness_points)
	exploration_pressure = 0
	encounter_pending = false
	surveyed_regions.clear()
	alerted_regions.clear()
	world_gate_progress.clear()
	pending_scout_regions.clear()
	missing_scouts.clear()
	scout_in_flight = false
	last_scout_survey_count = 0
	encounter_cooldown_remaining = 0.0
	if not saved is Dictionary:
		return
	var data: Dictionary = saved
	awareness_points = maxi(0, int(data.get("awareness_points", awareness_points)))
	awareness_tier = _tier_for_points(awareness_points)
	exploration_pressure = maxi(0, int(data.get("exploration_pressure", 0)))
	encounter_pending = bool(data.get("encounter_pending", false))
	_decode_regions(data.get("surveyed_regions", []), surveyed_regions)
	_decode_region_levels(data.get("alerted_regions", []), alerted_regions)
	var saved_gate: Variant = data.get("world_gate_progress", {})
	if saved_gate is Dictionary:
		world_gate_progress = saved_gate.duplicate(true)
	_decode_region_array(data.get("pending_scout_regions", []), pending_scout_regions)
	_decode_missing_scouts(data.get("missing_scouts", []))
	scout_in_flight = bool(data.get("scout_in_flight", false))
	last_scout_survey_count = maxi(0, int(data.get("last_scout_survey_count", surveyed_regions.size())))
	encounter_cooldown_remaining = maxf(0.0, float(data.get("encounter_cooldown_remaining", 0.0)))


func _tier_for_points(points: int) -> int:
	var tier := 0
	for threshold_index in range(TIER_THRESHOLDS.size()):
		if points < TIER_THRESHOLDS[threshold_index]:
			break
		tier = threshold_index
	return clampi(tier, 0, MAX_TIER)


func _encode_regions(regions: Dictionary) -> Array:
	var encoded: Array = []
	for region_value: Variant in regions.keys():
		var region: Vector2i = region_value
		encoded.append([region.x, region.y])
	return encoded


func _encode_region_levels(regions: Dictionary) -> Array:
	var encoded: Array = []
	for region_value: Variant in regions.keys():
		var region: Vector2i = region_value
		encoded.append([region.x, region.y, int(regions[region])])
	return encoded


func _decode_regions(saved: Variant, target: Dictionary) -> void:
	if not saved is Array:
		return
	for pair_value: Variant in saved:
		if pair_value is Array and pair_value.size() >= 2:
			target[Vector2i(int(pair_value[0]), int(pair_value[1]))] = true


func _decode_region_levels(saved: Variant, target: Dictionary) -> void:
	if not saved is Array:
		return
	for record_value: Variant in saved:
		if record_value is Array and record_value.size() >= 3:
			target[Vector2i(int(record_value[0]), int(record_value[1]))] = maxi(0, int(record_value[2]))


func _encode_region_array(regions: Array[Vector2i]) -> Array:
	var encoded: Array = []
	for region: Vector2i in regions:
		encoded.append([region.x, region.y])
	return encoded


func _decode_region_array(saved: Variant, target: Array[Vector2i]) -> void:
	if not saved is Array:
		return
	for pair_value: Variant in saved:
		if pair_value is Array and pair_value.size() >= 2:
			target.append(Vector2i(int(pair_value[0]), int(pair_value[1])))


func _encode_missing_scouts() -> Array:
	var encoded: Array = []
	for record: Dictionary in missing_scouts:
		var region: Vector2i = record.get("region", Vector2i.ZERO)
		encoded.append([region.x, region.y, maxf(0.0, float(record.get("remaining", 0.0)))])
	return encoded


func _decode_missing_scouts(saved: Variant) -> void:
	if not saved is Array:
		return
	for record_value: Variant in saved:
		if record_value is Array and record_value.size() >= 3:
			missing_scouts.append({
				"region": Vector2i(int(record_value[0]), int(record_value[1])),
				"remaining": maxf(0.0, float(record_value[2])),
			})
