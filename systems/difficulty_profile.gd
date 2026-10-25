class_name DifficultyProfile
extends RefCounted

const DEFAULT_ID := "bastion"
const ORDER: Array[String] = ["explorer", "bastion", "onslaught", "extinction"]

const PRESETS := {
	"explorer": {
		"name": "EXPLORER",
		"description": "Larger swarms with generous recovery and slower attackers.",
		"wave_base": 8, # legacy curve only
		"mobs_per_wave": 4, # legacy curve only
		"contact_base": 8,
		"contact_growth": 2,
		"spawn_interval": 0.44,
		"minimum_spawn_interval": 0.30,
		"spawn_interval_decay": 0.008,
		"enemy_health": 0.85,
		"enemy_speed": 0.94,
		"enemy_damage": 0.75,
		"intermission": 8.5,
		"reward_multiplier": 1.15,
		"leaper_start": 3,
		"leaper_period": 5,
		"spitter_start": 4,
		"spitter_period": 8,
		"second_lane_wave": 5,
		"third_lane_wave": 10,
		"burst_size": 5,
		"burst_gap_multiplier": 1.8,
		"boss_bonus": 0,
		"recovery_health": 18.0,
		"recovery_ammo": 16,
	},
	"bastion": {
		"name": "BASTION",
		"description": "The intended defense rhythm with fast, sustained pressure.",
		"wave_base": 10, # legacy curve only
		"mobs_per_wave": 5, # legacy curve only
		"contact_base": 10,
		"contact_growth": 3,
		"spawn_interval": 0.34,
		"minimum_spawn_interval": 0.22,
		"spawn_interval_decay": 0.007,
		"enemy_health": 1.0,
		"enemy_speed": 1.0,
		"enemy_damage": 1.0,
		"intermission": 7.5,
		"reward_multiplier": 1.0,
		"leaper_start": 2,
		"leaper_period": 4,
		"spitter_start": 3,
		"spitter_period": 6,
		"second_lane_wave": 4,
		"third_lane_wave": 8,
		"burst_size": 6,
		"burst_gap_multiplier": 1.65,
		"boss_bonus": 0,
		"recovery_health": 12.0,
		"recovery_ammo": 14,
	},
	"onslaught": {
		"name": "ONSLAUGHT",
		"description": "Denser hunting parties, faster entry, and earlier specialist pressure.",
		"wave_base": 12, # legacy curve only
		"mobs_per_wave": 6, # legacy curve only
		"contact_base": 12,
		"contact_growth": 4,
		"spawn_interval": 0.25,
		"minimum_spawn_interval": 0.16,
		"spawn_interval_decay": 0.006,
		"enemy_health": 1.08,
		"enemy_speed": 1.06,
		"enemy_damage": 1.15,
		"intermission": 6.5,
		"reward_multiplier": 1.0,
		"leaper_start": 2,
		"leaper_period": 3,
		"spitter_start": 2,
		"spitter_period": 5,
		"second_lane_wave": 3,
		"third_lane_wave": 6,
		"burst_size": 7,
		"burst_gap_multiplier": 1.5,
		"boss_bonus": 0,
		"recovery_health": 8.0,
		"recovery_ammo": 12,
	},
	"extinction": {
		"name": "EXTINCTION",
		"description": "Relentless contact pressure for mastered builds and fast reactions.",
		"wave_base": 15, # legacy curve only
		"mobs_per_wave": 7, # legacy curve only
		"contact_base": 15,
		"contact_growth": 5,
		"spawn_interval": 0.18,
		"minimum_spawn_interval": 0.12,
		"spawn_interval_decay": 0.004,
		"enemy_health": 1.18,
		"enemy_speed": 1.12,
		"enemy_damage": 1.30,
		"intermission": 5.5,
		"reward_multiplier": 1.05,
		"leaper_start": 1,
		"leaper_period": 3,
		"spitter_start": 2,
		"spitter_period": 4,
		"second_lane_wave": 2,
		"third_lane_wave": 4,
		"burst_size": 8,
		"burst_gap_multiplier": 1.35,
		"boss_bonus": 1,
		"recovery_health": 5.0,
		"recovery_ammo": 10,
	},
}


static func normalize_id(requested_id: String) -> String:
	return requested_id if PRESETS.has(requested_id) else DEFAULT_ID


static func get_profile(requested_id: String) -> Dictionary:
	return PRESETS[normalize_id(requested_id)].duplicate(true)


static func next_id(current_id: String) -> String:
	var normalized := normalize_id(current_id)
	var current_index := ORDER.find(normalized)
	return ORDER[(current_index + 1) % ORDER.size()]


static func wave_spawn_count(requested_id: String, wave_number: int) -> int:
	var profile := get_profile(requested_id)
	return int(profile["wave_base"]) + maxi(1, wave_number) * int(profile["mobs_per_wave"])


static func encounter_spawn_count(requested_id: String, awareness_tier: int) -> int:
	var profile := get_profile(requested_id)
	var tier := clampi(awareness_tier, 0, 8)
	var per_tier := maxi(2, int(profile.get("contact_growth", 3)))
	return clampi(int(profile.get("contact_base", 10)) + tier * per_tier, 8, 12 + tier * 4)




static func encounter_spawn_interval(requested_id: String, awareness_tier: int) -> float:
	# Open-world contacts should arrive as readable hunting groups, not dump a
	# tower-defense wave into the room in one second. Awareness still tightens the
	# cadence, but the open-world baseline is intentionally slower than legacy waves.
	var profile := get_profile(requested_id)
	var tier := clampi(awareness_tier, 0, 8)
	var open_world_base := float(profile["spawn_interval"]) * 1.55
	var open_world_floor := float(profile["minimum_spawn_interval"]) * 1.75
	var reduction := float(tier) * float(profile["spawn_interval_decay"])
	return maxf(open_world_floor, open_world_base - reduction)

static func spawn_interval(requested_id: String, wave_number: int) -> float:
	var profile := get_profile(requested_id)
	var reduction := float(maxi(0, wave_number - 1)) * float(profile["spawn_interval_decay"])
	return maxf(float(profile["minimum_spawn_interval"]), float(profile["spawn_interval"]) - reduction)
