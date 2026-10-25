class_name CrawlBrawlRun
extends Node2D

signal exit_to_menu
signal restart_requested

const WorldGridScript := preload("res://systems/world_grid.gd")
const WorldAddressScript := preload("res://systems/world_address.gd")
const RuinedFortressScript := preload("res://systems/ruined_fortress.gd")
const FlowFieldScript := preload("res://systems/flow_field.gd")
const RenderLayerScript := preload("res://scripts/render_layer.gd")
const DIFFICULTY_PROFILE := preload("res://systems/difficulty_profile.gd")
const WaveDirectorScript := preload("res://systems/wave_director.gd")
const HiveAwarenessScript := preload("res://systems/hive_awareness.gd")
const BaseNetworkScript := preload("res://systems/base_network.gd")
const MaterialEconomyScript := preload("res://systems/material_economy.gd")
const BiomeWallEconomyScript := preload("res://systems/biome_wall_economy.gd")
const FoundryUnitScript := preload("res://systems/foundry_unit.gd")
const ShelterUnitScript := preload("res://systems/shelter_unit.gd")
const SettlementProgressionScript := preload("res://systems/settlement_progression.gd")
const RealmSaveScript := preload("res://systems/realm_save.gd")
const RealmVisualStyleScript := preload("res://systems/realm_visual_style.gd")
const DisplaySettingsScript := preload("res://systems/display_settings.gd")
const TEXTURE_LOADER := preload("res://systems/texture_loader.gd")
const ProgressionTreeScript := preload("res://systems/progression_tree.gd")
const UpgradeEconomyScript := preload("res://systems/upgrade_economy.gd")
const PlayerArmorScript := preload("res://systems/player_armor.gd")
const ScrapEconomyScript := preload("res://systems/scrap_economy.gd")
const MobLocomotionScript := preload("res://systems/mob_locomotion.gd")
const CombatSpatialScript := preload("res://systems/combat_spatial.gd")
const CombatVfxScript := preload("res://systems/combat_vfx.gd")
const BiomeBestiaryScript := preload("res://systems/biome_bestiary.gd")
const EnemyProjectileEffectsScript := preload("res://systems/enemy_projectile_effects.gd")
const OperatorLoadoutScript := preload("res://systems/operator_loadout.gd")
const OperatorOnboardScript := preload("res://systems/operator_onboard.gd")
const PlaceableBlocksScript := preload("res://systems/placeable_blocks.gd")
const GameplayTelemetryScript := preload("res://systems/gameplay_telemetry.gd")
const RunWorldPresentationScript := preload("res://systems/run_components/run_world_presentation.gd")
const RunActorPresentationScript := preload("res://systems/run_components/run_actor_presentation.gd")
const RunHudPresentationScript := preload("res://systems/run_components/run_hud_presentation.gd")
const CURSOR_TEXTURE_PATH := "res://assets/art/ui/cursor_pointer.svg"
const CAVE_TEXTURE_PATH := "res://assets/art/cave_material_runtime.png"
const HIVE_MATERIAL_PATH := "res://assets/art/environment/hive_material_base_phase1.png"
const TUNNEL_MATERIAL_PATH := "res://assets/art/environment/tunnel_material_base_phase1.png"
const BUNKER_MATERIAL_PATH := "res://assets/art/environment/bunker_material_base_phase1.png"
const CRYSTAL_MATERIAL_PATH := "res://assets/art/environment/crystal_material_base_phase1.png"
const FOUNDRY_MATERIAL_PATH := "res://assets/art/environment/foundry_material_base_phase1.png"
const SULFUR_MATERIAL_PATH := "res://assets/art/environment/sulfur_material_base_phase1.png"
const IRON_MATERIAL_PATH := "res://assets/art/environment/iron_material_base_phase1.png"
const BIOME_MATERIAL_PATHS := {
	"crystal": CRYSTAL_MATERIAL_PATH,
	"foundry": FOUNDRY_MATERIAL_PATH,
	"sulfur": SULFUR_MATERIAL_PATH,
	"iron": IRON_MATERIAL_PATH,
}
const FORMATION_MATERIAL_PATHS := {
	0: "res://assets/art/environment/tunnel_material_formation_phase2.png",
	1: "res://assets/art/environment/hive_material_formation_phase2.png",
	2: "res://assets/art/environment/bunker_material_formation_phase2.png",
	3: "res://assets/art/environment/crystal_material_formation_phase2.png",
	4: "res://assets/art/environment/foundry_material_formation_phase2.png",
	5: "res://assets/art/environment/sulfur_material_formation_phase2.png",
	6: "res://assets/art/environment/iron_material_formation_phase2.png",
}
const MATERIAL_MACRO_CELLS := 2
# The generated 320px terrain atlases contain a 10x10 bank of 32px source
# macros. Each macro is split into four 16px source quadrants which map to a
# 2x2 block of 16px world cells. Keep source and destination sizes separate:
# using the world size as the source size was quartering the authored art.
const MATERIAL_MACRO_SIZE := 32
const MATERIAL_SUBPATCH_SIZE := 16
const CAVE_MACRO_SIZE := 32
const CAVE_ATLAS_COLUMNS := 4
const CAVE_ATLAS_ROWS := 4
const VISUAL_BOUNDARY_DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const CORE_PANEL_SIZE := Vector2(624, 360)
const CORE_TERMINAL_FRAME_PATH := "res://assets/art/ui/core_terminal_frame.png"
const OVERLAY_COMMAND_FRAME_PATH := "res://assets/art/ui/overlay_command_frame.png"

const VIEW_SIZE := Vector2(640, 360)
const PLAYER_SPEED := 82.0
const PLAYER_BODY_RADIUS := 5.0
const BULLET_SPEED := 360.0
const BUILD_BARRICADE := 0
const BUILD_SENTRY := 1
const BUILD_GRANITE_BARRIER := 2
const BUILD_REINFORCED_BARRIER := 3
const BUILD_BLAST_BARRIER := 4
const BUILD_LAND_MINE := 5
const BUILD_ROCKET_TURRET := 6
const BUILD_LASER_TURRET := 7
const BUILD_STEEL_BARRIER := 8
const BUILD_CHEST_SMALL := 9
const BUILD_CHEST_MEDIUM := 10
const BUILD_CHEST_LARGE := 11
const BUILD_HEAVY_DOORWAY := 12
const BUILD_FOUNDRY := 13
const BUILD_PERSONAL_BASE := 14
const BUILD_TORCH := 15
const BUILD_MERCHANT_STORE := 16
const WEAPON_PISTOL := 0
const WEAPON_SHOTGUN := 1
const WEAPON_LASER := 2
const WEAPON_SMG := 3
const WEAPON_RAILGUN := 4
const WEAPON_FLAMETHROWER := 5
const WEAPON_COUNT := 6
const SHOP_PAGES: Array[String] = ["armory", "supplies", "mining", "construction", "defenses", "materials", "storage", "base", "progress", "style"]
const SHOP_PAGE_LABELS := {
	"armory": "WEAPONS",
	"supplies": "SUPPLIES",
	"mining": "MINING",
	"construction": "BUILD",
	"defenses": "DEFENSE",
	"materials": "MATERIALS",
	"storage": "STORAGE",
	"base": "CORE",
	"progress": "SKILLS",
	"style": "SUIT",
}
const SHOP_DEPARTMENTS := {
	"gear": ["armory", "supplies", "mining"],
	"fortify": ["construction", "defenses"],
	"industry": ["materials", "storage"],
	"command": ["base", "progress"],
	"operator": ["style"],
}
const SHOP_DEPARTMENT_LABELS := {
	"gear": "GEAR",
	"fortify": "BUILD",
	"industry": "INDUSTRY",
	"command": "CORE",
	"operator": "SUIT",
}
const SHOP_DEPARTMENT_ORDER: Array[String] = ["gear", "fortify", "industry", "command", "operator"]
const EXPEDITION_XP_BASE := 22
const EXPEDITION_XP_THRESHOLD_TOPUP := 58
const MINING_CYCLE_DURATIONS: Array[float] = [0.0, 0.42, 0.34, 0.27, 0.21, 0.17]
const MINING_BEAM_REACHES: Array[float] = [0.0, 28.0, 36.0, 45.0, 56.0, 68.0]
const MINING_BEAM_WIDTHS: Array[float] = [0.0, 6.0, 7.5, 9.0, 11.0, 13.0]
const BACKPACK_CAPACITIES: Array[int] = [0, 80, 120, 180, 260]
const BACKPACK_COSTS: Array[int] = [0, 700, 2200, 6000]
# Max ammo each weapon's reserve can hold (independent of backpack)
const AMMO_RESERVE_CAPS: Array[int] = [600, 150, 999, 1200, 60]  # pistol, shotgun, laser(n/a), smg, rail
const TORCH_STOCK_ID := "torch"
const PERSONAL_BASE_ANCHOR_PREFIX := "hut:"
const TORCH_PURCHASE_COST := 30
const TORCH_DEPLOYMENT_CAP := 99 ## Soft legacy constant; field deploy uncapped (inventory stacks gate).
const TORCH_LIGHT_POOL_BUDGET := 16
const HOTBAR_SIZE := 9
const TORCH_VISION_RADII: Array[float] = [0.0, 46.0, 68.0, 92.0]
const TORCH_DURABILITY: Array[float] = [0.0, 60.0, 140.0, 260.0]
const TORCH_ALERT_INTERVAL := 2.25
const TORCH_SABOTAGE_RANGE := 92.0
const TORCH_LANTERN_REQUIREMENTS := [
	{},
	{MaterialEconomyScript.BRONZE_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1},
	{MaterialEconomyScript.OPTIC_CORE: 1, MaterialEconomyScript.CUT_DIAMOND: 1},
]
const TORCH_LANTERN_COSTS: Array[int] = [0, 90, 240]
const TORCH_COLOR_NAMES: Array[String] = ["AMBER", "CYAN", "VIOLET"]
const FLAMETHROWER_UNLOCK_REQUIREMENTS := {MaterialEconomyScript.STEEL_PLATE: 1, MaterialEconomyScript.EXPLOSIVE_COMPOUND: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
const FLAMETHROWER_FUEL_CAP := 180
const FLAMETHROWER_FUEL_BUNDLE := 60
const FLAMETHROWER_FUEL_BUNDLE_COST := 24
const FOUNDRY_FUEL_BUNDLE := 12
const FOUNDRY_FUEL_BUNDLE_COST := 20
const FLAMETHROWER_DIRECT_RANGE := 58.0
const FLAMETHROWER_CONE_HALF_ANGLE := 0.58
const FLAMETHROWER_PATCH_CAP := 6
const BUILD_STOCK_KEYS := {
	BUILD_GRANITE_BARRIER: "granite_barrier",
	BUILD_REINFORCED_BARRIER: "reinforced_barrier",
	BUILD_BLAST_BARRIER: "blast_barrier",
	BUILD_LAND_MINE: "land_mine",
	BUILD_ROCKET_TURRET: "rocket_turret",
	BUILD_LASER_TURRET: "laser_turret",
	BUILD_STEEL_BARRIER: "steel_barrier",
	BUILD_CHEST_SMALL: "chest_small",
	BUILD_CHEST_MEDIUM: "chest_medium",
	BUILD_CHEST_LARGE: "chest_large",
	BUILD_HEAVY_DOORWAY: "heavy_doorway",
	BUILD_PERSONAL_BASE: "personal_base",
	BUILD_FOUNDRY: "foundry",
	BUILD_TORCH: TORCH_STOCK_ID,
	BUILD_MERCHANT_STORE: SettlementProgressionScript.MERCHANT_STORE_STOCK_ID,
}
const DEPLOYABLE_WEIGHTS := {
	"granite_barrier": 3, "steel_barrier": 4, "reinforced_barrier": 4, "blast_barrier": 5,
	"land_mine": 2, "rocket_turret": 8, "laser_turret": 10,
	"chest_small": 4, "chest_medium": 8, "chest_large": 12,
	"heavy_doorway": 15,
	"personal_base": 12,
	"foundry": 14,
	TORCH_STOCK_ID: 1,
	SettlementProgressionScript.MERCHANT_STORE_STOCK_ID: 18,
}
const FOUNDRY_KIT_STOCK_CAP := 5
const CONSTRUCTION_ORDER: Array[String] = ["heavy_doorway", "granite_barrier", "steel_barrier", "reinforced_barrier", "blast_barrier", "land_mine", "rocket_turret", "laser_turret"]
const STORAGE_ORDER: Array[String] = ["chest_small", "chest_medium", "chest_large"]
const DEPLOYABLE_STORAGE_ORDER: Array[String] = [
	"granite_barrier", "steel_barrier", "reinforced_barrier", "blast_barrier",
	"land_mine", "rocket_turret", "laser_turret", "chest_small", "chest_medium", "chest_large",
]
const PLAYER_STYLE_NAMES: Array[String] = ["SURVEY SUIT", "FOUNDRY SUIT", "CONTAINMENT SUIT", "FRONTIER VETERAN"]
const PLAYER_STYLE_SLUGS: Array[String] = ["survey", "foundry", "containment", "veteran"]
const PLAYER_DIRECTION_NAMES: Array[String] = ["down", "right", "up", "left"]
const PLAYER_STYLE_PATHS: Array[String] = [
	"res://assets/art/player/survey.png",
	"res://assets/art/player/foundry.png",
	"res://assets/art/player/containment.png",
	"res://assets/art/player/veteran.png",
]
const SHOP_ICON_NAMES: Array[String] = [
	"pistol", "shotgun", "laser", "smg", "railgun", "flamethrower", "ammo_box", "pistol_ammo", "shotgun_ammo",
	"laser_battery", "smg_mag", "rail_slug", "medkit", "sentry", "turret_chip", "repair", "barricade",
	"command_core", "frontier_core", "copper_ore", "silver_ore", "gold_ore", "energy_crystal",
	"rough_diamond", "bronze_ingot", "silver_ingot", "gold_ingot", "crystal_core", "cut_diamond",
	"foundry_furnace", "cosmetic_suit",
	"rocket_turret", "laser_turret", "land_mine", "backpack", "granite", "basalt", "quartz",
	"iron_ore", "titanium_ore", "sulfur", "coal", "stone_block", "reinforced_block", "steel_plate",
	"titanium_plate", "explosive_compound", "optic_core", "granite_barrier", "reinforced_barrier", "blast_barrier",
	"steel_barrier", "chest_small", "chest_medium", "chest_large",
]
const ROLE_SWARM := 0
const ROLE_LEAPER := 1
const ROLE_SPITTER := 2
const ROLE_BRUTE := 3
const ROLE_BROODLING := 4
const ROLE_GUARDIAN := 5
const MOB_TEXTURE_PATHS := {
	ROLE_SWARM: "res://assets/art/mobs/swarmer_runtime.png",
	ROLE_LEAPER: "res://assets/art/mobs/leaper_runtime.png",
	ROLE_SPITTER: "res://assets/art/mobs/spitter_runtime.png",
	ROLE_BRUTE: "res://assets/art/mobs/brute_runtime.png",
	ROLE_BROODLING: "res://assets/art/mobs/broodling_runtime.png",
	ROLE_GUARDIAN: "res://assets/art/mobs/guardian_runtime.png",
}
const TURRET_TEXTURE_PATHS := {
	BUILD_SENTRY: "res://assets/art/turrets/sentry_runtime.png",
	BUILD_ROCKET_TURRET: "res://assets/art/turrets/rocket_runtime.png",
	BUILD_LASER_TURRET: "res://assets/art/turrets/laser_runtime.png",
}
const WORLD_TEXTURE_PATHS := {
	"foundry": "res://assets/art/world/foundry_runtime.png",
	"personal_base": "res://assets/art/world/personal_base_runtime.png",
	"heavy_doorway": "res://assets/art/world/heavy_doorway_runtime.png",
	"brood_nest": "res://assets/art/world/brood_nest_runtime.png",
	"brood_carrier": "res://assets/art/mobs/brood_carrier_runtime.png",
	"barrier": "res://assets/art/world/barrier_runtime.png",
	"pickup": "res://assets/art/world/pickup_runtime.png",
	"crate": "res://assets/art/world/crate_runtime.png",
	"lamp": "res://assets/art/world/lamp_runtime.png",
	"eggs": "res://assets/art/world/eggs_runtime.png",
	"acid": "res://assets/art/world/acid_runtime.png",
	"web": "res://assets/art/world/web_runtime.png",
	"grate": "res://assets/art/world/grate_runtime.png",
	"rubble": "res://assets/art/world/rubble_runtime.png",
	"conduit": "res://assets/art/world/conduit_runtime.png",
	"crystal_shard": "res://assets/art/world/crystal_shard_runtime.png",
	"sulfur_vent": "res://assets/art/world/sulfur_vent_runtime.png",
	"slag_heap": "res://assets/art/world/slag_heap_runtime.png",
}
const WEAPON_ICON_NAMES: Array[String] = ["pistol", "shotgun", "laser", "smg", "railgun", "flamethrower"]
const MAX_ACTIVE_ENEMIES := 280
const MAX_ACTIVE_BROOD_NESTS := 3
const BROOD_NEST_HEALTH := 650.0
const BROOD_NEST_INCUBATION := 90.0
const BROOD_NEST_AGGRO_RADIUS := 150.0
const CORE_SPAWN_EXCLUSION_PADDING_CELLS := 2.0
const PERSONAL_BASE_SPAWN_EXCLUSION_CELLS := 8.0
const OPENING_CONTACT_DELAYS: Array[float] = [2.5, 11.0]
const OPENING_CONTACT_PACKS: Array[int] = [4, 3]
const BROOD_NEST_DEFENDER_HEALTH := 1100.0
const NEST_MILESTONE_AWARENESS_TIERS: Array[int] = [2, 4, 6, 8]
const APEX_COMPONENTS: Array[String] = ["ALPHA NEURAL CORE", "BROOD ENGINE", "CHITIN FORGE", "PHASE GLAND", "QUEEN COMMAND MATRIX"]
const MECHA_COSTS: Array[int] = [0, 5000, 12000, 25000]
const BROOD_CARRIER_CHANNEL := 7.0
const NEST_SITE_FLOW_CHECK_CAP := 16
const SPIDER_ROUTING_FLOW_STALL_THRESHOLD := 0.45
const SPIDER_ROUTE_CHECK_INTERVAL := 8
const SPIDER_STALL_RECOVER_THRESHOLD := 0.65
const SPIDER_LOCAL_ROUTE_RADIUS := 10
const SPIDER_LOCAL_ROUTE_NODE_BUDGET := 144
const SPIDER_RECOVERY_SIDE_LOCK_TICKS := 90
const SPIDER_DIRECT_COMBAT_RANGE := 30.0
const WORLD_ECOLOGY_TICK_INTERVAL := 0.10
const WORLD_ECOLOGY_MAX_STEPS_PER_FRAME := 1
const INVALID_ROUTE_CELL := Vector2i(-999999, -999999)
const SAVE_VERSION := 14
const MIN_SUPPORTED_SAVE_VERSION := 3
const COMBAT_UI_RANGE := 180.0
const WEAPON_HUD_LABELS: Array[String] = ["PST", "SHT", "LSR", "SMG", "RAL", "FLM"]
const ARCHIVE_SAVE_COOLDOWN := 120.0
const MAX_CHECKPOINT_SLOTS := 3
const CHECKPOINT_SLOT_LEVEL_REQS: Array[int] = [0, 10, 20]
const RECOVERY_VERSION := 1
const RECOVERY_LIFETIME := 600.0
const PICKUP_PISTOL_AMMO := "pistol_ammo"
const PICKUP_SHOTGUN_AMMO := "shotgun_ammo"
const PICKUP_SMG_AMMO := "smg_ammo"
const PICKUP_RAIL_AMMO := "rail_ammo"
const KILL_AMMO_BOUNTY_BIG := 3
const KILL_AMMO_BOUNTY_SMALL := 0

class Spider:
	var position := Vector2.ZERO
	var health := 20.0
	var max_health := 20.0
	var speed := 26.0
	var radius := 5.0
	var attack_cooldown := 0.0
	var big := false
	var role := ROLE_SWARM
	var biome_id := -1
	var leap_cooldown := 0.0
	var spit_cooldown := 0.0
	var windup := 0.0
	var windup_target := Vector2.ZERO
	var hit_flash := 0.0
	var stream_phase := 0.0
	var next_summon_ratio := 0.75
	var target_base_id := BaseNetworkScript.COMMAND_ID
	var guardian_site_id := ""
	var brood_nest_cell := Vector2i(-1, -1)
	var hunts_turrets := false
	var hunts_player := false
	var target_turret_cell := Vector2i(-1, -1)
	var target_torch_cell := Vector2i(-1, -1)
	var is_explorer := false
	var explorer_duration := 0.0
	var explorer_route_index := -1
	var explorer_route_stride := 1
	var explorer_legs_remaining := 0
	var is_scout := false
	var scout_name := ""
	var scout_region := Vector2i.ZERO
	var scout_contact := false
	var scout_report_elapsed := 0.0
	var scout_reported := false
	var is_brood_carrier := false
	var carrier_target_cell := Vector2i(-1, -1)
	var carrier_channel := 0.0
	var carrier_stall_time := 0.0
	var counts_for_wave := true
	var cleanup_recalled := false
	var last_damaged_by_sentry := false
	var facing_angle := 0.0
	var steer_direction := Vector2.ZERO
	var visual_motion := 0.0
	var hit_reaction := 0.0
	var hit_recoil_direction := Vector2.ZERO
	var locomotion_stall := 0.0
	var route_check_tick := -999
	var route_viable_cache := true
	var route_flow_epoch := -1
	# Regional-flow step commitment. A mob may spend several frames inside one
	# 24x24 cell; do not rerun neighbor ranking/clearance every frame or let the
	# steering layer reconsider the same decision until its cell/target/flow changes.
	var flow_step_from := INVALID_ROUTE_CELL
	var flow_step_next := INVALID_ROUTE_CELL
	var flow_step_target_id := ""
	var flow_step_epoch := -1
	# Transient fallback-route commitment. This is deliberately not serialized:
	# it only prevents frame-to-frame neighbor reversal while a mob is alive.
	var fallback_route_from := INVALID_ROUTE_CELL
	var fallback_route_next := INVALID_ROUTE_CELL
	var fallback_route_previous := INVALID_ROUTE_CELL
	var fallback_route_target := INVALID_ROUTE_CELL
	# Recovery-side hysteresis is transient and prevents the same stalled mob from
	# choosing opposite lateral escapes on consecutive recovery attempts.
	var recovery_side_sign := 0.0
	var recovery_side_lock_until_tick := -999
	# Transient chunk-lifecycle state. Background non-persistent hostiles may be
	# retired after staying outside the simulation window; world-identity mobs
	# hibernate instead. This is intentionally not serialized.
	var inactive_sim_time := 0.0

class Bullet:
	var position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var life := 1.2
	var damage := 12.0
	var sentry_round := false
	var enemy_round := false
	var radius := 2.0
	var knockback := 0.0
	var color := Color("ffd36b")
	var pierce_remaining := 0
	var projectile_kind := "round"
	var explosion_radius := 0.0
	var source_biome_id := -1
	var damage_type: StringName = &""
	var projectile_level := 0
	var texture_glob_id := ""
	var texture_trail_id := ""
	var texture_splat_id := ""
	var is_special_lob := false
	var is_cyst := false
	var age := 0.0
	var visual_spin_rate := 0.0
	var visual_wobble := 0.0
	var trail_stretch := 1.0

class FirePatch:
	var position := Vector2.ZERO
	var life := 2.4
	var max_life := 2.4
	var radius := 18.0
	var damage_per_second := 7.0
	var player_only := false
	var source_damage_type: StringName = &""

class Structure:
	var kind := BUILD_BARRICADE
	var cell := Vector2i.ZERO
	var position := Vector2.ZERO
	var cooldown := 0.0
	var health := 100.0
	var max_health := 100.0
	var aim_direction := Vector2.LEFT
	var level := 1
	var base_id := ""
	var powered := false
	var inventory: Dictionary = {}
	var chest_capacity := 0
	var size := Vector2i(1, 1)
	var rotated := false
	var is_open := false
	var lantern_color_id := 0
	var foundry_state: Dictionary = {}
	var is_ruin := false
	var fortress_chest := false
	var fortress_reward_claimed := false

class Spark:
	var position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var life := 0.4
	var max_life := 0.4
	var color := Color.WHITE
	var size := 1.0

class CombatImpact:
	var texture_id := ""
	var position := Vector2.ZERO
	var direction := Vector2.RIGHT
	var size := Vector2(8, 8)
	var life := 0.22
	var max_life := 0.22
	var modulate := Color.WHITE
	var enemy_pop := false

class XpHighlight:
	var position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var life := 1.15
	var max_life := 1.15
	var text := "+0 XP"
	var color := Color("8eeaff")

class Pickup:
	var position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var kind := PICKUP_PISTOL_AMMO
	var amount := 1
	var life := 60.0
	var phase := 0.0

class BroodNest:
	var cell := Vector2i.ZERO
	var health := BROOD_NEST_HEALTH
	var max_health := BROOD_NEST_HEALTH
	var maturity := 0.0
	var spawn_cooldown := 24.0
	var register_retry_cooldown := 0.0
	var birth_wave := 0
	var aggressive := false
	var boss_spawned := false
	var is_lair := false
	var apex_id := ""
	var pressure_pulses := 0

var grid: WorldGridScript
var flow: FlowFieldScript
var explorer_flows: Array[FlowFieldScript] = []
var explorer_targets: Array[Vector2i] = []
var brood_carrier_flows: Dictionary = {}
var player_flow: FlowFieldScript
var player_flow_cell := Vector2i(-999, -999)
var player_flow_region := Vector2i(-999, -999)
var active_player_region := Vector2i(-999, -999)
var _enemy_blocked_cells: Dictionary = {}
var visual_prop_cache: Dictionary = {}
var discovery_hive_cells: Dictionary = {}
var ruined_fortress_regions: Dictionary = {}
var region_floor_materials: Dictionary = {}
var visual_formation_cache: Dictionary = {}
var visual_landmark_cache: Dictionary = {}
var visual_biome_cache: Dictionary = {}
var terrain_chunk_layers: Dictionary = {}
var terrain_chunk_redraw_queue: Dictionary = {}
var terrain_chunk_committed: Dictionary = {}
## Lean intent captured at schedule time — queue is erased before CanvasItem _draw runs.
var terrain_chunk_lean_pending: Dictionary = {}
# Immediate mutation overlay + deferred quality refinement. The authoritative
# patch set is indexed into tiny 8x8 draw sectors so a new mined block redraws
# only its local sector instead of replaying every outstanding mutation.
var terrain_mutation_patch_cells: Dictionary = {}
var terrain_mutation_sector_cells: Dictionary = {}
var terrain_mutation_sector_layers: Dictionary = {}
var terrain_chunk_mutation_regions: Dictionary = {}
var terrain_chunk_refine_queue: Dictionary = {}
var terrain_chunk_force_quality: Dictionary = {}
var terrain_refine_cooldown := 0.0
var _terrain_draw_stream_regions: Dictionary = {}
var _mining_beam_regions: Dictionary = {}
var _terrain_redraw_force_burst := false
var _boot_terrain_drain_active := false
var _terrain_chunk_draw_lean := false
var _last_stream_regions: Dictionary = {}
var minimap_cache_texture: ImageTexture
var minimap_cache_image: Image
var minimap_view_origin := Vector2i.ZERO
var minimap_patch_pending := false
var minimap_cache_dirty := true
var minimap_rebuild_cooldown := 0.0
var terrain_flow_dirty := false
var terrain_flow_rebuild_cooldown := 0.0
var flow_dirty_regions: Dictionary = {}
var flow_region_dirty_cooldowns: Dictionary = {}
var _spider_flow_refresh_regions: Dictionary = {}
# One route-repair anchor per base target is retained until the debounced flow
# rebuild actually runs. This prevents no-flow mobs from starving the debounce.
var _routing_flow_repair_requests: Dictionary = {}
var routing_flow_rebuild_pending := false
var player_flow_stale := false
var player_flow_refresh_cooldown := 0.0
var _minimap_flush_frame := -999
var _enemy_spatial_buckets: Dictionary = {}
var _enemy_spatial_buckets_frame := -1
var _enemy_spatial_bucket_enemy_count := -1
var _turret_target_cache: Dictionary = {}
var _combat_frame_tick := 0
var base_flow_rebuild_cooldown := 0.0
var _visual_dirty_mask := VIS_DIRTY_ALL
var _paused_ui_dirty := false
var _last_aim_mouse_world := Vector2.ZERO
var _last_player_region := Vector2i(-999, -999)
var _last_camera_center := Vector2.ZERO
var _camera_stable_frames := 0
var _last_stream_direction := Vector2.ZERO
var _stream_center_tick := 0
var _last_render_player_region := Vector2i(-999, -999)
var _last_render_camera_region := Vector2i(-999, -999)
var _last_render_signature := -1
var _wave_pressure_nearby := 0
var _wave_pressure_frame := -1
var _wave_pressure_enemy_count := -1
var _wave_pressure_recompute_tick := -999
var _wave_pressure_dirty := true
var pending_brood_carrier_requests: Array[Dictionary] = []
var _cached_bases_under_attack: Dictionary = {"count": 0, "bases": {}}
var _cached_bases_under_attack_tick := -1
var _structure_spatial_buckets: Dictionary = {}
var _structure_spatial_buckets_frame := -1
var _structure_spatial_bucket_count := -1
var _player_flow_refresh_pending := false
var _recent_mine_flow_tick := -999
var _chunk_formations_cache: Dictionary = {}
var _chunk_macro_floor_ok: Dictionary = {}
var _chunk_macro_rock_ok: Dictionary = {}
var _pending_visual_region_builds: Array[Vector2i] = []
var _pending_visual_region_set: Dictionary = {}
const MINIMAP_REBUILD_DELAY := 0.18
const TERRAIN_FLOW_REBUILD_DELAY := 0.9
const BASE_FLOW_COMBAT_THROTTLE := 1.75
const BASE_FLOW_COMBAT_ENEMY_THRESHOLD := 80
const FLOW_REGION_DIRTY_COOLDOWN := 1.0
const PLAYER_FLOW_REFRESH_DELAY := 0.25
const PLAYER_FLOW_REGION_CAP := 5
const FAR_NEST_REGION_SCAN_CAP := 4
const FAR_NEST_CANDIDATE_CAP := 6
const FAR_NEST_SITE_CHECK_CAP := 24
const NEST_SITE_REGION_SCAN_CAP := 4
const NEST_SITE_FRONTIER_VISIT_CAP := 480
const TERRAIN_CHUNK_REDRAW_BUDGET := 1
const MINING_TERRAIN_REDRAW_BUDGET := 1
const BOOT_TERRAIN_FLUSH_BUDGET := 1
const BOOT_TERRAIN_DRAIN_BUDGET := 1
const BOOT_TERRAIN_DRAIN_UNTIL := 3
const TERRAIN_CHUNK_FLUSH_BURST_CAP := 6
## Lean is decided at schedule time (before queue erase). Threshold 1 keeps drain frames lean.
const TERRAIN_LEAN_QUEUE_THRESHOLD := 1
const MINING_REDRAW_CANDIDATE_CAP := 6
const MAX_TERRAIN_REDRAW_QUEUE := 32
# Single-cell mining/build mutations render through a lightweight overlay first.
# Full chunk rasters are coalesced behind the interaction instead of blocking it.
const TERRAIN_MUTATION_PATCH_MAX_CELLS := 512
const TERRAIN_MUTATION_SECTOR_SIZE := 8
const TERRAIN_REFINE_INTERVAL := 0.85
const MINING_CHUNK_CATCHUP_QUEUE := 8
const LIGHTING_PROP_THROTTLE_FRAMES := 4
const MINING_LIGHTING_THROTTLE_FRAMES := 4
const LIGHTING_CULL_MARGIN := 80.0
const VIS_DIRTY_WORLD := 1
const VIS_DIRTY_ACTORS := 2
const VIS_DIRTY_EFFECTS := 4
const VIS_DIRTY_LIGHTING := 8
const VIS_DIRTY_HUD := 16
const VIS_DIRTY_ALL := 31
const TERRAIN_CHUNK_BLEED_CELLS := 2
const TERRAIN_CHUNK_BACKING := Color("121820")
const HOSTILE_SPAWN_FRAME_BUDGET := 2
const HOSTILE_SPAWN_QUEUE_CAP := 64
const GUARDIAN_SUMMON_PACK := 3
const NEST_REGISTER_RETRY_COOLDOWN := 1.0
const MAX_SPARKS := 384
const MAX_ENEMY_BULLETS := 24
const CAP_RETRY_COOLDOWN := 0.25
const MAX_COMBAT_IMPACTS := 64
const SPARK_SIEGE_ENEMY_THRESHOLD := 64
const SPARK_MINING_SKIP_THRESHOLD := 48
# Chunk materialization is GDScript-heavy. Keep it to one chunk per frame;
# mining owns that frame's budget after it has prioritized the beam corridor.
const REGION_PRELOAD_BUDGET := 1
const EXTERIOR_HORIZON_CELLS := 100
const EXTERIOR_ENQUEUE_CAP := 1
const REGION_PRELOAD_MOVING_BUDGET := 1
const REGION_PRELOAD_MINING_BUDGET := 1
const BOOT_REGION_PRELOAD_CAP := 2
# Prop/formation generation is deferred off the preload tick so materialization
# and decoration work never stack on the same frame.
const VISUAL_REGION_BUILD_BUDGET := 1
const VISUAL_REGION_BUILD_MOVING_BUDGET := 1
const VISUAL_REGION_BUILD_MINING_BUDGET := 1
const ENCOUNTER_FLOW_GRACE := 0.45
const MAX_PENDING_BROOD_CARRIER_REQUESTS := 8
const WAVE_RELOCATE_PLAYER_SAFE_RADIUS := 200.0
const WAVE_REROUTE_INTERVAL := 22.0
const WAVE_RELOCATE_MIN_STALL := 1.0
# Minecraft-style hostile lifecycle: incidental ecology mobs do not remain in
# memory forever after their chunks leave the simulation window. Encounter and
# persistent guardian/nest mobs hibernate instead of being retired.
const BACKGROUND_HOSTILE_DESPAWN_SEC := 12.0
const MAX_WAVE_RELOCATIONS_PER_TICK := 3
var base_network: BaseNetworkScript
var material_economy: MaterialEconomyScript
var operator_loadout: OperatorLoadoutScript
var operator_onboard: OperatorOnboardScript
var placeable_blocks: PlaceableBlocksScript
var gameplay_telemetry: GameplayTelemetryScript
var torch_starter_issued := false
var opening_contact_stage := 0
var opening_contact_timer := -1.0
var merchant_invited := false
var merchant_store_kit_issued := false
var merchant_store_session := false
var merchant_store_structure_index := -1
var controls_remap_seen := false
var pack_selected_index := 0 ## backpack grid selection while I is open
var torch_contact_cache_frame := -1
var torch_contact_cache: Dictionary = {} ## structure index -> count
var _pending_loadout_data: Variant = {}
var _pending_loadout_stock: Dictionary = {}
var _pending_loadout_weapon := 0
var base_flows: Dictionary = {}
var hive_awareness: HiveAwarenessScript = HiveAwarenessScript.new()

var player_position := Vector2.ZERO
var player_health := 100.0
var aim_direction := Vector2.LEFT
var aim_uses_controller := false
var shoot_cooldown := 0.0
var muzzle_flash := 0.0
var muzzle_flash_max := 0.14
var magazine := 12
var reserve_ammo := 120
var reload_time := 0.0
var reload_hold_time := 0.0
var inventory_hold_time := 0.0
var current_weapon := WEAPON_PISTOL
var shotgun_magazine := 6
var shotgun_reserve := 36
var laser_energy := 100.0
var smg_magazine := 30
var smg_reserve := 120
var railgun_magazine := 3
var railgun_reserve := 12
var flame_fuel := 0
var flamethrower_unlocked := false
var laser_active := false
var laser_end := Vector2.ZERO
var weapon_damage_multiplier := 1.0
var fire_rate_multiplier := 1.0
var sentry_damage_multiplier := 1.0
var sentry_rate_multiplier := 1.0
var fortification_multiplier := 1.0
var unlocked_weapons: Array[bool] = [true, true, true, false, false, false]
var weapon_tiers: Array[int] = [1, 1, 1, 1, 1, 1]
var mag_upgrade_tiers: Array[int] = [0, 0, 0, 0, 0, 0]  # per-weapon extended mag tier (0-4)
var armory_mag_weapon_index := 0  # which weapon Extended Mags slot 6 is focused on
var storage_upgrade_focus_index := 0  # which deployable the storage upgrade slot targets
var player_style_id := 0
var unlocked_player_styles: Array[bool] = [true, false, false, false]
var player_strength_multiplier := 1.0
var player_defense_multiplier := 1.0
var dash_cooldown := 0.0
var player_invulnerability := 0.0
var player_dot_time := 0.0
var player_dot_dps := 0.0
var player_slow_time := 0.0
var player_slow_mult := 1.0
var _encounter_special_lob_used := 0
var damage_flash := 0.0
var sprint_energy := 100.0
var sprint_recovery_delay := 0.0
var sprinting := false
var player_moving := false
var player_move_direction := Vector2.ZERO
var locomotion_phase := 0.0
var locomotion_step_side := 0
var sprint_trail_cooldown := 0.0
var player_hit_time := 0.0
var player_hit_recoil := Vector2.ZERO

var core_health := 100.0
var scrap := ScrapEconomyScript.START
var score := 0
var explored_sectors: Dictionary = {}
var discovered_biomes: Dictionary = {}
var exploration_find_count := 0
var total_survey_sectors := 0

var breached := false
var first_breach_cell := Vector2i(-1, -1)
var first_mine_earned := false
var wave := 0
var encounters_completed := 0
var wave_active := false
var spawns_remaining := 0
var spawn_cooldown := 0.0
var boss_pending := false
var bosses_remaining := 0
var spawn_sequence := 0
var current_wave_plan: Dictionary = {}
var wave_reward_claimed := false
var brood_carriers_remaining := 0
var wave_cleanup_elapsed := 0.0
var spawn_cap_stall_elapsed := 0.0
var hostile_spawn_budget_active := false
var hostile_spawn_budget_remaining := 0
var pending_hostile_spawns: Array[Dictionary] = []
var wave_reroute_elapsed := 0.0
var encounter_load_grace := 0.0
var world_ecology_accumulator := 0.0
var world_ecology_tick_sequence := 0
var terrain_raster_scheduled_this_frame := false
var ecology_tick_ran_this_frame := false
var run_seed := 0
var realm_id := ""
var realm_ended := false
var autosave_elapsed := 0.0
var checkpoint_exists := false
var checkpoint_base_id := ""
var checkpoint_position := Vector2.ZERO
var checkpoint_generation := 0
var checkpoint_slots: Array[Dictionary] = []
var realm_save_cooldown := 0.0
var encounter_epoch := 0
var recovery_cache: Dictionary = {}
var recovery_journal_elapsed := 0.0
var sleeping := false
var sleep_phase := 0
var sleep_elapsed := 0.0
var sleep_structure_index := -1
var sleep_entry_cooldown := 0.0
var lantern_upgrade_target_cell := Vector2i(-1, -1)
var discovery_alert := ""
var discovery_alert_time := 0.0
var chest_alert_text := ""
var chest_alert_time := 0.0
var chest_alert_position := Vector2.ZERO
var difficulty_id := DIFFICULTY_PROFILE.DEFAULT_ID
var difficulty: Dictionary = DIFFICULTY_PROFILE.get_profile(DIFFICULTY_PROFILE.DEFAULT_ID)
var choosing_upgrade := false  # Legacy flag kept for save compatibility; upgrades now resolve at the shop.
var build_mode := false
var build_intent := false
var build_orientation := false
var selected_build := BUILD_BARRICADE
var build_target := Vector2i.ZERO
var foundry_kit_available := false
var mine_target := Vector2i(-1, -1)
var mine_progress := 0.0
var mining_speed_tier := 1
var mining_cycle_multiplier := 1.0
var mining_emitter_tier := 1
var relocating_structure_index := -1
var relocation_target := Vector2i(-1, -1)
var backpack_tier := 1
var construction_unlocks: Dictionary = {
	"granite_barrier": true, "steel_barrier": true, "reinforced_barrier": false, "blast_barrier": false,
	"land_mine": false, "rocket_turret": false, "laser_turret": false,
	"chest_small": true, "chest_medium": true, "chest_large": true,
	"heavy_doorway": false,
	"personal_base": false,
	SettlementProgressionScript.MERCHANT_STORE_STOCK_ID: false,
	TORCH_STOCK_ID: true,
}
var deployable_stock: Dictionary = {
	"granite_barrier": 0, "steel_barrier": 0, "reinforced_barrier": 0, "blast_barrier": 0,
	"land_mine": 0, "rocket_turret": 0, "laser_turret": 0,
	"chest_small": 0, "chest_medium": 0, "chest_large": 0,
	"heavy_doorway": 0,
	"personal_base": 0,
	"foundry": 0,
	SettlementProgressionScript.MERCHANT_STORE_STOCK_ID: 0,
	TORCH_STOCK_ID: 0,
}
# Max stock for each deployable type (Tier 0=50, Tier1=100, Tier2=200)
var deployable_storage_tiers: Dictionary = {
	"granite_barrier": 0, "steel_barrier": 0, "reinforced_barrier": 0, "blast_barrier": 0,
	"land_mine": 0, "rocket_turret": 0, "laser_turret": 0,
	"chest_small": 0, "chest_medium": 0, "chest_large": 0,
	"heavy_doorway": 0,
	"personal_base": 0,
	SettlementProgressionScript.MERCHANT_STORE_STOCK_ID: 0,
}
var door_hold_time := 0.0  # tracks how long F is held near a doorway
var mining_beam_end := Vector2.ZERO
var mining_beam_valid := false
var mining_feedback_time := 0.0
var mining_spark_cooldown := 0.0
var mining_impact_pulse := 0.0
var mining_impact_position := Vector2.ZERO
var laser_visual_phase := 0.0
var combat_fx_phase := 0.0
var paused := false
var backpack_open := false
var game_over := false
var using_core_base := false
var using_foundry := false
var active_foundry_index := -1
var suppress_primary_fire_until_release := false
var using_chest_index := -1
var chest_panel: ColorRect
var chest_title: Label
var chest_status: Label
var chest_player_list: GridContainer
var chest_vault_list: GridContainer
var chest_player_heading: Label
var chest_vault_heading: Label
var chest_actions: Array[Button] = []
var core_menu_page := "armory"
var turret_selection_active := false
var turret_selection_indices: Array[int] = []
var turret_selection_cursor := 0
var current_base_id := BaseNetworkScript.COMMAND_ID
var load_saved_run := false
var saved_run_loaded := false
var _load_handoff: Dictionary = {}
var _terrain_preloaded := false
var _pending_suit_alert := false
var activation_spawn_cooldown := 0.0
var activation_spawn_sequence := 0
var expedition_level := 0
var expedition_xp := 0
var skill_points := 0
var skill_unlocks: Array[String] = []
var foundry_ui_refresh_elapsed := 0.0

var enemies: Array[Spider] = []
var brood_nests: Array[BroodNest] = []
var destroyed_brood_nests: Dictionary = {}
var brood_escalation := 0
var nest_milestones_spawned: Dictionary = {}
var _pending_far_nest_milestone := -1
var _far_nest_retry_cooldown := 0.0
var _far_nest_retry_attempts := 0
var flow_epoch := 0
var nest_kills_total := 0
var lair_cycle_pending := false
var apex_phase := false
var _apex_spawn_attempts := 0
var boss_components_carried: Dictionary = {}
var boss_components_deposited: Dictionary = {}
var mecha_level := 0
var mecha_spiders: Array[Spider] = []
var surface_portal_cell := Vector2i(-1, -1)
var beta_teaser_active := false
var bullets: Array[Bullet] = []
var _enemy_bullet_count := 0
var fire_patches: Array[FirePatch] = []
var structures: Array[Structure] = []
var sparks: Array[Spark] = []
var combat_impacts: Array[CombatImpact] = []
var xp_highlights: Array[XpHighlight] = []
var hud_suit_display := 100.0
var hud_energy_display := 100.0
var hud_scrap_display := 0.0
var hud_suit_damage_flash := 0.0
var hud_suit_heal_flash := 0.0
var hud_energy_low_flash := 0.0
var hud_scrap_tick := 0.0
var hud_pack_flash := 0.0
var hud_weapon_flash := 0.0
var hud_weapon_last := 0
var hud_level_up_flash := 0.0
var hud_sp_pulse := 0.0
var hud_last_scrap := 0
var hud_last_pack_used := 0
var hud_xp_pip_ratio := 0.0
var hud_xp_flash := 0.0
var hud_objective_pulse := 0.0
var hud_wave_flash := 0.0
var hud_breather_pulse := 0.0
var hud_minimap_bloom := 0.0
var hud_minimap_bloom_cell := Vector2i(-99999, -99999)
var hud_minimap_sweep := 0.0
var hud_base_attack_flash: Dictionary = {}
var hud_near_core_sp_glow := 0.0
var hud_comms_active: Dictionary = {}
var hud_comms_queue: Array[Dictionary] = []
var hud_comms_last_posted_text := ""
var hud_comms_secondary: Dictionary = {}
var hud_comms_secondary_alpha := 0.0
var hud_comms_transition := 0.0
var hud_comms_display_text := ""
var hud_comms_glyph_spin := 0.0
var hud_comms_last_severity := ""
var hud_context_idle_blink := 0.0
var hud_last_bases_under_attack := 0
var hud_last_wave_active := false
var hud_last_breather := false
var hud_breather_total := 0.0
var hud_breather_ratio := 0.0
var hud_kill_streak := 0
var hud_kill_streak_timer := 0.0
var hud_kill_streak_flash := 0.0
var pickups: Array[Pickup] = []

var pause_panel: Control
var realm_archive_panel: Control
var realm_archive_title: Label
var realm_archive_status: Label
var realm_archive_detail: Label
var realm_archive_save_button: Button
var realm_archive_save_buttons: Array[Button] = []
var realm_archive_activate_buttons: Array[Button] = []
var realm_archive_back_button: Button
var using_realm_archive := false
var archive_return_to_pause := false
var pause_save_button: Button
var game_over_panel: Control
var game_over_label: Label
var sleep_overlay: ColorRect
var sleep_status_label: Label
var core_base_panel: Control
var foundry_panel: ColorRect
var foundry_title: Label
var foundry_status: Label
var foundry_production_label: Label
var foundry_inventory_label: Label
var foundry_detail_label: Label
var foundry_progress_bar: ColorRect
var foundry_machine_icon: TextureRect
var foundry_recipe_input_icons: Array[TextureRect] = []
var foundry_recipe_input_counts: Array[Label] = []
var foundry_recipe_output_icon: TextureRect
var foundry_recipe_output_count: Label
var foundry_buffer_icons: Array[TextureRect] = []
var foundry_buffer_counts: Array[Label] = []
var foundry_action_buttons: Array[Button] = []
var foundry_action_message := ""
var backpack_panel: Control
var backpack_capacity_label: Label
var backpack_load_bar: ColorRect
var backpack_slot_icons: Array[TextureRect] = []
var backpack_slot_counts: Array[Label] = []
var backpack_slot_frames: Array[ColorRect] = []
var pack_assign_holster: Array = []
var pack_assign_build: Array = []
var pack_assign_pack: Array = []
var pack_assign_pick: Dictionary = {}
var core_base_status: Label
var core_base_scrap_label: Label
var core_base_network_label: Label
var core_xp_track: ColorRect
var core_xp_fill: ColorRect
var core_xp_label: Label
var core_detail_icon: TextureRect
var core_detail_title: Label
var core_detail_body: Label
var core_detail_state: Label
var core_department_buttons: Dictionary = {}
var core_purchase_button: Button
var core_purchase_cost: Label
var core_selected_action_slot := 0
var pause_summary: Label
var pause_realm_title: Label
var armory_button: Button
var research_button: Button
var turret_button: Button
var repair_button: Button
var restock_button: Button
var extra_action_button: Button
var extra_action_button2: Button
var extra_action_button3: Button
var base_upgrade_button: Button
var material_sale_button: Button
var core_base_title: Label
var core_tab_buttons: Dictionary = {}
var core_service_buttons: Array[Button] = []
var core_action_details: Array[String] = ["", "", "", "", "", "", "", "", "", ""]
var core_action_states: Array[String] = ["", "", "", "", "", "", "", "", "", ""]
var overlay_root: Control
var world_layer: RenderLayerScript
var terrain_mutation_layer: RenderLayerScript
var actor_layer: RenderLayerScript
var effects_layer: RenderLayerScript
var lighting_layer: RenderLayerScript
var hud_draw: RenderLayerScript
var player_camera: Camera2D
var cave_texture: Texture2D
var hive_material: Texture2D
var tunnel_material: Texture2D
var bunker_material: Texture2D
var crystal_material: Texture2D
var foundry_material: Texture2D
var sulfur_material: Texture2D
var iron_material: Texture2D
var formation_materials: Dictionary = {}
var material_backing_colors: Dictionary = {}
var patch_backing_cache: Dictionary = {}
var mob_textures: Dictionary = {}
var biome_mob_textures: Dictionary = {}
var turret_textures: Dictionary = {}
var player_textures: Array[Texture2D] = []
var player_direction_textures: Dictionary = {}
var player_active_direction_textures: Dictionary = {}
var shop_icons: Dictionary = {}
var world_textures: Dictionary = {}
var combat_textures: Dictionary = {}
var runtime_assets_valid := true
var runtime_asset_failures: PackedStringArray = PackedStringArray()
const USE_IMPORTED_COMBAT_FX := true
const USE_IMPORTED_HUD_SKINS := true
const USE_IMPORTED_RETICLES := true
# The sliced atlas frames carry a baked-in magenta corner accent that clashes
# with this HUD's cyan/teal palette. Modulating with this tint suppresses the
# red channel so those corners read as cool teal instead of pink.
const HUD_CHROME_TINT := Color(0.58, 1.0, 0.98)
const UI_TEXTURE_NAMES: Array[String] = [
	"hud_bar_green", "hud_bar_cyan", "hud_bar_amber",
	"hud_panel_teal", "hud_panel_cyan", "hud_panel_muted",
	"hud_panel_wide_teal", "hud_panel_wide_cyan", "hud_panel_square",
	"hud_slot_dark", "hud_slot_cyan", "hud_slot_locked",
	"hud_display_panel", "hud_window_square",
	"hud_icon_crosshair", "hud_icon_warning", "hud_icon_factory", "hud_icon_briefcase",
	"reticle_yellow", "reticle_cyan", "reticle_purple", "reticle_white",
]
var ui_textures: Dictionary = {}
var _world_presentation: RefCounted
var _actor_presentation: RefCounted
var _hud_presentation: RefCounted


func set_difficulty(requested_id: String) -> void:
	difficulty_id = DIFFICULTY_PROFILE.normalize_id(requested_id)
	difficulty = DIFFICULTY_PROFILE.get_profile(difficulty_id)


func request_saved_run() -> void:
	load_saved_run = true


func configure_new_realm(seed: int) -> void:
	run_seed = maxi(1, seed & 0x7fffffff)
	realm_id = RealmSaveScript.realm_id_for_seed(run_seed)


func get_run_seed() -> int:
	return run_seed


func accept_load_handoff(handoff: Dictionary) -> void:
	_load_handoff = handoff
	if handoff.has("grid"):
		grid = handoff["grid"]
	if handoff.has("run_seed"):
		run_seed = int(handoff["run_seed"])
	if handoff.has("realm_id"):
		realm_id = str(handoff["realm_id"])
	if handoff.has("difficulty_id"):
		difficulty_id = DIFFICULTY_PROFILE.normalize_id(str(handoff["difficulty_id"]))
		difficulty = DIFFICULTY_PROFILE.get_profile(difficulty_id)
	_terrain_preloaded = bool(handoff.get("terrain_preloaded", false))
	_pending_suit_alert = bool(handoff.get("show_suit_alert", false))
	if str(handoff.get("mode", "")) == "resume":
		load_saved_run = true


func _resolve_realm_dimensions() -> Vector2i:
	return Vector2i(WorldGridScript.REALM_WIDTH, WorldGridScript.REALM_HEIGHT)


func _saved_realm_dimensions(data: Dictionary) -> Vector2i:
	var saved_version := int(data.get("version", 0))
	if saved_version >= 12:
		return Vector2i(
			int(data.get("realm_width", WorldGridScript.REALM_WIDTH)),
			int(data.get("realm_height", WorldGridScript.REALM_HEIGHT))
		)
	return Vector2i(WorldGridScript.LEGACY_REALM_WIDTH, WorldGridScript.LEGACY_REALM_HEIGHT)


func _save_needs_realm_upscale(data: Dictionary) -> bool:
	var saved_dimensions := _saved_realm_dimensions(data)
	return saved_dimensions.x != WorldGridScript.REALM_WIDTH or saved_dimensions.y != WorldGridScript.REALM_HEIGHT


func _realm_upscale_ratios(source_dimensions: Vector2i) -> Vector2:
	return Vector2(
		float(WorldGridScript.REALM_WIDTH) / float(maxi(1, source_dimensions.x)),
		float(WorldGridScript.REALM_HEIGHT) / float(maxi(1, source_dimensions.y))
	)


func _scale_realm_pair(pair: Array, ratios: Vector2) -> Array:
	if pair.size() != 2:
		return pair
	return [
		int(round(float(pair[0]) * ratios.x)),
		int(round(float(pair[1]) * ratios.y)),
	]


func _upscale_encoded_cell_dictionary(values: Dictionary, ratios: Vector2) -> Dictionary:
	var result: Dictionary = {}
	for encoded: String in values.keys():
		var parts: PackedStringArray = encoded.split(",")
		if parts.size() != 2:
			continue
		var cell := Vector2i(
			int(round(float(parts[0]) * ratios.x)),
			int(round(float(parts[1]) * ratios.y))
		)
		result["%d,%d" % [cell.x, cell.y]] = values[encoded]
	return result


func _apply_realm_upscale_to_save(data: Dictionary, source_dimensions: Vector2i) -> void:
	var ratios := _realm_upscale_ratios(source_dimensions)
	data["realm_width"] = WorldGridScript.REALM_WIDTH
	data["realm_height"] = WorldGridScript.REALM_HEIGHT
	var checkpoint_position: Variant = data.get("checkpoint_position", [])
	if checkpoint_position is Array and checkpoint_position.size() == 2:
		data["checkpoint_position"] = [
			float(checkpoint_position[0]) * ratios.x,
			float(checkpoint_position[1]) * ratios.y,
		]
	var player_position: Variant = data.get("player_position", [])
	if player_position is Array and player_position.size() == 2:
		data["player_position"] = [
			float(player_position[0]) * ratios.x,
			float(player_position[1]) * ratios.y,
		]
	for field_name: String in ["first_breach_cell", "surface_portal_cell", "lantern_upgrade_target_cell", "starting_core_cell"]:
		var saved_pair: Variant = data.get(field_name, [])
		if saved_pair is Array and saved_pair.size() == 2:
			data[field_name] = _scale_realm_pair(saved_pair, ratios)
	for dictionary_field: String in ["cell_deltas", "explored_sectors", "visited_regions", "loaded_regions", "revealed_discoveries", "mined_minerals", "destroyed_brood_nests"]:
		var saved_dictionary: Variant = data.get(dictionary_field, {})
		if saved_dictionary is Dictionary:
			data[dictionary_field] = _upscale_encoded_cell_dictionary(saved_dictionary, ratios)
	var saved_spawn_cells: Variant = data.get("spawn_cells", [])
	if saved_spawn_cells is Array:
		var scaled_spawn_cells: Array = []
		for pair_value: Variant in saved_spawn_cells:
			if pair_value is Array:
				scaled_spawn_cells.append(_scale_realm_pair(pair_value, ratios))
		data["spawn_cells"] = scaled_spawn_cells
	var saved_structures: Variant = data.get("structures", [])
	if saved_structures is Array:
		for structure_value: Variant in saved_structures:
			if structure_value is Dictionary:
				var saved_cell: Variant = structure_value.get("cell", [])
				if saved_cell is Array:
					structure_value["cell"] = _scale_realm_pair(saved_cell, ratios)
	var saved_nests: Variant = data.get("brood_nests", [])
	if saved_nests is Array:
		for nest_value: Variant in saved_nests:
			if nest_value is Dictionary:
				var nest_cell: Variant = nest_value.get("cell", [])
				if nest_cell is Array:
					nest_value["cell"] = _scale_realm_pair(nest_cell, ratios)
	for entity_field: String in ["enemies", "pickups"]:
		var saved_entities: Variant = data.get(entity_field, [])
		if saved_entities is Array:
			for entity_value: Variant in saved_entities:
				if entity_value is Dictionary:
					var entity_position: Variant = entity_value.get("position", [])
					if entity_position is Array and entity_position.size() == 2:
						entity_value["position"] = [
							float(entity_position[0]) * ratios.x,
							float(entity_position[1]) * ratios.y,
						]
	var recovery_cache: Variant = data.get("recovery_cache", {})
	if recovery_cache is Dictionary and recovery_cache.get("position") is Array:
		var cache_position: Array = recovery_cache["position"]
		if cache_position.size() == 2:
			recovery_cache["position"] = [
				float(cache_position[0]) * ratios.x,
				float(cache_position[1]) * ratios.y,
			]
	var network_data: Variant = data.get("base_network", {})
	if network_data is Dictionary:
		for base_id: String in network_data.keys():
			var record: Variant = network_data[base_id]
			if record is Dictionary and record.get("cell") is Array:
				record["cell"] = _scale_realm_pair(record["cell"], ratios)
		var frontier_sites: Variant = network_data.get("frontier_sites", {})
		if frontier_sites is Dictionary:
			for site_id: String in frontier_sites.keys():
				var site_cell: Variant = frontier_sites[site_id]
				if site_cell is Array:
					frontier_sites[site_id] = _scale_realm_pair(site_cell, ratios)


func _region_stream_radius() -> int:
	## Rendering is driven primarily by the camera bounds; this center radius is
	## only travel headroom. One region is sufficient because the simulation halo
	## and rolling 9x9 prepare horizon provide the larger safety margins. Keeping
	## radius 2 duplicated a 5x5 center window on top of the camera-derived window.
	return 1


func get_wave_spawn_count(wave_number: int) -> int:
	return DIFFICULTY_PROFILE.wave_spawn_count(difficulty_id, wave_number)


func get_spawn_interval(wave_number: int) -> float:
	return DIFFICULTY_PROFILE.spawn_interval(difficulty_id, wave_number)


func _ready() -> void:
	_world_presentation = RunWorldPresentationScript.new(self)
	_actor_presentation = RunActorPresentationScript.new(self)
	_hud_presentation = RunHudPresentationScript.new(self)
	_install_custom_cursor()
	if load_saved_run:
		var summary: Dictionary = RealmSaveScript.active_summary()
		if not summary.is_empty():
			run_seed = int(summary.get("realm_seed", 0))
			realm_id = str(summary.get("realm_id", ""))
	var realm_size := _resolve_realm_dimensions()
	if grid == null:
		grid = WorldGridScript.new(realm_size.x, realm_size.y, WorldGridScript.REALM_TILE_SIZE)
	if run_seed == 0:
		run_seed = int(Time.get_ticks_usec() & 0x7fffffff) ^ difficulty_id.hash()
	if realm_id.is_empty():
		realm_id = RealmSaveScript.realm_id_for_seed(run_seed)
	if not _terrain_preloaded:
		grid.generate_realm(run_seed, difficulty_id)
		grid.configure_discoveries(run_seed, difficulty_id)
	flow = FlowFieldScript.new()
	player_flow = FlowFieldScript.new()
	base_network = BaseNetworkScript.new()
	base_network.configure(grid.core_cell, grid.width, grid.height, grid.frontier_sites)
	base_network.sanitize_activation_state()
	material_economy = MaterialEconomyScript.new()
	operator_loadout = OperatorLoadoutScript.new()
	operator_onboard = OperatorOnboardScript.new()
	placeable_blocks = PlaceableBlocksScript.new()
	gameplay_telemetry = GameplayTelemetryScript.new()
	gameplay_telemetry.configure_from_environment()
	if not load_saved_run:
		operator_loadout.apply_default_new_run(unlocked_weapons)
		operator_loadout.set_pack_tier(backpack_tier)
		_issue_starter_torch_if_needed()
		_sync_deployable_mirror()
		_sync_current_weapon_from_hotbar()
	call_deferred("_rebuild_base_flows", false, false, true)
	player_position = grid.cell_to_world(grid.core_cell + Vector2i(-1, 0))
	if not _terrain_preloaded and not load_saved_run:
		grid.activate_prepare_zone()
		_ensure_boot_render_window()
	elif _terrain_preloaded and not load_saved_run:
		grid.activate_prepare_zone()
		_ensure_boot_render_window()
		grid.process_region_preload_budget(BOOT_REGION_PRELOAD_CAP)
		if _pending_suit_alert and (operator_onboard == null or operator_onboard.is_done()):
			discovery_alert = "COMMAND // YOU'RE IN THE NEST // SURVIVE AND PUSH OUTWARD"
			discovery_alert_time = 5.0
	active_player_region = grid.region_for_cell(grid.world_to_cell(player_position))
	hive_awareness.register_prepared_region(active_player_region, false)
	_bind_visual_layers()
	_configure_camera()
	cave_texture = _load_png_texture(CAVE_TEXTURE_PATH)
	hive_material = _load_png_texture(HIVE_MATERIAL_PATH)
	tunnel_material = _load_png_texture(TUNNEL_MATERIAL_PATH)
	bunker_material = _load_png_texture(BUNKER_MATERIAL_PATH)
	crystal_material = _load_png_texture(CRYSTAL_MATERIAL_PATH)
	foundry_material = _load_png_texture(FOUNDRY_MATERIAL_PATH)
	sulfur_material = _load_png_texture(SULFUR_MATERIAL_PATH)
	iron_material = _load_png_texture(IRON_MATERIAL_PATH)
	formation_materials.clear()
	for material_id: int in FORMATION_MATERIAL_PATHS:
		formation_materials[material_id] = _load_png_texture(FORMATION_MATERIAL_PATHS[material_id])
	patch_backing_cache.clear()
	_cache_terrain_backing_colors()
	_reset_render_caches(true)
	_load_mob_textures()
	_load_player_and_shop_textures()
	_load_combat_textures()
	_load_ui_textures()
	_load_turret_textures()
	_load_world_textures()
	_validate_runtime_assets()
	_build_pause_panel()
	_build_realm_archive_panel()
	_build_game_over_panel()
	_build_sleep_overlay()
	_build_core_base_panel()
	_build_foundry_panel()
	_build_chest_panel()
	_build_backpack_panel()
	if load_saved_run:
		saved_run_loaded = _load_run()
		if saved_run_loaded:
			_apply_recovery_journal()
			if _terrain_preloaded:
				_mark_minimap_dirty(0.0)
				if minimap_cache_dirty and minimap_rebuild_cooldown <= 0.0:
					_rebuild_minimap_cache()
	_register_sector(grid.world_to_cell(player_position), false)
	_rebuild_player_armor_multipliers()
	_sync_hud_motion_displays()
	_bootstrap_stream_visuals()
	if not load_saved_run:
		_update_onboard()
	_queue_visual_redraw(true)


func _bootstrap_stream_visuals() -> void:
	if not is_instance_valid(world_layer) or grid == null:
		return
	_ensure_boot_render_window()
	_sync_terrain_chunk_layers()
	var stream_regions: Dictionary = _active_stream_regions()
	_terrain_draw_stream_regions = stream_regions.duplicate()
	# Do not synchronously build even one decorative region at run start. Historical
	# profiling put full prop/formation cache construction in the 100ms-class when
	# several regions were involved, and DEV009 still reported early pre-combat
	# spikes. Active terrain is lean; paused/full-quality refinement builds visual
	# caches on demand when the player is already UI-frozen.
	var focus_cell := grid.world_to_cell(player_position)
	for region: Vector2i in _stream_regions_near(focus_cell, stream_regions, BOOT_TERRAIN_FLUSH_BUDGET):
		_queue_terrain_region_redraw(region, true)
		_redraw_terrain_chunk_region(region)
	_ensure_undrawn_stream_chunks_queued()
	_boot_terrain_drain_active = terrain_chunk_redraw_queue.size() > BOOT_TERRAIN_DRAIN_UNTIL
	_mark_visual_dirty(VIS_DIRTY_ALL)
	_last_camera_center = _effective_camera_center()


func _bind_visual_layers() -> void:
	world_layer = get_node("WorldLayer") as RenderLayerScript
	actor_layer = get_node("ActorLayer") as RenderLayerScript
	effects_layer = get_node("EffectsLayer") as RenderLayerScript
	lighting_layer = get_node("LightingLayer") as RenderLayerScript
	hud_draw = get_node("HUDLayer/HUDDraw") as RenderLayerScript
	overlay_root = get_node("HUDLayer/OverlayRoot") as Control
	var interface_scale := DisplaySettingsScript.overlay_scale()
	overlay_root.scale = Vector2.ONE * interface_scale
	overlay_root.position = VIEW_SIZE * (1.0 - interface_scale) * 0.5
	player_camera = get_node("PlayerCamera") as Camera2D
	if not grid.terrain_cell_changed.is_connected(_on_grid_terrain_cell_changed):
		grid.terrain_cell_changed.connect(_on_grid_terrain_cell_changed)
	world_layer.configure(_draw_world)
	terrain_mutation_layer = world_layer.get_node_or_null("TerrainMutationLayer") as RenderLayerScript
	if terrain_mutation_layer == null:
		terrain_mutation_layer = RenderLayerScript.new()
		terrain_mutation_layer.name = "TerrainMutationLayer"
		terrain_mutation_layer.z_index = 10
		world_layer.add_child(terrain_mutation_layer)
	terrain_mutation_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# The parent is now only a z-ordered container. Individual 8x8 mutation
	# sectors own persistent draw commands and are invalidated independently.
	terrain_mutation_layer.configure(Callable(), false)
	# Pixel art stays crisp even when actor/effect layers animate independently.
	world_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	effects_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lighting_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hud_draw.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	overlay_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor_layer.configure(_draw_actors)
	effects_layer.configure(_draw_effects)
	lighting_layer.configure(_draw_lighting)
	hud_draw.configure(_draw_hud)


func _configure_camera() -> void:
	player_camera.limit_left = -1000000000
	player_camera.limit_top = -1000000000
	player_camera.limit_right = 1000000000
	player_camera.limit_bottom = 1000000000
	player_camera.position = player_position.round()
	player_camera.make_current()
	total_survey_sectors = ceili(float(grid.width) / 12.0) * ceili(float(grid.height) / 12.0)


func _load_png_texture(resource_path: String) -> Texture2D:
	return TEXTURE_LOADER.load_png(resource_path)


func _load_player_and_shop_textures() -> void:
	player_textures.clear()
	for resource_path: String in PLAYER_STYLE_PATHS:
		player_textures.append(_load_png_texture(resource_path))
	player_direction_textures.clear()
	player_active_direction_textures.clear()
	for style_slug: String in PLAYER_STYLE_SLUGS:
		for direction_name: String in PLAYER_DIRECTION_NAMES:
			var direction_key := "%s_%s" % [style_slug, direction_name]
			var texture: Texture2D = _load_png_texture("res://assets/art/player/%s.png" % direction_key)
			player_direction_textures[direction_key] = texture
			var active_key := "%s_%s_active" % [style_slug, direction_name]
			var active_texture: Texture2D = _load_png_texture("res://assets/art/player/%s.png" % active_key)
			if active_texture != null:
				player_active_direction_textures[direction_key] = active_texture
			else:
				player_active_direction_textures[direction_key] = player_direction_textures[direction_key]
	shop_icons.clear()
	for icon_name: String in SHOP_ICON_NAMES:
		shop_icons[icon_name] = _load_png_texture("res://assets/art/shop/%s.png" % icon_name)


func _load_ui_textures() -> void:
	ui_textures.clear()
	for texture_id: String in UI_TEXTURE_NAMES:
		var texture := _load_png_texture("res://assets/art/ui/%s.png" % texture_id)
		if texture != null:
			ui_textures[texture_id] = texture


func _ui_texture(texture_id: String) -> Texture2D:
	return ui_textures.get(texture_id)


func _draw_ui_texture_rect(canvas: CanvasItem, texture_id: String, rect: Rect2, modulate: Color = Color.WHITE) -> bool:
	var texture: Texture2D = _ui_texture(texture_id)
	if texture == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return false
	canvas.draw_texture_rect(texture, rect, false, modulate)
	return true


func _draw_ui_nine_patch(canvas: CanvasItem, texture_id: String, rect: Rect2, margin: float = 8.0, modulate: Color = Color.WHITE) -> bool:
	var texture: Texture2D = _ui_texture(texture_id)
	if texture == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return false
	var source_size := texture.get_size()
	var margin_x := minf(margin, minf(source_size.x * 0.33, rect.size.x * 0.5))
	var margin_y := minf(margin, minf(source_size.y * 0.33, rect.size.y * 0.5))
	var source_x := [0.0, margin_x, source_size.x - margin_x, source_size.x]
	var source_y := [0.0, margin_y, source_size.y - margin_y, source_size.y]
	var target_x := [rect.position.x, rect.position.x + margin_x, rect.end.x - margin_x, rect.end.x]
	var target_y := [rect.position.y, rect.position.y + margin_y, rect.end.y - margin_y, rect.end.y]
	for row in range(3):
		for column in range(3):
			var source_rect := Rect2(
				Vector2(source_x[column], source_y[row]),
				Vector2(source_x[column + 1] - source_x[column], source_y[row + 1] - source_y[row])
			)


			var target_rect := Rect2(
				Vector2(target_x[column], target_y[row]),
				Vector2(target_x[column + 1] - target_x[column], target_y[row + 1] - target_y[row])
			)
			canvas.draw_texture_rect_region(texture, target_rect, source_rect, modulate)
	return true


func _draw_ui_three_slice(canvas: CanvasItem, texture_id: String, rect: Rect2, cap_width: float = 6.0, modulate: Color = Color.WHITE) -> bool:
	var texture: Texture2D = _ui_texture(texture_id)
	if texture == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return false
	var source_size := texture.get_size()
	var source_cap := minf(cap_width, source_size.x * 0.33)
	var target_cap := minf(source_cap, rect.size.x * 0.5)
	var source_x := [0.0, source_cap, source_size.x - source_cap, source_size.x]
	var target_x := [rect.position.x, rect.position.x + target_cap, rect.end.x - target_cap, rect.end.x]
	for column in range(3):
		canvas.draw_texture_rect_region(
			texture,
			Rect2(Vector2(target_x[column], rect.position.y), Vector2(target_x[column + 1] - target_x[column], rect.size.y)),
			Rect2(Vector2(source_x[column], 0.0), Vector2(source_x[column + 1] - source_x[column], source_size.y)),
			modulate
		)
	return true


func _draw_hud_meter_bar(
	canvas: CanvasItem,
	bar_rect: Rect2,
	ratio: float,
	fill_color: Color,
	flash_color: Color = Color.TRANSPARENT,
	flash_alpha: float = 0.0,
	texture_id: String = ""
) -> void:
	var fill_ratio := clampf(ratio, 0.0, 1.0)
	var inner := Rect2(bar_rect.position + Vector2(1, 1), Vector2(maxf(0.0, bar_rect.size.x - 2.0), maxf(0.0, bar_rect.size.y - 2.0)))
	if not USE_IMPORTED_HUD_SKINS or texture_id.is_empty() or not _draw_ui_three_slice(canvas, texture_id, bar_rect):
		canvas.draw_rect(bar_rect, Color("142a31"))
		canvas.draw_rect(Rect2(inner.position, Vector2(inner.size.x * fill_ratio, inner.size.y)), fill_color)
	elif fill_ratio < 1.0:
		var empty_start := inner.position.x + inner.size.x * fill_ratio
		canvas.draw_rect(
			Rect2(Vector2(empty_start, inner.position.y), Vector2(inner.end.x - empty_start, inner.size.y)),
			Color(0.025, 0.06, 0.07, 0.94)
		)
	if flash_alpha > 0.0:
		canvas.draw_rect(bar_rect, Color(flash_color, flash_alpha), false, 1.0)


func _hud_glyph_texture_id(glyph: String) -> String:
	match glyph:
		"core":
			return "hud_icon_crosshair"
		"foundry":
			return "hud_icon_factory"
		"vault":
			return "hud_icon_briefcase"
		"warning":
			return "hud_icon_warning"
		"pack":
			return "hud_icon_briefcase"
	return ""


func _crosshair_reticle_texture_id() -> String:
	var placing := build_mode
	var mining := _primary_break_held() or mining_beam_valid or (operator_loadout != null and operator_loadout.is_cutter_selected() and not placing)
	return CombatVfxScript.reticle_texture_id(placing, mining, current_weapon)


func _load_combat_textures() -> void:
	combat_textures.clear()
	if not USE_IMPORTED_COMBAT_FX:
		return
	for texture_id: String in CombatVfxScript.all_texture_names():
		var texture: Texture2D = _load_png_texture("res://assets/art/combat/%s.png" % texture_id)
		if texture != null:
			combat_textures[texture_id] = texture


func _validate_runtime_assets() -> void:
	runtime_asset_failures = _runtime_asset_failures()
	runtime_assets_valid = runtime_asset_failures.is_empty()
	if runtime_assets_valid:
		print("CRAWL_BRAWL_ASSETS_OK")
		return
	for failure: String in runtime_asset_failures:
		push_error(failure)


func _runtime_asset_failures() -> PackedStringArray:
	var failures: PackedStringArray = PackedStringArray()
	var terrain: Array[Texture2D] = [
		cave_texture, hive_material, tunnel_material, bunker_material,
		crystal_material, foundry_material, sulfur_material, iron_material,
	]
	for index: int in range(terrain.size()):
		var texture: Texture2D = terrain[index]
		if texture == null:
			failures.append("Terrain atlas %d failed to load" % index)
		elif texture == cave_texture:
			if texture.get_width() % CAVE_MACRO_SIZE != 0 or texture.get_height() % CAVE_MACRO_SIZE != 0:
				failures.append("Cave atlas is not aligned to %dpx macro patches" % CAVE_MACRO_SIZE)
		elif texture.get_width() % MATERIAL_MACRO_SIZE != 0 or texture.get_height() % MATERIAL_MACRO_SIZE != 0:
			failures.append("Terrain atlas %d is not aligned to %dpx macro patches" % [index, MATERIAL_MACRO_SIZE])
	for material_id: int in range(RealmVisualStyleScript.MATERIAL_IRON + 1):
		var formation_texture: Texture2D = formation_materials.get(material_id)
		if formation_texture == null:
			failures.append("Formation atlas %d failed to load" % material_id)
		elif formation_texture.get_width() != 320 or formation_texture.get_height() != 320:
			failures.append("Formation atlas %d must be a 320px 10x10 macro bank" % material_id)
	for style_index: int in range(PLAYER_STYLE_PATHS.size()):
		if style_index >= player_textures.size() or player_textures[style_index] == null:
			failures.append("Missing player style texture: %s" % PLAYER_STYLE_PATHS[style_index])
	for style_slug: String in PLAYER_STYLE_SLUGS:
		for direction_name: String in PLAYER_DIRECTION_NAMES:
			var direction_key := "%s_%s" % [style_slug, direction_name]
			if player_direction_textures.get(direction_key) == null:
				failures.append("Missing player direction texture: %s" % direction_key)
			if player_active_direction_textures.get(direction_key) == null:
				failures.append("Missing player active direction texture: %s" % direction_key)
	for icon_name: String in SHOP_ICON_NAMES:
		if shop_icons.get(icon_name) == null:
			failures.append("Missing shop icon: %s" % icon_name)
	for role: int in MOB_TEXTURE_PATHS:
		if mob_textures.get(role) == null:
			failures.append("Missing mob texture for role %d" % role)
	for biome_id: int in range(BiomeBestiaryScript.BIOME_SLUGS.size()):
		for archetype: int in range(BiomeBestiaryScript.ARCHETYPE_COUNT):
			var resource_path := BiomeBestiaryScript.texture_path(biome_id, archetype)
			if biome_mob_textures.get(resource_path) == null:
				failures.append("Missing biome mob texture: %s" % resource_path)
	var player_chroma_spill := _player_chroma_spill_pixels()
	if player_chroma_spill > 0:
		failures.append("Player sprites retain %d magenta-background spill pixels" % player_chroma_spill)
	for build_kind: int in TURRET_TEXTURE_PATHS:
		if turret_textures.get(build_kind) == null:
			failures.append("Missing turret texture for build kind %d" % build_kind)
	for texture_id: String in WORLD_TEXTURE_PATHS:
		if world_textures.get(texture_id) == null:
			failures.append("Missing world texture: %s" % texture_id)
	for texture_id: String in UI_TEXTURE_NAMES:
		if ui_textures.get(texture_id) == null:
			failures.append("Missing UI texture: %s" % texture_id)
	if USE_IMPORTED_COMBAT_FX:
		for texture_id: String in CombatVfxScript.all_texture_names():
			if combat_textures.get(texture_id) == null:
				failures.append("Missing combat texture: %s" % texture_id)
		for weapon_id: int in range(CombatVfxScript.HELD_TEXTURE_BY_WEAPON.size()):
			var held_id: String = CombatVfxScript.held_weapon_texture_id(weapon_id)
			var held_texture: Texture2D = combat_textures.get(held_id)
			if held_texture == null:
				failures.append("Missing held weapon texture: %s" % held_id)
			elif held_texture.get_width() != int(CombatVfxScript.HELD_WEAPON_CANVAS.x) or held_texture.get_height() != int(CombatVfxScript.HELD_WEAPON_CANVAS.y):
				failures.append("Held weapon %s must be 24x16, got %dx%d" % [held_id, held_texture.get_width(), held_texture.get_height()])
			elif not _texture_has_visible_alpha(held_texture):
				failures.append("Held weapon %s has no visible alpha" % held_id)
		for tier: int in range(1, 6):
			for direction_name: String in CombatVfxScript.MINING_GUN_DIRECTIONS:
				var mining_id := CombatVfxScript.mining_gun_texture_id(tier, direction_name)
				var mining_texture: Texture2D = combat_textures.get(mining_id)
				if mining_texture == null:
					failures.append("Missing mining gun texture: %s" % mining_id)
				elif mining_texture.get_width() != 32 or mining_texture.get_height() != 32:
					failures.append("Mining gun %s must be 32x32, got %dx%d" % [mining_id, mining_texture.get_width(), mining_texture.get_height()])
				elif not _texture_has_visible_alpha(mining_texture):
					failures.append("Mining gun %s has no visible alpha" % mining_id)
	return failures


func _texture_has_visible_alpha(texture: Texture2D) -> bool:
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return false
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.05:
				return true
	return false


func _is_player_chroma_spill(color: Color) -> bool:
	if color.a <= 0.047:
		return false
	var red := color.r * 255.0
	var green := color.g * 255.0
	var blue := color.b * 255.0
	return (
		red >= 20.0
		and blue >= 20.0
		and green <= minf(red, blue) * 0.78
		and minf(red, blue) - green >= 8.0
		and absf(red - blue) <= 108.0
	)


func _player_chroma_spill_pixels() -> int:
	var count := 0
	var textures: Array[Texture2D] = []
	textures.append_array(player_textures)
	for texture: Texture2D in player_direction_textures.values():
		textures.append(texture)
	for texture: Texture2D in player_active_direction_textures.values():
		textures.append(texture)
	for texture: Texture2D in textures:
		if texture == null:
			continue
		var image := texture.get_image()
		if image == null or image.is_empty():
			continue
		for y: int in range(image.get_height()):
			for x: int in range(image.get_width()):
				if not _is_player_chroma_spill(image.get_pixel(x, y)):
					continue
				var edge_connected := false
				for offset: Vector2i in [
					Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
					Vector2i(-1, 0), Vector2i(1, 0),
					Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
				]:
					var neighbor := Vector2i(x, y) + offset
					if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= image.get_width() or neighbor.y >= image.get_height() or image.get_pixelv(neighbor).a <= 0.047:
						edge_connected = true
						break
				if edge_connected:
					count += 1
	return count


func _combat_texture(texture_id: String) -> Texture2D:
	return combat_textures.get(texture_id)


func _draw_oriented_combat_sprite(
	canvas: CanvasItem,
	texture: Texture2D,
	position: Vector2,
	direction: Vector2,
	size: Vector2,
	modulate: Color = Color.WHITE,
	angle_override: float = INF
) -> void:
	if texture == null:
		return
	var angle := angle_override
	if not is_finite(angle):
		angle = direction.angle() if direction.length_squared() > 0.0001 else 0.0
	canvas.draw_set_transform(position, angle, Vector2.ONE)
	canvas.draw_texture_rect(texture, Rect2(-size * 0.5, size), false, modulate)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _projectile_texture_for_bullet(bullet: Bullet) -> Texture2D:
	return _combat_texture(_projectile_texture_id_for_bullet(bullet))


func _projectile_texture_id_for_bullet(bullet: Bullet) -> String:
	if bullet.enemy_round:
		return _enemy_projectile_part_texture_id(bullet, "glob")
	match bullet.projectile_kind:
		"rocket":
			return "rocket_body"
		"laser_turret":
			return "laser_turret_head"
	if bullet.color.is_equal_approx(Color("ffd36b")):
		return "projectile_pistol"
	if bullet.color.is_equal_approx(Color("ffb85c")):
		return "projectile_shotgun"
	if bullet.color.is_equal_approx(Color("fff09a")):
		return "projectile_smg"
	if bullet.color.is_equal_approx(Color("a7f4ff")):
		return "projectile_railgun"
	if bullet.color.is_equal_approx(Color("82e9ff")):
		return "projectile_sentry"
	return "projectile_pistol"


func _enemy_projectile_part_texture_id(bullet: Bullet, part: String) -> String:
	var texture_id := ""
	match part:
		"trail":
			texture_id = bullet.texture_trail_id
		"splat":
			texture_id = bullet.texture_splat_id
		_:
			texture_id = bullet.texture_glob_id
	if texture_id.is_empty():
		texture_id = CombatVfxScript.enemy_projectile_texture_id(bullet.source_biome_id, part)
	if _combat_texture(texture_id) != null:
		return texture_id
	match part:
		"trail":
			return "acid_trail"
		"splat":
			return "acid_splat"
		_:
			return "acid_glob"


func _projectile_size_for_bullet(bullet: Bullet) -> Vector2:
	if bullet.enemy_round:
		if bullet.is_cyst:
			return Vector2(14, 14)
		if bullet.is_special_lob:
			return Vector2(12, 12)
		return Vector2(10, 10)
	match bullet.projectile_kind:
		"rocket":
			return Vector2(12, 6)
		"laser_turret":
			return Vector2(10, 4)
	if bullet.color.is_equal_approx(Color("ffb85c")):
		return Vector2(8, 8)
	if bullet.color.is_equal_approx(Color("a7f4ff")):
		return Vector2(16, 6)
	if bullet.color.is_equal_approx(Color("fff09a")):
		return Vector2(10, 6)
	return Vector2(12, 6)


func _projectile_trail_texture_for_bullet(bullet: Bullet) -> Texture2D:
	if bullet.enemy_round:
		return _combat_texture(_enemy_projectile_part_texture_id(bullet, "trail"))
	match bullet.projectile_kind:
		"rocket":
			return _combat_texture("rocket_trail")
		"laser_turret":
			return _combat_texture("laser_turret_trail")
	return null


func _load_mob_textures() -> void:
	mob_textures.clear()
	biome_mob_textures.clear()
	for role: int in MOB_TEXTURE_PATHS:
		var texture: Texture2D = _load_png_texture(str(MOB_TEXTURE_PATHS[role]))
		if texture != null:
			mob_textures[role] = texture
	for biome_id: int in range(BiomeBestiaryScript.BIOME_SLUGS.size()):
		for archetype: int in range(BiomeBestiaryScript.ARCHETYPE_COUNT):
			var resource_path := BiomeBestiaryScript.texture_path(biome_id, archetype)
			var biome_texture: Texture2D = _load_png_texture(resource_path)
			if biome_texture != null:
				biome_mob_textures[resource_path] = biome_texture


func _biome_for_cell(cell: Vector2i) -> int:
	return grid.region_biome(grid.region_for_cell(cell))


func _assign_spider_biome(spider: Spider, spawn_cell: Vector2i) -> void:
	spider.biome_id = _biome_for_cell(spawn_cell)


func _spider_trait_id(spider: Spider) -> String:
	return BiomeBestiaryScript.trait_id(spider.biome_id)


func _mob_texture_for_spider(spider: Spider) -> Texture2D:
	if spider.is_brood_carrier:
		return world_textures.get("brood_carrier")
	if BiomeBestiaryScript.uses_biome_texture(spider.role):
		var biome_id := spider.biome_id
		if biome_id < 0:
			biome_id = _biome_for_cell(grid.world_to_cell(spider.position))
		var resource_path := BiomeBestiaryScript.texture_path_for_role(biome_id, spider.role)
		var biome_texture: Texture2D = biome_mob_textures.get(resource_path)
		if biome_texture != null:
			return biome_texture
	return mob_textures.get(spider.role)


func _load_turret_textures() -> void:
	turret_textures.clear()
	for build_kind: int in TURRET_TEXTURE_PATHS:
		var texture: Texture2D = _load_png_texture(str(TURRET_TEXTURE_PATHS[build_kind]))
		if texture != null:
			turret_textures[build_kind] = texture


func _load_world_textures() -> void:
	world_textures.clear()
	for texture_id: String in WORLD_TEXTURE_PATHS:
		var texture: Texture2D = _load_png_texture(str(WORLD_TEXTURE_PATHS[texture_id]))
		if texture != null:
			world_textures[texture_id] = texture


func _mark_visual_dirty(mask: int) -> void:
	_visual_dirty_mask |= mask


func _queue_visual_redraw(force_all: bool = false) -> void:
	if force_all:
		_visual_dirty_mask = VIS_DIRTY_ALL
	if _visual_dirty_mask == 0 and terrain_chunk_redraw_queue.is_empty():
		return
	var dirty := _visual_dirty_mask
	_visual_dirty_mask = 0
	if dirty & VIS_DIRTY_WORLD or not terrain_chunk_redraw_queue.is_empty():
		if _primary_break_held():
			# Mutation patches make mining visually immediate. Only catch up a full
			# chunk when the queue is growing; otherwise coalesce until release.
			if terrain_mutation_patch_cells.is_empty() or terrain_chunk_redraw_queue.size() >= MINING_CHUNK_CATCHUP_QUEUE:
				_flush_mining_terrain_chunks(MINING_TERRAIN_REDRAW_BUDGET)
		elif _boot_terrain_drain_active:
			_flush_terrain_chunk_redraws(BOOT_TERRAIN_DRAIN_BUDGET)
			if terrain_chunk_redraw_queue.size() <= BOOT_TERRAIN_DRAIN_UNTIL:
				_boot_terrain_drain_active = false
		elif _terrain_redraw_force_burst:
			_terrain_redraw_force_burst = false
			# One chunk per frame — each raster is ~25ms; stacking burst redraws creates 100ms+ spikes.
			_flush_terrain_chunk_redraws(1)
		else:
			_flush_terrain_chunk_redraws(TERRAIN_CHUNK_REDRAW_BUDGET)
		if is_instance_valid(world_layer):
			world_layer.queue_redraw()
	if dirty & VIS_DIRTY_ACTORS and is_instance_valid(actor_layer):
		actor_layer.queue_redraw()
	if dirty & VIS_DIRTY_EFFECTS and is_instance_valid(effects_layer):
		effects_layer.queue_redraw()
	if dirty & VIS_DIRTY_LIGHTING and is_instance_valid(lighting_layer):
		if terrain_raster_scheduled_this_frame or ecology_tick_ran_this_frame:
			# Terrain, lighting and ecology were independent 40-50ms-class costs in
			# DEV009. Never stack lighting with either other heavy family; preserve the
			# dirty bit so lighting is serviced on the following available frame.
			_visual_dirty_mask |= VIS_DIRTY_LIGHTING
		else:
			lighting_layer.queue_redraw()
	if dirty & VIS_DIRTY_HUD and is_instance_valid(hud_draw):
		hud_draw.queue_redraw()


func _ensure_boot_render_window() -> void:
	_update_visible_render_window(true)
	if grid.stream_window_regions().is_empty():
		for center_value: Variant in _region_stream_centers():
			grid.ensure_region_for_cell(center_value, true)
		_update_visible_render_window(true)


func _render_cell_bounds(margin: int = 2) -> Rect2i:
	return _visible_cell_bounds(margin)


func _should_refresh_render_window() -> bool:
	if grid.stream_window_regions().is_empty():
		return true
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var player_region := grid.region_for_cell(player_cell)
	if player_region != _last_render_player_region:
		return true
	var camera_region := grid.region_for_cell(grid.world_to_cell(_effective_camera_center()))
	if camera_region != _last_render_camera_region:
		return true
	if player_moving and _stream_center_tick % 3 == 0:
		return true
	return false


func _render_window_signature(bounds: Rect2i, centers: Array) -> int:
	var signature := bounds.position.x
	signature = signature * 31 + bounds.position.y
	signature = signature * 31 + bounds.size.x
	signature = signature * 31 + bounds.size.y
	signature = signature * 31 + _region_stream_radius()
	for center_value: Variant in centers:
		var center: Vector2i = center_value
		signature = signature * 31 + center.x
		signature = signature * 31 + center.y
	return signature


func _update_visible_render_window(force: bool = false) -> int:
	if not force and not _should_refresh_render_window():
		return 0
	var bounds := _render_cell_bounds(2)
	var centers := _region_stream_centers()
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var signature := _render_window_signature(bounds, centers)
	if not force and signature == _last_render_signature and not grid.stream_window_regions().is_empty():
		return 0
	for center_value: Variant in centers:
		var center: Vector2i = center_value
		grid.ensure_region_for_cell(center, center != player_cell)
	var desired := grid.compute_desired_render_regions(
		bounds,
		centers,
		_region_stream_radius(),
		player_cell
	)
	var diff := grid.apply_render_window(desired, player_cell)
	_last_render_signature = signature
	_last_render_player_region = grid.region_for_cell(player_cell)
	_last_render_camera_region = grid.region_for_cell(grid.world_to_cell(_effective_camera_center()))
	return diff.added.size() + diff.removed.size()


func _prefetch_travel_regions(movement: Vector2) -> void:
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	grid.ensure_region_for_cell(player_cell)
	if movement.length_squared() > 0.01:
		var step_cell := player_cell + Vector2i(
			int(signf(movement.x)),
			int(signf(movement.y))
		)
		if step_cell != player_cell:
			grid.ensure_region_for_cell(step_cell, true)
		var ahead_cell := Vector2i(
			player_cell.x + int(round(movement.normalized().x * float(WorldGridScript.REGION_SIZE * 0.75))),
			player_cell.y + int(round(movement.normalized().y * float(WorldGridScript.REGION_SIZE * 0.75)))
		)
		if ahead_cell != player_cell:
			grid.ensure_region_for_cell(ahead_cell, true)


func _active_stream_regions() -> Dictionary:
	var stream_regions: Dictionary = grid.stream_window_regions()
	if not stream_regions.is_empty():
		return stream_regions
	_ensure_boot_render_window()
	return grid.stream_window_regions()


func _stream_regions_changed(previous: Dictionary, current: Dictionary) -> bool:
	if previous.size() != current.size():
		return true
	for region_value: Variant in current.keys():
		if not previous.has(region_value):
			return true
	return false


func _sync_terrain_chunk_layers() -> bool:
	if not is_instance_valid(world_layer) or grid == null:
		return false
	var stream_regions: Dictionary = _active_stream_regions()
	if stream_regions.is_empty():
		return false
	var changed := false
	for region_value: Variant in terrain_chunk_layers.keys():
		var region: Vector2i = region_value
		if stream_regions.has(region):
			continue
		var chunk_layer: RenderLayerScript = terrain_chunk_layers[region]
		if is_instance_valid(chunk_layer):
			chunk_layer.queue_free()
		terrain_chunk_layers.erase(region)
		terrain_chunk_redraw_queue.erase(region)
		terrain_chunk_committed.erase(region)
		terrain_chunk_lean_pending.erase(region)
		terrain_chunk_mutation_regions.erase(region)
		terrain_chunk_refine_queue.erase(region)
		terrain_chunk_force_quality.erase(region)
		_clear_terrain_mutations_for_region(region)
		changed = true
	var added_regions: Array[Vector2i] = []
	for region_value: Variant in stream_regions.keys():
		var region: Vector2i = region_value
		if terrain_chunk_layers.has(region):
			continue
		added_regions.append(region)
		var chunk_layer := RenderLayerScript.new()
		chunk_layer.name = "TerrainChunk_%d_%d" % [region.x, region.y]
		# Stay hidden until budgeted flush — add_child/first-visible would
		# otherwise raster many chunks in one draw frame (150ms+ gaps).
		chunk_layer.visible = false
		world_layer.add_child(chunk_layer)
		chunk_layer.configure(_draw_terrain_chunk.bind(region), false)
		terrain_chunk_layers[region] = chunk_layer
		_queue_terrain_region_redraw(region)
	if not added_regions.is_empty():
		# New render tickets must not force four already-committed neighbors through
		# another 24x24 raster. The shared backing layer hides border seams; actual
		# terrain mutations still invalidate their seam neighbors explicitly.
		changed = true
	if _stream_regions_changed(_last_stream_regions, stream_regions):
		changed = true
	_last_stream_regions = stream_regions.duplicate()
	_terrain_draw_stream_regions = stream_regions.duplicate()
	return changed


func _stream_regions_near(focus_cell: Vector2i, stream_regions: Dictionary, limit: int) -> Array[Vector2i]:
	var ranked: Array[Dictionary] = []
	for region_value: Variant in stream_regions.keys():
		var region: Vector2i = region_value
		var region_center := region * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
		ranked.append({"region": region, "distance": region_center.distance_squared_to(focus_cell)})
	ranked.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left["distance"]) < int(right["distance"])
	)
	var priority: Array[Vector2i] = []
	for entry: Dictionary in ranked.slice(0, maxi(limit, 1)):
		priority.append(entry["region"])
	return priority


func _ensure_undrawn_stream_chunks_queued() -> void:
	for region_value: Variant in _active_stream_regions().keys():
		var region: Vector2i = region_value
		if terrain_chunk_committed.get(region, false):
			continue
		if terrain_chunk_redraw_queue.has(region):
			continue
		_queue_terrain_region_redraw(region, true)


func _queue_terrain_region_redraw(region: Vector2i, force: bool = false) -> void:
	if not force and terrain_chunk_committed.get(region, false):
		return
	if terrain_chunk_layers.has(region):
		terrain_chunk_redraw_queue[region] = true
		_mark_visual_dirty(VIS_DIRTY_WORLD)
		_prune_terrain_redraw_queue()


func _terrain_seam_regions_for_cell(cell: Vector2i) -> Array[Vector2i]:
	var regions: Array[Vector2i] = []
	var region := grid.region_for_cell(cell)
	regions.append(region)
	var local_x := posmod(cell.x, WorldGridScript.REGION_SIZE)
	var local_y := posmod(cell.y, WorldGridScript.REGION_SIZE)
	if local_x == 0:
		regions.append(region + Vector2i.LEFT)
	elif local_x == WorldGridScript.REGION_SIZE - 1:
		regions.append(region + Vector2i.RIGHT)
	if local_y == 0:
		regions.append(region + Vector2i.UP)
	elif local_y == WorldGridScript.REGION_SIZE - 1:
		regions.append(region + Vector2i.DOWN)
	return regions


func _mark_terrain_cell_dirty(cell: Vector2i) -> void:
	# A single block mutation is rendered by the tiny overlay immediately. Do not
	# enqueue a 24x24 region raster in the mining frame (or the release frame).
	# The committed chunk remains underneath until an idle refinement folds the
	# overlay into it, exactly like a chunk mesh rebuild separated from block state.
	_queue_terrain_mutation_patch(cell)
	for region: Vector2i in _terrain_seam_regions_for_cell(cell):
		terrain_chunk_mutation_regions[region] = true
		_schedule_terrain_refine(region)


func _mark_all_terrain_chunks_dirty() -> void:
	terrain_chunk_committed.clear()
	terrain_chunk_mutation_regions.clear()
	terrain_chunk_refine_queue.clear()
	terrain_chunk_force_quality.clear()
	_clear_all_terrain_mutations()
	for region_value: Variant in terrain_chunk_layers.keys():
		terrain_chunk_redraw_queue[region_value] = true
	_terrain_redraw_force_burst = true


func _mark_breach_terrain_dirty(breach_cell: Vector2i) -> void:
	for region: Vector2i in _terrain_seam_regions_for_cell(breach_cell):
		terrain_chunk_committed.erase(region)
		_queue_terrain_region_redraw(region, true)


func _register_first_contact(preferred_wall_cell: Vector2i = Vector2i(-1, -1)) -> void:
	if breached:
		return
	var seal := Vector2i(-1, -1)
	if preferred_wall_cell != Vector2i(-1, -1) and grid.is_start_chamber_wall(preferred_wall_cell):
		seal = preferred_wall_cell
	elif grid.is_start_chamber_wall(grid.tutorial_rock):
		seal = grid.tutorial_rock
	if seal == Vector2i(-1, -1):
		breached = true
		hive_awareness.register_activity("first_breach", grid.region_for_cell(grid.world_to_cell(player_position)))
		_arm_opening_contact()
		discovery_alert = "LANDING SEAL BREACHED // MOVEMENT IN THE TUNNELS // HOLD THE POCKET"
		discovery_alert_time = 5.0
		call_deferred("_rebuild_base_flows", false, false, true)
		return
	# Auto-open keeps the spawn↔core seal walkable; player-mined seals already FLOOR (no scrap here).
	if grid.can_mine(seal) and grid.open_cell(seal):
		grid.visited_regions[grid.region_for_cell(seal)] = true
		_on_terrain_cell_opened(seal)
	grid.establish_first_breach(seal)
	first_breach_cell = seal
	breached = true
	_mark_breach_terrain_dirty(seal)
	_mark_breach_terrain_dirty(grid.spawn_cell)
	hive_awareness.register_activity("first_breach", grid.region_for_cell(seal))
	_arm_opening_contact()
	discovery_alert = "LANDING SEAL BREACHED // MOVEMENT IN THE TUNNELS // HOLD THE POCKET"
	discovery_alert_time = 5.0
	terrain_flow_dirty = false
	terrain_flow_rebuild_cooldown = 0.0
	for region: Vector2i in grid.route_regions_for_flow(seal, grid.spawn_cell, 3).keys():
		_mark_flow_region_dirty(region)
	_mark_flow_region_dirty(grid.region_for_cell(seal))
	_mark_flow_region_dirty(grid.region_for_cell(grid.spawn_cell))
	call_deferred("_rebuild_base_flows", false, false, true)


func _opening_contact_complete() -> bool:
	if opening_contact_stage < OPENING_CONTACT_PACKS.size() or _hostile_near(COMBAT_UI_RANGE * 0.85):
		return false
	for request: Dictionary in pending_hostile_spawns:
		if str(request.get("source_tag", "")) == "opening_contact":
			return false
	return true


func _arm_opening_contact() -> void:
	if opening_contact_stage >= OPENING_CONTACT_PACKS.size():
		return
	opening_contact_timer = OPENING_CONTACT_DELAYS[opening_contact_stage]


func _update_opening_contact(step: float) -> void:
	if not breached or opening_contact_stage >= OPENING_CONTACT_PACKS.size():
		return
	if opening_contact_timer < 0.0:
		opening_contact_timer = OPENING_CONTACT_DELAYS[opening_contact_stage]
	opening_contact_timer = maxf(0.0, opening_contact_timer - maxf(0.0, step))
	if opening_contact_timer > 0.0:
		return
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var spawn_cell: Vector2i = _prepared_spider_spawn_cell_near(player_cell, 6, 13 + opening_contact_stage * 2, 0xCB12 + opening_contact_stage * 811)
	if spawn_cell == Vector2i(-1, -1):
		opening_contact_timer = 1.0
		return
	var pack_size: int = OPENING_CONTACT_PACKS[opening_contact_stage]
	_queue_broodling_pack(spawn_cell, pack_size, false, 9000 + opening_contact_stage * 31, "opening_contact")
	opening_contact_stage += 1
	if opening_contact_stage < OPENING_CONTACT_PACKS.size():
		opening_contact_timer = OPENING_CONTACT_DELAYS[opening_contact_stage]
		discovery_alert = "TUNNEL CONTACT // %d HOSTILES MOVING ON THE LANDING POCKET" % pack_size
	else:
		opening_contact_timer = -1.0
		discovery_alert = "SECOND CONTACT INBOUND // BREAK THEM THEN STABILIZE THE POCKET"
	discovery_alert_time = 4.0


func _refresh_mining_beam_regions() -> void:
	_mining_beam_regions.clear()
	if aim_direction.length_squared() <= 0.01:
		return
	var origin := _player_muzzle_position(true)
	var max_distance := _mining_beam_reach()
	var distance := 0.0
	while distance <= max_distance:
		var probe := origin + aim_direction * distance
		_mining_beam_regions[grid.region_for_cell(grid.world_to_cell(probe))] = true
		distance += float(WorldGridScript.REGION_SIZE) * 0.5


func _mining_redraw_priority_regions() -> Array[Vector2i]:
	var candidates: Dictionary = {}
	var player_region := grid.region_for_cell(grid.world_to_cell(player_position))
	candidates[player_region] = true
	for region_value: Variant in _mining_beam_regions.keys():
		candidates[region_value] = true
	if mine_target.x >= 0:
		for region: Vector2i in _terrain_seam_regions_for_cell(mine_target):
			candidates[region] = true
	elif mining_beam_valid:
		var beam_cell := grid.world_to_cell(mining_beam_end)
		for region: Vector2i in _terrain_seam_regions_for_cell(beam_cell):
			candidates[region] = true
	var ranked: Array[Dictionary] = []
	var focus_cell := mine_target if mine_target.x >= 0 else grid.world_to_cell(mining_beam_end if mining_beam_valid else player_position)
	for region_value: Variant in candidates.keys():
		var region: Vector2i = region_value
		if not terrain_chunk_redraw_queue.has(region):
			continue
		var region_center := region * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
		ranked.append({"region": region, "distance": region_center.distance_squared_to(focus_cell)})
	ranked.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left["distance"]) < int(right["distance"])
	)
	var priority: Array[Vector2i] = []
	for entry: Dictionary in ranked.slice(0, MINING_REDRAW_CANDIDATE_CAP):
		priority.append(entry["region"])
	return priority


func _terrain_region_visible_for_raster(region: Vector2i, margin: int = 2) -> bool:
	var region_bounds := Rect2i(region * WorldGridScript.REGION_SIZE, Vector2i.ONE * WorldGridScript.REGION_SIZE)
	return region_bounds.intersects(_visible_cell_bounds(margin))


func _visible_terrain_raster_pending() -> bool:
	for region_value: Variant in terrain_chunk_redraw_queue.keys():
		var region: Vector2i = region_value
		if terrain_chunk_layers.has(region) and _terrain_region_visible_for_raster(region):
			return true
	return false


func _terrain_redraw_priority_regions(focus_cell: Vector2i, limit: int = MINING_REDRAW_CANDIDATE_CAP) -> Array[Vector2i]:
	var ranked: Array[Dictionary] = []
	for region_value: Variant in terrain_chunk_redraw_queue.keys():
		var region: Vector2i = region_value
		if not terrain_chunk_layers.has(region):
			continue
		# CanvasItem draw callbacks still execute GDScript even when their geometry is
		# off camera. Keep unseen chunks queued and raster them only when they enter
		# the actual camera envelope. This turns the 12-region render window into a
		# cache, not 12 eager 24x24 raster jobs.
		if not _terrain_region_visible_for_raster(region):
			continue
		var region_center := region * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
		ranked.append({"region": region, "distance": region_center.distance_squared_to(focus_cell)})
	ranked.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left["distance"]) < int(right["distance"])
	)
	var priority: Array[Vector2i] = []
	for entry: Dictionary in ranked.slice(0, maxi(limit, 1)):
		priority.append(entry["region"])
	return priority


func _prune_terrain_redraw_queue() -> void:
	if terrain_chunk_redraw_queue.size() <= MAX_TERRAIN_REDRAW_QUEUE:
		return
	var protected: Dictionary = {}
	for region: Vector2i in _mining_redraw_priority_regions():
		protected[region] = true
	var focus_cell := mine_target if mine_target.x >= 0 else grid.world_to_cell(player_position)
	var ranked: Array[Dictionary] = []
	for region_value: Variant in terrain_chunk_redraw_queue.keys():
		var region: Vector2i = region_value
		if protected.has(region):
			continue
		if not terrain_chunk_layers.has(region):
			terrain_chunk_redraw_queue.erase(region)
			continue
		var region_center := region * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
		ranked.append({"region": region, "distance": region_center.distance_squared_to(focus_cell)})
	ranked.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left["distance"]) > int(right["distance"])
	)
	while terrain_chunk_redraw_queue.size() > MAX_TERRAIN_REDRAW_QUEUE and not ranked.is_empty():
		var region: Vector2i = ranked[0]["region"]
		ranked.remove_at(0)
		if protected.has(region):
			continue
		terrain_chunk_redraw_queue.erase(region)


func _should_lean_terrain_chunk_draw(queue_size_including_self: int) -> bool:
	# Active-play chunk commits are always lean. A single newly-visible region used
	# to take the full decorated raster path while the player stood still, which
	# explains pre-combat 100ms-class stalls even with zero enemies. Full-quality
	# decoration is now *only* requested explicitly by _service_terrain_refinements()
	# while gameplay is already frozen behind a menu/pause/terminal.
	return true


func _redraw_terrain_chunk_region(region: Vector2i) -> void:
	# Capture lean BEFORE erase — draw runs later when queue no longer includes this region.
	var queue_size := terrain_chunk_redraw_queue.size()
	if terrain_chunk_force_quality.has(region):
		terrain_chunk_force_quality.erase(region)
		terrain_chunk_lean_pending[region] = false
	elif terrain_chunk_mutation_regions.has(region):
		terrain_chunk_mutation_regions.erase(region)
		terrain_chunk_lean_pending[region] = true
	else:
		terrain_chunk_lean_pending[region] = _should_lean_terrain_chunk_draw(maxi(queue_size, 1))
	terrain_chunk_redraw_queue.erase(region)
	terrain_chunk_committed.erase(region)
	var chunk_layer: RenderLayerScript = terrain_chunk_layers.get(region)
	if is_instance_valid(chunk_layer):
		# Reveal only when this chunk owns the redraw budget slot.
		terrain_raster_scheduled_this_frame = true
		chunk_layer.visible = true
		chunk_layer.queue_redraw()


func _terrain_mutation_sector_for_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(
		floori(float(cell.x) / float(TERRAIN_MUTATION_SECTOR_SIZE)),
		floori(float(cell.y) / float(TERRAIN_MUTATION_SECTOR_SIZE))
	)


func _ensure_terrain_mutation_sector_layer(sector: Vector2i) -> RenderLayerScript:
	var existing: RenderLayerScript = terrain_mutation_sector_layers.get(sector) as RenderLayerScript
	if is_instance_valid(existing):
		return existing
	var layer := RenderLayerScript.new()
	layer.name = "TerrainMutation_%d_%d" % [sector.x, sector.y]
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	terrain_mutation_layer.add_child(layer)
	layer.configure(_draw_terrain_mutation_sector.bind(sector), false)
	terrain_mutation_sector_layers[sector] = layer
	return layer


func _refresh_terrain_mutation_sector(sector: Vector2i) -> void:
	var sector_cells: Dictionary = terrain_mutation_sector_cells.get(sector, {})
	var layer: RenderLayerScript = terrain_mutation_sector_layers.get(sector) as RenderLayerScript
	if sector_cells.is_empty():
		terrain_mutation_sector_cells.erase(sector)
		terrain_mutation_sector_layers.erase(sector)
		if is_instance_valid(layer):
			layer.queue_free()
		return
	if not is_instance_valid(layer):
		layer = _ensure_terrain_mutation_sector_layer(sector)
	layer.queue_redraw()


func _erase_terrain_mutation_cell(cell: Vector2i, dirty_sectors: Dictionary) -> void:
	if not terrain_mutation_patch_cells.has(cell):
		return
	terrain_mutation_patch_cells.erase(cell)
	var sector := _terrain_mutation_sector_for_cell(cell)
	var sector_cells: Dictionary = terrain_mutation_sector_cells.get(sector, {})
	sector_cells.erase(cell)
	if sector_cells.is_empty():
		terrain_mutation_sector_cells.erase(sector)
	else:
		terrain_mutation_sector_cells[sector] = sector_cells
	dirty_sectors[sector] = true


func _clear_terrain_mutations_for_region(region: Vector2i) -> void:
	var dirty_sectors: Dictionary = {}
	for patch_cell_value: Variant in terrain_mutation_patch_cells.keys():
		var patch_cell: Vector2i = patch_cell_value
		if grid.region_for_cell(patch_cell) == region:
			_erase_terrain_mutation_cell(patch_cell, dirty_sectors)
	for sector_value: Variant in dirty_sectors.keys():
		var dirty_sector: Vector2i = sector_value
		_refresh_terrain_mutation_sector(dirty_sector)


func _clear_all_terrain_mutations() -> void:
	terrain_mutation_patch_cells.clear()
	terrain_mutation_sector_cells.clear()
	for layer_value: Variant in terrain_mutation_sector_layers.values():
		var layer: RenderLayerScript = layer_value as RenderLayerScript
		if is_instance_valid(layer):
			layer.queue_free()
	terrain_mutation_sector_layers.clear()


func _queue_terrain_mutation_patch(cell: Vector2i) -> void:
	# Cover the changed tile plus immediate neighbors so wall lips/edges update
	# without waiting for a 24x24 regional raster. Only touched 8x8 mutation
	# sectors redraw; older sectors keep their cached CanvasItem draw commands.
	var dirty_sectors: Dictionary = {}
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			var patch_cell := cell + Vector2i(ox, oy)
			if not grid.in_bounds(patch_cell):
				continue
			terrain_mutation_patch_cells[patch_cell] = true
			var sector := _terrain_mutation_sector_for_cell(patch_cell)
			var sector_cells: Dictionary = terrain_mutation_sector_cells.get(sector, {})
			sector_cells[patch_cell] = true
			terrain_mutation_sector_cells[sector] = sector_cells
			dirty_sectors[sector] = true
	if terrain_mutation_patch_cells.size() > TERRAIN_MUTATION_PATCH_MAX_CELLS:
		# World travel bounds the persistent mutation overlay to rendered regions.
		# Do not drop active patches (which would reveal stale chunk pixels); old
		# regions are discarded as soon as their render ticket leaves the window.
		var active_regions := _active_stream_regions()
		for patch_value: Variant in terrain_mutation_patch_cells.keys():
			var patch_cell: Vector2i = patch_value
			if not active_regions.has(grid.region_for_cell(patch_cell)):
				_erase_terrain_mutation_cell(patch_cell, dirty_sectors)
	for sector_value: Variant in dirty_sectors.keys():
		var dirty_sector: Vector2i = sector_value
		_refresh_terrain_mutation_sector(dirty_sector)


func _draw_terrain_mutation_sector(canvas: CanvasItem, sector: Vector2i) -> void:
	var sector_cells: Dictionary = terrain_mutation_sector_cells.get(sector, {})
	if sector_cells.is_empty() or grid == null:
		return
	var visible_bounds := _visible_cell_bounds(2)
	var previous_lean := _terrain_chunk_draw_lean
	_terrain_chunk_draw_lean = true
	for cell_value: Variant in sector_cells.keys():
		var cell: Vector2i = cell_value
		if not visible_bounds.has_point(cell) or not grid.in_bounds(cell):
			continue
		var rect := Rect2(Vector2(cell * grid.tile_size), Vector2.ONE * float(grid.tile_size))
		if grid.is_walkable(cell):
			_draw_floor_cell(canvas, cell, rect)
		elif grid.get_cell(cell) != WorldGridScript.BEDROCK:
			_draw_rock_cell(canvas, cell, rect)
		_draw_wall_edges_in_bounds(canvas, Rect2i(cell, Vector2i.ONE))
	_terrain_chunk_draw_lean = previous_lean


func _draw_terrain_mutation_patches(canvas: CanvasItem) -> void:
	# Compatibility/debug entrypoint. Runtime uses sector layers so new mining
	# mutations never replay the entire outstanding patch set.
	for sector_value: Variant in terrain_mutation_sector_cells.keys():
		var sector: Vector2i = sector_value
		_draw_terrain_mutation_sector(canvas, sector)


func _terrain_chunk_draw_committed(region: Vector2i, lean_draw: bool) -> void:
	# Once the underlying regional raster contains the new terrain, retire only the
	# mutation sectors that overlap that region. Other sectors keep their cached
	# draw commands and are not replayed.
	_clear_terrain_mutations_for_region(region)
	if lean_draw:
		_schedule_terrain_refine(region)


func _schedule_terrain_refine(region: Vector2i) -> void:
	if terrain_chunk_layers.has(region):
		terrain_chunk_refine_queue[region] = true


func _service_terrain_refinements(delta: float, ui_frozen: bool = false) -> void:
	terrain_refine_cooldown = maxf(0.0, terrain_refine_cooldown - delta)
	if terrain_refine_cooldown > 0.0 or terrain_chunk_refine_queue.is_empty():
		return
	# Full-quality chunk decoration costs enough to create visible frame spikes.
	# Active exploration/combat keeps the lean raster; refinement is serviced only
	# while a menu/pause/terminal already freezes gameplay.
	if not ui_frozen:
		return
	if not terrain_chunk_redraw_queue.is_empty() or _primary_break_held() or mining_beam_valid or player_moving:
		return
	var focus_region := grid.region_for_cell(grid.world_to_cell(player_position))
	var best_region := Vector2i.ZERO
	var best_distance: float = INF
	var found := false
	for region_value: Variant in terrain_chunk_refine_queue.keys():
		var region: Vector2i = region_value
		if not terrain_chunk_layers.has(region):
			terrain_chunk_refine_queue.erase(region)
			continue
		var distance: float = region.distance_squared_to(focus_region)
		if not found or distance < best_distance:
			best_region = region
			best_distance = distance
			found = true
	if not found:
		return
	terrain_chunk_refine_queue.erase(best_region)
	# Decorative caches are expensive to rebuild. Invalidate them only when the
	# low-priority full-quality pass actually runs, never in the mining frame.
	visual_prop_cache.erase(best_region)
	visual_formation_cache.erase(best_region)
	visual_landmark_cache.erase(best_region)
	terrain_chunk_force_quality[best_region] = true
	terrain_chunk_committed.erase(best_region)
	_queue_terrain_region_redraw(best_region, true)
	terrain_refine_cooldown = TERRAIN_REFINE_INTERVAL
	_mark_visual_dirty(VIS_DIRTY_WORLD)


func _flush_mining_terrain_chunks(max_chunks: int = MINING_TERRAIN_REDRAW_BUDGET) -> void:
	if terrain_chunk_redraw_queue.is_empty():
		return
	var priority := _mining_redraw_priority_regions()
	var redrawn := 0
	for region: Vector2i in priority:
		if redrawn >= maxi(max_chunks, 1):
			break
		if not terrain_chunk_redraw_queue.has(region):
			continue
		_redraw_terrain_chunk_region(region)
		redrawn += 1


func _flush_terrain_chunk_redraws(max_chunks: int) -> void:
	if terrain_chunk_redraw_queue.is_empty():
		return
	var focus_cell := grid.world_to_cell(player_position)
	var flush_budget := maxi(max_chunks, 1)
	var priority := _terrain_redraw_priority_regions(focus_cell, flush_budget)
	var redrawn := 0
	for region: Vector2i in priority:
		if redrawn >= flush_budget:
			break
		if not terrain_chunk_redraw_queue.has(region):
			continue
		_redraw_terrain_chunk_region(region)
		redrawn += 1


func _on_grid_terrain_cell_changed(cell: Vector2i) -> void:
	var mutation_start_us := Time.get_ticks_usec()
	_invalidate_visual_region(cell)
	if gameplay_telemetry != null:
		gameplay_telemetry.note_terrain_mutation(Time.get_ticks_usec() - mutation_start_us)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_inside_tree() and not game_over:
		set_paused(true)
	elif what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if gameplay_telemetry != null:
			gameplay_telemetry.shutdown()
			gameplay_telemetry = null


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		suppress_primary_fire_until_release = false
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		aim_uses_controller = false
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.35:
		aim_uses_controller = true


func _unhandled_input(event: InputEvent) -> void:
	if beta_teaser_active:
		if event.is_action_pressed("interact") or event.is_action_pressed("pause_game") or event.is_action_pressed("fire"):
			beta_teaser_active = false
			get_viewport().set_input_as_handled()
		return
	if sleeping:
		get_viewport().set_input_as_handled()
		return
	if using_realm_archive:
		if event.is_action_pressed("pause_game"):
			_close_realm_archive()
			get_viewport().set_input_as_handled()
		return
	if using_foundry:
		if event.is_action_pressed("pause_game") or event.is_action_pressed("interact") or event.is_action_pressed("inventory"):
			_close_foundry()
			get_viewport().set_input_as_handled()
		return
	if using_chest_index >= 0:
		if event.is_action_pressed("inventory") or event.is_action_pressed("pause_game") or event.is_action_pressed("interact"):
			_close_chest()
			get_viewport().set_input_as_handled()
		return
	if backpack_open:
		if event.is_action_pressed("inventory") or event.is_action_pressed("pause_game"):
			_close_backpack()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not game_over and not paused:
		if _try_handle_world_interaction_click(_world_position_from_viewport(event.position)):
			suppress_primary_fire_until_release = true
			get_viewport().set_input_as_handled()
			return
	if turret_selection_active:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _select_turret_at_world_position(_world_position_from_viewport(event.position)):
				_confirm_turret_upgrade()
			else:
				discovery_alert = "CLICK A MARKED TURRET // OR Q/E THEN F"
				discovery_alert_time = 4.0
		elif event.is_action_pressed("build_prev") or event.is_action_pressed("move_left"):
			_cycle_turret_selection(-1)
		elif event.is_action_pressed("build_next") or event.is_action_pressed("move_right"):
			_cycle_turret_selection(1)
		elif event.is_action_pressed("interact") or event.is_action_pressed("fire"):
			_confirm_turret_upgrade()
		elif event.is_action_pressed("pause_game"):
			_cancel_turret_selection()
		get_viewport().set_input_as_handled()
		return
	if using_core_base and (event.is_action_pressed("build_prev") or event.is_action_pressed("build_next")):
		_cycle_core_menu_page(-1 if event.is_action_pressed("build_prev") else 1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_released("inventory") and not paused and not game_over and not choosing_upgrade and not using_core_base and not using_foundry:
		if inventory_hold_time >= 0.0 and inventory_hold_time < 0.4:
			_open_backpack()
		inventory_hold_time = 0.0
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("interact") and not game_over:
		if using_core_base:
			_close_core_base()
		else:
			var nearby_merchant_index: int = _nearby_merchant_store()
			if nearby_merchant_index >= 0:
				_open_merchant_store(nearby_merchant_index)
			else:
				var nearby_shelter_index := _nearby_personal_base()
				if nearby_shelter_index >= 0:
					_try_rest_at_personal_base(nearby_shelter_index)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause_game") and not game_over:
		if using_core_base:
			_close_core_base()
			get_viewport().set_input_as_handled()
			return
		set_paused(not paused)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	terrain_raster_scheduled_this_frame = false
	ecology_tick_ran_this_frame = false
	_update_cursor_presentation()
	_update_hud_motion(delta)
	if beta_teaser_active:
		_queue_visual_redraw(true)
		return
	if sleeping:
		_update_sleep_sequence(delta)
		_queue_visual_redraw(true)
		return
	var contract_payout := 0
	var foundry_completed: Dictionary = {}
	if not paused and not game_over and not choosing_upgrade and not turret_selection_active:
		contract_payout = material_economy.tick_contract(delta)
		for structure_index in range(structures.size()):
			var structure: Structure = structures[structure_index]
			if structure.kind != BUILD_FOUNDRY or not _foundry_operational(structure_index):
				continue
			var batch_completed: Dictionary = FoundryUnitScript.tick(structure, material_economy, delta, true)
			for output_id: String in batch_completed.keys():
				foundry_completed[output_id] = int(foundry_completed.get(output_id, 0)) + int(batch_completed[output_id])
	if contract_payout > 0:
		_apply_scrap_delta(contract_payout, "contract_payout")
		discovery_alert = "CONTRACT REFINERY COMPLETE // +$%d CREDITS" % contract_payout
		discovery_alert_time = 4.0
		if using_core_base:
			_refresh_core_base_panel()
		_save_run()
	if not foundry_completed.is_empty():
		discovery_alert = "FOUNDRY BATCH BUFFERED // %s // COLLECT AT FACILITY" % _format_material_requirements(foundry_completed)
		discovery_alert_time = 3.0
		if using_foundry:
			foundry_action_message = discovery_alert
			_refresh_foundry_panel()
		elif using_core_base:
			_refresh_core_base_panel()
		_save_run()
	# The terminal freezes combat, not inventory suction. Pickups already inside
	# the player's magnet radius continue moving into the pack while shopping.
	if (using_core_base or using_foundry) and not paused and not game_over:
		if using_foundry:
			_refresh_foundry_live_progress()
		elif core_menu_page == "materials":
			foundry_ui_refresh_elapsed += delta
			if foundry_ui_refresh_elapsed >= 1.0:
				foundry_ui_refresh_elapsed = 0.0
				_refresh_materials_live_status()
		var pickup_count_before := pickups.size()
		_update_pickups(delta)
		if pickups.size() != pickup_count_before:
			if using_foundry:
				_refresh_foundry_panel()
			else:
				_refresh_core_base_panel()
			_save_run()
	if paused or backpack_open or game_over or choosing_upgrade or using_core_base or using_foundry or using_realm_archive or using_chest_index >= 0 or turret_selection_active:
		if _paused_ui_dirty:
			_mark_visual_dirty(VIS_DIRTY_HUD)
			_paused_ui_dirty = false
		_service_terrain_refinements(delta, true)
		_queue_visual_redraw()
		return
	_update_aim()
	_update_player(delta)
	if game_over:
		_mark_visual_dirty(VIS_DIRTY_HUD | VIS_DIRTY_ACTORS)
		_queue_visual_redraw()
		return
	_update_personal_base_cooldowns(delta)
	if sleeping:
		_queue_visual_redraw()
		return
	var streaming_started_us := Time.get_ticks_usec() if gameplay_telemetry != null and gameplay_telemetry.enabled else 0
	_update_region_streaming()
	if streaming_started_us > 0:
		gameplay_telemetry.note_streaming_update_cost(Time.get_ticks_usec() - streaming_started_us)
	_begin_hostile_spawn_frame()
	_drain_pending_hostile_spawns(1)
	_update_exploration()
	player_camera.position = player_position.round()
	_update_weapon_selection()
	_update_build_mode()
	_update_chest_interactions(delta)
	_update_torch_interactions()
	_update_mining(delta)
	_update_weapon(delta)
	if encounter_load_grace > 0.0:
		encounter_load_grace = maxf(0.0, encounter_load_grace - delta)
	var ecology_started_us := Time.get_ticks_usec() if gameplay_telemetry != null and gameplay_telemetry.enabled else 0
	_update_world_ecology(delta)
	if ecology_started_us > 0:
		gameplay_telemetry.note_ecology_update_cost(Time.get_ticks_usec() - ecology_started_us)
	discovery_alert_time = maxf(0.0, discovery_alert_time - delta)
	_combat_frame_tick += 1
	base_flow_rebuild_cooldown = maxf(0.0, base_flow_rebuild_cooldown - delta)
	player_flow_refresh_cooldown = maxf(0.0, player_flow_refresh_cooldown - delta)
	var enemy_update_started_us := Time.get_ticks_usec() if gameplay_telemetry != null and gameplay_telemetry.enabled else 0
	_update_enemies(delta)
	if enemy_update_started_us > 0:
		gameplay_telemetry.note_enemy_update_cost(Time.get_ticks_usec() - enemy_update_started_us)
	if gameplay_telemetry != null:
		gameplay_telemetry.tick_runtime(
			delta,
			_simulation_enemy_count(),
			_primary_break_held() or mining_beam_valid,
			grid.loaded_regions.size(),
			grid.stream_window_regions().size(),
			grid.region_preload_pending()
		)
	_update_onboard()
	_service_player_flow_refresh()
	_process_pending_brood_carriers()
	_end_hostile_spawn_frame()
	_update_structures(delta)
	_update_mecha_spiders(delta)
	_update_bullets(delta)
	_update_fire_patches(delta)
	_update_player_status(delta)
	combat_fx_phase = fmod(combat_fx_phase + delta, TAU)
	_update_pickups(delta)
	_update_recovery_cache(delta)
	_update_terrain_debounce(delta)
	_update_sparks(delta)
	_update_combat_impacts(delta)
	_update_xp_highlights(delta)
	shoot_cooldown = maxf(0.0, shoot_cooldown - delta)
	muzzle_flash = maxf(0.0, muzzle_flash - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	player_invulnerability = maxf(0.0, player_invulnerability - delta)
	damage_flash = maxf(0.0, damage_flash - delta)
	player_hit_time = maxf(0.0, player_hit_time - delta)
	sprint_trail_cooldown = maxf(0.0, sprint_trail_cooldown - delta)
	mining_feedback_time = maxf(0.0, mining_feedback_time - delta)
	mining_spark_cooldown = maxf(0.0, mining_spark_cooldown - delta)
	mining_impact_pulse = maxf(0.0, mining_impact_pulse - delta)
	if not enemies.is_empty() or muzzle_flash > 0.0 or player_slow_time > 0.0 or player_dot_time > 0.0:
		_mark_visual_dirty(VIS_DIRTY_ACTORS)
	if not bullets.is_empty() or not sparks.is_empty() or not fire_patches.is_empty() or not combat_impacts.is_empty() or chest_alert_time > 0.0:
		_mark_visual_dirty(VIS_DIRTY_EFFECTS)
	var camera_center := _effective_camera_center()
	var camera_cell := grid.world_to_cell(camera_center)
	var last_camera_cell := grid.world_to_cell(_last_camera_center)
	if camera_cell != last_camera_cell:
		_last_camera_center = camera_center
		_camera_stable_frames = 0
		_mark_visual_dirty(VIS_DIRTY_LIGHTING)
	else:
		_last_camera_center = camera_center
		_camera_stable_frames += 1
	var current_player_region := grid.region_for_cell(grid.world_to_cell(player_position))
	if current_player_region != _last_player_region:
		_last_player_region = current_player_region
		_mark_visual_dirty(VIS_DIRTY_LIGHTING)
	if player_moving and _combat_frame_tick % LIGHTING_PROP_THROTTLE_FRAMES == 0:
		_mark_visual_dirty(VIS_DIRTY_LIGHTING)
	# Mining beam/tool animation lives on effects/actor layers. Lighting is dirtied
	# by actual terrain mutations, not by holding the mining input.
	if build_mode or relocating_structure_index >= 0 or _should_draw_combat_crosshair():
		_mark_visual_dirty(VIS_DIRTY_EFFECTS)
	_service_terrain_refinements(delta)
	_queue_visual_redraw()


func _install_custom_cursor() -> void:
	# Runtime loading avoids a parse-time failure when a clean source checkout
	# has not generated its .godot import cache yet. The system cursor remains
	# usable if the optional custom cursor cannot be loaded.
	var cursor_resource: Resource = ResourceLoader.load(CURSOR_TEXTURE_PATH)
	var cursor_texture := cursor_resource as Texture2D
	if cursor_texture == null:
		return
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(2, 2))
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_POINTING_HAND, Vector2(2, 2))


func _update_cursor_presentation() -> void:
	var interface_open := paused or backpack_open or game_over or choosing_upgrade or using_core_base or using_foundry or using_chest_index >= 0 or turret_selection_active
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if interface_open or _has_nearby_world_click_target() else Input.MOUSE_MODE_HIDDEN


func _world_position_from_viewport(viewport_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * viewport_position


func _mouse_world_position() -> Vector2:
	return _world_position_from_viewport(get_viewport().get_mouse_position())


func _combat_pointer_world() -> Vector2:
	if aim_uses_controller:
		var reach := minf(72.0, _ray_terrain_distance(player_position, aim_direction, 72.0))
		return player_position + aim_direction * reach
	return _mouse_world_position()


func _update_aim() -> void:
	var previous := aim_direction
	var previous_mouse := _last_aim_mouse_world
	var stick := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if stick.length() > 0.25:
		aim_direction = stick.normalized()
		aim_uses_controller = true
	elif not aim_uses_controller:
		var mouse_world := _mouse_world_position()
		_last_aim_mouse_world = mouse_world
		var mouse_delta := mouse_world - player_position
		if mouse_delta.length_squared() > 0.01:
			aim_direction = mouse_delta.normalized()
	if aim_direction.distance_squared_to(previous) > 0.0001:
		_mark_visual_dirty(VIS_DIRTY_ACTORS | VIS_DIRTY_HUD | VIS_DIRTY_EFFECTS)
	elif not aim_uses_controller and _last_aim_mouse_world.distance_squared_to(previous_mouse) > 0.25:
		_mark_visual_dirty(VIS_DIRTY_EFFECTS)


func _update_player(delta: float) -> void:
	var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if movement.length() > 1.0:
		movement = movement.normalized()
	player_moving = movement.length() > 0.08
	player_move_direction = movement.normalized() if player_moving else Vector2.ZERO
	var wants_sprint := Input.is_action_pressed("sprint") and player_moving and sprint_energy > 0.0
	sprinting = wants_sprint
	if sprinting:
		sprint_energy = maxf(0.0, sprint_energy - 30.0 * delta)
		sprint_recovery_delay = 0.75
		if sprint_energy <= 0.0:
			sprinting = false
	else:
		sprint_recovery_delay = maxf(0.0, sprint_recovery_delay - delta)
		if sprint_recovery_delay <= 0.0:
			sprint_energy = minf(100.0, sprint_energy + 24.0 * delta)
	if player_moving:
		var previous_step_side: int = locomotion_step_side
		locomotion_phase = fmod(locomotion_phase + delta * (15.0 if sprinting else 9.0), TAU)
		locomotion_step_side = 1 if sin(locomotion_phase) >= 0.0 else -1
		if previous_step_side != 0 and previous_step_side != locomotion_step_side:
			var foot_normal := Vector2(-player_move_direction.y, player_move_direction.x)
			_burst(player_position - player_move_direction * 4.0 + foot_normal * float(locomotion_step_side) * 2.0, Color(0.43, 0.56, 0.58, 0.38), 2 if not sprinting else 4, 18.0 if not sprinting else 30.0)
	else:
		locomotion_step_side = 0
	if sprinting and sprint_trail_cooldown <= 0.0:
		sprint_trail_cooldown = 0.09
		var trail_direction := -movement.normalized()
		_burst(player_position + trail_direction * 5.0, Color(0.38, 0.86, 1.0, 0.72), 3, 24.0)
	var movement_speed := PLAYER_SPEED * (1.65 if sprinting else 1.0) * player_slow_mult
	var step := movement * movement_speed * delta
	_prefetch_travel_regions(movement)
	var previous_position := player_position
	player_position = _move_entity(player_position, step, PLAYER_BODY_RADIUS)
	if player_position.distance_squared_to(previous_position) > 0.25:
		_mark_visual_dirty(VIS_DIRTY_ACTORS)

	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
		var dash_direction := movement.normalized() if movement.length() > 0.1 else aim_direction
		for dash_step in range(7):
			var dash_candidate := player_position + dash_direction * 4.0
			if not _enemy_can_occupy(dash_candidate, PLAYER_BODY_RADIUS):
				break
			player_position = dash_candidate
		dash_cooldown = 1.15
		player_invulnerability = 0.28
		_burst(player_position, Color("6be6ff"), 12, 48.0)

	if player_health <= 0.0:
		_handle_player_death()


func _update_weapon_selection() -> void:
	## TAB/scroll/Q-E cycle the holster and exit build. 1-9 alone owns the build bar.
	if relocating_structure_index < 0:
		if Input.is_action_just_pressed("build_toggle") or Input.is_action_just_pressed("weapon_next") or Input.is_action_just_pressed("build_next"):
			_cycle_weapon(1)
			return
		if Input.is_action_just_pressed("weapon_prev") or Input.is_action_just_pressed("build_prev"):
			_cycle_weapon(-1)
			return
	if Input.is_action_just_pressed("hotbar_1"):
		_select_build_slot(0)
	elif Input.is_action_just_pressed("hotbar_2"):
		_select_build_slot(1)
	elif Input.is_action_just_pressed("hotbar_3"):
		_select_build_slot(2)
	elif Input.is_action_just_pressed("hotbar_4"):
		_select_build_slot(3)
	elif Input.is_action_just_pressed("hotbar_5"):
		_select_build_slot(4)
	elif Input.is_action_just_pressed("hotbar_6"):
		_select_build_slot(5)
	elif Input.is_action_just_pressed("hotbar_7"):
		_select_build_slot(6)
	elif Input.is_action_just_pressed("hotbar_8"):
		_select_build_slot(7)
	elif Input.is_action_just_pressed("hotbar_9"):
		_select_build_slot(8)


func _select_build_slot(index: int) -> void:
	if build_intent and operator_loadout.hotbar_index == index:
		build_intent = false
		_mark_visual_dirty(VIS_DIRTY_HUD | VIS_DIRTY_EFFECTS)
		return
	if operator_loadout.set_hotbar_index(index):
		build_intent = true
		_mark_visual_dirty(VIS_DIRTY_HUD | VIS_DIRTY_EFFECTS)


func _cycle_weapon(direction: int) -> void:
	operator_loadout.cycle_holster(direction)
	build_intent = false
	_sync_current_weapon_from_hotbar()
	_mark_visual_dirty(VIS_DIRTY_HUD | VIS_DIRTY_EFFECTS)


func _update_build_mode() -> void:
	## Minecraft use/place path. TAB cycles holster; relocate cancel wins.
	if relocating_structure_index >= 0:
		if relocating_structure_index >= structures.size():
			_cancel_structure_relocation("RELOCATION LOST // STRUCTURE DESTROYED")
			return
		relocation_target = _pointed_cell(_mining_beam_reach())
		_mark_visual_dirty(VIS_DIRTY_EFFECTS)
		if Input.is_action_just_pressed("build_toggle"):
			_cancel_structure_relocation("RELOCATION CANCELLED // STRUCTURE UNCHANGED")
		elif Input.is_action_just_pressed("mine"):
			suppress_primary_fire_until_release = true
			_place_relocated_structure(relocation_target)
		return
	var stack := _hotbar_active_stack()
	if operator_loadout.is_cutter_selected() and (
		(str(stack.get("kind", "")) == OperatorLoadoutScript.KIND_BUILD and int(stack.get("build_kind", -1)) == BUILD_HEAVY_DOORWAY)
		or (str(stack.get("kind", "")) == OperatorLoadoutScript.KIND_DEPLOYABLE and str(stack.get("id", "")) == "heavy_doorway")
	):
		if Input.is_action_just_pressed("reload"):
			build_orientation = not build_orientation
			_mark_visual_dirty(VIS_DIRTY_EFFECTS)

	var previous_build_target := build_target
	build_target = _pointed_cell(48.0)
	var want_build := build_intent and _hotbar_is_placeable()
	if want_build:
		selected_build = _selected_build_from_hotbar()
	if want_build != build_mode or (want_build and build_target != previous_build_target):
		_mark_visual_dirty(VIS_DIRTY_EFFECTS)
	build_mode = want_build
	if Input.is_action_just_pressed("mine"):
		_handle_use_action()


func _handle_use_action() -> void:
	## RMB/LT: interact target first, else place from hotbar while build setup is live.
	if _try_use_world_target():
		return
	if relocating_structure_index >= 0 or not build_mode:
		return
	var stack := _hotbar_active_stack()
	if not OperatorLoadoutScript.is_placeable(stack):
		return
	selected_build = _selected_build_from_hotbar()
	if str(stack.get("kind", "")) == OperatorLoadoutScript.KIND_BLOCK:
		_place_block_from_hotbar(build_target)
		return
	_place_structure(build_target)


func _try_use_world_target() -> bool:
	## Prefer F-style interactables under aim/near player.
	if _try_handle_world_interaction_click(player_position + aim_direction * 24.0):
		return true
	return false


func _available_build_types() -> Array[int]:
	var result: Array[int] = [BUILD_BARRICADE, BUILD_SENTRY]
	if foundry_kit_available and kit_count("foundry") <= 0:
		if grant_kit("foundry", 1) <= 0:
			foundry_kit_available = false
	if kit_count("foundry") > 0:
		result.append(BUILD_FOUNDRY)
	for build_kind: int in [BUILD_HEAVY_DOORWAY, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER,
			BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER, BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM,
			BUILD_CHEST_LARGE, BUILD_LAND_MINE, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET, BUILD_PERSONAL_BASE,
			BUILD_TORCH, BUILD_MERCHANT_STORE]:
		var stock_id: String = str(BUILD_STOCK_KEYS[build_kind])
		if bool(construction_unlocks.get(stock_id, false)):
			result.append(build_kind)
	return result


func _cycle_build_selection(direction: int) -> void:
	var available: Array[int] = _available_build_types()
	var current_index: int = available.find(selected_build)
	if current_index < 0:
		current_index = 0
	selected_build = available[posmod(current_index + direction, available.size())]


func _build_name(build_kind: int) -> String:
	var names := {
		BUILD_BARRICADE: "SCRAP BARRICADE", BUILD_SENTRY: "SENTRY",
		BUILD_GRANITE_BARRIER: "GRANITE BARRIER", BUILD_STEEL_BARRIER: "STEEL BARRIER",
		BUILD_REINFORCED_BARRIER: "REINFORCED BARRIER",
		BUILD_BLAST_BARRIER: "BLAST BARRIER", BUILD_LAND_MINE: "LAND MINE",
		BUILD_ROCKET_TURRET: "ROCKET TURRET", BUILD_LASER_TURRET: "LASER TURRET",
		BUILD_CHEST_SMALL: "SMALL CHEST", BUILD_CHEST_MEDIUM: "MEDIUM CHEST", BUILD_CHEST_LARGE: "LARGE CHEST",
		BUILD_HEAVY_DOORWAY: "HEAVY DOORWAY",
		BUILD_FOUNDRY: "CORE FOUNDRY",
		BUILD_PERSONAL_BASE: "PERSONAL BASE",
		BUILD_TORCH: "FIELD LANTERN",
		BUILD_MERCHANT_STORE: "MERCHANT STORE",
	}
	return str(names.get(build_kind, "STRUCTURE"))


func _update_mining(delta: float) -> void:
	if relocating_structure_index >= 0:
		_mining_beam_regions.clear()
		mine_target = Vector2i(-1, -1)
		mine_progress = 0.0
		mining_beam_valid = false
		return
	## Primary (LMB/fire) breaks when hand allows mining; never while a gun is selected.
	if not _hotbar_can_mine() or not Input.is_action_pressed("fire") or suppress_primary_fire_until_release:
		_mining_beam_regions.clear()
		mine_target = Vector2i(-1, -1)
		mine_progress = 0.0
		mining_beam_valid = false
		return

	_refresh_mining_beam_regions()

	var mining_hit: Dictionary = _resolve_mining_hit()
	if mining_hit.is_empty():
		mine_target = Vector2i(-1, -1)
		mine_progress = 0.0
		mining_beam_valid = false
		return
	var target: Vector2i = mining_hit["cell"]
	var target_position: Vector2 = mining_hit["end"]
	mining_beam_end = target_position
	mining_beam_valid = true

	if mine_target != target:
		mine_target = target
		mine_progress = 0.0
	mine_progress += delta
	mining_feedback_time = 0.09
	if mining_spark_cooldown <= 0.0 and enemies.size() < SPARK_MINING_SKIP_THRESHOLD:
		mining_spark_cooldown = 0.14
		_burst(target_position + Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0)), Color("e4ad65"), 2, 26.0)
	if mine_progress < _mining_cycle_duration():
		return

	mine_progress = 0.0
	if str(mining_hit.get("kind", "terrain")) == "structure":
		if operator_loadout.is_cutter_selected():
			_begin_structure_relocation(int(mining_hit.get("structure_index", -1)))
		return
	var mined_was_placed: bool = placeable_blocks.has_placed(target)
	var mined_biome: int = placeable_blocks.biome_at(target, _biome_for_cell(target))
	var mining_commit_start_us := Time.get_ticks_usec()
	var open_cell_start_us := mining_commit_start_us
	var opened_cell := grid.open_cell(target)
	var open_cell_cost_us := Time.get_ticks_usec() - open_cell_start_us
	if opened_cell:
		grid.visited_regions[grid.region_for_cell(target)] = true
		placeable_blocks.clear_placed(target)
		_on_terrain_cell_opened(target)
		if not mined_was_placed:
			_apply_scrap_delta(ScrapEconomyScript.MINE_CELL, "mine_cell")
			score += 25
			first_mine_earned = true
		mining_impact_pulse = 0.28
		mining_impact_position = target_position
		_combat_feedback(target_position, aim_direction, "impact_rock", Color("e5b56f"), 24, 82.0, true)
		_burst(target_position, Color("78eaff"), 4, 48.0, true)
		if not mined_was_placed:
			_collect_mineral(target)
		_handle_mined_wall_economy(target, mined_biome, mined_was_placed)
		if not mined_was_placed:
			_register_first_contact(target)
			_resolve_mining_discovery(target)
	if gameplay_telemetry != null:
		gameplay_telemetry.note_mining_commit(open_cell_cost_us, Time.get_ticks_usec() - mining_commit_start_us)


func _resolve_mining_hit() -> Dictionary:
	var origin: Vector2 = _player_muzzle_position(true)
	var max_distance: float = _mining_beam_reach()
	var current_cell := grid.world_to_cell(origin)
	var current_structure := _relocatable_structure_index_at_cell(current_cell)
	if current_structure >= 0:
		return {"kind": "structure", "structure_index": current_structure, "cell": current_cell, "end": origin, "distance": 0.0}
	if grid.can_mine(current_cell):
		return {"kind": "terrain", "cell": current_cell, "end": origin, "distance": 0.0}
	var last_cell := current_cell
	var distance := 2.0
	while distance <= max_distance:
		var probe := origin + aim_direction * distance
		var cell := grid.world_to_cell(probe)
		if cell != last_cell:
			var structure_index := _relocatable_structure_index_at_cell(cell)
			if structure_index >= 0:
				return {"kind": "structure", "structure_index": structure_index, "cell": cell, "end": probe, "distance": distance}
			if grid.can_mine(cell):
				return {"kind": "terrain", "cell": cell, "end": probe - aim_direction, "distance": distance}
			if not grid.is_walkable(cell):
				return {}
			last_cell = cell
		distance += 2.0
	return {}


func _is_relocatable_structure_kind(kind: int) -> bool:
	return kind in [
		BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER,
		BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER, BUILD_HEAVY_DOORWAY,
		BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET,
	]


func _relocatable_structure_index_at_cell(cell: Vector2i) -> int:
	if _mining_tool_tier() < 2:
		return -1
	for structure_index: int in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if _is_relocatable_structure_kind(structure.kind) and _structure_covers_cell(structure, cell):
			return structure_index
	return -1


func _begin_structure_relocation(structure_index: int) -> bool:
	if _mining_tool_tier() < 2 or structure_index < 0 or structure_index >= structures.size():
		return false
	var structure: Structure = structures[structure_index]
	if not _is_relocatable_structure_kind(structure.kind):
		return false
	relocating_structure_index = structure_index
	relocation_target = structure.cell
	mining_beam_valid = false
	mine_target = Vector2i(-1, -1)
	discovery_alert = "%s ACQUIRED // RMB TO PLACE // TAB TO CANCEL" % _build_name(structure.kind)
	discovery_alert_time = 4.0
	return true


func _cancel_structure_relocation(message: String = "") -> void:
	relocating_structure_index = -1
	relocation_target = Vector2i(-1, -1)
	if not message.is_empty():
		discovery_alert = message
		discovery_alert_time = 2.5


func _can_place_relocated_structure(cell: Vector2i, structure_index: int = -1) -> bool:
	var index := relocating_structure_index if structure_index < 0 else structure_index
	if index < 0 or index >= structures.size():
		return false
	var held: Structure = structures[index]
	for ox: int in range(held.size.x):
		for oy: int in range(held.size.y):
			var candidate := cell + Vector2i(ox, oy)
			if not grid.is_walkable(candidate):
				return false
			if grid.cell_to_world(candidate).distance_to(player_position) > _mining_beam_reach():
				return false
			for base_id: String in base_network.bases.keys():
				if candidate.distance_to(base_network.get_cell(base_id)) < 2.0:
					return false
			if candidate in grid.spawn_cells or _brood_nest_index_at_cell(candidate) >= 0:
				return false
			for other_index: int in range(structures.size()):
				if other_index != index and _structure_covers_cell(structures[other_index], candidate):
					return false
	return true


func _place_relocated_structure(cell: Vector2i) -> bool:
	if not _can_place_relocated_structure(cell):
		_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
		discovery_alert = "INVALID RELOCATION SITE // SOURCE UNCHANGED"
		discovery_alert_time = 2.0
		return false
	var structure: Structure = structures[relocating_structure_index]
	structure.cell = cell
	structure.position = grid.cell_to_world(cell)
	structure.base_id = base_network.powered_base_for(cell)
	structure.powered = not structure.base_id.is_empty()
	var structure_name := _build_name(structure.kind)
	_cancel_structure_relocation()
	discovery_alert = "%s RELOCATED // CONDITION PRESERVED" % structure_name
	discovery_alert_time = 2.5
	_burst(structure.position, Color("77dff3"), 10, 40.0)
	_mark_flow_dirty_for_structure_cell(cell)
	call_deferred("_save_run")
	return true


func _mining_cycle_duration(tier_override: int = -1) -> float:
	var tier: int = mining_speed_tier if tier_override < 0 else clampi(tier_override, 1, 5)
	return MINING_CYCLE_DURATIONS[tier] * mining_cycle_multiplier


func _mining_beam_reach(tier_override: int = -1) -> float:
	var tier: int = mining_emitter_tier if tier_override < 0 else clampi(tier_override, 1, 5)
	return MINING_BEAM_REACHES[tier]


func _mining_beam_width(tier_override: int = -1) -> float:
	var tier: int = mining_emitter_tier if tier_override < 0 else clampi(tier_override, 1, 5)
	return MINING_BEAM_WIDTHS[tier]


func _backpack_capacity(tier_override: int = -1) -> int:
	var tier: int = backpack_tier if tier_override < 0 else clampi(tier_override, 1, 4)
	return BACKPACK_CAPACITIES[tier]


func _sync_deployable_mirror() -> void:
	if operator_loadout == null:
		return
	for stock_id: String in deployable_stock.keys():
		deployable_stock[stock_id] = operator_loadout.count_of(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id)


func _adopt_deployable_stock_mirror() -> void:
	## Lets tests that mutate deployable_stock still drive placement/craft.
	if operator_loadout == null:
		return
	for stock_id: String in deployable_stock.keys():
		var want := maxi(0, int(deployable_stock.get(stock_id, 0)))
		var have := operator_loadout.count_of(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id)
		if want != have:
			operator_loadout.set_deployable_total(stock_id, want)


func kit_count(stock_id: String) -> int:
	_adopt_deployable_stock_mirror()
	return operator_loadout.count_of(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id)


func set_kit_stock(stock_id: String, amount: int) -> void:
	operator_loadout.set_deployable_total(stock_id, maxi(0, amount))
	_sync_deployable_mirror()


func grant_kit(stock_id: String, amount: int = 1) -> int:
	## Returns leftover that did not fit.
	var left := operator_loadout.add_stacks(OperatorLoadoutScript.make_stack(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id, amount))
	_sync_deployable_mirror()
	return left


func consume_kit(stock_id: String, amount: int = 1) -> bool:
	_adopt_deployable_stock_mirror()
	var ok := operator_loadout.consume_kind(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id, amount)
	_sync_deployable_mirror()
	return ok


func _issue_starter_torch_if_needed() -> void:
	if torch_starter_issued:
		return
	torch_starter_issued = true
	var left := grant_kit(TORCH_STOCK_ID, 2)
	if left >= 2:
		return
	if operator_onboard == null or operator_onboard.is_done():
		discovery_alert = OperatorOnboardScript.PROMPT_TORCH
		discovery_alert_time = 4.5
	else:
		operator_onboard.torch_hint_pending = true


func _hotbar_active_stack() -> Dictionary:
	return operator_loadout.active_stack() if operator_loadout else OperatorLoadoutScript.empty_stack()


func _hotbar_holds_weapon() -> bool:
	return operator_loadout.is_gun_selected() if operator_loadout else false


func _hotbar_can_mine() -> bool:
	return operator_loadout.is_cutter_selected() if operator_loadout else false


func _hotbar_is_placeable() -> bool:
	return OperatorLoadoutScript.is_placeable(_hotbar_active_stack())


func _primary_break_held() -> bool:
	return _hotbar_can_mine() and Input.is_action_pressed("fire") and not suppress_primary_fire_until_release


func _hostile_near(radius: float) -> bool:
	if enemies.is_empty():
		return false
	_ensure_enemy_spatial_buckets()
	return CombatSpatialScript.enemy_near_position(_enemy_spatial_buckets, player_position, radius, enemies)


func _onboard_wall_ahead() -> bool:
	if grid == null:
		return false
	return str(_resolve_mining_hit().get("kind", "")) == "terrain"


func _onboard_may_speak() -> bool:
	if discovery_alert_time <= 0.0 or discovery_alert.is_empty():
		return true
	if operator_onboard != null and operator_onboard.is_prompt(discovery_alert):
		return true
	var alert_upper := discovery_alert.to_upper()
	return not ("UNDER ATTACK" in alert_upper or "INTERCEPT" in alert_upper)


func _update_onboard() -> void:
	if operator_onboard == null or operator_onboard.is_done():
		return
	var gun_fired := operator_loadout != null and operator_loadout.is_gun_selected() and muzzle_flash > 0.0
	var became_done := operator_onboard.advance(player_moving, first_mine_earned or mine_progress > 0.0, gun_fired)
	var wall := operator_onboard.step == OperatorOnboardScript.STEP_MINE and _onboard_wall_ahead()
	var hostile := operator_onboard.step == OperatorOnboardScript.STEP_FIRE and _hostile_near(COMBAT_UI_RANGE)
	var prompt := operator_onboard.prompt(wall, hostile)
	if not prompt.is_empty() and _onboard_may_speak():
		discovery_alert = prompt
		discovery_alert_time = 2.4
	if became_done and operator_onboard.consume_torch_hint():
		discovery_alert = OperatorOnboardScript.PROMPT_TORCH
		discovery_alert_time = 4.5


func _sync_current_weapon_from_hotbar() -> void:
	if operator_loadout == null:
		return
	var wid := operator_loadout.selected_weapon_id()
	if wid >= 0 and wid < WEAPON_COUNT and unlocked_weapons[wid]:
		current_weapon = wid


func _equip_unlocked_weapon(weapon_id: int) -> void:
	if operator_loadout == null or weapon_id < 0 or weapon_id >= WEAPON_COUNT:
		return
	var dest := operator_loadout.ensure_weapon(weapon_id)
	if dest == "pack":
		discovery_alert = "%s IN PACK // I TO ASSIGN" % _weapon_name(weapon_id).to_upper()
		discovery_alert_time = 4.0
	elif dest == "lost":
		discovery_alert = "%s NO ROOM // I TO ASSIGN" % _weapon_name(weapon_id).to_upper()
		discovery_alert_time = 4.0


func _selected_build_from_hotbar() -> int:
	var stack := _hotbar_active_stack()
	var kind := str(stack.get("kind", ""))
	if kind == OperatorLoadoutScript.KIND_BUILD:
		return int(stack.get("build_kind", BUILD_BARRICADE))
	if kind == OperatorLoadoutScript.KIND_DEPLOYABLE:
		var stock_id := str(stack.get("id", ""))
		if stock_id == TORCH_STOCK_ID:
			return BUILD_TORCH
		for build_kind: int in BUILD_STOCK_KEYS.keys():
			if str(BUILD_STOCK_KEYS[build_kind]) == stock_id:
				return build_kind
	return selected_build


func _deployable_pack_units(stock_override: Dictionary = {}) -> int:
	## Kits no longer consume material capacity; kept for legacy callers → always 0.
	return 0


func _deployable_stock_total() -> int:
	_adopt_deployable_stock_mirror()
	var total := 0
	for stock_id: String in deployable_stock.keys():
		total += kit_count(stock_id)
	return total


func _deployable_cap(stock_id: String) -> int:
	## Slot grid is the real cap; keep a high ceiling for shop UI copy.
	return OperatorLoadoutScript.STACK_MAX * (OperatorLoadoutScript.BACKPACK_SIZE + OperatorLoadoutScript.HOTBAR_SIZE)


func _backpack_used() -> int:
	return material_economy.inventory_units()


func _backpack_free() -> int:
	return maxi(0, _backpack_capacity() - _backpack_used())


func _can_accept_units(units: int) -> bool:
	return _backpack_used() + maxi(0, units) <= _backpack_capacity()


func _can_accept_kit(stock_id: String = "personal_base") -> bool:
	if operator_loadout == null:
		return false
	var probe: Dictionary = OperatorLoadoutScript.make_stack(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id, 1)
	return operator_loadout.can_accept_stack(probe, 1)



func _try_add_ammo(kind: String, amount: int) -> bool:
	match kind:
		PICKUP_PISTOL_AMMO:
			if reserve_ammo >= AMMO_RESERVE_CAPS[WEAPON_PISTOL]:
				return false
			reserve_ammo = mini(reserve_ammo + amount, AMMO_RESERVE_CAPS[WEAPON_PISTOL])
		PICKUP_SHOTGUN_AMMO:
			if shotgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_SHOTGUN]:
				return false
			shotgun_reserve = mini(shotgun_reserve + amount, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN])
		PICKUP_SMG_AMMO:
			if smg_reserve >= AMMO_RESERVE_CAPS[WEAPON_SMG]:
				return false
			smg_reserve = mini(smg_reserve + amount, AMMO_RESERVE_CAPS[WEAPON_SMG])
		PICKUP_RAIL_AMMO:
			if railgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_RAILGUN]:
				return false
			railgun_reserve = mini(railgun_reserve + amount, AMMO_RESERVE_CAPS[WEAPON_RAILGUN])
		_:
			return false
	return true


func _update_chest_interactions(delta: float) -> void:
	chest_alert_time = maxf(0.0, chest_alert_time - delta)
	if build_mode or using_chest_index >= 0 or using_core_base or using_foundry:
		reload_hold_time = 0.0
		inventory_hold_time = 0.0
		return
	
	var chest_idx: int = _nearby_chest()
	if chest_idx < 0:
		reload_hold_time = 0.0
		inventory_hold_time = 0.0
		return
		
	if Input.is_action_pressed("reload"):
		if reload_hold_time >= 0.0:
			reload_hold_time += delta
			if reload_hold_time >= 0.4:
				reload_hold_time = -1.0
				_chest_auto_dump(chest_idx)
	else:
		reload_hold_time = 0.0

	inventory_hold_time = 0.0

	# Doorway open/close handling runs independently
	_update_door_interactions(delta)


func _update_door_interactions(delta: float) -> void:
	if build_mode or using_chest_index >= 0 or using_core_base or using_foundry:
		door_hold_time = 0.0
		return
	var door_idx := _nearby_doorway()
	if door_idx < 0:
		door_hold_time = 0.0
		return
	if Input.is_action_pressed("interact"):
		if door_hold_time >= 0.0:
			door_hold_time += delta
			if door_hold_time >= 0.45:
				door_hold_time = -1.0
				_toggle_doorway(door_idx)
	else:
		door_hold_time = 0.0


func _toggle_doorway(door_idx: int) -> bool:
	## One authoritative doorway state transition for both click and F-hold input.
	## This keeps presentation, enemy blockers, flow repair, and persistence in sync.
	if door_idx < 0 or door_idx >= structures.size():
		return false
	var door: Structure = structures[door_idx]
	if door.kind != BUILD_HEAVY_DOORWAY or door.health <= 0.0:
		return false
	door_hold_time = -1.0
	door.is_open = not door.is_open
	_mark_flow_dirty_for_structure(door)
	var state_str := "OPENED" if door.is_open else "CLOSED"
	var warn_str := "  //  MOBS CAN PASS!" if door.is_open else "  //  SECURED"
	discovery_alert = "DOORWAY %s%s" % [state_str, warn_str]
	discovery_alert_time = 2.5
	_mark_visual_dirty(VIS_DIRTY_ACTORS | VIS_DIRTY_EFFECTS)
	_save_run()
	return true


func _nearby_torch() -> int:
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind == BUILD_TORCH and structure.position.distance_to(player_position) <= 24.0:
			return structure_index
	return -1


func _update_torch_interactions() -> void:
	if build_mode or using_chest_index >= 0 or using_core_base or using_foundry:
		return
	var torch_index := _nearby_torch()
	if torch_index < 0 or not Input.is_action_just_pressed("interact"):
		return
	var torch: Structure = structures[torch_index]
	if torch.cell != lantern_upgrade_target_cell:
		if torch.level < TORCH_DURABILITY.size() - 1:
			discovery_alert = "LANTERN CALIBRATION REQUIRED // PREPARE AT FOUNDRY"
			discovery_alert_time = 2.0
		return
	_apply_prepared_lantern_upgrade(torch)


func _apply_prepared_lantern_upgrade(torch: Structure) -> void:
	if torch.kind != BUILD_TORCH or torch.cell != lantern_upgrade_target_cell or torch.level >= TORCH_DURABILITY.size() - 1:
		return
	var next_level := mini(torch.level + 1, TORCH_DURABILITY.size() - 1)
	torch.level = next_level
	torch.lantern_color_id = clampi(next_level - 1, 0, TORCH_COLOR_NAMES.size() - 1)
	torch.max_health = TORCH_DURABILITY[next_level] * fortification_multiplier
	torch.health = torch.max_health
	lantern_upgrade_target_cell = Vector2i(-1, -1)
	discovery_alert = "LANTERN MK%d ONLINE // %s SPECTRUM // %d VISION" % [next_level, TORCH_COLOR_NAMES[torch.lantern_color_id], TORCH_VISION_RADII[next_level]]
	discovery_alert_time = 3.0
	_burst(torch.position, _torch_light_color(torch), 16, 56.0)
	_save_run()


func _chest_used(chest: Structure) -> int:
	var total := 0
	for amount: int in chest.inventory.values():
		total += amount
	return total

func _chest_auto_dump(chest_idx: int) -> void:
	var chest: Structure = structures[chest_idx]
	var starting_used := _chest_used(chest)
	var dumped := 0
	
	for material_type: String in material_economy.RAW_ORDER:
		var held: int = int(material_economy.raw.get(material_type, 0))
		if held > 0:
			var capacity_left := chest.chest_capacity - _chest_used(chest)
			var to_move := min(held, capacity_left)
			if to_move > 0:
				material_economy.raw[material_type] = held - to_move
				chest.inventory[material_type] = int(chest.inventory.get(material_type, 0)) + to_move
				dumped += to_move
				
	for material_type: String in material_economy.REFINED_ORDER:
		var held: int = int(material_economy.refined.get(material_type, 0))
		if held > 0:
			var capacity_left := chest.chest_capacity - _chest_used(chest)
			var to_move := min(held, capacity_left)
			if to_move > 0:
				material_economy.refined[material_type] = held - to_move
				chest.inventory[material_type] = int(chest.inventory.get(material_type, 0)) + to_move
				dumped += to_move

	if dumped > 0:
		_burst(chest.position, Color("baf7d1"), 8, 30.0)
		chest_alert_text = "STORED +%d" % dumped
		chest_alert_time = 1.4
		chest_alert_position = chest.position + Vector2(0, -20)
		_mark_visual_dirty(VIS_DIRTY_ACTORS | VIS_DIRTY_EFFECTS)
		_save_run()
	
	if _chest_used(chest) >= chest.chest_capacity and dumped == 0:
		chest_alert_text = "I'm full!"
		chest_alert_time = 2.0
		chest_alert_position = chest.position + Vector2(0, -20)
		_mark_visual_dirty(VIS_DIRTY_ACTORS | VIS_DIRTY_EFFECTS)

func _update_exploration() -> void:
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var next_origin := _minimap_view_origin_for(player_cell)
	if next_origin != minimap_view_origin:
		_advance_minimap_view(next_origin)
	var player_region := grid.region_for_cell(player_cell)
	if player_region != active_player_region:
		active_player_region = player_region
		_prune_visual_prop_cache()
	_register_prepared_region_exploration(player_region)
	_notify_biome_discovery(player_region)
	_register_sector(player_cell, true)
	_discover_frontier_site(player_cell)
	_ensure_local_persistent_encounters(player_region)
	_try_spawn_pending_scout(player_region)


func _register_prepared_region_exploration(region: Vector2i) -> void:
	var region_cell := region * WorldGridScript.REGION_SIZE + Vector2i.ONE
	if not grid.is_region_active(region_cell):
		return
	_ensure_ruined_fortress_in_region(region)
	var result := hive_awareness.register_prepared_region(region, region != grid.region_for_cell(grid.core_cell))
	if not bool(result.get("accepted", false)):
		return
	if bool(result.get("tier_changed", false)):
		discovery_alert = "HIVE AWARENESS %s // SETTLEMENT SIGNAL SPREADING" % hive_awareness.tier_label()
		discovery_alert_time = 4.0


func _ensure_ruined_fortress_in_region(region: Vector2i) -> bool:
	if ruined_fortress_regions.has(region):
		return false
	var region_probe := region * WorldGridScript.REGION_SIZE + Vector2i.ONE
	if not grid.is_region_active(region_probe):
		return false
	var origin_region := grid.region_for_cell(grid.core_cell)
	ruined_fortress_regions[region] = false
	if not RuinedFortressScript.should_spawn(run_seed, region, origin_region):
		return false
	var anchor := _ruined_fortress_anchor(region)
	if anchor == Vector2i(-1, -1):
		return false
	_materialize_ruined_fortress(region, anchor)
	ruined_fortress_regions[region] = anchor
	discovery_alert = "ABANDONED SETTLEMENT FORTRESS LOCATED // SALVAGE CACHE DETECTED"
	discovery_alert_time = 5.0
	return true


func _ruined_fortress_anchor(region: Vector2i) -> Vector2i:
	var origin := region * WorldGridScript.REGION_SIZE
	var candidates: Array[Vector2i] = []
	for y in range(5, WorldGridScript.REGION_SIZE - 5):
		for x in range(5, WorldGridScript.REGION_SIZE - 5):
			var candidate := origin + Vector2i(x, y)
			if grid.in_bounds(candidate) and grid.is_spawn_ready(candidate) and _ruined_fortress_site_clear(candidate):
				candidates.append(candidate)
	if candidates.is_empty():
		return Vector2i(-1, -1)
	candidates.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		var left_hash := posmod(run_seed ^ left.x * 92821 ^ left.y * 68917, 2147483647)
		var right_hash := posmod(run_seed ^ right.x * 92821 ^ right.y * 68917, 2147483647)
		return left_hash < right_hash
	)
	return candidates[0]


func _ruined_fortress_site_clear(center: Vector2i) -> bool:
	for base_id: String in base_network.bases.keys():
		if center.distance_to(base_network.get_cell(base_id)) < 10.0:
			return false
	for y in range(-4, 5):
		for x in range(-4, 5):
			var cell := center + Vector2i(x, y)
			if not grid.in_bounds(cell) or not grid.is_region_active(cell):
				return false
			if grid.discovery_cells.has(cell) or grid.mineral_cells.has(cell) or cell in grid.spawn_cells:
				return false
			if _brood_nest_index_at_cell(cell) >= 0 or _structure_index_at_cell(cell) >= 0:
				return false
	return true


func _materialize_ruined_fortress(region: Vector2i, center: Vector2i) -> void:
	if not grid.is_region_active(center):
		return
	grid.open_discovery_chamber(center, 4)
	var wall_offsets: Array[Vector2i] = [
		Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2),
		Vector2i(-3, -1), Vector2i(3, -1), Vector2i(-3, 0), Vector2i(3, 1),
		Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(2, 2), Vector2i(3, 2),
	]
	for wall_index in range(wall_offsets.size()):
		var wall := Structure.new()
		wall.kind = BUILD_GRANITE_BARRIER
		wall.cell = center + wall_offsets[wall_index]
		wall.position = grid.cell_to_world(wall.cell)
		wall.health = 46.0 + float(posmod(run_seed + wall_index * 17 + region.x * 31 + region.y * 43, 55))
		wall.max_health = 240.0
		wall.aim_direction = Vector2.RIGHT if wall_offsets[wall_index].y != -2 and wall_offsets[wall_index].y != 2 else Vector2.DOWN
		wall.is_ruin = true
		structures.append(wall)
	var region_distance := absi(region.x - grid.region_for_cell(grid.core_cell).x) + absi(region.y - grid.region_for_cell(grid.core_cell).y)
	var luck := RuinedFortressScript.luck_tier(region_distance, expedition_level, hive_awareness.awareness_tier)
	var chest := Structure.new()
	chest.kind = BUILD_CHEST_SMALL
	chest.cell = center
	chest.position = grid.cell_to_world(center)
	chest.health = 100.0
	chest.max_health = 100.0
	chest.chest_capacity = 100
	chest.inventory = RuinedFortressScript.minor_loot(run_seed, region, luck)
	chest.is_ruin = true
	chest.fortress_chest = true
	chest.powered = true
	structures.append(chest)
	_invalidate_structure_spatial_buckets()


func _ensure_local_persistent_encounters(region: Vector2i) -> void:
	for base_id: String in base_network.bases.keys():
		if base_id == BaseNetworkScript.COMMAND_ID:
			continue
		var record: Dictionary = base_network.get_base(base_id)
		var site_cell: Vector2i = record.get("cell", Vector2i(-1, -1))
		if grid.region_for_cell(site_cell) != region or not bool(record.get("revealed", false)):
			continue
		if bool(record.get("guardian_cleared", false)) or str(record.get("status", "")) != BaseNetworkScript.STATUS_SITE:
			continue
		if not _has_guardian_for_site(base_id) and _spawn_guardian(site_cell):
			enemies.back().guardian_site_id = base_id


func _try_spawn_pending_scout(active_region: Vector2i) -> bool:
	if not _hostile_spawn_slot_available() or _simulation_enemy_count() >= _active_enemy_cap():
		return false
	for requested_region: Vector2i in hive_awareness.pending_scout_regions:
		if requested_region != active_region:
			continue
		for spider: Spider in enemies:
			if spider.is_scout and spider.scout_region == requested_region and not spider.scout_reported:
				return false
		var spawn_cell := _prepared_spider_spawn_cell_near(
			grid.world_to_cell(player_position),
			7,
			30,
			run_seed ^ requested_region.x * 92821 ^ requested_region.y * 68917
		)
		if not _spider_spawn_allowed_cell(spawn_cell):
			return false
		var profile := HiveAwarenessScript.scout_profile(grid.region_biome(requested_region))
		var scout := Spider.new()
		scout.is_scout = true
		scout.scout_name = str(profile["name"])
		scout.scout_region = requested_region
		scout.role = int(profile["role"])
		scout.position = _spider_spawn_position(spawn_cell, hive_awareness.awareness_points, 6211)
		if not _valid_spider_spawn_position(scout.position):
			return false
		scout.target_base_id = base_network.nearest_active(spawn_cell)
		if scout.target_base_id.is_empty():
			scout.target_base_id = BaseNetworkScript.COMMAND_ID
		scout.hunts_player = true
		scout.counts_for_wave = false
		scout.radius = 8.0 if scout.role == ROLE_BRUTE else 5.0
		var ecology_level := _combat_pressure_level()
		scout.max_health = (16.0 + float(ecology_level) * 2.0) * float(difficulty["enemy_health"])
		if scout.role == ROLE_BRUTE:
			scout.max_health *= 2.0
		scout.health = scout.max_health
		scout.speed = MobLocomotionScript.brute_speed_for_pressure(ecology_level, float(difficulty["enemy_speed"])) if scout.role == ROLE_BRUTE else MobLocomotionScript.swarm_speed_for_pressure(scout.role == ROLE_SPITTER, ecology_level, float(difficulty["enemy_speed"]))
		if scout.role == ROLE_LEAPER:
			scout.leap_cooldown = 0.8
		elif scout.role == ROLE_SPITTER:
			scout.spit_cooldown = 1.2
		_assign_spider_biome(scout, spawn_cell)
		if not _consume_hostile_spawn_slot():
			return false
		enemies.append(scout)
		hive_awareness.consume_scout_request(requested_region)
		discovery_alert = "%s SCOUTING // INTERCEPT BEFORE IT REPORTS" % scout.scout_name
		discovery_alert_time = 4.0
		return true
	return false


func _update_scouts(delta: float) -> void:
	for enemy_index in range(enemies.size() - 1, -1, -1):
		var scout: Spider = enemies[enemy_index]
		if not scout.is_scout or scout.scout_reported:
			continue
		var scout_cell := grid.world_to_cell(scout.position)
		if not grid.is_region_active(scout_cell):
			hive_awareness.mark_scout_missing(scout.scout_region)
			enemies.remove_at(enemy_index)
			continue
		if not scout.scout_contact and scout.position.distance_to(player_position) <= 170.0:
			scout.scout_contact = true
			discovery_alert = "%s HAS CONTACT // STOP THE REPORT" % scout.scout_name
			discovery_alert_time = 3.0
		if not scout.scout_contact or not _spider_has_viable_route(scout):
			continue
		scout.scout_report_elapsed += delta
		if scout.scout_report_elapsed < 6.0:
			continue
		scout.scout_reported = true
		hive_awareness.report_scout(scout.scout_region)
		discovery_alert = "%s REPORTED // HUNTING PARTY MOBILIZING" % scout.scout_name
		discovery_alert_time = 4.0


func _update_missing_scouts(delta: float) -> void:
	var escalated_regions := hive_awareness.tick_missing_scouts(delta)
	if escalated_regions.is_empty():
		return
	discovery_alert = "SCOUT OVERDUE // HIVE SEARCH PARTIES MOBILIZING"
	discovery_alert_time = 4.0


func _region_stream_centers() -> Array:
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var centers: Array = [player_cell]
	# Chunk streaming follows travel, not tool aim. The mining beam is only a few
	# cells long; using its aim direction used to request terrain ~1.25 regions
	# ahead while the player stood still, making mining trigger chunk generation.
	var direction := player_move_direction if player_moving else Vector2.ZERO
	var direction_changed := direction.length_squared() > 0.01 and direction.distance_squared_to(_last_stream_direction) > 0.04
	if direction_changed:
		_last_stream_direction = direction
	if direction.length_squared() > 0.01 and (direction_changed or _stream_center_tick % 3 == 0):
		var ahead_cell := Vector2i(
			player_cell.x + int(round(direction.x * float(WorldGridScript.REGION_SIZE) * 1.25)),
			player_cell.y + int(round(direction.y * float(WorldGridScript.REGION_SIZE) * 1.25))
		)
		if ahead_cell != player_cell:
			centers.append(ahead_cell)
	return centers


func _update_region_streaming() -> void:
	_stream_center_tick += 1
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var expanded := grid.try_expand_prepare_zone(player_cell)
	# Defensive budget gate: if any legacy/preload helper ever leaked regions into
	# active ownership, sanitize the window even while the player is stationary.
	# Hard limits must be runtime invariants, not only refresh-time intentions.
	var window_over_budget := (
		grid.stream_window_regions().size() > WorldGridScript.MAX_RENDER_REGIONS
		or grid.loaded_regions.size() > WorldGridScript.MAX_SIMULATION_REGIONS
	)
	var render_added := _update_visible_render_window(expanded or window_over_budget)
	# Mining owns the frame. The rolling 9x9 prepare horizon already gives travel
	# headroom, so background chunk generation/cache building can pause completely
	# while the cutter is held instead of competing with the block mutation frame.
	var mining_busy := _primary_break_held() or mining_beam_valid
	var budget := 0 if mining_busy else (REGION_PRELOAD_MOVING_BUDGET if player_moving else REGION_PRELOAD_BUDGET)
	var loaded_now := grid.process_region_preload_budget(budget)
	var stream_regions := _active_stream_regions()
	if expanded or render_added > 0 or loaded_now > 0 or _stream_regions_changed(_last_stream_regions, stream_regions) or terrain_chunk_layers.size() != stream_regions.size():
		var window_changed := _sync_terrain_chunk_layers()
		if window_changed:
			_ensure_undrawn_stream_chunks_queued()
			_mark_visual_dirty(VIS_DIRTY_WORLD)
	# Consume generation deltas, but do not build decorative formation/prop caches
	# during live play. Lean terrain does not use them, and DEV009 showed that eager
	# presentation-cache work was adding avoidable exploration-frame cost. The first
	# paused/full-quality refinement builds these caches on demand instead.
	grid.take_region_preload_delta()
	if not _pending_visual_region_builds.is_empty():
		_pending_visual_region_builds.clear()
		_pending_visual_region_set.clear()
	if gameplay_telemetry != null:
		gameplay_telemetry.note_streaming_work(loaded_now, mining_busy)


func _enqueue_visual_region_build(region: Vector2i) -> void:
	if _pending_visual_region_set.has(region):
		return
	if visual_prop_cache.has(region) and visual_formation_cache.has(region) and visual_landmark_cache.has(region):
		return
	_pending_visual_region_set[region] = true
	_pending_visual_region_builds.append(region)


func _service_visual_region_builds(budget: int) -> void:
	var built := 0
	var deferred: Array[Vector2i] = []
	while built < budget and not _pending_visual_region_builds.is_empty():
		var region: Vector2i = _pending_visual_region_builds.pop_front()
		_pending_visual_region_set.erase(region)
		if grid == null or not grid.stream_window_regions().has(region):
			continue
		if grid.region_readiness(region) < WorldGridScript.RegionReadiness.PREPARED:
			deferred.append(region)
			continue
		_visual_formations_for_region(region)
		_visual_props_for_region(region)
		built += 1
	for region: Vector2i in deferred:
		_enqueue_visual_region_build(region)


func _notify_biome_discovery(region: Vector2i) -> void:
	if discovered_biomes.has(region):
		return
	discovered_biomes[region] = grid.region_biome(region)
	if region == grid.region_for_cell(grid.core_cell):
		return
	discovery_alert = "BIOME SURVEY // %s // LOCAL DEPOSITS LIKELY" % grid.region_biome_name(region)
	discovery_alert_time = 4.0


func _register_sector(cell: Vector2i, award_reward: bool) -> void:
	var sector := Vector2i(floori(float(cell.x) / 12.0), floori(float(cell.y) / 12.0))
	if explored_sectors.has(sector):
		return
	explored_sectors[sector] = true
	_patch_minimap_sector(sector)
	if not award_reward:
		return
	hive_awareness.register_activity("survey", grid.region_for_cell(cell))
	_apply_scrap_delta(ScrapEconomyScript.SECTOR, "sector_survey")
	score += 75
	exploration_find_count += 1
	discovery_alert = "NEW SECTOR SURVEYED // +$%d SALVAGE CREDIT" % ScrapEconomyScript.SECTOR
	discovery_alert_time = 2.5
	hud_minimap_bloom = 1.0
	hud_minimap_bloom_cell = cell
	_award_exploration_streak()


func _collect_mineral(cell: Vector2i) -> void:
	var mineral_type: String = grid.collect_mineral(cell)
	if mineral_type.is_empty():
		return
	var payout := 0
	var raw_id := ""
	var units := 0
	var score_bonus := 0
	var color := Color("c88252")
	var label := "COPPER SEAM"
	match mineral_type:
		WorldGridScript.MINERAL_COPPER:
			raw_id = MaterialEconomyScript.COPPER_ORE
			units = 3
			score_bonus = 100
		WorldGridScript.MINERAL_SILVER:
			raw_id = MaterialEconomyScript.SILVER_ORE
			units = 2
			score_bonus = 180
			color = Color("d5e0e4")
			label = "SILVER ORE"
		WorldGridScript.MINERAL_GOLD:
			raw_id = MaterialEconomyScript.GOLD_ORE
			units = 2
			score_bonus = 300
			color = Color("f2c14e")
			label = "GOLD ORE"
		WorldGridScript.MINERAL_CRYSTAL:
			raw_id = MaterialEconomyScript.ENERGY_CRYSTAL
			units = 2
			score_bonus = 250
			color = Color("66dcf2")
			label = "ENERGY CRYSTAL"
		WorldGridScript.MINERAL_DIAMOND:
			raw_id = MaterialEconomyScript.ROUGH_DIAMOND
			units = 1
			score_bonus = 600
			color = Color("d9fbff")
			label = "DIAMOND DEPOSIT"
		WorldGridScript.MINERAL_GRANITE:
			raw_id = MaterialEconomyScript.GRANITE
			units = 4
			score_bonus = 85
			color = Color("9b9995")
			label = "GRANITE SHELF"
		WorldGridScript.MINERAL_BASALT:
			raw_id = MaterialEconomyScript.BASALT
			units = 3
			score_bonus = 120
			color = Color("4e555c")
			label = "BASALT VEIN"
		WorldGridScript.MINERAL_QUARTZ:
			raw_id = MaterialEconomyScript.QUARTZ
			units = 2
			score_bonus = 190
			color = Color("f0e7ff")
			label = "QUARTZ CLUSTER"
		WorldGridScript.MINERAL_IRON:
			raw_id = MaterialEconomyScript.IRON_ORE
			units = 3
			score_bonus = 150
			color = Color("b36e52")
			label = "IRON ORE"
		WorldGridScript.MINERAL_TITANIUM:
			raw_id = MaterialEconomyScript.TITANIUM_ORE
			units = 2
			score_bonus = 380
			color = Color("8fb8e8")
			label = "TITANIUM ORE"
		WorldGridScript.MINERAL_SULFUR:
			raw_id = MaterialEconomyScript.SULFUR
			units = 2
			score_bonus = 175
			color = Color("ead447")
			label = "SULFUR CRYSTAL"
		WorldGridScript.MINERAL_COAL:
			raw_id = MaterialEconomyScript.COAL
			units = 4
			score_bonus = 95
			color = Color("45454b")
			label = "COAL SEAM"
		WorldGridScript.MINERAL_CACHE:
			payout = ScrapEconomyScript.SUPPLY_CACHE
			score_bonus = 400
			color = Color("ffd36b")
			label = "BURIED SUPPLY CACHE"
			_spawn_supply_cache_pickups(grid.cell_to_world(cell))
	var cargo_collected := true
	if not raw_id.is_empty():
		if _can_accept_units(units):
			material_economy.add_raw(raw_id, units)
		else:
			cargo_collected = false
			_spawn_pickup(grid.cell_to_world(cell), raw_id, units, Vector2(18.0, -22.0))
	_apply_scrap_delta(payout, "mineral_discovery")
	score += score_bonus
	exploration_find_count += 1
	discovery_alert = ("%s // +%d RAW // PACK %d/%d" % [label, units, _backpack_used(), _backpack_capacity()] if cargo_collected else "%s REVEALED // BACKPACK FULL // CARGO DROPPED" % label) if not raw_id.is_empty() else "%s // +$%d // COLLECT DROPS" % [label, payout]
	discovery_alert_time = 3.2
	_burst(grid.cell_to_world(cell), color, 22, 76.0)
	_award_exploration_streak()


func _spawn_supply_cache_pickups(at_position: Vector2) -> void:
	_spawn_pickup(at_position, PICKUP_PISTOL_AMMO, 18, Vector2(-24.0, -18.0))
	_spawn_pickup(at_position, PICKUP_SHOTGUN_AMMO, 6, Vector2(21.0, -24.0))
	_spawn_pickup(at_position, PICKUP_SMG_AMMO, 30, Vector2(-18.0, 23.0))
	_spawn_pickup(at_position, PICKUP_RAIL_AMMO, 2, Vector2(25.0, 18.0))


func _spawn_pickup(at_position: Vector2, kind: String, amount: int, launch_velocity: Vector2) -> void:
	var pickup := Pickup.new()
	pickup.position = at_position
	pickup.velocity = launch_velocity
	pickup.kind = kind
	pickup.amount = amount
	pickup.life = 600.0 if kind in MaterialEconomyScript.RAW_ORDER else 300.0
	pickup.phase = randf() * TAU
	pickups.append(pickup)


func _update_pickups(delta: float) -> void:
	for pickup_index in range(pickups.size() - 1, -1, -1):
		var pickup: Pickup = pickups[pickup_index]
		pickup.life -= delta
		if pickup.life <= 0.0:
			pickups.remove_at(pickup_index)
			continue
		pickup.velocity *= pow(0.09, delta)
		var to_player: Vector2 = player_position - pickup.position
		if to_player.length() < 54.0:
			pickup.velocity += to_player.normalized() * 210.0 * delta
		pickup.position += pickup.velocity * delta
		if pickup.position.distance_to(player_position) <= 10.0:
			if _collect_pickup(pickup):
				pickups.remove_at(pickup_index)
			else:
				pickup.velocity = (pickup.position - player_position).normalized() * 32.0


func _collect_pickup(pickup: Pickup) -> bool:
	var label := "SUPPLY"
	if pickup.kind in MaterialEconomyScript.RAW_ORDER:
		if not _can_accept_units(pickup.amount):
			discovery_alert = "BACKPACK FULL // %d/%d // CARGO REMAINS" % [_backpack_used(), _backpack_capacity()]
			discovery_alert_time = 1.2
			return false
		material_economy.add_raw(pickup.kind, pickup.amount)
		label = "%s +%d" % [_material_name(pickup.kind), pickup.amount]
		discovery_alert = "FIELD CARGO // %s // PACK %d/%d" % [label, _backpack_used(), _backpack_capacity()]
		discovery_alert_time = 1.8
		_burst(pickup.position, Color("8eeaff"), 10, 46.0)
		return true
	if not _try_add_ammo(pickup.kind, pickup.amount):
		discovery_alert = "BACKPACK FULL // AMMUNITION REMAINS"
		discovery_alert_time = 1.2
		return false
	match pickup.kind:
		PICKUP_PISTOL_AMMO:
			label = "PISTOL +%d" % pickup.amount
		PICKUP_SHOTGUN_AMMO:
			label = "SHELLS +%d" % pickup.amount
		PICKUP_SMG_AMMO:
			label = "SMG +%d" % pickup.amount
		PICKUP_RAIL_AMMO:
			label = "RAIL +%d" % pickup.amount
	discovery_alert = "FIELD PICKUP // %s" % label
	discovery_alert_time = 1.8
	_burst(pickup.position, Color("ffd36b"), 10, 46.0)
	return true


func _award_exploration_streak() -> void:
	if exploration_find_count > 0 and exploration_find_count % 6 == 0:
		_apply_scrap_delta(ScrapEconomyScript.EXPLORER_STREAK, "explorer_streak")
		score += 500
		discovery_alert = "EXPLORER BONUS // 6 FINDS +$%d" % ScrapEconomyScript.EXPLORER_STREAK
		discovery_alert_time = 3.5


func _discover_frontier_site(player_cell: Vector2i) -> void:
	for base_id: String in base_network.bases.keys():
		if base_id == BaseNetworkScript.COMMAND_ID:
			continue
		var record: Dictionary = base_network.bases[base_id]
		if bool(record.get("revealed", false)) or player_cell.distance_to(record["cell"]) > 7.0:
			continue
		record["revealed"] = true
		discovery_alert = "%s LOCATED // GUARDIAN SIGNATURE" % str(record["name"])
		discovery_alert_time = 4.5
		if _spawn_guardian(record["cell"]):
			enemies.back().guardian_site_id = base_id
		_burst(grid.cell_to_world(record["cell"]), Color("ffd36b"), 26, 86.0)


func _discovery_ambush_pack_size(discovery_type: String) -> int:
	var pressure := _combat_pressure_level()
	match discovery_type:
		"nest":
			return 4 + mini(4, floori(float(pressure) / 3.0))
		"ambush":
			return 8 + mini(8, pressure)
	return 0


func _resolve_mining_discovery(cell: Vector2i) -> void:
	var discovery_type := grid.reveal_discovery(cell)
	if discovery_type.is_empty():
		return
	_invalidate_visual_region(cell)
	hive_awareness.register_activity("discovery", grid.region_for_cell(cell))
	_mark_discovery_revealed(cell)
	match discovery_type:
		"nest":
			_establish_brood_nest(cell, 0.45)
			discovery_alert = "BROOD NEST EXPOSED // DESTROY BEFORE MATURITY"
			_queue_broodling_pack(cell, _discovery_ambush_pack_size("nest"))
		"guardian":
			grid.open_discovery_chamber(cell, 2)
			discovery_alert = "SEALED BROOD GUARDIAN AWAKENED"
			if not _spawn_guardian(cell):
				_queue_guardian_spawn(cell)
		"ambush":
			grid.open_discovery_chamber(cell, 1)
			discovery_alert = "EGG POCKET RUPTURE // AMBUSH"
			_queue_broodling_pack(cell, _discovery_ambush_pack_size("ambush"))
	discovery_alert_time = 4.5
	_mark_flow_region_dirty(grid.region_for_cell(cell))
	call_deferred("_rebuild_base_flows", false, false, true)
	_burst(grid.cell_to_world(cell), Color("b8f05b"), 24, 82.0)


func _update_weapon(delta: float) -> void:
	laser_active = false
	if current_weapon != WEAPON_LASER or suppress_primary_fire_until_release or not Input.is_action_pressed("fire"):
		laser_energy = minf(100.0, laser_energy + 17.0 * delta)

	if reload_time > 0.0:
		reload_time -= delta
		if reload_time <= 0.0:
			_finish_reload()
		return

	if not _hotbar_holds_weapon():
		return

	if Input.is_action_just_pressed("reload"):
		if current_weapon == WEAPON_PISTOL and magazine < _weapon_mag_capacity(WEAPON_PISTOL) and reserve_ammo > 0:
			reload_time = _weapon_reload_duration(WEAPON_PISTOL)
		elif current_weapon == WEAPON_SHOTGUN and shotgun_magazine < _weapon_mag_capacity(WEAPON_SHOTGUN) and shotgun_reserve > 0:
			reload_time = _weapon_reload_duration(WEAPON_SHOTGUN)
		elif current_weapon == WEAPON_SMG and smg_magazine < _weapon_mag_capacity(WEAPON_SMG) and smg_reserve > 0:
			reload_time = _weapon_reload_duration(WEAPON_SMG)
		elif current_weapon == WEAPON_RAILGUN and railgun_magazine < _weapon_mag_capacity(WEAPON_RAILGUN) and railgun_reserve > 0:
			reload_time = _weapon_reload_duration(WEAPON_RAILGUN)
		return

	if (not _hotbar_holds_weapon()) or relocating_structure_index >= 0 or suppress_primary_fire_until_release or not Input.is_action_pressed("fire") or shoot_cooldown > 0.0:
		return

	match current_weapon:
		WEAPON_PISTOL:
			_fire_pistol()
		WEAPON_SHOTGUN:
			_fire_shotgun()
		WEAPON_LASER:
			_fire_laser(delta)
		WEAPON_SMG:
			_fire_smg()
		WEAPON_RAILGUN:
			_fire_railgun()
		WEAPON_FLAMETHROWER:
			_fire_flamethrower()


func _finish_reload() -> void:
	if current_weapon == WEAPON_SHOTGUN:
		var shotgun_needed := _weapon_mag_capacity(WEAPON_SHOTGUN) - shotgun_magazine
		var shells_loaded := mini(shotgun_needed, shotgun_reserve)
		shotgun_magazine += shells_loaded
		shotgun_reserve -= shells_loaded
	elif current_weapon == WEAPON_SMG:
		var smg_needed := _weapon_mag_capacity(WEAPON_SMG) - smg_magazine
		var rounds_loaded := mini(smg_needed, smg_reserve)
		smg_magazine += rounds_loaded
		smg_reserve -= rounds_loaded
	elif current_weapon == WEAPON_RAILGUN:
		var rail_needed := _weapon_mag_capacity(WEAPON_RAILGUN) - railgun_magazine
		var slugs_loaded := mini(rail_needed, railgun_reserve)
		railgun_magazine += slugs_loaded
		railgun_reserve -= slugs_loaded
	else:
		var needed := _weapon_mag_capacity(WEAPON_PISTOL) - magazine
		var loaded := mini(needed, reserve_ammo)
		magazine += loaded
		reserve_ammo -= loaded


func _fire_pistol() -> void:
	if magazine <= 0:
		if reserve_ammo > 0:
			reload_time = _weapon_reload_duration(WEAPON_PISTOL)
		return
	magazine -= 1
	shoot_cooldown = _weapon_fire_interval(WEAPON_PISTOL) / fire_rate_multiplier
	muzzle_flash = 0.06
	muzzle_flash_max = 0.06
	var muzzle: Vector2 = _player_muzzle_position()
	_spawn_bullet(muzzle, aim_direction, 14.0 * _weapon_damage_scale(WEAPON_PISTOL), false, false, 2.0, 14.0, Color("ffd36b"))
	_burst(muzzle, Color("ffd56a"), 3, 28.0)


func _fire_shotgun() -> void:
	if shotgun_magazine <= 0:
		if shotgun_reserve > 0:
			reload_time = _weapon_reload_duration(WEAPON_SHOTGUN)
		return
	shotgun_magazine -= 1
	shoot_cooldown = _weapon_fire_interval(WEAPON_SHOTGUN) / fire_rate_multiplier
	muzzle_flash = 0.1
	muzzle_flash_max = 0.1
	var pellet_count := _weapon_shotgun_pellets()
	var total_spread := _weapon_shotgun_spread()
	var muzzle: Vector2 = _player_muzzle_position()
	for pellet_index in range(pellet_count):
		var spread := -total_spread * 0.5 + float(pellet_index) * (total_spread / float(maxi(1, pellet_count - 1))) + randf_range(-0.018, 0.018)
		var direction := aim_direction.rotated(spread)
		_spawn_bullet(muzzle, direction, 8.0 * _weapon_damage_scale(WEAPON_SHOTGUN), false, false, 2.0, 34.0, Color("ffb85c"), 0.55)
	_burst(muzzle, Color("ffbe63"), 10, 64.0)


func _fire_laser(delta: float) -> void:
	if laser_energy <= 0.0:
		return
	laser_active = true
	laser_visual_phase = fmod(laser_visual_phase + delta * 34.0, TAU)
	laser_energy = maxf(0.0, laser_energy - _weapon_laser_drain() * delta)
	var beam_start: Vector2 = _player_muzzle_position()
	var closest_projection: float = _ray_terrain_distance(beam_start, aim_direction, 176.0)
	laser_end = beam_start + aim_direction * closest_projection
	var hit_spider: Spider
	var hit_nest_index := -1
	for spider in enemies:
		var to_spider := spider.position - beam_start
		var projection := to_spider.dot(aim_direction)
		if projection < 0.0 or projection > closest_projection:
			continue
		var perpendicular := absf(to_spider.cross(aim_direction))
		if perpendicular <= spider.radius + 3.0:
			closest_projection = projection
			hit_spider = spider
	for nest_index in range(brood_nests.size()):
		var nest_position := grid.cell_to_world(brood_nests[nest_index].cell)
		var to_nest := nest_position - beam_start
		var projection := to_nest.dot(aim_direction)
		if projection < 0.0 or projection > closest_projection:
			continue
		if absf(to_nest.cross(aim_direction)) <= 11.0:
			closest_projection = projection
			hit_spider = null
			hit_nest_index = nest_index
	if hit_spider != null:
		laser_end = beam_start + aim_direction * closest_projection
		hit_spider.health -= 64.0 * _weapon_damage_scale(WEAPON_LASER) * delta
		hit_spider.hit_flash = 0.08
		hit_spider.hit_reaction = 0.12
		hit_spider.hit_recoil_direction = aim_direction
		if randf() < delta * 36.0:
			_burst(laser_end, Color("78eaff"), 3, 42.0)
		if hit_spider.health <= 0.0:
			var hit_index := enemies.find(hit_spider)
			if hit_index >= 0:
				_kill_spider(hit_index)
	elif hit_nest_index >= 0:
		laser_end = beam_start + aim_direction * closest_projection
		_damage_brood_nest(hit_nest_index, 64.0 * _weapon_damage_scale(WEAPON_LASER) * delta)


func _ray_terrain_distance(origin: Vector2, direction: Vector2, maximum_distance: float) -> float:
	var distance := 2.0
	while distance <= maximum_distance:
		if not grid.is_walkable(grid.world_to_cell(origin + direction * distance)):
			return maxf(0.0, distance - 1.5)
		distance += 2.0
	return maximum_distance


func _fire_smg() -> void:
	if smg_magazine <= 0:
		if smg_reserve > 0:
			reload_time = _weapon_reload_duration(WEAPON_SMG)
		return
	smg_magazine -= 1
	shoot_cooldown = _weapon_fire_interval(WEAPON_SMG) / fire_rate_multiplier
	muzzle_flash = 0.035
	muzzle_flash_max = 0.035
	var direction := aim_direction.rotated(randf_range(-_weapon_smg_spread(), _weapon_smg_spread()))
	_spawn_bullet(_player_muzzle_position(), direction, 8.5 * _weapon_damage_scale(WEAPON_SMG), false, false, 1.6, 6.0, Color("fff09a"), 0.85)


func _fire_railgun() -> void:
	if railgun_magazine <= 0:
		if railgun_reserve > 0:
			reload_time = _weapon_reload_duration(WEAPON_RAILGUN)
		return
	railgun_magazine -= 1
	shoot_cooldown = _weapon_fire_interval(WEAPON_RAILGUN) / fire_rate_multiplier
	muzzle_flash = 0.14
	muzzle_flash_max = 0.14
	var muzzle: Vector2 = _player_muzzle_position()
	_spawn_bullet(muzzle, aim_direction, 115.0 * _weapon_damage_scale(WEAPON_RAILGUN), false, false, 3.0, 72.0, Color("a7f4ff"), 1.8, _weapon_railgun_pierce())
	_burst(muzzle, Color("b8f7ff"), 16, 88.0)


func _fire_flamethrower() -> void:
	if not flamethrower_unlocked or flame_fuel < 5:
		if flame_fuel <= 0:
			discovery_alert = "FLAMETHROWER DRY // BUY FUEL AT SUPPLIES"
			discovery_alert_time = 1.4
		return
	flame_fuel = maxi(0, flame_fuel - 5)
	shoot_cooldown = 0.18 / fire_rate_multiplier
	muzzle_flash = 0.08
	muzzle_flash_max = 0.08
	var muzzle := _player_muzzle_position()
	var direct_damage := 15.0 * _weapon_damage_scale(WEAPON_FLAMETHROWER)
	for enemy_index in range(enemies.size() - 1, -1, -1):
		var spider: Spider = enemies[enemy_index]
		var offset := spider.position - muzzle
		if offset.length() > FLAMETHROWER_DIRECT_RANGE + spider.radius or absf(aim_direction.angle_to(offset.normalized())) > FLAMETHROWER_CONE_HALF_ANGLE:
			continue
		spider.health -= direct_damage
		spider.hit_flash = 0.10
		spider.hit_reaction = 0.12
		spider.hit_recoil_direction = aim_direction
		if spider.health <= 0.0:
			_kill_spider(enemy_index)
	var patch := FirePatch.new()
	patch.position = muzzle + aim_direction * 34.0
	patch.damage_per_second = 7.0 * _weapon_damage_scale(WEAPON_FLAMETHROWER)
	var flame_count := 0
	for existing: FirePatch in fire_patches:
		if not existing.player_only:
			flame_count += 1
	while flame_count >= FLAMETHROWER_PATCH_CAP:
		var removed := false
		for patch_index in range(fire_patches.size()):
			if not fire_patches[patch_index].player_only:
				fire_patches.remove_at(patch_index)
				flame_count -= 1
				removed = true
				break
		if not removed:
			break
	fire_patches.append(patch)
	_burst(patch.position, Color("ff8b35"), 9, 48.0)


func _weapon_damage_scale(weapon_id: int) -> float:
	return weapon_damage_multiplier * player_strength_multiplier * (1.0 + float(weapon_tiers[weapon_id] - 1) * 0.22)


func _weapon_mag_capacity(weapon_id: int, tier_override: int = -1, mag_tier_override: int = -1) -> int:
	var tier: int = weapon_tiers[weapon_id] if tier_override < 0 else tier_override
	var mag_tier: int = mag_upgrade_tiers[weapon_id] if mag_tier_override < 0 else mag_tier_override
	# Base mag bonus per mag_upgrade_tier: [+0, +2, +5, +9, +15] scaled per weapon
	var mag_bonus_table: Array[int] = [0, 2, 5, 9, 15]
	var mag_bonus: int = 0
	match weapon_id:
		WEAPON_PISTOL:
			mag_bonus = mag_bonus_table[clampi(mag_tier, 0, 4)]
			return 12 + (2 if tier >= 3 else 0) + (2 if tier >= 4 else 0) + mag_bonus
		WEAPON_SHOTGUN:
			mag_bonus = [0, 1, 2, 4, 6][clampi(mag_tier, 0, 4)]
			return 6 + (1 if tier >= 3 else 0) + (1 if tier >= 4 else 0) + mag_bonus
		WEAPON_SMG:
			mag_bonus = [0, 6, 14, 24, 40][clampi(mag_tier, 0, 4)]
			return 30 + (6 if tier >= 3 else 0) + (6 if tier >= 4 else 0) + mag_bonus
		WEAPON_RAILGUN:
			mag_bonus = [0, 1, 2, 3, 5][clampi(mag_tier, 0, 4)]
			return 3 + (1 if tier >= 4 else 0) + mag_bonus
	return 0


func _weapon_reload_duration(weapon_id: int, tier_override: int = -1) -> float:
	var tier: int = weapon_tiers[weapon_id] if tier_override < 0 else tier_override
	var base_duration: float = [0.82, 1.05, 0.0, 1.25, 1.55, 0.0][weapon_id]
	return base_duration * (1.0 - float(tier - 1) * 0.05)


func _weapon_fire_interval(weapon_id: int, tier_override: int = -1) -> float:
	var tier: int = weapon_tiers[weapon_id] if tier_override < 0 else tier_override
	var base_interval: float = [0.16, 0.68, 0.0, 0.075, 0.95, 0.18][weapon_id]
	return base_interval * (1.0 - float(tier - 1) * 0.04)


func _weapon_shotgun_pellets(tier_override: int = -1) -> int:
	var tier: int = weapon_tiers[WEAPON_SHOTGUN] if tier_override < 0 else tier_override
	return 7 + (1 if tier >= 3 else 0) + (1 if tier >= 4 else 0)


func _weapon_shotgun_spread(tier_override: int = -1) -> float:
	var tier: int = weapon_tiers[WEAPON_SHOTGUN] if tier_override < 0 else tier_override
	return 0.44 - float(tier - 1) * 0.025


func _weapon_laser_drain(tier_override: int = -1) -> float:
	var tier: int = weapon_tiers[WEAPON_LASER] if tier_override < 0 else tier_override
	return 31.0 * (1.0 - float(tier - 1) * 0.08)


func _weapon_smg_spread(tier_override: int = -1) -> float:
	var tier: int = weapon_tiers[WEAPON_SMG] if tier_override < 0 else tier_override
	return 0.055 * (1.0 - float(tier - 1) * 0.10)


func _weapon_railgun_pierce(tier_override: int = -1) -> int:
	var tier: int = weapon_tiers[WEAPON_RAILGUN] if tier_override < 0 else tier_override
	return 3 + (1 if tier >= 3 else 0) + (1 if tier >= 4 else 0)


func _begin_hostile_spawn_frame() -> void:
	hostile_spawn_budget_active = true
	hostile_spawn_budget_remaining = HOSTILE_SPAWN_FRAME_BUDGET


func _end_hostile_spawn_frame() -> void:
	_drain_pending_hostile_spawns(hostile_spawn_budget_remaining)
	hostile_spawn_budget_active = false
	hostile_spawn_budget_remaining = 0


func _hostile_spawn_slot_available() -> bool:
	return not hostile_spawn_budget_active or hostile_spawn_budget_remaining > 0


func _consume_hostile_spawn_slot() -> bool:
	if not hostile_spawn_budget_active:
		return true
	if hostile_spawn_budget_remaining <= 0:
		return false
	hostile_spawn_budget_remaining -= 1
	return true


func _queue_broodling_pack(at_cell: Vector2i, count: int, counts_for_wave: bool = false, sequence_offset: int = 0, source_tag: String = "") -> void:
	for pack_index in range(maxi(0, count)):
		if pending_hostile_spawns.size() >= HOSTILE_SPAWN_QUEUE_CAP:
			break
		pending_hostile_spawns.append({
			"kind": "broodling",
			"cell": at_cell,
			"pack_index": sequence_offset + pack_index,
			"counts_for_wave": counts_for_wave,
			"source_tag": source_tag,
		})
	# Release only via HOSTILE_SPAWN_FRAME_BUDGET — never instant-drain packs.


func _drain_pending_hostile_spawns(max_requests: int) -> int:
	if max_requests <= 0 or pending_hostile_spawns.is_empty():
		return 0
	var spawned := 0
	var attempts := mini(max_requests, pending_hostile_spawns.size())
	for unused in range(attempts):
		if not _hostile_spawn_slot_available() or pending_hostile_spawns.is_empty():
			break
		var request: Dictionary = pending_hostile_spawns.pop_front()
		var succeeded := false
		match str(request.get("kind", "")):
			"broodling":
				succeeded = _spawn_broodling(
					request.get("cell", Vector2i(-1, -1)),
					int(request.get("pack_index", 0)),
					bool(request.get("counts_for_wave", false))
				)
			"guardian":
				succeeded = _spawn_guardian(request.get("cell", Vector2i(-1, -1)))
				if succeeded and not str(request.get("guardian_site_id", "")).is_empty():
					enemies.back().guardian_site_id = str(request["guardian_site_id"])
		if succeeded:
			spawned += 1
		else:
			var request_cell: Vector2i = request.get("cell", Vector2i(-1, -1))
			var retries := int(request.get("retries", 0)) + 1
			if retries < 30 and grid.region_spawn_retryable(request_cell) and pending_hostile_spawns.size() < HOSTILE_SPAWN_QUEUE_CAP:
				request["retries"] = retries
				pending_hostile_spawns.append(request)
	return spawned


func _queue_guardian_spawn(at_cell: Vector2i, guardian_site_id: String = "") -> void:
	if pending_hostile_spawns.size() >= HOSTILE_SPAWN_QUEUE_CAP:
		return
	pending_hostile_spawns.append({
		"kind": "guardian",
		"cell": at_cell,
		"guardian_site_id": guardian_site_id,
	})


func _try_release_encounter() -> bool:
	if wave_active or not breached:
		return false
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var can_release := hive_awareness.can_release_encounter(
		breached,
		wave_active,
		grid.region_preload_pending(),
		grid.is_region_active(player_cell)
	)
	if not can_release:
		return false
	hive_awareness.consume_encounter()
	_start_encounter()
	return true


func _update_world_ecology(delta: float) -> void:
	# BV5.7: world ecology advances on a bounded 10 Hz clock, but a visible terrain
	# raster owns the frame. We retain at most one tick of debt instead of stacking
	# terrain + ecology work into the same hitch. Simulation may momentarily slow
	# under load; it must never try to "catch up" by creating another spike.
	world_ecology_accumulator = minf(
		world_ecology_accumulator + maxf(0.0, delta),
		WORLD_ECOLOGY_TICK_INTERVAL * float(WORLD_ECOLOGY_MAX_STEPS_PER_FRAME)
	)
	if _visible_terrain_raster_pending():
		return
	var steps := 0
	while world_ecology_accumulator + 0.000001 >= WORLD_ECOLOGY_TICK_INTERVAL and steps < WORLD_ECOLOGY_MAX_STEPS_PER_FRAME:
		ecology_tick_ran_this_frame = true
		_tick_world_ecology(WORLD_ECOLOGY_TICK_INTERVAL)
		world_ecology_accumulator -= WORLD_ECOLOGY_TICK_INTERVAL
		steps += 1


func _ecology_phase_begin() -> int:
	if gameplay_telemetry == null or not gameplay_telemetry.enabled:
		return 0
	return Time.get_ticks_usec()


func _ecology_phase_end(phase: String, started_us: int) -> void:
	if started_us <= 0 or gameplay_telemetry == null:
		return
	gameplay_telemetry.note_ecology_phase_cost(phase, Time.get_ticks_usec() - started_us)


func _tick_world_ecology(step: float) -> void:
	world_ecology_tick_sequence += 1
	hive_awareness.tick(step)
	_update_opening_contact(step)

	var started_us := _ecology_phase_begin()
	_update_scouts(step)
	_ecology_phase_end("scouts", started_us)

	started_us = _ecology_phase_begin()
	_update_missing_scouts(step)
	_ecology_phase_end("missing_scouts", started_us)

	started_us = _ecology_phase_begin()
	_update_encounter_delivery(step)
	_ecology_phase_end("encounter", started_us)

	# Heavier world systems are interleaved rather than executed together. Each
	# receives the elapsed 0.2 s it represents, so pacing stays correct while the
	# display thread only pays for one heavy ecology family per tick.
	if world_ecology_tick_sequence % 2 == 0:
		started_us = _ecology_phase_begin()
		_update_brood_nests(step * 2.0)
		_ecology_phase_end("brood", started_us)
	else:
		started_us = _ecology_phase_begin()
		_update_frontier_activation(step * 2.0)
		_ecology_phase_end("frontier", started_us)

	# Far-nest placement is rare and search-heavy. Service it at 2 Hz only while a
	# milestone is actually pending instead of touching it on every ecology tick.
	if _pending_far_nest_milestone >= 0 and world_ecology_tick_sequence % 5 == 0:
		started_us = _ecology_phase_begin()
		_update_pending_far_nest_retry(step * 5.0)
		_ecology_phase_end("far_nest", started_us)

	if gameplay_telemetry != null:
		gameplay_telemetry.note_pacing_state(
			hive_awareness.awareness_points,
			hive_awareness.awareness_tier,
			hive_awareness.exploration_pressure,
			encounters_completed,
			brood_nests.size(),
			hive_awareness.encounter_cooldown_remaining
		)


func _update_encounter_delivery(delta: float) -> void:
	# Hunting parties are delivery events, not tower-defense rounds. Once the
	# authorized party has entered the world, its members become ordinary ecology
	# entities and the encounter lifecycle ends immediately; there is no kill-all
	# cleanup phase, straggler recall, wave reward, or reroute timer.
	if not breached:
		return
	if not wave_active:
		_try_release_encounter()
		return
	if spawns_remaining <= 0:
		_finish_encounter_delivery()
		return

	var spawn_headroom := _encounter_spawn_headroom()
	if _simulation_enemy_count() >= spawn_headroom:
		spawn_cap_stall_elapsed += delta
		spawn_cooldown = maxf(0.0, spawn_cooldown - delta)
		return
	spawn_cap_stall_elapsed = 0.0
	spawn_cooldown -= delta
	if spawn_cooldown > 0.0:
		return

	var make_big := false # Guardians/bosses are world entities, never periodic encounter slots.
	if not _spawn_spider(make_big):
		spawn_cooldown = 0.2
		return
	if make_big:
		bosses_remaining -= 1
	boss_pending = bosses_remaining > 0
	var broodling_pack := int(current_wave_plan.get("broodling_pack", 0))
	var broodling_period := maxi(1, int(current_wave_plan.get("broodling_period", 99)))
	if broodling_pack > 0 and spawn_sequence % broodling_period == 0 and _simulation_enemy_count() + broodling_pack <= spawn_headroom:
		var brood_cell: Vector2i = _resolve_wave_spawn_cell(spawn_sequence)
		_queue_broodling_pack(brood_cell, broodling_pack, false, spawn_sequence * 17)
	spawns_remaining -= 1
	var interval := WaveDirectorScript.spawn_delay(current_wave_plan, spawn_sequence)
	spawn_cooldown = interval if not make_big else interval * 1.75
	if spawns_remaining <= 0:
		_finish_encounter_delivery()


func _finish_encounter_delivery() -> void:
	wave_active = false
	spawns_remaining = 0
	spawn_cap_stall_elapsed = 0.0
	wave_cleanup_elapsed = 0.0
	wave_reroute_elapsed = 0.0
	# XP remains available as an expedition progression source, but the award is
	# pressure-based and independent of encounter count. Kills retain their own loot.
	if not wave_reward_claimed:
		_award_expedition_xp()
		wave_reward_claimed = true
	_save_run()


func _update_waves(delta: float) -> void:
	_update_encounter_delivery(delta)


func _combat_pressure_level() -> int:
	return clampi(maxi(hive_awareness.awareness_tier + 1, brood_escalation + 1), 1, HiveAwarenessScript.MAX_TIER + 1)


func _encounter_spawn_headroom() -> int:
	return mini(_active_enemy_cap(), hive_awareness.regional_population_cap())


func _wave_spawn_headroom() -> int:
	# Legacy API wrapper. Live pacing is ecology/population based.
	return _encounter_spawn_headroom()


func _invalidate_wave_pressure_count() -> void:
	_wave_pressure_dirty = true


func _ensure_wave_pressure_count() -> int:
	if (
		not _wave_pressure_dirty
		and _wave_pressure_frame == _combat_frame_tick
		and _wave_pressure_enemy_count == enemies.size()
	):
		return _wave_pressure_nearby
	if (
		not _wave_pressure_dirty
		and (_combat_frame_tick - _wave_pressure_recompute_tick) < 4
		and spawn_cooldown > 0.0
	):
		return _wave_pressure_nearby
	_wave_pressure_nearby = _compute_wave_pressure_nearby()
	_wave_pressure_frame = _combat_frame_tick
	_wave_pressure_enemy_count = enemies.size()
	_wave_pressure_recompute_tick = _combat_frame_tick
	_wave_pressure_dirty = false
	return _wave_pressure_nearby


func _compute_wave_pressure_nearby() -> int:
	# Compatibility counter only. The old implementation performed per-mob distance
	# and route-viability probes merely to decide spawn pacing. Simulation-active
	# population is the open-world authority now.
	return _simulation_enemy_count()


func _wave_spawn_pressure_count() -> int:
	return _ensure_wave_pressure_count()


func _spider_is_simulation_active(spider: Spider) -> bool:
	if grid == null:
		return true
	return grid.loaded_regions.has(grid.region_for_cell(grid.world_to_cell(spider.position)))


func _simulation_enemy_count() -> int:
	var count := 0
	for spider: Spider in enemies:
		if _spider_is_simulation_active(spider):
			count += 1
	return count


func _spider_can_background_despawn(spider: Spider) -> bool:
	# Open-world hunting-party mobs behave like ordinary ecology and may retire once
	# far outside simulation. World-identity actors remain persistent.
	if spider.is_scout or spider.is_brood_carrier:
		return false
	if spider.role == ROLE_GUARDIAN or not spider.guardian_site_id.is_empty():
		return false
	if spider.brood_nest_cell != Vector2i(-1, -1):
		return false
	return true


func _active_enemy_cap() -> int:
	var active_bases := base_network.active_ids().size() if is_instance_valid(base_network) else 1
	return hive_awareness.population_cap(active_bases, grid.loaded_regions.size(), MAX_ACTIVE_ENEMIES)


func _aggressive_brood_nest_count() -> int:
	var count := 0
	for nest: BroodNest in brood_nests:
		if nest.aggressive:
			count += 1
	return count


func _brood_regional_budget_remaining() -> int:
	return maxi(0, hive_awareness.regional_population_cap() - _simulation_enemy_count())


func _brood_pulse_allowed() -> bool:
	return _simulation_enemy_count() < hive_awareness.regional_population_cap()


func _resolve_wave_spawn_cell(pattern_sequence: int) -> Vector2i:
	var salt := pattern_sequence + encounter_epoch * 101
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var local_spawn := _prepared_wave_spawn_cell_near(player_cell, 7, 15, salt, pattern_sequence)
	if local_spawn.x >= 0:
		return local_spawn
	local_spawn = _prepared_wave_spawn_cell_near(player_cell, 15, 22, salt + 991, pattern_sequence)
	if local_spawn.x >= 0:
		return local_spawn
	var primary_lane: Vector2i = grid.spawn_cell
	var spawn_at: Vector2i = grid.get_weighted_spawn_cell(pattern_sequence)
	if grid.uses_sparse_cells():
		if not _reachable_base_target_for_spawn(spawn_at, pattern_sequence).is_empty():
			return spawn_at
		if not _reachable_base_target_for_spawn(primary_lane, pattern_sequence).is_empty():
			return primary_lane
		return Vector2i(-1, -1)
	if not _spider_spawn_allowed_cell(spawn_at):
		return primary_lane if _spider_spawn_allowed_cell(primary_lane) else Vector2i(-1, -1)
	grid.connect_spawn_lane_to_core(spawn_at)
	if spawn_at == primary_lane:
		return primary_lane
	var target_base_id := base_network.choose_target(spawn_at, pattern_sequence, difficulty_id)
	var target_flow: FlowFieldScript = base_flows.get(target_base_id, flow)
	if target_flow != null and target_flow.has_path(spawn_at):
		return spawn_at
	if grid.ensure_spawn_lane_route(spawn_at):
		_refresh_spawn_lane_flow(spawn_at, target_base_id)
		target_flow = base_flows.get(target_base_id, flow)
		if target_flow != null and target_flow.has_path(spawn_at):
			return spawn_at
	return primary_lane if _spider_spawn_allowed_cell(primary_lane) else Vector2i(-1, -1)


func _spider_spawn_excluded(at_position: Vector2) -> bool:
	for base_id: String in base_network.active_ids(true):
		var base_position := grid.cell_to_world(base_network.get_cell(base_id))
		var exclusion_radius := float(base_network.territory_radius(base_id)) + CORE_SPAWN_EXCLUSION_PADDING_CELLS
		if at_position.distance_to(base_position) < exclusion_radius * float(grid.tile_size):
			return true
	for structure: Structure in structures:
		if structure.health <= 0.0:
			continue
		var safe_radius_cells: float = 0.0
		if structure.kind == BUILD_PERSONAL_BASE:
			safe_radius_cells = PERSONAL_BASE_SPAWN_EXCLUSION_CELLS
		elif structure.kind == BUILD_MERCHANT_STORE:
			safe_radius_cells = SettlementProgressionScript.MERCHANT_STORE_SAFE_RADIUS_CELLS
		if safe_radius_cells <= 0.0:
			continue
		var shelter_center := grid.cell_to_world(structure.cell) + Vector2(structure.size - Vector2i.ONE) * float(grid.tile_size) * 0.5
		if at_position.distance_to(shelter_center) < safe_radius_cells * float(grid.tile_size):
			return true
	return false


func _spider_spawn_allowed_cell(cell: Vector2i) -> bool:
	return grid.is_spawn_ready(cell) and not _spider_spawn_excluded(grid.cell_to_world(cell))


func _reachable_base_target_for_spawn(spawn_at: Vector2i, sequence: int) -> String:
	## Spawn admission is topological, not flow-field dependent. Barricades may
	## temporarily block combat movement, but a mob must start in terrain that has
	## a real authored route to at least one active base.
	if not _spider_spawn_allowed_cell(spawn_at):
		return ""
	var preferred := base_network.choose_target(spawn_at, sequence, difficulty_id)
	if not preferred.is_empty() and grid.has_walkable_route(spawn_at, base_network.get_cell(preferred)):
		return preferred
	var best_id := ""
	var best_distance := INF
	for base_id: String in base_network.active_ids(true):
		var base_cell := base_network.get_cell(base_id)
		if not grid.has_walkable_route(spawn_at, base_cell):
			continue
		var distance := spawn_at.distance_squared_to(base_cell)
		if distance < best_distance:
			best_distance = distance
			best_id = base_id
	return best_id


func _prepared_wave_spawn_cell_near(center: Vector2i, min_distance: int, max_distance: int, salt: int, sequence: int) -> Vector2i:
	# Keep the search bounded. The normal prepared-spawn helper already does the
	# expensive world-readiness filtering; this adds the route contract only at
	# encounter admission instead of burdening every ecology spawn.
	for attempt in range(16):
		var candidate := grid.prepared_spawn_cell_near(center, min_distance, max_distance, salt + attempt * 104729)
		if _reachable_base_target_for_spawn(candidate, sequence).is_empty():
			continue
		return candidate
	return Vector2i(-1, -1)


func _carrier_lane_spawn_ready(lane: Vector2i) -> bool:
	if not _spider_spawn_allowed_cell(lane):
		return false
	if grid.spawn_cells.has(lane):
		return true
	return grid.has_walkable_route(lane, grid.core_cell) or grid.has_walkable_route(lane, grid.spawn_cell)


func _prepared_spider_spawn_cell_near(center: Vector2i, min_distance: int, max_distance: int, salt: int) -> Vector2i:
	for attempt in range(48):
		var candidate := grid.prepared_spawn_cell_near(center, min_distance, max_distance, salt + attempt * 104729)
		if _spider_spawn_allowed_cell(candidate):
			return candidate
	return Vector2i(-1, -1)


func _spider_spawn_position(spawn_at: Vector2i, sequence: int, extra_seed: int = 0) -> Vector2:
	if not _spider_spawn_allowed_cell(spawn_at):
		return Vector2(INF, INF)
	for attempt in range(10):
		var candidate := grid.offset_spawn_position(spawn_at, sequence + attempt * 37, extra_seed + attempt * 7919)
		if not _spider_spawn_excluded(candidate):
			return candidate
	var center := grid.cell_to_world(spawn_at)
	return center if not _spider_spawn_excluded(center) else Vector2(INF, INF)


func _valid_spider_spawn_position(at_position: Vector2) -> bool:
	return is_finite(at_position.x) and is_finite(at_position.y) and not _spider_spawn_excluded(at_position)


func _award_wave_completion(allow_autosave: bool) -> void:
	# Deprecated compatibility wrapper. There is no wave-clear economy anymore;
	# preserve the old save-order contract for legacy tests/callers only.
	_award_expedition_xp()
	if allow_autosave:
		_save_run()


func _repair_wave_plan() -> void:
	if current_wave_plan.is_empty():
		current_wave_plan = WaveDirectorScript.build_encounter_plan(
			difficulty_id,
			hive_awareness.awareness_tier,
			brood_escalation,
			maxi(1, encounters_completed),
			grid.spawn_cells.size()
		)
		return
	var rebuilt := WaveDirectorScript.build_encounter_plan(
		difficulty_id,
		hive_awareness.awareness_tier,
		brood_escalation,
		maxi(1, encounters_completed),
		grid.spawn_cells.size()
	)
	for key: Variant in rebuilt.keys():
		if not current_wave_plan.has(key):
			current_wave_plan[key] = rebuilt[key]


func _restore_terrain_from_save(data: Dictionary, saved_version: int, legacy_upscale: bool, source_dimensions: Vector2i, saved_cells: Variant) -> bool:
	var saved_spawn := _decode_cells(data.get("spawn_cells", []))
	var breach_cell := Vector2i(-1, -1)
	var saved_breach: Variant = data.get("first_breach_cell", [])
	if saved_breach is Array and saved_breach.size() == 2:
		breach_cell = Vector2i(int(saved_breach[0]), int(saved_breach[1]))
	var lane_count := maxi(1, int(data.get("active_lane_count", maxi(1, saved_spawn.size()))))
	grid.prepare_resume_context(saved_spawn, breach_cell, lane_count)
	var saved_visited_regions: Dictionary = _decode_cell_dictionary(data.get("visited_regions", data.get("loaded_regions", {})))
	grid.restore_visited_regions_for_load(saved_visited_regions)
	for visited_region_value: Variant in grid.visited_regions.keys():
		discovered_biomes[visited_region_value] = grid.region_biome(visited_region_value)
	var saved_cell_deltas_value: Variant = data.get("cell_deltas", {})
	if saved_version >= 4:
		if not saved_cell_deltas_value is Dictionary:
			push_warning("Ignoring a sparse realm save without terrain deltas")
			return false
		grid.restore_cell_deltas(_decode_cell_dictionary(saved_cell_deltas_value))
	elif legacy_upscale:
		if not grid.restore_cells_upscaled(saved_cells, source_dimensions.x, source_dimensions.y):
			push_warning("Ignoring an invalid legacy terrain snapshot")
			return false
	else:
		if not grid.restore_legacy_cells(saved_cells):
			push_warning("Ignoring an invalid legacy terrain snapshot")
			return false
	grid.revealed_discoveries = _decode_cell_dictionary(data.get("revealed_discoveries", {}))
	grid.mined_minerals = _decode_cell_dictionary(data.get("mined_minerals", {}))
	explored_sectors = _decode_cell_dictionary(data.get("explored_sectors", {}))
	ruined_fortress_regions = _decode_cell_dictionary(data.get("ruined_fortress_regions", {}))
	exploration_find_count = int(data.get("exploration_find_count", 0))
	_reset_render_caches(true)
	return true


func _validate_generator_contract(data: Dictionary) -> bool:
	var saved_generator := int(data.get("generator_version", 0))
	if saved_generator <= 0:
		return true
	if saved_generator < WorldGridScript.GENERATOR_VERSION:
		push_warning("Realm generator version mismatch: save %d, runtime %d" % [saved_generator, WorldGridScript.GENERATOR_VERSION])
		return false
	if saved_generator != WorldGridScript.GENERATOR_VERSION:
		push_warning("Realm generator version mismatch: save %d, runtime %d" % [saved_generator, WorldGridScript.GENERATOR_VERSION])
	return true


func _start_encounter() -> void:
	encounters_completed += 1
	wave = encounters_completed # schema-14 historical mirror only; never gameplay authority
	encounter_epoch += 1
	wave_active = true # compatibility name: means encounter delivery is in progress
	_invalidate_wave_pressure_count()
	_update_hive_progression_for_encounter()
	current_wave_plan = WaveDirectorScript.build_encounter_plan(
		difficulty_id,
		hive_awareness.awareness_tier,
		brood_escalation,
		encounters_completed,
		grid.spawn_cells.size()
	)
	var encounter_lanes := int(current_wave_plan["active_lanes"])
	for lane_index in range(mini(encounter_lanes, grid.spawn_cells.size())):
		var lane_cell: Vector2i = grid.spawn_cells[lane_index]
		_mark_flow_region_dirty(grid.region_for_cell(lane_cell))
	_mark_flow_region_dirty(grid.region_for_cell(grid.core_cell))
	encounter_load_grace = maxf(encounter_load_grace, ENCOUNTER_FLOW_GRACE)
	call_deferred("_finalize_encounter_start", encounter_lanes)
	spawns_remaining = int(current_wave_plan["spawn_count"])
	var brood_pressure := minf(1.35, 1.0 + float(brood_escalation) * 0.08)
	spawns_remaining = ceili(float(spawns_remaining) * base_network.threat_multiplier() * brood_pressure)
	spawns_remaining = mini(spawns_remaining, hive_awareness.encounter_party_size())
	spawn_cooldown = 0.1
	bosses_remaining = int(current_wave_plan["boss_count"])
	boss_pending = bosses_remaining > 0
	spawn_sequence = 0
	wave_reward_claimed = false
	brood_carriers_remaining = int(current_wave_plan.get("brood_carriers", 0)) if brood_nests.size() < _active_brood_nest_cap() else 0
	wave_cleanup_elapsed = 0.0
	wave_reroute_elapsed = 0.0
	_encounter_special_lob_used = 0
	discovery_alert = "HUNTING PARTY // HIVE AWARENESS %s // DEFEND SETTLEMENT" % hive_awareness.tier_label()
	discovery_alert_time = 3.0
	hud_wave_flash = 0.45
	hud_objective_pulse = 0.35


func _start_wave() -> void:
	_start_encounter()


func _finalize_encounter_start(lane_count: int) -> void:
	grid.activate_lanes(maxi(1, lane_count))
	# Light partial — full 36-region rebuild hitch was 270–400ms on the mobilize frame.
	_rebuild_base_flows(false, false, true)
	encounter_load_grace = maxf(encounter_load_grace, 0.12)


func _spawn_spider(make_big: bool) -> bool:
	if not _hostile_spawn_slot_available():
		return false
	var spider := Spider.new()
	var pattern_sequence := spawn_sequence + encounter_epoch * 17
	var spawn_at: Vector2i = _resolve_wave_spawn_cell(pattern_sequence)
	var carrier_slot := int(current_wave_plan.get("brood_carrier_slot", -1))
	var carrier_requested := not make_big and brood_carriers_remaining > 0 and spawn_sequence >= carrier_slot and _active_brood_carrier_count() == 0
	if carrier_requested:
		var carrier_lane := grid.get_weighted_spawn_cell(pattern_sequence)
		if _carrier_lane_spawn_ready(carrier_lane):
			spawn_at = carrier_lane
	if not _spider_spawn_allowed_cell(spawn_at) or _simulation_enemy_count() >= _active_enemy_cap():
		return false
	var spawn_biome_id := _biome_for_cell(spawn_at)
	spider.position = _spider_spawn_position(spawn_at, pattern_sequence)
	if not _valid_spider_spawn_position(spider.position):
		return false
	spider.big = make_big
	spider.target_base_id = _reachable_base_target_for_spawn(spawn_at, pattern_sequence)
	if spider.target_base_id.is_empty():
		return false
	var pressure := _combat_pressure_level()
	if make_big:
		spider.role = ROLE_BRUTE
		spider.max_health = (220.0 + pressure * 18.0) * float(difficulty["enemy_health"]) * WaveDirectorScript.enemy_health_for_pressure(pressure)
		spider.health = spider.max_health
		spider.speed = MobLocomotionScript.brute_speed_for_pressure(pressure, float(difficulty["enemy_speed"]))
		spider.radius = 11.0
		if pressure >= 6:
			spider.spit_cooldown = randf_range(2.2, 4.0)
	else:
		var director_role := WaveDirectorScript.role_for_pressure(difficulty_id, pressure, pattern_sequence)
		spider.role = BiomeBestiaryScript.role_for_pressure(difficulty_id, pressure, pattern_sequence, spawn_biome_id, director_role)
		spider.max_health = (18.0 + pressure * 2.5) * float(difficulty["enemy_health"]) * WaveDirectorScript.enemy_health_for_pressure(pressure)
		spider.health = spider.max_health
		spider.speed = MobLocomotionScript.swarm_speed_for_pressure(spider.role == ROLE_SPITTER, pressure, float(difficulty["enemy_speed"]))
		spider.radius = 5.0
		if spider.role == ROLE_LEAPER:
			spider.max_health *= 1.25
			spider.health = spider.max_health
			spider.leap_cooldown = randf_range(1.0, 2.0)
		elif spider.role == ROLE_SPITTER:
			spider.max_health *= 1.4
			spider.health = spider.max_health
			spider.spit_cooldown = randf_range(1.0, 2.2)
		elif spider.role == ROLE_BRUTE:
			spider.max_health *= 2.2
			spider.health = spider.max_health
			spider.speed = MobLocomotionScript.brute_speed_for_pressure(pressure, float(difficulty["enemy_speed"])) * 1.08
			spider.radius = 8.0
			if pressure >= 6:
				spider.spit_cooldown = randf_range(2.2, 4.0)
	spider.counts_for_wave = false
	spider.hunts_turrets = _role_hunts_turrets(spider.role, pattern_sequence)
	spider.hunts_player = _role_hunts_player(spider.role, pattern_sequence)
	var assigned_carrier := false
	if carrier_requested:
		assigned_carrier = _assign_brood_carrier(spider, spawn_at)
		if assigned_carrier:
			brood_carriers_remaining = 0
	if not assigned_carrier:
		_assign_expedition_tactic(spider, pattern_sequence, not make_big)
	_assign_spider_biome(spider, spawn_at)
	if not _enemy_can_occupy(spider.position, spider.radius):
		spider.position = _resolve_guardian_spawn_position(spawn_at, spider.radius)
	if not _valid_spider_spawn_position(spider.position):
		return false
	if not _consume_hostile_spawn_slot():
		return false
	enemies.append(spider)
	if assigned_carrier:
		_process_pending_brood_carriers()
	spawn_sequence += 1
	return true


func _spawn_broodling(at_cell: Vector2i, pack_index: int = 0, counts_for_wave: bool = false) -> bool:
	if not _hostile_spawn_slot_available():
		return false
	var headroom := _active_enemy_cap() if counts_for_wave else _wave_spawn_headroom()
	if _simulation_enemy_count() >= headroom or not _spider_spawn_allowed_cell(at_cell):
		return false
	var spider := Spider.new()
	spider.role = ROLE_BROODLING
	spider.target_base_id = _reachable_base_target_for_spawn(at_cell, pack_index + spawn_sequence)
	if spider.target_base_id.is_empty():
		return false
	spider.position = _spider_spawn_position(at_cell, pack_index + spawn_sequence, 4099)
	if not _valid_spider_spawn_position(spider.position):
		return false
	spider.radius = 2.4
	var pressure := _combat_pressure_level()
	spider.max_health = (5.0 + float(pressure) * 0.7) * float(difficulty["enemy_health"]) * WaveDirectorScript.enemy_health_for_pressure(pressure)
	spider.health = spider.max_health
	spider.speed = MobLocomotionScript.broodling_speed_for_pressure(pressure, float(difficulty["enemy_speed"]))
	spider.stream_phase = float(pack_index) * 1.71 + randf_range(0.0, 1.0)
	spider.counts_for_wave = counts_for_wave
	_assign_spider_biome(spider, at_cell)
	_assign_expedition_tactic(spider, pack_index + spawn_sequence, true)
	if not _consume_hostile_spawn_slot():
		return false
	enemies.append(spider)
	return true


func _spawn_guardian(at_cell: Vector2i) -> bool:
	if not _hostile_spawn_slot_available() or _simulation_enemy_count() >= _active_enemy_cap() or not _spider_spawn_allowed_cell(at_cell):
		return false
	var spider := Spider.new()
	spider.role = ROLE_GUARDIAN
	spider.target_base_id = _reachable_base_target_for_spawn(at_cell, spawn_sequence + enemies.size())
	if spider.target_base_id.is_empty():
		return false
	spider.big = true
	spider.position = _resolve_guardian_spawn_position(at_cell, 14.0)
	if not _valid_spider_spawn_position(spider.position):
		return false
	spider.radius = 14.0
	var pressure := _combat_pressure_level()
	spider.max_health = (1250.0 + float(pressure) * 95.0) * float(difficulty["enemy_health"])
	spider.health = spider.max_health
	spider.speed = MobLocomotionScript.guardian_speed_for_pressure(pressure, float(difficulty["enemy_speed"]))
	spider.next_summon_ratio = 0.75
	spider.hunts_turrets = true
	spider.counts_for_wave = false
	spider.spit_cooldown = randf_range(2.5, 4.5)
	_assign_spider_biome(spider, at_cell)
	if not _consume_hostile_spawn_slot():
		return false
	enemies.append(spider)
	return true


func _active_brood_carrier_count() -> int:
	var count := 0
	for spider: Spider in enemies:
		if spider.is_brood_carrier:
			count += 1
	return count


func _wave_blocking_enemy_count() -> int:
	var count := 0
	for spider: Spider in enemies:
		if spider.counts_for_wave:
			count += 1
	return count


func _default_counts_for_wave(spider: Spider) -> bool:
	if spider.is_brood_carrier or spider.role in [ROLE_BROODLING, ROLE_GUARDIAN]:
		return false
	return true


func _normalize_spider_wave_count(spider: Spider) -> void:
	# counts_for_wave is retained in schema 14 only so older saves load. New runtime
	# ecology has no kill-all wave membership.
	spider.counts_for_wave = false
	spider.cleanup_recalled = false


func _recall_wave_stragglers() -> void:
	var recalled := 0
	for spider: Spider in enemies:
		if not spider.counts_for_wave or spider.cleanup_recalled:
			continue
		# Stragglers still in active combat range keep their current routing;
		# flipping them to cleanup pull mid-fight reads as a position reset.
		if spider.position.distance_to(player_position) <= WAVE_RELOCATE_PLAYER_SAFE_RADIUS:
			continue
		spider.is_explorer = false
		spider.cleanup_recalled = true
		spider.target_base_id = base_network.nearest_active(grid.world_to_cell(spider.position))
		if spider.target_base_id.is_empty():
			spider.target_base_id = BaseNetworkScript.COMMAND_ID
		recalled += 1
	if recalled > 0:
		discovery_alert = "SWEEP PHASE // %d STRAGGLER%s RECALLED" % [recalled, "" if recalled == 1 else "S"]
		discovery_alert_time = 3.0
	wave_cleanup_elapsed = -9999.0


func _spider_combat_target_position(spider: Spider) -> Vector2:
	var targeted_torch_index := _torch_target_for(spider)
	if targeted_torch_index >= 0:
		return structures[targeted_torch_index].position
	var targeted_turret_index := _turret_target_for(spider)
	if targeted_turret_index >= 0:
		return structures[targeted_turret_index].position
	if spider.is_explorer and spider.explorer_route_index >= 0 and spider.explorer_route_index < explorer_targets.size():
		return grid.cell_to_world(explorer_targets[spider.explorer_route_index])
	if spider.hunts_player:
		return player_position
	return grid.cell_to_world(base_network.get_cell(spider.target_base_id))


func _local_route_viable_read_only(spider: Spider, from_cell: Vector2i, target_cell: Vector2i, body_radius: float) -> bool:
	## Lightweight, side-effect-free route viability probe. Pressure accounting and
	## spawn admission must never construct or rewrite a mob's committed fallback
	## route; only the movement loop owns that state.
	if from_cell == target_cell:
		return true
	if (
		spider.fallback_route_from == from_cell
		and spider.fallback_route_target == target_cell
		and spider.fallback_route_next != INVALID_ROUTE_CELL
		and _enemy_can_occupy(grid.cell_to_world(spider.fallback_route_next), body_radius)
	):
		return true
	return _greedy_step_toward(from_cell, target_cell, body_radius) != from_cell


func _spider_route_viable_light(spider: Spider) -> bool:
	if spider.route_flow_epoch != flow_epoch:
		spider.route_flow_epoch = flow_epoch
		spider.route_check_tick = -999
	if (_combat_frame_tick - spider.route_check_tick) < SPIDER_ROUTE_CHECK_INTERVAL:
		return spider.route_viable_cache
	spider.route_check_tick = _combat_frame_tick
	var current_cell: Vector2i = grid.world_to_cell(spider.position)
	var target_flow: FlowFieldScript = base_flows.get(spider.target_base_id, flow)
	if target_flow != null and target_flow.has_path(current_cell):
		spider.route_viable_cache = true
		return true
	if spider.hunts_player and player_flow.has_path(current_cell):
		spider.route_viable_cache = true
		return true
	if spider.is_explorer and spider.explorer_route_index >= 0 and spider.explorer_route_index < explorer_flows.size():
		if explorer_flows[spider.explorer_route_index].has_path(current_cell):
			spider.route_viable_cache = true
			return true
	var route_target: Vector2 = player_position if spider.hunts_player else grid.cell_to_world(base_network.get_cell(spider.target_base_id))
	var target_cell: Vector2i = grid.world_to_cell(route_target)
	if _local_route_viable_read_only(spider, current_cell, target_cell, spider.radius):
		spider.route_viable_cache = true
		return true
	spider.route_viable_cache = spider.locomotion_stall < 0.6
	return spider.route_viable_cache


func _spider_has_viable_route(spider: Spider) -> bool:
	if (_combat_frame_tick - spider.route_check_tick) < SPIDER_ROUTE_CHECK_INTERVAL:
		return spider.route_viable_cache
	if _spider_route_viable_light(spider):
		return true
	var current_cell: Vector2i = grid.world_to_cell(spider.position)
	var target_cell: Vector2i = grid.world_to_cell(_spider_combat_target_position(spider))
	if _local_route_step_toward(spider, current_cell, target_cell, spider.radius) != current_cell:
		spider.route_viable_cache = true
		return true
	spider.route_viable_cache = false
	return false


func _spider_has_wave_route(spider: Spider) -> bool:
	return _spider_has_viable_route(spider)


func _reposition_unreachable_wave_spiders() -> int:
	var relocated := 0
	for spider: Spider in enemies:
		if relocated >= MAX_WAVE_RELOCATIONS_PER_TICK:
			break
		if not spider.counts_for_wave or spider.cleanup_recalled or spider.is_brood_carrier:
			continue
		if _spider_has_viable_route(spider):
			continue
		if spider.position.distance_to(player_position) <= WAVE_RELOCATE_PLAYER_SAFE_RADIUS:
			_mark_flow_region_dirty(grid.region_for_cell(grid.world_to_cell(spider.position)))
			continue
		if spider.locomotion_stall < WAVE_RELOCATE_MIN_STALL:
			continue
		if spider.position.distance_to(grid.cell_to_world(grid.core_cell)) < 120.0:
			continue
		var recover_target := _spider_combat_target_position(spider)
		var recover_direction := (recover_target - spider.position).normalized()
		if recover_direction.is_zero_approx():
			recover_target = grid.cell_to_world(grid.core_cell)
			recover_direction = (recover_target - spider.position).normalized()
		_recover_stuck_spider_to(spider, recover_direction, recover_target)
		# Recovery changed the mob's cell/occupancy context; do not immediately reuse
		# the pre-recovery negative viability cache when deciding whether to relocate.
		spider.route_check_tick = -999
		if _spider_has_viable_route(spider):
			spider.locomotion_stall = 0.0
			continue
		var spawn_at: Vector2i = Vector2i(-1, -1)
		var command_flow: FlowFieldScript = base_flows.get(BaseNetworkScript.COMMAND_ID, flow)
		var best_dist := INF
		for lane_value: Variant in grid.spawn_cells:
			var lane: Vector2i = lane_value
			if command_flow != null and not command_flow.has_path(lane) and not grid.has_walkable_route(lane, grid.core_cell):
				continue
			var dist := spider.position.distance_squared_to(grid.cell_to_world(lane))
			if dist < best_dist:
				best_dist = dist
				spawn_at = lane
		if spawn_at.x < 0:
			var player_cell: Vector2i = grid.world_to_cell(player_position)
			spawn_at = _prepared_spider_spawn_cell_near(player_cell, 7, 18, spawn_sequence + relocated + encounter_epoch * 13)
		else:
			spawn_at = _prepared_spider_spawn_cell_near(spawn_at, 2, 10, spawn_sequence + relocated + encounter_epoch * 13)
		var relocated_position := _spider_spawn_position(spawn_at, spawn_sequence + relocated + encounter_epoch)
		if not _valid_spider_spawn_position(relocated_position):
			continue
		spider.position = relocated_position
		var relocated_target := _reachable_base_target_for_spawn(spawn_at, spawn_sequence + relocated)
		if not relocated_target.is_empty():
			spider.target_base_id = relocated_target
		_clear_fallback_route(spider)
		spider.locomotion_stall = 0.0
		relocated += 1
	if relocated > 0:
		discovery_alert = "ROUTE RE-SEED // %d HOSTILE%s RELOCATED" % [relocated, "" if relocated == 1 else "S"]
		discovery_alert_time = 2.5
		_invalidate_wave_pressure_count()
	return relocated


func _assign_brood_carrier(spider: Spider, from_cell: Vector2i) -> bool:
	if pending_brood_carrier_requests.size() >= MAX_PENDING_BROOD_CARRIER_REQUESTS:
		return false
	pending_brood_carrier_requests.append({"spider": spider, "from_cell": from_cell})
	return true


func _process_pending_brood_carriers() -> void:
	if pending_brood_carrier_requests.is_empty():
		return
	var request: Dictionary = pending_brood_carrier_requests.pop_front()
	var spider: Spider = request.get("spider")
	if spider == null:
		return
	var from_cell: Vector2i = request.get("from_cell", Vector2i.ZERO)
	var target := _choose_brood_nest_site(from_cell)
	if target.x < 0:
		return
	spider.is_brood_carrier = true
	spider.carrier_target_cell = target
	spider.carrier_channel = 0.0
	spider.carrier_stall_time = 0.0
	spider.is_explorer = false
	spider.hunts_player = false
	spider.hunts_turrets = false
	spider.counts_for_wave = false
	spider.max_health *= 1.65
	spider.health = spider.max_health
	discovery_alert = "BROOD CARRIER DETECTED // INTERCEPT BEFORE NESTING"
	discovery_alert_time = 5.0


func _brood_carrier_origin_cells(primary: Vector2i) -> Array[Vector2i]:
	var origins: Array[Vector2i] = [primary]
	for spawn_cell: Vector2i in grid.spawn_cells:
		if not origins.has(spawn_cell):
			origins.append(spawn_cell)
	return origins


func _brood_carrier_can_reach(from_cells: Array[Vector2i], target: Vector2i) -> bool:
	var carrier_flow := _flow_for_brood_target(target)
	if carrier_flow == null:
		return false
	for from_cell: Vector2i in from_cells:
		if carrier_flow.has_path(from_cell):
			return true
	return false


func _demote_brood_carrier(spider: Spider) -> void:
	if not spider.is_brood_carrier:
		return
	var abandoned_target := spider.carrier_target_cell
	spider.is_brood_carrier = false
	spider.carrier_target_cell = Vector2i(-1, -1)
	spider.carrier_channel = 0.0
	spider.carrier_stall_time = 0.0
	brood_carrier_flows.erase(abandoned_target)
	var pattern_sequence := grid.world_to_cell(spider.position).x + grid.world_to_cell(spider.position).y * 17 + encounter_epoch * 3
	spider.hunts_turrets = _role_hunts_turrets(spider.role, pattern_sequence)
	spider.hunts_player = _role_hunts_player(spider.role, pattern_sequence)
	spider.counts_for_wave = false
	_assign_expedition_tactic(spider, pattern_sequence, false)


func _choose_brood_nest_site(from_cell: Vector2i) -> Vector2i:
	var candidates: Array[Vector2i] = []
	var seeded_candidates: Array[Vector2i] = []
	var origin_cells := _brood_carrier_origin_cells(from_cell)
	for cell_value: Variant in grid.discovery_cells.keys():
		var cell: Vector2i = cell_value
		if str(grid.discovery_cells[cell]) == "nest" and not grid.revealed_discoveries.has(cell) and _brood_site_geometry_ok(cell):
			seeded_candidates.append(cell)
			candidates.append(cell)
	if candidates.is_empty():
		var scannable_regions: Array[Vector2i] = []
		var seen_regions: Dictionary = {}
		for region_value: Variant in grid.visited_regions.keys():
			var region: Vector2i = region_value
			if seen_regions.has(region):
				continue
			seen_regions[region] = true
			scannable_regions.append(region)
		for region_value: Variant in grid.loaded_regions.keys():
			var region: Vector2i = region_value
			if seen_regions.has(region):
				continue
			seen_regions[region] = true
			scannable_regions.append(region)
		scannable_regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
			var left_center := left * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
			var right_center := right * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
			return left_center.distance_squared_to(from_cell) < right_center.distance_squared_to(from_cell)
		)
		var scanned_regions := 0
		for region: Vector2i in scannable_regions:
			if scanned_regions >= NEST_SITE_REGION_SCAN_CAP or candidates.size() >= NEST_SITE_FLOW_CHECK_CAP * 4:
				break
			scanned_regions += 1
			var bounds := grid._region_bounds(region)
			for y in range(bounds.position.y, bounds.end.y, 2):
				for x in range(bounds.position.x, bounds.end.x, 2):
					var cell := Vector2i(x, y)
					# Hash gate before expensive geometry / ownership checks.
					if posmod(RealmVisualStyleScript.stable_cell_hash(run_seed, cell, encounter_epoch + 421), 19) != 0:
						continue
					if grid.discovery_cells.has(cell) or not grid.get_mineral_type(cell).is_empty() or not _brood_site_geometry_ok(cell):
						continue
					candidates.append(cell)
					if candidates.size() >= NEST_SITE_FLOW_CHECK_CAP * 4:
						break
				if candidates.size() >= NEST_SITE_FLOW_CHECK_CAP * 4:
					break
	if candidates.is_empty():
		return Vector2i(-1, -1)
	candidates = candidates.slice(0, mini(candidates.size(), NEST_SITE_FLOW_CHECK_CAP * 4))
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return posmod(RealmVisualStyleScript.stable_cell_hash(run_seed, a, encounter_epoch + 719), 1000003) < posmod(RealmVisualStyleScript.stable_cell_hash(run_seed, b, encounter_epoch + 719), 1000003)
	)
	var flow_checks := 0
	for candidate: Vector2i in candidates:
		if flow_checks >= NEST_SITE_FLOW_CHECK_CAP:
			break
		flow_checks += 1
		if _brood_nest_approach(candidate).x < 0:
			continue
		if _brood_carrier_can_reach(origin_cells, candidate):
			grid.discovery_cells[candidate] = "nest"
			return candidate
	if not seeded_candidates.is_empty():
		seeded_candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			return a.distance_squared_to(from_cell) < b.distance_squared_to(from_cell)
		)
		return seeded_candidates[0]
	var frontier_target := _choose_brood_nest_site_from_frontier(from_cell, origin_cells, NEST_SITE_FLOW_CHECK_CAP - flow_checks)
	return frontier_target


func _choose_brood_nest_site_from_frontier(from_cell: Vector2i, origin_cells: Array[Vector2i], flow_check_budget: int = NEST_SITE_FLOW_CHECK_CAP) -> Vector2i:
	var frontier: Array[Vector2i] = [from_cell]
	var visited: Dictionary = {from_cell: true}
	var hash_matches: Array[Vector2i] = []
	var fallback_matches: Array[Vector2i] = []
	var head := 0
	while head < frontier.size() and head < NEST_SITE_FRONTIER_VISIT_CAP:
		var current: Vector2i = frontier[head]
		head += 1
		_collect_brood_chamber_candidate(current, from_cell, hash_matches, fallback_matches)
		for direction: Vector2i in FlowFieldScript.DIRECTIONS:
			var chamber := current + direction
			if grid.can_mine(chamber):
				_collect_brood_chamber_candidate(chamber, from_cell, hash_matches, fallback_matches)
		if current.distance_to(from_cell) > _brood_frontier_search_radius():
			continue
		for direction: Vector2i in FlowFieldScript.DIRECTIONS:
			var neighbor := current + direction
			if not grid.in_bounds(neighbor) or visited.has(neighbor) or not grid.is_walkable(neighbor):
				continue
			visited[neighbor] = true
			frontier.append(neighbor)
	var pool: Array[Vector2i] = hash_matches if not hash_matches.is_empty() else fallback_matches
	if pool.is_empty():
		return Vector2i(-1, -1)
	pool.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.distance_squared_to(from_cell) < b.distance_squared_to(from_cell)
	)
	var flow_checks := 0
	for candidate: Vector2i in pool:
		if flow_checks >= maxi(flow_check_budget, 0):
			break
		flow_checks += 1
		if _brood_carrier_can_reach(origin_cells, candidate):
			grid.discovery_cells[candidate] = "nest"
			return candidate
	var nearest := pool[0]
	grid.discovery_cells[nearest] = "nest"
	return nearest


func _collect_brood_chamber_candidate(cell: Vector2i, from_cell: Vector2i, hash_matches: Array[Vector2i], fallback_matches: Array[Vector2i]) -> void:
	if not grid.can_mine(cell) or grid.discovery_cells.has(cell) or not _brood_site_geometry_ok(cell):
		return
	if posmod(RealmVisualStyleScript.stable_cell_hash(run_seed, cell, encounter_epoch + 421), 19) == 0:
		hash_matches.append(cell)
	elif fallback_matches.size() < 16:
		fallback_matches.append(cell)


func _brood_site_geometry_ok(cell: Vector2i) -> bool:
	if not grid.can_mine(cell) or destroyed_brood_nests.has(cell) or _brood_nest_index_at_cell(cell) >= 0:
		return false
	if _spider_spawn_excluded(grid.cell_to_world(cell)):
		return false
	if cell.distance_to(grid.world_to_cell(player_position)) < _nest_min_player_cells():
		return false
	for base_id: String in base_network.active_ids(true):
		if base_network.owns_cell(base_id, cell):
			return false
	for nest: BroodNest in brood_nests:
		if cell.distance_to(nest.cell) < _nest_spacing_cells():
			return false
	return true


func _brood_site_is_valid(cell: Vector2i) -> bool:
	return _brood_site_geometry_ok(cell) and _brood_nest_approach(cell).x >= 0


func _realm_span() -> float:
	return grid.realm_span()


func _nest_min_player_cells() -> float:
	return maxf(28.0, _realm_span() * 0.14)


func _nest_min_base_cells() -> float:
	return maxf(80.0, _realm_span() * 0.42)


func _nest_spacing_cells() -> float:
	return maxf(30.0, _realm_span() * 0.16)


func _nest_relocate_min_player_cells() -> float:
	return maxf(48.0, _realm_span() * 0.24)


func _brood_frontier_search_radius() -> float:
	return maxf(150.0, _realm_span() * 0.72)


func _brood_nest_approach(cell: Vector2i, prefer_from: Vector2i = Vector2i(-9999, -9999)) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_score := INF
	for direction: Vector2i in FlowFieldScript.DIRECTIONS:
		var approach := cell + direction
		if not grid.is_walkable(approach):
			continue
		var score := approach.distance_squared_to(prefer_from) if prefer_from.x > -9000 else 0.0
		if score < best_score:
			best = approach
			best_score = score
	return best


func _resolve_guardian_spawn_position(anchor_cell: Vector2i, radius: float) -> Vector2:
	var candidates: Array[Vector2] = []
	var center := grid.cell_to_world(anchor_cell)
	var approach := _brood_nest_approach(anchor_cell, grid.world_to_cell(player_position))
	if approach.x >= 0:
		candidates.append(grid.cell_to_world(approach))
		candidates.append(grid.offset_spawn_position(approach, 0, 7717))
	candidates.append(center)
	candidates.append(grid.offset_spawn_position(anchor_cell, 0, 9191))
	var away := (center - player_position).normalized()
	if away.is_zero_approx():
		away = Vector2.RIGHT
	for step in range(2, 7):
		var offset_cell := anchor_cell + Vector2i(roundi(away.x * step), roundi(away.y * step))
		if grid.is_walkable(offset_cell):
			candidates.append(grid.offset_spawn_position(offset_cell, step, 4403))
	for candidate: Vector2 in candidates:
		if not _spider_spawn_excluded(candidate) and _enemy_can_occupy(candidate, radius):
			return candidate
	for step in range(4, 224, 8):
		var probe := center + away * float(step)
		if not _spider_spawn_excluded(probe) and grid.is_region_active(grid.world_to_cell(probe)) and _enemy_can_occupy(probe, radius * 0.75):
			return probe
	var fallback_cell := _prepared_spider_spawn_cell_near(anchor_cell, 1, 28, run_seed ^ anchor_cell.x * 31337 ^ anchor_cell.y * 6971)
	if _spider_spawn_allowed_cell(fallback_cell):
		var fallback_position := _spider_spawn_position(fallback_cell, spawn_sequence, 4403)
		if _valid_spider_spawn_position(fallback_position) and _enemy_can_occupy(fallback_position, radius * 0.75):
			return fallback_position
	return Vector2(INF, INF)


func _spawn_nest_pressure_spider(nest: BroodNest) -> void:
	if not _hostile_spawn_slot_available() or _simulation_enemy_count() >= _wave_spawn_headroom() or not _spider_spawn_allowed_cell(nest.cell):
		return
	var spider := Spider.new()
	var pressure := _combat_pressure_level()
	var pattern_sequence := nest.pressure_pulses + pressure * 11 + spawn_sequence
	var spawn_at := nest.cell
	var spawn_biome_id := _biome_for_cell(spawn_at)
	spider.position = _spider_spawn_position(spawn_at, pattern_sequence, 7717)
	if not _valid_spider_spawn_position(spider.position):
		return
	spider.target_base_id = _reachable_base_target_for_spawn(spawn_at, pattern_sequence)
	if spider.target_base_id.is_empty():
		return
	var use_brute := pressure >= 10 and nest.pressure_pulses % 6 == 0
	if use_brute:
		spider.role = ROLE_BRUTE
		spider.big = true
		spider.max_health = (220.0 + pressure * 18.0) * float(difficulty["enemy_health"]) * WaveDirectorScript.enemy_health_for_pressure(pressure)
		spider.health = spider.max_health
		spider.speed = MobLocomotionScript.brute_speed_for_pressure(pressure, float(difficulty["enemy_speed"]))
		spider.radius = 11.0
	else:
		var director_role := WaveDirectorScript.role_for_pressure(difficulty_id, pressure, pattern_sequence)
		spider.role = BiomeBestiaryScript.role_for_pressure(difficulty_id, pressure, pattern_sequence, spawn_biome_id, director_role)
		spider.max_health = (18.0 + pressure * 2.5) * float(difficulty["enemy_health"]) * WaveDirectorScript.enemy_health_for_pressure(pressure)
		spider.health = spider.max_health
		spider.speed = MobLocomotionScript.swarm_speed_for_pressure(spider.role == ROLE_SPITTER, pressure, float(difficulty["enemy_speed"]))
		spider.radius = 5.0
		if spider.role == ROLE_LEAPER:
			spider.max_health *= 1.25
			spider.health = spider.max_health
			spider.leap_cooldown = randf_range(1.0, 2.0)
		elif spider.role == ROLE_SPITTER:
			spider.max_health *= 1.4
			spider.health = spider.max_health
			spider.spit_cooldown = randf_range(1.0, 2.2)
		elif spider.role == ROLE_BRUTE:
			spider.max_health *= 2.2
			spider.health = spider.max_health
			spider.speed = MobLocomotionScript.brute_speed_for_pressure(pressure, float(difficulty["enemy_speed"])) * 1.08
			spider.radius = 8.0
			if pressure >= 6:
				spider.spit_cooldown = randf_range(2.2, 4.0)
	spider.hunts_turrets = _role_hunts_turrets(spider.role, pattern_sequence)
	spider.hunts_player = _role_hunts_player(spider.role, pattern_sequence)
	spider.counts_for_wave = false
	_assign_spider_biome(spider, spawn_at)
	_assign_expedition_tactic(spider, pattern_sequence, not use_brute)
	if not _enemy_can_occupy(spider.position, spider.radius):
		spider.position = _resolve_guardian_spawn_position(spawn_at, spider.radius)
	if not _valid_spider_spawn_position(spider.position):
		return
	if not _consume_hostile_spawn_slot():
		return
	enemies.append(spider)


func _flow_for_brood_target(cell: Vector2i) -> FlowFieldScript:
	if brood_carrier_flows.has(cell):
		return brood_carrier_flows[cell]
	var approach := _brood_nest_approach(cell)
	if approach.x < 0:
		return null
	var carrier_flow := FlowFieldScript.new()
	carrier_flow.rebuild(grid, approach, _flow_allowed_regions([approach, cell]))
	brood_carrier_flows[cell] = carrier_flow
	return carrier_flow


func _steer_spider(spider: Spider, desired_direction: Vector2, delta: float, steer_rate: float = 7.5) -> Vector2:
	# A self-cell destination is a stop signal, not an instruction to keep the
	# previous heading. Preserving the old heading here was feeding the stall
	# recovery loop and visually producing orbiting/spiraling mobs.
	if desired_direction.is_zero_approx():
		spider.steer_direction = Vector2.ZERO
		return Vector2.ZERO
	if spider.steer_direction.length_squared() <= 0.0001:
		spider.steer_direction = desired_direction
	else:
		spider.steer_direction = spider.steer_direction.lerp(desired_direction, minf(1.0, delta * steer_rate)).normalized()
	return spider.steer_direction


func _structure_blocks_enemy(structure: Structure) -> bool:
	if structure.kind == BUILD_HEAVY_DOORWAY:
		return not structure.is_open
	return structure.kind in [BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER]


func _cell_blocks_enemy(cell: Vector2i) -> bool:
	if not grid.is_walkable(cell):
		return true
	return _enemy_blocked_cells.has(cell)


const _GREEDY_CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
]
const _GREEDY_DIAGONAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]


func _cell_routing_openness(cell: Vector2i) -> int:
	var open := 0
	for direction in _GREEDY_CARDINAL_DIRECTIONS:
		var neighbor := cell + direction
		if grid.is_walkable(neighbor) and not _cell_blocks_enemy(neighbor):
			open += 1
	return open


# Wall-aware single step used when no flow field covers the mob's region yet
# (lazily-materializing frontier, or a siege outrunning flow rebuilds). Cardinals
# first; ties prefer open cells so Euclidean greedy does not sink into corners.
func _greedy_step_toward(from_cell: Vector2i, target_cell: Vector2i, body_radius: float = 5.0) -> Vector2i:
	if from_cell == target_cell:
		return from_cell
	var best := _best_greedy_neighbor(from_cell, target_cell, body_radius, _GREEDY_CARDINAL_DIRECTIONS)
	if best != from_cell:
		return best
	return _best_greedy_neighbor(from_cell, target_cell, body_radius, _GREEDY_DIAGONAL_DIRECTIONS)


func _best_greedy_neighbor(from_cell: Vector2i, target_cell: Vector2i, body_radius: float, directions: Array[Vector2i]) -> Vector2i:
	var best_cell := from_cell
	var best_distance: float = from_cell.distance_squared_to(target_cell)
	var best_open := _cell_routing_openness(from_cell)
	for direction in directions:
		var candidate := from_cell + direction
		if not _enemy_can_occupy(grid.cell_to_world(candidate), body_radius):
			continue
		var candidate_distance: float = candidate.distance_squared_to(target_cell)
		var candidate_open := _cell_routing_openness(candidate)
		if candidate_distance < best_distance or (is_equal_approx(candidate_distance, best_distance) and candidate_open > best_open):
			best_distance = candidate_distance
			best_open = candidate_open
			best_cell = candidate
	return best_cell


func _clear_fallback_route(spider: Spider) -> void:
	spider.fallback_route_from = INVALID_ROUTE_CELL
	spider.fallback_route_next = INVALID_ROUTE_CELL
	spider.fallback_route_previous = INVALID_ROUTE_CELL
	spider.fallback_route_target = INVALID_ROUTE_CELL


func _local_route_step_toward(spider: Spider, from_cell: Vector2i, target_cell: Vector2i, body_radius: float) -> Vector2i:
	## Bounded local BFS used only while a regional flow does not cover this mob.
	## It can intentionally take a sideways step around a wall, unlike Euclidean
	## greedy routing, and commits that first step until the mob changes cells.
	if from_cell == target_cell:
		return from_cell
	if (
		spider.fallback_route_from == from_cell
		and spider.fallback_route_target == target_cell
		and spider.fallback_route_next != INVALID_ROUTE_CELL
		and _enemy_can_occupy(grid.cell_to_world(spider.fallback_route_next), body_radius)
	):
		if gameplay_telemetry != null:
			gameplay_telemetry.note_local_route_reuse()
		return spider.fallback_route_next
	if spider.fallback_route_from != INVALID_ROUTE_CELL and spider.fallback_route_from != from_cell:
		spider.fallback_route_previous = spider.fallback_route_from
	spider.fallback_route_from = from_cell
	spider.fallback_route_target = target_cell
	spider.fallback_route_next = INVALID_ROUTE_CELL
	if gameplay_telemetry != null:
		gameplay_telemetry.note_local_route_build()

	var frontier: Array[Vector2i] = [from_cell]
	var seen: Dictionary = {from_cell: true}
	var first_step: Dictionary = {from_cell: from_cell}
	var head := 0
	var visited := 0
	var best_cell := from_cell
	var best_score := float(from_cell.distance_squared_to(target_cell))
	var found_target := false
	while head < frontier.size() and visited < SPIDER_LOCAL_ROUTE_NODE_BUDGET:
		var current: Vector2i = frontier[head]
		head += 1
		visited += 1
		for direction: Vector2i in _GREEDY_CARDINAL_DIRECTIONS:
			var candidate := current + direction
			if seen.has(candidate):
				continue
			if maxi(absi(candidate.x - from_cell.x), absi(candidate.y - from_cell.y)) > SPIDER_LOCAL_ROUTE_RADIUS:
				continue
			if not _enemy_can_occupy(grid.cell_to_world(candidate), body_radius):
				continue
			seen[candidate] = true
			var candidate_first: Vector2i = candidate if current == from_cell else first_step[current]
			first_step[candidate] = candidate_first
			frontier.append(candidate)
			var reverse_penalty := 900.0 if candidate_first == spider.fallback_route_previous else 0.0
			var score := float(candidate.distance_squared_to(target_cell)) + reverse_penalty - float(_cell_routing_openness(candidate)) * 0.2
			if candidate == target_cell:
				best_cell = candidate
				found_target = true
				break
			if score < best_score:
				best_score = score
				best_cell = candidate
		if found_target:
			break

	var chosen := from_cell
	if best_cell != from_cell:
		chosen = first_step[best_cell]
	else:
		# The obstacle is larger than the local search window. Pick a stable
		# wall-following escape instead of alternating left/right every frame.
		var best_escape_score := -INF
		for direction: Vector2i in _GREEDY_CARDINAL_DIRECTIONS:
			var candidate := from_cell + direction
			if not _enemy_can_occupy(grid.cell_to_world(candidate), body_radius):
				continue
			var escape_score := float(_cell_routing_openness(candidate)) * 20.0 - float(candidate.distance_squared_to(target_cell)) * 0.01
			if candidate == spider.fallback_route_previous:
				escape_score -= 1000.0
			if escape_score > best_escape_score:
				best_escape_score = escape_score
				chosen = candidate
	spider.fallback_route_next = chosen
	return chosen


func _spider_direct_combat_range(spider: Spider) -> float:
	if spider.role == ROLE_BROODLING:
		return 20.0
	if spider.role == ROLE_SPITTER:
		return 22.0
	if spider.big or spider.role in [ROLE_BRUTE, ROLE_GUARDIAN]:
		return 38.0
	return SPIDER_DIRECT_COMBAT_RANGE


func _enemy_can_occupy(at_position: Vector2, radius: float = 0.0) -> bool:
	var center := grid.world_to_cell(at_position)
	if _cell_blocks_enemy(center):
		return false
	if radius <= 0.0:
		return true
	var tile_radius := maxi(1, ceili((radius + 2.0) / float(grid.tile_size)))
	var clearance := radius + grid.tile_size * 0.25
	var clearance_sq := clearance * clearance
	for ox in range(-tile_radius, tile_radius + 1):
		for oy in range(-tile_radius, tile_radius + 1):
			if ox == 0 and oy == 0:
				continue
			var probe := center + Vector2i(ox, oy)
			# This is one of the hottest mob loops. Avoid sqrt distance_to() per probe.
			if at_position.distance_squared_to(grid.cell_to_world(probe)) > clearance_sq:
				continue
			if _cell_blocks_enemy(probe):
				return false
	return true


func _apply_enemy_knockback(spider: Spider, direction: Vector2, distance: float) -> void:
	if direction.is_zero_approx() or distance <= 0.0:
		return
	distance *= BiomeBestiaryScript.knockback_scale(spider.biome_id)
	var step := 2.0
	var traveled := 0.0
	var current := spider.position
	while traveled + step <= distance:
		var candidate := current + direction * step
		if not _enemy_can_occupy(candidate, spider.radius):
			break
		current = candidate
		traveled += step
	spider.position = current


func _move_spider(spider: Spider, direction: Vector2, speed_scale: float, delta: float, speed_multiplier: float = 1.0) -> bool:
	if direction.is_zero_approx():
		return false
	var move_delta := direction * spider.speed * speed_scale * speed_multiplier * delta
	var next_pos := spider.position + move_delta
	for radius_scale in [1.0, 0.78, 0.58]:
		var probe_radius: float = spider.radius * float(radius_scale)
		if _enemy_can_occupy(next_pos, probe_radius):
			spider.position = next_pos
			return true
		var slide_x := spider.position + Vector2(move_delta.x, 0.0)
		if _enemy_can_occupy(slide_x, probe_radius):
			spider.position = slide_x
			return true
		var slide_y := spider.position + Vector2(0.0, move_delta.y)
		if _enemy_can_occupy(slide_y, probe_radius):
			spider.position = slide_y
			return true
	return false


func _move_entity(at_position: Vector2, move_delta: Vector2, radius: float) -> Vector2:
	if move_delta.is_zero_approx():
		return at_position
	var next_pos := at_position + move_delta
	for radius_scale in [1.0, 0.78, 0.58]:
		var probe_radius: float = radius * float(radius_scale)
		if _enemy_can_occupy(next_pos, probe_radius):
			return next_pos
		var slide_x := at_position + Vector2(move_delta.x, 0.0)
		if _enemy_can_occupy(slide_x, probe_radius):
			return slide_x
		var slide_y := at_position + Vector2(0.0, move_delta.y)
		if _enemy_can_occupy(slide_y, probe_radius):
			return slide_y
	return at_position


func _recover_stuck_spider(spider: Spider, desired_direction: Vector2) -> void:
	# Compatibility facade for tests/tools that still call the legacy two-argument
	# recovery helper. The live movement path passes its already-selected target to
	# _recover_stuck_spider_to() so normal combat recovery never reselects a mission.
	_recover_stuck_spider_to(spider, desired_direction, _spider_combat_target_position(spider))


func _recover_stuck_spider_to(spider: Spider, desired_direction: Vector2, mission: Vector2) -> void:
	## Recovery must use the combat target already selected for this frame. Re-running
	## target selection here could switch between a torch/turret/base and make the
	## recovery sidestep fight the navigation decision that triggered it.
	var travel := desired_direction.normalized() if not desired_direction.is_zero_approx() else Vector2.RIGHT
	var tangent := Vector2(-travel.y, travel.x)
	var best_probe := Vector2.INF
	var best_score := -INF
	var best_side := 0.0
	var probe_radius := spider.radius * 0.72
	var locked_side := spider.recovery_side_sign if _combat_frame_tick < spider.recovery_side_lock_until_tick else 0.0
	for side in [-1.0, 1.0]:
		for step in [6.0, 12.0, 18.0]:
			var probe: Vector2 = spider.position + tangent * side * step
			if not _enemy_can_occupy(probe, probe_radius):
				continue
			var probe_cell := grid.world_to_cell(probe)
			var openness := float(_cell_routing_openness(probe_cell))
			var progress := spider.position.distance_squared_to(mission) - probe.distance_squared_to(mission)
			var side_commit_bonus := 192.0 if locked_side != 0.0 and is_equal_approx(side, locked_side) else 0.0
			var score := openness * 64.0 + progress + side_commit_bonus
			if score > best_score:
				best_score = score
				best_probe = probe
				best_side = side
	var back := spider.position - travel * 8.0
	if _enemy_can_occupy(back, probe_radius):
		var back_cell := grid.world_to_cell(back)
		var openness := float(_cell_routing_openness(back_cell))
		var progress := spider.position.distance_squared_to(mission) - back.distance_squared_to(mission)
		var score := openness * 64.0 + progress
		if score > best_score:
			best_score = score
			best_probe = back
			best_side = 0.0
	if best_probe != Vector2.INF:
		spider.position = best_probe
		if best_side != 0.0:
			spider.recovery_side_sign = best_side
			spider.recovery_side_lock_until_tick = _combat_frame_tick + SPIDER_RECOVERY_SIDE_LOCK_TICKS


func _pick_flow_route_cell(target_flow: FlowFieldScript, current_cell: Vector2i, body_radius: float) -> Vector2i:
	## Occupancy-aware escape: downhill/sideways neighbors the spider can actually enter.
	if target_flow == null or not target_flow.has_path(current_cell):
		return current_cell
	for next_cell: Vector2i in target_flow.ranked_passable_neighbors(current_cell, _cell_blocks_enemy):
		if next_cell == current_cell or _cell_blocks_enemy(next_cell):
			continue
		if _enemy_can_occupy(grid.cell_to_world(next_cell), body_radius):
			return next_cell
	return current_cell


func _clear_flow_step(spider: Spider) -> void:
	spider.flow_step_from = INVALID_ROUTE_CELL
	spider.flow_step_next = INVALID_ROUTE_CELL
	spider.flow_step_target_id = ""
	spider.flow_step_epoch = -1


func _flow_route_step_for_spider(
	spider: Spider,
	target_flow: FlowFieldScript,
	current_cell: Vector2i,
	target_base_id: String,
	body_radius: float
) -> Vector2i:
	# Reuse one regional-flow decision for the entire source cell. This removes a
	# hot neighbor/clearance scan from every combat frame and prevents a mob from
	# changing its preferred exit while it is still traversing the same tile.
	if (
		spider.flow_step_from == current_cell
		and spider.flow_step_target_id == target_base_id
		and spider.flow_step_epoch == flow_epoch
		and spider.flow_step_next != INVALID_ROUTE_CELL
		and not _cell_blocks_enemy(spider.flow_step_next)
	):
		if gameplay_telemetry != null:
			gameplay_telemetry.note_flow_step_reuse()
		return spider.flow_step_next
	var next_cell := _pick_flow_route_cell(target_flow, current_cell, body_radius)
	spider.flow_step_from = current_cell
	spider.flow_step_next = next_cell if next_cell != current_cell else INVALID_ROUTE_CELL
	spider.flow_step_target_id = target_base_id
	spider.flow_step_epoch = flow_epoch
	if gameplay_telemetry != null:
		gameplay_telemetry.note_flow_step_build()
	return next_cell


func _update_brood_carrier(spider: Spider, delta: float) -> bool:
	var approach := _brood_nest_approach(spider.carrier_target_cell, grid.world_to_cell(spider.position))
	if approach.x < 0:
		_demote_brood_carrier(spider)
		return false
	var approach_position := grid.cell_to_world(approach)
	var nesting_priority := spider.carrier_channel > 0.0 or spider.position.distance_to(approach_position) <= 36.0
	if not nesting_priority:
		var structure_index := _nearby_structure(spider.position, spider.radius + 8.0)
		if structure_index >= 0 and encounter_load_grace <= 0.0 and spider.attack_cooldown <= 0.0:
			var structure: Structure = structures[structure_index]
			structure.health -= 6.0 * float(difficulty["enemy_damage"]) * WaveDirectorScript.enemy_damage_for_pressure(_combat_pressure_level())
			spider.attack_cooldown = 0.65
			_burst(structure.position, Color("b5ca62"), 5, 34.0)
			if structure.health <= 0.0:
				var ruined_cell: Vector2i = structure.cell
				_on_structure_destroyed(structure)
				structures.remove_at(structure_index)
				_invalidate_structure_spatial_buckets()
				_mark_flow_dirty_for_structure_cell(ruined_cell)
		elif spider.position.distance_to(player_position) < spider.radius + 7.0 and encounter_load_grace <= 0.0 and spider.attack_cooldown <= 0.0:
			_hurt_player(7.0 * float(difficulty["enemy_damage"]), spider.position)
			spider.attack_cooldown = 0.75
		else:
			spider.carrier_stall_time += delta
	else:
		spider.carrier_stall_time = 0.0
	if spider.position.distance_to(approach_position) <= 15.0:
		if spider.carrier_channel <= 0.0:
			discovery_alert = "BROOD CARRIER PLANTING // %d SEC" % ceili(BROOD_CARRIER_CHANNEL)
			discovery_alert_time = 3.0
		spider.carrier_channel += delta
		if spider.carrier_channel >= BROOD_CARRIER_CHANNEL:
			_establish_brood_nest(spider.carrier_target_cell, 0.0)
			return true
		return false
	var carrier_flow := _flow_for_brood_target(spider.carrier_target_cell)
	if carrier_flow == null:
		_demote_brood_carrier(spider)
		return false
	var current_cell := grid.world_to_cell(spider.position)
	if not carrier_flow.has_path(current_cell):
		brood_carrier_flows.erase(spider.carrier_target_cell)
		carrier_flow = _flow_for_brood_target(spider.carrier_target_cell)
		if carrier_flow == null or not carrier_flow.has_path(current_cell):
			spider.carrier_stall_time += delta
			if spider.carrier_stall_time >= 8.0:
				var replacement := _choose_brood_nest_site(current_cell)
				if replacement.x >= 0:
					spider.carrier_target_cell = replacement
					spider.carrier_stall_time = 0.0
				else:
					_demote_brood_carrier(spider)
			return false
	spider.carrier_stall_time = maxf(0.0, spider.carrier_stall_time - delta * 0.5)
	var destination := grid.cell_to_world(carrier_flow.next_cell(current_cell))
	var direction := _steer_spider(spider, (destination - spider.position).normalized(), delta, 9.0)
	var move_start: Vector2 = spider.position
	if _move_spider(spider, direction, 1.0, delta, MobLocomotionScript.CARRIER_TRAVEL_SCALE):
		var actual_motion: Vector2 = spider.position - move_start
		if actual_motion.length_squared() > 0.0001:
			var actual_direction := actual_motion.normalized()
			spider.steer_direction = spider.steer_direction.lerp(actual_direction, minf(1.0, delta * 12.0)).normalized()
			spider.facing_angle = lerp_angle(spider.facing_angle, actual_direction.angle(), minf(1.0, delta * 11.0))
	return false


func _update_hive_progression_for_encounter() -> void:
	# Nest site scans are GDScript-heavy — never run them on the mobilize frame.
	call_deferred("_apply_encounter_nest_milestones")


func _apply_encounter_nest_milestones() -> void:
	# World ecology expands with Hive Awareness, not with the number of hunting
	# parties that happened to be delivered. Use 100+tier keys so old encounter
	# milestone keys in schema-14 saves cannot accidentally satisfy new gates.
	for tier: int in NEST_MILESTONE_AWARENESS_TIERS:
		if hive_awareness.awareness_tier < tier:
			continue
		var milestone_key := 100 + tier
		if nest_milestones_spawned.get(milestone_key, false) or _pending_far_nest_milestone == milestone_key:
			continue
		if not _spawn_far_brood_nest("", -1.0, -1.0, milestone_key):
			_pending_far_nest_milestone = milestone_key
			_far_nest_retry_cooldown = 0.35
			_far_nest_retry_attempts = 0
		break
	if hive_awareness.awareness_tier >= 6 and not apex_phase:
		var has_lair := false
		for nest: BroodNest in brood_nests:
			has_lair = has_lair or nest.is_lair
		if not has_lair and (lair_cycle_pending or nest_kills_total < 10):
			_promote_next_lair()
	if _apex_progress_ready() and not apex_phase:
		call_deferred("_begin_apex_phase")


func _apex_progress_ready() -> bool:
	return hive_awareness.awareness_tier >= 6 and nest_kills_total >= 10


func _update_pending_far_nest_retry(delta: float) -> void:
	if _pending_far_nest_milestone < 0:
		return
	if nest_milestones_spawned.get(_pending_far_nest_milestone, false):
		_pending_far_nest_milestone = -1
		return
	_far_nest_retry_cooldown = maxf(0.0, _far_nest_retry_cooldown - delta)
	if _far_nest_retry_cooldown > 0.0:
		return
	_far_nest_retry_attempts += 1
	var milestone := _pending_far_nest_milestone
	if _spawn_far_brood_nest("", -1.0, -1.0, milestone):
		_far_nest_retry_attempts = 0
		return
	if _far_nest_retry_attempts >= 10:
		_pending_far_nest_milestone = -1
		return
	_far_nest_retry_cooldown = 0.75


func _choose_far_brood_nest_site(minimum_base_distance: float, nest_spacing: float, salt: int) -> Vector2i:
	# Hard wall budget — prepared_spawn_cell_near over all regions was ~3ms×72.
	var deadline_usec := Time.get_ticks_usec() + 6000
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var soft_base_distance := minimum_base_distance * 0.45
	var region_rank: Array[Dictionary] = []
	var scanned_regions := 0
	for region_value: Variant in grid.loaded_regions.keys():
		var region: Vector2i = region_value
		if not grid._region_is_prepared(region):
			continue
		var region_center := region * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
		region_rank.append({"region": region, "distance": region_center.distance_squared_to(player_cell)})
	region_rank.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left["distance"]) > int(right["distance"])
	)
	# Retry: ensure one farthest ranked region (no megascan).
	if _far_nest_retry_attempts >= 1 and not region_rank.is_empty():
		var far_region: Vector2i = region_rank[0]["region"]
		var far_center := far_region * WorldGridScript.REGION_SIZE + Vector2i(WorldGridScript.REGION_SIZE / 2, WorldGridScript.REGION_SIZE / 2)
		grid.ensure_regions_around(far_center, 1)
	for entry: Dictionary in region_rank:
		if scanned_regions >= FAR_NEST_REGION_SCAN_CAP or Time.get_ticks_usec() >= deadline_usec:
			break
		scanned_regions += 1
		var region: Vector2i = entry["region"]
		var pick := _pick_far_nest_in_region(region, salt + scanned_regions * 131, soft_base_distance, nest_spacing)
		if pick.x >= 0:
			return pick
	return Vector2i(-1, -1)


func _pick_far_nest_in_region(region: Vector2i, salt: int, minimum_base_distance: float, nest_spacing: float) -> Vector2i:
	var bounds := grid._region_bounds(region)
	if bounds.size.x <= 2 or bounds.size.y <= 2:
		return Vector2i(-1, -1)
	for attempt in range(16):
		var local_x := 1 + posmod(salt + attempt * 17 + attempt * attempt * 3, bounds.size.x - 2)
		var local_y := 1 + posmod(salt * 3 + attempt * 11 + attempt * attempt * 5, bounds.size.y - 2)
		var candidate := bounds.position + Vector2i(local_x, local_y)
		if not grid.is_spawn_ready(candidate):
			continue
		if not _brood_site_geometry_ok(candidate) or _brood_nest_approach(candidate).x < 0:
			continue
		if not _far_nest_spacing_ok(candidate, minimum_base_distance, nest_spacing):
			continue
		return candidate
	return Vector2i(-1, -1)


func _far_nest_spacing_ok(candidate: Vector2i, minimum_base_distance: float, nest_spacing: float) -> bool:
	for base_id: String in base_network.active_ids(true):
		if candidate.distance_to(base_network.get_cell(base_id)) < minimum_base_distance:
			return false
	for nest: BroodNest in brood_nests:
		if candidate.distance_to(nest.cell) < nest_spacing:
			return false
	return true


func _spawn_far_brood_nest(apex_id: String = "", minimum_base_distance: float = -1.0, nest_spacing: float = -1.0, milestone: int = -1) -> bool:
	if minimum_base_distance < 0.0:
		minimum_base_distance = _nest_min_base_cells()
	if nest_spacing < 0.0:
		nest_spacing = _nest_spacing_cells()
	var salt := int(run_seed) ^ int(encounter_epoch * 65537) ^ int((nest_kills_total + brood_nests.size() + 1) * 104729) ^ (_far_nest_retry_attempts * 9182449)
	var target: Vector2i = _choose_far_brood_nest_site(minimum_base_distance, nest_spacing, salt)
	if target.x < 0:
		return false
	# Search and establish on separate frames — mark milestone only after nest exists.
	call_deferred("_finish_far_brood_nest_establish", target, apex_id, milestone, false)
	if milestone >= 0:
		_pending_far_nest_milestone = milestone
		# Hold retry until deferred finish marks complete or fails.
		_far_nest_retry_cooldown = 2.0
	return true


func _finish_far_brood_nest_establish(target: Vector2i, apex_id: String = "", milestone: int = -1, force_lair: bool = false) -> void:
	_establish_brood_nest(target, 1.0)
	var nest_index := _brood_nest_index_at_cell(target)
	if nest_index >= 0:
		brood_nests[nest_index].apex_id = apex_id
		brood_nests[nest_index].is_lair = force_lair or not apex_id.is_empty()
		brood_nests[nest_index].max_health *= 4.0 if not apex_id.is_empty() else (2.5 if force_lair else 1.0)
		brood_nests[nest_index].health = brood_nests[nest_index].max_health
		if force_lair:
			brood_nests[nest_index].aggressive = false
			brood_nests[nest_index].boss_spawned = false
			lair_cycle_pending = false
			discovery_alert = "SPIDER LAIR REVEALED // HIVE CYCLE %d" % (nest_kills_total + 1)
			discovery_alert_time = 6.0
		if milestone >= 0:
			nest_milestones_spawned[milestone] = true
			if _pending_far_nest_milestone == milestone:
				_pending_far_nest_milestone = -1
				_far_nest_retry_attempts = 0
				_far_nest_retry_cooldown = 0.0
	else:
		# Establish failed — allow pending retry again.
		if milestone >= 0 and _pending_far_nest_milestone == milestone:
			_far_nest_retry_cooldown = 0.35


func _promote_next_lair() -> void:
	var candidate: BroodNest = null
	var farthest := -1.0
	for nest: BroodNest in brood_nests:
		if nest.is_lair or not nest.apex_id.is_empty():
			continue
		var distance := nest.cell.distance_to(grid.world_to_cell(player_position))
		if distance > farthest:
			farthest = distance
			candidate = nest
	if candidate == null:
		# Deferred establish — lair flags applied in finish via force_lair.
		var salt := int(run_seed) ^ int(encounter_epoch * 65537) ^ int((nest_kills_total + brood_nests.size() + 1) * 104729)
		var target: Vector2i = _choose_far_brood_nest_site(_nest_min_base_cells(), _nest_spacing_cells(), salt)
		if target.x < 0:
			return
		call_deferred("_finish_far_brood_nest_establish", target, "", -1, true)
		return
	candidate.is_lair = true
	candidate.aggressive = false
	candidate.boss_spawned = false
	candidate.max_health *= 2.5
	candidate.health = candidate.max_health
	lair_cycle_pending = false
	discovery_alert = "SPIDER LAIR REVEALED // HIVE CYCLE %d" % (nest_kills_total + 1)
	discovery_alert_time = 6.0


func _begin_apex_phase() -> void:
	apex_phase = true
	_apex_spawn_attempts = 0
	call_deferred("_spawn_apex_components")
	discovery_alert = "FINAL FIVE AWAKENED // RECOVER ALL APEX COMPONENTS"
	discovery_alert_time = 7.0


func _spawn_apex_components() -> void:
	var spawned := 0
	for component: String in APEX_COMPONENTS:
		if _spawn_far_brood_nest(component, _nest_min_base_cells() * 0.88, _nest_spacing_cells() * 0.75):
			spawned += 1
		elif _spawn_far_brood_nest(component, _nest_min_base_cells() * 0.72, _nest_spacing_cells() * 0.65):
			spawned += 1
	if spawned < APEX_COMPONENTS.size() and _apex_spawn_attempts < 3:
		_apex_spawn_attempts += 1
		call_deferred("_spawn_apex_components")


func _establish_brood_nest(cell: Vector2i, initial_maturity: float = 0.0) -> void:
	if _brood_nest_index_at_cell(cell) >= 0 or destroyed_brood_nests.has(cell):
		return
	grid.discovery_cells[cell] = "nest"
	if not grid.reveal_discovery(cell).is_empty():
		_mark_discovery_revealed(cell)
	grid.open_discovery_chamber(cell, 1)
	var nest := BroodNest.new()
	nest.cell = cell
	nest.max_health = BROOD_NEST_HEALTH * (1.0 + float(brood_escalation) * 0.32)
	nest.health = nest.max_health
	nest.maturity = clampf(initial_maturity, 0.0, 1.0)
	nest.birth_wave = encounters_completed
	nest.spawn_cooldown = 18.0 + float(posmod(cell.x * 7 + cell.y * 11, 9))
	brood_nests.append(nest)
	if nest.maturity >= 1.0:
		# Lane registration does path work (~30ms) — never stack it on nest search.
		call_deferred("_register_mature_brood_nest_lane", cell)
	grid.ensure_regions_around(cell, 1)
	brood_carrier_flows.erase(cell)
	terrain_flow_dirty = true
	terrain_flow_rebuild_cooldown = maxf(terrain_flow_rebuild_cooldown, TERRAIN_FLOW_REBUILD_DELAY)
	_mark_flow_region_dirty(grid.region_for_cell(cell))
	_patch_minimap_cell(cell)
	_burst(grid.cell_to_world(cell), Color("b8f05b"), 12, 92.0, true)
	discovery_alert = "BROOD NEST INCUBATING // HUNT OR FACE A NEW FRONT"
	discovery_alert_time = 5.0


func _register_mature_brood_nest_lane(cell: Vector2i) -> void:
	var nest_index := _brood_nest_index_at_cell(cell)
	if nest_index < 0:
		return
	var registered := grid.register_spawn_cell(cell)
	if registered:
		call_deferred("_prune_unreachable_spawn_lanes")
		discovery_alert = "BROOD NEST MATURE // NEW SPAWN FRONT ACTIVE"
		discovery_alert_time = 5.0
		terrain_flow_dirty = true
		terrain_flow_rebuild_cooldown = maxf(terrain_flow_rebuild_cooldown, TERRAIN_FLOW_REBUILD_DELAY)
		_mark_flow_region_dirty(grid.region_for_cell(cell))
	else:
		discovery_alert = "BROOD NEST INCUBATING // ROUTE NOT YET OPEN"
		discovery_alert_time = 4.0
	_patch_minimap_cell(cell)


func _update_brood_nests(delta: float) -> void:
	for nest: BroodNest in brood_nests:
		# Incubation always ticks — ecology hibernates outside prepared ring.
		if nest.maturity < 1.0:
			var was_mature := nest.maturity >= 1.0
			nest.maturity = minf(1.0, nest.maturity + delta / BROOD_NEST_INCUBATION)
			if not was_mature and nest.maturity >= 1.0:
				nest.register_retry_cooldown = 0.0
				_patch_minimap_cell(nest.cell)
		if nest.maturity >= 1.0 and not grid.spawn_cells.has(nest.cell):
			nest.register_retry_cooldown = maxf(0.0, nest.register_retry_cooldown - delta)
			if nest.register_retry_cooldown <= 0.0:
				nest.register_retry_cooldown = NEST_REGISTER_RETRY_COOLDOWN
				if grid.register_spawn_cell(nest.cell):
					call_deferred("_prune_unreachable_spawn_lanes")
					discovery_alert = "BROOD NEST MATURE // NEW SPAWN FRONT ACTIVE"
					discovery_alert_time = 5.0
					terrain_flow_dirty = true
					terrain_flow_rebuild_cooldown = maxf(terrain_flow_rebuild_cooldown, TERRAIN_FLOW_REBUILD_DELAY)
					_mark_flow_region_dirty(grid.region_for_cell(nest.cell))
		if not grid.is_spawn_ready(nest.cell):
			continue
		var nest_position := grid.cell_to_world(nest.cell)
		if not nest.aggressive and player_position.distance_to(nest_position) <= BROOD_NEST_AGGRO_RADIUS:
			nest.aggressive = true
			nest.spawn_cooldown = minf(nest.spawn_cooldown, 1.5)
			var aggro_budget := _brood_regional_budget_remaining()
			if aggro_budget > 0 and _brood_pulse_allowed():
				var aggro_size := mini(mini(4 + mini(6, brood_escalation), 4), aggro_budget)
				if aggro_size > 0:
					_queue_broodling_pack(nest.cell, aggro_size, false, nest.pressure_pulses * 17)
			discovery_alert = "BROOD BASE AWAKENED // ALPHA DEFENDER ACTIVE"
			discovery_alert_time = 5.0
		if nest.aggressive and not nest.boss_spawned and enemies.size() < _active_enemy_cap():
			nest.boss_spawned = _spawn_nest_boss(nest)
		if nest.maturity < 1.0 and not nest.aggressive:
			continue
		nest.spawn_cooldown -= delta
		if encounter_load_grace > 0.0:
			nest.spawn_cooldown = maxf(nest.spawn_cooldown, encounter_load_grace)
		if nest.spawn_cooldown > 0.0 or not _brood_pulse_allowed():
			continue
		nest.pressure_pulses += 1
		var regional_cap := hive_awareness.regional_population_cap()
		var pulse_cap := mini(4, regional_cap / maxi(1, _aggressive_brood_nest_count()))
		var pulse_size := mini(pulse_cap, 2 + brood_escalation + hive_awareness.awareness_tier / 2)
		pulse_size = mini(pulse_size, _brood_regional_budget_remaining())
		if pulse_size <= 0:
			continue
		_queue_broodling_pack(nest.cell, pulse_size, false, nest.pressure_pulses * 23)
		if nest.aggressive and nest.pressure_pulses % 3 == 0:
			_spawn_nest_pressure_spider(nest)
		var pressure_interval := 18.0 if nest.aggressive else 30.0
		var pressure := _combat_pressure_level()
		nest.spawn_cooldown = maxf(10.0, pressure_interval - float(pressure) * 0.20 - float(brood_escalation) * 0.45) + float(posmod(nest.cell.x + nest.cell.y, 4))
		discovery_alert = "LOCAL BROOD PULSE // %d CONTACTS" % pulse_size
		discovery_alert_time = 2.5


func _spawn_nest_boss(nest: BroodNest) -> bool:
	if not _hostile_spawn_slot_available() or _simulation_enemy_count() >= _active_enemy_cap() or not _spider_spawn_allowed_cell(nest.cell):
		return false
	var spider := Spider.new()
	spider.role = ROLE_GUARDIAN
	spider.big = true
	spider.brood_nest_cell = nest.cell
	spider.counts_for_wave = false
	spider.hunts_player = true
	spider.target_base_id = base_network.nearest_active(nest.cell)
	if spider.target_base_id.is_empty():
		spider.target_base_id = BaseNetworkScript.COMMAND_ID
	spider.position = _resolve_guardian_spawn_position(nest.cell, 13.0)
	if not _valid_spider_spawn_position(spider.position):
		return false
	spider.radius = 13.0
	var lair_multiplier := 3.5 if not nest.apex_id.is_empty() else (1.8 if nest.is_lair else 1.0)
	var pressure := _combat_pressure_level()
	spider.max_health = (BROOD_NEST_DEFENDER_HEALTH + float(pressure) * 90.0) * (1.0 + float(brood_escalation) * 0.28) * lair_multiplier * float(difficulty["enemy_health"])
	spider.health = spider.max_health
	spider.speed = MobLocomotionScript.nest_defender_speed(brood_escalation, float(difficulty["enemy_speed"]))
	spider.next_summon_ratio = 0.75
	spider.spit_cooldown = randf_range(2.5, 4.5)
	_assign_spider_biome(spider, nest.cell)
	if not _consume_hostile_spawn_slot():
		return false
	enemies.append(spider)
	return true


func _brood_nest_index_at_cell(cell: Vector2i) -> int:
	for nest_index in range(brood_nests.size()):
		if brood_nests[nest_index].cell == cell:
			return nest_index
	return -1


func _damage_brood_nest(nest_index: int, damage: float, autosave: bool = true) -> void:
	if nest_index < 0 or nest_index >= brood_nests.size():
		return
	var nest := brood_nests[nest_index]
	nest.health -= damage
	_burst(grid.cell_to_world(nest.cell), Color("a9e85d"), 5, 34.0)
	if nest.health > 0.0:
		return
	var destroyed_cell := nest.cell
	var was_lair := nest.is_lair
	var was_apex := not nest.apex_id.is_empty()
	if was_apex:
		boss_components_carried[nest.apex_id] = true
	grid.unregister_spawn_cell(nest.cell)
	destroyed_brood_nests[nest.cell] = true
	brood_nests.remove_at(nest_index)
	brood_escalation += 1
	nest_kills_total += 1
	score += 1800
	_apply_scrap_delta(ScrapEconomyScript.NEST, "nest_destroyed")
	_burst(grid.cell_to_world(nest.cell), Color("d6f06b"), 16, 112.0, true)
	if not was_apex:
		_relocate_brood_nest(destroyed_cell)
		if brood_escalation % 2 == 0 and brood_nests.size() < _active_brood_nest_cap():
			call_deferred("_relocate_brood_nest", destroyed_cell)
	if was_lair and not was_apex:
		lair_cycle_pending = true
	if _apex_progress_ready() and not apex_phase:
		call_deferred("_begin_apex_phase")
	discovery_alert = "APEX NEST PURGED" if was_apex else "BROOD BASE PURGED // HIVE RELOCATED // %d/10" % mini(10, nest_kills_total)
	discovery_alert_time = 5.0
	if autosave:
		call_deferred("_save_run")


func _active_brood_nest_cap() -> int:
	return mini(7, MAX_ACTIVE_BROOD_NESTS + floori(float(brood_escalation) / 2.0))


func _relocate_brood_nest(origin: Vector2i) -> bool:
	if brood_nests.size() >= _active_brood_nest_cap():
		return false
	var target := _choose_brood_nest_site(origin)
	if target.x >= 0:
		var player_cell: Vector2i = grid.world_to_cell(player_position)
		if target.distance_to(player_cell) < _nest_relocate_min_player_cells():
			target = Vector2i(-1, -1)
	if target.x < 0:
		target = _pick_brood_relocate_site(origin)
	if target.x < 0:
		return false
	grid.discovery_cells[target] = "nest"
	_establish_brood_nest(target, minf(0.95, 0.62 + float(brood_escalation) * 0.05))
	return true


func _pick_brood_relocate_site(origin: Vector2i) -> Vector2i:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(run_seed) ^ int(brood_escalation * 104729) ^ int(Time.get_ticks_usec())
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var minimum_player_distance := _nest_relocate_min_player_cells()
	for attempt in range(192):
		var candidate := Vector2i(rng.randi_range(2, grid.width - 3), rng.randi_range(2, grid.height - 3))
		if candidate.distance_to(player_cell) < minimum_player_distance or candidate.distance_to(origin) < _nest_spacing_cells():
			continue
		if grid.discovery_cells.has(candidate) or not grid.get_mineral_type(candidate).is_empty() or not _brood_site_is_valid(candidate):
			continue
		return candidate
	return Vector2i(-1, -1)


func _update_enemies(delta: float) -> void:
	var current_player_cell: Vector2i = grid.world_to_cell(player_position)
	var current_player_region: Vector2i = grid.region_for_cell(current_player_cell)
	if player_flow_refresh_cooldown <= 0.0 and not _player_flow_refresh_deferred() and (
		player_flow_stale
		or current_player_region != player_flow_region
	):
		_player_flow_refresh_pending = true
	var guardian_summons: Array[Dictionary] = []
	var completed_carriers: Array[Spider] = []
	var inactive_despawns: Array[Spider] = []
	var pressure := _combat_pressure_level()
	for spider in enemies:
		spider.visual_motion += delta * (3.2 + spider.speed * 0.08)
		spider.attack_cooldown = maxf(0.0, spider.attack_cooldown - delta)
		spider.leap_cooldown = maxf(0.0, spider.leap_cooldown - delta)
		spider.spit_cooldown = maxf(0.0, spider.spit_cooldown - delta)
		spider.hit_flash = maxf(0.0, spider.hit_flash - delta)
		spider.hit_reaction = maxf(0.0, spider.hit_reaction - delta)

		# Minecraft-style entity ticking boundary: an enemy outside the bounded
		# simulation window is hibernated. It keeps cheap presentation/cooldown state
		# but performs no LOS, targeting, pathfinding, collision, or attacks until a
		# simulation ticket reaches its chunk again. The simulation halo extends
		# beyond rendering, so this transition occurs off-screen.
		var spider_region := grid.region_for_cell(grid.world_to_cell(spider.position))
		if not grid.loaded_regions.has(spider_region):
			spider.steer_direction = Vector2.ZERO
			spider.locomotion_stall = 0.0
			spider.inactive_sim_time += delta
			if spider.inactive_sim_time >= BACKGROUND_HOSTILE_DESPAWN_SEC and _spider_can_background_despawn(spider):
				inactive_despawns.append(spider)
			continue
		spider.inactive_sim_time = 0.0

		if spider.windup > 0.0:
			var windup_direction: Vector2 = (spider.windup_target - spider.position).normalized()
			if not windup_direction.is_zero_approx():
				spider.facing_angle = windup_direction.angle()
			spider.windup -= delta
			if spider.windup <= 0.0:
				var leap_direction := (spider.windup_target - spider.position).normalized()
				for leap_step in range(7):
					var leap_candidate := spider.position + leap_direction * 3.5
					if not _enemy_can_occupy(leap_candidate, spider.radius):
						break
					spider.position = leap_candidate
				spider.leap_cooldown = 2.8
				_burst(spider.position, Color("d57a4c"), 9, 50.0)
			continue
		if spider.is_brood_carrier:
			if _update_brood_carrier(spider, delta):
				completed_carriers.append(spider)
			continue

		var player_distance := spider.position.distance_to(player_position)
		if base_network.get_status(spider.target_base_id) not in [BaseNetworkScript.STATUS_ACTIVE, BaseNetworkScript.STATUS_ACTIVATING]:
			spider.target_base_id = base_network.choose_target(grid.world_to_cell(spider.position), spawn_sequence, difficulty_id)
		var target_core_cell: Vector2i = base_network.get_cell(spider.target_base_id)
		var core_position: Vector2 = grid.cell_to_world(target_core_cell)
		var is_exploring_now := _update_expedition_tactic(spider, delta)
		var near_player := player_distance <= 220.0
		var targeted_torch_index := _torch_target_for(spider) if near_player else -1
		var targeted_turret_index := -1
		if targeted_torch_index < 0 and (near_player or spider.hunts_turrets):
			targeted_turret_index = _turret_target_for(spider)
		# Expedition cohorts stay on their strategic route. They can still hurt the
		# player on contact, but proximity alone does not pull their traffic inward.
		var combat_target := player_position if spider.hunts_player and not is_exploring_now else core_position
		if targeted_torch_index >= 0:
			combat_target = structures[targeted_torch_index].position
		elif targeted_turret_index >= 0:
			combat_target = structures[targeted_turret_index].position
		var target_distance := spider.position.distance_to(combat_target)
		if encounter_load_grace <= 0.0 and spider.role == ROLE_GUARDIAN and spider.health / spider.max_health <= spider.next_summon_ratio:
			guardian_summons.append({"cell": grid.world_to_cell(spider.position), "counts_for_wave": spider.counts_for_wave})
			spider.next_summon_ratio -= 0.25
			discovery_alert = "GUARDIAN BROOD RELEASED"
			discovery_alert_time = 2.5

		if spider.role == ROLE_LEAPER and spider.leap_cooldown <= 0.0 and target_distance > 28.0 and target_distance < 125.0:
			spider.windup = 0.48
			spider.windup_target = combat_target
			continue

		if spider.role == ROLE_SPITTER and spider.spit_cooldown <= 0.0:
			_try_fire_spitter_projectile(spider, combat_target, target_distance, pressure)
		elif spider.role == ROLE_BRUTE and pressure >= 6 and spider.spit_cooldown <= 0.0:
			_try_fire_bulwark_lob(spider, combat_target, target_distance, pressure)
		elif spider.role == ROLE_GUARDIAN and spider.spit_cooldown <= 0.0:
			_try_fire_guardian_cyst(spider, combat_target, target_distance, pressure)

		var structure_index := _nearby_structure(spider.position, spider.radius + 8.0)
		if structure_index >= 0 and encounter_load_grace <= 0.0 and spider.attack_cooldown <= 0.0:
			var attacked_structure: Structure = structures[structure_index]
			var structure_damage := 21.0 if spider.big else (3.2 if spider.role == ROLE_BROODLING else 6.0)
			if spider.role == ROLE_GUARDIAN:
				structure_damage = 34.0
			structure_damage *= BiomeBestiaryScript.structure_damage_scale(spider.biome_id)
			attacked_structure.health -= structure_damage * float(difficulty["enemy_damage"]) * WaveDirectorScript.enemy_damage_for_pressure(pressure)
			spider.attack_cooldown = 0.65
			_combat_feedback(attacked_structure.position, (spider.position - attacked_structure.position).normalized(), "impact_metal", Color("c69b62"), 5, 34.0)
			if attacked_structure.health <= 0.0:
				_combat_feedback(attacked_structure.position, (spider.position - attacked_structure.position).normalized(), "impact_metal", Color("9b7650"), 18, 72.0)
				var ruined_cell: Vector2i = attacked_structure.cell
				_on_structure_destroyed(attacked_structure)
				structures.remove_at(structure_index)
				_invalidate_structure_spatial_buckets()
				_mark_flow_dirty_for_structure_cell(ruined_cell)
			continue

		if player_distance < spider.radius + 7.0 and encounter_load_grace <= 0.0 and spider.attack_cooldown <= 0.0:
			var contact_damage := 18.0 if spider.big else (4.0 if spider.role == ROLE_BROODLING else 8.0)
			_hurt_player(contact_damage * float(difficulty["enemy_damage"]) * WaveDirectorScript.enemy_damage_for_pressure(pressure), spider.position)
			spider.attack_cooldown = 0.75
			continue

		var core_attack_padding := 28.0 if spider.big or spider.role in [ROLE_BRUTE, ROLE_GUARDIAN] else 16.0
		if spider.position.distance_to(core_position) < spider.radius + core_attack_padding and encounter_load_grace <= 0.0 and spider.attack_cooldown <= 0.0:
			var core_damage := 9.0 if spider.big else (1.2 if spider.role == ROLE_BROODLING else 3.0)
			_damage_base(spider.target_base_id, core_damage * float(difficulty["enemy_damage"]) * WaveDirectorScript.enemy_damage_for_pressure(pressure))
			damage_flash = maxf(damage_flash, 0.16)
			spider.attack_cooldown = 0.68
			_burst(core_position, Color("71ddf7"), 8, 36.0)
			continue

		var current_cell: Vector2i = grid.world_to_cell(spider.position)
		var destination: Vector2
		var direct_combat_commit := (
			target_distance <= _spider_direct_combat_range(spider)
			and _clear_line_of_sight(spider.position, combat_target)
		)
		
		if direct_combat_commit:
			destination = combat_target
		elif is_exploring_now and explorer_flows[spider.explorer_route_index].has_path(current_cell):
			var next_cell: Vector2i = explorer_flows[spider.explorer_route_index].next_cell(current_cell)
			destination = grid.cell_to_world(next_cell)
		elif targeted_torch_index >= 0:
			destination = structures[targeted_torch_index].position
		elif targeted_turret_index >= 0:
			destination = structures[targeted_turret_index].position
		elif spider.hunts_player and player_flow.has_path(current_cell):
			destination = grid.cell_to_world(player_flow.next_cell(current_cell))
		else:
			var target_flow: FlowFieldScript = base_flows.get(spider.target_base_id, flow)
			var routed := false
			if target_flow != null and target_flow.has_path(current_cell):
				# Regional fields intentionally ignore player-built blockers. This keeps the
				# expensive field stable while doors/barriers change and gives siege mobs a
				# clear concept of which obstacle lies directly on the terrain route.
				var terrain_next: Vector2i = target_flow.next_cell(current_cell)
				var blocker_index := _enemy_blocking_structure_index(terrain_next) if terrain_next != current_cell else -1
				if blocker_index >= 0 and blocker_index < structures.size():
					_clear_flow_step(spider)
					_clear_fallback_route(spider)
					# Move up to the blocking footprint. The normal nearby-structure combat
					# check then attacks it instead of local BFS orbiting a sealed defense.
					destination = grid.cell_to_world(terrain_next)
					routed = true
					if gameplay_telemetry != null:
						gameplay_telemetry.note_flow_breach()
				else:
					var next_cell: Vector2i = _flow_route_step_for_spider(
						spider, target_flow, current_cell, spider.target_base_id, spider.radius
					)
					if next_cell != current_cell:
						_clear_fallback_route(spider)
						destination = grid.cell_to_world(next_cell)
						routed = true
						if gameplay_telemetry != null:
							gameplay_telemetry.note_flow_ok()
					else:
						if gameplay_telemetry != null:
							gameplay_telemetry.note_dead_end()
						_request_spider_routing_flow_refresh(spider, current_cell)
			elif target_flow == null or not target_flow.has_path(current_cell):
				_clear_flow_step(spider)
				if gameplay_telemetry != null:
					gameplay_telemetry.note_no_flow()
				_request_spider_routing_flow_refresh(spider, current_cell)
			if not routed:
				# Regional flows are an optimization, not a prerequisite for correct
				# movement. A bounded local BFS can take the temporary sideways step
				# required to round a wall and commits the choice until cell change.
				if gameplay_telemetry != null:
					gameplay_telemetry.note_greedy()
				# Use the target already resolved for this frame. Re-running target selection
				# here could choose a different torch/turret and also duplicated LOS/spatial
				# work for every mob that temporarily fell back from a flow field.
				var fallback_target: Vector2i = grid.world_to_cell(combat_target)
				var fallback_step := _local_route_step_toward(spider, current_cell, fallback_target, spider.radius)
				destination = grid.cell_to_world(fallback_step)
				if spider.locomotion_stall >= SPIDER_ROUTING_FLOW_STALL_THRESHOLD:
					_request_spider_routing_flow_refresh(spider, current_cell)
		if spider.role == ROLE_BROODLING:
			var flow_direction := (destination - spider.position).normalized()
			if not flow_direction.is_zero_approx():
				var stream_side := Vector2(-flow_direction.y, flow_direction.x)
				var stream_wave := sin(spider.visual_motion * 2.4 + spider.stream_phase) * 2.0
				var streamed_destination := destination + stream_side * stream_wave
				if _enemy_can_occupy(streamed_destination, spider.radius):
					destination = streamed_destination
		var direction := _steer_spider(spider, (destination - spider.position).normalized(), delta)
		var moved := false
		if destination.distance_squared_to(spider.position) < 1.0:
			if gameplay_telemetry != null:
				gameplay_telemetry.note_foot_aim_blocked()
		elif not direction.is_zero_approx():
			var speed_scale := _barricade_slow(spider.position)
			var travel_scale := MobLocomotionScript.travel_scale_for_pressure(
				player_distance,
				spider.position.distance_to(core_position),
				_combat_pressure_level(),
				spider.is_brood_carrier
			)
			travel_scale *= BiomeBestiaryScript.home_speed_scale(spider.biome_id, _biome_for_cell(current_cell) == spider.biome_id)
			var move_start: Vector2 = spider.position
			moved = _move_spider(spider, direction, speed_scale, delta, travel_scale)
			# Collision resolution may slide on one axis even when the desired heading
			# points diagonally into a blocker. Face the displacement that actually
			# happened so sprites do not rotate toward a wall while moving sideways.
			if moved:
				var actual_motion: Vector2 = spider.position - move_start
				if actual_motion.length_squared() > 0.0001:
					var actual_direction := actual_motion.normalized()
					spider.steer_direction = spider.steer_direction.lerp(actual_direction, minf(1.0, delta * 14.0)).normalized()
					spider.facing_angle = lerp_angle(spider.facing_angle, actual_direction.angle(), minf(1.0, delta * 13.0))
		if moved:
			spider.locomotion_stall = 0.0
		else:
			if direction.length_squared() > 0.0001:
				spider.locomotion_stall += delta
			if spider.locomotion_stall >= SPIDER_STALL_RECOVER_THRESHOLD:
				var recover_direction := direction if direction.length_squared() > 0.0001 else (combat_target - spider.position)
				_recover_stuck_spider_to(spider, recover_direction, combat_target)
				if gameplay_telemetry != null:
					gameplay_telemetry.note_stall_recover()
				spider.locomotion_stall = 0.0
	for completed_carrier: Spider in completed_carriers:
		enemies.erase(completed_carrier)
	for inactive_spider: Spider in inactive_despawns:
		enemies.erase(inactive_spider)
	if not inactive_despawns.is_empty():
		_invalidate_wave_pressure_count()
	for summon: Dictionary in guardian_summons:
		_queue_broodling_pack(summon["cell"], GUARDIAN_SUMMON_PACK, bool(summon["counts_for_wave"]), spawn_sequence * 29)
	_service_spider_routing_flow_refresh()


func _update_mecha_spiders(delta: float) -> void:
	for mecha: Spider in mecha_spiders:
		mecha.attack_cooldown = maxf(0.0, mecha.attack_cooldown - delta)
		mecha.visual_motion += delta * 6.0
		var enemy_index := -1
		var enemy_distance := 78.0 + float(mecha_level) * 18.0
		for index in range(enemies.size()):
			var distance := mecha.position.distance_to(enemies[index].position)
			if distance < enemy_distance:
				enemy_distance = distance
				enemy_index = index
		if enemy_index >= 0 and mecha.attack_cooldown <= 0.0:
			enemies[enemy_index].health -= 42.0 * float(mecha_level)
			_burst(enemies[enemy_index].position, Color("71e8ff"), 8, 42.0)
			mecha.attack_cooldown = maxf(0.22, 0.65 - float(mecha_level) * 0.12)
			if enemies[enemy_index].health <= 0.0:
				_kill_spider(enemy_index)
			continue
		var target_nest_index := -1
		var target_distance := INF
		for nest_index in range(brood_nests.size()):
			var distance := mecha.position.distance_to(grid.cell_to_world(brood_nests[nest_index].cell))
			if distance < target_distance:
				target_distance = distance
				target_nest_index = nest_index
		if target_nest_index >= 0:
			var target_nest: BroodNest = brood_nests[target_nest_index]
			if target_distance <= 24.0 and mecha.attack_cooldown <= 0.0:
				_damage_brood_nest(target_nest_index, 34.0 * float(mecha_level), false)
				mecha.attack_cooldown = 0.75
				continue
			var nest_flow := _flow_for_brood_target(target_nest.cell)
			var current_cell := grid.world_to_cell(mecha.position)
			if nest_flow != null and nest_flow.has_path(current_cell):
				var destination := grid.cell_to_world(nest_flow.next_cell(current_cell))
				var direction := (destination - mecha.position).normalized()
				mecha.facing_angle = lerp_angle(mecha.facing_angle, direction.angle(), minf(1.0, delta * 9.0))
				var candidate := mecha.position + direction * mecha.speed * delta
				if grid.is_walkable(grid.world_to_cell(candidate)):
					mecha.position = candidate
		elif mecha.position.distance_to(player_position) > 42.0:
			var current_cell := grid.world_to_cell(mecha.position)
			if player_flow.has_path(current_cell):
				var destination := grid.cell_to_world(player_flow.next_cell(current_cell))
				var direction := (destination - mecha.position).normalized()
				var candidate := mecha.position + direction * mecha.speed * delta
				if grid.is_walkable(grid.world_to_cell(candidate)):
					mecha.position = candidate


func _hurt_player(amount: float, source_position: Vector2 = Vector2.INF) -> void:
	if player_invulnerability > 0.0:
		return
	player_health -= amount * player_defense_multiplier
	player_invulnerability = 0.42
	damage_flash = 0.22
	hud_suit_damage_flash = 0.28
	player_hit_time = 0.24
	player_hit_recoil = -aim_direction * 3.0
	if source_position != Vector2.INF:
		var away_from_hit := (player_position - source_position).normalized()
		if not away_from_hit.is_zero_approx():
			player_hit_recoil = away_from_hit * 4.5
	_burst(player_position, Color("ef5b5b"), 7, 44.0)


func _hurt_player_dot(amount: float, source_position: Vector2 = Vector2.INF) -> void:
	## Lingering DoT/hazards ignore i-frames so status remains readable after the hit flash.
	if amount <= 0.0:
		return
	player_health -= amount * player_defense_multiplier
	damage_flash = maxf(damage_flash, 0.08)
	hud_suit_damage_flash = maxf(hud_suit_damage_flash, 0.1)
	if source_position != Vector2.INF and player_hit_time <= 0.0:
		var away_from_hit := (player_position - source_position).normalized()
		if not away_from_hit.is_zero_approx():
			player_hit_recoil = away_from_hit * 1.2
			player_hit_time = 0.08


func _clear_player_status() -> void:
	player_dot_time = 0.0
	player_dot_dps = 0.0
	player_slow_time = 0.0
	player_slow_mult = 1.0


func _clear_enemy_hazard_patches() -> void:
	for patch_index in range(fire_patches.size() - 1, -1, -1):
		if fire_patches[patch_index].player_only:
			fire_patches.remove_at(patch_index)


func _clear_runtime_combat_fx() -> void:
	_clear_player_status()
	_clear_enemy_hazard_patches()
	combat_impacts.clear()


func _apply_player_dot(dps: float, duration: float) -> void:
	if dps <= 0.0 or duration <= 0.0:
		return
	## Stacked refresh: take the stronger DPS and refresh duration.
	player_dot_dps = maxf(player_dot_dps, dps)
	player_dot_time = maxf(player_dot_time, duration)
	_mark_visual_dirty(VIS_DIRTY_EFFECTS)


func _apply_player_slow(mult: float, duration: float) -> void:
	if duration <= 0.0:
		return
	player_slow_mult = minf(player_slow_mult, mult)
	player_slow_time = maxf(player_slow_time, duration)
	_mark_visual_dirty(VIS_DIRTY_EFFECTS)


func _update_player_status(delta: float) -> void:
	if player_slow_time > 0.0:
		player_slow_time = maxf(0.0, player_slow_time - delta)
		if player_slow_time <= 0.0:
			player_slow_mult = 1.0
	else:
		player_slow_mult = 1.0
	if player_dot_time > 0.0 and player_dot_dps > 0.0:
		_hurt_player_dot(player_dot_dps * delta)
		player_dot_time = maxf(0.0, player_dot_time - delta)
		if player_dot_time <= 0.0:
			player_dot_dps = 0.0


func _structure_contact_distance_squared(structure: Structure, at_position: Vector2) -> float:
	## Contact distance is measured to the closest occupied footprint cell, not
	## only the structure origin. This matters for upgraded 4x2 doorways: mobs at
	## the far end must be able to attack the blocker instead of stalling because
	## its top-left anchor is outside melee range.
	var footprint := structure.size if structure.size != Vector2i.ZERO else Vector2i.ONE
	if footprint == Vector2i.ONE:
		return structure.position.distance_squared_to(at_position)
	var best_distance := INF
	for ox in range(footprint.x):
		for oy in range(footprint.y):
			var cell_position := grid.cell_to_world(structure.cell + Vector2i(ox, oy))
			best_distance = minf(best_distance, cell_position.distance_squared_to(at_position))
	return best_distance


func _nearby_structure(at_position: Vector2, distance: float) -> int:
	# Enemy contact checks happen once per mob per frame. Use the static structure
	# spatial index instead of two O(structures) scans for every enemy. Barrier
	# interception keeps priority, matching the previous gameplay contract.
	if structures.is_empty() or distance <= 0.0:
		return -1
	_ensure_structure_spatial_buckets()
	var probe_radius := maxi(1, ceili(distance / CombatSpatialScript.CELL_SIZE) + 1)
	var max_distance_sq := distance * distance
	var best_barrier := -1
	var best_barrier_distance := INF
	var best_any := -1
	var best_any_distance := INF
	for structure_index: int in CombatSpatialScript.collect_structure_indices(_structure_spatial_buckets, at_position, probe_radius):
		if structure_index < 0 or structure_index >= structures.size():
			continue
		var structure: Structure = structures[structure_index]
		# An open heavy doorway is intentionally passable; mobs should traverse it,
		# not stop at the threshold to attack a structure that is not blocking them.
		if structure.kind == BUILD_HEAVY_DOORWAY and structure.is_open:
			continue
		var distance_sq := _structure_contact_distance_squared(structure, at_position)
		if distance_sq >= max_distance_sq:
			continue
		if distance_sq < best_any_distance:
			best_any_distance = distance_sq
			best_any = structure_index
		if structure.kind in [BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER] and distance_sq < best_barrier_distance:
			best_barrier_distance = distance_sq
			best_barrier = structure_index
	return best_barrier if best_barrier >= 0 else best_any


func _role_hunts_turrets(role: int, sequence: int) -> bool:
	# Heavy and leaping enemies are dedicated equipment hunters. As the siege
	# matures, an increasing share of the ordinary swarm joins them.
	if role in [ROLE_BRUTE, ROLE_GUARDIAN, ROLE_LEAPER]:
		return true
	var pressure_wave := _combat_pressure_level() + brood_escalation * 2
	if role != ROLE_SWARM or pressure_wave < 7:
		return false
	var hunter_period := maxi(2, 7 - int(pressure_wave / 5))
	if difficulty_id == "onslaught":
		hunter_period = maxi(2, hunter_period - 1)
	elif difficulty_id == "extinction":
		hunter_period = 2
	return sequence % hunter_period == 0


func _role_hunts_player(role: int, sequence: int) -> bool:
	# Specialist stalkers and a growing share of the mature swarm deliberately
	# pursue the player through the tunnel network.
	if role in [ROLE_LEAPER, ROLE_SPITTER]:
		return true
	var pressure_wave := _combat_pressure_level() + brood_escalation * 2
	if role != ROLE_SWARM or pressure_wave < 6:
		return false
	var predator_period := maxi(3, 9 - int(pressure_wave / 4))
	if difficulty_id == "onslaught":
		predator_period = maxi(3, predator_period - 1)
	elif difficulty_id == "extinction":
		predator_period = 3
	return sequence % predator_period == 1


func _assign_expedition_tactic(spider: Spider, sequence: int, eligible: bool) -> void:
	if not eligible or explorer_flows.is_empty():
		return
	# A predictable fraction of high-pressure swarms peels away, so challenge does not
	# depend on a lucky random roll. Later and harder waves split more often.
	var pressure := _combat_pressure_level()
	var expedition_period := 5
	if pressure >= 4:
		expedition_period = 4
	if pressure >= 9 or difficulty_id in ["onslaught", "extinction"]:
		expedition_period = 3
	if sequence % expedition_period != 0:
		return
	spider.is_explorer = true
	spider.explorer_duration = 28.0 + float(posmod(sequence * 7 + pressure * 3, 18))
	spider.explorer_route_index = posmod(sequence + pressure, explorer_flows.size())
	spider.explorer_route_stride = 1 + posmod(sequence + pressure, maxi(1, explorer_flows.size() - 1))
	spider.explorer_legs_remaining = 2 + posmod(sequence + pressure, 2)
	spider.hunts_player = false


func _update_expedition_tactic(spider: Spider, delta: float) -> bool:
	if not spider.is_explorer or spider.explorer_route_index < 0 or explorer_flows.is_empty():
		return false
	spider.explorer_duration -= delta
	if spider.explorer_duration <= 0.0:
		spider.is_explorer = false
		return false
	spider.explorer_route_index = posmod(spider.explorer_route_index, explorer_flows.size())
	var target_position := grid.cell_to_world(explorer_targets[spider.explorer_route_index])
	if spider.position.distance_to(target_position) < 28.0:
		spider.explorer_legs_remaining -= 1
		if spider.explorer_legs_remaining <= 0:
			spider.is_explorer = false
			return false
		spider.explorer_route_index = posmod(spider.explorer_route_index + spider.explorer_route_stride, explorer_flows.size())
	return true


func _service_player_flow_refresh() -> void:
	if not _player_flow_refresh_pending:
		return
	_player_flow_refresh_pending = false
	if player_flow_refresh_cooldown > 0.0 or _player_flow_refresh_deferred():
		return
	_refresh_player_flow()
	var refresh_delay := PLAYER_FLOW_REFRESH_DELAY
	if not player_flow_stale and (_combat_frame_tick - _recent_mine_flow_tick) > 30:
		refresh_delay = 0.5
	player_flow_refresh_cooldown = refresh_delay


func _turret_target_for(spider: Spider) -> int:
	if not spider.hunts_turrets:
		return -1
	var retained_index: int = _structure_index_at_cell(spider.target_turret_cell)
	if retained_index >= 0:
		var retained: Structure = structures[retained_index]
		var retain_range := _turret_aggro_range(retained, spider) * 1.25
		if retained.kind in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET] and spider.position.distance_to(retained.position) <= retain_range:
			return retained_index
	spider.target_turret_cell = Vector2i(-1, -1)
	if (_combat_frame_tick + int(spider.stream_phase * 10.0)) % 4 != 0:
		return -1

	_ensure_structure_spatial_buckets()
	var best_index: int = -1
	var best_threat: float = -INF
	var probe_radius := maxi(2, ceili(200.0 / CombatSpatialScript.CELL_SIZE) + 1)
	for structure_index: int in CombatSpatialScript.collect_structure_indices(_structure_spatial_buckets, spider.position, probe_radius):
		var structure: Structure = structures[structure_index]
		if structure.kind not in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET]:
			continue
		var distance_to_turret: float = spider.position.distance_to(structure.position)
		var aggro_range: float = _turret_aggro_range(structure, spider)
		if distance_to_turret > aggro_range:
			continue
		if not _clear_line_of_sight(spider.position, structure.position):
			continue
		var condition_ratio := structure.health / maxf(1.0, structure.max_health)
		var effective_level: int = structure.level if structure.kind == BUILD_SENTRY else (3 if structure.kind == BUILD_ROCKET_TURRET else 4)
		var threat := float(effective_level * effective_level) * 90.0
		threat += 45.0 if structure.powered else 0.0
		threat += condition_ratio * 30.0
		threat -= distance_to_turret
		if threat > best_threat:
			best_threat = threat
			best_index = structure_index
	if best_index >= 0:
		spider.target_turret_cell = structures[best_index].cell
	return best_index


func _torch_target_for(spider: Spider) -> int:
	# A Torch creates a small, local diversion rather than a global taunt.
	# Broodlings keep their swarm route; heavier enemies are reliable saboteurs.
	if spider.role == ROLE_BROODLING or spider.is_explorer:
		return -1
	var sabotage_range := TORCH_SABOTAGE_RANGE
	if spider.role in [ROLE_BRUTE, ROLE_GUARDIAN]:
		sabotage_range *= 1.35
	var retained_index := _structure_index_at_cell(spider.target_torch_cell, BUILD_TORCH)
	if retained_index >= 0 and spider.position.distance_to(structures[retained_index].position) <= sabotage_range * 1.25:
		return retained_index
	spider.target_torch_cell = Vector2i(-1, -1)
	# New target acquisition can be staggered; retained targets are still checked
	# every frame. This removes redundant LOS/spatial work from dense sieges.
	if (_combat_frame_tick + int(spider.stream_phase * 13.0)) % 3 != 0:
		return -1
	var closest_index := -1
	var closest_distance := sabotage_range
	_ensure_structure_spatial_buckets()
	var probe_radius := maxi(2, ceili(sabotage_range / CombatSpatialScript.CELL_SIZE) + 1)
	for structure_index: int in CombatSpatialScript.collect_structure_indices(_structure_spatial_buckets, spider.position, probe_radius):
		var structure: Structure = structures[structure_index]
		if structure.kind != BUILD_TORCH or structure.health <= 0.0 or structure.level <= 0:
			continue
		var torch_distance := spider.position.distance_to(structure.position)
		if torch_distance > closest_distance or not _clear_line_of_sight(spider.position, structure.position):
			continue
		closest_distance = torch_distance
		closest_index = structure_index
	if closest_index >= 0:
		spider.target_torch_cell = structures[closest_index].cell
	return closest_index


func _torch_contact_count(torch: Structure) -> int:
	var torch_index := structures.find(torch)
	if torch_index >= 0 and torch_contact_cache_frame == Engine.get_process_frames() and torch_contact_cache.has(torch_index):
		return int(torch_contact_cache[torch_index])
	var contacts := 0
	var vision_radius: float = TORCH_VISION_RADII[clampi(torch.level, 1, TORCH_VISION_RADII.size() - 1)]
	_ensure_enemy_spatial_buckets()
	var probe_radius := maxi(1, ceili(vision_radius / CombatSpatialScript.CELL_SIZE) + 1)
	for enemy_index: int in CombatSpatialScript.collect_enemy_indices(_enemy_spatial_buckets, torch.position, probe_radius):
		var spider: Spider = enemies[enemy_index]
		if torch.position.distance_to(spider.position) <= vision_radius:
			contacts += 1
	if torch_index >= 0:
		if torch_contact_cache_frame != Engine.get_process_frames():
			torch_contact_cache_frame = Engine.get_process_frames()
			torch_contact_cache.clear()
		torch_contact_cache[torch_index] = contacts
	return contacts


func _torch_reveals_position(position: Vector2) -> bool:
	for structure: Structure in structures:
		if structure.kind != BUILD_TORCH:
			continue
		var vision_radius: float = TORCH_VISION_RADII[clampi(structure.level, 1, TORCH_VISION_RADII.size() - 1)]
		if structure.position.distance_to(position) <= vision_radius:
			return true
	return false


func _torch_light_color(torch: Structure) -> Color:
	match clampi(torch.lantern_color_id, 0, TORCH_COLOR_NAMES.size() - 1):
		1:
			return Color("67eaff")
		2:
			return Color("c979ff")
		_:
			return Color("ffae4f")


func _turret_aggro_range(structure: Structure, spider: Spider) -> float:
	var tier_range := 58.0 + float(structure.level - 1) * 34.0
	if structure.powered:
		tier_range += 14.0
	if spider.role == ROLE_GUARDIAN:
		return tier_range * 1.65
	if spider.role == ROLE_BRUTE:
		return tier_range * 1.45
	if spider.role == ROLE_LEAPER:
		return tier_range * 1.25
	return tier_range


func _structure_index_at_cell(cell: Vector2i, required_kind: int = -1) -> int:
	if cell.x < 0 or cell.y < 0:
		return -1
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		# Open doorways are passable — skip them for collision
		if structure.kind == BUILD_HEAVY_DOORWAY and structure.is_open:
			continue
		if (required_kind < 0 or structure.kind == required_kind) and _structure_covers_cell(structure, cell):
			return structure_index
	return -1


func _clear_line_of_sight(from: Vector2, to: Vector2) -> bool:
	var distance := from.distance_to(to)
	var direction := (to - from).normalized()
	var step := 8.0
	var current := step
	while current < distance:
		if not grid.is_walkable(grid.world_to_cell(from + direction * current)):
			return false
		current += step
	return true


func _ensure_structure_spatial_buckets() -> void:
	if structures.is_empty():
		_structure_spatial_buckets.clear()
		_structure_spatial_buckets_frame = _combat_frame_tick
		_structure_spatial_bucket_count = 0
		return
	# Structures are static between explicit placement/removal/footprint mutations.
	# The old cache required the build frame to equal the current combat frame,
	# rebuilding the entire structure index every frame despite no position change.
	if _structure_spatial_buckets_frame >= 0 and _structure_spatial_bucket_count == structures.size():
		return
	CombatSpatialScript.rebuild_structure_buckets(_structure_spatial_buckets, structures)
	_structure_spatial_buckets_frame = _combat_frame_tick
	_structure_spatial_bucket_count = structures.size()


func _invalidate_structure_spatial_buckets() -> void:
	_structure_spatial_buckets_frame = -1
	_structure_spatial_bucket_count = -1
	_turret_target_cache.clear()


func _barricade_slow(at_position: Vector2) -> float:
	_ensure_structure_spatial_buckets()
	for structure_index: int in CombatSpatialScript.collect_structure_indices(_structure_spatial_buckets, at_position, 1):
		var structure: Structure = structures[structure_index]
		if structure.position.distance_to(at_position) >= 10.0:
			continue
		match structure.kind:
			BUILD_BARRICADE:
				return 0.36
			BUILD_GRANITE_BARRIER:
				return 0.28
			BUILD_STEEL_BARRIER:
				return 0.22
			BUILD_REINFORCED_BARRIER:
				return 0.18
			BUILD_BLAST_BARRIER:
				return 0.10
	return 1.0


func _update_fire_patches(delta: float) -> void:
	for patch_index in range(fire_patches.size() - 1, -1, -1):
		var patch: FirePatch = fire_patches[patch_index]
		patch.life -= delta
		if patch.life <= 0.0:
			fire_patches.remove_at(patch_index)
			continue
		if not patch.player_only:
			for enemy_index in range(enemies.size() - 1, -1, -1):
				var spider: Spider = enemies[enemy_index]
				if patch.position.distance_to(spider.position) > patch.radius + spider.radius:
					continue
				spider.health -= patch.damage_per_second * delta
				spider.hit_flash = maxf(spider.hit_flash, 0.04)
				if spider.health <= 0.0:
					_kill_spider(enemy_index)
		# Fresh patches give the player a brief step-away window; standing in a
		# lingering pool still burns, making placement a real positioning choice.
		if patch.life < patch.max_life - EnemyProjectileEffectsScript.HAZARD_GRACE and patch.position.distance_to(player_position) <= patch.radius:
			if patch.player_only:
				_hurt_player_dot(patch.damage_per_second * delta, patch.position)
			else:
				_hurt_player(9.0 * delta, patch.position)


func _ensure_enemy_spatial_buckets() -> void:
	if enemies.is_empty():
		_enemy_spatial_buckets.clear()
		_enemy_spatial_buckets_frame = _combat_frame_tick
		_enemy_spatial_bucket_enemy_count = 0
		return
	if _enemy_spatial_buckets_frame == _combat_frame_tick and _enemy_spatial_bucket_enemy_count == enemies.size():
		return
	CombatSpatialScript.rebuild_enemy_buckets(_enemy_spatial_buckets, enemies)
	_enemy_spatial_buckets_frame = _combat_frame_tick
	_enemy_spatial_bucket_enemy_count = enemies.size()


func _update_bullets(delta: float) -> void:
	_ensure_enemy_spatial_buckets()
	var pressure := _combat_pressure_level()
	var damage_pressure := WaveDirectorScript.enemy_damage_for_pressure(pressure)
	var difficulty_damage := float(difficulty["enemy_damage"])
	for bullet_index in range(bullets.size() - 1, -1, -1):
		var bullet := bullets[bullet_index]
		if bullet.enemy_round:
			bullet.age += delta
		bullet.position += bullet.velocity * delta
		bullet.life -= delta
		if bullet.life <= 0.0 or not grid.is_walkable(grid.world_to_cell(bullet.position)):
			if bullet.projectile_kind == "rocket":
				_explode_area_damage(bullet.position, bullet.damage, bullet.explosion_radius, bullet.color)
			else:
				var expire_direction := bullet.velocity.normalized() if bullet.velocity.length_squared() > 0.0001 else Vector2.RIGHT
				var expire_impact := (
					_enemy_projectile_part_texture_id(bullet, "splat")
					if bullet.enemy_round
					else CombatVfxScript.impact_texture_id_for_bullet(bullet.color, bullet.projectile_kind, bullet.enemy_round)
				)
				_combat_feedback(bullet.position, expire_direction, expire_impact, bullet.color, 3, 22.0, false, bullet.enemy_round)
				if bullet.enemy_round:
					_spawn_enemy_hazard_from_bullet(bullet)
					if bullet.explosion_radius > 0.0:
						_apply_enemy_splash(bullet, difficulty_damage, damage_pressure)
			_remove_bullet_at(bullet_index)
			continue

		if bullet.enemy_round:
			if bullet.position.distance_to(player_position) < bullet.radius + 5.0:
				_resolve_enemy_projectile_hit(bullet, difficulty_damage, damage_pressure, true)
				_remove_bullet_at(bullet_index)
				continue
			var hit_base_id := _base_at_position(bullet.position, bullet.radius + 10.0)
			if not hit_base_id.is_empty():
				_damage_base(hit_base_id, bullet.damage * 0.6 * difficulty_damage * damage_pressure * EnemyProjectileEffectsScript.structure_damage_multiplier(bullet.damage_type))
				damage_flash = maxf(damage_flash, 0.14)
				var base_acid_direction := bullet.velocity.normalized() if bullet.velocity.length_squared() > 0.0001 else Vector2.RIGHT
				_combat_feedback(bullet.position, base_acid_direction, _enemy_projectile_part_texture_id(bullet, "splat"), bullet.color, 8, 36.0, false, true)
				_resolve_enemy_projectile_hit(bullet, difficulty_damage, damage_pressure, false, false)
				_remove_bullet_at(bullet_index)
				continue
			if EnemyProjectileEffectsScript.structure_priority(bullet.damage_type) and _try_enemy_bullet_structure_hit(bullet, difficulty_damage, damage_pressure):
				_resolve_enemy_projectile_hit(bullet, difficulty_damage, damage_pressure, false, false)
				_remove_bullet_at(bullet_index)
			continue

		var hit := false
		var rocket_impact := false
		for enemy_index: int in CombatSpatialScript.collect_enemy_indices(_enemy_spatial_buckets, bullet.position, 1):
			if enemy_index < 0 or enemy_index >= enemies.size():
				continue
			var spider: Spider = enemies[enemy_index]
			if bullet.position.distance_to(spider.position) > spider.radius + 2.0:
				continue
			if bullet.projectile_kind == "rocket":
				rocket_impact = true
				hit = true
				break
			spider.health -= bullet.damage
			spider.last_damaged_by_sentry = bullet.sentry_round
			spider.hit_flash = 0.08
			spider.hit_reaction = 0.16
			spider.hit_recoil_direction = bullet.velocity.normalized()
			if bullet.knockback > 0.0:
				_apply_enemy_knockback(spider, bullet.velocity.normalized(), bullet.knockback)
			var hit_direction := bullet.velocity.normalized() if bullet.velocity.length_squared() > 0.0001 else Vector2.RIGHT
			var hit_impact := CombatVfxScript.impact_texture_id_for_bullet(bullet.color, bullet.projectile_kind, bullet.enemy_round)
			_combat_feedback(bullet.position, hit_direction, hit_impact, Color("c7f46a"), 5, 35.0)
			if spider.health <= 0.0:
				_kill_spider(enemy_index)
			if bullet.pierce_remaining > 0:
				bullet.pierce_remaining -= 1
				bullet.position += bullet.velocity.normalized() * (spider.radius + 6.0)
			else:
				hit = true
			break
		if not hit:
			var nest_index := _brood_nest_hit_index(bullet.position, bullet.radius + 10.0)
			if nest_index >= 0:
				if bullet.projectile_kind == "rocket":
					rocket_impact = true
				else:
					_damage_brood_nest(nest_index, bullet.damage)
				hit = true
		if rocket_impact:
			_explode_area_damage(bullet.position, bullet.damage, bullet.explosion_radius, bullet.color, bullet.sentry_round)
		if hit:
			_remove_bullet_at(bullet_index)


func _try_fire_spitter_projectile(spider: Spider, combat_target: Vector2, target_distance: float, pressure: int) -> void:
	var ecology: Dictionary = BiomeBestiaryScript.trait_profile(spider.biome_id)
	var damage_type: StringName = BiomeBestiaryScript.damage_type_for_biome(spider.biome_id)
	var projectile_level := BiomeBestiaryScript.projectile_level_for_pressure(pressure)
	var combat: Dictionary = BiomeBestiaryScript.projectile_combat_profile(damage_type, projectile_level, ecology)
	if target_distance >= float(combat["engage_range"]):
		return
	if _enemy_bullet_count >= MAX_ENEMY_BULLETS:
		spider.spit_cooldown = CAP_RETRY_COOLDOWN
		return
	var spit_direction: Vector2 = (combat_target - spider.position).normalized()
	if spit_direction.is_zero_approx():
		return
	spider.facing_angle = spit_direction.angle()
	var spit_color: Color = ecology.get("projectile_color", Color("a4e85b"))
	_spawn_bullet(
		spider.position + spit_direction * 7.0,
		spit_direction,
		float(combat["damage"]),
		false,
		true,
		float(combat["hit_radius"]),
		0.0,
		spit_color,
		float(combat["life"]),
		0,
		"round",
		float(combat["splash_radius"])
	)
	var spawned: Bullet = bullets.back()
	spawned.velocity *= float(combat["speed_scale"])
	spawned.source_biome_id = spider.biome_id
	spawned.damage_type = damage_type
	spawned.projectile_level = projectile_level
	_assign_enemy_projectile_visuals(spawned)
	spider.spit_cooldown = float(combat["cooldown"])
	_enemy_muzzle_puff(spider.position + spit_direction * 7.0, spit_direction, spawned)


func _try_fire_bulwark_lob(spider: Spider, combat_target: Vector2, target_distance: float, pressure: int) -> void:
	if _encounter_special_lob_used >= EnemyProjectileEffectsScript.MAX_SPECIAL_LOBS_PER_ENCOUNTER:
		spider.spit_cooldown = EnemyProjectileEffectsScript.LOB_COOLDOWN
		return
	var ecology: Dictionary = BiomeBestiaryScript.trait_profile(spider.biome_id)
	var damage_type: StringName = BiomeBestiaryScript.damage_type_for_biome(spider.biome_id)
	var projectile_level := BiomeBestiaryScript.projectile_level_for_pressure(pressure)
	var combat: Dictionary = BiomeBestiaryScript.projectile_combat_profile(damage_type, projectile_level, ecology)
	var lob: Dictionary = EnemyProjectileEffectsScript.lob_profile_scale()
	if target_distance >= float(lob["engage"]):
		return
	if _enemy_bullet_count >= MAX_ENEMY_BULLETS:
		spider.spit_cooldown = CAP_RETRY_COOLDOWN
		return
	var spit_direction: Vector2 = (combat_target - spider.position).normalized()
	if spit_direction.is_zero_approx():
		return
	spider.facing_angle = spit_direction.angle()
	var spit_color: Color = ecology.get("projectile_color", Color("a4e85b"))
	_spawn_bullet(
		spider.position + spit_direction * 9.0,
		spit_direction,
		float(combat["damage"]) * float(lob["damage_mult"]),
		false,
		true,
		float(combat["hit_radius"]) * float(lob["hit_radius_mult"]),
		0.0,
		spit_color,
		float(combat["life"]) * float(lob["life_mult"]),
		0,
		"enemy_lob",
		float(combat["splash_radius"]) * float(lob["splash_mult"])
	)
	var spawned: Bullet = bullets.back()
	spawned.velocity *= float(combat["speed_scale"]) * float(lob["speed_mult"])
	spawned.source_biome_id = spider.biome_id
	spawned.damage_type = damage_type
	spawned.projectile_level = projectile_level
	spawned.is_special_lob = true
	_assign_enemy_projectile_visuals(spawned)
	spider.spit_cooldown = float(lob["cooldown"])
	_encounter_special_lob_used += 1
	_enemy_muzzle_puff(spider.position + spit_direction * 9.0, spit_direction, spawned)


func _try_fire_guardian_cyst(spider: Spider, combat_target: Vector2, target_distance: float, pressure: int) -> void:
	if _encounter_special_lob_used >= EnemyProjectileEffectsScript.MAX_SPECIAL_LOBS_PER_ENCOUNTER:
		spider.spit_cooldown = EnemyProjectileEffectsScript.CYST_COOLDOWN
		return
	var ecology: Dictionary = BiomeBestiaryScript.trait_profile(spider.biome_id)
	var projectile_level := BiomeBestiaryScript.projectile_level_for_pressure(pressure)
	var combat: Dictionary = BiomeBestiaryScript.projectile_combat_profile(BiomeBestiaryScript.DAMAGE_VENOM, projectile_level, ecology)
	var cyst: Dictionary = EnemyProjectileEffectsScript.cyst_profile_scale()
	if target_distance >= float(cyst["engage"]):
		return
	if _enemy_bullet_count >= MAX_ENEMY_BULLETS:
		spider.spit_cooldown = CAP_RETRY_COOLDOWN
		return
	var spit_direction: Vector2 = (combat_target - spider.position).normalized()
	if spit_direction.is_zero_approx():
		return
	spider.facing_angle = spit_direction.angle()
	var spit_color := Color("9a4ecf")
	_spawn_bullet(
		spider.position + spit_direction * 11.0,
		spit_direction,
		float(combat["damage"]) * float(cyst["damage_mult"]),
		false,
		true,
		float(combat["hit_radius"]) * float(cyst["hit_radius_mult"]),
		0.0,
		spit_color,
		float(combat["life"]) * float(cyst["life_mult"]),
		0,
		"enemy_cyst",
		maxf(18.0, float(combat["splash_radius"]) * float(cyst["splash_mult"]))
	)
	var spawned: Bullet = bullets.back()
	spawned.velocity *= float(combat["speed_scale"]) * float(cyst["speed_mult"])
	spawned.source_biome_id = spider.biome_id if spider.biome_id >= 0 else WorldGridScript.BIOME_HIVE
	spawned.damage_type = BiomeBestiaryScript.DAMAGE_VENOM
	spawned.projectile_level = projectile_level
	spawned.is_special_lob = true
	spawned.is_cyst = true
	_assign_enemy_projectile_visuals(spawned)
	spider.spit_cooldown = float(cyst["cooldown"])
	_encounter_special_lob_used += 1
	_enemy_muzzle_puff(spider.position + spit_direction * 11.0, spit_direction, spawned)


func _assign_enemy_projectile_visuals(bullet: Bullet) -> void:
	var motion: PackedFloat32Array = CombatVfxScript.enemy_projectile_motion(bullet.damage_type, bullet.is_special_lob, bullet.is_cyst)
	bullet.age = 0.0
	bullet.visual_spin_rate = motion[0]
	bullet.visual_wobble = motion[1]
	bullet.trail_stretch = motion[2]
	if bullet.is_cyst and _combat_texture("enemy_cyst_glob") != null:
		bullet.texture_glob_id = "enemy_cyst_glob"
		bullet.texture_trail_id = "enemy_cyst_trail"
		bullet.texture_splat_id = "enemy_cyst_splat"
	elif bullet.is_special_lob and _combat_texture("enemy_lob_glob") != null:
		bullet.texture_glob_id = "enemy_lob_glob"
		bullet.texture_trail_id = "enemy_lob_trail"
		bullet.texture_splat_id = "enemy_lob_splat"
	else:
		var biome_id := bullet.source_biome_id
		bullet.texture_glob_id = CombatVfxScript.enemy_projectile_texture_id(biome_id, "glob")
		bullet.texture_trail_id = CombatVfxScript.enemy_projectile_texture_id(biome_id, "trail")
		bullet.texture_splat_id = CombatVfxScript.enemy_projectile_texture_id(biome_id, "splat")


func _enemy_muzzle_puff(at_position: Vector2, direction: Vector2, bullet: Bullet) -> void:
	var glob_id := _enemy_projectile_part_texture_id(bullet, "glob")
	var puff_size := _projectile_size_for_bullet(bullet) * 0.7
	_spawn_combat_impact(glob_id, at_position, direction, puff_size, 0.12, true)
	_burst(at_position, bullet.color, 4, 22.0)


func _resolve_enemy_projectile_hit(
	bullet: Bullet,
	difficulty_damage: float,
	damage_pressure: float,
	hit_player: bool,
	emit_splat: bool = true
) -> void:
	var impact_direction := bullet.velocity.normalized() if bullet.velocity.length_squared() > 0.0001 else Vector2.RIGHT
	if hit_player:
		_hurt_player(bullet.damage * difficulty_damage * damage_pressure, bullet.position)
		if emit_splat:
			_combat_feedback(
				bullet.position,
				impact_direction,
				_enemy_projectile_part_texture_id(bullet, "splat"),
				bullet.color,
				9,
				38.0,
				false,
				true
			)
		_apply_enemy_projectile_player_status(bullet)
	_spawn_enemy_hazard_from_bullet(bullet)
	if bullet.explosion_radius > 0.0:
		_apply_enemy_splash(bullet, difficulty_damage, damage_pressure)


func _apply_enemy_projectile_player_status(bullet: Bullet) -> void:
	if EnemyProjectileEffectsScript.applies_player_slow(bullet.damage_type):
		_apply_player_slow(EnemyProjectileEffectsScript.VENOM_SLOW_MULT, EnemyProjectileEffectsScript.VENOM_SLOW_DURATION)
	var dot_spec: Dictionary = EnemyProjectileEffectsScript.player_dot_spec(bullet.damage_type, bullet.is_cyst)
	if not dot_spec.is_empty():
		_apply_player_dot(float(dot_spec["dps"]), float(dot_spec["duration"]))


func _spawn_enemy_hazard_from_bullet(bullet: Bullet) -> void:
	if not EnemyProjectileEffectsScript.spawns_hazard(bullet.damage_type):
		return
	var spec: Dictionary = EnemyProjectileEffectsScript.hazard_spec(bullet.damage_type, bullet.explosion_radius)
	if spec.is_empty():
		return
	var patch := FirePatch.new()
	patch.position = bullet.position
	patch.damage_per_second = float(spec["dps"])
	patch.radius = float(spec["radius"])
	patch.life = float(spec["life"])
	patch.max_life = patch.life
	patch.player_only = true
	patch.source_damage_type = bullet.damage_type
	_enqueue_enemy_hazard_patch(patch)


func _enqueue_enemy_hazard_patch(patch: FirePatch) -> void:
	var enemy_hazard_count := 0
	for existing: FirePatch in fire_patches:
		if existing.player_only:
			enemy_hazard_count += 1
	while enemy_hazard_count >= EnemyProjectileEffectsScript.MAX_ENEMY_HAZARD_PATCHES:
		var removed := false
		for patch_index in range(fire_patches.size()):
			if fire_patches[patch_index].player_only:
				fire_patches.remove_at(patch_index)
				enemy_hazard_count -= 1
				removed = true
				break
		if not removed:
			break
	fire_patches.append(patch)


func _apply_enemy_splash(bullet: Bullet, difficulty_damage: float, damage_pressure: float) -> void:
	var splash := bullet.explosion_radius
	if splash <= 0.0:
		return
	if bullet.position.distance_to(player_position) <= splash + 5.0:
		_hurt_player_dot(bullet.damage * 0.35 * difficulty_damage * damage_pressure, bullet.position)
		_apply_enemy_projectile_player_status(bullet)
	if not EnemyProjectileEffectsScript.hits_structures(bullet.damage_type):
		return
	_ensure_structure_spatial_buckets()
	var structure_mult := EnemyProjectileEffectsScript.structure_damage_multiplier(bullet.damage_type)
	var splash_frac := EnemyProjectileEffectsScript.ARC_SPLASH_STRUCTURE_FRAC if bullet.damage_type == BiomeBestiaryScript.DAMAGE_ARC else 0.55
	var doomed: Array[int] = []
	var splash_spark_budget := 4
	for structure_index: int in CombatSpatialScript.collect_structure_indices(_structure_spatial_buckets, bullet.position, 2):
		if structure_index < 0 or structure_index >= structures.size():
			continue
		var structure: Structure = structures[structure_index]
		if bullet.position.distance_to(structure.position) > splash + 8.0:
			continue
		structure.health -= bullet.damage * splash_frac * difficulty_damage * damage_pressure * structure_mult
		if splash_spark_budget > 0:
			var sparks_here := mini(2, splash_spark_budget)
			_combat_feedback(structure.position, (structure.position - bullet.position).normalized(), "impact_metal", Color("c69b62"), sparks_here, 28.0)
			splash_spark_budget -= sparks_here
		if structure.health <= 0.0 and structure_index not in doomed:
			doomed.append(structure_index)
	doomed.sort()
	for doomed_i in range(doomed.size() - 1, -1, -1):
		var doomed_index: int = doomed[doomed_i]
		if doomed_index < 0 or doomed_index >= structures.size():
			continue
		if splash_spark_budget > 0:
			var destroy_sparks := mini(2, splash_spark_budget)
			_combat_feedback(structures[doomed_index].position, Vector2.UP, "impact_metal", Color("9b7650"), destroy_sparks, 56.0)
			splash_spark_budget -= destroy_sparks
		var ruined_cell: Vector2i = structures[doomed_index].cell
		_on_structure_destroyed(structures[doomed_index])
		structures.remove_at(doomed_index)
		_mark_flow_dirty_for_structure_cell(ruined_cell)
	if not doomed.is_empty():
		_invalidate_structure_spatial_buckets()


func _try_enemy_bullet_structure_hit(bullet: Bullet, difficulty_damage: float, damage_pressure: float) -> bool:
	_ensure_structure_spatial_buckets()
	var hit_radius := bullet.radius + 8.0
	var best_index := -1
	var best_distance := hit_radius
	for structure_index: int in CombatSpatialScript.collect_structure_indices(_structure_spatial_buckets, bullet.position, 1):
		if structure_index < 0 or structure_index >= structures.size():
			continue
		var structure: Structure = structures[structure_index]
		if structure.kind not in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET, BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER]:
			continue
		var distance := bullet.position.distance_to(structure.position)
		if distance < best_distance:
			best_distance = distance
			best_index = structure_index
	if best_index < 0:
		return false
	var hit_structure: Structure = structures[best_index]
	var structure_mult := EnemyProjectileEffectsScript.structure_damage_multiplier(bullet.damage_type)
	hit_structure.health -= bullet.damage * 0.85 * difficulty_damage * damage_pressure * structure_mult * BiomeBestiaryScript.structure_damage_scale(bullet.source_biome_id)
	var hit_direction := bullet.velocity.normalized() if bullet.velocity.length_squared() > 0.0001 else Vector2.RIGHT
	_combat_feedback(bullet.position, hit_direction, _enemy_projectile_part_texture_id(bullet, "splat"), bullet.color, 8, 36.0, false, true)
	if hit_structure.health <= 0.0:
		_combat_feedback(hit_structure.position, hit_direction, "impact_metal", Color("9b7650"), 16, 64.0)
		var ruined_cell: Vector2i = hit_structure.cell
		_on_structure_destroyed(hit_structure)
		structures.remove_at(best_index)
		_invalidate_structure_spatial_buckets()
		_mark_flow_dirty_for_structure_cell(ruined_cell)
	return true


func _remove_bullet_at(bullet_index: int) -> void:
	if bullet_index < 0 or bullet_index >= bullets.size():
		return
	if bullets[bullet_index].enemy_round:
		_enemy_bullet_count = maxi(0, _enemy_bullet_count - 1)
	bullets.remove_at(bullet_index)


func _clear_bullets() -> void:
	bullets.clear()
	_enemy_bullet_count = 0


func _spawn_bullet(
	at_position: Vector2,
	direction: Vector2,
	damage: float,
	from_sentry: bool,
	from_enemy: bool = false,
	round_radius: float = 2.0,
	knockback_force: float = 0.0,
	round_color: Color = Color("ffd36b"),
	lifetime: float = 1.2,
	pierce_count: int = 0,
	projectile_kind: String = "round",
	explosion_radius: float = 0.0
) -> void:
	var bullet := Bullet.new()
	bullet.position = at_position
	var speed := 86.0 if from_enemy else (BULLET_SPEED if not from_sentry else (190.0 if projectile_kind == "rocket" else (460.0 if projectile_kind == "laser_turret" else 300.0)))
	bullet.velocity = direction * speed
	bullet.damage = damage
	bullet.sentry_round = from_sentry
	bullet.enemy_round = from_enemy
	bullet.radius = round_radius
	bullet.knockback = knockback_force
	bullet.color = round_color
	bullet.life = lifetime
	bullet.pierce_remaining = pierce_count
	bullet.projectile_kind = projectile_kind
	bullet.explosion_radius = explosion_radius
	bullets.append(bullet)
	if from_enemy:
		_enemy_bullet_count += 1


func _kill_spider(index_to_remove: int) -> void:
	var spider := enemies[index_to_remove]
	if spider.is_scout and not spider.scout_reported:
		hive_awareness.mark_scout_missing(spider.scout_region)
		discovery_alert = "%s MISSING // HIVE INVESTIGATION DELAYED" % spider.scout_name
		discovery_alert_time = 3.0
	if spider.role == ROLE_GUARDIAN:
		score += 5000
		_apply_scrap_delta(ScrapEconomyScript.GUARDIAN, "guardian_kill")
		if not _try_add_ammo(PICKUP_PISTOL_AMMO, 30):
			_spawn_pickup(spider.position, PICKUP_PISTOL_AMMO, 30, Vector2(0, -24))
		if not spider.guardian_site_id.is_empty():
			base_network.mark_guardian_cleared(spider.guardian_site_id)
			hive_awareness.register_activity("guardian", grid.region_for_cell(grid.world_to_cell(spider.position)))
			discovery_alert = "%s CLEARED // CORE SITE READY" % str(base_network.get_base(spider.guardian_site_id)["name"])
			discovery_alert_time = 4.0
			if checkpoint_exists:
				_save_run()
		elif spider.brood_nest_cell.x >= 0:
			var defended_nest_index := _brood_nest_index_at_cell(spider.brood_nest_cell)
			if defended_nest_index >= 0:
				var defended_nest: BroodNest = brood_nests[defended_nest_index]
				defended_nest.spawn_cooldown = 0.5
				if not defended_nest.apex_id.is_empty():
					boss_components_carried[defended_nest.apex_id] = true
					hive_awareness.mark_world_gate(defended_nest.apex_id)
			discovery_alert = "APEX COMPONENT RECOVERED // RETURN TO CORE" if defended_nest_index >= 0 and not brood_nests[defended_nest_index].apex_id.is_empty() else "BROOD ALPHA SLAIN // NEST ENRAGED"
			discovery_alert_time = 4.0
	elif spider.role == ROLE_BROODLING:
		score += 25
		_apply_scrap_delta(ScrapEconomyScript.BROODLING, "broodling_kill")
	else:
		score += 500 if spider.big else 100
		_apply_scrap_delta(ScrapEconomyScript.kill_reward(spider.big, spider.last_damaged_by_sentry), "enemy_kill")
		_award_kill_ammo_loot(spider)
		_register_hud_kill_streak(spider.last_damaged_by_sentry)
		_burst(spider.position, Color("75c65b"), 30 if spider.big else 12, 90.0 if spider.big else 58.0, true)
	_register_first_contact()
	enemies.remove_at(index_to_remove)
	_invalidate_wave_pressure_count()


func _award_kill_ammo_loot(spider: Spider) -> void:
	if spider.last_damaged_by_sentry:
		return
	var bounty_ammo := KILL_AMMO_BOUNTY_BIG if spider.big else KILL_AMMO_BOUNTY_SMALL
	if bounty_ammo <= 0:
		return
	if not _try_add_ammo(PICKUP_PISTOL_AMMO, bounty_ammo):
		_spawn_pickup(spider.position, PICKUP_PISTOL_AMMO, bounty_ammo, Vector2(0, -18))


func _update_structures(delta: float) -> void:
	_ensure_enemy_spatial_buckets()
	for structure_index in range(structures.size() - 1, -1, -1):
		var structure: Structure = structures[structure_index]
		structure.base_id = base_network.powered_base_for(structure.cell)
		structure.powered = structure.kind in [BUILD_PERSONAL_BASE, BUILD_MERCHANT_STORE] or structure.fortress_chest or not structure.base_id.is_empty()
		if structure.kind == BUILD_LAND_MINE:
			if CombatSpatialScript.enemy_near_position(_enemy_spatial_buckets, structure.position, 14.0, enemies):
				_explode_area_damage(structure.position, 95.0, 42.0, Color("ff9a46"), true)
				structures.remove_at(structure_index)
				_invalidate_structure_spatial_buckets()
			continue
		if structure.kind == BUILD_TORCH:
			structure.cooldown = maxf(0.0, structure.cooldown - delta)
			var contacts := _torch_contact_count(structure)
			if contacts > 0 and structure.cooldown <= 0.0:
				discovery_alert = "LANTERN CONTACT // %d HOSTILE%s // GRID %02d:%02d" % [contacts, "" if contacts == 1 else "S", structure.cell.x, structure.cell.y]
				discovery_alert_time = 1.8
				structure.cooldown = TORCH_ALERT_INTERVAL
			continue
		if structure.kind not in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET]:
			continue
		structure.cooldown = maxf(0.0, structure.cooldown - delta)
		if structure.cooldown > 0.0:
			continue
		var target: Spider = _turret_target_spider(structure, structure_index, 128.0 if structure.kind == BUILD_SENTRY else (160.0 if structure.kind == BUILD_ROCKET_TURRET else 176.0))
		if target == null:
			continue
		var direction := (target.position - structure.position).normalized()
		structure.aim_direction = direction
		if structure.kind == BUILD_ROCKET_TURRET:
			_spawn_bullet(structure.position + direction * 9.0, direction, _turret_damage_at_level(structure.level, structure.kind), true, false, 3.0, 8.0, Color("ff9b45"), 1.6, 0, "rocket", 48.0)
			structure.cooldown = _turret_interval_at_level(structure.level, structure.powered, structure.kind)
			_combat_feedback(structure.position + direction * 9.0, direction, "impact_orange", Color("ffb05a"), 6, 38.0)
		elif structure.kind == BUILD_LASER_TURRET:
			_spawn_bullet(structure.position + direction * 8.0, direction, _turret_damage_at_level(structure.level, structure.kind), true, false, 2.0, 3.0, Color("69efff"), 0.75, 0, "laser_turret")
			structure.cooldown = _turret_interval_at_level(structure.level, structure.powered, structure.kind)
			_spawn_combat_impact("laser_muzzle", structure.position + direction * 8.0, direction, Vector2(12, 12), 0.08)
			_burst(structure.position + direction * 8.0, Color("a7fbff"), 1, 18.0)
		else:
			_spawn_bullet(structure.position + direction * 7.0, direction, _turret_damage_at_level(structure.level, structure.kind), true, false, 2.0, 4.0, Color("82e9ff"))
			structure.cooldown = _turret_interval_at_level(structure.level, structure.powered, structure.kind)
			_spawn_combat_impact("muzzle_sentry", structure.position + direction * 8.0, direction, Vector2(12, 10), 0.08)
			_burst(structure.position + direction * 8.0, Color("82e9ff"), 1, 20.0)


func _place_structure(cell: Vector2i) -> void:
	_adopt_deployable_stock_mirror()
	if not _can_place_structure(cell):
		_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
		return
	# Doorway: only 1 allowed at a time
	if selected_build == BUILD_HEAVY_DOORWAY and _doorway_exists():
		discovery_alert = "DOORWAY ALREADY PLACED // ONLY 1 ALLOWED"
		discovery_alert_time = 2.5
		_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
		return
	if selected_build == BUILD_FOUNDRY and kit_count("foundry") <= 0:
		discovery_alert = "NO FOUNDRY KIT AVAILABLE // FABRICATE AT COMMAND CORE"
		discovery_alert_time = 2.5
		return
	if selected_build == BUILD_PERSONAL_BASE:
		if not grid.is_region_active(cell):
			discovery_alert = "PERSONAL BASE REQUIRES PREPARED GROUND"
			discovery_alert_time = 2.5
			return
	if selected_build == BUILD_MERCHANT_STORE:
		if not merchant_invited:
			discovery_alert = "MERCHANT HAS NOT BEEN INVITED // USE COMMAND CORE"
			discovery_alert_time = 2.5
			return
		if not grid.is_region_active(cell):
			discovery_alert = "MERCHANT STORE REQUIRES PREPARED GROUND"
			discovery_alert_time = 2.5
			return
	var cost := 25 if selected_build == BUILD_BARRICADE else (60 if selected_build == BUILD_SENTRY else 0)
	var stock_id := str(BUILD_STOCK_KEYS.get(selected_build, ""))
	if cost > 0 and scrap < cost:
		discovery_alert = "INSUFFICIENT CREDITS // NEED $%d" % cost
		discovery_alert_time = 2.0
		_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
		return
	if not stock_id.is_empty() and kit_count(stock_id) <= 0:
		discovery_alert = "NO %s KIT // FABRICATE AT CORE" % _construction_name(stock_id)
		discovery_alert_time = 2.5
		_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
		return
	var structure := Structure.new()
	structure.kind = selected_build
	structure.cell = cell
	structure.position = grid.cell_to_world(cell)
	var base_health := {
		BUILD_BARRICADE: 140.0, BUILD_SENTRY: 72.0, BUILD_GRANITE_BARRIER: 240.0,
		BUILD_STEEL_BARRIER: 300.0, BUILD_REINFORCED_BARRIER: 390.0,
		BUILD_BLAST_BARRIER: 620.0, BUILD_LAND_MINE: 1.0,
		BUILD_ROCKET_TURRET: 120.0, BUILD_LASER_TURRET: 96.0,
		BUILD_CHEST_SMALL: 100.0, BUILD_CHEST_MEDIUM: 150.0, BUILD_CHEST_LARGE: 250.0,
		BUILD_HEAVY_DOORWAY: 800.0, BUILD_FOUNDRY: 420.0, BUILD_PERSONAL_BASE: 360.0,
		BUILD_TORCH: TORCH_DURABILITY[1], BUILD_MERCHANT_STORE: SettlementProgressionScript.MERCHANT_STORE_MAX_HEALTH,
	}
	structure.health = float(base_health.get(selected_build, 72.0)) * fortification_multiplier
	structure.max_health = structure.health
	if selected_build == BUILD_HEAVY_DOORWAY:
		var fp := _footprint_for_build(BUILD_HEAVY_DOORWAY, build_orientation)
		structure.size = fp
		structure.rotated = build_orientation
		structure.is_open = false
	elif selected_build == BUILD_FOUNDRY:
		structure.size = Vector2i(2, 2)
		structure.level = 1
		FoundryUnitScript.ensure_state(structure)
	elif selected_build == BUILD_PERSONAL_BASE:
		structure.size = Vector2i(3, 2)
		structure.level = 1
	elif selected_build == BUILD_MERCHANT_STORE:
		structure.size = SettlementProgressionScript.MERCHANT_STORE_FOOTPRINT
		structure.level = 1
	elif selected_build == BUILD_CHEST_SMALL:
		structure.chest_capacity = 100
	elif selected_build == BUILD_CHEST_MEDIUM:
		structure.chest_capacity = 300
	elif selected_build == BUILD_CHEST_LARGE:
		structure.chest_capacity = 800
	if selected_build in [BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER]:
		structure.aim_direction = aim_direction
	structure.base_id = base_network.powered_base_for(cell)
	structure.powered = selected_build in [BUILD_PERSONAL_BASE, BUILD_MERCHANT_STORE] or not structure.base_id.is_empty()
	structures.append(structure)
	_invalidate_structure_spatial_buckets()
	if cost > 0:
		_apply_scrap_delta(-cost, "deploy_structure")
	if not stock_id.is_empty():
		if OperatorLoadoutScript.is_placeable(_hotbar_active_stack()) and (
			str(_hotbar_active_stack().get("id", "")) == stock_id
			or (str(_hotbar_active_stack().get("kind", "")) == OperatorLoadoutScript.KIND_BUILD and int(_hotbar_active_stack().get("build_kind", -1)) == selected_build)
		):
			if str(_hotbar_active_stack().get("kind", "")) == OperatorLoadoutScript.KIND_DEPLOYABLE:
				operator_loadout.consume_active(1)
				_sync_deployable_mirror()
		else:
			consume_kit(stock_id, 1)
	elif selected_build == BUILD_FOUNDRY:
		_consume_foundry_kit()
	if selected_build in [BUILD_FOUNDRY, BUILD_PERSONAL_BASE, BUILD_MERCHANT_STORE]:
		build_mode = false
	if selected_build == BUILD_PERSONAL_BASE:
		discovery_alert = "FIELD HUT ONLINE // PRESS F TO HEAL AND SAVE"
	elif selected_build == BUILD_MERCHANT_STORE:
		merchant_store_kit_issued = true
		merchant_store_structure_index = structures.size() - 1
		hive_awareness.register_activity("settlement", grid.region_for_cell(cell))
		discovery_alert = "FIRST SETTLEMENT STORE ONLINE // PRESS F TO ENTER // SAFE INTERIOR"
	else:
		discovery_alert = "%s DEPLOYED" % _build_name(selected_build)
	discovery_alert_time = 1.8
	_burst(structure.position, Color("77dff3"), 10, 40.0)
	if selected_build in [BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER, BUILD_HEAVY_DOORWAY, BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET, BUILD_PERSONAL_BASE, BUILD_FOUNDRY, BUILD_MERCHANT_STORE]:
		_mark_flow_dirty_for_structure_cell(cell)
	call_deferred("_save_run")


func _can_place_structure(cell: Vector2i) -> bool:
	_adopt_deployable_stock_mirror()
	var fp := _footprint_for_build(selected_build, build_orientation)
	if selected_build == BUILD_FOUNDRY:
		if kit_count("foundry") <= 0:
			return false
		var owner_id := base_network.powered_base_for(cell)
		if owner_id.is_empty():
			return false
		if cell.distance_to(base_network.get_cell(owner_id)) > float(base_network.territory_radius(owner_id) - 2):
			return false
	if selected_build == BUILD_PERSONAL_BASE:
		if not grid.is_region_active(cell):
			return false
	if selected_build == BUILD_MERCHANT_STORE:
		if not merchant_invited or _merchant_store_index() >= 0 or not grid.is_region_active(cell):
			return false
	for ox in range(fp.x):
		for oy in range(fp.y):
			var c := cell + Vector2i(ox, oy)
			if not grid.is_region_active(c) or not grid.is_walkable(c):
				return false
			if grid.cell_to_world(c).distance_to(player_position) > 96.0:
				return false
			for base_id: String in base_network.bases.keys():
				if c.distance_to(base_network.get_cell(base_id)) < 2.0:
					return false
			if c in grid.spawn_cells:
				return false
			if _brood_nest_index_at_cell(c) >= 0:
				return false
			for structure in structures:
				if _structure_covers_cell(structure, c):
					return false
	return true


func _mark_flow_dirty_for_structure_cell(cell: Vector2i) -> void:
	# Keep the public signature stable for tests/tools.
	var _unused_cell := cell
	## BV5.4 base flows describe terrain topology only. Dynamic defenses are handled
	## by the blocker cache and explicit breach targeting, so placing/destroying a
	## barrier must not rebuild a regional BFS field. This removes siege-time flow
	## spikes while preserving immediate collision behavior.
	_rebuild_enemy_blocker_cache()
	flow_epoch += 1


func _mark_flow_dirty_for_structure(structure: Structure) -> void:
	# Keep the public signature stable for tests/tools.
	var _unused_structure := structure
	## Door state/footprint changes are dynamic blockers, not terrain mutations.
	_rebuild_enemy_blocker_cache()
	flow_epoch += 1


func _grant_mined_block_if_eligible(cell: Vector2i) -> void:
	## Compatibility entrypoint retained for tests/tools. New mining calls the richer
	## wall-economy handler so MK1 salvage and placed-wall recovery share one path.
	if _mining_tool_tier() >= 2:
		_try_store_wall_block(_biome_for_cell(cell))


func _try_store_wall_block(biome_id: int) -> bool:
	var block_id: String = PlaceableBlocksScript.block_id_for_biome(biome_id)
	var stack: Dictionary = OperatorLoadoutScript.make_stack(OperatorLoadoutScript.KIND_BLOCK, block_id, 1)
	if not operator_loadout.can_accept_stack(stack, 1):
		return false
	return operator_loadout.add_stacks(stack) <= 0


func _handle_mined_wall_economy(cell: Vector2i, biome_id: int, was_placed_block: bool) -> void:
	## Natural MK2+ walls become reusable biome blocks. MK1 walls become raw
	## salvage. Player-placed walls never mint scrap/material on re-mining; they
	## are recovered as their original block, with recycle fallback only if full.
	if was_placed_block or _mining_tool_tier() >= 2:
		if _try_store_wall_block(biome_id):
			return
	var salvage: Dictionary = BiomeWallEconomyScript.recycle_manifest(biome_id, 1) if was_placed_block else BiomeWallEconomyScript.natural_salvage(biome_id, cell, run_seed)
	_add_wall_salvage_or_drop(salvage, grid.cell_to_world(cell))


func _add_wall_salvage_or_drop(manifest: Dictionary, at_position: Vector2) -> void:
	if manifest.is_empty():
		return
	var unit_count: int = BiomeWallEconomyScript.manifest_units(manifest)
	if _can_accept_units(unit_count):
		for material_id: String in manifest.keys():
			material_economy.add_raw(material_id, int(manifest[material_id]))
		return
	var launch_index: int = 0
	for material_id: String in manifest.keys():
		var amount: int = int(manifest[material_id])
		if amount <= 0:
			continue
		var launch := Vector2(-16.0 + float(launch_index * 12), -20.0 - float(launch_index * 3))
		_spawn_pickup(at_position, material_id, amount, launch)
		launch_index += 1


func _place_block_from_hotbar(cell: Vector2i) -> void:
	var stack := _hotbar_active_stack()
	if str(stack.get("kind", "")) != OperatorLoadoutScript.KIND_BLOCK or int(stack.get("count", 0)) <= 0:
		return
	if not grid.in_bounds(cell) or not grid.is_walkable(cell):
		_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
		return
	if grid.cell_to_world(cell).distance_to(player_position) > 96.0:
		return
	for structure in structures:
		if _structure_covers_cell(structure, cell):
			_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
			return
	if cell in grid.spawn_cells or _brood_nest_index_at_cell(cell) >= 0:
		return
	var block_id := str(stack.get("id", ""))
	var biome_id := PlaceableBlocksScript.biome_from_block_id(block_id)
	if biome_id < 0:
		biome_id = 0
	grid.set_cell(cell, WorldGridScript.ROCK)
	if grid.get_cell(cell) != WorldGridScript.ROCK:
		_burst(grid.cell_to_world(cell), Color("e55858"), 5, 24.0)
		return
	placeable_blocks.set_placed(cell, biome_id)
	operator_loadout.consume_active(1)
	# WorldGrid.terrain_cell_changed already queued the immediate block mutation
	# patch. Do not schedule the same visual invalidation a second time here.
	_mark_flow_dirty_for_structure_cell(cell)
	discovery_alert = "BLOCK PLACED"
	discovery_alert_time = 1.2
	_burst(grid.cell_to_world(cell), Color("77dff3"), 8, 32.0)
	call_deferred("_save_run")


func _footprint_for_build(kind: int, rotated: bool) -> Vector2i:
	if kind == BUILD_HEAVY_DOORWAY:
		return Vector2i(1, 2) if rotated else Vector2i(2, 1)
	if kind == BUILD_FOUNDRY:
		return Vector2i(2, 2)
	if kind == BUILD_PERSONAL_BASE:
		return Vector2i(3, 2)
	if kind == BUILD_MERCHANT_STORE:
		return SettlementProgressionScript.MERCHANT_STORE_FOOTPRINT
	return Vector2i(1, 1)


func _footprint_for_doorway_level(level: int, rotated: bool) -> Vector2i:
	var base_fp: Vector2i
	match level:
		1: base_fp = Vector2i(2, 1)
		2: base_fp = Vector2i(4, 1)
		3: base_fp = Vector2i(4, 2)
		_: base_fp = Vector2i(2, 1)
	if rotated:
		return Vector2i(base_fp.y, base_fp.x)
	return base_fp


func _structure_covers_cell(structure: Structure, cell: Vector2i) -> bool:
	for ox in range(structure.size.x):
		for oy in range(structure.size.y):
			if structure.cell + Vector2i(ox, oy) == cell:
				return true
	return false


func _nearby_doorway() -> int:
	for i in range(structures.size()):
		var s: Structure = structures[i]
		if s.kind == BUILD_HEAVY_DOORWAY:
			# Check distance to any cell in the doorway footprint
			for ox in range(s.size.x):
				for oy in range(s.size.y):
					var cp: Vector2 = grid.cell_to_world(s.cell + Vector2i(ox, oy))
					if cp.distance_to(player_position) < 52.0:
						return i
	return -1


func _doorway_exists() -> bool:
	for s in structures:
		if s.kind == BUILD_HEAVY_DOORWAY:
			return true
	return false


func _explode_area_damage(at_position: Vector2, damage: float, radius: float, color: Color, from_sentry: bool = false) -> void:
	_combat_feedback(at_position, Vector2.UP, "rocket_explosion", color, 34, 105.0, true)
	for enemy_index in range(enemies.size() - 1, -1, -1):
		var spider: Spider = enemies[enemy_index]
		var distance_to_blast: float = at_position.distance_to(spider.position)
		if distance_to_blast > radius:
			continue
		var falloff: float = lerpf(1.0, 0.35, distance_to_blast / maxf(1.0, radius))
		spider.health -= damage * falloff
		spider.last_damaged_by_sentry = from_sentry
		spider.hit_flash = 0.12
		spider.hit_reaction = 0.18
		spider.hit_recoil_direction = (spider.position - at_position).normalized()
		if spider.health <= 0.0:
			_kill_spider(enemy_index)
	for nest_index in range(brood_nests.size() - 1, -1, -1):
		var nest_position := grid.cell_to_world(brood_nests[nest_index].cell)
		var distance_to_nest := at_position.distance_to(nest_position)
		if distance_to_nest <= radius + 10.0:
			var falloff := lerpf(1.0, 0.35, distance_to_nest / maxf(1.0, radius + 10.0))
			_damage_brood_nest(nest_index, damage * falloff)


func _brood_nest_hit_index(at_position: Vector2, radius: float) -> int:
	for nest_index in range(brood_nests.size()):
		if at_position.distance_to(grid.cell_to_world(brood_nests[nest_index].cell)) <= radius:
			return nest_index
	return -1


func _update_sparks(delta: float) -> void:
	for index_to_update in range(sparks.size() - 1, -1, -1):
		var spark := sparks[index_to_update]
		spark.position += spark.velocity * delta
		spark.velocity *= 0.92
		spark.life -= delta
		if spark.life <= 0.0:
			sparks.remove_at(index_to_update)


func _update_xp_highlights(delta: float) -> void:
	for index_to_update in range(xp_highlights.size() - 1, -1, -1):
		var highlight := xp_highlights[index_to_update]
		highlight.position += highlight.velocity * delta
		highlight.velocity *= 0.94
		highlight.life -= delta
		if highlight.life <= 0.0:
			xp_highlights.remove_at(index_to_update)


func _spawn_xp_highlight(label: String, at_position: Vector2, color: Color = Color("8eeaff")) -> void:
	if label.is_empty():
		return
	var highlight := XpHighlight.new()
	highlight.text = label
	highlight.color = color
	highlight.position = at_position + Vector2(randf_range(-10.0, 10.0), randf_range(-4.0, 2.0))
	highlight.velocity = Vector2(randf_range(-8.0, 8.0), -36.0)
	xp_highlights.append(highlight)
	_burst(at_position, color, 5, 18.0)


func _turret_target_spider(structure: Structure, structure_index: int, max_range: float) -> Spider:
	var cached: Variant = _turret_target_cache.get(structure_index)
	if _combat_frame_tick % 2 != 0 and cached != null:
		var cached_index: int = int(cached.get("index", -1))
		if cached_index >= 0 and cached_index < enemies.size():
			var cached_spider: Spider = enemies[cached_index]
			if structure.position.distance_to(cached_spider.position) <= max_range:
				return cached_spider
	var best_index := CombatSpatialScript.nearest_enemy_index(_enemy_spatial_buckets, structure.position, max_range, enemies, 2)
	var best_spider: Spider = null
	if best_index >= 0:
		best_spider = enemies[best_index]
	_turret_target_cache[structure_index] = {"index": best_index}
	return best_spider


func _request_spider_routing_flow_refresh(spider: Spider, current_cell: Vector2i) -> void:
	var target_base_id := spider.target_base_id
	if target_base_id.is_empty():
		target_base_id = BaseNetworkScript.COMMAND_ID
	var region := grid.region_for_cell(current_cell)
	var key := "%s|%d|%d" % [target_base_id, region.x, region.y]
	_spider_flow_refresh_regions[key] = {
		"region": region,
		"cell": current_cell,
		"target_base_id": target_base_id,
	}


func _service_spider_routing_flow_refresh() -> void:
	if _spider_flow_refresh_regions.is_empty():
		return
	var accepted_regions: Dictionary = {}
	for request_value: Variant in _spider_flow_refresh_regions.values():
		var request: Dictionary = request_value
		var region: Vector2i = request.get("region", Vector2i.ZERO)
		var accepted := routing_flow_rebuild_pending or accepted_regions.has(region)
		if not accepted:
			accepted = _mark_flow_region_dirty(region)
			if accepted:
				accepted_regions[region] = true
		if not accepted:
			continue
		var target_base_id := str(request.get("target_base_id", BaseNetworkScript.COMMAND_ID))
		var current_cell: Vector2i = request.get("cell", Vector2i.ZERO)
		# Keep the farthest anchor per target; a repair corridor reaching the
		# farthest mob naturally covers clustered mobs nearer that target.
		var replace_anchor := not _routing_flow_repair_requests.has(target_base_id)
		if not replace_anchor:
			var existing: Dictionary = _routing_flow_repair_requests[target_base_id]
			var target_cell := base_network.get_cell(target_base_id)
			var existing_cell: Vector2i = existing.get("cell", current_cell)
			replace_anchor = current_cell.distance_squared_to(target_cell) > existing_cell.distance_squared_to(target_cell)
		if replace_anchor:
			_routing_flow_repair_requests[target_base_id] = request
	_spider_flow_refresh_regions.clear()
	if accepted_regions.is_empty() and not routing_flow_rebuild_pending:
		return

	# Leading-edge debounce: once armed, repeated no-flow requests MUST NOT push
	# the deadline forward. The previous trailing-edge max() call was starved by
	# requests every frame, so the flow rebuild could literally never execute.
	if not routing_flow_rebuild_pending:
		routing_flow_rebuild_pending = true
		if gameplay_telemetry != null:
			for unused_region: Variant in accepted_regions.keys():
				gameplay_telemetry.note_refresh_request()
	if not terrain_flow_dirty:
		terrain_flow_dirty = true
		terrain_flow_rebuild_cooldown = TERRAIN_FLOW_REBUILD_DELAY
	elif terrain_flow_rebuild_cooldown <= 0.0:
		terrain_flow_rebuild_cooldown = TERRAIN_FLOW_REBUILD_DELAY
	if gameplay_telemetry != null and not accepted_regions.is_empty():
		gameplay_telemetry.note_refresh_batch(accepted_regions.size())


func _mark_flow_region_dirty(region: Vector2i) -> bool:
	var now := Time.get_ticks_msec() * 0.001
	if flow_region_dirty_cooldowns.has(region):
		if now - float(flow_region_dirty_cooldowns[region]) < FLOW_REGION_DIRTY_COOLDOWN:
			return false
	flow_region_dirty_cooldowns[region] = now
	flow_dirty_regions[region] = true
	return true


func _siege_spark_load() -> bool:
	return enemies.size() >= SPARK_SIEGE_ENEMY_THRESHOLD


func _trim_sparks_for_budget(incoming: int) -> int:
	while sparks.size() + incoming > MAX_SPARKS and not sparks.is_empty():
		sparks.remove_at(0)
	return mini(incoming, maxi(0, MAX_SPARKS - sparks.size()))


func _trim_combat_impacts_for_budget(incoming: int) -> int:
	while combat_impacts.size() + incoming > MAX_COMBAT_IMPACTS and not combat_impacts.is_empty():
		combat_impacts.remove_at(0)
	return mini(incoming, maxi(0, MAX_COMBAT_IMPACTS - combat_impacts.size()))


func _spawn_combat_impact(
	texture_id: String,
	at_position: Vector2,
	direction: Vector2 = Vector2.RIGHT,
	size: Vector2 = Vector2(-1, -1),
	duration: float = -1.0,
	enemy_pop: bool = false
) -> void:
	if not USE_IMPORTED_COMBAT_FX or texture_id.is_empty():
		return
	if _combat_texture(texture_id) == null:
		return
	if _trim_combat_impacts_for_budget(1) <= 0:
		return
	var impact := CombatImpact.new()
	impact.texture_id = texture_id
	impact.position = at_position
	impact.direction = direction if direction.length_squared() > 0.0001 else Vector2.RIGHT
	impact.size = size if size.x > 0.0 and size.y > 0.0 else CombatVfxScript.impact_size(texture_id)
	impact.max_life = duration if duration > 0.0 else CombatVfxScript.impact_duration(texture_id)
	impact.life = impact.max_life
	impact.modulate = Color.WHITE
	impact.enemy_pop = enemy_pop
	combat_impacts.append(impact)


func _combat_feedback(
	at_position: Vector2,
	direction: Vector2,
	texture_id: String,
	spark_color: Color,
	spark_amount: int,
	spark_force: float,
	critical: bool = false,
	enemy_pop: bool = false
) -> void:
	var spawned_sprite := false
	if USE_IMPORTED_COMBAT_FX and not texture_id.is_empty() and _combat_texture(texture_id) != null:
		_spawn_combat_impact(texture_id, at_position, direction, Vector2(-1, -1), -1.0, enemy_pop)
		spawned_sprite = true
	var burst_amount := spark_amount
	if spawned_sprite:
		burst_amount = maxi(1, spark_amount / 2) if spark_amount > 0 else 0
	if burst_amount > 0:
		_burst(at_position, spark_color, burst_amount, spark_force, critical)


func _update_combat_impacts(delta: float) -> void:
	for index_to_update in range(combat_impacts.size() - 1, -1, -1):
		var impact := combat_impacts[index_to_update]
		impact.life -= delta
		if impact.life <= 0.0:
			combat_impacts.remove_at(index_to_update)


func _draw_combat_impacts(canvas: CanvasItem) -> void:
	for impact: CombatImpact in combat_impacts:
		var texture := _combat_texture(impact.texture_id)
		if texture == null:
			continue
		var ratio := clampf(impact.life / maxf(0.001, impact.max_life), 0.0, 1.0)
		var modulate := Color(impact.modulate, ratio)
		var draw_size := impact.size
		if impact.enemy_pop:
			draw_size *= 0.85 + ratio * 0.4
		_draw_oriented_combat_sprite(canvas, texture, impact.position, impact.direction, draw_size, modulate)
	if mining_impact_pulse > 0.0 and USE_IMPORTED_COMBAT_FX:
		var rock_texture := _combat_texture("impact_rock")
		if rock_texture != null:
			var impact_ratio := 1.0 - mining_impact_pulse / 0.28
			var rock_size := Vector2(10, 10) * (0.85 + impact_ratio * 0.45)
			_draw_oriented_combat_sprite(
				canvas,
				rock_texture,
				mining_impact_position,
				aim_direction if aim_direction.length_squared() > 0.0001 else Vector2.RIGHT,
				rock_size,
				Color(1.0, 1.0, 1.0, 1.0 - impact_ratio)
			)


func _draw_laser_segment_chain(canvas: CanvasItem, beam_start: Vector2, beam_end: Vector2, direction: Vector2) -> void:
	var segment_texture := _combat_texture("laser_segment")
	if segment_texture == null:
		return
	var segment_length := 16.0
	var distance := beam_start.distance_to(beam_end)
	if distance <= 0.001:
		return
	var steps := maxi(1, ceili(distance / segment_length))
	for step_index in range(steps):
		var t := float(step_index) / float(maxi(1, steps - 1))
		var segment_position := beam_start.lerp(beam_end, t)
		_draw_oriented_combat_sprite(canvas, segment_texture, segment_position, direction, Vector2(16, 4), Color(1.0, 1.0, 1.0, 0.88))


func _burst(at_position: Vector2, color: Color, amount: int, force: float, critical: bool = false) -> void:
	if amount <= 0:
		return
	if not critical and enemies.size() >= SPARK_MINING_SKIP_THRESHOLD and amount <= 2:
		return
	var scaled_amount := amount
	if not critical and _siege_spark_load():
		scaled_amount = maxi(1, amount / 2)
	if not critical and scaled_amount > 12:
		scaled_amount = 12
	scaled_amount = _trim_sparks_for_budget(scaled_amount)
	if scaled_amount <= 0:
		return
	for particle_index in range(scaled_amount):
		var spark := Spark.new()
		var angle := randf() * TAU
		var magnitude := randf_range(force * 0.35, force)
		spark.position = at_position
		spark.velocity = Vector2.from_angle(angle) * magnitude
		spark.max_life = randf_range(0.18, 0.48)
		spark.life = spark.max_life
		spark.color = color
		spark.size = randf_range(1.0, 2.2)
		sparks.append(spark)


func _pointed_cell(controller_distance: float) -> Vector2i:
	if aim_uses_controller:
		return grid.world_to_cell(player_position + aim_direction * controller_distance)
	return grid.world_to_cell(_mouse_world_position())


func _finish_run() -> void:
	if game_over:
		return
	game_over = true
	realm_ended = true
	_save_run(true)
	RealmSaveScript.clear_recovery(realm_id)
	choosing_upgrade = false
	using_core_base = false
	using_foundry = false
	using_realm_archive = false
	if is_instance_valid(core_base_panel):
		core_base_panel.visible = false
	if is_instance_valid(foundry_panel):
		foundry_panel.visible = false
	if is_instance_valid(realm_archive_panel):
		realm_archive_panel.visible = false
	core_health = 0.0
	game_over_label.text = "BASE NETWORK OFFLINE // %s\nAWARENESS %s   SCORE %07d" % [difficulty["name"], hive_awareness.tier_label(), score]
	game_over_panel.visible = true
	game_over_panel.get_node("Buttons/Retry").grab_focus()


func set_paused(value: bool) -> void:
	if game_over:
		return
	if not value and using_realm_archive:
		_close_realm_archive()
		return
	if value and using_realm_archive:
		return
	paused = value
	pause_panel.visible = paused and not using_realm_archive
	_paused_ui_dirty = true
	if paused:
		pause_realm_title.text = grid.realm_title
		pause_summary.text = _pause_summary_text()
		_refresh_pause_actions()
		pause_panel.get_node("Frame/Buttons/Resume").grab_focus()


func _pause_summary_text() -> String:
	_sync_expedition_progress()
	var checkpoint_text := "SAVED  %s  ·  GEN %d" % [_base_short_name(checkpoint_base_id), checkpoint_generation] if checkpoint_exists else "NO CHECKPOINT  ·  REST AT A FIELD HUT OR USE A CORE"
	var hostile_count := enemies.size()
	return "HIVE %s  ·  HOSTILES %03d  ·  $%05d\n%s" % [hive_awareness.tier_label(), hostile_count, scrap, checkpoint_text]


func _refresh_pause_actions() -> void:
	if not is_instance_valid(pause_save_button):
		return
	if not _can_open_realm_archive():
		pause_save_button.text = "SAVE AT A CORE"
		pause_save_button.disabled = true
	elif not _save_ready():
		pause_save_button.text = "SAVE IN %dS" % ceili(realm_save_cooldown)
		pause_save_button.disabled = true
	else:
		pause_save_button.text = "SAVE GAME"
		pause_save_button.disabled = false


func _build_pause_panel() -> void:
	pause_panel = ColorRect.new()
	pause_panel.position = Vector2.ZERO
	pause_panel.size = VIEW_SIZE
	pause_panel.color = Color(0.006, 0.015, 0.02, 0.88)
	pause_panel.z_index = 100
	pause_panel.visible = false
	overlay_root.add_child(pause_panel)

	var pause_frame := Panel.new()
	pause_frame.name = "Frame"
	pause_frame.position = Vector2(100, 56)
	pause_frame.size = Vector2(440, 248)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color.TRANSPARENT
	pause_frame.add_theme_stylebox_override("panel", frame_style)
	pause_panel.add_child(pause_frame)

	var frame_art := TextureRect.new()
	frame_art.name = "FrameArt"
	frame_art.texture = _load_png_texture(OVERLAY_COMMAND_FRAME_PATH)
	frame_art.position = Vector2.ZERO
	frame_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame_art.size = pause_frame.size
	frame_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	frame_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_frame.add_child(frame_art)
	frame_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var title := Label.new()
	title.text = "PAUSED"
	title.position = Vector2(64, 25)
	title.size = Vector2(pause_frame.size.x - 128, 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", RealmVisualStyleScript.CYAN_TEXT)
	pause_frame.add_child(title)

	pause_realm_title = Label.new()
	pause_realm_title.position = Vector2(74, 61)
	pause_realm_title.size = Vector2(pause_frame.size.x - 148, 18)
	pause_realm_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_realm_title.add_theme_font_size_override("font_size", 11)
	pause_realm_title.add_theme_color_override("font_color", Color("b8dce4"))
	pause_frame.add_child(pause_realm_title)

	pause_summary = Label.new()
	pause_summary.position = Vector2(76, 82)
	pause_summary.size = Vector2(pause_frame.size.x - 152, 42)
	pause_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_summary.add_theme_font_size_override("font_size", 9)
	pause_summary.clip_text = true
	pause_summary.add_theme_color_override("font_color", Color("a9bac0"))
	pause_frame.add_child(pause_summary)

	var buttons := VBoxContainer.new()
	buttons.name = "Buttons"
	buttons.position = Vector2(102, 130)
	buttons.size = Vector2(236, 72)
	buttons.add_theme_constant_override("separation", 2)
	pause_frame.add_child(buttons)

	var resume := _overlay_button("RESUME")
	resume.name = "Resume"
	resume.custom_minimum_size = Vector2(236, 23)
	resume.add_theme_stylebox_override("normal", _button_style(Color(0.01, 0.04, 0.05, 0.72), Color("347c88"), 1))
	resume.pressed.connect(func() -> void: set_paused(false))
	buttons.add_child(resume)
	pause_save_button = _overlay_button("SAVE AT A CORE")
	pause_save_button.name = "Save"
	pause_save_button.custom_minimum_size = Vector2(236, 23)
	pause_save_button.add_theme_color_override("font_color", Color("f0c96d"))
	pause_save_button.add_theme_stylebox_override("normal", _button_style(Color(0.06, 0.045, 0.018, 0.72), Color("8e6b34"), 1))
	pause_save_button.pressed.connect(func() -> void: _open_realm_archive(true))
	buttons.add_child(pause_save_button)
	var menu := _overlay_button("MAIN MENU")
	menu.custom_minimum_size = Vector2(236, 23)
	menu.add_theme_color_override("font_color", Color("d3a89d"))
	menu.add_theme_stylebox_override("normal", _button_style(Color(0.05, 0.02, 0.02, 0.72), Color("6d4640"), 1))
	menu.pressed.connect(func() -> void:
		exit_to_menu.emit()
	)
	buttons.add_child(menu)

	var hint := Label.new()
	hint.text = "ESC  RESUME"
	hint.position = Vector2(72, 216)
	hint.size = Vector2(pause_frame.size.x - 144, 12)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color("547880"))
	pause_frame.add_child(hint)
	_apply_interface_typography()


func _build_realm_archive_panel() -> void:
	realm_archive_panel = ColorRect.new()
	realm_archive_panel.position = Vector2(60, 34)
	realm_archive_panel.size = Vector2(520, 292)
	realm_archive_panel.color = Color.TRANSPARENT
	realm_archive_panel.z_index = 109
	realm_archive_panel.visible = false
	overlay_root.add_child(realm_archive_panel)

	var frame_art := TextureRect.new()
	frame_art.name = "FrameArt"
	frame_art.texture = _load_png_texture(OVERLAY_COMMAND_FRAME_PATH)
	frame_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame_art.size = realm_archive_panel.size
	frame_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	frame_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	realm_archive_panel.add_child(frame_art)
	frame_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var title := Label.new()
	title.name = "ArchiveTitle"
	realm_archive_title = title
	title.text = "SAVE GAME"
	title.position = Vector2(92, 27)
	title.size = Vector2(336, 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("8eeaff"))
	realm_archive_panel.add_child(title)

	realm_archive_status = Label.new()
	realm_archive_status.position = Vector2(98, 65)
	realm_archive_status.size = Vector2(324, 18)
	realm_archive_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	realm_archive_status.add_theme_font_size_override("font_size", 9)
	realm_archive_status.add_theme_color_override("font_color", Color("f0d47b"))
	realm_archive_panel.add_child(realm_archive_status)

	realm_archive_detail = Label.new()
	realm_archive_detail.position = Vector2(100, 90)
	realm_archive_detail.size = Vector2(320, 40)
	realm_archive_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	realm_archive_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	realm_archive_detail.add_theme_font_size_override("font_size", 8)
	realm_archive_detail.add_theme_color_override("font_color", Color("9eb2b8"))
	realm_archive_panel.add_child(realm_archive_detail)

	var slot_list := VBoxContainer.new()
	slot_list.name = "ArchiveButtons"
	slot_list.position = Vector2(120, 151)
	slot_list.size = Vector2(280, 78)
	slot_list.add_theme_constant_override("separation", 2)
	realm_archive_panel.add_child(slot_list)

	realm_archive_save_buttons.clear()
	realm_archive_activate_buttons.clear()
	for slot_index in range(MAX_CHECKPOINT_SLOTS):
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(280, 25)
		row.add_theme_constant_override("separation", 4)
		slot_list.add_child(row)
		var save_button := _overlay_button("SAVE CHECKPOINT SLOT %d" % (slot_index + 1))
		save_button.custom_minimum_size = Vector2(280 if slot_index == 0 else 216, 25)
		save_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		save_button.add_theme_stylebox_override("normal", _button_style(Color(0.01, 0.035, 0.042, 0.7), Color("315e66"), 1))
		var slot_index_copy := slot_index
		save_button.pressed.connect(func() -> void: _try_commit_realm_save_slot(slot_index_copy))
		row.add_child(save_button)
		realm_archive_save_buttons.append(save_button)
		if slot_index > 0:
			var activate_button := _overlay_button("USE")
			activate_button.custom_minimum_size = Vector2(60, 25)
			activate_button.add_theme_color_override("font_color", Color("f0c96d"))
			activate_button.add_theme_stylebox_override("normal", _button_style(Color(0.06, 0.045, 0.018, 0.72), Color("8e6b34"), 1))
			var activate_slot := slot_index
			activate_button.pressed.connect(func() -> void: _try_activate_checkpoint_slot(activate_slot))
			row.add_child(activate_button)
			realm_archive_activate_buttons.append(activate_button)
	realm_archive_save_button = realm_archive_save_buttons[0]

	realm_archive_back_button = _overlay_button("BACK")
	realm_archive_back_button.position = Vector2(184, 250)
	realm_archive_back_button.size = Vector2(152, 24)
	realm_archive_back_button.custom_minimum_size = Vector2(152, 24)
	realm_archive_back_button.pressed.connect(_close_realm_archive)
	realm_archive_panel.add_child(realm_archive_back_button)

	var hint := Label.new()
	hint.text = "ESC  BACK"
	hint.position = Vector2(100, 276)
	hint.size = Vector2(320, 12)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color("547880"))
	realm_archive_panel.add_child(hint)


func _save_archive_base_id() -> String:
	var nearby := _nearby_base_id()
	if not nearby.is_empty() and base_network.get_status(nearby) == BaseNetworkScript.STATUS_ACTIVE:
		return nearby
	if using_core_base and not current_base_id.is_empty() and base_network.get_status(current_base_id) == BaseNetworkScript.STATUS_ACTIVE:
		return current_base_id
	if using_realm_archive and not current_base_id.is_empty() and base_network.get_status(current_base_id) == BaseNetworkScript.STATUS_ACTIVE:
		return current_base_id
	return ""


func _can_open_realm_archive() -> bool:
	return not _save_archive_base_id().is_empty()


func _is_at_save_archive() -> bool:
	return not _save_archive_base_id().is_empty()


func _checkpoint_anchor_position(base_id: String) -> Vector2:
	var shelter_index := _personal_base_index_for_anchor_id(base_id)
	if shelter_index >= 0:
		return _personal_base_exit_position(structures[shelter_index])
	if not base_network.bases.has(base_id):
		base_id = BaseNetworkScript.COMMAND_ID
	return grid.cell_to_world(base_network.get_cell(base_id) + Vector2i(-1, 0))


func _fallback_checkpoint_base_id() -> String:
	if base_network.get_status(BaseNetworkScript.COMMAND_ID) == BaseNetworkScript.STATUS_ACTIVE:
		return BaseNetworkScript.COMMAND_ID
	for base_id: String in base_network.active_ids():
		return base_id
	return BaseNetworkScript.COMMAND_ID


func _resolve_checkpoint_spawn() -> void:
	var shelter_index := _personal_base_index_for_anchor_id(checkpoint_base_id)
	if shelter_index < 0:
		if not base_network.bases.has(checkpoint_base_id) or base_network.get_status(checkpoint_base_id) != BaseNetworkScript.STATUS_ACTIVE:
			checkpoint_base_id = _fallback_checkpoint_base_id()
	checkpoint_position = _checkpoint_anchor_position(checkpoint_base_id)


func _open_realm_archive(return_to_pause: bool = false) -> void:
	if not _can_open_realm_archive():
		return
	archive_return_to_pause = return_to_pause
	using_realm_archive = true
	paused = true
	pause_panel.visible = false
	current_base_id = _save_archive_base_id()
	realm_archive_panel.visible = true
	_refresh_realm_archive_panel()
	if _can_commit_realm_save_for_slot(0):
		realm_archive_save_button.grab_focus()
	else:
		realm_archive_back_button.grab_focus()


func _close_realm_archive() -> void:
	using_realm_archive = false
	realm_archive_panel.visible = false
	var return_to_pause := archive_return_to_pause
	archive_return_to_pause = false
	paused = return_to_pause
	pause_panel.visible = return_to_pause
	if return_to_pause:
		pause_summary.text = _pause_summary_text()
		_refresh_pause_actions()
		pause_panel.get_node("Frame/Buttons/Resume").grab_focus()


func _refresh_realm_archive_panel() -> void:
	if not is_instance_valid(realm_archive_panel):
		return
	var archive_base_id := _save_archive_base_id()
	if archive_base_id.is_empty():
		archive_base_id = current_base_id
	var base_record: Dictionary = base_network.get_base(archive_base_id)
	realm_archive_title.text = "SAVE GAME"
	realm_archive_status.text = "%s  ·  AWARENESS %s" % [str(base_record.get("name", "CORE")), hive_awareness.tier_label()]
	var detail := "Choose a slot. Slot 1 is your active respawn point."
	if not _save_ready():
		detail = "Next save available in %d seconds." % ceili(realm_save_cooldown)
	elif checkpoint_exists and checkpoint_base_id == archive_base_id:
		detail = "Active checkpoint: %s  ·  Generation %d" % [str(base_record.get("name", archive_base_id)), checkpoint_generation]
	elif checkpoint_exists:
		detail = "Save to Slot 1 to move your respawn point here."
	else:
		detail = "No checkpoint yet. Save to Slot 1 to protect this realm."
	realm_archive_detail.text = detail
	for slot_index in range(realm_archive_save_buttons.size()):
		var save_button: Button = realm_archive_save_buttons[slot_index]
		save_button.custom_minimum_size.x = 280 if slot_index == 0 or not _checkpoint_slot_open(slot_index) else 216
		save_button.disabled = not _can_commit_realm_save_for_slot(slot_index)
		if not _checkpoint_slot_open(slot_index):
			save_button.text = "SLOT %d  ·  UNLOCKS AT LEVEL %d" % [slot_index + 1, _checkpoint_slot_level_req(slot_index)]
		elif slot_index == 0:
			save_button.text = "SLOT 1  ·  ACTIVE  ·  GEN %d" % checkpoint_generation if checkpoint_exists else "SLOT 1  ·  EMPTY"
		else:
			_ensure_checkpoint_slots_size()
			var stored: Dictionary = checkpoint_slots[slot_index] if slot_index < checkpoint_slots.size() else {}
			if stored.is_empty():
				save_button.text = "SLOT %d  ·  EMPTY" % (slot_index + 1)
			else:
				save_button.text = "SLOT %d  ·  %s  ·  GEN %d" % [slot_index + 1, _base_short_name(str(stored.get("base_id", ""))), int(stored.get("generation", 0))]
	for activate_index in range(realm_archive_activate_buttons.size()):
		var slot_index := activate_index + 1
		var activate_button: Button = realm_archive_activate_buttons[activate_index]
		activate_button.visible = _checkpoint_slot_open(slot_index)
		_ensure_checkpoint_slots_size()
		var stored: Dictionary = checkpoint_slots[slot_index] if slot_index < checkpoint_slots.size() else {}
		var active_here := checkpoint_exists and not stored.is_empty() and checkpoint_base_id == str(stored.get("base_id", "")) and checkpoint_generation == int(stored.get("generation", -1))
		activate_button.text = "ACTIVE" if active_here else "USE"
		activate_button.disabled = active_here or not _can_activate_checkpoint_slot(slot_index)


func _build_game_over_panel() -> void:
	game_over_panel = ColorRect.new()
	game_over_panel.position = Vector2.ZERO
	game_over_panel.size = VIEW_SIZE
	game_over_panel.color = Color(0.07, 0.005, 0.008, 0.9)
	game_over_panel.z_index = 110
	game_over_panel.visible = false
	overlay_root.add_child(game_over_panel)

	game_over_label = Label.new()
	game_over_label.position = Vector2(150, 78)
	game_over_label.size = Vector2(340, 70)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 20)
	game_over_label.add_theme_color_override("font_color", Color("ff8c7c"))
	game_over_panel.add_child(game_over_label)

	var buttons := VBoxContainer.new()
	buttons.name = "Buttons"
	buttons.position = Vector2(225, 176)
	buttons.size = Vector2(190, 90)
	buttons.add_theme_constant_override("separation", 8)
	game_over_panel.add_child(buttons)
	var retry := _overlay_button("RETRY")
	retry.name = "Retry"
	retry.pressed.connect(func() -> void: restart_requested.emit())
	buttons.add_child(retry)
	var menu := _overlay_button("MAIN MENU")
	menu.pressed.connect(func() -> void: exit_to_menu.emit())
	buttons.add_child(menu)


func _build_sleep_overlay() -> void:
	sleep_overlay = ColorRect.new()
	sleep_overlay.position = Vector2.ZERO
	sleep_overlay.size = VIEW_SIZE
	sleep_overlay.color = Color("02040d")
	sleep_overlay.z_index = 120
	sleep_overlay.visible = false
	sleep_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_root.add_child(sleep_overlay)
	var galaxy := ColorRect.new()
	galaxy.position = Vector2(72, 116)
	galaxy.size = Vector2(500, 74)
	galaxy.color = Color(0.18, 0.28, 0.62, 0.18)
	galaxy.rotation = -0.12
	galaxy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sleep_overlay.add_child(galaxy)
	for star_index in range(72):
		var star := ColorRect.new()
		star.position = Vector2(posmod(star_index * 83 + 29, 626) + 7, posmod(star_index * 47 + star_index * star_index, 320) + 8)
		var star_size := 2.0 if star_index % 11 == 0 else 1.0
		star.size = Vector2.ONE * star_size
		star.color = Color("bceeff") if star_index % 5 else Color("d8c7ff")
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sleep_overlay.add_child(star)
	sleep_status_label = Label.new()
	sleep_status_label.position = Vector2(110, 246)
	sleep_status_label.size = Vector2(420, 56)
	sleep_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sleep_status_label.add_theme_font_size_override("font_size", 15)
	sleep_status_label.add_theme_color_override("font_color", Color("a7eefa"))
	sleep_overlay.add_child(sleep_status_label)


func _begin_sleep(structure_index: int) -> void:
	if sleeping or structure_index < 0 or structure_index >= structures.size():
		return
	sleeping = true
	sleep_phase = 0
	sleep_elapsed = 0.0
	sleep_structure_index = structure_index
	sleep_overlay.modulate.a = 0.0
	sleep_overlay.visible = true
	sleep_status_label.text = "ENTERING PERSONAL BASE"


func _update_sleep_sequence(delta: float) -> void:
	sleep_elapsed += delta
	var shelter: Structure = structures[sleep_structure_index] if sleep_structure_index >= 0 and sleep_structure_index < structures.size() else null
	var tier := ShelterUnitScript.clamp_tier(shelter.level if shelter != null else 1)
	var rest_duration := ShelterUnitScript.rest_duration(tier)
	if sleep_phase == 0:
		sleep_overlay.modulate.a = clampf(sleep_elapsed / 0.55, 0.0, 1.0)
		if sleep_elapsed >= 0.55:
			sleep_phase = 1
			sleep_elapsed = 0.0
			sleep_status_label.text = "PERSONAL BASE REST // FREE RECOVERY"
		return
	if sleep_phase == 1:
		if shelter != null:
			var restored := ShelterUnitScript.apply_rest(shelter, player_health, sprint_energy, delta)
			player_health = float(restored["health"])
			sprint_energy = float(restored["energy"])
		if sleep_elapsed < rest_duration * 0.55:
			sleep_status_label.text = "RECOVERY MK%d // %.0f HP/S" % [tier, ShelterUnitScript.heal_rate(tier)]
		else:
			sleep_status_label.text = "REST COMPLETE // EXITING HUT"
		if sleep_elapsed >= rest_duration:
			sleep_phase = 2
			sleep_elapsed = 0.0
		return
	sleep_overlay.modulate.a = 1.0 - clampf(sleep_elapsed / 0.55, 0.0, 1.0)
	if sleep_elapsed < 0.55:
		return
	var saved_at_hut := false
	if shelter != null:
		player_health = 100.0
		sprint_energy = 100.0
		player_position = _personal_base_exit_position(shelter)
		player_camera.position = player_position
		var shelter_anchor := _personal_base_anchor_id(shelter)
		saved_at_hut = _commit_checkpoint_at(player_position, shelter_anchor)
		realm_save_cooldown = 0.0
	sleeping = false
	sleep_overlay.visible = false
	sleep_entry_cooldown = 2.0
	discovery_alert = "FIELD HUT REST COMPLETE // HP RESTORED // REALM SAVED" if shelter != null and saved_at_hut else "FIELD HUT REST COMPLETE // SAVE FAILED"
	discovery_alert_time = 3.5


func _expedition_xp_threshold() -> int:
	return 80 + expedition_level * 12


func _reconcile_expedition_xp(milestone_wave: int = -1, announce_level_up: bool = true) -> void:
	var sp_before := skill_points
	var leveled := false
	while expedition_xp >= _expedition_xp_threshold():
		expedition_xp -= _expedition_xp_threshold()
		expedition_level += 1
		skill_points += 1
		leveled = true
	var sp_gained := skill_points - sp_before
	if leveled and announce_level_up and sp_gained > 0:
		discovery_alert = "LEVEL UP // %d SP READY AT COMMAND PROGRESS" % skill_points
		discovery_alert_time = 4.5
		hud_level_up_flash = 0.65
		hud_sp_pulse = 1.0
		_spawn_xp_highlight("+%d SP" % sp_gained, player_position + Vector2(0, -28.0), Color("f0d47b"))
	_refresh_expedition_xp_meter()


func _sync_expedition_progress() -> void:
	_reconcile_expedition_xp(-1, true)


func _sync_progression_unlocks() -> void:
	if ProgressionTreeScript.is_unlocked("personal_base", skill_unlocks):
		construction_unlocks["personal_base"] = true


func _award_expedition_xp() -> void:
	_sync_expedition_progress()
	var gain := EXPEDITION_XP_BASE + hive_awareness.awareness_tier * 6 + mini(18, brood_escalation * 2)
	expedition_xp += maxi(1, gain)
	_reconcile_expedition_xp(-1)
	hud_xp_flash = 0.4
	hud_objective_pulse = 0.35
	_spawn_xp_highlight("+%d XP" % gain, player_position + Vector2(0, -18.0), Color("8eeaff"))


func _refresh_expedition_xp_meter() -> void:
	if not is_instance_valid(core_xp_label):
		return
	var threshold := maxi(1, _expedition_xp_threshold())
	var ratio := clampf(float(expedition_xp) / float(threshold), 0.0, 1.0)
	core_xp_fill.size.x = maxf(0.0, (core_xp_track.size.x - 2.0) * ratio)
	var sp_text := "  //  SP %d" % skill_points if skill_points > 0 else ""
	core_xp_label.text = "EXPEDITION XP  %d / %d  //  LVL %d%s" % [expedition_xp, threshold, expedition_level, sp_text]
	core_xp_label.add_theme_color_override("font_color", Color("f0d47b") if skill_points > 0 else Color("9adcf0"))


func _unlock_skill_node(node_id: String) -> bool:
	var gate := ProgressionTreeScript.can_unlock(node_id, skill_unlocks, skill_points, expedition_level)
	if gate != "READY":
		if using_core_base:
			core_base_status.text = gate
		return false
	skill_points -= ProgressionTreeScript.sp_cost(node_id)
	skill_unlocks.append(node_id)
	_rebuild_progression_multipliers()
	hud_sp_pulse = 1.0
	_push_comms_alert("SPENT %d SP // %s" % [ProgressionTreeScript.sp_cost(node_id), str(ProgressionTreeScript.node(node_id).get("label", node_id))], 4.0)
	_burst(grid.cell_to_world(grid.core_cell), Color("8eeaff"), 22, 74.0)
	if using_core_base:
		core_base_status.text = "PROGRESS  //  %s UNLOCKED" % str(ProgressionTreeScript.node(node_id).get("label", node_id))
		_refresh_core_base_panel()
	_save_run()
	return true


func _apply_skill_effect(node_id: String) -> void:
	match node_id:
		"overclock":
			weapon_damage_multiplier *= 1.18
			fire_rate_multiplier *= 1.04
		"fortify":
			fortification_multiplier *= 1.2
			core_health = minf(100.0, core_health + 30.0)
			base_network.bases[BaseNetworkScript.COMMAND_ID]["health"] = core_health
			player_health = minf(100.0, player_health + 30.0)
			for structure in structures:
				structure.max_health *= 1.2
				structure.health = structure.max_health
		"automation":
			sentry_damage_multiplier *= 1.2
			sentry_rate_multiplier *= 1.2
		"excavation":
			mining_cycle_multiplier = 0.95
		"personal_base":
			construction_unlocks["personal_base"] = true


func _rebuild_progression_multipliers() -> void:
	weapon_damage_multiplier = 1.0
	fire_rate_multiplier = 1.0
	fortification_multiplier = 1.0
	sentry_damage_multiplier = 1.0
	sentry_rate_multiplier = 1.0
	mining_cycle_multiplier = 1.0
	for node_id: String in skill_unlocks:
		_apply_skill_effect(node_id)
	_sync_progression_unlocks()


func _rebuild_player_armor_multipliers() -> void:
	player_strength_multiplier = PlayerArmorScript.strength_multiplier(player_style_id)
	player_defense_multiplier = PlayerArmorScript.defense_multiplier(player_style_id)


func _uses_regional_flow_fields() -> bool:
	return grid.width >= WorldGridScript.LAZY_TOPOLOGY_MIN_WIDTH


func _routing_flow_allowed_regions() -> Dictionary:
	if not _uses_regional_flow_fields():
		return {}
	var regions: Dictionary = flow_dirty_regions.duplicate()
	regions[grid.region_for_cell(grid.core_cell)] = true
	regions[grid.region_for_cell(grid.world_to_cell(player_position))] = true
	# Preserve a connected Command flow even when the immediate repair target is
	# a frontier base or a structure edit shares the same debounce window.
	regions.merge(grid.route_regions_for_flow(grid.spawn_cell, grid.core_cell, 2))
	for target_base_id: String in _routing_flow_repair_requests.keys():
		if not base_network.bases.has(target_base_id):
			continue
		var request: Dictionary = _routing_flow_repair_requests[target_base_id]
		var from_cell: Vector2i = request.get("cell", grid.world_to_cell(player_position))
		var target_cell := base_network.get_cell(target_base_id)
		regions.merge(grid.route_regions_for_flow(from_cell, target_cell, 2))
		# Authored realms often route through the primary spawn backbone instead
		# of a geometric straight line. Include both legs so the repair flow has a
		# connected regional corridor rather than two isolated endpoint regions.
		regions.merge(grid.route_regions_for_flow(from_cell, grid.spawn_cell, 2))
		regions.merge(grid.route_regions_for_flow(grid.spawn_cell, target_cell, 2))
	return regions


func _flow_allowed_regions(extra_cells: Array = [], mining_partial: bool = false) -> Dictionary:
	if not _uses_regional_flow_fields():
		return {}
	if mining_partial:
		var mining_regions: Dictionary = flow_dirty_regions.duplicate()
		mining_regions[grid.region_for_cell(grid.world_to_cell(player_position))] = true
		mining_regions[grid.region_for_cell(base_network.get_cell(BaseNetworkScript.COMMAND_ID))] = true
		mining_regions[grid.region_for_cell(grid.core_cell)] = true
		for cell_value: Variant in extra_cells:
			mining_regions[grid.region_for_cell(cell_value)] = true
		return grid.cap_regions_near_cell(
			mining_regions,
			grid.world_to_cell(player_position),
			WorldGridScript.MINING_FLOW_REGIONS
		)
	# Regional flow coverage follows the entity simulation envelope, not merely
	# what is visible. MAX_SIMULATION_REGIONS is intentionally aligned with the
	# full-flow cap so every actively ticking mob can live inside a flow map.
	var regions: Dictionary = grid.simulation_window_regions().duplicate()
	if regions.is_empty():
		regions = grid.loaded_regions.duplicate()
	for base_id: String in base_network.bases.keys():
		regions[grid.region_for_cell(base_network.get_cell(base_id))] = true
	for spawn_value: Variant in grid.spawn_cells:
		var spawn_cell: Vector2i = spawn_value
		regions[grid.region_for_cell(spawn_cell)] = true
		regions.merge(grid.spawn_lane_corridor_regions(spawn_cell))
	regions[grid.region_for_cell(grid.core_cell)] = true
	regions[grid.region_for_cell(grid.world_to_cell(player_position))] = true
	for site_value: Variant in grid.frontier_sites.values():
		regions.merge(grid.route_regions_for_flow(site_value, grid.core_cell, 2))
	for cell_value: Variant in extra_cells:
		var cell: Vector2i = cell_value
		regions[grid.region_for_cell(cell)] = true
	if not flow_dirty_regions.is_empty():
		regions.merge(flow_dirty_regions)
	regions = grid.expand_regions(regions, 1)
	return grid.cap_regions_near_cell(regions, grid.world_to_cell(player_position), WorldGridScript.MAX_FLOW_REGIONS)


func _materialize_spawn_routes() -> void:
	for spawn_value: Variant in grid.spawn_cells:
		var spawn_cell: Vector2i = spawn_value
		if spawn_cell == grid.spawn_cell and not breached:
			continue
		grid.materialize_route_regions(spawn_cell, grid.core_cell, 3)
	for site_value: Variant in grid.frontier_sites.values():
		grid.materialize_route_regions(site_value, grid.core_cell, 2)


func _refresh_spawn_lane_flow(spawn_at: Vector2i, target_base_id: String) -> void:
	var allowed_regions := _flow_allowed_regions([spawn_at, grid.core_cell, grid.spawn_cell])
	var target_cell: Vector2i = base_network.get_cell(target_base_id)
	var lane_flow: FlowFieldScript = FlowFieldScript.new()
	lane_flow.rebuild(grid, target_cell, allowed_regions)
	base_flows[target_base_id] = lane_flow
	if target_base_id == BaseNetworkScript.COMMAND_ID:
		flow = lane_flow


func _prune_unreachable_spawn_lanes() -> void:
	if grid.spawn_cells.size() <= 1:
		return
	var primary_lane: Vector2i = grid.spawn_cell
	var kept: Array[Vector2i] = [primary_lane]
	var kept_lookup: Dictionary = {primary_lane: true}
	for lane_index in range(1, grid.spawn_cells.size()):
		var lane: Vector2i = grid.spawn_cells[lane_index]
		grid.connect_spawn_lane_to_core(lane)
		if grid.has_walkable_route(lane, grid.core_cell) or grid.has_walkable_route(lane, primary_lane):
			kept.append(lane)
			kept_lookup[lane] = true
	# Protect mature brood nest lanes from prune drops.
	for nest: BroodNest in brood_nests:
		if nest.maturity < 1.0:
			continue
		if kept_lookup.has(nest.cell):
			continue
		if grid.spawn_cells.has(nest.cell) or grid.is_spawn_ready(nest.cell):
			kept.append(nest.cell)
			kept_lookup[nest.cell] = true
	if kept.size() != grid.spawn_cells.size():
		grid.spawn_cells = kept
		grid.activate_lanes(mini(grid.active_lane_count, maxi(1, grid.spawn_cells.size())))


func _rebuild_enemy_blocker_cache() -> void:
	_enemy_blocked_cells.clear()
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if not _structure_blocks_enemy(structure):
			continue
		var footprint := structure.size if structure.size != Vector2i.ZERO else Vector2i.ONE
		for ox in range(footprint.x):
			for oy in range(footprint.y):
				# Store index+1 instead of a bare bool. Membership semantics stay identical,
				# while routing can immediately identify the siege blocker without scanning.
				_enemy_blocked_cells[structure.cell + Vector2i(ox, oy)] = structure_index + 1


func _enemy_blocking_structure_index(cell: Vector2i) -> int:
	return int(_enemy_blocked_cells.get(cell, 0)) - 1


func _base_flow_intersects_dirty(base_id: String, mining_partial: bool = false) -> bool:
	if base_id == BaseNetworkScript.COMMAND_ID:
		return true
	var base_region := grid.region_for_cell(base_network.get_cell(base_id))
	if flow_dirty_regions.has(base_region):
		return true
	if mining_partial:
		return false
	for spawn_value: Variant in grid.spawn_cells:
		var spawn_cell: Vector2i = spawn_value
		var corridor: Dictionary = grid.spawn_lane_corridor_regions(spawn_cell)
		for region_value: Variant in flow_dirty_regions.keys():
			if corridor.has(region_value):
				return true
	return false


func _rebuild_base_flows(materialize_routes: bool = true, force_full: bool = true, mining_partial: bool = false, routing_partial: bool = false) -> void:
	var partial_ok := mining_partial or routing_partial or (not force_full and not flow_dirty_regions.is_empty())
	var boot_light := not force_full and not mining_partial and enemies.is_empty()
	if partial_ok and base_flow_rebuild_cooldown > 0.0 and not mining_partial:
		return
	_rebuild_enemy_blocker_cache()
	if materialize_routes and not mining_partial and not boot_light:
		_materialize_spawn_routes()
	# Dirty/partial rebuilds must not expand to MAX_FLOW_REGIONS (36) — that alone is 250–400ms.
	var use_light_regions := mining_partial or (partial_ok and not force_full and not routing_partial) or boot_light
	var allowed_regions := _routing_flow_allowed_regions() if routing_partial else _flow_allowed_regions([], use_light_regions)
	if boot_light:
		allowed_regions = grid.cap_regions_near_cell(
			{
				grid.region_for_cell(grid.core_cell): true,
				grid.region_for_cell(grid.world_to_cell(player_position)): true,
			},
			grid.world_to_cell(player_position),
			PLAYER_FLOW_REGION_CAP
		)
	var targets_to_rebuild: Array[String] = []
	if partial_ok:
		if mining_partial:
			targets_to_rebuild = [BaseNetworkScript.COMMAND_ID]
		elif routing_partial:
			for target_base_id: String in _routing_flow_repair_requests.keys():
				if base_network.bases.has(target_base_id) and not targets_to_rebuild.has(target_base_id):
					targets_to_rebuild.append(target_base_id)
			if not targets_to_rebuild.has(BaseNetworkScript.COMMAND_ID):
				targets_to_rebuild.append(BaseNetworkScript.COMMAND_ID)
		else:
			for base_id: String in base_network.bases.keys():
				if _base_flow_intersects_dirty(base_id, mining_partial):
					targets_to_rebuild.append(base_id)
			if targets_to_rebuild.is_empty():
				targets_to_rebuild = [BaseNetworkScript.COMMAND_ID]
	elif boot_light:
		targets_to_rebuild = [BaseNetworkScript.COMMAND_ID]
	else:
		base_flows.clear()
		if force_full:
			brood_carrier_flows.clear()
		for base_id: String in base_network.bases.keys():
			targets_to_rebuild.append(base_id)
	for base_id: String in targets_to_rebuild:
		var target_flow: FlowFieldScript = FlowFieldScript.new()
		target_flow.rebuild(grid, base_network.get_cell(base_id), allowed_regions)
		base_flows[base_id] = target_flow
	flow_dirty_regions.clear()
	flow = base_flows.get(BaseNetworkScript.COMMAND_ID, flow)
	flow_epoch += 1
	if not mining_partial and enemies.size() >= BASE_FLOW_COMBAT_ENEMY_THRESHOLD:
		base_flow_rebuild_cooldown = BASE_FLOW_COMBAT_THROTTLE
	for nest: BroodNest in brood_nests:
		if nest.maturity >= 1.0 and not grid.spawn_cells.has(nest.cell):
			if grid.register_spawn_cell(nest.cell):
				call_deferred("_prune_unreachable_spawn_lanes")
	if not mining_partial:
		_rebuild_expedition_flows()
		for spider: Spider in enemies:
			if spider.is_brood_carrier and spider.carrier_target_cell.x >= 0:
				_flow_for_brood_target(spider.carrier_target_cell)
	if not mining_partial and (player_flow_stale or force_full):
		_refresh_player_flow()


func _player_flow_refresh_deferred() -> bool:
	if _primary_break_held() or mining_beam_valid:
		return true
	if not terrain_chunk_redraw_queue.is_empty():
		return true
	if terrain_flow_rebuild_cooldown > 0.0 or terrain_flow_dirty:
		return true
	if (_combat_frame_tick - _recent_mine_flow_tick) <= 45:
		return true
	return false


func _refresh_player_flow(extra_cells: Array = []) -> void:
	var current_player_cell: Vector2i = grid.world_to_cell(player_position)
	var allowed_cells: Array = [current_player_cell]
	allowed_cells.append_array(extra_cells)
	var player_regions: Dictionary = grid.expand_regions({grid.region_for_cell(current_player_cell): true}, 1)
	for cell_value: Variant in extra_cells:
		player_regions[grid.region_for_cell(cell_value)] = true
	player_regions = grid.cap_regions_near_cell(player_regions, current_player_cell, PLAYER_FLOW_REGION_CAP)
	player_flow.rebuild(grid, current_player_cell, player_regions)
	player_flow_region = grid.region_for_cell(current_player_cell)
	player_flow_cell = current_player_cell
	player_flow_stale = false
	flow_epoch += 1


func _rebuild_expedition_flows() -> void:
	explorer_flows.clear()
	explorer_targets.clear()
	# Inactive Frontier sites are intentional raid waypoints: mobs crossing the
	# realm toward them create flanking traffic before the player claims a base.
	for base_id: String in [BaseNetworkScript.WEST_ID, BaseNetworkScript.NORTH_ID, BaseNetworkScript.SOUTH_ID]:
		var target_cell := base_network.get_cell(base_id)
		if not grid.is_walkable(target_cell):
			continue
		var expedition_flow: FlowFieldScript = base_flows.get(base_id)
		if expedition_flow == null:
			continue
		explorer_targets.append(target_cell)
		explorer_flows.append(expedition_flow)


func _nearby_base_id() -> String:
	return base_network.nearest_interactable(player_position, grid.tile_size)


func _base_at_position(at_position: Vector2, distance: float) -> String:
	for base_id: String in base_network.active_ids(true):
		if at_position.distance_to(grid.cell_to_world(base_network.get_cell(base_id))) < distance:
			return base_id
	return ""


func _damage_base(base_id: String, amount: float) -> void:
	var outcome: String = base_network.damage(base_id, amount)
	core_health = float(base_network.get_base(BaseNetworkScript.COMMAND_ID).get("health", 0.0))
	if outcome == "disabled":
		var base_name := str(base_network.get_base(base_id).get("name", base_id))
		discovery_alert = "%s DISABLED // REACTIVATE FOR $70" % base_name
		discovery_alert_time = 4.5
		_rebuild_base_flows()
		_save_run()
		_check_network_defeat()


func _check_network_defeat() -> void:
	if base_network.has_operational_network():
		return
	_finish_run()


func _enemies_blocking_construction(base_id: String, radius: float = 80.0) -> bool:
	var center: Vector2 = grid.cell_to_world(base_network.get_cell(base_id))
	for spider in enemies:
		if spider.role == ROLE_BROODLING and not spider.counts_for_wave:
			continue
		if spider.position.distance_to(center) <= radius:
			return true
	return false


func _refresh_bases_under_attack_cache() -> void:
	if _cached_bases_under_attack_tick == _combat_frame_tick:
		return
	var count := 0
	var attacked: Dictionary = {}
	for base_id: String in base_network.active_ids():
		if _enemies_near_base(base_id, 96.0):
			count += 1
			attacked[base_id] = true
	_cached_bases_under_attack = {"count": count, "bases": attacked}
	_cached_bases_under_attack_tick = _combat_frame_tick


func _base_is_under_attack(base_id: String) -> bool:
	_refresh_bases_under_attack_cache()
	return bool(_cached_bases_under_attack["bases"].get(base_id, false))


func _bases_under_attack_count() -> int:
	_refresh_bases_under_attack_cache()
	return int(_cached_bases_under_attack.get("count", 0))


func _enemies_near_base(base_id: String, radius: float = 112.0) -> bool:
	var center: Vector2 = grid.cell_to_world(base_network.get_cell(base_id))
	for spider in enemies:
		if spider.position.distance_to(center) <= radius:
			return true
	return false


func _interact_with_base(base_id: String) -> void:
	var status: String = base_network.get_status(base_id)
	if status == BaseNetworkScript.STATUS_ACTIVE:
		current_base_id = base_id
		_open_core_base()
	elif status == BaseNetworkScript.STATUS_DISABLED:
		current_base_id = base_id
		if _spend_scrap(70) and base_network.reactivate(base_id):
			discovery_alert = "%s REACTIVATED" % str(base_network.get_base(base_id)["name"])
			discovery_alert_time = 3.5
			_rebuild_base_flows()
			_save_run()
	elif status == BaseNetworkScript.STATUS_ACTIVATING:
		var remaining := ceili(float(base_network.get_base(base_id).get("activation_remaining", 0.0)))
		discovery_alert = "%s ACTIVATING // DEFEND %02d SEC" % [str(base_network.get_base(base_id)["name"]), remaining]
		discovery_alert_time = 3.0
	elif status == BaseNetworkScript.STATUS_SITE:
		var can_build: bool = base_network.can_construct_open_world(base_id, explored_sectors.size(), _enemies_blocking_construction(base_id))
		if not can_build:
			var missing: PackedStringArray = []
			if explored_sectors.size() < 4:
				missing.append("%d MORE SECTORS" % (4 - explored_sectors.size()))
			if not bool(base_network.get_base(base_id).get("guardian_cleared", false)):
				missing.append("GUARDIAN")
			if _enemies_blocking_construction(base_id):
				missing.append("CLEAR SITE")
			if not base_network.activation_base_id.is_empty() and base_network.activation_base_id != base_id:
				missing.append("OTHER SITE ACTIVATING")
			discovery_alert = "SITE LOCKED // " + " + ".join(missing)
			discovery_alert_time = 4.0
			return
		if scrap < BaseNetworkScript.FRONTIER_COST:
			discovery_alert = "FRONTIER CORE REQUIRES $1000 // NEED $%d MORE" % (BaseNetworkScript.FRONTIER_COST - scrap)
			discovery_alert_time = 4.0
			return
		if _spend_scrap(BaseNetworkScript.FRONTIER_COST) and base_network.begin_activation(base_id):
			activation_spawn_cooldown = 0.25
			activation_spawn_sequence = 0
			discovery_alert = "%s DEPLOYING // DEFEND 50 SECONDS" % str(base_network.get_base(base_id)["name"])
			discovery_alert_time = 4.0
			_rebuild_base_flows()
			_save_run()


func _update_frontier_activation(delta: float) -> void:
	var activation_id: String = base_network.activation_base_id
	if activation_id.is_empty():
		return
	var completed: String = base_network.tick_activation(delta)
	if encounter_load_grace <= 0.0:
		activation_spawn_cooldown -= delta
		if activation_spawn_cooldown <= 0.0:
			var activation_cap := mini(_active_enemy_cap(), hive_awareness.regional_population_cap())
			if enemies.size() < activation_cap:
				var site_cell: Vector2i = base_network.get_cell(activation_id)
				var spawn_cell: Vector2i = _activation_spawn_cell(site_cell, activation_spawn_sequence)
				if _spawn_broodling(spawn_cell, activation_spawn_sequence, false):
					enemies.back().target_base_id = activation_id
					activation_spawn_sequence += 1
				var difficulty_rate := float(difficulty["spawn_interval"])
				activation_spawn_cooldown = maxf(0.45, difficulty_rate * 3.5)
	if not completed.is_empty():
		grid.ensure_regions_around(base_network.get_cell(completed), 1)
		hive_awareness.register_activity("settlement", grid.region_for_cell(base_network.get_cell(completed)))
		discovery_alert = "%s ONLINE // REGIONAL SHOP AVAILABLE" % str(base_network.get_base(completed)["name"])
		discovery_alert_time = 5.0
		score += 2500
		_rebuild_base_flows()
		_save_run()


func _activation_spawn_cell(site_cell: Vector2i, sequence: int) -> Vector2i:
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	var salt := RealmVisualStyleScript.stable_cell_hash(run_seed, site_cell, sequence + 1709)
	# Probe a deterministic annulus instead of scanning and sorting 2,025 cells
	# every time an activating settlement asks for one attacker.
	for attempt in range(48):
		var angle_index := posmod(salt + attempt * 17, 64)
		var angle := float(angle_index) * TAU / 64.0
		var radius := 14 + posmod(salt / 67 + attempt * 5, 9)
		var candidate := site_cell + Vector2i(roundi(cos(angle) * radius), roundi(sin(angle) * radius))
		if candidate.distance_to(player_cell) < 11.0:
			continue
		if _spider_spawn_allowed_cell(candidate):
			return candidate
	var fallback := _prepared_spider_spawn_cell_near(site_cell, 14, 22, salt)
	if fallback.x >= 0 and fallback.distance_to(player_cell) >= 11.0:
		return fallback
	return site_cell if _spider_spawn_allowed_cell(site_cell) else Vector2i(-1, -1)


func _build_core_base_panel() -> void:
	core_base_panel = ColorRect.new()
	core_base_panel.position = Vector2(8, 0)
	core_base_panel.size = CORE_PANEL_SIZE
	core_base_panel.color = Color(0.003, 0.008, 0.011, 0.96)
	core_base_panel.z_index = 108
	core_base_panel.visible = false
	overlay_root.add_child(core_base_panel)

	var terminal_frame := TextureRect.new()
	terminal_frame.name = "TerminalFrame"
	terminal_frame.texture = _load_png_texture(CORE_TERMINAL_FRAME_PATH)
	terminal_frame.position = Vector2.ZERO
	terminal_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	terminal_frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	terminal_frame.size = Vector2(624, 351)
	terminal_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	terminal_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core_base_panel.add_child(terminal_frame)
	terminal_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var top_accent := ColorRect.new()
	top_accent.position = Vector2.ZERO
	top_accent.size = Vector2.ZERO
	top_accent.color = Color.TRANSPARENT
	top_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core_base_panel.add_child(top_accent)

	var header_rule := ColorRect.new()
	header_rule.position = Vector2.ZERO
	header_rule.size = Vector2.ZERO
	header_rule.color = Color("284852")
	header_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core_base_panel.add_child(header_rule)

	core_base_title = Label.new()
	core_base_title.text = "CORE BASE // ENGINEERING & ARMORY"
	core_base_title.position = Vector2(148, 24)
	core_base_title.size = Vector2(218, 24)
	core_base_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	core_base_title.add_theme_color_override("font_color", Color("8eeaff"))
	core_base_panel.add_child(core_base_title)

	core_base_status = Label.new()
	core_base_status.position = Vector2(148, 48)
	core_base_status.size = Vector2(218, 14)
	core_base_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	core_base_status.add_theme_color_override("font_color", Color("9eb2b8"))
	core_base_panel.add_child(core_base_status)

	var xp_card := ColorRect.new()
	xp_card.position = Vector2(148, 306)
	xp_card.size = Vector2(220, 18)
	xp_card.color = Color(0.01, 0.025, 0.03, 0.78)
	xp_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core_base_panel.add_child(xp_card)
	core_xp_track = ColorRect.new()
	core_xp_track.position = Vector2(8, 11)
	core_xp_track.size = Vector2(204, 4)
	core_xp_track.color = Color("13242c")
	core_xp_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_card.add_child(core_xp_track)
	core_xp_fill = ColorRect.new()
	core_xp_fill.position = core_xp_track.position + Vector2(1, 1)
	core_xp_fill.size = Vector2(0, 2)
	core_xp_fill.color = Color("55dff5")
	core_xp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_card.add_child(core_xp_fill)
	core_xp_label = Label.new()
	core_xp_label.position = Vector2(8, 0)
	core_xp_label.size = Vector2(204, 11)
	core_xp_label.add_theme_color_override("font_color", Color("9adcf0"))
	core_xp_label.clip_text = true
	core_xp_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	xp_card.add_child(core_xp_label)

	var scrap_card := ColorRect.new()
	scrap_card.position = Vector2(382, 24)
	scrap_card.size = Vector2(168, 48)
	scrap_card.color = Color(0.01, 0.02, 0.025, 0.5)
	scrap_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core_base_panel.add_child(scrap_card)
	core_base_scrap_label = Label.new()
	core_base_scrap_label.position = Vector2(10, 5)
	core_base_scrap_label.size = Vector2(148, 38)
	core_base_scrap_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	core_base_scrap_label.add_theme_color_override("font_color", Color("70e1a4"))
	scrap_card.add_child(core_base_scrap_label)

	var network_card := ColorRect.new()
	network_card.position = Vector2(148, 63)
	network_card.size = Vector2(218, 16)
	network_card.color = Color(0.01, 0.02, 0.025, 0.5)
	network_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core_base_panel.add_child(network_card)
	core_base_network_label = Label.new()
	core_base_network_label.position = Vector2(4, 1)
	core_base_network_label.size = Vector2(210, 14)
	core_base_network_label.clip_text = true
	core_base_network_label.add_theme_color_override("font_color", Color("a7eefa"))
	network_card.add_child(core_base_network_label)

	core_department_buttons.clear()
	for department_index in range(SHOP_DEPARTMENT_ORDER.size()):
		var department_id := SHOP_DEPARTMENT_ORDER[department_index]
		var department_button := _overlay_button(str(SHOP_DEPARTMENT_LABELS[department_id]))
		department_button.position = Vector2(68, 96 + department_index * 37)
		department_button.size = Vector2(52, 34)
		department_button.custom_minimum_size = Vector2(52, 34)
		department_button.icon = _core_tab_icon(str(SHOP_DEPARTMENTS[department_id][0]))
		department_button.expand_icon = true
		department_button.pressed.connect(_set_core_department.bind(department_id))
		core_base_panel.add_child(department_button)
		core_department_buttons[department_id] = department_button

	var subtabs := HBoxContainer.new()
	subtabs.name = "Subtabs"
	subtabs.position = Vector2(148, 94)
	subtabs.size = Vector2(220, 24)
	subtabs.add_theme_constant_override("separation", 4)
	core_base_panel.add_child(subtabs)
	for page_id: String in SHOP_PAGES:
		var tab := _overlay_button(str(SHOP_PAGE_LABELS.get(page_id, page_id.to_upper())))
		tab.custom_minimum_size = Vector2(68, 24)
		tab.icon = _core_tab_icon(page_id)
		tab.expand_icon = true
		tab.pressed.connect(_set_core_menu_page.bind(page_id))
		subtabs.add_child(tab)
		core_tab_buttons[page_id] = tab

	var services_scroll := ScrollContainer.new()
	services_scroll.name = "ServiceScroll"
	services_scroll.position = Vector2(148, 122)
	services_scroll.size = Vector2(220, 176)
	services_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	core_base_panel.add_child(services_scroll)

	var buttons := VBoxContainer.new()
	buttons.name = "Services"
	buttons.custom_minimum_size = Vector2(204, 0)
	buttons.add_theme_constant_override("separation", 3)
	services_scroll.add_child(buttons)

	armory_button = _overlay_button("")
	armory_button.custom_minimum_size = Vector2(204, 30)
	armory_button.pressed.connect(func() -> void: _execute_core_action(0))
	buttons.add_child(armory_button)
	research_button = _overlay_button("")
	research_button.custom_minimum_size = Vector2(204, 30)
	research_button.pressed.connect(func() -> void: _execute_core_action(1))
	buttons.add_child(research_button)
	turret_button = _overlay_button("")
	turret_button.custom_minimum_size = Vector2(204, 30)
	turret_button.pressed.connect(func() -> void: _execute_core_action(2))
	buttons.add_child(turret_button)
	repair_button = _overlay_button("")
	repair_button.custom_minimum_size = Vector2(204, 30)
	repair_button.pressed.connect(func() -> void: _execute_core_action(3))
	buttons.add_child(repair_button)
	restock_button = _overlay_button("FIELD RESTOCK // $25")
	restock_button.custom_minimum_size = Vector2(204, 30)
	restock_button.pressed.connect(func() -> void: _execute_core_action(4))
	buttons.add_child(restock_button)
	base_upgrade_button = _overlay_button("")
	base_upgrade_button.custom_minimum_size = Vector2(204, 30)
	base_upgrade_button.pressed.connect(func() -> void: _execute_core_action(5))
	buttons.add_child(base_upgrade_button)
	material_sale_button = _overlay_button("")
	material_sale_button.custom_minimum_size = Vector2(204, 30)
	material_sale_button.pressed.connect(func() -> void: _execute_core_action(6))
	buttons.add_child(material_sale_button)
	extra_action_button = _overlay_button("")
	extra_action_button.custom_minimum_size = Vector2(204, 30)
	extra_action_button.pressed.connect(func() -> void: _execute_core_action(7))
	buttons.add_child(extra_action_button)
	extra_action_button2 = _overlay_button("")
	extra_action_button2.custom_minimum_size = Vector2(204, 30)
	extra_action_button2.pressed.connect(func() -> void: _execute_core_action(8))
	buttons.add_child(extra_action_button2)
	extra_action_button3 = _overlay_button("")
	extra_action_button3.custom_minimum_size = Vector2(204, 30)
	extra_action_button3.pressed.connect(func() -> void: _execute_core_action(9))
	buttons.add_child(extra_action_button3)
	core_service_buttons = [armory_button, research_button, turret_button, repair_button, restock_button, base_upgrade_button, material_sale_button, extra_action_button, extra_action_button2, extra_action_button3]
	for service_index in range(core_service_buttons.size()):
		var service_button: Button = core_service_buttons[service_index]
		service_button.add_theme_constant_override("icon_max_width", 17)
		service_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		service_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		service_button.clip_text = true
		service_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		service_button.focus_entered.connect(_show_core_action_detail.bind(service_index))
		service_button.mouse_entered.connect(_show_core_action_detail.bind(service_index))

	var detail_card := ColorRect.new()
	detail_card.position = Vector2(381, 94)
	detail_card.size = Vector2(172, 153)
	detail_card.color = Color.TRANSPARENT
	detail_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core_base_panel.add_child(detail_card)
	var detail_accent := ColorRect.new()
	detail_accent.size = Vector2.ZERO
	detail_accent.color = Color.TRANSPARENT
	detail_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_card.add_child(detail_accent)
	core_detail_icon = TextureRect.new()
	core_detail_icon.position = Vector2(48, 8)
	core_detail_icon.size = Vector2(76, 62)
	core_detail_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	core_detail_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	core_detail_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_card.add_child(core_detail_icon)
	core_detail_title = Label.new()
	core_detail_title.position = Vector2(8, 72)
	core_detail_title.size = Vector2(156, 18)
	core_detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	core_detail_title.add_theme_color_override("font_color", Color("8eeaff"))
	core_detail_title.clip_text = true
	core_detail_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	detail_card.add_child(core_detail_title)
	var detail_caption := Label.new()
	detail_caption.text = ""
	detail_caption.position = Vector2.ZERO
	detail_caption.size = Vector2.ZERO
	detail_caption.add_theme_color_override("font_color", Color("668d96"))
	detail_card.add_child(detail_caption)
	var detail_rule := ColorRect.new()
	detail_rule.position = Vector2(8, 94)
	detail_rule.size = Vector2(156, 1)
	detail_rule.color = Color("234550")
	detail_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_card.add_child(detail_rule)
	core_detail_body = Label.new()
	core_detail_body.position = Vector2(8, 98)
	core_detail_body.size = Vector2(156, 34)
	core_detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	core_detail_body.add_theme_color_override("font_color", Color("c8d8dc"))
	core_detail_body.clip_text = true
	core_detail_body.max_lines_visible = 3
	core_detail_body.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	detail_card.add_child(core_detail_body)
	var state_backdrop := ColorRect.new()
	state_backdrop.position = Vector2(8, 134)
	state_backdrop.size = Vector2(156, 17)
	state_backdrop.color = Color("07191f")
	state_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_card.add_child(state_backdrop)
	core_detail_state = Label.new()
	core_detail_state.position = Vector2(12, 136)
	core_detail_state.size = Vector2(148, 13)
	core_detail_state.clip_text = true
	core_detail_state.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	detail_card.add_child(core_detail_state)

	core_purchase_cost = Label.new()
	core_purchase_cost.position = Vector2(385, 254)
	core_purchase_cost.size = Vector2(46, 28)
	core_purchase_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	core_purchase_cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	core_purchase_cost.add_theme_font_size_override("font_size", 8)
	core_purchase_cost.add_theme_color_override("font_color", Color("f0c96d"))
	core_base_panel.add_child(core_purchase_cost)

	core_purchase_button = _overlay_button("PURCHASE")
	core_purchase_button.position = Vector2(435, 253)
	core_purchase_button.size = Vector2(112, 28)
	core_purchase_button.custom_minimum_size = Vector2(112, 28)
	core_purchase_button.add_theme_color_override("font_color", Color("ffe0a0"))
	core_purchase_button.add_theme_color_override("font_hover_color", Color("fff1c9"))
	core_purchase_button.add_theme_stylebox_override("normal", _button_style(Color("35230f"), Color("d0943f"), 1))
	core_purchase_button.add_theme_stylebox_override("hover", _button_style(Color("51351a"), Color("f0bd66"), 1))
	core_purchase_button.pressed.connect(func() -> void: _execute_core_action(core_selected_action_slot))
	core_base_panel.add_child(core_purchase_button)

	var navigation_hint := Label.new()
	navigation_hint.text = "Q/E DEPARTMENT  ·  ESC CLOSE"
	navigation_hint.position = Vector2(385, 286)
	navigation_hint.size = Vector2(164, 16)
	navigation_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	navigation_hint.add_theme_color_override("font_color", Color("81979d"))
	core_base_panel.add_child(navigation_hint)

	var close := _overlay_button("CLOSE")
	close.position = Vector2(435, 306)
	close.size = Vector2(112, 18)
	close.custom_minimum_size = Vector2(112, 18)
	close.alignment = HORIZONTAL_ALIGNMENT_LEFT
	close.pressed.connect(_close_core_base)
	core_base_panel.add_child(close)
	_apply_interface_typography()


func _build_foundry_panel() -> void:
	var compact_interface := DisplaySettingsScript.ui_density() == "COMPACT"
	foundry_panel = ColorRect.new()
	foundry_panel.position = Vector2(56, 18)
	foundry_panel.size = Vector2(528, 324)
	foundry_panel.color = Color(0.015, 0.025, 0.026, 0.985)
	foundry_panel.z_index = 109
	foundry_panel.visible = false
	overlay_root.add_child(foundry_panel)

	var top_accent := ColorRect.new()
	top_accent.size = Vector2(528, 4)
	top_accent.color = Color("e99845")
	top_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foundry_panel.add_child(top_accent)

	foundry_title = Label.new()
	foundry_title.position = Vector2(20, 12)
	foundry_title.size = Vector2(488, 25)
	foundry_title.add_theme_font_size_override("font_size", 13 if compact_interface else 15)
	foundry_title.add_theme_color_override("font_color", Color("ffc16d"))
	foundry_panel.add_child(foundry_title)

	foundry_status = Label.new()
	foundry_status.position = Vector2(20, 39)
	foundry_status.size = Vector2(488, 18)
	foundry_status.add_theme_font_size_override("font_size", 8 if compact_interface else 9)
	foundry_status.add_theme_color_override("font_color", Color("b8c9c9"))
	foundry_panel.add_child(foundry_status)

	var production_card := ColorRect.new()
	production_card.position = Vector2(20, 66)
	production_card.size = Vector2(488, 70)
	production_card.color = Color("10272a")
	foundry_panel.add_child(production_card)
	foundry_production_label = Label.new()
	foundry_production_label.position = Vector2(12, 5)
	foundry_production_label.size = Vector2(464, 14)
	foundry_production_label.add_theme_font_size_override("font_size", 8 if compact_interface else 9)
	foundry_production_label.clip_text = true
	foundry_production_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	foundry_production_label.add_theme_color_override("font_color", Color("ffcf87"))
	production_card.add_child(foundry_production_label)
	var flow_caption := Label.new()
	flow_caption.text = "INPUT"
	flow_caption.position = Vector2(12, 21)
	flow_caption.size = Vector2(66, 10)
	flow_caption.add_theme_font_size_override("font_size", 6)
	flow_caption.add_theme_color_override("font_color", Color("76989a"))
	production_card.add_child(flow_caption)
	foundry_recipe_input_icons.clear()
	foundry_recipe_input_counts.clear()
	for input_index in range(2):
		var input_frame := ColorRect.new()
		input_frame.position = Vector2(12 + input_index * 34, 31)
		input_frame.size = Vector2(30, 22)
		input_frame.color = Color("08171c")
		production_card.add_child(input_frame)
		var input_icon := TextureRect.new()
		input_icon.position = Vector2(3, 2)
		input_icon.size = Vector2(16, 16)
		input_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		input_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		input_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		input_frame.add_child(input_icon)
		foundry_recipe_input_icons.append(input_icon)
		var input_count := Label.new()
		input_count.position = Vector2(19, 7)
		input_count.size = Vector2(10, 10)
		input_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		input_count.add_theme_font_size_override("font_size", 6)
		input_count.add_theme_color_override("font_color", Color("d5eceb"))
		input_frame.add_child(input_count)
		foundry_recipe_input_counts.append(input_count)
	var input_arrow := Label.new()
	input_arrow.text = ">"
	input_arrow.position = Vector2(84, 34)
	input_arrow.size = Vector2(12, 16)
	input_arrow.add_theme_font_size_override("font_size", 11)
	input_arrow.add_theme_color_override("font_color", Color("f2a65a"))
	production_card.add_child(input_arrow)
	foundry_machine_icon = TextureRect.new()
	foundry_machine_icon.texture = shop_icons.get("foundry_furnace")
	foundry_machine_icon.position = Vector2(102, 26)
	foundry_machine_icon.size = Vector2(30, 30)
	foundry_machine_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	foundry_machine_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	foundry_machine_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	production_card.add_child(foundry_machine_icon)
	var output_arrow := Label.new()
	output_arrow.text = ">"
	output_arrow.position = Vector2(139, 34)
	output_arrow.size = Vector2(12, 16)
	output_arrow.add_theme_font_size_override("font_size", 11)
	output_arrow.add_theme_color_override("font_color", Color("f2a65a"))
	production_card.add_child(output_arrow)
	var output_frame := ColorRect.new()
	output_frame.position = Vector2(157, 31)
	output_frame.size = Vector2(30, 22)
	output_frame.color = Color("172019")
	production_card.add_child(output_frame)
	foundry_recipe_output_icon = TextureRect.new()
	foundry_recipe_output_icon.position = Vector2(3, 2)
	foundry_recipe_output_icon.size = Vector2(16, 16)
	foundry_recipe_output_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	foundry_recipe_output_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	foundry_recipe_output_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	output_frame.add_child(foundry_recipe_output_icon)
	foundry_recipe_output_count = Label.new()
	foundry_recipe_output_count.position = Vector2(19, 7)
	foundry_recipe_output_count.size = Vector2(10, 10)
	foundry_recipe_output_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	foundry_recipe_output_count.add_theme_font_size_override("font_size", 6)
	foundry_recipe_output_count.add_theme_color_override("font_color", Color("9af0b3"))
	output_frame.add_child(foundry_recipe_output_count)
	var buffer_caption := Label.new()
	buffer_caption.text = "BUFFER"
	buffer_caption.position = Vector2(199, 25)
	buffer_caption.size = Vector2(70, 10)
	buffer_caption.add_theme_font_size_override("font_size", 6)
	buffer_caption.add_theme_color_override("font_color", Color("76989a"))
	production_card.add_child(buffer_caption)
	var progress_track := ColorRect.new()
	progress_track.position = Vector2(199, 40)
	progress_track.size = Vector2(277, 8)
	progress_track.color = Color("251b15")
	production_card.add_child(progress_track)
	foundry_progress_bar = ColorRect.new()
	foundry_progress_bar.size = Vector2(0, 8)
	foundry_progress_bar.color = Color("f29b42")
	progress_track.add_child(foundry_progress_bar)

	var actions_card := ColorRect.new()
	actions_card.position = Vector2(20, 146)
	actions_card.size = Vector2(238, 166)
	actions_card.color = Color("0b1d20")
	foundry_panel.add_child(actions_card)
	foundry_action_buttons.clear()
	for action_index in range(6):
		var action_button := _overlay_button("")
		action_button.position = Vector2(8, 6 + action_index * 26)
		action_button.size = Vector2(222, 23)
		action_button.custom_minimum_size = Vector2(222, 23)
		action_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		action_button.add_theme_font_size_override("font_size", 7 if compact_interface else 8)
		action_button.icon = _foundry_action_icon(action_index)
		action_button.expand_icon = true
		action_button.add_theme_constant_override("icon_max_width", 16)
		action_button.clip_text = true
		action_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		action_button.pressed.connect(_execute_foundry_action.bind(action_index))
		actions_card.add_child(action_button)
		foundry_action_buttons.append(action_button)

	var detail_card := ColorRect.new()
	detail_card.position = Vector2(270, 146)
	detail_card.size = Vector2(238, 166)
	detail_card.color = Color("122327")
	foundry_panel.add_child(detail_card)
	foundry_inventory_label = Label.new()
	foundry_inventory_label.position = Vector2(10, 8)
	foundry_inventory_label.size = Vector2(218, 16)
	foundry_inventory_label.add_theme_font_size_override("font_size", 8)
	foundry_inventory_label.add_theme_color_override("font_color", Color("8de6c0"))
	detail_card.add_child(foundry_inventory_label)
	var buffer_rule := ColorRect.new()
	buffer_rule.position = Vector2(10, 27)
	buffer_rule.size = Vector2(218, 1)
	buffer_rule.color = Color("294850")
	buffer_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_card.add_child(buffer_rule)
	foundry_buffer_icons.clear()
	foundry_buffer_counts.clear()
	for buffer_index in range(3):
		var buffer_slot := ColorRect.new()
		buffer_slot.position = Vector2(10 + buffer_index * 36, 36)
		buffer_slot.size = Vector2(32, 28)
		buffer_slot.color = Color("08171c")
		detail_card.add_child(buffer_slot)
		var buffer_icon := TextureRect.new()
		buffer_icon.position = Vector2(5, 3)
		buffer_icon.size = Vector2(18, 18)
		buffer_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		buffer_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		buffer_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		buffer_slot.add_child(buffer_icon)
		foundry_buffer_icons.append(buffer_icon)
		var buffer_count := Label.new()
		buffer_count.position = Vector2(19, 15)
		buffer_count.size = Vector2(11, 10)
		buffer_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		buffer_count.add_theme_font_size_override("font_size", 6)
		buffer_count.add_theme_color_override("font_color", Color("9af0b3"))
		buffer_slot.add_child(buffer_count)
		foundry_buffer_counts.append(buffer_count)
	foundry_detail_label = Label.new()
	foundry_detail_label.position = Vector2(10, 74)
	foundry_detail_label.size = Vector2(218, 52)
	foundry_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	foundry_detail_label.add_theme_font_size_override("font_size", 7 if compact_interface else 8)
	foundry_detail_label.add_theme_color_override("font_color", Color("c2d2d2"))
	foundry_detail_label.clip_text = true
	foundry_detail_label.max_lines_visible = 4
	foundry_detail_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	detail_card.add_child(foundry_detail_label)

	var close := _overlay_button("CLOSE FOUNDRY  //  F / B")
	close.position = Vector2(20, 290)
	close.size = Vector2(488, 24)
	close.custom_minimum_size = Vector2(488, 24)
	close.alignment = HORIZONTAL_ALIGNMENT_LEFT
	close.add_theme_font_size_override("font_size", 8 if compact_interface else 9)
	close.pressed.connect(_close_foundry)
	foundry_panel.add_child(close)
	_apply_interface_typography()


func _open_foundry() -> void:
	_open_foundry_at(_nearby_foundry())


func _open_foundry_at(structure_index: int) -> bool:
	if structure_index < 0 or structure_index >= structures.size():
		discovery_alert = "NO FOUNDRY IN RANGE"
		discovery_alert_time = 2.5
		return false
	var structure: Structure = structures[structure_index]
	if structure.kind != BUILD_FOUNDRY or structure.health <= 0.0:
		return false
	var foundry_center := _foundry_center(structure)
	if player_position.distance_to(foundry_center) > 52.0:
		discovery_alert = "MOVE CLOSER TO USE FOUNDRY"
		discovery_alert_time = 2.5
		return false
	active_foundry_index = structure_index
	using_foundry = true
	using_core_base = false
	current_base_id = structure.base_id if not structure.base_id.is_empty() else BaseNetworkScript.COMMAND_ID
	build_mode = false
	foundry_action_message = ""
	foundry_ui_refresh_elapsed = 0.0
	if _foundry_powered(structure_index):
		var loaded := FoundryUnitScript.load_fuel_from_backpack(structure, material_economy)
		if loaded > 0:
			foundry_action_message = "COAL LOADED INTO FUEL BUFFER // %d STORED" % FoundryUnitScript.fuel_remaining(structure)
	foundry_panel.visible = true
	core_base_panel.visible = false
	_refresh_foundry_panel()
	_focus_first_foundry_action()
	return true


func _close_foundry() -> void:
	using_foundry = false
	active_foundry_index = -1
	foundry_panel.visible = false


func _focus_first_foundry_action() -> void:
	for button: Button in foundry_action_buttons:
		if not button.disabled:
			button.grab_focus()
			return


func _execute_foundry_action(action_index: int) -> void:
	match action_index:
		0:
			_refine_next_available()
		1:
			_prepare_lantern_upgrade()
		2:
			_collect_foundry_output()
		3:
			_upgrade_active_foundry()
		4:
			_teleport_sell_foundry_output()
		5:
			var foundry := _active_foundry()
			var pack_coal := int(material_economy.raw.get(MaterialEconomyScript.COAL, 0))
			if foundry != null and pack_coal > 0 and FoundryUnitScript.fuel_space(foundry) > 0:
				_load_foundry_fuel()
			else:
				_purchase_foundry_fuel(true)
	_refresh_foundry_panel()
	_repair_foundry_focus(action_index)


func _lantern_upgrade_target_index() -> int:
	return _structure_index_at_cell(lantern_upgrade_target_cell, BUILD_TORCH)


func _next_lantern_upgrade_index() -> int:
	var prepared_index := _lantern_upgrade_target_index()
	if prepared_index >= 0:
		return prepared_index
	var best_index := -1
	var best_level := 99
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind != BUILD_TORCH or structure.level >= TORCH_DURABILITY.size() - 1:
			continue
		if structure.level < best_level:
			best_level = structure.level
			best_index = structure_index
	return best_index


func _prepare_lantern_upgrade() -> void:
	var torch_index := _next_lantern_upgrade_index()
	if torch_index < 0:
		foundry_action_message = "NO ELIGIBLE TORCH // DEPLOY OR UPGRADE A WARD FIRST"
		return
	var torch: Structure = structures[torch_index]
	if torch.cell == lantern_upgrade_target_cell:
		foundry_action_message = "CALIBRATION READY // TRAVEL TO GRID %02d:%02d" % [torch.cell.x, torch.cell.y]
		return
	var requirement_index := clampi(torch.level, 1, TORCH_LANTERN_REQUIREMENTS.size() - 1)
	var cost: int = TORCH_LANTERN_COSTS[requirement_index]
	var requirements: Dictionary = TORCH_LANTERN_REQUIREMENTS[requirement_index]
	if not _spend_purchase(cost, requirements):
		foundry_action_message = "CALIBRATION BLOCKED // %s" % _purchase_state(cost, requirements)
		return
	lantern_upgrade_target_cell = torch.cell
	foundry_action_message = "CALIBRATION PREPARED // GRID %02d:%02d // APPLY AT TORCH" % [torch.cell.x, torch.cell.y]
	_save_run()


func _repair_foundry_focus(preferred_index: int) -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused in foundry_action_buttons and not (focused as Button).disabled:
		return
	for offset in range(foundry_action_buttons.size()):
		var index := posmod(preferred_index + offset, foundry_action_buttons.size())
		var button: Button = foundry_action_buttons[index]
		if not button.disabled:
			button.grab_focus()
			return


func _collect_foundry_output() -> void:
	var foundry := _active_foundry()
	if foundry == null:
		foundry_action_message = "FOUNDRY OFFLINE"
		return
	var stored := FoundryUnitScript.output_total(foundry)
	if stored <= 0:
		foundry_action_message = "OUTPUT BUFFER EMPTY"
		return
	var free_capacity := _backpack_free()
	if free_capacity <= 0:
		foundry_action_message = "BACKPACK FULL // OUTPUT REMAINS SAFE IN FOUNDRY"
		return
	var collected := FoundryUnitScript.collect_output(foundry, material_economy, free_capacity)
	var collected_total := 0
	for amount: Variant in collected.values():
		collected_total += int(amount)
	foundry_action_message = "COLLECTED %d UNIT%s // %d REMAIN IN BUFFER" % [collected_total, "" if collected_total == 1 else "S", FoundryUnitScript.output_total(foundry)]
	_save_run()


func _teleport_sell_foundry_output() -> void:
	var foundry := _active_foundry()
	if foundry == null:
		foundry_action_message = "FOUNDRY OFFLINE"
		return
	if foundry.level < 2:
		foundry_action_message = "TELEPORTATION MODULE REQUIRES FOUNDRY MK2"
		return
	var payout := FoundryUnitScript.sell_output(foundry)
	if payout <= 0:
		foundry_action_message = "OUTPUT BUFFER EMPTY // NOTHING TO TELEPORT"
		return
	_apply_scrap_delta(payout, "foundry_teleport_sell")
	foundry_action_message = "OUTPUT TELEPORTED TO MARKET // +$%d // CARRIED PARTS RETAINED" % payout
	_save_run()


func _upgrade_active_foundry() -> void:
	var foundry := _active_foundry()
	if foundry == null or active_foundry_index < 0:
		foundry_action_message = "FOUNDRY OFFLINE"
		return
	if foundry.level >= material_economy.foundry_tier:
		foundry_action_message = "UNLOCK MK%d AT COMMAND CORE FIRST" % [foundry.level + 1]
		return
	if foundry.level >= 3:
		foundry_action_message = "FOUNDRY MK3 // MAXIMUM"
		return
	var upgrade_cost := material_economy.foundry_upgrade_cost(foundry.level)
	if scrap < upgrade_cost:
		foundry_action_message = "NEED $%d FOR MK%d UPGRADE" % [upgrade_cost, foundry.level + 1]
		return
	_apply_scrap_delta(-upgrade_cost, "foundry_upgrade")
	FoundryUnitScript.upgrade(foundry, material_economy)
	foundry_action_message = "FOUNDRY MK%d ONLINE // HOLD %d // QUEUE %d" % [foundry.level, FoundryUnitScript.output_limit(foundry.level), FoundryUnitScript.queue_limit(foundry.level)]
	_save_run()


func _foundry_action_icon(action_index: int) -> Texture2D:
	match action_index:
		0:
			return shop_icons.get("copper_ore")
		1:
			return shop_icons.get("crystal_core")
		2:
			return shop_icons.get("backpack")
		3:
			return shop_icons.get("turret_chip")
		4:
			return shop_icons.get("bronze_ingot")
		5:
			return shop_icons.get("coal")
	return null


func _refresh_foundry_visual_flow() -> void:
	var foundry := _active_foundry()
	if foundry == null or not is_instance_valid(material_economy):
		return
	var recipe_id := FoundryUnitScript.active_recipe(foundry)
	if recipe_id.is_empty():
		recipe_id = material_economy.next_recipe(foundry.level)
	var requirements: Dictionary = material_economy.recipe_requirements(recipe_id)
	var requirement_ids: Array[String] = []
	for material_id: String in requirements.keys():
		requirement_ids.append(material_id)
	for input_index in range(foundry_recipe_input_icons.size()):
		var has_input := input_index < requirement_ids.size()
		var input_id := requirement_ids[input_index] if has_input else ""
		foundry_recipe_input_icons[input_index].texture = shop_icons.get(input_id) if has_input else null
		foundry_recipe_input_counts[input_index].text = "x%d" % int(requirements.get(input_id, 0)) if has_input else "-"
	var output_id := material_economy.recipe_output(recipe_id)
	foundry_recipe_output_icon.texture = shop_icons.get(output_id) if not output_id.is_empty() else null
	foundry_recipe_output_count.text = "x%d" % material_economy.recipe_output_amount(recipe_id, foundry.level) if not output_id.is_empty() else "-"
	if is_instance_valid(foundry_machine_icon):
		foundry_machine_icon.modulate = Color.WHITE if not FoundryUnitScript.active_recipe(foundry).is_empty() else Color(0.55, 0.62, 0.62, 0.72)
	var output: Dictionary = FoundryUnitScript.output_dict(foundry)
	var buffer_slot := 0
	for material_id: String in MaterialEconomyScript.REFINED_ORDER:
		var amount := int(output.get(material_id, 0))
		if amount <= 0:
			continue
		if buffer_slot >= foundry_buffer_icons.size():
			break
		foundry_buffer_icons[buffer_slot].texture = shop_icons.get(material_id)
		foundry_buffer_counts[buffer_slot].text = "x%d" % amount
		buffer_slot += 1
	for empty_index in range(buffer_slot, foundry_buffer_icons.size()):
		foundry_buffer_icons[empty_index].texture = null
		foundry_buffer_counts[empty_index].text = "-"


func _refresh_foundry_action_buttons() -> void:
	var foundry := _active_foundry()
	if foundry == null or not is_instance_valid(material_economy) or foundry_action_buttons.is_empty():
		return
	var online := _foundry_operational(active_foundry_index)
	var tier := foundry.level
	var stored := FoundryUnitScript.output_total(foundry)
	var output_cap := FoundryUnitScript.output_limit(tier)
	var queue_cap := FoundryUnitScript.queue_limit(tier)
	var next_raw := material_economy.next_recipe(tier)
	var next_label := "QUEUE NEXT // NO COMPLETE RECIPE"
	if not next_raw.is_empty():
		next_label = "QUEUE NEXT // %s > %s" % [_material_name(next_raw).to_upper(), _material_name(material_economy.recipe_output(next_raw)).to_upper()]
	foundry_action_buttons[0].text = next_label
	foundry_action_buttons[0].disabled = not online or next_raw.is_empty() or FoundryUnitScript.queue_full(foundry) or FoundryUnitScript.output_full(foundry) or not FoundryUnitScript.has_runtime_fuel(foundry, material_economy)
	var lantern_target_index := _next_lantern_upgrade_index()
	if lantern_target_index < 0:
		foundry_action_buttons[1].text = "LANTERN CALIBRATION // NO ELIGIBLE TORCH"
		foundry_action_buttons[1].disabled = true
	else:
		var lantern_torch: Structure = structures[lantern_target_index]
		if lantern_torch.cell == lantern_upgrade_target_cell:
			foundry_action_buttons[1].text = "LANTERN READY // GRID %02d:%02d" % [lantern_torch.cell.x, lantern_torch.cell.y]
			foundry_action_buttons[1].disabled = false
		else:
			var requirement_index := clampi(lantern_torch.level, 1, TORCH_LANTERN_REQUIREMENTS.size() - 1)
			var lantern_cost: int = TORCH_LANTERN_COSTS[requirement_index]
			var lantern_requirements: Dictionary = TORCH_LANTERN_REQUIREMENTS[requirement_index]
			foundry_action_buttons[1].text = "PREP LANTERN MK%d // $%d" % [lantern_torch.level + 1, lantern_cost]
			foundry_action_buttons[1].disabled = not online or _purchase_state(lantern_cost, lantern_requirements) != "READY"
	var collectable := mini(stored, _backpack_free())
	foundry_action_buttons[2].text = "COLLECT OUTPUT // %d FIT // %d/%d STORED" % [collectable, stored, output_cap]
	foundry_action_buttons[2].disabled = stored <= 0 or _backpack_free() <= 0
	if tier >= 3 or tier >= material_economy.foundry_tier:
		foundry_action_buttons[3].text = "FOUNDRY MK3 // MAXIMUM" if tier >= 3 else "UNLOCK MK%d AT COMMAND CORE" % [tier + 1]
		foundry_action_buttons[3].disabled = true
	else:
		var upgrade_cost := material_economy.foundry_upgrade_cost(tier)
		foundry_action_buttons[3].text = "UPGRADE MK%d > MK%d // $%d // HOLD %d" % [tier, tier + 1, upgrade_cost, FoundryUnitScript.output_limit(tier + 1)]
		foundry_action_buttons[3].disabled = not online or scrap < upgrade_cost
	if tier < 2:
		foundry_action_buttons[4].text = "TELEPORT SALE // REQUIRES MK2"
		foundry_action_buttons[4].disabled = true
	else:
		foundry_action_buttons[4].text = "TELEPORT SELL BUFFER // $%d" % FoundryUnitScript.output_sale_value(foundry)
		foundry_action_buttons[4].disabled = stored <= 0
	var fuel_room := _foundry_fuel_purchase_room(foundry)
	var fuel_bundle := mini(FOUNDRY_FUEL_BUNDLE, fuel_room)
	var pack_coal := int(material_economy.raw.get(MaterialEconomyScript.COAL, 0))
	var buffer_space := FoundryUnitScript.fuel_space(foundry)
	if pack_coal > 0 and buffer_space > 0 and _foundry_powered(active_foundry_index):
		var load_amount := mini(pack_coal, buffer_space)
		foundry_action_buttons[5].text = "[LOAD] COAL FUEL // %d TO BUFFER" % load_amount
		foundry_action_buttons[5].disabled = false
	elif fuel_room > 0:
		foundry_action_buttons[5].text = "[BUY] COAL FUEL +%d  //  $%d" % [fuel_bundle, FOUNDRY_FUEL_BUNDLE_COST]
		foundry_action_buttons[5].disabled = not _foundry_powered(active_foundry_index) or scrap < FOUNDRY_FUEL_BUNDLE_COST
	else:
		foundry_action_buttons[5].text = "[OWNED] COAL FUEL FULL"
		foundry_action_buttons[5].disabled = true
	foundry_inventory_label.text = "COAL %02d/%d BUF  //  PACK %02d  //  OUTPUT %02d/%d  //  $%04d  //  QUEUE %02d/%02d" % [FoundryUnitScript.fuel_remaining(foundry), FoundryUnitScript.fuel_capacity(tier), pack_coal, stored, output_cap, FoundryUnitScript.output_sale_value(foundry), FoundryUnitScript.queue_size(foundry), queue_cap]


func _refresh_foundry_panel() -> void:
	if not is_instance_valid(foundry_panel) or not is_instance_valid(material_economy):
		return
	var foundry := _active_foundry()
	if foundry == null:
		return
	var online := _foundry_operational(active_foundry_index)
	foundry_title.text = "INDUSTRIAL FOUNDRY  //  MK %d  //  GRID %02d:%02d" % [foundry.level, foundry.cell.x, foundry.cell.y]
	_refresh_foundry_live_progress()
	_refresh_foundry_visual_flow()
	_refresh_foundry_action_buttons()
	var lantern_detail := "NO TORCH CALIBRATION PENDING"
	var prepared_torch_index := _lantern_upgrade_target_index()
	if prepared_torch_index >= 0:
		var prepared_torch: Structure = structures[prepared_torch_index]
		lantern_detail = "LANTERN READY // GRID %02d:%02d // APPLY AT WARD" % [prepared_torch.cell.x, prepared_torch.cell.y]
	foundry_detail_label.text = "PACK SPACE  %03d FREE  //  COAL BUF %02d/%d  //  PACK %02d\n%s\n%s" % [_backpack_free(), FoundryUnitScript.fuel_remaining(foundry), FoundryUnitScript.fuel_capacity(foundry.level), int(material_economy.raw.get(MaterialEconomyScript.COAL, 0)), material_economy.short_refined_manifest(), lantern_detail]


func _refresh_foundry_live_progress() -> void:
	if not is_instance_valid(foundry_panel) or not is_instance_valid(material_economy):
		return
	var foundry := _active_foundry()
	if foundry == null:
		return
	var online := _foundry_operational(active_foundry_index)
	var powered := _foundry_powered(active_foundry_index)
	var queue_cap := FoundryUnitScript.queue_limit(foundry.level)
	var output_cap := FoundryUnitScript.output_limit(foundry.level)
	var default_status := "ONLINE  //  %.0f SEC  //  QUEUE %02d/%02d  //  HOLD %02d/%02d" % [FoundryUnitScript.batch_duration(foundry.level), FoundryUnitScript.queue_size(foundry), queue_cap, FoundryUnitScript.output_total(foundry), output_cap] if online else ("NO COAL FUEL  //  MINE OR CARRY COAL TO RUN" if powered else "OFFLINE  //  PRODUCTION PAUSED")
	if FoundryUnitScript.output_full(foundry) and online:
		default_status = "BUFFER FULL  //  COLLECT OR TELEPORT OUTPUT"
	var status_text := foundry_action_message if not foundry_action_message.is_empty() else default_status
	if foundry_status.text != status_text:
		foundry_status.text = status_text
	var status_color := Color("ef8068") if (not online or FoundryUnitScript.output_full(foundry)) else Color("8de6c0")
	if foundry_status.get_theme_color("font_color") != status_color:
		foundry_status.add_theme_color_override("font_color", status_color)
	var active_name := "IDLE // LOAD A COMPLETE RECIPE"
	var active_recipe_id := FoundryUnitScript.active_recipe(foundry)
	if not active_recipe_id.is_empty():
		active_name = "%s > %s  //  %04.1f SEC REMAINING" % [_material_name(active_recipe_id).to_upper(), _material_name(material_economy.recipe_output(active_recipe_id)).to_upper(), FoundryUnitScript.active_recipe_remaining(foundry)]
	if foundry_production_label.text != active_name:
		foundry_production_label.text = active_name
	foundry_progress_bar.size.x = 277.0 * FoundryUnitScript.active_progress(foundry)
	var progress_color := Color("f29b42") if online else Color("76604c")
	if foundry_progress_bar.color != progress_color:
		foundry_progress_bar.color = progress_color
	_refresh_foundry_action_buttons()


# Slot grid data: [material_key, display_name, icon_key, slot_type]
# slot_type: "raw", "refined", "ammo", "kit"
const BACKPACK_SLOT_DEFS: Array = [
	# RAW ORE row 1
	["copper_ore", "Cu", "copper_ore", "raw"],
	["silver_ore", "Ag", "silver_ore", "raw"],
	["gold_ore", "Au", "gold_ore", "raw"],
	["iron_ore", "Fe", "iron_ore", "raw"],
	["titanium_ore", "Ti", "titanium_ore", "raw"],
	["energy_crystal", "Cryst", "energy_crystal", "raw"],
	["rough_diamond", "Dia", "rough_diamond", "raw"],
	["granite", "Gran", "granite", "raw"],
	["basalt", "Bslt", "basalt", "raw"],
	["quartz", "Qtz", "quartz", "raw"],
	["sulfur", "Sulf", "sulfur", "raw"],
	["coal", "Coal", "coal", "raw"],
	# REFINED row
	["bronze_ingot", "Brz", "bronze_ingot", "refined"],
	["silver_ingot", "AgI", "silver_ingot", "refined"],
	["gold_ingot", "AuI", "gold_ingot", "refined"],
	["steel_plate", "Stl", "steel_plate", "refined"],
	["titanium_plate", "TiP", "titanium_plate", "refined"],
	["stone_block", "Stn", "stone_block", "refined"],
	["reinforced_block", "RnB", "reinforced_block", "refined"],
	["crystal_core", "CCo", "crystal_core", "refined"],
	["optic_core", "Opt", "optic_core", "refined"],
	["explosive_compound", "Exp", "explosive_compound", "refined"],
	["cut_diamond", "CDi", "cut_diamond", "refined"],
	# AMMO & SUPPLIES
	["pistol", "Pst", "pistol_ammo", "ammo"],
	["shotgun", "Shg", "shotgun_ammo", "ammo"],
	["smg", "SMG", "smg_mag", "ammo"],
	["railgun", "Rail", "rail_slug", "ammo"],
	# KITS
	["granite_barrier", "GBar", "granite_barrier", "kit"],
	["steel_barrier", "Stl", "steel_plate", "kit"],
	["reinforced_barrier", "RBar", "reinforced_barrier", "kit"],
	["blast_barrier", "BBar", "blast_barrier", "kit"],
	["land_mine", "Mine", "land_mine", "kit"],
	["rocket_turret", "Rkt", "rocket_turret", "kit"],
	["laser_turret", "Las", "laser_turret", "kit"],
]

func _make_slot(parent: Node, pos: Vector2, icon_key: String) -> Array:
	var frame := ColorRect.new()
	frame.position = pos
	frame.size = Vector2(46, 46)
	frame.color = Color("0a1f28")
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(frame)
	var border := ColorRect.new()
	border.size = Vector2(46, 46)
	border.color = Color(0, 0, 0, 0)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(border)
	var icon := TextureRect.new()
	icon.position = Vector2(5, 4)
	icon.size = Vector2(28, 28)
	icon.texture = shop_icons.get(icon_key)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(icon)
	var count_lbl := Label.new()
	count_lbl.position = Vector2(1, 34)
	count_lbl.size = Vector2(44, 11)
	count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_lbl.add_theme_font_size_override("font_size", 8)
	count_lbl.add_theme_color_override("font_color", Color("c8d8dc"))
	frame.add_child(count_lbl)
	return [frame, icon, count_lbl]


func _build_backpack_panel() -> void:
	backpack_panel = ColorRect.new()
	backpack_panel.position = Vector2(8, 6)
	backpack_panel.size = Vector2(624, 348)
	backpack_panel.color = Color(0.005, 0.018, 0.026, 0.985)
	backpack_panel.z_index = 112
	backpack_panel.visible = false
	backpack_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_root.add_child(backpack_panel)

	var top_accent := ColorRect.new()
	top_accent.size = Vector2(624, 3)
	top_accent.color = Color("55dff5")
	top_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backpack_panel.add_child(top_accent)

	var pack_icon := TextureRect.new()
	pack_icon.position = Vector2(16, 10)
	pack_icon.size = Vector2(32, 32)
	pack_icon.texture = shop_icons.get("backpack")
	pack_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pack_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pack_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backpack_panel.add_child(pack_icon)

	var title := Label.new()
	title.text = "FIELD BACKPACK"
	title.position = Vector2(58, 8)
	title.size = Vector2(400, 20)
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color("8eeaff"))
	backpack_panel.add_child(title)

	backpack_capacity_label = Label.new()
	backpack_capacity_label.position = Vector2(58, 27)
	backpack_capacity_label.size = Vector2(400, 14)
	backpack_capacity_label.add_theme_font_size_override("font_size", 8)
	backpack_capacity_label.add_theme_color_override("font_color", Color("70e1a4"))
	backpack_panel.add_child(backpack_capacity_label)

	var load_track := ColorRect.new()
	load_track.position = Vector2(16, 47)
	load_track.size = Vector2(592, 6)
	load_track.color = Color("142a31")
	load_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backpack_panel.add_child(load_track)
	backpack_load_bar = ColorRect.new()
	backpack_load_bar.position = Vector2.ZERO
	backpack_load_bar.size = Vector2(0, 6)
	backpack_load_bar.color = Color("62e7c3")
	backpack_load_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_track.add_child(backpack_load_bar)

	# Section labels
	var _make_section_label = func(text: String, pos: Vector2, col: Color) -> void:
		var lbl := Label.new()
		lbl.text = text
		lbl.position = pos
		lbl.size = Vector2(300, 12)
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.add_theme_color_override("font_color", col)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		backpack_panel.add_child(lbl)
	_make_section_label.call("RAW CARGO", Vector2(16, 58), Color("d7b36a"))
	_make_section_label.call("PROCESSED", Vector2(16, 118), Color("8eeaff"))
	_make_section_label.call("AMMO", Vector2(16, 178), Color("f1d388"))
	_make_section_label.call("DEPLOYABLES", Vector2(16, 220), Color("a7eefa"))

	# Build slot grid
	backpack_slot_frames.clear()
	backpack_slot_icons.clear()
	backpack_slot_counts.clear()

	var raw_x := 16
	var refined_x := 16
	var ammo_x := 16
	var kit_x := 16
	const SLOT_W := 48

	for slot_def in BACKPACK_SLOT_DEFS:
		var slot_type: String = slot_def[3]
		var slot_x: int
		var slot_y: int
		match slot_type:
			"raw":
				slot_x = raw_x
				slot_y = 68
				raw_x += SLOT_W
			"refined":
				slot_x = refined_x
				slot_y = 128
				refined_x += SLOT_W
			"ammo":
				slot_x = ammo_x
				slot_y = 188
				ammo_x += SLOT_W
			"kit":
				slot_x = kit_x
				slot_y = 230
				kit_x += SLOT_W
			_:
				continue
		var result := _make_slot(backpack_panel, Vector2(slot_x, slot_y), slot_def[2])
		backpack_slot_frames.append(result[0])
		backpack_slot_icons.append(result[1])
		backpack_slot_counts.append(result[2])

	var hint := Label.new()
	hint.text = "CLICK ASSIGN  HOLSTER / BUILD / PACK  //  [R] DISCARD RAW"
	hint.position = Vector2(16, 334)
	hint.size = Vector2(470, 12)
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color("81979d"))
	backpack_panel.add_child(hint)

	var close := _overlay_button("CLOSE  //  [I]")
	close.position = Vector2(490, 8)
	close.size = Vector2(114, 28)
	close.add_theme_font_size_override("font_size", 8)
	close.pressed.connect(_close_backpack)
	backpack_panel.add_child(close)

	_build_pack_assign_grid()


func _build_pack_assign_grid() -> void:
	pack_assign_holster.clear()
	pack_assign_build.clear()
	pack_assign_pack.clear()
	pack_assign_pick.clear()
	var holster_lbl := Label.new()
	holster_lbl.text = "HOLSTER"
	holster_lbl.position = Vector2(16, 276)
	holster_lbl.size = Vector2(52, 10)
	holster_lbl.add_theme_font_size_override("font_size", 7)
	holster_lbl.add_theme_color_override("font_color", Color("8eeaff"))
	holster_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backpack_panel.add_child(holster_lbl)
	for i in range(OperatorLoadoutScript.HOLSTER_SIZE):
		pack_assign_holster.append(_make_assign_cell(Vector2(70 + i * 24, 274), 22, "holster", i))
	var build_lbl := Label.new()
	build_lbl.text = "BUILD"
	build_lbl.position = Vector2(230, 276)
	build_lbl.size = Vector2(40, 10)
	build_lbl.add_theme_font_size_override("font_size", 7)
	build_lbl.add_theme_color_override("font_color", Color("d7b36a"))
	build_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backpack_panel.add_child(build_lbl)
	for i in range(OperatorLoadoutScript.HOTBAR_SIZE):
		pack_assign_build.append(_make_assign_cell(Vector2(272 + i * 20, 274), 18, "hotbar", i))
	var pack_lbl := Label.new()
	pack_lbl.text = "PACK"
	pack_lbl.position = Vector2(16, 298)
	pack_lbl.size = Vector2(40, 10)
	pack_lbl.add_theme_font_size_override("font_size", 7)
	pack_lbl.add_theme_color_override("font_color", Color("70e1a4"))
	pack_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backpack_panel.add_child(pack_lbl)
	for i in range(OperatorLoadoutScript.BACKPACK_SIZE):
		var col := i % 9
		var row := int(i / 9)
		pack_assign_pack.append(_make_assign_cell(Vector2(58 + col * 20, 296 + row * 16), 15, "backpack", i))


func _make_assign_cell(pos: Vector2, size_px: int, where: String, index: int) -> Dictionary:
	var frame := ColorRect.new()
	frame.position = pos
	frame.size = Vector2(size_px, size_px)
	frame.color = Color("0a1f28")
	frame.mouse_filter = Control.MOUSE_FILTER_STOP
	frame.gui_input.connect(_on_pack_assign_gui_input.bind(where, index))
	backpack_panel.add_child(frame)
	var lbl := Label.new()
	lbl.position = Vector2(1, 2)
	lbl.size = Vector2(size_px - 2, size_px - 2)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 7)
	lbl.add_theme_color_override("font_color", Color("c8d8dc"))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(lbl)

	var icon := TextureRect.new()
	icon.position = Vector2(1, 1)
	icon.size = Vector2(size_px - 2, size_px - 2)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(icon)

	return {"frame": frame, "label": lbl, "icon": icon}


func _on_pack_assign_gui_input(event: InputEvent, where: String, index: int) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if pack_assign_pick.is_empty():
		pack_assign_pick = {"where": where, "index": index}
		_refresh_pack_assign_grid()
		get_viewport().set_input_as_handled()
		return
	operator_loadout.swap_slots(str(pack_assign_pick.get("where", "")), int(pack_assign_pick.get("index", -1)), where, index)
	pack_assign_pick.clear()
	_sync_deployable_mirror()
	_sync_current_weapon_from_hotbar()
	_refresh_backpack_panel()
	get_viewport().set_input_as_handled()


func _refresh_pack_assign_grid() -> void:
	if operator_loadout == null:
		return
	var pick_where := str(pack_assign_pick.get("where", ""))
	var pick_index := int(pack_assign_pick.get("index", -1))
	for i in range(pack_assign_holster.size()):
		var unlocked := i < operator_loadout.gun_slot_count()
		_paint_assign_cell(pack_assign_holster[i], operator_loadout.get_slot("holster", i), unlocked, pick_where == "holster" and pick_index == i)
	for i in range(pack_assign_build.size()):
		var unlocked := i < operator_loadout.build_slot_count()
		_paint_assign_cell(pack_assign_build[i], operator_loadout.get_slot("hotbar", i), unlocked, pick_where == "hotbar" and pick_index == i)
	for i in range(pack_assign_pack.size()):
		_paint_assign_cell(pack_assign_pack[i], operator_loadout.get_slot("backpack", i), true, pick_where == "backpack" and pick_index == i)


func _paint_assign_cell(cell: Dictionary, stack: Dictionary, unlocked: bool, picked: bool) -> void:
	var frame: ColorRect = cell["frame"]
	var lbl: Label = cell["label"]
	frame.visible = unlocked
	if not unlocked:
		return
	var filled := str(stack.get("kind", OperatorLoadoutScript.KIND_EMPTY)) != OperatorLoadoutScript.KIND_EMPTY
	frame.color = Color("1a4a55") if picked else (Color("0f2a36") if filled else Color("080f14"))
	var count := int(stack.get("count", 0))
	var icon_tex: Texture2D = null
	if filled:
		icon_tex = _hotbar_stack_icon(stack)
	var text := _hotbar_slot_label(stack)

	var icon: TextureRect = cell.get("icon")
	if filled:
		if icon_tex != null and icon != null:
			icon.texture = icon_tex
			icon.visible = true
			if count > 1:
				lbl.visible = true
				lbl.text = str(count)
			else:
				lbl.visible = false
				lbl.text = ""
		else:
			if icon != null:
				icon.visible = false
			if count > 1:
				text = "%s%d" % [text.substr(0, 2), count]
			lbl.visible = true
			lbl.text = text
	else:
		if icon != null:
			icon.visible = false
		lbl.visible = true
		lbl.text = "-"


func _open_backpack() -> void:
	backpack_open = true
	build_mode = false
	sprinting = false
	pack_assign_pick.clear()
	_refresh_backpack_panel()
	backpack_panel.visible = true


func _close_backpack() -> void:
	backpack_open = false
	backpack_panel.visible = false


func _refresh_backpack_panel() -> void:
	if not is_instance_valid(backpack_panel) or not is_instance_valid(material_economy):
		return
	var used: int = _backpack_used()
	var capacity: int = _backpack_capacity()
	var free: int = _backpack_free()
	var load_ratio: float = clampf(float(used) / maxf(1.0, float(capacity)), 0.0, 1.0)
	backpack_capacity_label.text = "MK%d  //  %d / %d MATERIAL  //  %d FREE  //  KITS %d  WALLS %d  //  AMMO %d EXEMPT" % [
		backpack_tier, used, capacity, free,
		_deployable_stock_total(),
		operator_loadout.block_total(),
		reserve_ammo + shotgun_reserve + smg_reserve + railgun_reserve
	]
	backpack_capacity_label.add_theme_color_override("font_color", Color("ef8b72") if free <= 0 else Color("70e1a4"))
	backpack_load_bar.size.x = 592.0 * load_ratio
	backpack_load_bar.color = Color("ef8b72") if load_ratio >= 0.95 else (Color("f0ad57") if load_ratio >= 0.75 else Color("62e7c3"))

	# Update each slot
	var ammo_counts := {
		"pistol": reserve_ammo,
		"shotgun": shotgun_reserve,
		"smg": smg_reserve,
		"railgun": railgun_reserve,
	}
	var kit_counts := deployable_stock

	for slot_index in range(BACKPACK_SLOT_DEFS.size()):
		if slot_index >= backpack_slot_counts.size():
			break
		var slot_def = BACKPACK_SLOT_DEFS[slot_index]
		var key: String = slot_def[0]
		var slot_type: String = slot_def[3]
		var amount := 0
		match slot_type:
			"raw":
				amount = int(material_economy.raw.get(key, 0))
			"refined":
				amount = int(material_economy.refined.get(key, 0))
			"ammo":
				amount = int(ammo_counts.get(key, 0))
			"kit":
				amount = int(kit_counts.get(key, 0))
		var count_lbl: Label = backpack_slot_counts[slot_index]
		var frame: ColorRect = backpack_slot_frames[slot_index]
		if amount > 0:
			count_lbl.text = str(amount)
			count_lbl.add_theme_color_override("font_color", Color("c8ffd4"))
			frame.color = Color("0f2a36")
			backpack_slot_icons[slot_index].modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			count_lbl.text = "-"
			count_lbl.add_theme_color_override("font_color", Color("334d55"))
			frame.color = Color("080f14")
			backpack_slot_icons[slot_index].modulate = Color(1.0, 1.0, 1.0, 0.22)
	_refresh_pack_assign_grid()


func _is_near_core() -> bool:
	return not _nearby_base_id().is_empty()


func _open_core_base() -> void:
	_deposit_apex_components()
	using_core_base = true
	build_mode = false
	core_base_panel.visible = true
	var record: Dictionary = base_network.get_base(current_base_id)
	core_base_title.text = "%s  ·  MK %d" % [str(record["name"]), int(record["tier"])]
	core_menu_page = "progress" if skill_points > 0 else "armory"
	foundry_ui_refresh_elapsed = 0.0
	if skill_points > 0:
		core_base_status.text = "%d SKILL POINT%s READY" % [skill_points, "" if skill_points == 1 else "S"]
	else:
		core_base_status.text = "WEAPONS"
	_refresh_core_base_panel()
	_focus_first_core_action()


func _set_core_menu_page(page_id: String) -> void:
	if merchant_store_session and page_id != "supplies":
		return
	if page_id not in SHOP_PAGES:
		return
	core_menu_page = page_id
	core_base_status.text = str(SHOP_PAGE_LABELS.get(page_id, page_id.to_upper()))
	_refresh_core_base_panel()
	_focus_first_core_action()


func _set_core_department(department_id: String) -> void:
	if merchant_store_session:
		_set_core_menu_page("supplies")
		return
	var pages: Variant = SHOP_DEPARTMENTS.get(department_id, [])
	if not pages is Array or pages.is_empty():
		return
	_set_core_menu_page(str(pages[0]))


func _focus_first_core_action() -> void:
	for button: Button in core_service_buttons:
		if button.visible and not button.disabled:
			button.grab_focus()
			return


func _cycle_core_menu_page(direction: int) -> void:
	if merchant_store_session:
		_set_core_menu_page("supplies")
		return
	var current_department := _department_for_page(core_menu_page)
	var current_index := maxi(0, SHOP_DEPARTMENT_ORDER.find(current_department))
	_set_core_department(SHOP_DEPARTMENT_ORDER[posmod(current_index + direction, SHOP_DEPARTMENT_ORDER.size())])


func _department_for_page(page_id: String) -> String:
	for department_id: String in SHOP_DEPARTMENT_ORDER:
		if page_id in SHOP_DEPARTMENTS[department_id]:
			return department_id
	return "gear"


func _execute_core_action(slot: int) -> void:
	match core_menu_page:
		"armory":
			if slot >= 0 and slot <= WEAPON_RAILGUN:
				_purchase_weapon_upgrade_for(slot)
			elif slot == 5:
				_purchase_weapon_unlock()
			elif slot == 6:
				_purchase_mag_upgrade()
			elif slot == 7:
				_purchase_weapon_upgrade_for(WEAPON_FLAMETHROWER)
		"supplies":
			_purchase_supply(slot)
		"mining":
			if slot == 0:
				_purchase_mining_upgrade(true)
			elif slot == 1:
				_purchase_mining_upgrade(false)
		"construction":
			if slot == 8:
				_purchase_doorway_upgrade()
			else:
				_purchase_or_research_construction(slot)
		"storage":
			if slot == 4:
				_purchase_deployable_storage_upgrade()
			else:
				_purchase_or_craft_storage(slot)
		"defenses":
			if slot == 0:
				_purchase_turret_upgrade()
			elif slot == 1:
				_purchase_repairs()
			elif slot == 2:
				_purchase_base_upgrade()
		"materials":
			if slot == 0:
				_deposit_contract_refining()
			elif slot == 1 and material_economy.foundry_tier <= 0:
				_unlock_foundry()
			elif slot == 1 and material_economy.foundry_tier < 3:
				_unlock_foundry()
			elif slot == 2 and material_economy.foundry_tier > 0:
				_fabricate_foundry_kit()
			elif slot == 3:
				_sell_refined_materials()
			elif slot == 4:
				_sell_raw_materials_quick()
			elif slot == 7:
				_purchase_foundry_fuel()
			elif slot == 8:
				_recycle_wall_blocks()
			elif slot == 9:
				_sell_wall_blocks()
		"base":
			if slot == 8 and current_base_id == BaseNetworkScript.COMMAND_ID:
				_invite_or_claim_merchant()
			elif slot == 0:
				_purchase_base_upgrade()
			elif slot == 1:
				_purchase_repairs()
			elif slot == 4:
				_purchase_regional_service()
			elif slot == 5:
				if _personal_base_index_for_base(current_base_id) >= 0:
					_upgrade_personal_base()
				else:
					_purchase_or_craft_personal_base()
			elif slot in [6, 7]:
				_purchase_mecha_upgrade()
		"style":
			if slot >= 0 and slot < PLAYER_STYLE_NAMES.size():
				_purchase_or_equip_style(slot)
			elif slot == 5:
				_purchase_backpack_upgrade()
		"progress":
			var node_id := ProgressionTreeScript.node_for_action_slot(slot)
			if not node_id.is_empty():
				_unlock_skill_node(node_id)


func _close_core_base() -> void:
	using_core_base = false
	merchant_store_session = false
	merchant_store_structure_index = -1
	core_base_panel.visible = false


func _refresh_core_base_panel() -> void:
	_sync_expedition_progress()
	var focused_slot := -1
	var focused := get_viewport().gui_get_focus_owner()
	if focused in core_service_buttons:
		focused_slot = core_service_buttons.find(focused)
	if merchant_store_session:
		_refresh_merchant_store_panel(focused_slot)
		return
	var record: Dictionary = base_network.get_base(current_base_id)
	var is_command: bool = current_base_id == BaseNetworkScript.COMMAND_ID
	var condition_percent: int = roundi(float(record["health"]) / maxf(1.0, float(record["max_health"])) * 100.0)
	var linked_defenses: int = 0
	var damaged_defenses: int = 0
	for structure in structures:
		if structure.base_id == current_base_id:
			linked_defenses += 1
			if structure.health < structure.max_health:
				damaged_defenses += 1
	_update_scrap_label()
	core_base_network_label.text = "CORE %d%%  ·  %d DEFENSES  ·  %d REPAIR" % [condition_percent, linked_defenses, damaged_defenses]
	core_base_network_label.add_theme_color_override("font_color", Color("ef8b72") if condition_percent < 40 or damaged_defenses > 0 else Color("a7eefa"))
	_refresh_expedition_xp_meter()
	var active_department := _department_for_page(core_menu_page)
	var active_pages: Array = SHOP_DEPARTMENTS[active_department]
	core_base_status.text = "%s DEPARTMENT  ·  %s" % [str(SHOP_DEPARTMENT_LABELS[active_department]), str(SHOP_PAGE_LABELS.get(core_menu_page, core_menu_page.to_upper()))]
	if skill_points > 0 and core_menu_page != "progress":
		core_base_status.text += "  ·  %d SP READY" % skill_points
	for department_id: String in SHOP_DEPARTMENT_ORDER:
		var department_button: Button = core_department_buttons[department_id]
		if department_id == active_department:
			department_button.add_theme_color_override("font_color", Color("b9f6ff"))
			department_button.add_theme_color_override("icon_normal_color", Color("b9f6ff"))
			department_button.add_theme_stylebox_override("normal", _button_style(Color("102c34"), Color("66deef"), 1))
		else:
			department_button.add_theme_color_override("font_color", Color("8f754b"))
			department_button.add_theme_color_override("icon_normal_color", Color("ab8752"))
			department_button.add_theme_stylebox_override("normal", _button_style(Color("16140f"), Color("55452f"), 1))
	for tab_id: String in core_tab_buttons.keys():
		var tab: Button = core_tab_buttons[tab_id]
		tab.visible = tab_id in active_pages
		var tab_label := str(SHOP_PAGE_LABELS.get(tab_id, tab_id.to_upper()))
		if tab_id == core_menu_page:
			tab.text = tab_label
			tab.add_theme_color_override("font_color", Color("8eeaff"))
			tab.add_theme_color_override("font_hover_color", Color("b8f6ff"))
			tab.add_theme_stylebox_override("normal", _active_tab_stylebox())
		elif tab_id == "progress" and skill_points > 0:
			tab.text = "%s +%d" % [tab_label, skill_points]
			tab.add_theme_color_override("font_color", Color("f0d47b"))
			tab.add_theme_color_override("font_hover_color", Color("ffe7a0"))
			tab.remove_theme_stylebox_override("normal")
		else:
			tab.text = tab_label
			tab.add_theme_color_override("font_color", Color("547880"))
			tab.add_theme_color_override("font_hover_color", Color("78aabc"))
			tab.remove_theme_stylebox_override("normal")
	for button: Button in core_service_buttons:
		button.visible = false
		button.disabled = false
	for detail_index in range(core_action_details.size()):
		core_action_details[detail_index] = ""
		core_action_states[detail_index] = ""
	match core_menu_page:
		"armory":
			_refresh_armory_page(record, is_command)
		"supplies":
			_refresh_supplies_page(record)
		"mining":
			_refresh_mining_page()
		"construction":
			_refresh_construction_page()
		"storage":
			_refresh_storage_page()
		"defenses":
			_refresh_defenses_page(record, is_command)
		"materials":
			_refresh_materials_page()
		"base":
			_refresh_base_page(record, is_command)
		"progress":
			_refresh_progress_page()
		"style":
			_refresh_style_page()
	var detail_slot := _repair_core_focus(focused_slot) if focused_slot >= 0 else 0
	_show_core_action_detail(detail_slot)


func _repair_core_focus(preferred_slot: int) -> int:
	for offset in range(core_service_buttons.size()):
		var slot := posmod(preferred_slot + offset, core_service_buttons.size())
		var button: Button = core_service_buttons[slot]
		if button.visible and not button.disabled:
			button.grab_focus()
			return slot
	return preferred_slot if core_service_buttons[preferred_slot].visible else 0


func _show_core_action(slot: int, label: String, disabled: bool = false, detail: String = "", state: String = "") -> void:
	var display_label := label.replace("[BUY] ", "BUY ") \
		.replace("[CRAFT] ", "CRAFT ") \
		.replace("[LOCKED] ", "⊘ ") \
		.replace("[RESEARCH] ", "RESEARCH ") \
		.replace("[INFO] ", "INFO ") \
		.replace("[EQUIPPED] ", "✓ EQUIPPED ") \
		.replace("[SELECT] ", "SELECT ") \
		.replace("[OWNED] ", "✓ OWNED ") \
		.replace("[MAX] ", "✓ MAX ") \
		.replace("[ACTION] ", "ACTION ") \
		.replace("[DEPOSIT] ", "DEPOSIT ") \
		.replace("[BUILD] ", "BUILD ") \
		.replace("[REFINE] ", "REFINE ") \
		.replace("[SELL] ", "SELL ") \
		.replace("[EQUIP] ", "EQUIP ") \
		.replace("[UNLOCK] ", "UNLOCK ") \
		.replace("[LVL ", "LVL ") \
		.replace("[MISSING] ", "MISSING ")
	
	var button: Button = core_service_buttons[slot]
	button.visible = true
	button.text = _compact_shop_action_label(label)
	button.icon = _shop_icon_for_label(label)
	button.expand_icon = true
	# The terminal detail card is the deliberate, compact inspection surface.
	# Native tooltips inherit viewport-scale typography and can cover the entire menu.
	button.tooltip_text = ""
	core_action_details[slot] = detail
	core_action_states[slot] = state if not state.is_empty() else ("LOCKED" if disabled else "READY")
	var state_blocks_purchase: bool = core_action_states[slot].begins_with("MISSING") or core_action_states[slot].begins_with("LOCKED") or core_action_states[slot] in ["OWNED", "MAXIMUM", "EQUIPPED", "IN PROGRESS", "DEPLOYED"]
	button.disabled = disabled or state_blocks_purchase
	var state_color := Color("c8d8dc")
	if core_action_states[slot] == "READY":
		state_color = Color("baf7d1")
	elif core_action_states[slot].begins_with("MISSING") or core_action_states[slot].begins_with("LOCKED"):
		state_color = Color("f3a08c")
	elif core_action_states[slot] in ["OWNED", "MAXIMUM", "EQUIPPED", "DEPLOYED"]:
		state_color = Color("f0d47b")
	button.add_theme_color_override("font_color", state_color)
	button.add_theme_color_override("font_disabled_color", state_color.darkened(0.12))
	if core_action_states[slot].begins_with("MISSING") or core_action_states[slot].begins_with("LOCKED"):
		button.add_theme_stylebox_override("disabled", _button_style(Color("17191a"), Color("534b3e"), 1))
	elif core_action_states[slot] in ["OWNED", "MAXIMUM", "EQUIPPED", "DEPLOYED"]:
		button.add_theme_stylebox_override("disabled", _button_style(Color("242316"), Color("706638"), 1))
	else:
		button.add_theme_stylebox_override("disabled", _button_style(Color("0a1a20"), Color("1c343b"), 1))


func _compact_shop_action_label(source_label: String) -> String:
	var compact := source_label.strip_edges()
	var is_info := compact.begins_with("[INFO] ")
	var meta := ""
	if compact.begins_with("[SP ") or compact.begins_with("[LVL "):
		var bracket_end := compact.find("]")
		if bracket_end >= 0:
			var bracket_text := compact.substr(1, bracket_end - 1)
			meta = bracket_text.trim_prefix("SP ") + " SP" if compact.begins_with("[SP ") else bracket_text
			compact = compact.substr(bracket_end + 1).strip_edges()
	for prefix: String in ["[BUY] ", "[CRAFT] ", "[LOCKED] ", "[RESEARCH] ", "[INFO] ", "[EQUIPPED] ", "[SELECT] ", "[OWNED] ", "[MAX] ", "[ACTION] ", "[DEPOSIT] ", "[BUILD] ", "[REFINE] ", "[RECYCLE] ", "[SELL] ", "[SELL NOW] ", "[EQUIP] ", "[UNLOCK] ", "[MISSING] "]:
		compact = compact.trim_prefix(prefix)
	var segments := compact.split("  //  ")
	var primary := str(segments[0]).replace(" > ", " → ")
	var secondary := meta
	if secondary.is_empty():
		for segment_index in range(1, segments.size()):
			var candidate := str(segments[segment_index]).strip_edges()
			if candidate.begins_with("$") or candidate.begins_with("MK") or candidate == "NO COST":
				secondary = candidate.get_slice(" + ", 0)
				break
	if secondary.is_empty() and is_info and segments.size() > 1:
		secondary = str(segments[1]).strip_edges()
	return primary if secondary.is_empty() else "%s  ·  %s" % [primary, secondary]


func _core_tab_icon(page_id: String) -> Texture2D:
	match page_id:
		"armory":
			return shop_icons.get("pistol")
		"supplies":
			return shop_icons.get("ammo_box")
		"mining":
			return shop_icons.get("laser")
		"construction":
			return shop_icons.get("barricade")
		"defenses":
			return shop_icons.get("sentry")
		"materials":
			return shop_icons.get("bronze_ingot")
		"storage":
			return shop_icons.get("chest_small")
		"base":
			return shop_icons.get("command_core")
		"progress":
			return shop_icons.get("optic_core")
		"style":
			return shop_icons.get("cosmetic_suit")
	return null


func _shop_icon_for_label(label: String) -> Texture2D:
	var upper := label.to_upper()
	for style_index in range(PLAYER_STYLE_NAMES.size()):
		if PLAYER_STYLE_NAMES[style_index] in upper and style_index < player_textures.size():
			return player_textures[style_index]
	if "PISTOL CARTRIDGE" in upper:
		return shop_icons.get("pistol_ammo")
	if "SHOTGUN SHELL" in upper:
		return shop_icons.get("shotgun_ammo")
	if "LASER RECHARGE" in upper or "LASER CHARGE" in upper:
		return shop_icons.get("laser_battery")
	if "SMG ROUND" in upper:
		return shop_icons.get("smg_mag")
	if "FLAME FUEL" in upper or "FLAMETHROWER" in upper:
		return shop_icons.get("flamethrower")
	if "RAIL SLUG" in upper:
		return shop_icons.get("rail_slug")
	if "AMMO" in upper or "LOADOUT" in upper:
		return shop_icons.get("ammo_box")
	if "MEDICAL" in upper or "HEALTH" in upper:
		return shop_icons.get("medkit")
	if "TURRET UPGRADE" in upper:
		return shop_icons.get("turret_chip")
	if "ROCKET TURRET" in upper:
		return shop_icons.get("rocket_turret")
	if "LASER TURRET" in upper:
		return shop_icons.get("laser_turret")
	if "LAND MINE" in upper:
		return shop_icons.get("land_mine")
	if "BACKPACK" in upper or "PACK LOAD" in upper or "EXPEDITION HAULER" in upper:
		return shop_icons.get("backpack")
	if "WALL BLOCK" in upper:
		return shop_icons.get("stone_block")
	if "GRANITE BARRIER" in upper:
		return shop_icons.get("granite_barrier")
	if "REINFORCED BARRIER" in upper:
		return shop_icons.get("reinforced_barrier")
	if "BLAST BARRIER" in upper:
		return shop_icons.get("blast_barrier")
	if "STEEL BARRIER" in upper:
		return shop_icons.get("steel_barrier")
	if "SMALL CHEST" in upper:
		return shop_icons.get("chest_small")
	if "MEDIUM CHEST" in upper:
		return shop_icons.get("chest_medium")
	if "LARGE CHEST" in upper:
		return shop_icons.get("chest_large")
	if "TURRET" in upper or "SENTRY" in upper:
		return shop_icons.get("sentry")
	if "REPAIR" in upper:
		return shop_icons.get("repair")
	if "FOUNDRY" in upper:
		return shop_icons.get("foundry_furnace")
	if "CUTTER" in upper or "EMITTER" in upper or "SURFACE-LOCK" in upper:
		return shop_icons.get("laser")
	if "FRONTIER CORE" in upper:
		return shop_icons.get("frontier_core")
	if "CORE" in upper and "CRYSTAL CORE" not in upper and "OPTIC CORE" not in upper:
		return shop_icons.get("command_core")
	for material_match: Array in [
		["EXPLOSIVE COMPOUND", "explosive_compound"], ["OPTIC CORE", "optic_core"],
		["TITANIUM PLATE", "titanium_plate"], ["STEEL PLATE", "steel_plate"],
		["REINFORCED BLOCK", "reinforced_block"], ["STONE BLOCK", "stone_block"],
		["TITANIUM", "titanium_ore"], ["IRON", "iron_ore"], ["GRANITE", "granite"],
		["BASALT", "basalt"], ["QUARTZ", "quartz"], ["SULFUR", "sulfur"], ["COAL", "coal"],
		["CUT DIAMOND", "cut_diamond"], ["ROUGH DIAMOND", "rough_diamond"], ["DIAMOND", "rough_diamond"],
		["CRYSTAL CORE", "crystal_core"], ["ENERGY CRYSTAL", "energy_crystal"], ["CRYSTAL", "energy_crystal"],
		["BRONZE", "bronze_ingot"], ["SILVER BAR", "silver_ingot"], ["GOLD BAR", "gold_ingot"],
		["COPPER", "copper_ore"], ["SILVER", "silver_ore"], ["GOLD", "gold_ore"],
	]:
		if str(material_match[0]) in upper:
			return shop_icons.get(str(material_match[1]))
	for weapon_match: Array in [["RAILGUN", "railgun"], ["SHOTGUN", "shotgun"], ["PISTOL", "pistol"], ["LASER", "laser"], ["SMG", "smg"]]:
		if str(weapon_match[0]) in upper:
			return shop_icons.get(str(weapon_match[1]))
	return shop_icons.get("cosmetic_suit")


func _show_core_action_detail(slot: int) -> void:
	if slot < 0 or slot >= core_service_buttons.size() or not core_service_buttons[slot].visible:
		return
	core_selected_action_slot = slot
	var title_text: String = core_service_buttons[slot].text
	if "  //  " in title_text:
		title_text = title_text.get_slice("  //  ", 0)
	if "  ·  " in title_text:
		title_text = title_text.get_slice("  ·  ", 0)
	for prefix: String in ["BUY ", "CRAFT ", "ACTION ", "SELECT ", "RESEARCH ", "DEPOSIT ", "BUILD ", "REFINE ", "SELL ", "INFO ", "EQUIP ", "✓ EQUIPPED ", "UNLOCK ", "⊘ ", "MISSING ", "✓ OWNED ", "✓ MAX "]:
		title_text = title_text.trim_prefix(prefix)
	core_detail_title.text = title_text
	if is_instance_valid(core_detail_icon):
		core_detail_icon.texture = core_service_buttons[slot].icon
	core_detail_body.text = core_action_details[slot].replace("\n\nCOST       ", "\nCOST  ").replace("\n\n", "\n")
	var state: String = core_action_states[slot]
	core_detail_state.text = state
	var purchase_blocked := core_service_buttons[slot].disabled
	core_purchase_button.disabled = purchase_blocked
	core_purchase_cost.text = "" if purchase_blocked else _shop_action_cost(core_service_buttons[slot].text)
	if state == "READY":
		core_purchase_button.text = "PURCHASE"
	elif state in ["OWNED", "MAXIMUM", "EQUIPPED", "DEPLOYED"]:
		core_purchase_button.text = state
	elif state == "IN PROGRESS":
		core_purchase_button.text = "PROCESSING"
	else:
		core_purchase_button.text = "UNAVAILABLE" if purchase_blocked else "ACTIVATE"
	var state_color := Color("70e1a4")
	if state.begins_with("MISSING") or state.begins_with("LOCKED"):
		state_color = Color("ef8b72")
	elif state in ["OWNED", "MAXIMUM", "EQUIPPED", "DEPLOYED"]:
		state_color = Color("f0c96d")
	core_detail_state.add_theme_color_override("font_color", state_color)


func _shop_action_cost(action_label: String) -> String:
	if "  ·  " in action_label:
		return action_label.get_slice("  ·  ", 1)
	return "READY"


func _refresh_armory_page(record: Dictionary, is_command: bool) -> void:
	var arsenal_gate := ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_ARSENAL, skill_unlocks)
	var arsenal_lock := ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.BRANCH_ARSENAL)
	for weapon_id in range(WEAPON_RAILGUN + 1):
		var weapon_name := _weapon_name(weapon_id)
		var tier: int = weapon_tiers[weapon_id]
		if not unlocked_weapons[weapon_id]:
			_show_core_action(weapon_id, "[LOCKED] %s" % weapon_name, true, "Research this weapon at the Command Core before purchasing field upgrades.", "LOCKED")
		elif not arsenal_gate:
			_show_core_action(
				weapon_id,
				"[LOCKED] %s  //  PROGRESS" % weapon_name,
				true,
				_weapon_upgrade_detail(weapon_id, tier, arsenal_lock),
				"LOCKED"
			)
		elif tier >= 4:
			_show_core_action(weapon_id, "[MAX] %s  //  MK4" % weapon_name, true, "%s\n\nFINAL      %s" % [_weapon_role(weapon_id), _weapon_stat_summary(weapon_id, tier)], "MAXIMUM")
		else:
			var requirements: Dictionary = _weapon_material_requirements(weapon_id, tier)
			var state := _material_purchase_state(requirements, ProgressionTreeScript.BRANCH_ARSENAL)
			_show_core_action(
				weapon_id,
				"[BUY] %s  MK%d > MK%d  //  %s" % [weapon_name, tier, tier + 1, _format_material_requirements(requirements)],
				state.begins_with("LOCKED"),
				"%s\nCOST       %s" % [_weapon_upgrade_detail(weapon_id, tier), _format_material_requirements(requirements)],
				state
			)
	if not is_command:
		var regional_state := _regional_service_state(record)
		_show_core_action(5, _regional_service_label(str(record["kind"])), regional_state == "MAXIMUM", _regional_service_detail(record), regional_state)
	elif not unlocked_weapons[WEAPON_SMG]:
		var smg_req := {MaterialEconomyScript.BRONZE_INGOT: 1}
		_show_core_action(5, "[RESEARCH] COMPACT SMG  //  1 BRONZE" if arsenal_gate else "[LOCKED] COMPACT SMG  //  PROGRESS", not arsenal_gate, "Unlocks a 30-round automatic weapon. The SMG becomes selectable immediately after research.", _material_purchase_state(smg_req, ProgressionTreeScript.BRANCH_ARSENAL) if arsenal_gate else arsenal_lock)
	elif not unlocked_weapons[WEAPON_RAILGUN]:
		var rail_req := {MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
		_show_core_action(5, "[RESEARCH] RAILGUN  //  SILVER + CORE" if arsenal_gate else "[LOCKED] RAILGUN  //  PROGRESS", not arsenal_gate, "Unlocks a 115-damage heavy slug that pierces up to three targets.", _material_purchase_state(rail_req, ProgressionTreeScript.BRANCH_ARSENAL) if arsenal_gate else arsenal_lock)
	elif not flamethrower_unlocked:
		_show_core_action(5, "[RESEARCH] FLAMETHROWER  //  %s" % _format_material_requirements(FLAMETHROWER_UNLOCK_REQUIREMENTS) if arsenal_gate else "[LOCKED] FLAMETHROWER  //  PROGRESS", not arsenal_gate, "Short wide flame bursts leave hazardous fire patches. Fuel is purchased in Supplies.", _material_purchase_state(FLAMETHROWER_UNLOCK_REQUIREMENTS, ProgressionTreeScript.BRANCH_ARSENAL) if arsenal_gate else arsenal_lock)
	else:
		_show_core_action(5, "[OWNED] ALL WEAPON RESEARCH", true, "SMG and Railgun research is complete for this realm.", "OWNED")
	# Slot 6: Extended Mags — show upgrade for whichever weapon is the current selection
	# Cycle through weapons to find the current "focus" for the mag upgrade UI
	var mag_weapon_focus := _armory_mag_focus_weapon()
	if mag_weapon_focus < 0:
		_show_core_action(6, "[MAX] EXTENDED MAGS  //  ALL WEAPONS MAXED", true, "All weapons have reached maximum magazine capacity upgrades.", "MAXIMUM")
	else:
		var wname := _weapon_name(mag_weapon_focus)
		var mtier: int = mag_upgrade_tiers[mag_weapon_focus]
		var mag_req := _mag_upgrade_requirements(mtier)
		var cur_cap := _weapon_mag_capacity(mag_weapon_focus)
		var next_cap := _weapon_mag_capacity(mag_weapon_focus, -1, mtier + 1)
		if not unlocked_weapons[mag_weapon_focus]:
			_show_core_action(6, "[LOCKED] EXTENDED MAGS: %s" % wname, true, "Unlock the %s first." % wname, "LOCKED")
		elif not arsenal_gate:
			_show_core_action(6, "[LOCKED] EXTENDED MAGS  //  PROGRESS", true, arsenal_lock, "LOCKED")
		else:
			_show_core_action(6, "[BUY] EXTENDED MAGS: %s  MK%d>MK%d  //  %s" % [wname, mtier, mtier + 1, _format_material_requirements(mag_req)], false,
				"Increases %s magazine size.\n\nCURRENT  %d rounds\nNEXT       %d rounds\nCOST       %s\n\n[Use Q/E to cycle weapons]" % [wname, cur_cap, next_cap, _format_material_requirements(mag_req)],
			_material_purchase_state(mag_req, ProgressionTreeScript.BRANCH_ARSENAL))
	if not flamethrower_unlocked:
		_show_core_action(7, "[LOCKED] FLAMETHROWER UPGRADES", true, "Research the Flamethrower first.", "LOCKED")
	elif not arsenal_gate:
		_show_core_action(7, "[LOCKED] FLAMETHROWER  //  PROGRESS", true, arsenal_lock, "LOCKED")
	elif weapon_tiers[WEAPON_FLAMETHROWER] >= 4:
		_show_core_action(7, "[MAX] FLAMETHROWER  //  MK4", true, "Final flame-pressure calibration installed.", "MAXIMUM")
	else:
		var flame_tier := weapon_tiers[WEAPON_FLAMETHROWER]
		var flame_requirements := _weapon_material_requirements(WEAPON_FLAMETHROWER, flame_tier)
		_show_core_action(7, "[BUY] FLAMETHROWER  MK%d > MK%d  //  %s" % [flame_tier, flame_tier + 1, _format_material_requirements(flame_requirements)], false, "Improves burst and lingering fire damage.\n\nCURRENT  %s\nNEXT       %s" % [_weapon_stat_summary(WEAPON_FLAMETHROWER, flame_tier), _weapon_stat_summary(WEAPON_FLAMETHROWER, flame_tier + 1)], _material_purchase_state(flame_requirements, ProgressionTreeScript.BRANCH_ARSENAL))


func _refresh_supplies_page(record: Dictionary) -> void:
	_show_core_action(0, "[BUY] PISTOL CARTRIDGES x60  //  $12", false,
		"Adds 60 Pistol cartridges. Reserve: %d/%d." % [reserve_ammo, AMMO_RESERVE_CAPS[WEAPON_PISTOL]],
		_supply_purchase_state(0, 12))
	_show_core_action(1, "[BUY] SHOTGUN SHELLS x24  //  $18", false,
		"Adds 24 Shotgun shells. Reserve: %d/%d." % [shotgun_reserve, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN]],
		_supply_purchase_state(1, 18))
	var laser_missing := maxi(0, ceili(100.0 - laser_energy))
	_show_core_action(2, "[BUY] LASER RECHARGE +%d%%  //  $15" % laser_missing if laser_missing > 0 else "[OWNED] LASER FULLY CHARGED", laser_missing <= 0, "Restores the Laser capacitor to 100%%. Current charge: %d%%." % floori(laser_energy), _purchase_state(15, {}) if laser_missing > 0 else "OWNED")
	_show_core_action(3, "[BUY] SMG ROUNDS x120  //  $22" if unlocked_weapons[WEAPON_SMG] else "[LOCKED] SMG ROUNDS", not unlocked_weapons[WEAPON_SMG],
		"Adds 120 SMG rounds. Reserve: %d/%d." % [smg_reserve, AMMO_RESERVE_CAPS[WEAPON_SMG]] if unlocked_weapons[WEAPON_SMG] else "Research the Compact SMG first.",
		_supply_purchase_state(3, 22, unlocked_weapons[WEAPON_SMG], "SMG research required"))
	var rail_bonus := 3 if str(record["kind"]) == "research" else 0
	_show_core_action(4, "[BUY] RAIL SLUGS x%d  //  $30" % (9 + rail_bonus) if unlocked_weapons[WEAPON_RAILGUN] else "[LOCKED] RAIL SLUGS", not unlocked_weapons[WEAPON_RAILGUN],
		"Adds %d Railgun slugs. Reserve: %d/%d." % [9 + rail_bonus, railgun_reserve, AMMO_RESERVE_CAPS[WEAPON_RAILGUN]] if unlocked_weapons[WEAPON_RAILGUN] else "Research the Railgun first.",
		_supply_purchase_state(4, 30, unlocked_weapons[WEAPON_RAILGUN], "Railgun research required"))
	_show_core_action(5, "[BUY] FIELD AMMO BUNDLE  //  $55", false,
		"Fills all weapon reserves: Pistol x60, Shells x18, SMG x90, Rail x6, Laser charge.",
		_supply_purchase_state(5, 55))
	var missing_health := maxi(0, ceili(100.0 - player_health))
	_show_core_action(6, "[BUY] MEDICAL TREATMENT +%d HP  //  $25" % missing_health if missing_health > 0 else "[OWNED] OPERATOR AT FULL HEALTH", missing_health <= 0, "Restores operator health to 100. Current health: %d." % floori(player_health), _purchase_state(25, {}) if missing_health > 0 else "OWNED")
	var torch_stock: int = kit_count(TORCH_STOCK_ID)
	_show_core_action(7, "[BUY] FIELD LANTERN KIT  //  $%d  //  STOCK %d" % [TORCH_PURCHASE_COST, torch_stock], false,
		"Adds one placeable Field Lantern kit to your pack. Select it on the hotbar and RMB to place. Foundry upgrades add stronger vision and color.",
		_purchase_state(TORCH_PURCHASE_COST, {}))
	var fuel_missing := FLAMETHROWER_FUEL_CAP - flame_fuel
	var foundry_fuel_room := _foundry_fuel_purchase_room()
	var foundry_fuel_bundle := mini(FOUNDRY_FUEL_BUNDLE, foundry_fuel_room)
	if flamethrower_unlocked and fuel_missing > 0:
		_show_core_action(8, "[BUY] FLAME FUEL +%d  //  $%d" % [mini(FLAMETHROWER_FUEL_BUNDLE, fuel_missing), FLAMETHROWER_FUEL_BUNDLE_COST], false, "Restores Flame Fuel. The Flamethrower creates lingering fire that harms all units, including you.", _purchase_state(FLAMETHROWER_FUEL_BUNDLE_COST, {}))
	elif material_economy.foundry_tier > 0 and foundry_fuel_room > 0:
		_show_core_action(8, "[BUY] FOUNDRY COAL +%d  //  $%d" % [foundry_fuel_bundle, FOUNDRY_FUEL_BUNDLE_COST], false, "Issues coal into Foundry fuel buffers first. Buffered coal cannot be quick-sold from the field pack.", _purchase_state(FOUNDRY_FUEL_BUNDLE_COST, {}))
	elif flamethrower_unlocked:
		_show_core_action(8, "[OWNED] FLAME FUEL FULL", true, "Flame Fuel reserves are topped off.", "OWNED")
	elif material_economy.foundry_tier > 0:
		_show_core_action(8, "[OWNED] FOUNDRY COAL FULL", true, "Foundry fuel storage and pack coal reserves are topped off.", "OWNED")
	else:
		_show_core_action(8, "[LOCKED] FOUNDRY COAL", true, "Research Foundry MK1 in MATERIALS before buying facility fuel.", "LOCKED")


func _supply_purchase_state(slot: int, cost: int, gate_open: bool = true, locked_reason: String = "") -> String:
	# Ammo no longer counts against backpack — just check money and reserve caps
	var state: String = _purchase_state(cost, {}, gate_open, locked_reason)
	if state != "READY":
		return state
	match slot:
		0:
			if reserve_ammo >= AMMO_RESERVE_CAPS[WEAPON_PISTOL]: return "MAXIMUM"
		1:
			if shotgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_SHOTGUN]: return "MAXIMUM"
		3:
			if smg_reserve >= AMMO_RESERVE_CAPS[WEAPON_SMG]: return "MAXIMUM"
		4:
			if railgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_RAILGUN]: return "MAXIMUM"
		5:
			var all_full := (reserve_ammo >= AMMO_RESERVE_CAPS[WEAPON_PISTOL] and
						shotgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_SHOTGUN] and
						(not unlocked_weapons[WEAPON_SMG] or smg_reserve >= AMMO_RESERVE_CAPS[WEAPON_SMG]) and
						(not unlocked_weapons[WEAPON_RAILGUN] or railgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_RAILGUN]) and
						laser_energy >= 99.9)
			if all_full: return "MAXIMUM"
	return state


func _refresh_mining_page() -> void:
	var mining_gate := ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.CATEGORY_MINING, skill_unlocks)
	var mining_lock := ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.CATEGORY_MINING)
	if mining_speed_tier >= 5:
		_show_core_action(0, "[MAX] CUTTER SPEED  //  MK5", true, "Final mining motor installed.\n\nCURRENT  %.2fs PER ROCK\nTHROUGHPUT  %.1f ROCKS/MIN" % [_mining_cycle_duration(), 60.0 / _mining_cycle_duration()], "MAXIMUM")
	elif not mining_gate:
		_show_core_action(0, "[LOCKED] CUTTER SPEED  //  PROGRESS", true, mining_lock, "LOCKED")
	else:
		var speed_requirements: Dictionary = _mining_upgrade_requirements(true, mining_speed_tier)
		_show_core_action(0, "[BUY] CUTTER SPEED MK%d > MK%d  //  %s" % [mining_speed_tier, mining_speed_tier + 1, _format_material_requirements(speed_requirements)], false, "Shortens each complete rock cut without changing beam reach.\n\nCURRENT  %.2fs PER ROCK\nNEXT       %.2fs PER ROCK\nCOST       %s" % [_mining_cycle_duration(), _mining_cycle_duration(mining_speed_tier + 1), _format_material_requirements(speed_requirements)], _material_purchase_state(speed_requirements, ProgressionTreeScript.CATEGORY_MINING))
	if mining_emitter_tier >= 5:
		_show_core_action(1, "[MAX] MINING EMITTER SIZE  //  MK5", true, "Final emitter aperture installed. The ray still terminates at the first mineable surface.\n\nCURRENT  %.0f RANGE | %.1f BEAM" % [_mining_beam_reach(), _mining_beam_width()], "MAXIMUM")
	elif not mining_gate:
		_show_core_action(1, "[LOCKED] EMITTER SIZE  //  PROGRESS", true, mining_lock, "LOCKED")
	else:
		var emitter_requirements: Dictionary = _mining_upgrade_requirements(false, mining_emitter_tier)
		_show_core_action(1, "[BUY] EMITTER SIZE MK%d > MK%d  //  %s" % [mining_emitter_tier, mining_emitter_tier + 1, _format_material_requirements(emitter_requirements)], false, "Increases safe standoff range and visible cutting-beam diameter. It never mines through the first rock face.\n\nCURRENT  %.0f RANGE | %.1f BEAM\nNEXT       %.0f RANGE | %.1f BEAM\nCOST       %s" % [_mining_beam_reach(), _mining_beam_width(), _mining_beam_reach(mining_emitter_tier + 1), _mining_beam_width(mining_emitter_tier + 1), _format_material_requirements(emitter_requirements)], _material_purchase_state(emitter_requirements, ProgressionTreeScript.CATEGORY_MINING))
	_show_core_action(2, "[INFO] MK2 RELOCATION", true, "At overall Mining Gun MK2, hold MINE on a turret or wall to acquire it. Aim and FIRE to relocate it; BUILD cancels safely.", "ACTIVE" if _mining_tool_tier() >= 2 else "UNLOCKS AT MK2")
	_show_core_action(3, "[INFO] LONG-TERM TOOL INVESTMENT", true, "Unlock Excavation Rig at PROGRESS, then upgrade with refined parts only. Scrap pays field logistics elsewhere.", "REALM PROGRESSION")


func _mining_upgrade_requirements(speed_upgrade: bool, current_tier: int) -> Dictionary:
	return UpgradeEconomyScript.mining_upgrade_requirements(speed_upgrade, current_tier)


func _purchase_mining_upgrade(speed_upgrade: bool) -> void:
	if not ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.CATEGORY_MINING, skill_unlocks):
		core_base_status.text = ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.CATEGORY_MINING)
		return
	var current_tier: int = mining_speed_tier if speed_upgrade else mining_emitter_tier
	if current_tier >= 5:
		return
	var requirements: Dictionary = _mining_upgrade_requirements(speed_upgrade, current_tier)
	if not _spend_material_purchase(requirements):
		return
	if speed_upgrade:
		mining_speed_tier += 1
		core_base_status.text = "CUTTER SPEED ADVANCED TO MK %d // %.2fs PER ROCK" % [mining_speed_tier, _mining_cycle_duration()]
	else:
		mining_emitter_tier += 1
		core_base_status.text = "MINING EMITTER ADVANCED TO MK %d // %.0f RANGE" % [mining_emitter_tier, _mining_beam_reach()]
	_refresh_core_base_panel()
	_save_run()


func _construction_requires_automation(construction_id: String) -> bool:
	return construction_id == "rocket_turret" or construction_id == "laser_turret"


func _construction_automation_state() -> String:
	if ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_AUTOMATION, skill_unlocks):
		return "READY"
	return "LOCKED: %s" % ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.BRANCH_AUTOMATION)


func _refresh_construction_page() -> void:
	for slot in range(CONSTRUCTION_ORDER.size()):
		var construction_id: String = CONSTRUCTION_ORDER[slot]
		var display_name: String = _construction_name(construction_id)
		
		if not bool(construction_unlocks.get(construction_id, false)):
			var research_cost: int = _construction_research_cost(construction_id)
			var research_requirements: Dictionary = _construction_research_requirements(construction_id)
			var research_state := _purchase_state(research_cost, research_requirements)
			if _construction_requires_automation(construction_id):
				var automation_state := _construction_automation_state()
				if automation_state != "READY":
					research_state = automation_state
			_show_core_action(slot, "[RESEARCH] %s  //  $%d" % [display_name, research_cost], false, "%s\n\nUnlocks permanent fabrication access for this realm. A deployable kit must still be crafted after research.\nCOST       $%d + %s" % [_construction_description(construction_id), research_cost, _format_material_requirements(research_requirements)], research_state)
			continue
		# Heavy Doorway is capped at 1 deployed at a time — not a stock item
		var craft_cost: int = _construction_craft_cost(construction_id)
		var craft_requirements: Dictionary = _construction_craft_requirements(construction_id)
		var craft_state: String = _deployable_craft_state(construction_id, craft_cost, craft_requirements)
		if _construction_requires_automation(construction_id):
			var automation_state := _construction_automation_state()
			if automation_state != "READY":
				craft_state = automation_state
		if construction_id == "heavy_doorway":
			var placed := _doorway_exists()
			if placed:
				var door_lvl := 1
				for s in structures:
					if s.kind == BUILD_HEAVY_DOORWAY:
						door_lvl = s.level
						break
				_show_core_action(slot, "[PLACED] HEAVY DOORWAY  //  LVL %d" % door_lvl, false,
					"%s\n\nCURRENT SIZE: %s\nHold F near the doorway to open or close it." % [
						_construction_description(construction_id),
						["2x1","4x1","4x2"][clampi(door_lvl - 1, 0, 2)]],
					"DEPLOYED")
			else:
				_show_core_action(slot, "[CRAFT] HEAVY DOORWAY KIT  //  $%d" % craft_cost, false,
					"%s\n\nCOST  $%d + %s" % [_construction_description(construction_id), craft_cost, _format_material_requirements(craft_requirements)],
					craft_state)
			continue
		var current_stock: int = int(deployable_stock[construction_id])
		var cap: int = _deployable_cap(construction_id)
		if current_stock >= cap:
			craft_state = "MAXIMUM"
		_show_core_action(slot, "[CRAFT] %s KIT  //  $%d  //  OWN %d/%d" % [display_name, craft_cost, current_stock, cap], false, "%s\n\nCreates one field-deployable kit. Stored in dedicated supply cache (cap: %d).\nCOST       $%d + %s" % [_construction_description(construction_id), cap, craft_cost, _format_material_requirements(craft_requirements)], craft_state)
	# Slot 7 belongs to the Laser Turret. Overall kit totals remain visible in
	# the terminal header instead of replacing its fabrication action.
	# Slot 8: Doorway upgrade
	var door_upgrade_lvl := 0
	for s: Structure in structures:
		if s.kind == BUILD_HEAVY_DOORWAY:
			door_upgrade_lvl = s.level
			break
	if not bool(construction_unlocks.get("heavy_doorway", false)):
		_show_core_action(8, "[LOCKED] DOORWAY UPGRADE", true, "Research HEAVY DOORWAY first.", "LOCKED")
	elif door_upgrade_lvl <= 0:
		_show_core_action(8, "[LOCKED] DOORWAY UPGRADE  //  NOT PLACED", true, "Place a HEAVY DOORWAY on the field before upgrading.", "LOCKED")
	elif door_upgrade_lvl >= 3:
		_show_core_action(8, "[MAX] DOORWAY  //  LVL 3  //  4x2 GATE", true, "The doorway has reached maximum reinforcement (4x2).", "MAXIMUM")
	else:
		var next_lvl := door_upgrade_lvl + 1
		var upgrade_sizes := ["2x1", "4x1", "4x2"]
		var ucost: int = UpgradeEconomyScript.doorway_upgrade_cost(door_upgrade_lvl)
		var ureq: Dictionary = UpgradeEconomyScript.doorway_upgrade_requirements(door_upgrade_lvl)
		_show_core_action(8, "[UPGRADE] DOORWAY  LVL%d>LVL%d  %s>%s  //  $%d + %s" % [
				door_upgrade_lvl, next_lvl, upgrade_sizes[door_upgrade_lvl - 1], upgrade_sizes[next_lvl - 1],
				ucost, _format_material_requirements(ureq)], false,
			"Upgrades the placed HEAVY DOORWAY. Adjacent cells must be clear.\n\nCURRENT  LVL%d (%s)\nNEXT       LVL%d (%s)\nCOST       $%d + %s" % [
				door_upgrade_lvl, upgrade_sizes[door_upgrade_lvl - 1], next_lvl, upgrade_sizes[next_lvl - 1],
				ucost, _format_material_requirements(ureq)],
			_purchase_state(ucost, ureq))


func _construction_name(construction_id: String) -> String:
	var names := {
		"granite_barrier": "GRANITE BARRIER", "steel_barrier": "STEEL BARRIER",
		"reinforced_barrier": "REINFORCED BARRIER",
		"blast_barrier": "BLAST BARRIER", "land_mine": "LAND MINE",
		"rocket_turret": "ROCKET TURRET", "laser_turret": "LASER TURRET",
		"chest_small": "SMALL CHEST", "chest_medium": "MEDIUM CHEST", "chest_large": "LARGE CHEST",
		"heavy_doorway": "HEAVY DOORWAY",
		"personal_base": "PERSONAL BASE",
		SettlementProgressionScript.MERCHANT_STORE_STOCK_ID: "MERCHANT STORE",
	}
	return str(names.get(construction_id, construction_id.to_upper()))


func _construction_description(construction_id: String) -> String:
	var descriptions := {
		"granite_barrier": "Dense stone wall with 240 condition and stronger lane control than a scrap barricade. Fabricates directly from Foundry Stone Blocks.",
		"steel_barrier": "Steel-framed masonry with 300 condition and good choke-point control. No research needed — craft once you have Stone and Steel.",
		"reinforced_barrier": "Steel-bound masonry with 390 condition and heavy enemy slowdown.",
		"blast_barrier": "Titanium-faced fortification with 620 condition and maximum choke-point control.",
		"land_mine": "Single-use proximity charge dealing 95 area damage within 42 pixels.",
		"rocket_turret": "Slow heavy turret firing 70-damage rockets with a 48-pixel blast radius.",
		"laser_turret": "Fast precision turret firing 15-damage coherent bolts at long range.",
		"chest_small": "Basic 100-capacity secure storage unit.",
		"chest_medium": "Reinforced 300-capacity long-term storage vault.",
		"chest_large": "Massive 800-capacity bulk cargo container.",
		"heavy_doorway": "A massive reinforced entryway gate spanning 2 tiles wide. Hold F near it to open or close it. Only one Doorway can be placed at a time. Upgrade to Level 2 (4x1) and Level 3 (4x2) via the CONSTRUCTION tab.",
		"personal_base": "A field hut for free healing and a realm save. Deploy it on any active prepared ground; it never opens a shop.",
		SettlementProgressionScript.MERCHANT_STORE_STOCK_ID: "The first civilian foothold. Enter for a protected supplies interior; its settlement beacon also creates an eight-cell hostile spawn exclusion radius.",
	}
	return str(descriptions.get(construction_id, "Field construction kit."))


func _construction_research_cost(construction_id: String) -> int:
	return UpgradeEconomyScript.construction_research_cost(construction_id)


func _construction_research_requirements(construction_id: String) -> Dictionary:
	return UpgradeEconomyScript.construction_research_requirements(construction_id)


func _construction_craft_cost(construction_id: String) -> int:
	return UpgradeEconomyScript.construction_craft_cost(construction_id)


func _construction_craft_requirements(construction_id: String) -> Dictionary:
	return UpgradeEconomyScript.construction_craft_requirements(construction_id)


func _purchase_or_research_construction(slot: int) -> void:
	if slot < 0 or slot >= CONSTRUCTION_ORDER.size():
		return
	var construction_id: String = CONSTRUCTION_ORDER[slot]
	if _construction_requires_automation(construction_id):
		var automation_state := _construction_automation_state()
		if automation_state != "READY":
			core_base_status.text = "FABRICATION BLOCKED // %s" % automation_state
			return
	if not bool(construction_unlocks.get(construction_id, false)):
		var research_cost: int = _construction_research_cost(construction_id)
		var research_requirements: Dictionary = _construction_research_requirements(construction_id)
		if not _spend_purchase(research_cost, research_requirements):
			return
		construction_unlocks[construction_id] = true
		core_base_status.text = "%s RESEARCH COMPLETE // FABRICATION UNLOCKED" % _construction_name(construction_id)
	elif construction_id == "heavy_doorway":
		# Craft the one kit
		if _doorway_exists():
			core_base_status.text = "DOORWAY ALREADY PLACED // ONLY 1 ALLOWED"
			return
		if kit_count("heavy_doorway") >= 1:
			core_base_status.text = "HEAVY DOORWAY KIT READY // RMB PLACE"
			return
		var doorway_cost := _construction_craft_cost(construction_id)
		var doorway_requirements := _construction_craft_requirements(construction_id)
		var doorway_state := _deployable_craft_state(construction_id, doorway_cost, doorway_requirements)
		if doorway_state != "READY":
			core_base_status.text = "FABRICATION BLOCKED // %s" % doorway_state
			return
		if not _spend_purchase(doorway_cost, doorway_requirements):
			return
		if grant_kit("heavy_doorway", 1) > 0:
			core_base_status.text = "PACK FULL // NO FREE SLOT"
			return
		core_base_status.text = "HEAVY DOORWAY KIT FABRICATED // RMB PLACE"
	else:
		var current_stock: int = kit_count(construction_id)
		var cap: int = _deployable_cap(construction_id)
		if current_stock >= cap:
			core_base_status.text = "SUPPLY CACHE FULL (%d/%d)" % [current_stock, cap]
			return
		var craft_cost := _construction_craft_cost(construction_id)
		var craft_requirements := _construction_craft_requirements(construction_id)
		var craft_state := _deployable_craft_state(construction_id, craft_cost, craft_requirements)
		if craft_state != "READY":
			core_base_status.text = "FABRICATION BLOCKED // %s" % craft_state
			return
		if not _spend_purchase(craft_cost, craft_requirements):
			return
		if grant_kit(construction_id, 1) > 0:
			core_base_status.text = "PACK FULL // NO FREE SLOT"
			return
		core_base_status.text = "%s KIT FABRICATED // STOCK %d" % [_construction_name(construction_id), kit_count(construction_id)]
	_refresh_core_base_panel()
	_save_run()


func _purchase_doorway_upgrade() -> void:
	var door_idx := -1
	for i in range(structures.size()):
		if structures[i].kind == BUILD_HEAVY_DOORWAY:
			door_idx = i
			break
	if door_idx < 0:
		core_base_status.text = "NO DOORWAY PLACED // BUILD ONE FIRST"
		return
	var door: Structure = structures[door_idx]
	if door.level >= 3:
		core_base_status.text = "DOORWAY ALREADY AT MAX LEVEL (4x2)"
		return
	var ucost: int = UpgradeEconomyScript.doorway_upgrade_cost(door.level)
	var ureq: Dictionary = UpgradeEconomyScript.doorway_upgrade_requirements(door.level)
	# Check the new footprint fits
	var new_fp := _footprint_for_doorway_level(door.level + 1, door.rotated)
	for ox in range(new_fp.x):
		for oy in range(new_fp.y):
			var c := door.cell + Vector2i(ox, oy)
			if not grid.is_walkable(c):
				core_base_status.text = "UPGRADE BLOCKED // CLEAR SPACE FOR %s FOOTPRINT" % ("%dx%d" % [new_fp.x, new_fp.y])
				return
			for other in structures:
				if other == door:
					continue
				if _structure_covers_cell(other, c):
					core_base_status.text = "UPGRADE BLOCKED // REMOVE OBSTRUCTIONS FIRST"
					return
	if not _spend_purchase(ucost, ureq):
		return
	door.level += 1
	door.size = new_fp
	var health_per_level := [800.0, 1400.0, 2200.0]
	door.max_health = health_per_level[clampi(door.level - 1, 0, 2)] * fortification_multiplier
	door.health = door.max_health  # fully restore on upgrade
	_invalidate_structure_spatial_buckets()
	_mark_flow_dirty_for_structure(door)
	var upgrade_sizes := ["2x1", "4x1", "4x2"]
	core_base_status.text = "DOORWAY UPGRADED TO LVL%d // %s GATE" % [door.level, upgrade_sizes[door.level - 1]]
	_refresh_core_base_panel()
	_save_run()


func _refresh_storage_page() -> void:
	var foundry_active: bool = material_economy.foundry_tier > 0
	for slot in range(STORAGE_ORDER.size()):
		var storage_id: String = STORAGE_ORDER[slot]
		var display_name: String = _construction_name(storage_id)
		if not foundry_active:
			_show_core_action(slot, "[LOCKED] %s" % display_name, false,
				"Requires PLAYER FOUNDRY MK 1 to be operational before storage vaults can be fabricated.",
				"LOCKED")
			continue
		var craft_cost: int = _construction_craft_cost(storage_id)
		var craft_requirements: Dictionary = _construction_craft_requirements(storage_id)
		var weight: int = int(DEPLOYABLE_WEIGHTS[storage_id])
		var craft_state: String = _deployable_craft_state(storage_id, craft_cost, craft_requirements)
		var owned: int = int(deployable_stock[storage_id])
		var cap: int = _deployable_cap(storage_id)
		if owned >= cap:
			craft_state = "MAXIMUM"
		_show_core_action(slot, "[CRAFT] %s KIT  //  $%d  //  OWN %d/%d" % [display_name, craft_cost, owned, cap],
			false,
			"%s\n\nCreates one field-deployable storage vault kit. Pack weight: %d.\nCOST       $%d + %s" % [
				_construction_description(storage_id), weight, craft_cost,
				_format_material_requirements(craft_requirements)],
			craft_state)
	var total_stored: int = 0
	for structure: Structure in structures:
		if structure.kind in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
			total_stored += _chest_used(structure)
	_show_core_action(3, "[INFO] FIELD VAULTS  //  %d TOTAL UNITS STORED" % total_stored, true,
		"Small %d  Medium %d  Large %d\nApproach a placed vault and press INTERACT to open it." % [
			int(deployable_stock["chest_small"]), int(deployable_stock["chest_medium"]), int(deployable_stock["chest_large"])],
		"%d PACK UNITS" % _deployable_pack_units())
	
	# Slot 4: Capacity Upgrade for Deployables
	var focus_id := _storage_deployable_focus_id()
	if focus_id.is_empty():
		_show_core_action(4, "[MAX] STORAGE UPGRADES  //  ALL CACHES MAXED", true, "All deployable storage caches have reached maximum capacity.", "MAXIMUM")
	else:
		var dname := _construction_name(focus_id)
		var dtier: int = int(deployable_storage_tiers.get(focus_id, 0))
		var dcost: int = _deployable_storage_upgrade_cost(dtier)
		var dreq := _deployable_storage_upgrade_requirements(dtier)
		var cur_cap := _deployable_cap(focus_id)
		var next_cap: int = [50, 100, 200][clampi(dtier + 1, 0, 2)]
		if not bool(construction_unlocks.get(focus_id, false)):
			_show_core_action(4, "[LOCKED] UPGRADE CACHE: %s" % dname, true, "Fabrication blueprint for %s must be researched first." % dname, "LOCKED")
		else:
			_show_core_action(4, "[BUY] UPGRADE CACHE: %s  LVL%d>LVL%d  //  $%d + %s" % [dname, dtier + 1, dtier + 2, dcost, _format_material_requirements(dreq)], false,
				"Increases storage limit for %s kits.\n\nCURRENT  %d limit\nNEXT       %d limit\nCOST       $%d + %s\n\n[Use Q/E to cycle deployables]" % [dname, cur_cap, next_cap, dcost, _format_material_requirements(dreq)],
				_purchase_state(dcost, dreq))


func _purchase_or_craft_storage(slot: int) -> void:
	if slot < 0 or slot >= STORAGE_ORDER.size():
		return
	var storage_id: String = STORAGE_ORDER[slot]
	if material_economy.foundry_tier <= 0:
		core_base_status.text = "FOUNDRY REQUIRED // BUILD PLAYER FOUNDRY FIRST"
		return
	var current_stock: int = kit_count(storage_id)
	var cap: int = _deployable_cap(storage_id)
	if current_stock >= cap:
		core_base_status.text = "SUPPLY CACHE FULL (%d/%d) // UPGRADE CAPACITY" % [current_stock, cap]
		_refresh_core_base_panel()
		return
	var craft_cost := _construction_craft_cost(storage_id)
	var craft_requirements := _construction_craft_requirements(storage_id)
	var craft_state := _deployable_craft_state(storage_id, craft_cost, craft_requirements)
	if craft_state != "READY":
		core_base_status.text = "FABRICATION BLOCKED // %s" % craft_state
		_refresh_core_base_panel()
		return
	if not _spend_purchase(craft_cost, craft_requirements):
		return
	if grant_kit(storage_id, 1) > 0:
		core_base_status.text = "PACK FULL // NO FREE SLOT"
		_refresh_core_base_panel()
		return
	core_base_status.text = "%s VAULT KIT FABRICATED // STOCK %d" % [_construction_name(storage_id), kit_count(storage_id)]
	_refresh_core_base_panel()
	_save_run()


func _refresh_defenses_page(record: Dictionary, is_command: bool) -> void:
	var automation_gate := ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_AUTOMATION, skill_unlocks)
	var eligible_indices := _eligible_turret_indices()
	var eligible_count: int = eligible_indices.size()
	var turret_detail := "Closes the terminal and marks every eligible local turret in the world and on the minimap. Sentry MK upgrades spend Skill Points plus refined parts without Automation. Rocket and Laser kits require Automation at CONSTRUCTION; Rocket and Laser turret upgrades require Automation at DEFENSES."
	var turret_purchase_state := "LOCKED"
	var preview_index := _preview_turret_index(eligible_indices)
	if preview_index >= 0:
		var preview_sentry: Structure = structures[preview_index]
		turret_detail = "%s is the first selectable turret. Q/E cycles all %d eligible turrets.\n\n%s\nCOST       %s" % [_turret_id(preview_sentry), eligible_count, _turret_upgrade_summary(preview_sentry), _turret_upgrade_cost_label(preview_sentry)]
		turret_purchase_state = _turret_purchase_state(preview_sentry)
		for eligible_index: int in eligible_indices:
			var candidate_sentry: Structure = structures[eligible_index]
			if _turret_purchase_state(candidate_sentry) == "READY":
				turret_purchase_state = "READY"
				break
	var turret_title := "[LOCKED] NO POWERED LOCAL TURRETS"
	if eligible_count > 0:
		turret_title = "[SELECT] SENTRY UPGRADE  //  %d AVAILABLE" % eligible_count if not automation_gate else "[SELECT] TARGETED TURRET UPGRADE  //  %d AVAILABLE" % eligible_count
	_show_core_action(0, turret_title, eligible_count <= 0, turret_detail + "\n\nClick a marked turret directly or use Q/E then F.", turret_purchase_state if eligible_count > 0 else "LOCKED")
	var repair_cost: int = _repair_cost()
	_show_core_action(1, "[BUY] REPAIR CORE + LINKED DEFENSES  //  $%d" % repair_cost if repair_cost > 0 else "[OWNED] LOCAL NETWORK AT FULL CONDITION", repair_cost <= 0, "Fully restores this Core and every barricade and turret linked to its power territory.", _purchase_state(repair_cost, {}) if repair_cost > 0 else "OWNED")
	var base_tier: int = int(record["tier"])
	var sp_cost: int = ProgressionTreeScript.frontier_core_upgrade_sp(base_tier)
	var level_gate: int = 4 if base_tier == 1 else 8
	var base_req: Dictionary = _base_material_requirements(base_tier)
	var base_ready := not is_command and base_tier < 3 and expedition_level >= level_gate
	var base_state := _sp_purchase_state(sp_cost, base_req, base_ready, "Requires a Frontier Core and Expedition Level %d" % level_gate)
	_show_core_action(2, "[SP %d] CORE MK%d > MK%d  //  %s" % [sp_cost, base_tier, base_tier + 1, _format_material_requirements(base_req)] if base_tier < 3 else "[MAX] CORE MK3", base_tier >= 3 or _sp_action_disabled(sp_cost, base_req, base_ready, "Requires a Frontier Core and Expedition Level %d" % level_gate), _base_upgrade_detail(record, base_tier), "MAXIMUM" if base_tier >= 3 else base_state)


func _refresh_materials_page() -> void:
	var foundry_online := _any_foundry_operational()
	var kit_stock := _foundry_stock_available()
	var facility_state := "NOT OWNED"
	if material_economy.foundry_tier > 0:
		facility_state = "%d ONLINE" % _operational_foundry_count() if foundry_online else ("KITS %d" % kit_stock if kit_stock > 0 else "OFFLINE")
	_update_scrap_label()
	var wall_count: int = operator_loadout.block_total()
	core_base_network_label.text = "PARTS %d  ·  WALL %d  ·  $%d PARTS  ·  FOUNDRY MK%d %s" % [material_economy.refined_total(), wall_count, material_economy.refined_sale_value(), material_economy.foundry_tier, facility_state]
	core_base_network_label.add_theme_color_override("font_color", Color("a7eefa") if foundry_online else Color("f0c96d"))
	var contract_text := "CONTRACT REFINERY // %02d SEC // PAYOUT $%d" % [ceili(material_economy.contract_remaining), material_economy.contract_payout] if material_economy.contract_active() else "ALL RAW ORE // CONTRACT PAYOUT $%d" % material_economy.contract_value()
	_show_core_action(0, "[DEPOSIT] " + contract_text, material_economy.contract_active() or material_economy.raw_total() <= 0, "Sends all raw cargo to an outside refinery. After 24 seconds, the shipment returns as credits and frees backpack capacity; it does not create components.", "IN PROGRESS" if material_economy.contract_active() else ("READY" if material_economy.raw_total() > 0 else "MISSING RAW CARGO"))
	if material_economy.foundry_tier <= 0:
		var cost: int = material_economy.foundry_upgrade_cost(material_economy.foundry_tier)
		var upgrade_ready := current_base_id == BaseNetworkScript.COMMAND_ID
		var upgrade_detail := "MK1 unlocks placeable foundries with 20-unit buffers and 6-batch queues. Coal fuels every batch; steel and advanced recipes also consume coal as an ingredient."
		_show_core_action(1, "[BUILD] FOUNDRY MK1 RESEARCH  //  $%d" % cost, not upgrade_ready, upgrade_detail, _purchase_state(cost, {}, upgrade_ready, "Command Core required"))
		_show_core_action(2, "[LOCKED] FOUNDRY FABRICATION", true, "Unlock Foundry research to fabricate facility kits.", "LOCKED")
	else:
		if material_economy.foundry_tier < 3:
			var research_cost := material_economy.foundry_upgrade_cost(material_economy.foundry_tier)
			_show_core_action(1, "[RESEARCH] FOUNDRY MK%d  //  $%d" % [material_economy.foundry_tier + 1, research_cost], current_base_id != BaseNetworkScript.COMMAND_ID, "Raises the maximum tier every deployed Foundry can reach. Upgrade each facility at its console.", _purchase_state(research_cost, {}, current_base_id == BaseNetworkScript.COMMAND_ID))
		else:
			_show_core_action(1, "[MAX] FOUNDRY MK3 RESEARCH", true, "All recipe tiers are unlocked. Upgrade individual facilities in the field.", "MAXIMUM")
		var carried_kits := int(deployable_stock.get("foundry", 0))
		var kit_full := carried_kits >= FOUNDRY_KIT_STOCK_CAP
		_show_core_action(2, "[FABRICATE] FOUNDRY KIT  //  $650 + 2 BRONZE + 4 STONE  //  %d/%d" % [carried_kits, FOUNDRY_KIT_STOCK_CAP], current_base_id != BaseNetworkScript.COMMAND_ID or kit_full, "Creates another 2x2 facility kit for any powered base territory. Each Foundry keeps its own queue and output buffer.", _foundry_kit_fabrication_state() if current_base_id == BaseNetworkScript.COMMAND_ID else _purchase_state(650, _foundry_kit_requirements(), false, "Command Core required"))
	_show_core_action(3, "[SELL] ALL PROCESSED STOCK  //  $%d" % material_economy.refined_sale_value(), material_economy.refined_total() <= 0, "Liquidates every processed component. Keep construction inputs if you intend to fabricate barriers, mines, Rocket Turrets, Laser Turrets, or backpack upgrades.", "READY" if material_economy.refined_total() > 0 else "MISSING PROCESSED STOCK")
	var quick_sale_value: int = material_economy.raw_quick_sale_value()
	_show_core_action(4, "[SELL NOW] ALL RAW CARGO  //  $%d" % quick_sale_value, material_economy.raw_total() <= 0, "Immediately liquidates all raw backpack cargo for 65% of its contract value. Use this when capacity or emergency cash matters more than maximum return.", "READY" if material_economy.raw_total() > 0 else "MISSING RAW CARGO")
	_show_core_action(5, "[INFO] RAW INVENTORY  //  %d UNITS" % material_economy.raw_total(), true, material_economy.raw_manifest(), "PACK INVENTORY")
	_show_core_action(6, "[INFO] PROCESSED INVENTORY  //  %d UNITS" % material_economy.refined_total(), true, material_economy.refined_manifest(), "SPENDABLE SHOP INPUTS")
	var foundry_fuel_room := _foundry_fuel_purchase_room()
	var foundry_fuel_bundle := mini(FOUNDRY_FUEL_BUNDLE, foundry_fuel_room)
	if material_economy.foundry_tier > 0:
		_show_core_action(7, "[BUY] FOUNDRY COAL +%d  //  $%d" % [foundry_fuel_bundle, FOUNDRY_FUEL_BUNDLE_COST] if foundry_fuel_room > 0 else "[OWNED] FOUNDRY COAL FULL", foundry_fuel_room <= 0, "Issues coal into Foundry fuel buffers first. Buffered coal cannot be quick-sold from the field pack.", _purchase_state(FOUNDRY_FUEL_BUNDLE_COST, {}) if foundry_fuel_room > 0 else "OWNED")
	else:
		_show_core_action(7, "[LOCKED] FOUNDRY COAL", true, "Research Foundry MK1 before buying facility fuel.", "LOCKED")
	var wall_counts: Dictionary = _wall_block_counts()
	var wall_total: int = _wall_block_total(wall_counts)
	var recycle_preview: Dictionary = _wall_block_recycle_manifest(wall_counts)
	var wall_detail: String = _wall_block_inventory_detail(wall_counts)
	var recycle_ready: bool = wall_total > 0 and _backpack_free() > 0
	_show_core_action(8, "[RECYCLE] WALL BLOCKS  //  %d CARRIED" % wall_total, not recycle_ready,
		"Crushes carried biome walls back into raw Foundry feedstock. Recycles as much as current material capacity can hold; unprocessed walls stay in inventory.\n\nFULL MANIFEST  %s\n%s" % [_format_material_requirements(recycle_preview), wall_detail],
		"READY" if recycle_ready else ("MISSING: WALL BLOCKS" if wall_total <= 0 else "MISSING: MATERIAL CAPACITY"))
	var wall_sale_value: int = _wall_block_sale_value(wall_counts)
	_show_core_action(9, "[SELL] WALL BLOCKS  //  $%d" % wall_sale_value, wall_total <= 0,
		"Immediately liquidates carried mined-wall blocks instead of placing or recycling them. Biome value varies with the material content.\n\n%s" % wall_detail,
		"READY" if wall_total > 0 else "MISSING: WALL BLOCKS")


func _wall_block_counts() -> Dictionary:
	return operator_loadout.block_counts() if operator_loadout else {}


func _wall_block_total(counts: Dictionary = {}) -> int:
	var source: Dictionary = _wall_block_counts() if counts.is_empty() else counts
	var total: int = 0
	for amount: Variant in source.values():
		total += maxi(0, int(amount))
	return total


func _wall_block_sale_value(counts: Dictionary = {}) -> int:
	var source: Dictionary = _wall_block_counts() if counts.is_empty() else counts
	var payout: int = 0
	for block_id: String in source.keys():
		var biome_id: int = PlaceableBlocksScript.biome_from_block_id(block_id)
		if biome_id < 0:
			continue
		payout += BiomeWallEconomyScript.block_sale_value(biome_id, int(source[block_id]))
	return payout


func _wall_block_recycle_manifest(counts: Dictionary = {}) -> Dictionary:
	var source: Dictionary = _wall_block_counts() if counts.is_empty() else counts
	var combined: Dictionary = {}
	for block_id: String in source.keys():
		var biome_id: int = PlaceableBlocksScript.biome_from_block_id(block_id)
		if biome_id < 0:
			continue
		var manifest: Dictionary = BiomeWallEconomyScript.recycle_manifest(biome_id, int(source[block_id]))
		for material_id: String in manifest.keys():
			combined[material_id] = int(combined.get(material_id, 0)) + int(manifest[material_id])
	return combined


func _wall_block_inventory_detail(counts: Dictionary = {}) -> String:
	var source: Dictionary = _wall_block_counts() if counts.is_empty() else counts
	if source.is_empty():
		return "No mined wall blocks carried."
	var lines: PackedStringArray = []
	for block_id: String in source.keys():
		var biome_id: int = PlaceableBlocksScript.biome_from_block_id(block_id)
		if biome_id < 0:
			continue
		lines.append("%s x%d  //  $%d" % [BiomeWallEconomyScript.biome_label(biome_id), int(source[block_id]), BiomeWallEconomyScript.block_sale_value(biome_id, int(source[block_id]))])
	return "\n".join(lines) if not lines.is_empty() else "No biome wall blocks carried."


func _max_wall_blocks_for_capacity(biome_id: int, available: int, free_units: int) -> int:
	var low: int = 0
	var high: int = maxi(0, available)
	while low < high:
		var mid: int = floori(float(low + high + 1) / 2.0)
		var units: int = BiomeWallEconomyScript.manifest_units(BiomeWallEconomyScript.recycle_manifest(biome_id, mid))
		if units <= free_units:
			low = mid
		else:
			high = mid - 1
	return low


func _recycle_wall_blocks() -> void:
	var counts: Dictionary = _wall_block_counts()
	if counts.is_empty():
		core_base_status.text = "NO WALL BLOCKS TO RECYCLE"
		return
	var free_units: int = _backpack_free()
	if free_units <= 0:
		core_base_status.text = "RECYCLING BLOCKED // MATERIAL PACK FULL"
		return
	var recycled: int = 0
	var recovered: Dictionary = {}
	for block_id: String in counts.keys():
		if free_units <= 0:
			break
		var biome_id: int = PlaceableBlocksScript.biome_from_block_id(block_id)
		if biome_id < 0:
			continue
		var take: int = _max_wall_blocks_for_capacity(biome_id, int(counts[block_id]), free_units)
		if take <= 0:
			continue
		var manifest: Dictionary = BiomeWallEconomyScript.recycle_manifest(biome_id, take)
		if not operator_loadout.consume_kind(OperatorLoadoutScript.KIND_BLOCK, block_id, take):
			continue
		for material_id: String in manifest.keys():
			var amount: int = int(manifest[material_id])
			material_economy.add_raw(material_id, amount)
			recovered[material_id] = int(recovered.get(material_id, 0)) + amount
		var used_units: int = BiomeWallEconomyScript.manifest_units(manifest)
		free_units -= used_units
		recycled += take
	if recycled <= 0:
		core_base_status.text = "RECYCLING BLOCKED // NOT ENOUGH MATERIAL CAPACITY"
		return
	core_base_status.text = "WALL RECOVERY // %d BLOCKS > %s" % [recycled, _format_material_requirements(recovered)]
	discovery_alert = "WALLS RECYCLED // %d BLOCKS" % recycled
	discovery_alert_time = 2.5
	_refresh_core_base_panel()
	_save_run()


func _sell_wall_blocks() -> void:
	var counts: Dictionary = _wall_block_counts()
	var payout: int = _wall_block_sale_value(counts)
	if payout <= 0:
		core_base_status.text = "NO WALL BLOCKS TO SELL"
		return
	var sold: int = 0
	for block_id: String in counts.keys():
		if PlaceableBlocksScript.biome_from_block_id(block_id) < 0:
			continue
		var amount: int = int(counts[block_id])
		if amount > 0 and operator_loadout.consume_kind(OperatorLoadoutScript.KIND_BLOCK, block_id, amount):
			sold += amount
	if sold <= 0:
		core_base_status.text = "WALL SALE FAILED // INVENTORY CHANGED"
		return
	_apply_scrap_delta(payout, "wall_block_sale")
	core_base_status.text = "WALL BLOCKS SOLD // %d BLOCKS // +$%d" % [sold, payout]
	discovery_alert = "WALL SALE // +$%d" % payout
	discovery_alert_time = 2.5
	_refresh_core_base_panel()
	_save_run()


func _refresh_materials_live_status() -> void:
	if not using_core_base or core_menu_page != "materials":
		return
	var foundry_online := _any_foundry_operational()
	var kit_stock := _foundry_stock_available()
	var facility_state := "NOT OWNED"
	if material_economy.foundry_tier > 0:
		facility_state = "%d ONLINE" % _operational_foundry_count() if foundry_online else ("KITS %d" % kit_stock if kit_stock > 0 else "OFFLINE")
	core_base_network_label.text = "PARTS %d  ·  WALL %d  ·  $%d PARTS  ·  FOUNDRY MK%d %s" % [material_economy.refined_total(), operator_loadout.block_total(), material_economy.refined_sale_value(), material_economy.foundry_tier, facility_state]
	if material_economy.contract_active():
		core_service_buttons[0].text = "DEPOSIT CONTRACT REFINERY // %02d SEC // PAYOUT $%d" % [ceili(material_economy.contract_remaining), material_economy.contract_payout]


func _refresh_progress_page() -> void:
	var threshold := _expedition_xp_threshold()
	var progress_detail := "Each expedition level grants 1 Skill Point. Branch nodes unlock at specific levels and may require earlier nodes."
	for node_id in ProgressionTreeScript.progress_node_ids():
		var slot_index := ProgressionTreeScript.action_slot(node_id)
		var record: Dictionary = ProgressionTreeScript.node(node_id)
		var gate := ProgressionTreeScript.can_unlock(node_id, skill_unlocks, skill_points, expedition_level)
		var branch_name := ProgressionTreeScript.branch_label(str(record.get("branch", "")))
		if ProgressionTreeScript.is_unlocked(node_id, skill_unlocks):
			_show_core_action(slot_index, "[OWNED] %s" % record.get("label", node_id), true,
				"%s\n\nBRANCH  %s\nSTATUS  OWNED" % [record.get("detail", ""), branch_name], "OWNED")
		else:
			_show_core_action(slot_index, ProgressionTreeScript.unlock_button_label(node_id), gate != "READY",
				"%s\n\nBRANCH  %s\n%s" % [record.get("detail", ""), branch_name, gate], gate)
	var next_node_id := ProgressionTreeScript.next_tree_node(skill_unlocks)
	var roadmap := "All branch nodes unlocked."
	if not next_node_id.is_empty():
		roadmap = "NEXT NODE  %s  //  %s" % [
			ProgressionTreeScript.unlock_button_label(next_node_id),
			ProgressionTreeScript.can_unlock(next_node_id, skill_unlocks, skill_points, expedition_level),
		]
		var blocked_by_level := ProgressionTreeScript.next_locked_node(expedition_level, skill_unlocks)
		if not blocked_by_level.is_empty() and blocked_by_level != next_node_id:
			roadmap += "\nBLOCKED  %s  //  %s" % [
				ProgressionTreeScript.unlock_button_label(blocked_by_level),
				ProgressionTreeScript.can_unlock(blocked_by_level, skill_unlocks, skill_points, expedition_level),
			]
		roadmap += "\nCHECKPOINT  SLOT 2 LVL 10  //  SLOT 3 LVL 20"
	_show_core_action(5, "[INFO] SKILL POINTS  //  %d BANKED" % skill_points, true,
		"%s\n\nBANKED SP  %d\nLEVEL  %d\nXP  %d / %d\n\n%s\n\nSP unlocks permanent branch nodes and pays tier upgrades.\nXP only levels the expedition and banks more SP." % [
			progress_detail, skill_points, expedition_level, expedition_xp, threshold, roadmap],
		"READY" if skill_points > 0 else "IN PROGRESS")
	_show_core_action(6, "[INFO] PERMANENT MULTIPLIERS", true,
		"WEAPONS x%.2f  //  FORT x%.2f  //  SENTRY x%.2f\nOPERATOR %s" % [
			weapon_damage_multiplier, fortification_multiplier, sentry_damage_multiplier,
			PlayerArmorScript.stat_line(player_style_id)],
		"ACTIVE")
	var branch_lines: PackedStringArray = []
	for branch_id: String in ProgressionTreeScript.BRANCH_ORDER:
		var owned := 0
		for branch_node_id: String in ProgressionTreeScript.nodes_for_branch(branch_id):
			if ProgressionTreeScript.is_unlocked(branch_node_id, skill_unlocks):
				owned += 1
		branch_lines.append("%s  %d/%d" % [ProgressionTreeScript.branch_label(branch_id), owned, ProgressionTreeScript.nodes_for_branch(branch_id).size()])
	_show_core_action(7, "[INFO] BRANCH PROGRESS", true, "\n".join(branch_lines), "ACTIVE")
	_show_core_action(8, "[INFO] EXPEDITION LEVEL MAP", true,
		"LVL 1  OVERCLOCK ARSENAL\nLVL 2  FORTIFY BUNKER + EXCAVATION RIG\nLVL 3  AUTOMATION\nLVL 5  PERSONAL BASE  //  REQUIRES FORTIFY\nLVL 10  CHECKPOINT SLOT 2  //  LVL 20  CHECKPOINT SLOT 3",
		"ACTIVE")


func _merchant_invite_gate() -> String:
	return SettlementProgressionScript.merchant_invite_gate(breached, _opening_contact_complete(), _torch_deployed_count())


func _merchant_store_index() -> int:
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind == BUILD_MERCHANT_STORE and structure.health > 0.0:
			return structure_index
	return -1


func _invite_or_claim_merchant() -> void:
	if current_base_id != BaseNetworkScript.COMMAND_ID:
		return
	if _merchant_store_index() >= 0:
		core_base_status.text = "FIRST SETTLEMENT STORE ALREADY ONLINE"
		_refresh_core_base_panel()
		return
	if not merchant_invited:
		var gate: String = _merchant_invite_gate()
		if gate != "READY":
			core_base_status.text = gate
			_refresh_core_base_panel()
			return
		merchant_invited = true
		construction_unlocks[SettlementProgressionScript.MERCHANT_STORE_STOCK_ID] = true
		core_base_status.text = "VOLUNTEER MERCHANT ACCEPTED // DESCENT PACKAGE INBOUND"
	if kit_count(SettlementProgressionScript.MERCHANT_STORE_STOCK_ID) <= 0 and not merchant_store_kit_issued:
		if grant_kit(SettlementProgressionScript.MERCHANT_STORE_STOCK_ID, 1) > 0:
			core_base_status.text = "MERCHANT READY // CLEAR ONE DEPLOYABLE PACK SLOT TO CLAIM STORE KIT"
		else:
			merchant_store_kit_issued = true
			core_base_status.text = "MERCHANT STORE KIT RECEIVED // PLACE THE 4x3 FIRST SETTLEMENT STORE"
	_refresh_core_base_panel()
	_save_run()


func _refresh_merchant_invite_action() -> void:
	var store_index: int = _merchant_store_index()
	if store_index >= 0:
		_show_core_action(8, "[OWNED] FIRST SETTLEMENT STORE // MERCHANT ONLINE", true,
			"The first volunteer merchant has made the descent. Enter the 4x3 store for supplies. The structure maintains a protected settlement radius against hostile spawning.", "DEPLOYED")
		return
	if merchant_invited:
		if kit_count(SettlementProgressionScript.MERCHANT_STORE_STOCK_ID) > 0:
			_show_core_action(8, "[OWNED] MERCHANT STORE KIT // PLACE 4x3", true,
				"The volunteer is committed. Place the store on active prepared ground to establish the first civilian foothold underground.", "OWNED")
		elif merchant_store_kit_issued:
			_show_core_action(8, "[INFO] MERCHANT STORE DEPLOYMENT PENDING", true,
				"The descent package was issued. Recover or place the Merchant Store kit to complete the first settlement.", "ACTIVE")
		else:
			_show_core_action(8, "[ACTION] CLAIM MERCHANT STORE KIT", false, SettlementProgressionScript.merchant_store_detail(), "READY")
		return
	var gate: String = _merchant_invite_gate()
	var detail: String = SettlementProgressionScript.merchant_store_detail() + "\n\nNo settlement has held. One prior survivor established contact, then disappeared and is presumed dead. The volunteer will not descend until the landing pocket proves it can survive contact and maintain field lighting."
	_show_core_action(8, "[ACTION] INVITE VOLUNTEER MERCHANT" if gate == "READY" else "[LOCKED] INVITE VOLUNTEER MERCHANT // %s" % gate, gate != "READY", detail, gate)


func _refresh_merchant_store_panel(focused_slot: int) -> void:
	core_menu_page = "supplies"
	_update_scrap_label()
	core_base_title.text = "VOLUNTEER MERCHANT  ·  FIRST SETTLEMENT"
	core_base_network_label.text = "SAFE INTERIOR  ·  PROTECTED RADIUS %d CELLS  ·  OUTSIDE HOSTILES PAUSED WHILE INSIDE" % roundi(SettlementProgressionScript.MERCHANT_STORE_SAFE_RADIUS_CELLS)
	core_base_network_label.add_theme_color_override("font_color", Color("8eeaff"))
	core_base_status.text = "SETTLEMENT SUPPLIES // FIRST CIVILIAN FOOTHOLD"
	for department_id: String in SHOP_DEPARTMENT_ORDER:
		var department_button: Button = core_department_buttons[department_id]
		department_button.add_theme_color_override("font_color", Color("547880"))
		department_button.add_theme_color_override("icon_normal_color", Color("547880"))
	for tab_id: String in core_tab_buttons.keys():
		var tab: Button = core_tab_buttons[tab_id]
		tab.visible = tab_id == "supplies"
		if tab_id == "supplies":
			tab.text = "SUPPLIES"
			tab.add_theme_color_override("font_color", Color("8eeaff"))
	for button: Button in core_service_buttons:
		button.visible = false
		button.disabled = false
	for detail_index in range(core_action_details.size()):
		core_action_details[detail_index] = ""
		core_action_states[detail_index] = ""
	_refresh_supplies_page(base_network.get_base(current_base_id))
	var detail_slot := _repair_core_focus(focused_slot) if focused_slot >= 0 else 0
	_show_core_action_detail(detail_slot)


func _refresh_base_page(record: Dictionary, is_command: bool) -> void:
	var base_tier: int = int(record["tier"])
	var level_gate: int = 4 if base_tier == 1 else 8
	var sp_cost: int = ProgressionTreeScript.frontier_core_upgrade_sp(base_tier)
	var base_req: Dictionary = _base_material_requirements(base_tier)
	var can_upgrade := not is_command and base_tier < 3 and expedition_level >= level_gate
	_show_core_action(0, "[SP %d] CORE MK%d > MK%d  //  %s" % [sp_cost, base_tier, base_tier + 1, _format_material_requirements(base_req)] if base_tier < 3 else "[MAX] CORE MK3", base_tier >= 3 or _sp_action_disabled(sp_cost, base_req, can_upgrade, "Requires Frontier Core and Expedition Level %d" % level_gate), _base_upgrade_detail(record, base_tier), "MAXIMUM" if base_tier >= 3 else _sp_purchase_state(sp_cost, base_req, can_upgrade, "Requires Frontier Core and Expedition Level %d" % level_gate))
	var repair_cost: int = _repair_cost()
	_show_core_action(1, "[BUY] REPAIR LOCAL NETWORK  //  $%d" % repair_cost if repair_cost > 0 else "[OWNED] NETWORK AT FULL CONDITION", repair_cost <= 0, "Fully restores this Core and every defense assigned to it.", _purchase_state(repair_cost, {}) if repair_cost > 0 else "OWNED")
	if not is_command:
		_show_core_action(2, "[INFO] FRONTIER CORE  //  $1000", true, "Frontier Cores are constructed at cleared Core Sites after four surveyed sectors and the site guardian are complete.", "WORLD SITE REQUIRED")
	_show_core_action(2 if is_command else 3, "[INFO] POWER RADIUS  //  %d CELLS" % base_network.territory_radius(current_base_id), true, "Turrets inside this radius operate at full rate and can be targeted for local upgrades and repairs.", "ACTIVE")
	if not is_command:
		var service_state := _regional_service_state(record)
		_show_core_action(4, _regional_service_label(str(record["kind"])), service_state == "MAXIMUM", _regional_service_detail(record), service_state)
	var personal_base_index := _personal_base_index_for_base(current_base_id)
	if personal_base_index >= 0:
		var shelter: Structure = structures[personal_base_index]
		var tier := ShelterUnitScript.clamp_tier(shelter.level)
		var anchored_here := checkpoint_exists and checkpoint_base_id == current_base_id
		if tier < 3:
			var next_tier := tier + 1
			var shelter_sp := ProgressionTreeScript.personal_base_upgrade_sp(tier)
			var shelter_upgrade_req := ShelterUnitScript.upgrade_requirements(tier)
			var shelter_state := _sp_purchase_state(shelter_sp, shelter_upgrade_req)
			_show_core_action(5, "[SP %d] PERSONAL BASE MK%d > MK%d  //  %s" % [shelter_sp, tier, next_tier, _format_material_requirements(shelter_upgrade_req)], _sp_action_disabled(shelter_sp, shelter_upgrade_req),
				"Press F at the hut for free recovery.\nMK%d: %.0f HP/s, %.1fs rest.%s\nCOST       %d SP + %s" % [
					next_tier, ShelterUnitScript.heal_rate(next_tier), ShelterUnitScript.rest_duration(next_tier),
					" // ACTIVE ANCHOR" if anchored_here else "",
					shelter_sp, _format_material_requirements(shelter_upgrade_req)],
				shelter_state)
		else:
			_show_core_action(5, "[MAX] PERSONAL BASE MK3", true,
				"Press F at the hut for free recovery.\n%.0f HP/s // %.1fs rest.%s" % [
					ShelterUnitScript.heal_rate(3), ShelterUnitScript.rest_duration(3),
					" ACTIVE ANCHOR" if anchored_here else ""], "MAXIMUM")
	elif not ProgressionTreeScript.is_unlocked("personal_base", skill_unlocks):
		var blueprint_gate := ProgressionTreeScript.can_unlock("personal_base", skill_unlocks, skill_points, expedition_level)
		_show_core_action(5, "[SP %d] UNLOCK PERSONAL BASE BLUEPRINT" % ProgressionTreeScript.sp_cost("personal_base"), blueprint_gate != "READY",
			"Spend a Skill Point from expedition levels to unlock Personal Base fabrication here.\n\n%s" % str(ProgressionTreeScript.node("personal_base").get("detail", "")), blueprint_gate)
	elif int(deployable_stock.get("personal_base", 0)) > 0:
		_show_core_action(5, "[OWNED] PERSONAL BASE KIT  //  READY TO PLACE", true,
			"Enter build mode and deploy it on any active prepared ground. Resting heals and saves; field huts do not provide shops.", "OWNED")
	else:
		var requirements := {MaterialEconomyScript.STONE_BLOCK: 2, MaterialEconomyScript.BRONZE_INGOT: 1}
		var kit_cost := ProgressionTreeScript.personal_base_kit_scrap_cost()
		var kit_room: bool = _can_accept_kit("personal_base")
		var kit_state := _purchase_state(kit_cost, requirements, kit_room, "Requires one free deployable stack slot")
		_show_core_action(5, "[CRAFT] PERSONAL BASE KIT  //  $%d + %s" % [kit_cost, _format_material_requirements(requirements)], kit_state != "READY",
			"Fabricates one 3x2 shelter kit. Deployables use inventory slots; they do not consume raw-material capacity.\nCOST       $%d + %s" % [kit_cost, _format_material_requirements(requirements)], kit_state)
	var component_count := boss_components_deposited.size()
	if component_count < APEX_COMPONENTS.size():
		_show_core_action(6, "[LOCKED] MECHA SPIDER RESEARCH  //  %d/5 COMPONENTS" % component_count, true, "Defeat the Final Five and return their unique components to an active Core.", "MISSING APEX COMPONENTS")
	else:
		var next_tier := mini(3, mecha_level + 1)
		_show_core_action(6, "[RESEARCH] MECHA SPIDERS MK%d  //  $%d" % [next_tier, MECHA_COSTS[next_tier]] if mecha_level == 0 else "[OWNED] MECHA SPIDERS MK%d" % mecha_level, mecha_level > 0, "Reverse-engineered friendly hunters automatically seek hostile nests.", _purchase_state(MECHA_COSTS[next_tier], {}) if mecha_level == 0 else "DEPLOYED")
	if mecha_level > 0 and mecha_level < 3:
		_show_core_action(7, "[BUY] MECHA SPIDERS MK%d > MK%d  //  $%d" % [mecha_level, mecha_level + 1, MECHA_COSTS[mecha_level + 1]], false, "Adds another hunter and improves speed, damage, armor, and nest pressure.", _purchase_state(MECHA_COSTS[mecha_level + 1], {}))
	elif mecha_level >= 3:
		_show_core_action(7, "[MAX] MECHA SPIDERS MK3  //  ULTIMATE POWER", true, "Three elite autonomous nest hunters are active.", "MAXIMUM")
	if is_command:
		_refresh_merchant_invite_action()
	else:
		_show_core_action(8, "[INFO] UNDERGROUND SETTLEMENT NETWORK", true, "This Frontier Core supports the expanding underground foothold. Surface excavation remains locked behind the future Final Five campaign technology.", "ACTIVE")


func _refresh_style_page() -> void:
	for style_index in range(PLAYER_STYLE_NAMES.size()):
		var style_name := PLAYER_STYLE_NAMES[style_index]
		var armor_stats := PlayerArmorScript.stat_line(style_index)
		if unlocked_player_styles[style_index]:
			if player_style_id == style_index:
				_show_core_action(style_index, "[EQUIPPED] %s" % style_name, true,
					"%s is active.\n%s\nHitbox and movement stay unchanged." % [_style_description(style_index), armor_stats], "EQUIPPED")
			else:
				_show_core_action(style_index, "[EQUIP] %s  //  NO COST" % style_name, false,
					"Switch to %s.\nWhen equipped: %s" % [_style_description(style_index), armor_stats], "READY")
			continue
		var cost := _style_unlock_cost(style_index)
		var requirements := _style_unlock_requirements(style_index)
		_show_core_action(style_index, "[UNLOCK] %s  //  $%d + %s" % [style_name, cost, _format_material_requirements(requirements)], false,
			"%s\n%s tier armor.\nWhen equipped: %s\nCOST       $%d + %s" % [
				_style_description(style_index), PlayerArmorScript.tier_label(style_index), armor_stats, cost, _format_material_requirements(requirements)],
			_purchase_state(cost, requirements))
	_show_core_action(4, "[INFO] ACTIVE LOOK  //  %s" % PLAYER_STYLE_NAMES[player_style_id], true,
		"Equipped armor sets operator strength and incoming damage reduction.\n%s" % PlayerArmorScript.stat_line(player_style_id), "EQUIPPED")
	if backpack_tier >= 4:
		_show_core_action(5, "[MAX] EXPEDITION HAULER  //  %d CAPACITY" % _backpack_capacity(), true, "Maximum backpack installed. Current load: %d/%d capacity points." % [_backpack_used(), _backpack_capacity()], "MAXIMUM")
	else:
		var pack_cost: int = BACKPACK_COSTS[backpack_tier]
		var pack_requirements: Dictionary = _backpack_upgrade_requirements(backpack_tier)
		_show_core_action(5, "[BUY] BACKPACK MK%d > MK%d  //  $%d" % [backpack_tier, backpack_tier + 1, pack_cost], false, "Expands raw-material and processed-component capacity from %d to %d. Deployable kits and mined wall blocks use stack slots instead. Ammunition uses dedicated weapon reserves.\nCOST       $%d + %s" % [_backpack_capacity(), _backpack_capacity(backpack_tier + 1), pack_cost, _format_material_requirements(pack_requirements)], _purchase_state(pack_cost, pack_requirements))
	_show_core_action(6, "[INFO] PACK LOAD  //  %d / %d" % [_backpack_used(), _backpack_capacity()], true,
		"RAW + PARTS %d  //  DEPLOYABLE KITS %d  //  WALL BLOCKS %d\nFree material capacity: %d\nAmmo is stored directly in weapon reserves (not in pack)." % [
			material_economy.inventory_units(), _deployable_stock_total(), operator_loadout.block_total(), _backpack_free()],
		"%d FREE" % _backpack_free())


func _deposit_apex_components() -> void:
	if boss_components_carried.is_empty():
		return
	for component: String in boss_components_carried.keys():
		boss_components_deposited[component] = true
	boss_components_carried.clear()
	discovery_alert = "APEX COMPONENTS SECURED // %d/5" % boss_components_deposited.size()
	discovery_alert_time = 4.0


func _purchase_mecha_upgrade() -> void:
	if boss_components_deposited.size() < APEX_COMPONENTS.size() or mecha_level >= 3:
		return
	var next_level := mecha_level + 1
	if not _spend_scrap(MECHA_COSTS[next_level]):
		core_base_status.text = "MECHA RESEARCH REQUIRES $%d" % MECHA_COSTS[next_level]
		return
	mecha_level = next_level
	_sync_mecha_squad()
	core_base_status.text = "MECHA SPIDERS MK%d ONLINE // %d HUNTERS // SURFACE EXCAVATION REMAINS LOCKED" % [mecha_level, mecha_spiders.size()]
	_refresh_core_base_panel()


func _sync_mecha_squad() -> void:
	while mecha_spiders.size() < mecha_level:
		var spider := Spider.new()
		spider.role = ROLE_GUARDIAN if mecha_level >= 3 else ROLE_BRUTE
		spider.big = true
		spider.radius = 10.0 + float(mecha_level)
		spider.max_health = 700.0 + float(mecha_level) * 500.0
		spider.health = spider.max_health
		spider.speed = 32.0 + float(mecha_level) * 6.0
		spider.position = grid.cell_to_world(grid.core_cell) + Vector2(float(mecha_spiders.size() * 12 - 12), 18.0)
		mecha_spiders.append(spider)
	while mecha_spiders.size() > mecha_level:
		mecha_spiders.pop_back()


func _spawn_surface_portal() -> void:
	if surface_portal_cell.x >= 0:
		return
	var candidates: Array[Vector2i] = []
	for y in range(2, grid.height - 2):
		for x in range(2, grid.width - 2):
			var candidate := Vector2i(x, y)
			if grid.is_walkable(candidate) and candidate.distance_to(grid.core_cell) >= 70.0:
				candidates.append(candidate)
	if candidates.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = int(run_seed) ^ 0x5FACE
	surface_portal_cell = candidates[rng.randi_range(0, candidates.size() - 1)]
	discovery_alert = "SURFACE ANOMALY LOCATED // PORTAL MARKED"
	discovery_alert_time = 7.0
	_invalidate_minimap()


func _backpack_upgrade_requirements(current_tier: int) -> Dictionary:
	match current_tier:
		1:
			return {MaterialEconomyScript.STONE_BLOCK: 4, MaterialEconomyScript.STEEL_PLATE: 1}
		2:
			return {MaterialEconomyScript.REINFORCED_BLOCK: 5, MaterialEconomyScript.STEEL_PLATE: 3, MaterialEconomyScript.TITANIUM_PLATE: 1}
		_:
			return {MaterialEconomyScript.REINFORCED_BLOCK: 6, MaterialEconomyScript.TITANIUM_PLATE: 5, MaterialEconomyScript.OPTIC_CORE: 2, MaterialEconomyScript.CUT_DIAMOND: 1}


func _purchase_backpack_upgrade() -> void:
	if backpack_tier >= 4:
		return
	var cost: int = BACKPACK_COSTS[backpack_tier]
	var requirements: Dictionary = _backpack_upgrade_requirements(backpack_tier)
	if not _spend_purchase(cost, requirements):
		return
	backpack_tier += 1
	if operator_loadout:
		operator_loadout.set_pack_tier(backpack_tier)
	core_base_status.text = "BACKPACK MK%d INSTALLED // CAPACITY %d" % [backpack_tier, _backpack_capacity()]
	_refresh_core_base_panel()
	_save_run()


func _style_unlock_cost(style_index: int) -> int:
	return [0, 250, 500, 1200][clampi(style_index, 0, 3)]


func _style_unlock_requirements(style_index: int) -> Dictionary:
	match style_index:
		1:
			return {MaterialEconomyScript.BRONZE_INGOT: 1}
		2:
			return {MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
		3:
			return {MaterialEconomyScript.GOLD_INGOT: 2, MaterialEconomyScript.CUT_DIAMOND: 1}
	return {}


func _style_description(style_index: int) -> String:
	return [
		"Cyan expedition armor for the original survey team.",
		"Orange industrial armor built around Foundry crews.",
		"Violet sealed armor used by Hive Containment operators.",
		"White-and-gold veteran armor for deep-realm commanders.",
	][clampi(style_index, 0, 3)]


func _purchase_or_equip_style(style_index: int) -> void:
	if style_index < 0 or style_index >= PLAYER_STYLE_NAMES.size():
		return
	if unlocked_player_styles[style_index]:
		player_style_id = style_index
		_rebuild_player_armor_multipliers()
		core_base_status.text = "%s EQUIPPED // %s" % [PLAYER_STYLE_NAMES[style_index], PlayerArmorScript.stat_line(style_index)]
		_refresh_core_base_panel()
		_save_run()
		return
	if not _spend_purchase(_style_unlock_cost(style_index), _style_unlock_requirements(style_index)):
		return
	unlocked_player_styles[style_index] = true
	player_style_id = style_index
	_rebuild_player_armor_multipliers()
	core_base_status.text = "%s UNLOCKED AND EQUIPPED // %s" % [PLAYER_STYLE_NAMES[style_index], PlayerArmorScript.stat_line(style_index)]
	_refresh_core_base_panel()
	_save_run()


func _base_upgrade_detail(record: Dictionary, current_tier: int) -> String:
	if current_tier >= 3:
		return "This Frontier Core has maximum 325 condition and a 16-cell powered territory radius."
	var current_health := int(record["max_health"])
	var next_health: int = int([150, 225, 325][current_tier])
	var current_radius: int = int([10, 13, 16][current_tier - 1])
	var next_radius: int = int([10, 13, 16][current_tier])
	var level_gate := 4 if current_tier == 1 else 8
	var sp_cost := ProgressionTreeScript.frontier_core_upgrade_sp(current_tier)
	var base_req := _base_material_requirements(current_tier)
	return "CURRENT  %d CORE HP | %d-CELL POWER\nNEXT       %d CORE HP | %d-CELL POWER\nGATE       EXPEDITION LVL %d\nCOST       %d SP + %s" % [
		current_health, current_radius, next_health, next_radius, level_gate, sp_cost, _format_material_requirements(base_req)]


func _regional_service_state(record: Dictionary) -> String:
	var kind: String = str(record["kind"])
	if kind == "foundry" and int(record.get("specialty_level", 0)) >= 3:
		return "MAXIMUM"
	if kind == "research" and railgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_RAILGUN] and laser_energy >= 99.9:
		return "MAXIMUM"
	if kind == "containment" and shotgun_reserve >= AMMO_RESERVE_CAPS[WEAPON_SHOTGUN] and (not unlocked_weapons[WEAPON_SMG] or smg_reserve >= AMMO_RESERVE_CAPS[WEAPON_SMG]):
		return "MAXIMUM"
	return _purchase_state(45 if str(record["kind"]) == "foundry" else 35, {})


func _regional_service_detail(record: Dictionary) -> String:
	match str(record["kind"]):
		"research":
			return "Immediately restores Laser charge to 100% and adds 5 Railgun slugs. Repeatable."
		"foundry":
			return "Adds 12%% maximum condition to every local defense and fully repairs them. Three installations maximum. Current installation: %d/3." % int(record.get("specialty_level", 0))
		_:
			return "Adds 90 SMG rounds and 18 Shotgun shells for anti-swarm defense. Repeatable."


func _regional_service_label(kind: String) -> String:
	match kind:
		"research":
			return "CRYSTAL CALIBRATION // +RAIL +LASER // $35"
		"foundry":
			return "FOUNDRY ARMOR SERVICE // FORTIFY LOCAL TURRETS // $45"
		_:
			return "CONTAINMENT LOADOUT // +SMG +SHOTGUN // $35"


func _storage_deployable_focus_id() -> String:
	var idx := storage_upgrade_focus_index
	for offset in range(DEPLOYABLE_STORAGE_ORDER.size()):
		var cid: String = DEPLOYABLE_STORAGE_ORDER[posmod(idx + offset, DEPLOYABLE_STORAGE_ORDER.size())]
		if bool(construction_unlocks.get(cid, false)) and int(deployable_storage_tiers.get(cid, 0)) < 2:
			return cid
	return ""


func _deployable_storage_upgrade_cost(current_tier: int) -> int:
	return [65, 120][clampi(current_tier, 0, 1)]


func _deployable_storage_upgrade_requirements(current_tier: int) -> Dictionary:
	if current_tier <= 0:
		return {MaterialEconomyScript.BRONZE_INGOT: 1}
	return {MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}


func _weapon_name(weapon_id: int) -> String:
	return ["PISTOL", "SHOTGUN", "LASER", "SMG", "RAILGUN", "FLAMETHROWER"][weapon_id]


func _armory_mag_focus_weapon() -> int:
	# Returns the weapon_id that the mag upgrade slot 6 should show, skipping LASER.
	# Stores the last focus in armory_mag_weapon_index.
	var idx := armory_mag_weapon_index
	# Find next upgradable unlocked non-laser weapon starting from current index
	for offset in range(WEAPON_COUNT):
		var wid: int = (idx + offset) % WEAPON_COUNT
		if wid in [WEAPON_LASER, WEAPON_FLAMETHROWER]:
			continue
		if unlocked_weapons[wid] and mag_upgrade_tiers[wid] < 4:
			return wid
	return -1  # All maxed


func _weapon_upgrade_detail(weapon_id: int, tier: int, footer: String = "") -> String:
	var detail := "%s\n\nCURRENT  %s\nNEXT       %s" % [_weapon_role(weapon_id), _weapon_stat_summary(weapon_id, tier), _weapon_stat_summary(weapon_id, tier + 1)]
	if not footer.is_empty():
		detail += "\n\n" + footer
	return detail


func _weapon_role(weapon_id: int) -> String:
	return [
		"Reliable sidearm // accurate sustained fire",
		"Close-range sweeper // multi-pellet burst",
		"Continuous energy beam // no physical ammunition",
		"High-rate crowd control // improved accuracy by tier",
		"Heavy precision weapon // piercing anti-armor slug",
		"Short-range area denial // lingering self-hazard",
	][weapon_id]


func _weapon_stat_summary(weapon_id: int, tier: int) -> String:
	var damage_percent := 100 + (tier - 1) * 22
	match weapon_id:
		WEAPON_PISTOL:
			return "%d%% DMG | %d MAG | %.2fs FIRE | %.2fs RELOAD" % [damage_percent, _weapon_mag_capacity(weapon_id, tier), _weapon_fire_interval(weapon_id, tier), _weapon_reload_duration(weapon_id, tier)]
		WEAPON_SHOTGUN:
			return "%d%% DMG | %d PELLETS | %d MAG | %.2fs RELOAD" % [damage_percent, _weapon_shotgun_pellets(tier), _weapon_mag_capacity(weapon_id, tier), _weapon_reload_duration(weapon_id, tier)]
		WEAPON_LASER:
			return "%d%% DMG | %.1f ENERGY/sec | 176 RANGE" % [damage_percent, _weapon_laser_drain(tier)]
		WEAPON_SMG:
			return "%d%% DMG | %d MAG | %.3fs FIRE | %.3f SPREAD" % [damage_percent, _weapon_mag_capacity(weapon_id, tier), _weapon_fire_interval(weapon_id, tier), _weapon_smg_spread(tier)]
		WEAPON_RAILGUN:
			return "%d%% DMG | %d MAG | %d TARGET PIERCE | %.2fs RELOAD" % [damage_percent, _weapon_mag_capacity(weapon_id, tier), _weapon_railgun_pierce(tier), _weapon_reload_duration(weapon_id, tier)]
		WEAPON_FLAMETHROWER:
			return "%d%% DMG | %d FUEL | %d RANGE | FIRE PATCH" % [damage_percent, flame_fuel, FLAMETHROWER_DIRECT_RANGE]
	return ""


func _weapon_material_requirements(weapon_id: int, current_tier: int) -> Dictionary:
	if current_tier <= 1:
		return {MaterialEconomyScript.CRYSTAL_CORE: 1} if weapon_id == WEAPON_LASER else {MaterialEconomyScript.BRONZE_INGOT: 1}
	if current_tier == 2:
		return {MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1} if weapon_id in [WEAPON_LASER, WEAPON_RAILGUN] else {MaterialEconomyScript.SILVER_INGOT: 1}
	return {MaterialEconomyScript.GOLD_INGOT: 1, MaterialEconomyScript.CUT_DIAMOND: 1}


func _turret_material_requirements(current_tier: int) -> Dictionary:
	return UpgradeEconomyScript.turret_material_requirements(current_tier)


func _base_material_requirements(current_tier: int) -> Dictionary:
	return UpgradeEconomyScript.frontier_core_material_requirements(current_tier)


func _format_material_requirements(requirements: Dictionary) -> String:
	if requirements.is_empty():
		return "NO COMPONENTS"
	var parts: PackedStringArray = []
	for material_id: String in requirements.keys():
		parts.append("%d %s" % [int(requirements[material_id]), _material_name(material_id)])
	return " + ".join(parts)


func _purchase_state(cost: int, requirements: Dictionary, gate_open: bool = true, locked_reason: String = "") -> String:
	if not gate_open:
		return "LOCKED" if locked_reason.is_empty() else "LOCKED: %s" % locked_reason
	var missing: PackedStringArray = []
	if scrap < cost:
		missing.append("$%d" % (cost - scrap))
	for material_id: String in requirements.keys():
		var shortage: int = int(requirements[material_id]) - int(material_economy.refined.get(material_id, 0))
		if shortage > 0:
			missing.append("%d %s" % [shortage, _material_name(material_id)])
	return "READY" if missing.is_empty() else "MISSING: %s" % " + ".join(missing)


func _material_purchase_state(requirements: Dictionary, category: String = "") -> String:
	var gate_open := category.is_empty() or ProgressionTreeScript.permanent_upgrade_unlocked(category, skill_unlocks)
	var locked_reason := "" if gate_open else ProgressionTreeScript.permanent_gate_reason(category)
	return _purchase_state(0, requirements, gate_open, locked_reason)


func _spend_material_purchase(requirements: Dictionary) -> bool:
	var purchase_state := _purchase_state(0, requirements)
	if purchase_state != "READY":
		core_base_status.text = "PURCHASE BLOCKED // %s" % purchase_state
		return false
	if requirements.is_empty():
		return true
	if not material_economy.spend_refined(requirements):
		core_base_status.text = "PURCHASE BLOCKED // MATERIAL INVENTORY CHANGED"
		return false
	return true


func _mag_upgrade_requirements(current_tier: int) -> Dictionary:
	return {MaterialEconomyScript.BRONZE_INGOT: clampi(current_tier, 1, 3)}


func _foundry_kit_requirements() -> Dictionary:
	return {MaterialEconomyScript.BRONZE_INGOT: 2, MaterialEconomyScript.STONE_BLOCK: 4}


func _foundry_kit_fabrication_state() -> String:
	var stock := kit_count("foundry")
	if stock >= FOUNDRY_KIT_STOCK_CAP:
		return "FULL (%d/%d)" % [stock, FOUNDRY_KIT_STOCK_CAP]
	return _deployable_craft_state("foundry", 650, _foundry_kit_requirements())


func _deployable_craft_state(stock_id: String, cost: int, requirements: Dictionary) -> String:
	var purchase_state: String = _purchase_state(cost, requirements)
	if purchase_state != "READY":
		return purchase_state
	## Preview must be pure: older probe/rollback logic could consume an existing
	## kit when the inventory was full. Kits use slots, not material weight.
	var probe: Dictionary = OperatorLoadoutScript.make_stack(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id, 1)
	return "READY" if operator_loadout.can_accept_stack(probe, 1) else "MISSING: FREE SLOT"


func _material_name(material_id: String) -> String:
	var names := {
		MaterialEconomyScript.COPPER_ORE: "COPPER",
		MaterialEconomyScript.SILVER_ORE: "SILVER",
		MaterialEconomyScript.GOLD_ORE: "GOLD",
		MaterialEconomyScript.ENERGY_CRYSTAL: "CRYSTAL",
		MaterialEconomyScript.ROUGH_DIAMOND: "DIAMOND",
		MaterialEconomyScript.BRONZE_INGOT: "BRONZE",
		MaterialEconomyScript.SILVER_INGOT: "SILVER BAR",
		MaterialEconomyScript.GOLD_INGOT: "GOLD BAR",
		MaterialEconomyScript.CRYSTAL_CORE: "CRYSTAL CORE",
		MaterialEconomyScript.CUT_DIAMOND: "CUT DIAMOND",
		MaterialEconomyScript.GRANITE: "GRANITE",
		MaterialEconomyScript.BASALT: "BASALT",
		MaterialEconomyScript.QUARTZ: "QUARTZ",
		MaterialEconomyScript.IRON_ORE: "IRON ORE",
		MaterialEconomyScript.TITANIUM_ORE: "TITANIUM ORE",
		MaterialEconomyScript.SULFUR: "SULFUR",
		MaterialEconomyScript.COAL: "COAL",
		MaterialEconomyScript.STONE_BLOCK: "STONE BLOCK",
		MaterialEconomyScript.REINFORCED_BLOCK: "REINFORCED BLOCK",
		MaterialEconomyScript.STEEL_PLATE: "STEEL PLATE",
		MaterialEconomyScript.TITANIUM_PLATE: "TITANIUM PLATE",
		MaterialEconomyScript.EXPLOSIVE_COMPOUND: "EXPLOSIVE COMPOUND",
		MaterialEconomyScript.OPTIC_CORE: "OPTIC CORE",
	}
	return str(names.get(material_id, material_id.to_upper()))


func _sp_purchase_state(sp_cost: int, requirements: Dictionary, gate_open: bool = true, locked_reason: String = "") -> String:
	if not gate_open:
		return "LOCKED" if locked_reason.is_empty() else "LOCKED: %s" % locked_reason
	var missing: PackedStringArray = []
	if skill_points < sp_cost:
		missing.append("%d SP" % (sp_cost - skill_points))
	for material_id: String in requirements.keys():
		var shortage: int = int(requirements[material_id]) - int(material_economy.refined.get(material_id, 0))
		if shortage > 0:
			missing.append("%d %s" % [shortage, _material_name(material_id)])
	return "READY" if missing.is_empty() else "MISSING: %s" % " + ".join(missing)


func _sp_action_disabled(sp_cost: int, requirements: Dictionary = {}, gate_open: bool = true, locked_reason: String = "") -> bool:
	return _sp_purchase_state(sp_cost, requirements, gate_open, locked_reason) != "READY"


func _spend_sp_purchase(sp_cost: int, requirements: Dictionary) -> bool:
	var purchase_state: String = _sp_purchase_state(sp_cost, requirements)
	if purchase_state != "READY":
		core_base_status.text = "UPGRADE BLOCKED // %s" % purchase_state
		return false
	var sp_before: int = skill_points
	skill_points -= sp_cost
	if not material_economy.spend_refined(requirements):
		skill_points = sp_before
		core_base_status.text = "UPGRADE ROLLED BACK // MATERIAL INVENTORY CHANGED"
		return false
	hud_sp_pulse = 1.0
	_push_comms_alert("SPENT %d SP // TIER UPGRADE" % sp_cost, 4.0)
	_refresh_expedition_xp_meter()
	if using_core_base:
		_refresh_core_base_panel()
	var burst_cell: Vector2i = base_network.get_cell(current_base_id) if is_instance_valid(base_network) else grid.core_cell
	_burst(grid.cell_to_world(burst_cell), Color("a7eefa"), 12, 48.0)
	return true


func _spend_purchase(cost: int, requirements: Dictionary) -> bool:
	var purchase_state: String = _purchase_state(cost, requirements)
	if purchase_state != "READY":
		core_base_status.text = "PURCHASE BLOCKED // %s" % purchase_state
		return false
	var credits_before: int = scrap
	if not _spend_scrap(cost):
		return false
	if not material_economy.spend_refined(requirements):
		_set_scrap(credits_before, "purchase_rollback")
		core_base_status.text = "PURCHASE ROLLED BACK // MATERIAL INVENTORY CHANGED"
		return false
	return true


func _purchase_weapon_upgrade() -> void:
	_purchase_weapon_upgrade_for(current_weapon)


func _purchase_weapon_upgrade_for(weapon_id: int) -> void:
	if weapon_id < 0 or weapon_id >= WEAPON_COUNT or not unlocked_weapons[weapon_id]:
		core_base_status.text = "WEAPON RESEARCH REQUIRED"
		return
	if not ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_ARSENAL, skill_unlocks):
		core_base_status.text = ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.BRANCH_ARSENAL)
		return
	if current_base_id != BaseNetworkScript.COMMAND_ID:
		var terminal_kind: String = str(base_network.get_base(current_base_id).get("kind", ""))
		if terminal_kind == "containment" and weapon_id == WEAPON_RAILGUN:
			core_base_status.text = "RAILGUN CALIBRATION UNAVAILABLE AT CONTAINMENT POST"
			return
	var tier: int = weapon_tiers[weapon_id]
	if tier >= 4:
		return
	var requirements: Dictionary = _weapon_material_requirements(weapon_id, tier)
	if not _spend_material_purchase(requirements):
		return
	var old_capacity := _weapon_mag_capacity(weapon_id, tier)
	weapon_tiers[weapon_id] += 1
	var capacity_gain := _weapon_mag_capacity(weapon_id) - old_capacity
	if capacity_gain > 0:
		match weapon_id:
			WEAPON_PISTOL:
				magazine += capacity_gain
			WEAPON_SHOTGUN:
				shotgun_magazine += capacity_gain
			WEAPON_SMG:
				smg_magazine += capacity_gain
			WEAPON_RAILGUN:
				railgun_magazine += capacity_gain
	core_base_status.text = "%s ADVANCED TO MK %d" % [_weapon_name(weapon_id), weapon_tiers[weapon_id]]
	_refresh_core_base_panel()
	_save_run()


func _purchase_weapon_unlock() -> void:
	if current_base_id != BaseNetworkScript.COMMAND_ID:
		_purchase_regional_service()
		return
	if not ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_ARSENAL, skill_unlocks):
		core_base_status.text = ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.BRANCH_ARSENAL)
		return
	var weapon_id: int = WEAPON_SMG
	var requirements: Dictionary = {MaterialEconomyScript.BRONZE_INGOT: 1}
	if unlocked_weapons[WEAPON_SMG]:
		weapon_id = WEAPON_RAILGUN
		requirements = {MaterialEconomyScript.SILVER_INGOT: 1, MaterialEconomyScript.CRYSTAL_CORE: 1}
	if unlocked_weapons[WEAPON_RAILGUN]:
		weapon_id = WEAPON_FLAMETHROWER
		requirements = FLAMETHROWER_UNLOCK_REQUIREMENTS.duplicate()
	if unlocked_weapons[weapon_id] or not _spend_material_purchase(requirements):
		return
	unlocked_weapons[weapon_id] = true
	if weapon_id == WEAPON_FLAMETHROWER:
		flamethrower_unlocked = true
		flame_fuel = FLAMETHROWER_FUEL_BUNDLE
	_equip_unlocked_weapon(weapon_id)
	core_base_status.text = "%s UNLOCKED" % _weapon_name(weapon_id)
	_refresh_core_base_panel()
	_save_run()


func _purchase_mag_upgrade() -> void:
	if not ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_ARSENAL, skill_unlocks):
		core_base_status.text = ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.BRANCH_ARSENAL)
		return
	var wid := _armory_mag_focus_weapon()
	if wid < 0:
		core_base_status.text = "ALL WEAPONS ALREADY AT MAX MAGAZINE CAPACITY"
		return
	if not unlocked_weapons[wid]:
		core_base_status.text = "UNLOCK %s FIRST BEFORE UPGRADING MAGAZINE" % _weapon_name(wid)
		return
	var current_mag_tier: int = mag_upgrade_tiers[wid]
	if current_mag_tier >= 4:
		core_base_status.text = "%s EXTENDED MAGS ALREADY MAXED" % _weapon_name(wid)
		return
	var requirements := _mag_upgrade_requirements(current_mag_tier)
	if not _spend_material_purchase(requirements):
		return
	var old_capacity := _weapon_mag_capacity(wid)
	mag_upgrade_tiers[wid] += 1
	# Bump magazines up to new capacity (don't reset ammo)
	magazine = mini(magazine, _weapon_mag_capacity(WEAPON_PISTOL))
	shotgun_magazine = mini(shotgun_magazine, _weapon_mag_capacity(WEAPON_SHOTGUN))
	smg_magazine = mini(smg_magazine, _weapon_mag_capacity(WEAPON_SMG))
	railgun_magazine = mini(railgun_magazine, _weapon_mag_capacity(WEAPON_RAILGUN))
	core_base_status.text = "%s EXTENDED MAGS MK%d // CAPACITY %d > %d" % [_weapon_name(wid), mag_upgrade_tiers[wid], old_capacity, _weapon_mag_capacity(wid)]
	_refresh_core_base_panel()
	_save_run()


func _purchase_deployable_storage_upgrade() -> void:
	var cid := _storage_deployable_focus_id()
	if cid.is_empty():
		core_base_status.text = "ALL STORAGE CACHES ALREADY AT MAXIMUM CAPACITY"
		return
	if not bool(construction_unlocks.get(cid, false)):
		core_base_status.text = "RESEARCH %s FABRICATION FIRST" % _construction_name(cid)
		return
	var dtier: int = int(deployable_storage_tiers.get(cid, 0))
	if dtier >= 2:
		core_base_status.text = "%s STORAGE CACHE ALREADY MAXED" % _construction_name(cid)
		return
	var cost: int = _deployable_storage_upgrade_cost(dtier)
	var dreq := _deployable_storage_upgrade_requirements(dtier)
	if not _spend_purchase(cost, dreq):
		return
	deployable_storage_tiers[cid] = dtier + 1
	core_base_status.text = "%s CACHE UPGRADED // CAPACITY INCREASED TO %d" % [_construction_name(cid), _deployable_cap(cid)]
	_refresh_core_base_panel()
	_save_run()


func _lowest_tier_sentry_index() -> int:
	var result := -1
	var lowest_level := 99
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind == BUILD_SENTRY and structure.base_id == current_base_id and structure.level < lowest_level:
			result = structure_index
			lowest_level = structure.level
	return result


func _eligible_turret_indices() -> Array[int]:
	var result: Array[int] = []
	var automation_gate := ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_AUTOMATION, skill_unlocks)
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if not _is_upgradeable_turret(structure) or structure.base_id != current_base_id or not structure.powered or structure.level >= 4:
			continue
		if structure.kind == BUILD_SENTRY or automation_gate:
			result.append(structure_index)
	return result


func _preview_turret_index(eligible_indices: Array[int]) -> int:
	var result := -1
	var lowest_level := 99
	for eligible_index: int in eligible_indices:
		var structure: Structure = structures[eligible_index]
		if structure.kind != BUILD_SENTRY:
			continue
		if structure.level < lowest_level:
			result = eligible_index
			lowest_level = structure.level
	if result >= 0:
		return result
	return eligible_indices[0] if not eligible_indices.is_empty() else -1


func _is_upgradeable_turret(structure: Structure) -> bool:
	return structure.kind in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET]


func _sentry_uses_sp_upgrade(structure: Structure) -> bool:
	return structure.kind == BUILD_SENTRY


func _turret_upgrade_cost_label(structure: Structure) -> String:
	var requirements: Dictionary = _turret_material_requirements(structure.level)
	if _sentry_uses_sp_upgrade(structure):
		return "[SP %d] + %s" % [ProgressionTreeScript.sentry_upgrade_sp(structure.level), _format_material_requirements(requirements)]
	return _format_material_requirements(requirements)


func _purchase_turret_upgrade() -> void:
	turret_selection_indices = _eligible_turret_indices()
	if turret_selection_indices.is_empty():
		core_base_status.text = "NO POWERED LOCAL TURRET CAN BE UPGRADED"
		return
	var any_affordable := false
	var blocked_state := "LOCKED"
	var first_affordable_cursor := 0
	for selection_index in range(turret_selection_indices.size()):
		var sentry_index: int = turret_selection_indices[selection_index]
		var sentry: Structure = structures[sentry_index]
		var candidate_state: String = _turret_purchase_state(sentry)
		if candidate_state == "READY":
			any_affordable = true
			first_affordable_cursor = selection_index
			break
		blocked_state = candidate_state
	if not any_affordable:
		core_base_status.text = "TURRET UPGRADE BLOCKED // %s" % blocked_state
		turret_selection_indices.clear()
		_refresh_core_base_panel()
		return
	turret_selection_cursor = first_affordable_cursor
	turret_selection_active = true
	using_core_base = false
	core_base_panel.visible = false
	discovery_alert = "TURRET MAP SELECT // CLICK TARGET // Q/E CYCLE // F CONFIRM"
	discovery_alert_time = 30.0
	_update_turret_selection_summary()
	_queue_visual_redraw()


func _cycle_turret_selection(direction: int) -> void:
	if turret_selection_indices.is_empty():
		_cancel_turret_selection()
		return
	turret_selection_cursor = posmod(turret_selection_cursor + direction, turret_selection_indices.size())
	_update_turret_selection_summary()


func _select_turret_at_world_position(world_position: Vector2) -> bool:
	var nearest_cursor := -1
	var nearest_distance := 20.0
	for selection_cursor in range(turret_selection_indices.size()):
		var sentry_index: int = turret_selection_indices[selection_cursor]
		if sentry_index < 0 or sentry_index >= structures.size():
			continue
		var distance_to_marker: float = structures[sentry_index].position.distance_to(world_position)
		if distance_to_marker <= nearest_distance:
			nearest_distance = distance_to_marker
			nearest_cursor = selection_cursor
	if nearest_cursor < 0:
		return false
	turret_selection_cursor = nearest_cursor
	_update_turret_selection_summary()
	return true


func _update_turret_selection_summary() -> void:
	if turret_selection_indices.is_empty():
		return
	var sentry: Structure = structures[turret_selection_indices[turret_selection_cursor]]
	var condition: int = roundi(sentry.health / maxf(1.0, sentry.max_health) * 100.0)
	discovery_alert = "%s // MK%d > MK%d // %d%% HP // %.1f > %.1f DMG // %s" % [_turret_id(sentry), sentry.level, sentry.level + 1, condition, _turret_damage_at_level(sentry.level, sentry.kind), _turret_damage_at_level(sentry.level + 1, sentry.kind), _turret_upgrade_cost_label(sentry)]
	discovery_alert_time = 30.0


func _turret_id(sentry: Structure) -> String:
	return "T-%03d-%03d" % [sentry.cell.x, sentry.cell.y]


func _turret_damage_at_level(level: int, kind: int = BUILD_SENTRY) -> float:
	var base_damage := 9.0
	if kind == BUILD_ROCKET_TURRET:
		base_damage = 70.0
	elif kind == BUILD_LASER_TURRET:
		base_damage = 15.0
	return base_damage * sentry_damage_multiplier * (1.0 + float(level - 1) * 0.35)


func _turret_interval_at_level(level: int, powered: bool = true, kind: int = BUILD_SENTRY) -> float:
	var base_interval := 0.42
	if kind == BUILD_ROCKET_TURRET:
		base_interval = 1.75
	elif kind == BUILD_LASER_TURRET:
		base_interval = 0.16
	var tier_rate := 1.0 + float(level - 1) * 0.18
	return base_interval / (sentry_rate_multiplier * tier_rate * (1.0 if powered else 0.55))


func _turret_health_after_upgrade(sentry: Structure) -> float:
	return sentry.max_health * 1.35


func _turret_aggression_radius(level: int) -> float:
	return 58.0 + float(level - 1) * 34.0


func _turret_upgrade_summary(sentry: Structure) -> String:
	var next_level := mini(4, sentry.level + 1)
	return "CURRENT  %.1f DMG | %.2fs FIRE | %.0f HP | %.0f AGGRO\nNEXT       %.1f DMG | %.2fs FIRE | %.0f HP | %.0f AGGRO" % [_turret_damage_at_level(sentry.level, sentry.kind), _turret_interval_at_level(sentry.level, true, sentry.kind), sentry.max_health, _turret_aggression_radius(sentry.level), _turret_damage_at_level(next_level, sentry.kind), _turret_interval_at_level(next_level, true, sentry.kind), _turret_health_after_upgrade(sentry), _turret_aggression_radius(next_level)]


func _turret_purchase_state(sentry: Structure) -> String:
	if sentry.level >= 4:
		return "MAXIMUM"
	if _sentry_uses_sp_upgrade(sentry):
		return _sp_purchase_state(ProgressionTreeScript.sentry_upgrade_sp(sentry.level), _turret_material_requirements(sentry.level))
	if not ProgressionTreeScript.permanent_upgrade_unlocked(ProgressionTreeScript.BRANCH_AUTOMATION, skill_unlocks):
		return ProgressionTreeScript.permanent_gate_reason(ProgressionTreeScript.BRANCH_AUTOMATION)
	return _material_purchase_state(_turret_material_requirements(sentry.level))


func _confirm_turret_upgrade() -> void:
	if turret_selection_indices.is_empty():
		_cancel_turret_selection()
		return
	var sentry_index: int = turret_selection_indices[turret_selection_cursor]
	if sentry_index < 0 or sentry_index >= structures.size():
		_cancel_turret_selection()
		return
	var sentry: Structure = structures[sentry_index]
	var requirements: Dictionary = _turret_material_requirements(sentry.level)
	var purchase_state: String = _turret_purchase_state(sentry)
	var purchase_ok := _spend_sp_purchase(ProgressionTreeScript.sentry_upgrade_sp(sentry.level), requirements) if _sentry_uses_sp_upgrade(sentry) else _spend_material_purchase(requirements)
	if purchase_state != "READY" or not purchase_ok:
		var failure_message: String = "TURRET UPGRADE BLOCKED // %s" % purchase_state
		_cancel_turret_selection(true)
		core_base_status.text = failure_message
		discovery_alert = failure_message
		discovery_alert_time = 4.0
		return
	sentry.level += 1
	sentry.max_health *= 1.35
	sentry.health = minf(sentry.max_health, sentry.health + sentry.max_health * 0.45)
	core_base_status.text = "%s ADVANCED TO MK %d" % [_turret_id(sentry), sentry.level]
	discovery_alert = core_base_status.text
	discovery_alert_time = 4.0
	_refresh_expedition_xp_meter()
	_cancel_turret_selection(true)
	_save_run()


func _cancel_turret_selection(return_to_menu: bool = true) -> void:
	turret_selection_active = false
	turret_selection_indices.clear()
	turret_selection_cursor = 0
	if return_to_menu:
		using_core_base = true
		core_base_panel.visible = true
		core_menu_page = "defenses"
		_refresh_core_base_panel()
		_focus_first_core_action()


func _deposit_contract_refining() -> void:
	if not material_economy.begin_contract():
		core_base_status.text = "CONTRACT BUSY OR NO RAW CARGO AVAILABLE"
		return
	core_base_status.text = "RAW CARGO DEPOSITED // $%d DUE IN %d SEC" % [material_economy.contract_payout, ceili(material_economy.contract_remaining)]
	_refresh_core_base_panel()
	_save_run()


func _unlock_foundry() -> void:
	if material_economy.foundry_tier >= 3:
		return
	if current_base_id != BaseNetworkScript.COMMAND_ID:
		core_base_status.text = "COMMAND CORE REQUIRED FOR FOUNDRY RESEARCH"
		return
	if not _spend_scrap(material_economy.foundry_upgrade_cost(material_economy.foundry_tier)):
		return
	material_economy.unlock_foundry()
	if material_economy.foundry_tier == 1:
		var kit_stock := int(deployable_stock.get("foundry", 0))
		if kit_stock < FOUNDRY_KIT_STOCK_CAP:
			var leftover: int = grant_kit("foundry", 1)
			if leftover <= 0:
				foundry_kit_available = false
				core_base_status.text = "FOUNDRY MK1 KIT READY // SELECT HOTBAR // RMB PLACE"
				_close_core_base()
				discovery_alert = "FOUNDRY KIT // SELECT SLOT // RMB PLACE"
				discovery_alert_time = 4.0
			else:
				foundry_kit_available = true
				core_base_status.text = "FOUNDRY MK1 RESEARCH COMPLETE // FREE KIT PENDING // CLEAR ONE DEPLOYABLE SLOT"
	else:
		core_base_status.text = "FOUNDRY MK%d RESEARCH COMPLETE // UPGRADE FACILITIES IN THE FIELD" % material_economy.foundry_tier
	if using_core_base:
		_refresh_core_base_panel()
	_save_run()


func _fabricate_foundry_kit() -> void:
	if material_economy.foundry_tier <= 0:
		core_base_status.text = "UNLOCK FOUNDRY MK1 RESEARCH FIRST"
		return
	if current_base_id != BaseNetworkScript.COMMAND_ID:
		core_base_status.text = "COMMAND CORE REQUIRED FOR FOUNDRY FABRICATION"
		return
	var current_stock := int(deployable_stock.get("foundry", 0))
	if current_stock >= FOUNDRY_KIT_STOCK_CAP:
		core_base_status.text = "FOUNDRY KIT CACHE FULL (%d/%d)" % [current_stock, FOUNDRY_KIT_STOCK_CAP]
		return
	var requirements := _foundry_kit_requirements()
	var craft_state := _deployable_craft_state("foundry", 650, requirements)
	if craft_state != "READY":
		core_base_status.text = "FABRICATION BLOCKED // %s" % craft_state
		return
	if not _spend_purchase(650, requirements):
		return
	grant_kit("foundry", 1)
	core_base_status.text = "FOUNDRY KIT FABRICATED // STOCK %d/%d // DEPLOY IN POWERED TERRITORY" % [int(deployable_stock["foundry"]), FOUNDRY_KIT_STOCK_CAP]
	if using_core_base:
		_refresh_core_base_panel()
	_save_run()


func _purchase_or_craft_personal_base() -> void:
	if _personal_base_index_for_base(current_base_id) >= 0:
		_upgrade_personal_base()
		return
	if not ProgressionTreeScript.is_unlocked("personal_base", skill_unlocks):
		if not _unlock_skill_node("personal_base"):
			return
		core_base_status.text = "PERSONAL BASE BLUEPRINT UNLOCKED // FABRICATE SHELTER KIT"
	elif int(deployable_stock.get("personal_base", 0)) > 0:
		core_base_status.text = "PERSONAL BASE KIT READY // ENTER BUILD MODE"
	else:
		var requirements := {MaterialEconomyScript.STONE_BLOCK: 2, MaterialEconomyScript.BRONZE_INGOT: 1}
		if not _can_accept_kit("personal_base"):
			core_base_status.text = "FABRICATION BLOCKED // NEED ONE FREE DEPLOYABLE SLOT"
			return
		var kit_cost := ProgressionTreeScript.personal_base_kit_scrap_cost()
		if not _spend_purchase(kit_cost, requirements):
			return
		set_kit_stock("personal_base", 1)
		core_base_status.text = "PERSONAL BASE KIT FABRICATED // DEPLOY ON ANY PREPARED GROUND"
	_refresh_core_base_panel()
	_save_run()


func _upgrade_personal_base() -> void:
	var shelter_index := _personal_base_index_for_base(current_base_id)
	if shelter_index < 0:
		return
	var shelter: Structure = structures[shelter_index]
	var tier := ShelterUnitScript.clamp_tier(shelter.level)
	if tier >= 3:
		core_base_status.text = "PERSONAL BASE MK3 // MAX RECOVERY TIER"
		return
	var upgrade_sp := ProgressionTreeScript.personal_base_upgrade_sp(tier)
	var upgrade_req := ShelterUnitScript.upgrade_requirements(tier)
	if not _spend_sp_purchase(upgrade_sp, upgrade_req):
		return
	shelter.level = tier + 1
	core_base_status.text = "PERSONAL BASE MK%d // %.0f HP/S // %.1fS REST" % [
		shelter.level, ShelterUnitScript.heal_rate(shelter.level), ShelterUnitScript.rest_duration(shelter.level)]
	_refresh_core_base_panel()
	_save_run()


func _refine_material(raw_id: String) -> void:
	var foundry_index := _preferred_foundry_index()
	if foundry_index < 0:
		core_base_status.text = "NO POWERED FOUNDRY // PLACE OR REPAIR A FACILITY"
		return
	var foundry: Structure = structures[foundry_index]
	if not FoundryUnitScript.queue_refinement(foundry, material_economy, raw_id):
		core_base_status.text = "INSUFFICIENT %s, COAL, OR FOUNDRY BUFFER/QUEUE FULL" % _material_name(raw_id)
		return
	var output_id: String = material_economy.recipe_output(raw_id)
	core_base_status.text = "%s QUEUED // %s IN %.0f SEC // %d/%d" % [_material_name(raw_id), _material_name(output_id), FoundryUnitScript.batch_duration(foundry.level), FoundryUnitScript.queue_size(foundry), FoundryUnitScript.queue_limit(foundry.level)]
	if using_core_base:
		_refresh_core_base_panel()
	if using_foundry and foundry_index == active_foundry_index:
		_refresh_foundry_panel()
	_save_run()


func _refine_next_available() -> void:
	var foundry_index := _preferred_foundry_index()
	var tier := structures[foundry_index].level if foundry_index >= 0 else material_economy.foundry_tier
	var raw_id: String = material_economy.next_recipe(tier)
	if raw_id.is_empty():
		foundry_action_message = "NO COMPLETE FOUNDRY RECIPE // MINE MORE MATERIALS"
		core_base_status.text = foundry_action_message
		return
	_refine_material(raw_id)


func _refine_all_available() -> void:
	var foundry_index := _preferred_foundry_index()
	if foundry_index < 0:
		core_base_status.text = "NO POWERED FOUNDRY // PLACE OR REPAIR A FACILITY"
		return
	var batches := FoundryUnitScript.queue_all_available(structures[foundry_index], material_economy)
	if batches <= 0:
		core_base_status.text = "NO COMPLETE FOUNDRY RECIPE // MINE MORE MATERIALS"
		return
	core_base_status.text = "FOUNDRY QUEUE LOADED // %d BATCHES // %.0f SEC EACH" % [batches, FoundryUnitScript.batch_duration(structures[foundry_index].level)]
	if using_core_base:
		_refresh_core_base_panel()
	_save_run()


func _format_raw_requirements(requirements: Dictionary) -> String:
	if requirements.is_empty():
		return "NO RAW INPUTS"
	var parts: PackedStringArray = []
	for material_id: String in requirements.keys():
		parts.append("%d %s" % [int(requirements[material_id]), _material_name(material_id)])
	return " + ".join(parts)


func _sell_refined_materials() -> void:
	var payout: int = material_economy.sell_refined()
	if payout <= 0:
		core_base_status.text = "NO REFINED STOCK AVAILABLE FOR SALE"
		return
	_apply_scrap_delta(payout, "sell_refined")
	core_base_status.text = "REFINED STOCK SOLD // +$%d CREDITS" % payout
	_refresh_core_base_panel()
	_save_run()


func _sell_raw_materials_quick() -> void:
	var payout: int = material_economy.sell_raw_quick()
	if payout <= 0:
		core_base_status.text = "NO RAW CARGO AVAILABLE FOR IMMEDIATE SALE"
		return
	_apply_scrap_delta(payout, "sell_raw_quick")
	core_base_status.text = "RAW CARGO SOLD IMMEDIATELY // +$%d CREDITS // 65%% RATE" % payout
	_refresh_core_base_panel()
	_save_run()


func _repair_cost() -> int:
	var base_record: Dictionary = base_network.get_base(current_base_id)
	var missing := maxf(0.0, float(base_record["max_health"]) - float(base_record["health"]))
	for structure in structures:
		if structure.base_id == current_base_id:
			missing += maxf(0.0, structure.max_health - structure.health)
	var divisor: float = 8.0 if str(base_record["kind"]) == "foundry" else 6.0
	return ceili(missing / divisor) if missing > 0.5 else 0


func _purchase_repairs() -> void:
	var cost: int = _repair_cost()
	if cost <= 0 or not _spend_scrap(cost):
		return
	base_network.repair(current_base_id)
	core_health = float(base_network.get_base(BaseNetworkScript.COMMAND_ID)["health"])
	for structure in structures:
		if structure.base_id == current_base_id:
			structure.health = structure.max_health
	core_base_status.text = "CORE AND FIELD EQUIPMENT RESTORED"
	_refresh_core_base_panel()
	_save_run()


func _purchase_restock() -> void:
	if not _spend_scrap(25):
		return
	reserve_ammo = mini(reserve_ammo + 36, AMMO_RESERVE_CAPS[WEAPON_PISTOL])
	shotgun_reserve = mini(shotgun_reserve + 12, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN])
	smg_reserve = mini(smg_reserve + 60, AMMO_RESERVE_CAPS[WEAPON_SMG])
	railgun_reserve = mini(railgun_reserve + 3, AMMO_RESERVE_CAPS[WEAPON_RAILGUN])
	laser_energy = 100.0
	var kind: String = str(base_network.get_base(current_base_id)["kind"])
	if kind == "research":
		railgun_reserve = mini(railgun_reserve + 3, AMMO_RESERVE_CAPS[WEAPON_RAILGUN])
		laser_energy = 100.0
	elif kind == "containment":
		smg_reserve = mini(smg_reserve + 45, AMMO_RESERVE_CAPS[WEAPON_SMG])
		shotgun_reserve = mini(shotgun_reserve + 8, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN])
	core_base_status.text = "FIELD AMMUNITION RESTOCKED"
	_refresh_core_base_panel()
	_save_run()


func _any_foundry_powered() -> bool:
	for structure_index in range(structures.size()):
		if _foundry_powered(structure_index):
			return true
	return false


func _foundry_fuel_purchase_room(preferred_foundry = null) -> int:
	if material_economy.foundry_tier <= 0:
		return 0
	var room := 0
	if preferred_foundry != null and _foundry_powered(active_foundry_index):
		room += FoundryUnitScript.fuel_space(preferred_foundry)
	else:
		for structure_index in range(structures.size()):
			if structures[structure_index].kind != BUILD_FOUNDRY or not _foundry_powered(structure_index):
				continue
			room += FoundryUnitScript.fuel_space(structures[structure_index])
	if room <= 0 and not _any_foundry_powered():
		room = _backpack_free()
	return room


func _load_foundry_fuel() -> bool:
	var foundry := _active_foundry()
	if foundry == null or not _foundry_powered(active_foundry_index):
		foundry_action_message = "FOUNDRY OFFLINE // POWER REQUIRED"
		return false
	var moved := FoundryUnitScript.load_fuel_from_backpack(foundry, material_economy)
	if moved <= 0:
		foundry_action_message = "NO PACK COAL OR BUFFER FULL"
		return false
	foundry_action_message = "COAL LOADED // BUFFER %d/%d  //  PACK %d" % [
		FoundryUnitScript.fuel_remaining(foundry),
		FoundryUnitScript.fuel_capacity(foundry.level),
		int(material_economy.raw.get(MaterialEconomyScript.COAL, 0)),
	]
	_refresh_foundry_panel()
	_save_run()
	return true


func _purchase_foundry_fuel(from_foundry_panel: bool = false) -> bool:
	if material_economy.foundry_tier <= 0:
		if not from_foundry_panel:
			core_base_status.text = "FOUNDRY RESEARCH REQUIRED"
		else:
			foundry_action_message = "FOUNDRY RESEARCH REQUIRED"
		return false
	var preferred_foundry = _active_foundry() if from_foundry_panel else null
	var has_powered_foundry := _any_foundry_powered()
	var room := _foundry_fuel_purchase_room(preferred_foundry)
	if room <= 0:
		if not from_foundry_panel:
			core_base_status.text = "FOUNDRY FUEL STORAGE FULL"
		else:
			foundry_action_message = "FOUNDRY FUEL STORAGE FULL"
		return false
	if not _spend_scrap(FOUNDRY_FUEL_BUNDLE_COST):
		return false
	var issued := mini(FOUNDRY_FUEL_BUNDLE, room)
	var remaining := issued
	if preferred_foundry != null and _foundry_powered(active_foundry_index):
		remaining -= FoundryUnitScript.add_fuel(preferred_foundry, remaining)
	elif has_powered_foundry:
		for structure_index in range(structures.size()):
			if remaining <= 0:
				break
			if structures[structure_index].kind != BUILD_FOUNDRY or not _foundry_powered(structure_index):
				continue
			remaining -= FoundryUnitScript.add_fuel(structures[structure_index], remaining)
	if remaining > 0 and not has_powered_foundry:
		remaining = mini(remaining, _backpack_free())
		if remaining > 0:
			material_economy.add_raw(MaterialEconomyScript.COAL, remaining)
	var pack_coal := int(material_economy.raw.get(MaterialEconomyScript.COAL, 0))
	var buffer_coal := 0
	if preferred_foundry != null and _foundry_powered(active_foundry_index):
		buffer_coal = FoundryUnitScript.fuel_remaining(preferred_foundry)
	elif has_powered_foundry:
		for structure_index in range(structures.size()):
			if structures[structure_index].kind != BUILD_FOUNDRY or not _foundry_powered(structure_index):
				continue
			buffer_coal += FoundryUnitScript.fuel_remaining(structures[structure_index])
	var status := "FOUNDRY COAL ISSUED // BUFFER %d" % buffer_coal if has_powered_foundry else "FOUNDRY COAL ISSUED // PACK %d" % pack_coal
	if has_powered_foundry and issued < FOUNDRY_FUEL_BUNDLE:
		status += " // PARTIAL FILL"
	if from_foundry_panel:
		foundry_action_message = status
	else:
		core_base_status.text = status
	_refresh_core_base_panel()
	if using_foundry:
		_refresh_foundry_panel()
	_save_run()
	return true


func _purchase_supply(slot: int) -> void:
	if slot == 8:
		if flamethrower_unlocked and flame_fuel < FLAMETHROWER_FUEL_CAP:
			if not _spend_scrap(FLAMETHROWER_FUEL_BUNDLE_COST):
				return
			flame_fuel = mini(FLAMETHROWER_FUEL_CAP, flame_fuel + FLAMETHROWER_FUEL_BUNDLE)
			core_base_status.text = "FLAME FUEL ISSUED // %d/%d" % [flame_fuel, FLAMETHROWER_FUEL_CAP]
			_refresh_core_base_panel()
			_save_run()
			return
		if material_economy.foundry_tier > 0:
			_purchase_foundry_fuel()
			return
		if flamethrower_unlocked:
			core_base_status.text = "FLAME FUEL ALREADY FULL"
		else:
			core_base_status.text = "FOUNDRY RESEARCH REQUIRED"
		return
	if slot == 7:
		if not _spend_scrap(TORCH_PURCHASE_COST):
			return
		if grant_kit(TORCH_STOCK_ID, 1) > 0:
			_apply_scrap_delta(TORCH_PURCHASE_COST, "torch_refund")
			core_base_status.text = "PACK FULL // NO FREE SLOT"
			return
		core_base_status.text = "FIELD LANTERN +1 // STOCK %d // RMB PLACE" % kit_count(TORCH_STOCK_ID)
		_refresh_core_base_panel()
		_save_run()
		return
	var cost: int = int([12, 18, 15, 22, 30, 55, 25][clampi(slot, 0, 6)])
	if slot == 2 and laser_energy >= 99.9:
		core_base_status.text = "LASER CAPACITOR ALREADY FULL"
		return
	if slot == 3 and not unlocked_weapons[WEAPON_SMG]:
		core_base_status.text = "SMG RESEARCH REQUIRED"
		return
	if slot == 4 and not unlocked_weapons[WEAPON_RAILGUN]:
		core_base_status.text = "RAILGUN RESEARCH REQUIRED"
		return
	if slot == 6 and player_health >= 99.9:
		core_base_status.text = "OPERATOR ALREADY AT FULL HEALTH"
		return
	if not _spend_scrap(cost):
		return
	match slot:
		0:
			reserve_ammo = mini(reserve_ammo + 60, AMMO_RESERVE_CAPS[WEAPON_PISTOL])
			core_base_status.text = "PISTOL CARTRIDGES RECEIVED // RESERVE: %d" % reserve_ammo
		1:
			shotgun_reserve = mini(shotgun_reserve + 24, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN])
			core_base_status.text = "SHOTGUN SHELLS RECEIVED // RESERVE: %d" % shotgun_reserve
		2:
			var restored_charge := ceili(100.0 - laser_energy)
			laser_energy = 100.0
			core_base_status.text = "LASER CAPACITOR RESTORED // +%d%%" % restored_charge
		3:
			smg_reserve = mini(smg_reserve + 120, AMMO_RESERVE_CAPS[WEAPON_SMG])
			core_base_status.text = "SMG ROUNDS RECEIVED // RESERVE: %d" % smg_reserve
		4:
			var rail_amount := 12 if str(base_network.get_base(current_base_id)["kind"]) == "research" else 9
			railgun_reserve = mini(railgun_reserve + rail_amount, AMMO_RESERVE_CAPS[WEAPON_RAILGUN])
			core_base_status.text = "RAIL SLUGS RECEIVED // RESERVE: %d" % railgun_reserve
		5:
			reserve_ammo = mini(reserve_ammo + 60, AMMO_RESERVE_CAPS[WEAPON_PISTOL])
			shotgun_reserve = mini(shotgun_reserve + 18, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN])
			laser_energy = 100.0
			if unlocked_weapons[WEAPON_SMG]:
				smg_reserve = mini(smg_reserve + 90, AMMO_RESERVE_CAPS[WEAPON_SMG])
			if unlocked_weapons[WEAPON_RAILGUN]:
				railgun_reserve = mini(railgun_reserve + 6, AMMO_RESERVE_CAPS[WEAPON_RAILGUN])
			core_base_status.text = "FIELD AMMO BUNDLE RECEIVED // ALL OWNED WEAPONS SUPPLIED"
		6:
			var restored_health := ceili(100.0 - player_health)
			player_health = 100.0
			core_base_status.text = "MEDICAL TREATMENT COMPLETE // +%d HP" % restored_health
	_refresh_core_base_panel()
	_save_run()


func _purchase_regional_service() -> void:
	var record: Dictionary = base_network.get_base(current_base_id)
	var kind: String = str(record["kind"])
	var service_state := _regional_service_state(record)
	if service_state != "READY":
		core_base_status.text = "SERVICE BLOCKED // %s" % service_state
		return
	var cost: int = 45 if kind == "foundry" else 35
	if not _spend_scrap(cost):
		return
	if kind == "research":
		railgun_reserve = mini(railgun_reserve + 5, AMMO_RESERVE_CAPS[WEAPON_RAILGUN])
		laser_energy = 100.0
		core_base_status.text = "CRYSTAL WEAPONS CALIBRATED"
	elif kind == "foundry":
		for structure in structures:
			if structure.base_id == current_base_id:
				structure.max_health *= 1.12
				structure.health = structure.max_health
		record["specialty_level"] = int(record.get("specialty_level", 0)) + 1
		core_base_status.text = "LOCAL DEFENSE ARMOR REINFORCED // %d/3" % int(record["specialty_level"])
	else:
		if unlocked_weapons[WEAPON_SMG]:
			smg_reserve = mini(smg_reserve + 90, AMMO_RESERVE_CAPS[WEAPON_SMG])
		shotgun_reserve = mini(shotgun_reserve + 18, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN])
		core_base_status.text = "ANTI-SWARM LOADOUT ISSUED"
	_refresh_core_base_panel()
	_save_run()


func _purchase_base_upgrade() -> void:
	var record: Dictionary = base_network.get_base(current_base_id)
	var tier: int = int(record["tier"])
	var level_gate: int = 4 if tier == 1 else 8
	var sp_cost: int = ProgressionTreeScript.frontier_core_upgrade_sp(tier)
	if current_base_id == BaseNetworkScript.COMMAND_ID or tier >= 3 or expedition_level < level_gate or not _spend_sp_purchase(sp_cost, _base_material_requirements(tier)):
		return
	if base_network.upgrade(current_base_id):
		core_base_status.text = "%s ADVANCED TO MK %d" % [str(record["name"]), tier + 1]
		_refresh_core_base_panel()
		_save_run()


func _on_scrap_changed(before: int, reason: String) -> void:
	hud_last_scrap = scrap
	hud_scrap_display = float(scrap)
	hud_scrap_tick = 0.35
	_mark_visual_dirty(VIS_DIRTY_HUD)
	if using_core_base:
		_update_scrap_label()


func _apply_scrap_delta(delta: int, reason: String) -> void:
	if delta == 0:
		return
	var before := scrap
	scrap = maxi(0, scrap + delta)
	if scrap != before:
		_on_scrap_changed(before, reason)


func _set_scrap(value: int, reason: String = "set") -> void:
	var before := scrap
	scrap = maxi(0, value)
	if scrap != before:
		_on_scrap_changed(before, reason)


func _update_scrap_label() -> void:
	if not is_instance_valid(core_base_scrap_label):
		return
	if core_menu_page == "materials":
		core_base_scrap_label.text = "ACCOUNT  $%05d\nRAW %d  ·  PACK %d/%d" % [scrap, material_economy.raw_total(), _backpack_used(), _backpack_capacity()]
	else:
		core_base_scrap_label.text = "ACCOUNT  $%05d\nPACK %d/%d  ·  SP %d" % [scrap, _backpack_used(), _backpack_capacity(), skill_points]


func _spend_scrap(cost: int, reason: String = "spend") -> bool:
	if scrap < cost:
		core_base_status.text = "INSUFFICIENT CREDITS // NEED $%d MORE" % (cost - scrap)
		return false
	_apply_scrap_delta(-cost, reason)
	var burst_cell: Vector2i = base_network.get_cell(current_base_id) if is_instance_valid(base_network) else grid.core_cell
	_burst(grid.cell_to_world(burst_cell), Color("8eeaff"), 12, 48.0)
	return true


func _serialize_recovery_cache() -> Dictionary:
	if recovery_cache.is_empty():
		return {}
	var position_value: Variant = recovery_cache.get("position", player_position)
	var position := position_value if position_value is Vector2 else Vector2.ZERO
	if position_value is Array and position_value.size() == 2:
		position = Vector2(float(position_value[0]), float(position_value[1]))
	return {
		"active": bool(recovery_cache.get("active", false)),
		"position": [position.x, position.y],
		"remaining": clampf(float(recovery_cache.get("remaining", 0.0)), 0.0, RECOVERY_LIFETIME),
		"cargo": recovery_cache.get("cargo", {}).duplicate(true),
	}


func _sanitize_recovery_cargo(saved_value: Variant) -> Dictionary:
	var result := {"raw": {}, "refined": {}, "kits": {}}
	if not saved_value is Dictionary:
		return result
	var saved: Dictionary = saved_value
	var saved_raw: Dictionary = saved.get("raw", {}) if saved.get("raw", {}) is Dictionary else {}
	var saved_refined: Dictionary = saved.get("refined", {}) if saved.get("refined", {}) is Dictionary else {}
	var saved_kits: Dictionary = saved.get("kits", {}) if saved.get("kits", {}) is Dictionary else {}
	for material_id: String in MaterialEconomyScript.RAW_ORDER:
		var amount := maxi(0, int(saved_raw.get(material_id, 0)))
		if amount > 0:
			result["raw"][material_id] = amount
	for material_id: String in MaterialEconomyScript.REFINED_ORDER:
		var amount := maxi(0, int(saved_refined.get(material_id, 0)))
		if amount > 0:
			result["refined"][material_id] = amount
	for stock_id: String in deployable_stock.keys():
		var amount := maxi(0, int(saved_kits.get(stock_id, 0)))
		if amount > 0:
			result["kits"][stock_id] = amount
	return result


func _restore_recovery_cache(saved_value: Variant) -> void:
	recovery_cache = {}
	if not saved_value is Dictionary:
		return
	var saved: Dictionary = saved_value
	var position_value: Variant = saved.get("position", [])
	if not position_value is Array or position_value.size() != 2:
		return
	var cargo := _sanitize_recovery_cargo(saved.get("cargo", {}))
	var remaining := clampf(float(saved.get("remaining", 0.0)), 0.0, RECOVERY_LIFETIME)
	recovery_cache = {
		"active": bool(saved.get("active", false)) and remaining > 0.0 and _cargo_units(cargo) > 0,
		"position": Vector2(float(position_value[0]), float(position_value[1])),
		"remaining": remaining,
		"cargo": cargo,
	}


func _capture_backpack_cargo() -> Dictionary:
	_adopt_deployable_stock_mirror()
	var raw: Dictionary = {}
	var refined: Dictionary = {}
	var kits: Dictionary = {}
	for material_id: String in MaterialEconomyScript.RAW_ORDER:
		var amount := maxi(0, int(material_economy.raw.get(material_id, 0)))
		if amount > 0:
			raw[material_id] = amount
	for material_id: String in MaterialEconomyScript.REFINED_ORDER:
		var amount := maxi(0, int(material_economy.refined.get(material_id, 0)))
		if amount > 0:
			refined[material_id] = amount
	for stock_id: String in deployable_stock.keys():
		var amount := kit_count(stock_id)
		if amount > 0:
			kits[stock_id] = amount
	var stacks: Array = []
	for stack: Dictionary in operator_loadout.backpack:
		if str(stack.get("kind", "")) in [OperatorLoadoutScript.KIND_DEPLOYABLE, OperatorLoadoutScript.KIND_BLOCK]:
			stacks.append(stack.duplicate(true))
	for stack: Dictionary in operator_loadout.hotbar:
		if str(stack.get("kind", "")) in [OperatorLoadoutScript.KIND_DEPLOYABLE, OperatorLoadoutScript.KIND_BLOCK]:
			stacks.append(stack.duplicate(true))
	return {"raw": raw, "refined": refined, "kits": kits, "stacks": stacks}


func _clear_backpack_cargo() -> void:
	for material_id: String in MaterialEconomyScript.RAW_ORDER:
		material_economy.raw[material_id] = 0
	for material_id: String in MaterialEconomyScript.REFINED_ORDER:
		material_economy.refined[material_id] = 0
	operator_loadout.clear_cargo_stacks()
	_sync_deployable_mirror()


func _cargo_units(cargo: Dictionary) -> int:
	var total := 0
	for amount: Variant in cargo.get("raw", {}).values():
		total += maxi(0, int(amount))
	for amount: Variant in cargo.get("refined", {}).values():
		total += maxi(0, int(amount))
	if cargo.has("stacks"):
		for stack_value: Variant in cargo.get("stacks", []):
			if stack_value is Dictionary:
				total += maxi(0, int(stack_value.get("count", 0)))
		return total
	for stock_id: String in cargo.get("kits", {}).keys():
		total += maxi(0, int(cargo["kits"][stock_id]))
	return total


func _nearest_recovery_position(death_position: Vector2) -> Vector2:
	var death_cell := grid.world_to_cell(death_position)
	if grid.is_walkable(death_cell):
		return grid.cell_to_world(death_cell)
	for radius in range(1, 13):
		for y in range(-radius, radius + 1):
			for x in range(-radius, radius + 1):
				if absi(x) != radius and absi(y) != radius:
					continue
				var candidate := death_cell + Vector2i(x, y)
				if grid.is_walkable(candidate):
					return grid.cell_to_world(candidate)
	return checkpoint_position


func _write_recovery_journal() -> bool:
	if not checkpoint_exists:
		return false
	return RealmSaveScript.write_recovery(realm_id, {
		"version": RECOVERY_VERSION,
		"realm_id": realm_id,
		"checkpoint_generation": checkpoint_generation,
		"encounter_epoch": encounter_epoch,
		"penalty_active": true,
		"cache": _serialize_recovery_cache(),
	})


func _apply_recovery_journal() -> void:
	if not checkpoint_exists:
		return
	var journal := RealmSaveScript.load_recovery(realm_id)
	if journal.is_empty():
		return
	if int(journal.get("checkpoint_generation", -1)) != checkpoint_generation:
		RealmSaveScript.clear_recovery(realm_id)
		return
	_clear_backpack_cargo()
	encounter_epoch = maxi(encounter_epoch, int(journal.get("encounter_epoch", encounter_epoch)))
	_restore_recovery_cache(journal.get("cache", {}))
	_remix_enemy_patterns(encounter_epoch)
	discovery_alert = "RECOVERY PROTOCOL ACTIVE // RETURN TO DEATH MARKER"
	discovery_alert_time = 4.0


func _checkpoint_slot_level_req(slot_index: int) -> int:
	return CHECKPOINT_SLOT_LEVEL_REQS[clampi(slot_index, 0, MAX_CHECKPOINT_SLOTS - 1)]


func _checkpoint_slot_open(slot_index: int) -> bool:
	return expedition_level >= _checkpoint_slot_level_req(slot_index)


func _checkpoint_slot_writes_enabled(slot_index: int) -> bool:
	return _checkpoint_slot_open(slot_index)


func _ensure_checkpoint_slots_size() -> void:
	while checkpoint_slots.size() < MAX_CHECKPOINT_SLOTS:
		checkpoint_slots.append({})


func _checkpoint_slot_snapshot(slot_index: int, base_id: String, save_position: Vector2, generation: int) -> Dictionary:
	return {
		"base_id": base_id,
		"position": [save_position.x, save_position.y],
		"generation": generation,
		"label": "PRIMARY" if slot_index == 0 else "ARCHIVE %d" % (slot_index + 1),
		"saved_wave": wave,
	}


func _checkpoint_slot_label(slot_index: int) -> String:
	var slot_num := slot_index + 1
	if not _checkpoint_slot_open(slot_index):
		return "SLOT %d LOCKED // LVL %d" % [slot_num, _checkpoint_slot_level_req(slot_index)]
	if slot_index == 0 and checkpoint_exists:
		return "SLOT %d ACTIVE // GEN %d" % [slot_num, checkpoint_generation]
	_ensure_checkpoint_slots_size()
	if slot_index < checkpoint_slots.size() and not checkpoint_slots[slot_index].is_empty():
		var slot: Dictionary = checkpoint_slots[slot_index]
		return "SLOT %d STORED // GEN %d" % [slot_num, int(slot.get("generation", 0))]
	return "SLOT %d EMPTY" % slot_num


func _checkpoint_slots_button_label() -> String:
	return "[INFO] %s" % _checkpoint_slot_label(0)


func _checkpoint_slots_detail() -> String:
	var lines: PackedStringArray = []
	for slot_index in range(MAX_CHECKPOINT_SLOTS):
		lines.append(_checkpoint_slot_label(slot_index))
	lines.append("")
	lines.append("Slot 1 is the active respawn anchor. Slots 2-3 store archive anchors you can activate later.")
	return "\n".join(lines)


func _checkpoint_slots_state() -> String:
	return "ACTIVE" if checkpoint_exists else "STANDBY"


func _serialize_checkpoint_slots() -> Array:
	var values: Array = []
	for slot_value: Variant in checkpoint_slots:
		if slot_value is Dictionary:
			values.append(slot_value.duplicate(true))
	return values


func _migrate_checkpoint_slots(data: Dictionary) -> void:
	checkpoint_slots.clear()
	var saved_slots: Variant = data.get("checkpoint_slots", [])
	if saved_slots is Array and not saved_slots.is_empty():
		for slot_value: Variant in saved_slots:
			if slot_value is Dictionary:
				checkpoint_slots.append(slot_value.duplicate(true))
		_ensure_checkpoint_slots_size()
		return
	if not bool(data.get("checkpoint_exists", checkpoint_exists)):
		return
	var saved_position: Variant = data.get("checkpoint_position", [])
	var position_values: Array = saved_position if saved_position is Array else [checkpoint_position.x, checkpoint_position.y]
	checkpoint_slots.append({
		"base_id": str(data.get("checkpoint_base_id", checkpoint_base_id)),
		"position": position_values,
		"generation": maxi(1, int(data.get("checkpoint_generation", checkpoint_generation))),
		"label": "PRIMARY",
	})
	_ensure_checkpoint_slots_size()


func _sync_checkpoint_slot(slot_index: int) -> void:
	if slot_index != 0 or not checkpoint_exists:
		return
	_ensure_checkpoint_slots_size()
	checkpoint_slots[slot_index] = _checkpoint_slot_snapshot(slot_index, checkpoint_base_id, checkpoint_position, checkpoint_generation)


func _sync_checkpoint_slot_zero() -> void:
	_sync_checkpoint_slot(0)


func _personal_base_deployed() -> bool:
	for structure in structures:
		if structure.kind == BUILD_PERSONAL_BASE and structure.health > 0.0:
			return true
	return false


func _save_cooldown_duration() -> float:
	var shelter_index := _personal_base_index_for_base(BaseNetworkScript.COMMAND_ID)
	if shelter_index < 0:
		for structure_index in range(structures.size()):
			if structures[structure_index].kind == BUILD_PERSONAL_BASE:
				shelter_index = structure_index
				break
	if shelter_index < 0:
		return ARCHIVE_SAVE_COOLDOWN
	return ShelterUnitScript.cooldown(structures[shelter_index].level)


func _save_ready() -> bool:
	return realm_save_cooldown <= 0.0


func _can_commit_realm_save() -> bool:
	return _is_at_save_archive() and _save_ready()


func _realm_save_state_label() -> String:
	if not _save_ready():
		return "%dS COOLDOWN" % ceili(realm_save_cooldown)
	return "READY"


func _can_commit_realm_save_for_slot(slot_index: int) -> bool:
	return _can_commit_realm_save() and _checkpoint_slot_open(slot_index)


func _can_activate_checkpoint_slot(slot_index: int) -> bool:
	if slot_index <= 0 or slot_index >= MAX_CHECKPOINT_SLOTS:
		return false
	if not _checkpoint_slot_open(slot_index) or not _is_at_save_archive():
		return false
	_ensure_checkpoint_slots_size()
	return slot_index < checkpoint_slots.size() and not checkpoint_slots[slot_index].is_empty()


func _commit_realm_save(require_archive_vicinity: bool = true) -> bool:
	return _commit_realm_save_to_slot(0, require_archive_vicinity)


func _commit_realm_save_to_slot(slot_index: int, require_archive_vicinity: bool = true) -> bool:
	if not _checkpoint_slot_open(slot_index):
		return false
	if require_archive_vicinity and not _is_at_save_archive():
		return false
	if not _save_ready():
		return false
	var archive_base_id := _save_archive_base_id()
	if archive_base_id.is_empty():
		return false
	var save_position := _checkpoint_anchor_position(archive_base_id)
	if slot_index == 0:
		if _commit_checkpoint_at(save_position, archive_base_id):
			realm_save_cooldown = _save_cooldown_duration()
			return true
		return false
	_ensure_checkpoint_slots_size()
	var prior_slot: Dictionary = checkpoint_slots[slot_index].duplicate(true) if slot_index < checkpoint_slots.size() else {}
	var prior_generation := int(checkpoint_slots[slot_index].get("generation", 0)) if not prior_slot.is_empty() else checkpoint_generation
	var next_generation := prior_generation + 1 if not prior_slot.is_empty() else maxi(1, checkpoint_generation)
	checkpoint_slots[slot_index] = _checkpoint_slot_snapshot(slot_index, archive_base_id, save_position, next_generation)
	if _save_run(false, true):
		realm_save_cooldown = _save_cooldown_duration()
		return true
	if prior_slot.is_empty():
		checkpoint_slots[slot_index] = {}
	else:
		checkpoint_slots[slot_index] = prior_slot
	return false


func _activate_checkpoint_slot(slot_index: int) -> bool:
	if not _can_activate_checkpoint_slot(slot_index):
		return false
	var slot: Dictionary = checkpoint_slots[slot_index]
	var position_values: Array = slot.get("position", [])
	if position_values.size() < 2:
		return false
	var prior_exists := checkpoint_exists
	var prior_base_id := checkpoint_base_id
	var prior_position := checkpoint_position
	var prior_generation := checkpoint_generation
	checkpoint_exists = true
	checkpoint_base_id = str(slot.get("base_id", BaseNetworkScript.COMMAND_ID))
	checkpoint_position = Vector2(float(position_values[0]), float(position_values[1]))
	checkpoint_generation = maxi(1, int(slot.get("generation", checkpoint_generation)))
	if _save_run(false, true):
		_sync_checkpoint_slot_zero()
		RealmSaveScript.clear_recovery(realm_id)
		return true
	checkpoint_exists = prior_exists
	checkpoint_base_id = prior_base_id
	checkpoint_position = prior_position
	checkpoint_generation = prior_generation
	return false


func _try_commit_realm_save_at_core() -> void:
	_try_commit_realm_save_at_archive()


func _try_commit_realm_save_at_archive() -> void:
	_try_commit_realm_save_slot(0)


func _try_commit_realm_save_slot(slot_index: int) -> void:
	if not _save_ready():
		if using_realm_archive:
			realm_archive_status.text = "COOLDOWN // %dS REMAINING" % ceili(realm_save_cooldown)
		else:
			core_base_status.text = "SAVE COOLDOWN // %dS REMAINING" % ceili(realm_save_cooldown)
	elif _commit_realm_save_to_slot(slot_index):
		var slot_num := slot_index + 1
		if slot_index == 0:
			discovery_alert = "REALM CHECKPOINT SAVED // %s // GEN %d" % [_base_short_name(checkpoint_base_id), checkpoint_generation]
		else:
			var stored_gen := int(checkpoint_slots[slot_index].get("generation", 0))
			discovery_alert = "ARCHIVE SLOT %d STORED // %s // GEN %d" % [slot_num, _base_short_name(str(checkpoint_slots[slot_index].get("base_id", ""))), stored_gen]
		discovery_alert_time = 4.0
		if using_realm_archive:
			_refresh_realm_archive_panel()
		elif using_core_base:
			core_base_status.text = "REALM SAVED // GENERATION %d" % checkpoint_generation
			_refresh_core_base_panel()
	else:
		if using_realm_archive:
			realm_archive_status.text = "SAVE FAILED // CHECK STORAGE"
		else:
			core_base_status.text = "SAVE FAILED // CHECK STORAGE"


func _try_activate_checkpoint_slot(slot_index: int) -> void:
	if _activate_checkpoint_slot(slot_index):
		discovery_alert = "CHECKPOINT ANCHOR MOVED TO SLOT %d // GEN %d" % [slot_index + 1, checkpoint_generation]
		discovery_alert_time = 4.0
		if using_realm_archive:
			_refresh_realm_archive_panel()
	else:
		if using_realm_archive:
			realm_archive_status.text = "ACTIVATION FAILED // SLOT EMPTY"


func _commit_checkpoint_at(save_position: Vector2, base_id: String) -> bool:
	var prior_exists := checkpoint_exists
	var prior_base_id := checkpoint_base_id
	var prior_position := checkpoint_position
	var prior_generation := checkpoint_generation
	checkpoint_exists = true
	checkpoint_base_id = base_id
	checkpoint_position = save_position
	checkpoint_generation += 1
	if _save_run(false, true):
		_sync_checkpoint_slot_zero()
		RealmSaveScript.clear_recovery(realm_id)
		return true
	checkpoint_exists = prior_exists
	checkpoint_base_id = prior_base_id
	checkpoint_position = prior_position
	checkpoint_generation = prior_generation
	return false

func _handle_player_death() -> void:
	if not checkpoint_exists:
		game_over = true
		using_core_base = false
		using_foundry = false
		game_over_label.text = "NO FIELD SAVE · REALM LOST\nREST AT A FIELD HUT OR SAVE AT AN ACTIVE CORE"
		game_over_panel.visible = true
		game_over_panel.get_node("Buttons/Retry").grab_focus()
		return
	var death_position := player_position
	var death_cargo := _capture_backpack_cargo()
	var next_epoch := encounter_epoch + 1
	if not _load_run():
		game_over = true
		game_over_label.text = "CHECKPOINT RECOVERY FAILED\nRETURN TO MAIN MENU"
		game_over_panel.visible = true
		return
	_clear_backpack_cargo()
	encounter_epoch = next_epoch
	var cache_position := _nearest_recovery_position(death_position)
	recovery_cache = {
		"active": _cargo_units(death_cargo) > 0,
		"position": cache_position,
		"remaining": RECOVERY_LIFETIME,
		"cargo": death_cargo,
	}
	player_position = checkpoint_position
	player_camera.position = player_position
	player_health = 100.0
	player_invulnerability = 3.0
	_sync_hud_motion_displays()
	_clear_bullets()
	sparks.clear()
	_clear_runtime_combat_fx()
	_remix_enemy_patterns(encounter_epoch)
	_stabilize_post_death_respawn()
	_write_recovery_journal()
	discovery_alert = "RESURRECTED AT LAST SAVE // BACKPACK DROPPED"
	discovery_alert_time = 5.0
	_burst(player_position, Color("9acbff"), 22, 76.0)


func _collect_recovery_cache() -> void:
	if not bool(recovery_cache.get("active", false)):
		return
	var cargo: Dictionary = recovery_cache.get("cargo", {})
	var collected_units := 0
	for category: String in ["raw", "refined"]:
		var inventory: Dictionary = cargo.get(category, {})
		for material_id: String in inventory.keys():
			var take := mini(maxi(0, int(inventory[material_id])), _backpack_free())
			if take <= 0:
				continue
			if category == "raw":
				material_economy.raw[material_id] = int(material_economy.raw.get(material_id, 0)) + take
			else:
				material_economy.refined[material_id] = int(material_economy.refined.get(material_id, 0)) + take
			inventory[material_id] = int(inventory[material_id]) - take
			collected_units += take
	var stacks: Array = cargo.get("stacks", [])
	if stacks.is_empty():
		## Legacy kits dict → stacks
		var kits: Dictionary = cargo.get("kits", {})
		for stock_id: String in kits.keys():
			var amount := maxi(0, int(kits[stock_id]))
			while amount > 0:
				var chunk := mini(OperatorLoadoutScript.STACK_MAX, amount)
				stacks.append(OperatorLoadoutScript.make_stack(OperatorLoadoutScript.KIND_DEPLOYABLE, stock_id, chunk))
				amount -= chunk
			kits[stock_id] = 0
		cargo["kits"] = kits
	var remaining_stacks: Array = []
	for entry: Variant in stacks:
		if not entry is Dictionary:
			continue
		var d: Dictionary = entry
		var count := int(d.get("count", 0))
		if count <= 0:
			continue
		var left := operator_loadout.add_stacks(d)
		collected_units += count - left
		if left > 0:
			d = d.duplicate(true)
			d["count"] = left
			remaining_stacks.append(d)
	cargo["stacks"] = remaining_stacks
	_sync_deployable_mirror()
	recovery_cache["cargo"] = cargo
	if _cargo_units(cargo) <= 0:
		recovery_cache["active"] = false
		recovery_cache["remaining"] = 0.0
		discovery_alert = "BACKPACK RECOVERED // DEATH MARKER CLEARED"
	else:
		discovery_alert = "RECOVERED %d // PACK FULL // CACHE REMAINS" % collected_units
	discovery_alert_time = 3.0
	_write_recovery_journal()


func _update_recovery_cache(delta: float) -> void:
	if not bool(recovery_cache.get("active", false)):
		return
	var remaining := maxf(0.0, float(recovery_cache.get("remaining", 0.0)) - delta)
	recovery_cache["remaining"] = remaining
	if remaining <= 0.0:
		recovery_cache["active"] = false
		recovery_cache["cargo"] = {}
		discovery_alert = "RECOVERY CACHE EXPIRED // CARGO LOST"
		discovery_alert_time = 4.0
		_write_recovery_journal()
		return
	var cache_position: Vector2 = recovery_cache.get("position", Vector2.ZERO)
	if player_position.distance_to(cache_position) <= 13.0:
		_collect_recovery_cache()
		return
	recovery_journal_elapsed += delta
	if recovery_journal_elapsed >= 15.0:
		recovery_journal_elapsed = 0.0
		_write_recovery_journal()


func _stabilize_post_death_respawn() -> void:
	encounter_load_grace = 8.0
	spawn_cooldown = maxf(spawn_cooldown, 8.0)
	activation_spawn_cooldown = maxf(activation_spawn_cooldown, 8.0)
	player_invulnerability = maxf(player_invulnerability, 4.0)
	for spider in enemies:
		spider.attack_cooldown = maxf(spider.attack_cooldown, 4.0)
		if spider.position.distance_to(checkpoint_position) <= 220.0:
			spider.attack_cooldown = maxf(spider.attack_cooldown, 8.0)
			spider.leap_cooldown = maxf(spider.leap_cooldown, 4.0)
			spider.spit_cooldown = maxf(spider.spit_cooldown, 4.0)


func _remix_enemy_patterns(epoch: int) -> void:
	if epoch <= 0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = int(run_seed) ^ int(checkpoint_generation * 7919) ^ int(epoch * 104729)
	var active_bases: Array[String] = base_network.active_ids(true)
	for enemy_index in range(enemies.size()):
		var spider: Spider = enemies[enemy_index]
		if spider.role == ROLE_GUARDIAN or not spider.guardian_site_id.is_empty():
			continue
		if not grid.spawn_cells.is_empty():
			var spawn_cell := _resolve_wave_spawn_cell(enemy_index + epoch * 11)
			var remixed_position := _spider_spawn_position(spawn_cell, enemy_index + epoch * 11, run_seed)
			if _valid_spider_spawn_position(remixed_position):
				spider.position = remixed_position
		if not active_bases.is_empty():
			spider.target_base_id = active_bases[rng.randi_range(0, active_bases.size() - 1)]
		spider.target_turret_cell = Vector2i(-1, -1)
		spider.attack_cooldown = rng.randf_range(0.25, 1.5)
		spider.leap_cooldown = rng.randf_range(1.0, 3.5) if spider.role == ROLE_LEAPER else 0.0
		spider.spit_cooldown = rng.randf_range(1.0, 3.5) if spider.role == ROLE_SPITTER else 0.0
		if spider.is_explorer and not explorer_targets.is_empty():
			spider.explorer_route_index = rng.randi_range(0, explorer_targets.size() - 1)
			spider.explorer_route_stride = 1 + rng.randi_range(0, maxi(0, explorer_targets.size() - 1))
	for nest: BroodNest in brood_nests:
		nest.spawn_cooldown = rng.randf_range(7.0, 22.0)


func _serialize_structures() -> Array[Dictionary]:
	var structure_values: Array[Dictionary] = []
	for structure in structures:
		var payload := {
			"kind": structure.kind, "cell": [structure.cell.x, structure.cell.y],
			"health": structure.health, "max_health": structure.max_health,
			"level": structure.level, "base_id": structure.base_id,
			"cooldown": structure.cooldown,
			"aim_direction": [structure.aim_direction.x, structure.aim_direction.y],
			"inventory": structure.inventory,
			"chest_capacity": structure.chest_capacity,
			"size": [structure.size.x, structure.size.y],
			"rotated": structure.rotated,
			"is_open": structure.is_open,
			"lantern_color_id": structure.lantern_color_id,
			"is_ruin": structure.is_ruin,
			"fortress_chest": structure.fortress_chest,
			"fortress_reward_claimed": structure.fortress_reward_claimed,
		}
		if structure.kind == BUILD_FOUNDRY:
			FoundryUnitScript.ensure_state(structure)
			payload["foundry_state"] = FoundryUnitScript.serialize_state(structure)
		structure_values.append(payload)
	return structure_values


func _save_run(final_state: bool = false, checkpoint_commit: bool = false) -> bool:
	if SAVE_VERSION != RealmSaveScript.SAVE_SCHEMA:
		push_error("Save contract mismatch: gameplay %d, storage %d" % [SAVE_VERSION, RealmSaveScript.SAVE_SCHEMA])
		return false
	if not is_instance_valid(grid) or not is_instance_valid(base_network) or (game_over and not final_state):
		return false
	if not checkpoint_commit and not final_state:
		if not checkpoint_exists:
			return false
	if final_state and not checkpoint_exists:
		return false
	var structure_values := _serialize_structures()
	var enemy_values: Array[Dictionary] = []
	for spider in enemies:
		# Scouts and other short-lived probes are population ecology, not permanent
		# realm objects. Exploration may create a fresh deterministic scout later.
		if spider.is_scout:
			continue
		enemy_values.append({
			"position": [spider.position.x, spider.position.y],
			"health": spider.health, "max_health": spider.max_health,
			"speed": spider.speed, "radius": spider.radius,
			"big": spider.big, "role": spider.role, "biome_id": spider.biome_id,
			"target_base_id": spider.target_base_id,
			"guardian_site_id": spider.guardian_site_id,
			"brood_nest_cell": [spider.brood_nest_cell.x, spider.brood_nest_cell.y],
			"hunts_turrets": spider.hunts_turrets,
			"hunts_player": spider.hunts_player,
			"is_explorer": spider.is_explorer,
			"explorer_duration": spider.explorer_duration,
			"explorer_route_index": spider.explorer_route_index,
			"explorer_route_stride": spider.explorer_route_stride,
			"explorer_legs_remaining": spider.explorer_legs_remaining,
			"is_brood_carrier": spider.is_brood_carrier,
			"carrier_target_cell": [spider.carrier_target_cell.x, spider.carrier_target_cell.y],
			"carrier_channel": spider.carrier_channel,
			"counts_for_wave": spider.counts_for_wave,
			"cleanup_recalled": spider.cleanup_recalled,
			"target_turret_cell": [spider.target_turret_cell.x, spider.target_turret_cell.y],
			"target_torch_cell": [spider.target_torch_cell.x, spider.target_torch_cell.y],
			"attack_cooldown": spider.attack_cooldown,
			"leap_cooldown": spider.leap_cooldown,
			"spit_cooldown": spider.spit_cooldown,
			"next_summon_ratio": spider.next_summon_ratio,
		})
	var brood_nest_values: Array[Dictionary] = []
	for nest: BroodNest in brood_nests:
		brood_nest_values.append({
			"cell": [nest.cell.x, nest.cell.y],
			"health": nest.health,
			"max_health": nest.max_health,
			"maturity": nest.maturity,
			"spawn_cooldown": nest.spawn_cooldown,
			"birth_wave": nest.birth_wave,
			"aggressive": nest.aggressive,
			"boss_spawned": nest.boss_spawned,
			"is_lair": nest.is_lair,
			"apex_id": nest.apex_id,
		})
	var pickup_values: Array[Dictionary] = []
	for pickup: Pickup in pickups:
		pickup_values.append({
			"position": [pickup.position.x, pickup.position.y],
			"velocity": [pickup.velocity.x, pickup.velocity.y],
			"kind": pickup.kind,
			"amount": pickup.amount,
			"life": pickup.life,
			"phase": pickup.phase,
		})
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"realm_id": realm_id,
		"realm_title": grid.realm_title,
		"realm_traits": grid.realm_traits,
		"realm_ended": final_state or realm_ended,
		"checkpoint_exists": checkpoint_exists,
		"checkpoint_base_id": checkpoint_base_id,
		"checkpoint_position": [checkpoint_position.x, checkpoint_position.y],
		"checkpoint_generation": checkpoint_generation,
		"checkpoint_slots": _serialize_checkpoint_slots(),
		"realm_save_cooldown": realm_save_cooldown,
		"encounter_epoch": encounter_epoch,
		"recovery_cache": _serialize_recovery_cache(),
		"saved_unix": int(Time.get_unix_time_from_system()),
		"difficulty_id": difficulty_id,
		"run_seed": run_seed,
		"realm_width": grid.width,
		"realm_height": grid.height,
		"generator_version": WorldGridScript.GENERATOR_VERSION,
		"terrain_delta_count": grid.cell_deltas.size(),
		"hive_awareness": hive_awareness.serialize(),
		"wave": wave,
		"encounters_completed": encounters_completed,
		"wave_active": wave_active,
		"spawns_remaining": spawns_remaining,
		"spawn_cooldown": spawn_cooldown,
		"bosses_remaining": bosses_remaining,
		"spawn_sequence": spawn_sequence,
		"current_wave_plan": current_wave_plan.duplicate(true),
		"wave_reward_claimed": wave_reward_claimed,
		"brood_carriers_remaining": brood_carriers_remaining,
		"wave_cleanup_elapsed": wave_cleanup_elapsed,
		"activation_spawn_cooldown": activation_spawn_cooldown,
		"activation_spawn_sequence": activation_spawn_sequence,
		"breached": breached,
		"opening_contact_stage": opening_contact_stage,
		"opening_contact_timer": opening_contact_timer,
		"merchant_invited": merchant_invited,
		"merchant_store_kit_issued": merchant_store_kit_issued,
		"first_breach_cell": [first_breach_cell.x, first_breach_cell.y],
		"first_mine_earned": first_mine_earned,
		"onboard_step": operator_onboard.serialize() if operator_onboard else OperatorOnboardScript.STEP_DONE,
		"starting_core_cell": [grid.core_cell.x, grid.core_cell.y],
		"scrap": scrap,
		"score": score,
		"player_position": [checkpoint_position.x, checkpoint_position.y] if checkpoint_exists and not final_state else [player_position.x, player_position.y],
		"player_health": player_health,
		"sprint_energy": sprint_energy,
		"mining_speed_tier": mining_speed_tier,
		"mining_emitter_tier": mining_emitter_tier,
		"backpack_tier": backpack_tier,
		"foundry_kit_available": foundry_kit_available,
		"construction_unlocks": construction_unlocks.duplicate(true),
		"deployable_stock": operator_loadout.deployable_stock_mirror(deployable_stock.keys()) if operator_loadout else deployable_stock.duplicate(true),
		"deployable_storage_tiers": deployable_storage_tiers.duplicate(true),
		"hotbar_stacks": operator_loadout.serialize() if operator_loadout else {},
		"placed_block_cells": placeable_blocks.serialize() if placeable_blocks else {},
		"torch_starter_issued": torch_starter_issued,
		"controls_remap_seen": controls_remap_seen,
		"current_weapon": current_weapon,
		"unlocked_weapons": unlocked_weapons,
		"weapon_tiers": weapon_tiers,
		"mag_upgrade_tiers": mag_upgrade_tiers,
		"flame_fuel": flame_fuel,
		"flamethrower_unlocked": flamethrower_unlocked,
		"lantern_upgrade_target_cell": [lantern_upgrade_target_cell.x, lantern_upgrade_target_cell.y],
		"player_style_id": player_style_id,
		"unlocked_player_styles": unlocked_player_styles,
		"ammo": [magazine, reserve_ammo, shotgun_magazine, shotgun_reserve, smg_magazine, smg_reserve, railgun_magazine, railgun_reserve],
		"laser_energy": laser_energy,
		"cell_deltas": _encode_cell_dictionary(grid.cell_deltas),
		"spawn_cells": _encode_cells(grid.spawn_cells),
		"revealed_discoveries": _encode_cell_dictionary(grid.revealed_discoveries),
		"mined_minerals": _encode_cell_dictionary(grid.mined_minerals),
		"explored_sectors": _encode_cell_dictionary(explored_sectors),
		"ruined_fortress_regions": _encode_cell_dictionary(ruined_fortress_regions),
		"exploration_find_count": exploration_find_count,
		"visited_regions": _encode_cell_dictionary(grid.visited_regions),
		"material_economy": material_economy.serialize(),
		"structures": structure_values,
		"enemies": enemy_values,
		"brood_nests": brood_nest_values,
		"destroyed_brood_nests": _encode_cell_dictionary(destroyed_brood_nests),
		"brood_escalation": brood_escalation,
		"nest_milestones_spawned": _serialize_nest_milestones_spawned(),
		"nest_kills_total": nest_kills_total,
		"lair_cycle_pending": lair_cycle_pending,
		"apex_phase": apex_phase,
		"boss_components_carried": boss_components_carried,
		"boss_components_deposited": boss_components_deposited,
		"mecha_level": mecha_level,
		"expedition_xp": expedition_xp,
		"expedition_level": expedition_level,
		"skill_points": skill_points,
		"skill_unlocks": skill_unlocks.duplicate(),
		"surface_portal_cell": [surface_portal_cell.x, surface_portal_cell.y],
		"pickups": pickup_values,
		"base_network": base_network.serialize(),
	}
	if not RealmSaveScript.write_realm(realm_id, data):
		push_warning("Could not write the protected realm save")
		return false
	return true


func _finalize_loadout_from_save() -> void:
	if operator_loadout == null:
		operator_loadout = OperatorLoadoutScript.new()
	operator_loadout.set_pack_tier(backpack_tier)
	var saved_loadout: Variant = _pending_loadout_data
	if saved_loadout is Dictionary and not saved_loadout.is_empty() and saved_loadout.has("hotbar"):
		operator_loadout.deserialize(saved_loadout)
	else:
		operator_loadout.migrate_from_deployable_stock(_pending_loadout_stock, _pending_loadout_weapon, unlocked_weapons)
		if operator_loadout.count_of(OperatorLoadoutScript.KIND_DEPLOYABLE, TORCH_STOCK_ID) > 0:
			torch_starter_issued = true
	operator_loadout.set_pack_tier(backpack_tier)
	_sync_deployable_mirror()
	_sync_current_weapon_from_hotbar()
	_pending_loadout_data = {}
	_pending_loadout_stock.clear()
	if not controls_remap_seen:
		controls_remap_seen = true
		if operator_onboard == null or operator_onboard.is_done():
			discovery_alert = "CONTROLS UPDATED // TAB/SCROLL CYCLES CUTTER AND GUNS // 1-9 BUILD // [I] PACK"
			discovery_alert_time = 5.5


func _torch_deployed_count() -> int:
	var deployed := 0
	for structure: Structure in structures:
		if structure.kind == BUILD_TORCH:
			deployed += 1
	return deployed


func _canonical_chest_capacity(kind: int) -> int:
	match kind:
		BUILD_CHEST_SMALL: return 100
		BUILD_CHEST_MEDIUM: return 300
		BUILD_CHEST_LARGE: return 800
	return 0


func _sanitize_chest_inventory(saved_value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not saved_value is Dictionary:
		return result
	var saved_inventory: Dictionary = saved_value
	for material_id: String in MaterialEconomyScript.RAW_ORDER:
		var amount := maxi(0, int(saved_inventory.get(material_id, 0)))
		if amount > 0:
			result[material_id] = amount
	for material_id: String in MaterialEconomyScript.REFINED_ORDER:
		var amount := maxi(0, int(saved_inventory.get(material_id, 0)))
		if amount > 0:
			result[material_id] = amount
	return result


func _restored_structure_overlaps(cell: Vector2i, size: Vector2i) -> bool:
	for ox in range(size.x):
		for oy in range(size.y):
			var covered_cell := cell + Vector2i(ox, oy)
			if not grid.in_bounds(covered_cell):
				return true
			for existing: Structure in structures:
				if _structure_covers_cell(existing, covered_cell):
					return true
	return false


func _restore_structures(saved_values: Variant) -> void:
	structures.clear()
	if not saved_values is Array:
		return
	for saved_structure_value: Variant in saved_values:
		if not saved_structure_value is Dictionary:
			continue
		var saved_structure: Dictionary = saved_structure_value
		var kind := int(saved_structure.get("kind", -1))
		if kind < BUILD_BARRICADE or kind > BUILD_MERCHANT_STORE:
			continue
		var saved_cell_value: Variant = saved_structure.get("cell", [])
		if not saved_cell_value is Array:
			continue
		var saved_cell: Array = saved_cell_value
		if saved_cell.size() != 2:
			continue
		var structure := Structure.new()
		structure.kind = kind
		structure.cell = Vector2i(int(saved_cell[0]), int(saved_cell[1]))
		structure.rotated = bool(saved_structure.get("rotated", false)) if kind == BUILD_HEAVY_DOORWAY else false
		if kind in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET]:
			structure.level = clampi(int(saved_structure.get("level", 1)), 1, 4)
		elif kind == BUILD_HEAVY_DOORWAY:
			structure.level = clampi(int(saved_structure.get("level", 1)), 1, 3)
		elif kind == BUILD_FOUNDRY:
			if material_economy.foundry_tier <= 0:
				continue
			structure.level = clampi(int(saved_structure.get("level", 1)), 1, material_economy.foundry_tier)
			FoundryUnitScript.restore_state(structure, saved_structure.get("foundry_state", {}), structure.level, material_economy)
		elif kind == BUILD_PERSONAL_BASE:
			structure.level = clampi(int(saved_structure.get("level", 1)), 1, 3)
		elif kind == BUILD_TORCH:
			structure.level = clampi(int(saved_structure.get("level", 1)), 1, TORCH_DURABILITY.size() - 1)
			structure.lantern_color_id = clampi(int(saved_structure.get("lantern_color_id", 0)), 0, TORCH_COLOR_NAMES.size() - 1)
			var torch_tier_max := TORCH_DURABILITY[structure.level] * fortification_multiplier
			structure.max_health = maxf(torch_tier_max, float(saved_structure.get("max_health", torch_tier_max)))
		else:
			structure.level = 1
		structure.size = _footprint_for_doorway_level(structure.level, structure.rotated) if kind == BUILD_HEAVY_DOORWAY else (_footprint_for_build(kind, false))
		if _restored_structure_overlaps(structure.cell, structure.size):
			continue
		if kind != BUILD_TORCH:
			structure.max_health = maxf(1.0, float(saved_structure.get("max_health", saved_structure.get("health", 72.0))))
		var restored_health := float(saved_structure.get("health", structure.max_health))
		if restored_health <= 0.0:
			continue
		structure.health = clampf(restored_health, 1.0, structure.max_health)
		structure.position = grid.cell_to_world(structure.cell)
		structure.cooldown = maxf(0.0, float(saved_structure.get("cooldown", 0.0)))
		var saved_aim_value: Variant = saved_structure.get("aim_direction", [])
		if saved_aim_value is Array:
			var saved_aim: Array = saved_aim_value
			if saved_aim.size() == 2:
				var restored_aim := Vector2(float(saved_aim[0]), float(saved_aim[1]))
				if not restored_aim.is_zero_approx():
					structure.aim_direction = restored_aim.normalized()
		structure.base_id = base_network.powered_base_for(structure.cell)
		structure.is_ruin = bool(saved_structure.get("is_ruin", false))
		structure.fortress_chest = bool(saved_structure.get("fortress_chest", false))
		structure.fortress_reward_claimed = bool(saved_structure.get("fortress_reward_claimed", false))
		structure.powered = kind in [BUILD_PERSONAL_BASE, BUILD_MERCHANT_STORE] or structure.fortress_chest or not structure.base_id.is_empty()
		structure.chest_capacity = _canonical_chest_capacity(kind)
		if structure.chest_capacity > 0:
			# Preserve legitimate legacy overflow; deposits remain locked until space exists.
			structure.inventory = _sanitize_chest_inventory(saved_structure.get("inventory", {}))
		structure.is_open = bool(saved_structure.get("is_open", false)) if kind == BUILD_HEAVY_DOORWAY else false
		structures.append(structure)
	_invalidate_structure_spatial_buckets()


func _load_run() -> bool:
	var data: Dictionary = RealmSaveScript.load_active_save()
	if data.is_empty():
		push_warning("Ignoring an unreadable or altered Crawl Brawl realm")
		return false
	var saved_version: int = int(data.get("version", -1))
	if saved_version < MIN_SUPPORTED_SAVE_VERSION or saved_version > SAVE_VERSION or bool(data.get("realm_ended", false)):
		push_warning("Ignoring an incompatible Crawl Brawl save version")
		return false
	var legacy_upscale := _save_needs_realm_upscale(data)
	var source_realm_dimensions := _saved_realm_dimensions(data)
	if legacy_upscale:
		_apply_realm_upscale_to_save(data, source_realm_dimensions)
	var saved_seed := int(data.get("run_seed", 0))
	var saved_realm_id := str(data.get("realm_id", ""))
	if saved_seed <= 0 or saved_realm_id != RealmSaveScript.realm_id_for_seed(saved_seed):
		push_warning("Ignoring a realm with mismatched identity data")
		return false
	if not _validate_generator_contract(data):
		return false
	checkpoint_exists = bool(data.get("checkpoint_exists", saved_version < 5))
	if not checkpoint_exists:
		push_warning("Ignoring a realm without a committed checkpoint")
		return false
	checkpoint_base_id = str(data.get("checkpoint_base_id", BaseNetworkScript.COMMAND_ID))
	checkpoint_generation = maxi(1, int(data.get("checkpoint_generation", 1)))
	_migrate_checkpoint_slots(data)
	realm_save_cooldown = maxf(0.0, float(data.get("realm_save_cooldown", 0.0)))
	var legacy_save_cooldown := clampf(float(data.get("save_cooldown_remaining", 0.0)), 0.0, ShelterUnitScript.cooldown(3))
	if realm_save_cooldown <= 0.0 and legacy_save_cooldown > 0.0:
		realm_save_cooldown = legacy_save_cooldown
	encounter_epoch = maxi(0, int(data.get("encounter_epoch", 0)))
	var saved_checkpoint_position: Variant = data.get("checkpoint_position", [])
	if saved_checkpoint_position is Array and saved_checkpoint_position.size() == 2:
		checkpoint_position = Vector2(float(saved_checkpoint_position[0]), float(saved_checkpoint_position[1]))
	var saved_cells: Variant = data.get("cells", [])
	var saved_cell_deltas_value: Variant = data.get("cell_deltas", {})
	var saved_cell_deltas: Dictionary = saved_cell_deltas_value if saved_cell_deltas_value is Dictionary else {}
	var network_data: Dictionary = data.get("base_network", {})
	var terrain_payload_valid: bool = saved_cell_deltas_value is Dictionary if saved_version >= 4 else saved_cells.size() == source_realm_dimensions.x * source_realm_dimensions.y
	if not terrain_payload_valid or not base_network.restore(network_data):
		push_warning("Ignoring an incomplete Crawl Brawl save")
		return false
	difficulty_id = DIFFICULTY_PROFILE.normalize_id(str(data.get("difficulty_id", difficulty_id)))
	difficulty = DIFFICULTY_PROFILE.get_profile(difficulty_id)
	run_seed = saved_seed
	realm_id = saved_realm_id
	if not _terrain_preloaded:
		grid.generate_realm(run_seed, difficulty_id, saved_version >= 8)
		grid.core_cell = base_network.get_cell(BaseNetworkScript.COMMAND_ID)
		grid.configure_discoveries(run_seed, difficulty_id)
		if not _restore_terrain_from_save(data, saved_version, legacy_upscale, source_realm_dimensions, saved_cells):
			return false
	else:
		grid.core_cell = base_network.get_cell(BaseNetworkScript.COMMAND_ID)
		explored_sectors = _decode_cell_dictionary(data.get("explored_sectors", {}))
		ruined_fortress_regions = _decode_cell_dictionary(data.get("ruined_fortress_regions", {}))
		exploration_find_count = int(data.get("exploration_find_count", 0))
		for visited_region_value: Variant in grid.visited_regions.keys():
			discovered_biomes[visited_region_value] = grid.region_biome(visited_region_value)
		_reset_render_caches(true)
	wave = int(data.get("wave", 0))
	encounters_completed = maxi(0, int(data.get("encounters_completed", wave)))
	hive_awareness.restore(data.get("hive_awareness", {}), wave)
	wave_active = bool(data.get("wave_active", false))
	spawns_remaining = maxi(0, int(data.get("spawns_remaining", 0)))
	if wave_active:
		spawns_remaining = mini(spawns_remaining, hive_awareness.encounter_party_size())
	spawn_cooldown = maxf(0.0, float(data.get("spawn_cooldown", 0.0)))
	bosses_remaining = maxi(0, int(data.get("bosses_remaining", 0)))
	spawn_sequence = maxi(0, int(data.get("spawn_sequence", 0)))
	current_wave_plan = data.get("current_wave_plan", {}).duplicate(true)
	wave_reward_claimed = bool(data.get("wave_reward_claimed", false))
	brood_carriers_remaining = maxi(0, int(data.get("brood_carriers_remaining", 0)))
	wave_cleanup_elapsed = float(data.get("wave_cleanup_elapsed", 0.0))
	activation_spawn_cooldown = maxf(0.0, float(data.get("activation_spawn_cooldown", 0.0)))
	activation_spawn_sequence = maxi(0, int(data.get("activation_spawn_sequence", 0)))
	if not base_network.activation_base_id.is_empty() and activation_spawn_cooldown <= 0.0:
		activation_spawn_cooldown = 2.0
	if wave_active and (current_wave_plan.is_empty() or not current_wave_plan.has("spawn_count")):
		current_wave_plan = WaveDirectorScript.build_encounter_plan(
			difficulty_id,
			hive_awareness.awareness_tier,
			brood_escalation,
			maxi(1, encounters_completed),
			grid.spawn_cells.size()
		)
		grid.activate_lanes(int(current_wave_plan.get("active_lanes", 1)))
	else:
		_repair_wave_plan()
	breached = bool(data.get("breached", false))
	if data.has("opening_contact_stage"):
		opening_contact_stage = clampi(int(data.get("opening_contact_stage", 0)), 0, OPENING_CONTACT_PACKS.size())
		opening_contact_timer = float(data.get("opening_contact_timer", -1.0))
	else:
		# Existing DEV011 realms already survived their opening; never ambush a resumed save.
		opening_contact_stage = OPENING_CONTACT_PACKS.size() if breached else 0
		opening_contact_timer = -1.0
	merchant_invited = bool(data.get("merchant_invited", false))
	merchant_store_kit_issued = bool(data.get("merchant_store_kit_issued", false))
	var saved_breach_cell: Array = data.get("first_breach_cell", [])
	first_breach_cell = Vector2i(int(saved_breach_cell[0]), int(saved_breach_cell[1])) if saved_breach_cell.size() == 2 else Vector2i(-1, -1)
	first_mine_earned = bool(data.get("first_mine_earned", breached and first_breach_cell != Vector2i(-1, -1)))
	scrap = int(data.get("scrap", ScrapEconomyScript.START))
	_sync_hud_motion_displays()
	score = int(data.get("score", 0))
	player_health = float(data.get("player_health", 100.0))
	_clear_runtime_combat_fx()
	_clear_bullets()
	sprint_energy = clampf(float(data.get("sprint_energy", 100.0)), 0.0, 100.0)
	mining_speed_tier = clampi(int(data.get("mining_speed_tier", 1)), 1, 5)
	mining_emitter_tier = clampi(int(data.get("mining_emitter_tier", 1)), 1, 5)
	backpack_tier = clampi(int(data.get("backpack_tier", 1)), 1, 4)
	var saved_construction_unlocks: Dictionary = data.get("construction_unlocks", {})
	for construction_id: String in construction_unlocks.keys():
		construction_unlocks[construction_id] = bool(saved_construction_unlocks.get(construction_id, construction_id in ["granite_barrier", "steel_barrier"]))
	construction_unlocks["granite_barrier"] = true
	construction_unlocks["steel_barrier"] = true
	if merchant_invited:
		construction_unlocks[SettlementProgressionScript.MERCHANT_STORE_STOCK_ID] = true
	var saved_deployable_stock: Dictionary = data.get("deployable_stock", {})
	for stock_id: String in deployable_stock.keys():
		deployable_stock[stock_id] = maxi(0, int(saved_deployable_stock.get(stock_id, 0)))
	var saved_dep_storage_tiers: Dictionary = data.get("deployable_storage_tiers", {})
	for stock_id: String in deployable_storage_tiers.keys():
		deployable_storage_tiers[stock_id] = clampi(int(saved_dep_storage_tiers.get(stock_id, 0)), 0, 2)
	torch_starter_issued = bool(data.get("torch_starter_issued", false))
	controls_remap_seen = bool(data.get("controls_remap_seen", false))
	if placeable_blocks == null:
		placeable_blocks = PlaceableBlocksScript.new()
	placeable_blocks.deserialize(data.get("placed_block_cells", {}))
	## operator_loadout restored after unlocked_weapons below
	_pending_loadout_data = data.get("hotbar_stacks", {})
	_pending_loadout_stock = saved_deployable_stock.duplicate(true)
	_pending_loadout_weapon = int(data.get("current_weapon", WEAPON_PISTOL))
	var saved_position: Array = data.get("player_position", [])
	if saved_position.size() == 2:
		player_position = Vector2(float(saved_position[0]), float(saved_position[1]))
	if checkpoint_position == Vector2.ZERO:
		checkpoint_position = _checkpoint_anchor_position(checkpoint_base_id)
	player_position = checkpoint_position
	_restore_recovery_cache(data.get("recovery_cache", {}))
	current_weapon = clampi(int(data.get("current_weapon", WEAPON_PISTOL)), 0, WEAPON_COUNT - 1)
	var saved_unlocks: Array = data.get("unlocked_weapons", [])
	var saved_tiers: Array = data.get("weapon_tiers", [])
	_restore_bool_array(saved_unlocks, unlocked_weapons)
	_restore_int_array(saved_tiers, weapon_tiers)
	var saved_mag_tiers: Array = data.get("mag_upgrade_tiers", [])
	_restore_int_array(saved_mag_tiers, mag_upgrade_tiers)
	var saved_styles: Array = data.get("unlocked_player_styles", [])
	_restore_bool_array(saved_styles, unlocked_player_styles)
	unlocked_player_styles[0] = true
	player_style_id = clampi(int(data.get("player_style_id", 0)), 0, PLAYER_STYLE_NAMES.size() - 1)
	if not unlocked_player_styles[player_style_id]:
		player_style_id = 0
	_rebuild_player_armor_multipliers()
	var ammo: Array = data.get("ammo", [])
	if ammo.size() == 8:
		magazine = clampi(int(ammo[0]), 0, _weapon_mag_capacity(WEAPON_PISTOL))
		reserve_ammo = clampi(int(ammo[1]), 0, AMMO_RESERVE_CAPS[WEAPON_PISTOL])
		shotgun_magazine = clampi(int(ammo[2]), 0, _weapon_mag_capacity(WEAPON_SHOTGUN))
		shotgun_reserve = clampi(int(ammo[3]), 0, AMMO_RESERVE_CAPS[WEAPON_SHOTGUN])
		smg_magazine = clampi(int(ammo[4]), 0, _weapon_mag_capacity(WEAPON_SMG))
		smg_reserve = clampi(int(ammo[5]), 0, AMMO_RESERVE_CAPS[WEAPON_SMG])
		railgun_magazine = clampi(int(ammo[6]), 0, _weapon_mag_capacity(WEAPON_RAILGUN))
		railgun_reserve = clampi(int(ammo[7]), 0, AMMO_RESERVE_CAPS[WEAPON_RAILGUN])
	flame_fuel = clampi(int(data.get("flame_fuel", 0)), 0, FLAMETHROWER_FUEL_CAP)
	flamethrower_unlocked = bool(data.get("flamethrower_unlocked", false))
	unlocked_weapons[WEAPON_FLAMETHROWER] = flamethrower_unlocked
	if operator_onboard == null:
		operator_onboard = OperatorOnboardScript.new()
	if data.has("onboard_step"):
		operator_onboard.restore(int(data.get("onboard_step", OperatorOnboardScript.STEP_DONE)), breached, first_mine_earned)
	else:
		operator_onboard.restore(-1, breached, first_mine_earned)
	_finalize_loadout_from_save()
	var saved_lantern_target: Array = data.get("lantern_upgrade_target_cell", [])
	lantern_upgrade_target_cell = Vector2i(int(saved_lantern_target[0]), int(saved_lantern_target[1])) if saved_lantern_target.size() == 2 else Vector2i(-1, -1)
	laser_energy = clampf(float(data.get("laser_energy", 100.0)), 0.0, 100.0)
	expedition_xp = maxi(0, int(data.get("expedition_xp", 0)))
	expedition_level = maxi(0, int(data.get("expedition_level", data.get("upgrade_count", 0))))
	skill_points = maxi(0, int(data.get("skill_points", data.get("pending_upgrade_picks", 0))))
	skill_unlocks.clear()
	var raw_unlocks: Array[String] = []
	for saved_unlock: Variant in data.get("skill_unlocks", []):
		var unlock_id := str(saved_unlock)
		if ProgressionTreeScript.node(unlock_id).is_empty() or unlock_id in raw_unlocks:
			continue
		raw_unlocks.append(unlock_id)
	for unlock_id: String in ProgressionTreeScript.repair_unlock_order(raw_unlocks):
		skill_unlocks.append(unlock_id)
	_rebuild_progression_multipliers()
	_reconcile_expedition_xp(-1, false)
	pickups.clear()
	for saved_pickup_value: Variant in data.get("pickups", []):
		var saved_pickup: Dictionary = saved_pickup_value
		var pickup_position: Array = saved_pickup.get("position", [])
		var pickup_velocity: Array = saved_pickup.get("velocity", [])
		if pickup_position.size() != 2:
			continue
		var pickup := Pickup.new()
		pickup.position = Vector2(float(pickup_position[0]), float(pickup_position[1]))
		if pickup_velocity.size() == 2:
			pickup.velocity = Vector2(float(pickup_velocity[0]), float(pickup_velocity[1]))
		pickup.kind = str(saved_pickup.get("kind", PICKUP_PISTOL_AMMO))
		pickup.amount = maxi(1, int(saved_pickup.get("amount", 1)))
		pickup.life = maxf(0.1, float(saved_pickup.get("life", 60.0)))
		pickup.phase = float(saved_pickup.get("phase", 0.0))
		pickups.append(pickup)
	grid.spawn_cells = _decode_cells(data.get("spawn_cells", []))
	if grid.spawn_cells.is_empty():
		grid.spawn_cells = [grid.spawn_cell]
	else:
		grid.spawn_cell = grid.spawn_cells[0]
	grid.active_lane_count = clampi(grid.active_lane_count, 1, maxi(1, grid.spawn_cells.size()))
	destroyed_brood_nests = _decode_cell_dictionary(data.get("destroyed_brood_nests", {}))
	brood_escalation = maxi(0, int(data.get("brood_escalation", 0)))
	nest_milestones_spawned.clear()
	for milestone_value: Variant in data.get("nest_milestones_spawned", []):
		nest_milestones_spawned[int(milestone_value)] = true
	nest_kills_total = maxi(0, int(data.get("nest_kills_total", brood_escalation)))
	lair_cycle_pending = bool(data.get("lair_cycle_pending", false))
	apex_phase = bool(data.get("apex_phase", false))
	boss_components_carried = data.get("boss_components_carried", {}).duplicate(true)
	boss_components_deposited = data.get("boss_components_deposited", {}).duplicate(true)
	mecha_level = clampi(int(data.get("mecha_level", 0)), 0, 3)
	# BV5.8 retires the old beta surface-portal shortcut. Preserve the serialized
	# field for save compatibility, but surface access now belongs to the future
	# Final Five -> excavation-technology campaign gate.
	surface_portal_cell = Vector2i(-1, -1)
	beta_teaser_active = false
	brood_nests.clear()
	for saved_nest_value: Variant in data.get("brood_nests", []):
		var saved_nest: Dictionary = saved_nest_value
		var saved_nest_cell: Array = saved_nest.get("cell", [])
		if saved_nest_cell.size() != 2:
			continue
		var nest := BroodNest.new()
		nest.cell = Vector2i(int(saved_nest_cell[0]), int(saved_nest_cell[1]))
		if destroyed_brood_nests.has(nest.cell):
			continue
		nest.max_health = BROOD_NEST_HEALTH if saved_version < 9 else maxf(1.0, float(saved_nest.get("max_health", BROOD_NEST_HEALTH)))
		nest.health = nest.max_health if saved_version < 9 else clampf(float(saved_nest.get("health", nest.max_health)), 1.0, nest.max_health)
		nest.maturity = clampf(float(saved_nest.get("maturity", 1.0)), 0.0, 1.0)
		nest.spawn_cooldown = maxf(8.0, float(saved_nest.get("spawn_cooldown", 20.0)))
		nest.birth_wave = maxi(0, int(saved_nest.get("birth_wave", wave)))
		nest.aggressive = bool(saved_nest.get("aggressive", false))
		nest.boss_spawned = bool(saved_nest.get("boss_spawned", false))
		nest.is_lair = bool(saved_nest.get("is_lair", false))
		nest.apex_id = str(saved_nest.get("apex_id", ""))
		brood_nests.append(nest)
		grid.discovery_cells[nest.cell] = "nest"
		if nest.maturity >= 1.0:
			grid.register_spawn_cell(nest.cell)
	if not data.has("brood_nests"):
		_reconcile_legacy_brood_nests()
	grid.activate_prepare_zone()
	_ensure_boot_render_window()
	grid.try_expand_prepare_zone(grid.world_to_cell(player_position))
	var corridor_cells: Array = []
	for cell_value: Variant in grid.spawn_cells:
		corridor_cells.append(cell_value)
	corridor_cells.append(grid.core_cell)
	grid.activate_corridor_preload_burst(corridor_cells, _region_stream_radius())
	active_player_region = grid.region_for_cell(grid.world_to_cell(player_position))
	material_economy.restore(data.get("material_economy", {}))
	_restore_structures(data.get("structures", []))
	var restored_merchant_index: int = _merchant_store_index()
	if restored_merchant_index >= 0:
		merchant_invited = true
		merchant_store_kit_issued = true
		construction_unlocks[SettlementProgressionScript.MERCHANT_STORE_STOCK_ID] = true
	_resolve_checkpoint_spawn()
	_migrate_legacy_save_cooldown(legacy_save_cooldown)
	_migrate_legacy_foundry_buffers()
	foundry_kit_available = bool(data.get("foundry_kit_available", false)) and int(deployable_stock.get("foundry", 0)) <= 0
	if foundry_kit_available and _can_accept_kit("foundry"):
		if grant_kit("foundry", 1) <= 0:
			foundry_kit_available = false
	enemies.clear()
	for saved_enemy_value: Variant in data.get("enemies", []):
		var saved_enemy: Dictionary = saved_enemy_value
		var saved_enemy_position: Array = saved_enemy.get("position", [])
		if saved_enemy_position.size() != 2:
			continue
		var spider := Spider.new()
		spider.position = Vector2(float(saved_enemy_position[0]), float(saved_enemy_position[1]))
		spider.health = maxf(1.0, float(saved_enemy.get("health", 20.0)))
		spider.max_health = maxf(spider.health, float(saved_enemy.get("max_health", spider.health)))
		spider.speed = maxf(1.0, float(saved_enemy.get("speed", 26.0)))
		spider.radius = maxf(1.0, float(saved_enemy.get("radius", 5.0)))
		spider.big = bool(saved_enemy.get("big", false))
		spider.role = clampi(int(saved_enemy.get("role", ROLE_SWARM)), ROLE_SWARM, ROLE_GUARDIAN)
		var saved_biome_id := int(saved_enemy.get("biome_id", -1))
		spider.biome_id = saved_biome_id if saved_biome_id >= 0 and saved_biome_id < BiomeBestiaryScript.BIOME_SLUGS.size() else _biome_for_cell(grid.world_to_cell(spider.position))
		spider.target_base_id = str(saved_enemy.get("target_base_id", BaseNetworkScript.COMMAND_ID))
		spider.guardian_site_id = str(saved_enemy.get("guardian_site_id", ""))
		var saved_brood_nest_cell: Array = saved_enemy.get("brood_nest_cell", [])
		if saved_brood_nest_cell.size() == 2:
			spider.brood_nest_cell = Vector2i(int(saved_brood_nest_cell[0]), int(saved_brood_nest_cell[1]))
		spider.hunts_turrets = bool(saved_enemy.get("hunts_turrets", false))
		spider.hunts_player = bool(saved_enemy.get("hunts_player", false))
		spider.is_explorer = bool(saved_enemy.get("is_explorer", false))
		spider.explorer_duration = maxf(0.0, float(saved_enemy.get("explorer_duration", 0.0)))
		spider.explorer_route_index = int(saved_enemy.get("explorer_route_index", -1))
		spider.explorer_route_stride = maxi(1, int(saved_enemy.get("explorer_route_stride", 1)))
		spider.explorer_legs_remaining = maxi(0, int(saved_enemy.get("explorer_legs_remaining", 0)))
		spider.is_brood_carrier = bool(saved_enemy.get("is_brood_carrier", false))
		var saved_carrier_target: Array = saved_enemy.get("carrier_target_cell", [])
		if saved_carrier_target.size() == 2:
			spider.carrier_target_cell = Vector2i(int(saved_carrier_target[0]), int(saved_carrier_target[1]))
			if spider.is_brood_carrier:
				grid.discovery_cells[spider.carrier_target_cell] = "nest"
		spider.carrier_channel = clampf(float(saved_enemy.get("carrier_channel", 0.0)), 0.0, BROOD_CARRIER_CHANNEL)
		if saved_enemy.has("counts_for_wave"):
			spider.counts_for_wave = bool(saved_enemy.get("counts_for_wave"))
		else:
			spider.counts_for_wave = _default_counts_for_wave(spider)
		_normalize_spider_wave_count(spider)
		spider.cleanup_recalled = false
		var saved_target_cell: Array = saved_enemy.get("target_turret_cell", [])
		if saved_target_cell.size() == 2:
			spider.target_turret_cell = Vector2i(int(saved_target_cell[0]), int(saved_target_cell[1]))
		var saved_torch_target_cell: Array = saved_enemy.get("target_torch_cell", [])
		if saved_torch_target_cell.size() == 2:
			spider.target_torch_cell = Vector2i(int(saved_torch_target_cell[0]), int(saved_torch_target_cell[1]))
		# Restore cooldowns. If the save predates cooldown persistence, stagger them
		# randomly so that hundreds of enemies don't all attack simultaneously on resume.
		if saved_enemy.has("attack_cooldown"):
			spider.attack_cooldown = maxf(0.0, float(saved_enemy["attack_cooldown"]))
		else:
			spider.attack_cooldown = randf_range(0.0, 1.2)
		if saved_enemy.has("leap_cooldown"):
			spider.leap_cooldown = maxf(0.0, float(saved_enemy["leap_cooldown"]))
		else:
			spider.leap_cooldown = randf_range(0.5, 3.0) if spider.role == ROLE_LEAPER else 0.0
		if saved_enemy.has("spit_cooldown"):
			spider.spit_cooldown = maxf(0.0, float(saved_enemy["spit_cooldown"]))
		else:
			spider.spit_cooldown = randf_range(0.5, 3.0) if spider.role == ROLE_SPITTER else 0.0
		if saved_enemy.has("next_summon_ratio"):
			spider.next_summon_ratio = clampf(float(saved_enemy["next_summon_ratio"]), 0.0, 0.75)
		elif spider.role == ROLE_GUARDIAN:
			var health_ratio := spider.health / maxf(1.0, spider.max_health)
			spider.next_summon_ratio = 0.75
			while spider.next_summon_ratio > 0.0 and health_ratio <= spider.next_summon_ratio:
				spider.next_summon_ratio -= 0.25
		enemies.append(spider)
	for base_id: String in base_network.bases.keys():
		var base_record: Dictionary = base_network.get_base(base_id)
		if base_id != BaseNetworkScript.COMMAND_ID and bool(base_record.get("revealed", false)) and not bool(base_record.get("guardian_cleared", false)) and str(base_record["status"]) == BaseNetworkScript.STATUS_SITE and not _has_guardian_for_site(base_id):
			if _spawn_guardian(base_record["cell"]):
				enemies.back().guardian_site_id = base_id
	core_health = float(base_network.get_base(BaseNetworkScript.COMMAND_ID)["health"])
	_rebuild_base_flows()
	_sync_mecha_squad()
	if lantern_upgrade_target_cell.x >= 0 and _structure_index_at_cell(lantern_upgrade_target_cell, BUILD_TORCH) < 0:
		lantern_upgrade_target_cell = Vector2i(-1, -1)
	for spider: Spider in enemies:
		spider.target_torch_cell = Vector2i(-1, -1)
	encounter_load_grace = 3.0
	discovery_alert = "%s RESTORED // SEED %08X // %d ACTIVE BASES" % [grid.realm_title, run_seed, base_network.active_ids().size()]
	discovery_alert_time = 4.0
	return true


func _has_guardian_for_site(base_id: String) -> bool:
	for spider in enemies:
		if spider.guardian_site_id == base_id and spider.health > 0.0:
			return true
	return false


func _foundry_index() -> int:
	for structure_index in range(structures.size()):
		if structures[structure_index].kind == BUILD_FOUNDRY:
			return structure_index
	return -1


func _foundry_count() -> int:
	var count := 0
	for structure: Structure in structures:
		if structure.kind == BUILD_FOUNDRY:
			count += 1
	return count


func _active_foundry() -> Structure:
	if active_foundry_index >= 0 and active_foundry_index < structures.size() and structures[active_foundry_index].kind == BUILD_FOUNDRY:
		return structures[active_foundry_index]
	return null


func _foundry_stock_available() -> int:
	return kit_count("foundry") + (1 if foundry_kit_available else 0)


func _consume_foundry_kit() -> void:
	if kit_count("foundry") > 0:
		consume_kit("foundry", 1)
	else:
		foundry_kit_available = false


func _preferred_foundry_index() -> int:
	if active_foundry_index >= 0 and _foundry_operational(active_foundry_index):
		return active_foundry_index
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind == BUILD_FOUNDRY and structure.base_id == BaseNetworkScript.COMMAND_ID and _foundry_operational(structure_index):
			return structure_index
	for structure_index in range(structures.size()):
		if structures[structure_index].kind == BUILD_FOUNDRY and _foundry_operational(structure_index):
			return structure_index
	return -1


func _foundry_output_total_all() -> int:
	var total := 0
	for structure: Structure in structures:
		if structure.kind == BUILD_FOUNDRY:
			total += FoundryUnitScript.output_total(structure)
	return total


func _operational_foundry_count() -> int:
	var count := 0
	for structure_index in range(structures.size()):
		if structures[structure_index].kind == BUILD_FOUNDRY and _foundry_operational(structure_index):
			count += 1
	return count


func _any_foundry_operational() -> bool:
	return _operational_foundry_count() > 0


func _migrate_legacy_foundry_buffers() -> void:
	var has_legacy := material_economy.foundry_output_total() > 0 or material_economy.queue_size() > 0 or not material_economy.active_recipe.is_empty()
	if not has_legacy:
		return
	var target_index := _foundry_index()
	if target_index >= 0:
		FoundryUnitScript.migrate_legacy_state(structures[target_index], material_economy)
	else:
		material_economy.clear_legacy_foundry_production()


func _nearby_foundry() -> int:
	var best_index := -1
	var best_distance := 52.0
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind != BUILD_FOUNDRY or structure.health <= 0.0:
			continue
		var foundry_center := _foundry_center(structure)
		var distance := foundry_center.distance_to(player_position)
		if distance <= 52.0 and (best_index < 0 or distance < best_distance):
			best_index = structure_index
			best_distance = distance
	return best_index


func _foundry_center(structure: Structure) -> Vector2:
	var foundry_origin := grid.cell_to_world(structure.cell) - Vector2.ONE * float(grid.tile_size) * 0.5
	var foundry_size := Vector2(structure.size) * float(grid.tile_size)
	return foundry_origin + foundry_size * 0.5


func _foundry_interaction_rect(structure: Structure) -> Rect2:
	var foundry_origin := grid.cell_to_world(structure.cell) - Vector2.ONE * float(grid.tile_size) * 0.5
	var foundry_size := Vector2(structure.size) * float(grid.tile_size)
	return Rect2(foundry_origin, foundry_size).grow(4.0)


func _chest_interaction_rect(structure: Structure) -> Rect2:
	var chest_sizes := {
		BUILD_CHEST_SMALL: Vector2(16, 12),
		BUILD_CHEST_MEDIUM: Vector2(22, 16),
		BUILD_CHEST_LARGE: Vector2(28, 20),
	}
	var chest_dim: Vector2 = chest_sizes.get(structure.kind, Vector2(16, 12))
	return Rect2(structure.position - chest_dim * 0.5, chest_dim).grow(6.0)


func _doorway_interaction_rect(structure: Structure) -> Rect2:
	var footprint := structure.size if structure.size != Vector2i.ZERO else Vector2i.ONE
	var origin: Vector2 = grid.cell_to_world(structure.cell) - Vector2.ONE * float(grid.tile_size) * 0.5
	return Rect2(origin, Vector2(footprint) * float(grid.tile_size)).grow(5.0)


func _doorway_player_in_range(structure: Structure, maximum_distance: float = 52.0) -> bool:
	return _structure_contact_distance_squared(structure, player_position) <= maximum_distance * maximum_distance


func _base_interaction_rect(base_id: String) -> Rect2:
	var center := grid.cell_to_world(base_network.get_cell(base_id))
	var half_size := 18.0 if base_id == BaseNetworkScript.COMMAND_ID else 20.0
	return Rect2(center - Vector2.ONE * half_size, Vector2.ONE * half_size * 2.0)


func _merchant_store_interaction_rect(structure: Structure) -> Rect2:
	var footprint: Vector2i = structure.size if structure.size != Vector2i.ZERO else SettlementProgressionScript.MERCHANT_STORE_FOOTPRINT
	var origin: Vector2 = grid.cell_to_world(structure.cell) - Vector2.ONE * float(grid.tile_size) * 0.5
	return Rect2(origin, Vector2(footprint) * float(grid.tile_size)).grow(6.0)


func _merchant_store_index_at_world_position(world_position: Vector2) -> int:
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind == BUILD_MERCHANT_STORE and structure.health > 0.0 and _merchant_store_interaction_rect(structure).has_point(world_position):
			return structure_index
	return -1


func _nearby_merchant_store() -> int:
	var best_index: int = -1
	var best_distance: float = 58.0
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind != BUILD_MERCHANT_STORE or structure.health <= 0.0:
			continue
		var center: Vector2 = _merchant_store_interaction_rect(structure).get_center()
		var distance: float = center.distance_to(player_position)
		if distance <= best_distance:
			best_index = structure_index
			best_distance = distance
	return best_index


func _open_merchant_store(structure_index: int) -> void:
	if structure_index < 0 or structure_index >= structures.size():
		return
	var structure: Structure = structures[structure_index]
	if structure.kind != BUILD_MERCHANT_STORE or structure.health <= 0.0:
		return
	var center: Vector2 = _merchant_store_interaction_rect(structure).get_center()
	if center.distance_to(player_position) > 62.0:
		discovery_alert = "MOVE CLOSER TO ENTER MERCHANT STORE"
		discovery_alert_time = 2.5
		return
	var service_base_id: String = base_network.nearest_active(structure.cell, true)
	current_base_id = service_base_id if not service_base_id.is_empty() else BaseNetworkScript.COMMAND_ID
	merchant_store_session = true
	merchant_store_structure_index = structure_index
	using_core_base = true
	build_mode = false
	core_base_panel.visible = true
	core_menu_page = "supplies"
	foundry_ui_refresh_elapsed = 0.0
	_refresh_core_base_panel()
	_focus_first_core_action()


func _has_nearby_world_click_target() -> bool:
	if paused or game_over or build_mode or sleeping or choosing_upgrade or turret_selection_active:
		return false
	if using_core_base or using_foundry or using_chest_index >= 0 or backpack_open:
		return false
	return _nearby_doorway() >= 0 or _nearby_merchant_store() >= 0 or _nearby_foundry() >= 0 or _nearby_chest() >= 0 or not _nearby_base_id().is_empty()


func _doorway_index_at_world_position(world_position: Vector2) -> int:
	var best_index := -1
	var best_distance := INF
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind != BUILD_HEAVY_DOORWAY or structure.health <= 0.0:
			continue
		var rect := _doorway_interaction_rect(structure)
		if not rect.has_point(world_position):
			continue
		var distance := world_position.distance_to(rect.get_center())
		if distance < best_distance:
			best_distance = distance
			best_index = structure_index
	return best_index


func _foundry_index_at_world_position(world_position: Vector2) -> int:
	var best_index := -1
	var best_distance := INF
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind != BUILD_FOUNDRY or structure.health <= 0.0:
			continue
		var rect := _foundry_interaction_rect(structure)
		if not rect.has_point(world_position):
			continue
		var distance := world_position.distance_to(rect.get_center())
		if distance < best_distance:
			best_distance = distance
			best_index = structure_index
	return best_index


func _chest_index_at_world_position(world_position: Vector2) -> int:
	var best_index := -1
	var best_distance := INF
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind not in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
			continue
		var rect := _chest_interaction_rect(structure)
		if not rect.has_point(world_position):
			continue
		var distance := world_position.distance_to(structure.position)
		if distance < best_distance:
			best_distance = distance
			best_index = structure_index
	return best_index


func _base_id_at_world_position(world_position: Vector2) -> String:
	var result := ""
	var closest := INF
	for base_id: String in base_network.bases.keys():
		if not bool(base_network.get_base(base_id).get("revealed", false)):
			continue
		var rect := _base_interaction_rect(base_id)
		if not rect.has_point(world_position):
			continue
		var distance := world_position.distance_to(rect.get_center())
		if distance < closest:
			closest = distance
			result = base_id
	return result


func _try_handle_world_interaction_click(world_position: Vector2) -> bool:
	if paused or game_over or sleeping or build_mode or choosing_upgrade or turret_selection_active:
		return false
	if using_core_base or using_foundry or using_chest_index >= 0 or backpack_open:
		return false
	var doorway_index := _doorway_index_at_world_position(world_position)
	if doorway_index >= 0:
		var doorway: Structure = structures[doorway_index]
		if not _doorway_player_in_range(doorway):
			discovery_alert = "MOVE CLOSER TO OPERATE DOORWAY"
			discovery_alert_time = 2.5
			return true
		return _toggle_doorway(doorway_index)
	var merchant_index: int = _merchant_store_index_at_world_position(world_position)
	if merchant_index >= 0:
		_open_merchant_store(merchant_index)
		return true
	var foundry_index := _foundry_index_at_world_position(world_position)
	if foundry_index >= 0:
		return _open_foundry_at(foundry_index)
	var chest_index := _chest_index_at_world_position(world_position)
	if chest_index >= 0:
		if structures[chest_index].position.distance_to(player_position) >= 48.0:
			discovery_alert = "MOVE CLOSER TO USE VAULT"
			discovery_alert_time = 2.5
			return false
		_open_chest(chest_index)
		return true
	var base_id := _base_id_at_world_position(world_position)
	if base_id.is_empty():
		return false
	var base_position := grid.cell_to_world(base_network.get_cell(base_id))
	if player_position.distance_to(base_position) > 54.0:
		discovery_alert = "MOVE CLOSER TO USE CORE"
		discovery_alert_time = 2.5
		return false
	_interact_with_base(base_id)
	return true


func _foundry_powered(structure_index: int) -> bool:
	if structure_index < 0 or structure_index >= structures.size():
		return false
	var foundry: Structure = structures[structure_index]
	return foundry.kind == BUILD_FOUNDRY and foundry.health > 0.0 and foundry.powered


func _foundry_operational(structure_index: int = -1) -> bool:
	if structure_index < 0:
		return _any_foundry_operational()
	if not _foundry_powered(structure_index):
		return false
	return FoundryUnitScript.has_runtime_fuel(structures[structure_index], material_economy)


func _on_structure_destroyed(structure: Structure) -> void:
	if structure.kind == BUILD_FOUNDRY:
		grant_kit("foundry", 1)
		if active_foundry_index >= 0 and active_foundry_index < structures.size() and structures[active_foundry_index] == structure:
			active_foundry_index = -1
			using_foundry = false
			if is_instance_valid(foundry_panel):
				foundry_panel.visible = false
		discovery_alert = "FOUNDRY DESTROYED // REBUILD KIT RECOVERED"
		discovery_alert_time = 4.0
	elif structure.kind == BUILD_MERCHANT_STORE:
		if merchant_store_session:
			_close_core_base()
		merchant_store_structure_index = -1
		if grant_kit(SettlementProgressionScript.MERCHANT_STORE_STOCK_ID, 1) <= 0:
			merchant_store_kit_issued = true
			discovery_alert = "MERCHANT STORE LOST // REBUILD KIT RECOVERED // SETTLEMENT MUST HOLD"
		else:
			merchant_store_kit_issued = false
			discovery_alert = "MERCHANT STORE LOST // CLEAR A PACK SLOT // RECLAIM KIT AT COMMAND CORE"
		discovery_alert_time = 4.0


func _personal_base_index_for_base(base_id: String) -> int:
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind == BUILD_PERSONAL_BASE and structure.base_id == base_id:
			return structure_index
	return -1


func _personal_base_anchor_id(structure: Structure) -> String:
	return "%s%d:%d" % [PERSONAL_BASE_ANCHOR_PREFIX, structure.cell.x, structure.cell.y]


func _personal_base_index_for_anchor_id(anchor_id: String) -> int:
	if not anchor_id.begins_with(PERSONAL_BASE_ANCHOR_PREFIX):
		return -1
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind == BUILD_PERSONAL_BASE and structure.health > 0.0 and _personal_base_anchor_id(structure) == anchor_id:
			return structure_index
	return -1


func _personal_base_exit_position(structure: Structure) -> Vector2:
	var preferred: Array[Vector2i] = [
		structure.cell + Vector2i(1, structure.size.y),
		structure.cell + Vector2i(-1, 0),
		structure.cell + Vector2i(structure.size.x, 0),
		structure.cell + Vector2i(1, -1),
	]
	for cell: Vector2i in preferred:
		if grid.is_walkable(cell) and _structure_index_at_cell(cell) < 0:
			return grid.cell_to_world(cell)
	return grid.cell_to_world(structure.cell)


func _nearby_personal_base() -> int:
	var best_index := -1
	var best_distance := 52.0
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind != BUILD_PERSONAL_BASE or structure.health <= 0.0:
			continue
		var center := grid.cell_to_world(structure.cell) + Vector2(structure.size - Vector2i.ONE) * float(grid.tile_size) * 0.5
		var distance: float = center.distance_to(player_position)
		if distance <= 52.0 and (best_index < 0 or distance < best_distance):
			best_index = structure_index
			best_distance = distance
	return best_index


func _try_rest_at_personal_base(structure_index: int) -> void:
	if sleeping or sleep_entry_cooldown > 0.0 or structure_index < 0 or structure_index >= structures.size():
		return
	var structure: Structure = structures[structure_index]
	if structure.kind != BUILD_PERSONAL_BASE or structure.health <= 0.0:
		return
	_begin_sleep(structure_index)


func _update_personal_base_cooldowns(delta: float) -> void:
	sleep_entry_cooldown = maxf(0.0, sleep_entry_cooldown - delta)
	realm_save_cooldown = maxf(0.0, realm_save_cooldown - delta)


func _migrate_legacy_save_cooldown(legacy_cooldown: float) -> void:
	if legacy_cooldown <= 0.0:
		return
	realm_save_cooldown = maxf(realm_save_cooldown, legacy_cooldown)
	for structure_index in range(structures.size()):
		if structures[structure_index].kind == BUILD_PERSONAL_BASE:
			structures[structure_index].cooldown = 0.0


func _reconcile_legacy_brood_nests() -> void:
	for cell_value: Variant in grid.revealed_discoveries.keys():
		var cell: Vector2i = cell_value
		if str(grid.revealed_discoveries[cell]) != "nest" or destroyed_brood_nests.has(cell) or _brood_nest_index_at_cell(cell) >= 0:
			continue
		var nest := BroodNest.new()
		nest.cell = cell
		nest.maturity = 1.0
		nest.birth_wave = encounters_completed
		brood_nests.append(nest)
		grid.discovery_cells[cell] = "nest"
		grid.register_spawn_cell(cell)


func _encode_cells(values: Array[Vector2i]) -> Array:
	var result: Array = []
	for cell: Vector2i in values:
		result.append([cell.x, cell.y])
	return result


func _serialize_nest_milestones_spawned() -> Array:
	var result: Array = []
	for milestone_value: Variant in nest_milestones_spawned.keys():
		if bool(nest_milestones_spawned[milestone_value]):
			result.append(int(milestone_value))
	return result


func _decode_cells(values: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for value: Variant in values:
		var pair: Array = value
		if pair.size() == 2:
			result.append(Vector2i(int(pair[0]), int(pair[1])))
	return result


func _encode_cell_dictionary(values: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key_value: Variant in values.keys():
		var cell: Vector2i = key_value
		result["%d,%d" % [cell.x, cell.y]] = values[key_value]
	return result


func _decode_cell_dictionary(values: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for encoded: String in values.keys():
		var parts: PackedStringArray = encoded.split(",")
		if parts.size() == 2:
			result[Vector2i(int(parts[0]), int(parts[1]))] = values[encoded]
	return result


func _restore_bool_array(source: Array, target: Array[bool]) -> void:
	for index in range(mini(source.size(), target.size())):
		target[index] = bool(source[index])


func _restore_int_array(source: Array, target: Array[int]) -> void:
	for index in range(mini(source.size(), target.size())):
		target[index] = int(source[index])


func _apply_interface_typography() -> void:
	if is_instance_valid(core_base_title):
		core_base_title.add_theme_font_size_override("font_size", DisplaySettingsScript.font_title())
	if is_instance_valid(core_base_status):
		core_base_status.add_theme_font_size_override("font_size", DisplaySettingsScript.font_status())
	if is_instance_valid(core_xp_label):
		core_xp_label.add_theme_font_size_override("font_size", DisplaySettingsScript.font_caption())
	if is_instance_valid(core_base_scrap_label):
		core_base_scrap_label.add_theme_font_size_override("font_size", DisplaySettingsScript.font_body())
	if is_instance_valid(core_base_network_label):
		core_base_network_label.add_theme_font_size_override("font_size", DisplaySettingsScript.font_body())
	for page_id: String in core_tab_buttons.keys():
		var tab: Button = core_tab_buttons[page_id]
		if is_instance_valid(tab):
			tab.add_theme_font_size_override("font_size", DisplaySettingsScript.font_tab())
			tab.add_theme_constant_override("icon_max_width", 12)
	for department_id: String in core_department_buttons.keys():
		var department_button: Button = core_department_buttons[department_id]
		if is_instance_valid(department_button):
			department_button.add_theme_font_size_override("font_size", DisplaySettingsScript.font_caption())
			department_button.add_theme_constant_override("icon_max_width", 16)
	for service_button: Button in core_service_buttons:
		if is_instance_valid(service_button):
			service_button.add_theme_font_size_override("font_size", DisplaySettingsScript.font_service())
	if is_instance_valid(core_detail_title):
		core_detail_title.add_theme_font_size_override("font_size", DisplaySettingsScript.font_status())
	if is_instance_valid(core_detail_body):
		core_detail_body.add_theme_font_size_override("font_size", DisplaySettingsScript.font_body())
	if is_instance_valid(core_detail_state):
		core_detail_state.add_theme_font_size_override("font_size", DisplaySettingsScript.font_body())
	for child: Node in core_base_panel.get_children() if is_instance_valid(core_base_panel) else []:
		if child is Label and str((child as Label).text).begins_with("Q/E DEPARTMENT"):
			(child as Label).add_theme_font_size_override("font_size", DisplaySettingsScript.font_caption())
		if child is Button and str((child as Button).text) == "CLOSE":
			(child as Button).add_theme_font_size_override("font_size", DisplaySettingsScript.font_status())
	for save_button: Button in realm_archive_save_buttons:
		if is_instance_valid(save_button):
			save_button.add_theme_font_size_override("font_size", DisplaySettingsScript.font_service())
	for activate_button: Button in realm_archive_activate_buttons:
		if is_instance_valid(activate_button):
			activate_button.add_theme_font_size_override("font_size", DisplaySettingsScript.font_service())
	for button: Button in foundry_action_buttons:
		if is_instance_valid(button):
			button.add_theme_font_size_override("font_size", DisplaySettingsScript.font_service())
	if is_instance_valid(foundry_title):
		foundry_title.add_theme_font_size_override("font_size", DisplaySettingsScript.font_title())
	if is_instance_valid(foundry_status):
		foundry_status.add_theme_font_size_override("font_size", DisplaySettingsScript.font_caption())
	if is_instance_valid(foundry_production_label):
		foundry_production_label.add_theme_font_size_override("font_size", DisplaySettingsScript.font_caption())
	if is_instance_valid(foundry_inventory_label):
		foundry_inventory_label.add_theme_font_size_override("font_size", DisplaySettingsScript.font_body())
	if is_instance_valid(foundry_detail_label):
		foundry_detail_label.add_theme_font_size_override("font_size", DisplaySettingsScript.font_body())
	if is_instance_valid(pause_panel):
		for child: Node in pause_panel.get_node("Frame/Buttons").get_children():
			if child is Button:
				(child as Button).add_theme_font_size_override("font_size", DisplaySettingsScript.font_service())


func _overlay_button(label_text: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(176, 30)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("d8f4f8"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_focus_color", Color("ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("60747a"))
	button.add_theme_stylebox_override("normal", _button_style(Color("102c35"), Color("294d57"), 1))
	button.add_theme_stylebox_override("hover", _button_style(Color("173d47"), Color("58cde3"), 1))
	button.add_theme_stylebox_override("pressed", _button_style(Color("0b2028"), Color("8eeaff"), 2))
	button.add_theme_stylebox_override("focus", _button_style(Color("173d47"), Color("8eeaff"), 2))
	button.add_theme_stylebox_override("disabled", _button_style(Color("0a1a20"), Color("1c343b"), 1))
	return button


func _active_tab_stylebox() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("0f3040")
	sb.border_color = Color("55dff5")
	sb.border_width_top = 2
	sb.border_width_bottom = 0
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.content_margin_left = 4.0
	sb.content_margin_right = 4.0
	sb.content_margin_top = 2.0
	sb.content_margin_bottom = 2.0
	return sb


func _button_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	return style


func _draw_world(canvas: CanvasItem) -> void:
	_world_presentation._draw_world(canvas)

func _terrain_chunk_draw_bounds(region: Vector2i) -> Rect2i:
	return _world_presentation._terrain_chunk_draw_bounds(region)

func _region_available_for_bleed(region: Vector2i, stream_regions: Dictionary) -> bool:
	return _world_presentation._region_available_for_bleed(region, stream_regions)

func _terrain_stream_draw_bounds() -> Rect2i:
	return _world_presentation._terrain_stream_draw_bounds()

func _lighting_cull_rect() -> Rect2:
	return _world_presentation._lighting_cull_rect()

func _lighting_rect_has_point(position: Vector2, cull_rect: Rect2) -> bool:
	return _world_presentation._lighting_rect_has_point(position, cull_rect)

func _should_draw_heavy_lighting() -> bool:
	return _world_presentation._should_draw_heavy_lighting()

func _draw_terrain_chunk(canvas: CanvasItem, region: Vector2i) -> void:
	var started_us := Time.get_ticks_usec() if gameplay_telemetry != null and gameplay_telemetry.enabled else 0
	_world_presentation._draw_terrain_chunk(canvas, region)
	if started_us > 0:
		gameplay_telemetry.note_draw_cost("terrain", Time.get_ticks_usec() - started_us)

func _draw_actors(canvas: CanvasItem) -> void:
	var started_us := Time.get_ticks_usec() if gameplay_telemetry != null and gameplay_telemetry.enabled else 0
	_world_presentation._draw_actors(canvas)
	if started_us > 0:
		gameplay_telemetry.note_draw_cost("actors", Time.get_ticks_usec() - started_us)

func _draw_mecha_spiders(canvas: CanvasItem) -> void:
	_world_presentation._draw_mecha_spiders(canvas)

func _draw_surface_portal(canvas: CanvasItem) -> void:
	_world_presentation._draw_surface_portal(canvas)

func _draw_recovery_cache(canvas: CanvasItem) -> void:
	_world_presentation._draw_recovery_cache(canvas)

func _draw_effects(canvas: CanvasItem) -> void:
	_world_presentation._draw_effects(canvas)

func _draw_chest_alerts(canvas: CanvasItem) -> void:
	_world_presentation._draw_chest_alerts(canvas)

func _draw_lighting(canvas: CanvasItem) -> void:
	var started_us := Time.get_ticks_usec() if gameplay_telemetry != null and gameplay_telemetry.enabled else 0
	_world_presentation._draw_lighting(canvas)
	if started_us > 0:
		gameplay_telemetry.note_draw_cost("lighting", Time.get_ticks_usec() - started_us)

func _tile_draw_rect(rect: Rect2) -> Rect2:
	return _world_presentation._tile_draw_rect(rect)

func _draw_grid(canvas: CanvasItem) -> void:
	_world_presentation._draw_grid(canvas)

func _draw_grid_cells(canvas: CanvasItem, bounds: Rect2i) -> void:
	_world_presentation._draw_grid_cells(canvas, bounds)

func _visible_cell_bounds(margin: int = 2) -> Rect2i:
	return _world_presentation._visible_cell_bounds(margin)

func _effective_camera_center() -> Vector2:
	return _world_presentation._effective_camera_center()

func _draw_mineral_seam(canvas: CanvasItem, rect: Rect2, mineral_type: String) -> void:
	_world_presentation._draw_mineral_seam(canvas, rect, mineral_type)

func _draw_geology_tell(canvas: CanvasItem, rect: Rect2, cell: Vector2i) -> void:
	_world_presentation._draw_geology_tell(canvas, rect, cell)

func _macro_block_origin(cell: Vector2i) -> Vector2i:
	return _world_presentation._macro_block_origin(cell)

func _macro_block_is_complete_floor(macro_origin: Vector2i) -> bool:
	return _world_presentation._macro_block_is_complete_floor(macro_origin)

func _macro_block_has_uniform_floor_material(macro_origin: Vector2i) -> bool:
	return _world_presentation._macro_block_has_uniform_floor_material(macro_origin)

func _macro_block_is_complete_rock(macro_origin: Vector2i) -> bool:
	return _world_presentation._macro_block_is_complete_rock(macro_origin)

func _chunk_floor_macro_drawable(macro_origin: Vector2i) -> bool:
	return _world_presentation._chunk_floor_macro_drawable(macro_origin)

func _chunk_rock_macro_drawable(macro_origin: Vector2i) -> bool:
	return _world_presentation._chunk_rock_macro_drawable(macro_origin)

func _material_for_macro_block(macro_origin: Vector2i) -> Texture2D:
	return _world_presentation._material_for_macro_block(macro_origin)

func _sample_patch_edge_color(texture: Texture2D, source_rect: Rect2) -> Color:
	return _world_presentation._sample_patch_edge_color(texture, source_rect)

func _backing_color_for_source(texture: Texture2D, source_rect: Rect2) -> Color:
	return _world_presentation._backing_color_for_source(texture, source_rect)

func _sample_atlas_corner_color(texture: Texture2D) -> Color:
	return _world_presentation._sample_atlas_corner_color(texture)

func _cache_terrain_backing_colors() -> void:
	_world_presentation._cache_terrain_backing_colors()

func _floor_backing_color_for_material(material: Texture2D) -> Color:
	return _world_presentation._floor_backing_color_for_material(material)

func _draw_floor_macro_block(canvas: CanvasItem, macro_origin: Vector2i) -> void:
	_world_presentation._draw_floor_macro_block(canvas, macro_origin)

func _draw_rock_macro_block(canvas: CanvasItem, macro_origin: Vector2i) -> void:
	_world_presentation._draw_rock_macro_block(canvas, macro_origin)

func _draw_floor_cell(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	_world_presentation._draw_floor_cell(canvas, cell, rect)

func _draw_floor_formation_overlay(canvas: CanvasItem, cell: Vector2i, rect: Rect2, material: Texture2D) -> void:
	_world_presentation._draw_floor_formation_overlay(canvas, cell, rect, material)

func _draw_floor_cell_overlays(canvas: CanvasItem, cell: Vector2i, rect: Rect2, material: Texture2D = null) -> void:
	_world_presentation._draw_floor_cell_overlays(canvas, cell, rect, material)

func _draw_rock_cell(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	_world_presentation._draw_rock_cell(canvas, cell, rect)

func _dominant_wall_material_id(counts: Dictionary, salt_cell: Vector2i) -> int:
	return _world_presentation._dominant_wall_material_id(counts, salt_cell)

func _wall_material_id_for_cell(cell: Vector2i) -> int:
	return _world_presentation._wall_material_id_for_cell(cell)

func _wall_material_id_for_macro(macro_origin: Vector2i) -> int:
	return _world_presentation._wall_material_id_for_macro(macro_origin)

func _wall_macro_source_rect(texture: Texture2D, macro_origin: Vector2i, material_id: int) -> Rect2:
	return _world_presentation._wall_macro_source_rect(texture, macro_origin, material_id)

func _draw_wall_macro_overlay(canvas: CanvasItem, macro_origin: Vector2i, rect: Rect2) -> void:
	_world_presentation._draw_wall_macro_overlay(canvas, macro_origin, rect)

func _draw_wall_cell_overlay(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	_world_presentation._draw_wall_cell_overlay(canvas, cell, rect)

func _draw_rock_cell_overlays(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	_world_presentation._draw_rock_cell_overlays(canvas, cell, rect)

func _floor_base_color_for_material(material: Texture2D) -> Color:
	return _world_presentation._floor_base_color_for_material(material)

func _floor_tint_for_material(material: Texture2D) -> Color:
	return _world_presentation._floor_tint_for_material(material)

func _cave_cell_tint(origin: Vector2i) -> Color:
	return _world_presentation._cave_cell_tint(origin)

func _cave_backing_color_for_cell(cell: Vector2i) -> Color:
	return _world_presentation._cave_backing_color_for_cell(cell)

func _material_salt(material: Texture2D) -> int:
	return _world_presentation._material_salt(material)

func _tile_texture_region(texture: Texture2D, cell: Vector2i, salt: int, patch_size: int = -1) -> Rect2:
	return _world_presentation._tile_texture_region(texture, cell, salt, patch_size)

func _floor_texture_region(texture: Texture2D, cell: Vector2i, salt: int) -> Rect2:
	return _world_presentation._floor_texture_region(texture, cell, salt)

func _macro_variant_index(texture: Texture2D, macro_cell: Vector2i, salt: int) -> int:
	return _world_presentation._macro_variant_index(texture, macro_cell, salt)

func _macro_block_texture_region(texture: Texture2D, macro_cell: Vector2i, salt: int) -> Rect2:
	return _world_presentation._macro_block_texture_region(texture, macro_cell, salt)

func _macro_texture_region(texture: Texture2D, cell: Vector2i, salt: int) -> Rect2:
	return _world_presentation._macro_texture_region(texture, cell, salt)

func _material_for_cell(cell: Vector2i) -> Texture2D:
	return _world_presentation._material_for_cell(cell)

func _visual_biome_for_cell(cell: Vector2i) -> int:
	return _world_presentation._visual_biome_for_cell(cell)

func _cell_uses_discovery_hive_material(cell: Vector2i) -> bool:
	return _world_presentation._cell_uses_discovery_hive_material(cell)

func _floor_material_for_region(region: Vector2i) -> Texture2D:
	return _world_presentation._floor_material_for_region(region)

func _floor_material_for_biome(biome_id: int) -> Texture2D:
	return _world_presentation._floor_material_for_biome(biome_id)

func _mark_discovery_revealed(center: Vector2i) -> void:
	_world_presentation._mark_discovery_revealed(center)

func _rebuild_discovery_hive_cells() -> void:
	_world_presentation._rebuild_discovery_hive_cells()

func _reset_render_caches(clear_minimap: bool) -> void:
	_world_presentation._reset_render_caches(clear_minimap)

func _has_floor_neighbor(cell: Vector2i) -> bool:
	return _world_presentation._has_floor_neighbor(cell)

func _draw_wall_edges(canvas: CanvasItem) -> void:
	_world_presentation._draw_wall_edges(canvas)

func _draw_wall_edges_in_bounds(canvas: CanvasItem, bounds: Rect2i) -> void:
	_world_presentation._draw_wall_edges_in_bounds(canvas, bounds)

func _draw_environment_props(canvas: CanvasItem) -> void:
	_world_presentation._draw_environment_props(canvas)

func _draw_discovery_scars_in_region(canvas: CanvasItem, region: Vector2i) -> void:
	_world_presentation._draw_discovery_scars_in_region(canvas, region)

func _draw_discovery_scar(canvas: CanvasItem, center: Vector2i, discovery_kind: String) -> void:
	_world_presentation._draw_discovery_scar(canvas, center, discovery_kind)

func _draw_region_visual_props(canvas: CanvasItem) -> void:
	_world_presentation._draw_region_visual_props(canvas)

func _draw_region_visual_props_in_bounds(canvas: CanvasItem, region: Vector2i, bounds: Rect2i) -> void:
	_world_presentation._draw_region_visual_props_in_bounds(canvas, region, bounds)

func _visual_formations_for_region(region: Vector2i) -> Dictionary:
	return _world_presentation._visual_formations_for_region(region)

func _visual_landmarks_for_region(region: Vector2i) -> Array:
	return _world_presentation._visual_landmarks_for_region(region)

func _visual_props_for_region(region: Vector2i) -> Array:
	return _world_presentation._visual_props_for_region(region)

func _visual_material_id(cell: Vector2i) -> int:
	return _world_presentation._visual_material_id(cell)

func _visual_material_id_for_texture(material: Texture2D) -> int:
	return _world_presentation._visual_material_id_for_texture(material)

func _visual_prop_clear_of_landmark(cell: Vector2i) -> bool:
	return _world_presentation._visual_prop_clear_of_landmark(cell)

func _draw_region_prop(canvas: CanvasItem, cell: Vector2i, kind: int, variant: int, draw_offset: Vector2 = Vector2.ZERO) -> void:
	_world_presentation._draw_region_prop(canvas, cell, kind, variant, draw_offset)

func _invalidate_visual_region(cell: Vector2i) -> void:
	_world_presentation._invalidate_visual_region(cell)

func _mark_minimap_dirty(delay: float = MINIMAP_REBUILD_DELAY) -> void:
	_world_presentation._mark_minimap_dirty(delay)

func _should_draw_terrain_cell(_cell: Vector2i) -> bool:
	return _world_presentation._should_draw_terrain_cell(_cell)

func _on_terrain_cell_opened(cell: Vector2i) -> void:
	_world_presentation._on_terrain_cell_opened(cell)

func _update_terrain_debounce(delta: float) -> void:
	_world_presentation._update_terrain_debounce(delta)

func _minimap_view_size() -> Vector2i:
	return _world_presentation._minimap_view_size()

func _minimap_view_origin_for(player_cell: Vector2i) -> Vector2i:
	return _world_presentation._minimap_view_origin_for(player_cell)

func _advance_minimap_view(new_origin: Vector2i) -> void:
	_world_presentation._advance_minimap_view(new_origin)

func _scroll_minimap_cache(new_origin: Vector2i, delta: Vector2i) -> void:
	_world_presentation._scroll_minimap_cache(new_origin, delta)

func _write_minimap_world_cell(image: Image, cell: Vector2i) -> void:
	_world_presentation._write_minimap_world_cell(image, cell)

func _minimap_local_pixel(cell: Vector2i) -> Vector2i:
	return _world_presentation._minimap_local_pixel(cell)

func _minimap_color_for_cell(cell: Vector2i) -> Color:
	return _world_presentation._minimap_color_for_cell(cell)

func _minimap_terrain_pixel_color(cell: Vector2i) -> Color:
	return _world_presentation._minimap_terrain_pixel_color(cell)

func _patch_minimap_cell(cell: Vector2i) -> void:
	_world_presentation._patch_minimap_cell(cell)

func _patch_minimap_sector(sector: Vector2i) -> void:
	_world_presentation._patch_minimap_sector(sector)

func _patch_minimap_region(region: Vector2i) -> void:
	_world_presentation._patch_minimap_region(region)

func _flush_minimap_patches() -> void:
	_world_presentation._flush_minimap_patches()

func _invalidate_minimap() -> void:
	_world_presentation._invalidate_minimap()

func _sector_is_explored(cell: Vector2i) -> bool:
	return _world_presentation._sector_is_explored(cell)

func _rebuild_minimap_cache() -> void:
	_world_presentation._rebuild_minimap_cache()

func _minimap_position_for_cell(cell: Vector2i) -> Variant:
	return _world_presentation._minimap_position_for_cell(cell)

func _minimap_edge_marker_for_cell(cell: Vector2i) -> Vector2:
	return _world_presentation._minimap_edge_marker_for_cell(cell)

func _draw_minimap_edge_tick(canvas: CanvasItem, position: Vector2, color: Color, toward: Vector2i) -> void:
	_world_presentation._draw_minimap_edge_tick(canvas, position, color, toward)

func _minimap_enemy_visible(spider: Spider) -> bool:
	return _world_presentation._minimap_enemy_visible(spider)

func _prune_visual_prop_cache() -> void:
	_world_presentation._prune_visual_prop_cache()

func _draw_core(canvas: CanvasItem) -> void:
	_actor_presentation._draw_core(canvas)

func _draw_structures(canvas: CanvasItem) -> void:
	_actor_presentation._draw_structures(canvas)

func _turret_sprite_rotation(structure: Structure) -> float:
	return _actor_presentation._turret_sprite_rotation(structure)

func _barrier_world_tint(kind: int) -> Color:
	return _actor_presentation._barrier_world_tint(kind)

func _draw_enemies(canvas: CanvasItem) -> void:
	_actor_presentation._draw_enemies(canvas)

func _draw_brood_nests(canvas: CanvasItem) -> void:
	_actor_presentation._draw_brood_nests(canvas)

func _mob_sprite_size(role: int) -> Vector2:
	return _actor_presentation._mob_sprite_size(role)

func _draw_bullets(canvas: CanvasItem) -> void:
	_actor_presentation._draw_bullets(canvas)

func _draw_enemy_hazard_patch(canvas: CanvasItem, patch: FirePatch, ratio: float) -> void:
	_actor_presentation._draw_enemy_hazard_patch(canvas, patch, ratio)

func _draw_player(canvas: CanvasItem) -> void:
	_actor_presentation._draw_player(canvas)

func _player_direction_texture(use_active_pose: bool = false) -> Texture2D:
	return _actor_presentation._player_direction_texture(use_active_pose)

func _draw_player_sprite(canvas: CanvasItem) -> void:
	_actor_presentation._draw_player_sprite(canvas)

func _draw_player_status_overlay(canvas: CanvasItem) -> void:
	_actor_presentation._draw_player_status_overlay(canvas)

func _player_visual_state() -> Dictionary:
	return _actor_presentation._player_visual_state()

func _player_hand_offset(direction_name: String) -> Vector2:
	return _actor_presentation._player_hand_offset(direction_name)

func _player_tool_pose(mining_tool: bool = false) -> Dictionary:
	return _actor_presentation._player_tool_pose(mining_tool)

func _player_weapon_draws_behind() -> bool:
	return _actor_presentation._player_weapon_draws_behind()

func _should_draw_held_weapon() -> bool:
	return _actor_presentation._should_draw_held_weapon()

func _should_draw_mining_gun() -> bool:
	return _actor_presentation._should_draw_mining_gun()

func _mining_tool_tier() -> int:
	return _actor_presentation._mining_tool_tier()

func _held_weapon_draw_transform(spec: Dictionary, direction: Vector2) -> Dictionary:
	return _actor_presentation._held_weapon_draw_transform(spec, direction)

func _held_weapon_muzzle_world(mount_position: Vector2, spec: Dictionary, direction: Vector2) -> Vector2:
	return _actor_presentation._held_weapon_muzzle_world(mount_position, spec, direction)

func _draw_held_weapon_sprite(canvas: CanvasItem, tool_pose: Dictionary) -> void:
	_actor_presentation._draw_held_weapon_sprite(canvas, tool_pose)

func _draw_procedural_held_weapon(canvas: CanvasItem, tool_pose: Dictionary) -> void:
	_actor_presentation._draw_procedural_held_weapon(canvas, tool_pose)

func _player_muzzle_position(mining_tool: bool = false) -> Vector2:
	return _actor_presentation._player_muzzle_position(mining_tool)

func _draw_player_weapon(canvas: CanvasItem, foreground: bool) -> void:
	_actor_presentation._draw_player_weapon(canvas, foreground)

func _draw_mining_gun_sprite(canvas: CanvasItem, tool_pose: Dictionary) -> void:
	_actor_presentation._draw_mining_gun_sprite(canvas, tool_pose)

func _player_direction_name() -> String:
	return _actor_presentation._player_direction_name()

func _draw_sparks(canvas: CanvasItem) -> void:
	_actor_presentation._draw_sparks(canvas)

func _draw_pickups(canvas: CanvasItem) -> void:
	_actor_presentation._draw_pickups(canvas)

func _pickup_world_tint(kind: String) -> Color:
	return _actor_presentation._pickup_world_tint(kind)

func _pickup_icon(kind: String) -> Texture2D:
	return _actor_presentation._pickup_icon(kind)

func _draw_mining_beam(canvas: CanvasItem) -> void:
	_actor_presentation._draw_mining_beam(canvas)

func _mining_feedback_position(target_position: Vector2) -> Vector2:
	return _actor_presentation._mining_feedback_position(target_position)

func _draw_targeting(canvas: CanvasItem) -> void:
	_actor_presentation._draw_targeting(canvas)

func _should_draw_combat_crosshair() -> bool:
	return _actor_presentation._should_draw_combat_crosshair()

func _draw_relocation_hologram(canvas: CanvasItem) -> void:
	_actor_presentation._draw_relocation_hologram(canvas)

func _draw_combat_crosshair(canvas: CanvasItem, center: Vector2) -> void:
	_actor_presentation._draw_combat_crosshair(canvas, center)

func _build_icon_name(build_kind: int) -> String:
	return _actor_presentation._build_icon_name(build_kind)

func _torch_icon() -> Texture2D:
	return _actor_presentation._torch_icon()

func _build_preview_texture(build_kind: int) -> Texture2D:
	return _actor_presentation._build_preview_texture(build_kind)

func _build_role_label(build_kind: int) -> String:
	return _actor_presentation._build_role_label(build_kind)

func _build_available_amount(build_kind: int) -> int:
	return _actor_presentation._build_available_amount(build_kind)

func _build_range(build_kind: int) -> float:
	return _actor_presentation._build_range(build_kind)

func _draw_build_hologram(canvas: CanvasItem) -> void:
	_actor_presentation._draw_build_hologram(canvas)

func _draw_build_belt(canvas: CanvasItem) -> void:
	_actor_presentation._draw_build_belt(canvas)

func _sync_hud_motion_displays() -> void:
	_hud_presentation._sync_hud_motion_displays()

func _comms_alert_priority(text: String) -> int:
	return _hud_presentation._comms_alert_priority(text)

func _comms_state_from_text(text: String) -> Dictionary:
	return _hud_presentation._comms_state_from_text(text)

func _push_comms_alert(text: String, duration: float) -> void:
	_hud_presentation._push_comms_alert(text, duration)

func _pop_comms_alert() -> Dictionary:
	return _hud_presentation._pop_comms_alert()

func _update_hud_comms(delta: float) -> void:
	_hud_presentation._update_hud_comms(delta)

func _register_hud_kill_streak(from_sentry: bool) -> void:
	_hud_presentation._register_hud_kill_streak(from_sentry)

func _active_comms_alert_text() -> String:
	return _hud_presentation._active_comms_alert_text()

func _update_hud_motion(delta: float) -> void:
	_hud_presentation._update_hud_motion(delta)

func _hud_panel_accent_alpha() -> float:
	return _hud_presentation._hud_panel_accent_alpha()

func _hud_panel_texture_id(panel: Rect2) -> String:
	return _hud_presentation._hud_panel_texture_id(panel)

func _draw_hud_panel(canvas: CanvasItem, panel: Rect2, accent: Color = RealmVisualStyleScript.CYAN, pulse: bool = true) -> void:
	_hud_presentation._draw_hud_panel(canvas, panel, accent, pulse)

func _draw_hud(canvas: CanvasItem) -> void:
	_hud_presentation._draw_hud(canvas)

func _hud_objective_state(bases_under_attack: int, hunter_count: int) -> Dictionary:
	return _hud_presentation._hud_objective_state(bases_under_attack, hunter_count)

func _hud_interaction_state() -> Dictionary:
	return _hud_presentation._hud_interaction_state()

func _draw_hud_state_glyph(canvas: CanvasItem, center: Vector2, glyph: String, color: Color, spin: float = 0.0) -> void:
	_hud_presentation._draw_hud_state_glyph(canvas, center, glyph, color, spin)

func _draw_atmosphere(canvas: CanvasItem) -> void:
	_hud_presentation._draw_atmosphere(canvas)

func _draw_light_pool(canvas: CanvasItem, position: Vector2, radius: float, color: Color, strength: float) -> void:
	_hud_presentation._draw_light_pool(canvas, position, radius, color, strength)

func _draw_region_prop_lights(canvas: CanvasItem, visible_rect: Rect2) -> void:
	_hud_presentation._draw_region_prop_lights(canvas, visible_rect)

func _draw_structure_contact_shadows(canvas: CanvasItem) -> void:
	_hud_presentation._draw_structure_contact_shadows(canvas)

func _draw_ambient_motes(canvas: CanvasItem, visible_rect: Rect2) -> void:
	_hud_presentation._draw_ambient_motes(canvas, visible_rect)

func _build_chest_panel() -> void:
	chest_panel = ColorRect.new()
	chest_panel.position = Vector2(72, 36)
	chest_panel.size = Vector2(496, 288)
	chest_panel.color = Color(0.012, 0.024, 0.028, 0.985)
	chest_panel.z_index = 110
	chest_panel.visible = false
	chest_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_root.add_child(chest_panel)

	var top_accent := ColorRect.new()
	top_accent.size = Vector2(496, 3)
	top_accent.color = Color("d7b36a")
	top_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chest_panel.add_child(top_accent)

	chest_title = Label.new()
	chest_title.position = Vector2(16, 10)
	chest_title.size = Vector2(360, 18)
	chest_title.add_theme_font_size_override("font_size", 13)
	chest_title.add_theme_color_override("font_color", Color("ffd36b"))
	chest_panel.add_child(chest_title)

	chest_status = Label.new()
	chest_status.position = Vector2(16, 30)
	chest_status.size = Vector2(460, 14)
	chest_status.add_theme_font_size_override("font_size", 8)
	chest_status.add_theme_color_override("font_color", Color("9db5b8"))
	chest_panel.add_child(chest_status)

	chest_player_heading = Label.new()
	chest_player_heading.text = "FIELD PACK"
	chest_player_heading.position = Vector2(16, 52)
	chest_player_heading.size = Vector2(200, 12)
	chest_player_heading.add_theme_font_size_override("font_size", 8)
	chest_player_heading.add_theme_color_override("font_color", Color("8eeaff"))
	chest_panel.add_child(chest_player_heading)

	chest_vault_heading = Label.new()
	chest_vault_heading.text = "VAULT CARGO"
	chest_vault_heading.position = Vector2(260, 52)
	chest_vault_heading.size = Vector2(200, 12)
	chest_vault_heading.add_theme_font_size_override("font_size", 8)
	chest_vault_heading.add_theme_color_override("font_color", Color("ffd36b"))
	chest_panel.add_child(chest_vault_heading)

	chest_player_list = GridContainer.new()
	chest_player_list.columns = 4
	chest_player_list.position = Vector2(16, 68)
	chest_player_list.size = Vector2(220, 160)
	chest_panel.add_child(chest_player_list)

	chest_vault_list = GridContainer.new()
	chest_vault_list.columns = 4
	chest_vault_list.position = Vector2(260, 68)
	chest_vault_list.size = Vector2(220, 160)
	chest_panel.add_child(chest_vault_list)

	chest_actions.clear()
	var deposit := _overlay_button("DEPOSIT ALL")
	deposit.position = Vector2(16, 244)
	deposit.size = Vector2(220, 24)
	deposit.pressed.connect(_chest_deposit_all)
	chest_panel.add_child(deposit)
	chest_actions.append(deposit)

	var withdraw := _overlay_button("WITHDRAW ALL")
	withdraw.position = Vector2(260, 244)
	withdraw.size = Vector2(220, 24)
	withdraw.pressed.connect(_chest_withdraw_all)
	chest_panel.add_child(withdraw)
	chest_actions.append(withdraw)

	var close := _overlay_button("CLOSE  //  F / B / I")
	close.position = Vector2(16, 272)
	close.size = Vector2(464, 22)
	close.pressed.connect(_close_chest)
	chest_panel.add_child(close)


func _refresh_chest_panel() -> void:
	if using_chest_index < 0 or using_chest_index >= structures.size() or not is_instance_valid(chest_panel):
		return
	var chest: Structure = structures[using_chest_index]
	chest_status.text = "CAPACITY  %d/%d  //  PACK %d/%d" % [
		_chest_used(chest),
		chest.chest_capacity,
		_backpack_used(),
		_backpack_capacity(),
	]
	var pack_manifest: Dictionary = {}
	for material_id: String in material_economy.RAW_ORDER:
		var raw_amount := int(material_economy.raw.get(material_id, 0))
		if raw_amount > 0:
			pack_manifest[material_id] = raw_amount
	for material_id: String in material_economy.REFINED_ORDER:
		var refined_amount := int(material_economy.refined.get(material_id, 0))
		if refined_amount > 0:
			pack_manifest[material_id] = refined_amount
	_fill_chest_material_list(chest_player_list, pack_manifest, true)
	_fill_chest_material_list(chest_vault_list, chest.inventory, false)
	var pack_has := material_economy.inventory_units() > 0
	var vault_has := _chest_used(chest) > 0
	var vault_space := chest.chest_capacity - _chest_used(chest)
	chest_actions[0].disabled = not pack_has or vault_space <= 0
	chest_actions[1].disabled = not vault_has


func _chest_deposit_all() -> void:
	if using_chest_index < 0 or using_chest_index >= structures.size():
		return
	var chest: Structure = structures[using_chest_index]
	var before := _chest_used(chest)
	_chest_auto_dump(using_chest_index)
	var moved := _chest_used(chest) - before
	if moved <= 0 and _chest_used(chest) >= chest.chest_capacity:
		chest_alert_text = "VAULT FULL"
		chest_alert_time = 1.4
		chest_alert_position = chest.position + Vector2(0, -20)
		_mark_visual_dirty(VIS_DIRTY_ACTORS | VIS_DIRTY_EFFECTS)
	_refresh_chest_panel()


func _chest_withdraw_all() -> void:
	if using_chest_index < 0 or using_chest_index >= structures.size():
		return
	var chest: Structure = structures[using_chest_index]
	var moved := 0
	var free_units := _backpack_free()
	var material_order: Array[String] = []
	material_order.append_array(material_economy.RAW_ORDER)
	material_order.append_array(material_economy.REFINED_ORDER)
	for material_id: String in material_order:
		if free_units <= 0:
			break
		var amount := int(chest.inventory.get(material_id, 0))
		if amount <= 0:
			continue
		var to_move := mini(amount, free_units)
		if material_id in material_economy.RAW_ORDER:
			material_economy.raw[material_id] = int(material_economy.raw.get(material_id, 0)) + to_move
		else:
			material_economy.refined[material_id] = int(material_economy.refined.get(material_id, 0)) + to_move
		var remaining := amount - to_move
		if remaining > 0:
			chest.inventory[material_id] = remaining
		else:
			chest.inventory.erase(material_id)
		moved += to_move
		free_units -= to_move
	if moved > 0:
		_burst(chest.position, Color("ffd36b"), 8, 28.0)
		chest_alert_text = "WITHDREW +%d" % moved
		chest_alert_time = 1.4
		chest_alert_position = chest.position + Vector2(0, -20)
		_mark_visual_dirty(VIS_DIRTY_ACTORS | VIS_DIRTY_EFFECTS)
		_save_run()
	elif _chest_used(chest) > 0:
		chest_alert_text = "PACK FULL"
		chest_alert_time = 1.4
		chest_alert_position = chest.position + Vector2(0, -20)
		_mark_visual_dirty(VIS_DIRTY_ACTORS | VIS_DIRTY_EFFECTS)
	_refresh_chest_panel()


func _fill_chest_material_list(list: GridContainer, source: Dictionary, from_pack: bool) -> void:
	# Detach immediately so GridContainer never lays out old + new chips together
	# for a frame while queue_free is pending.
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	var material_order: Array[String] = []
	material_order.append_array(material_economy.RAW_ORDER)
	material_order.append_array(material_economy.REFINED_ORDER)
	for material_id: String in material_order:
		var amount := int(source.get(material_id, 0))
		if amount <= 0 and not from_pack:
			continue
		if amount <= 0:
			continue
		var icon_tex: Texture2D = shop_icons.get(material_id)
		if icon_tex != null:
			var chip := Control.new()
			chip.custom_minimum_size = Vector2(50, 16)
			chip.mouse_filter = Control.MOUSE_FILTER_IGNORE

			var icon := TextureRect.new()
			icon.position = Vector2(1, 1)
			icon.size = Vector2(14, 14)
			icon.texture = icon_tex
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			chip.add_child(icon)

			var count_lbl := Label.new()
			count_lbl.position = Vector2(17, 0)
			count_lbl.size = Vector2(32, 16)
			count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			count_lbl.add_theme_font_size_override("font_size", 7)
			count_lbl.add_theme_color_override("font_color", Color("d5eceb"))
			count_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			count_lbl.text = str(amount)
			chip.add_child(count_lbl)
			list.add_child(chip)
		else:
			var chip := Label.new()
			chip.text = "%s %d" % [material_id.substr(0, mini(4, material_id.length())).to_upper(), amount]
			chip.custom_minimum_size = Vector2(50, 16)
			chip.add_theme_font_size_override("font_size", 7)
			chip.add_theme_color_override("font_color", Color("d5eceb"))
			list.add_child(chip)


func _open_chest(structure_index: int) -> void:
	if structure_index < 0 or structure_index >= structures.size():
		return
	var chest: Structure = structures[structure_index]
	if chest.kind not in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
		return
	using_chest_index = structure_index
	using_core_base = false
	using_foundry = false
	build_mode = false
	chest_title.text = "FIELD VAULT // %s" % str(BUILD_STOCK_KEYS.get(chest.kind, "chest")).to_upper()
	chest_panel.visible = true
	_refresh_chest_panel()


func _close_chest() -> void:
	using_chest_index = -1
	if is_instance_valid(chest_panel):
		chest_panel.visible = false


func _nearby_chest() -> int:
	var best_index := -1
	var best_distance := 48.0
	for structure_index in range(structures.size()):
		var structure: Structure = structures[structure_index]
		if structure.kind not in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
			continue
		if structure.health <= 0.0:
			continue
		var distance := structure.position.distance_to(player_position)
		if distance <= best_distance:
			best_distance = distance
			best_index = structure_index
	return best_index


func _base_short_name(base_id: String) -> String:
	match base_id:
		BaseNetworkScript.COMMAND_ID:
			return "CMD"
		BaseNetworkScript.NORTH_ID:
			return "CRS"
		BaseNetworkScript.SOUTH_ID:
			return "FDY"
		BaseNetworkScript.WEST_ID:
			return "HCP"
		_:
			var display := str(base_network.get_base(base_id).get("name", base_id))
			return display.substr(0, mini(3, display.length())).to_upper()


func _hud_base_order() -> Array[String]:
	return [
		BaseNetworkScript.COMMAND_ID,
		BaseNetworkScript.NORTH_ID,
		BaseNetworkScript.SOUTH_ID,
		BaseNetworkScript.WEST_ID,
	]


func _active_turret_hunter_count() -> int:
	var count := 0
	for spider: Spider in enemies:
		if spider.hunts_turrets and spider.target_turret_cell.x >= 0:
			count += 1
	return count


func _hunters_targeting_cell(cell: Vector2i) -> int:
	var count := 0
	for spider: Spider in enemies:
		if spider.hunts_turrets and spider.target_turret_cell == cell:
			count += 1
	return count


func _draw_base_network_cards(canvas: CanvasItem) -> void:
	var font: Font = ThemeDB.fallback_font
	var origin := RealmVisualStyleScript.HUD_BASE_START
	var card_size := RealmVisualStyleScript.HUD_BASE_CARD_SIZE
	var step := RealmVisualStyleScript.HUD_BASE_CARD_STEP
	var order: Array[String] = _hud_base_order()
	for card_index in range(order.size()):
		var base_id: String = order[card_index]
		var record: Dictionary = base_network.get_base(base_id)
		var revealed := bool(record.get("revealed", false))
		var card := Rect2(origin + Vector2(float(card_index) * float(step), 0.0), card_size)
		var status_color := RealmVisualStyleScript.CYAN
		var attack_flash := float(hud_base_attack_flash.get(base_id, 0.0))
		if _base_is_under_attack(base_id) or attack_flash > 0.0:
			status_color = Color("ef675f")
		elif str(record.get("status", "")) == BaseNetworkScript.STATUS_DISABLED:
			status_color = Color("8d6967")
		elif str(record.get("status", "")) == BaseNetworkScript.STATUS_ACTIVATING:
			status_color = RealmVisualStyleScript.AMBER
		elif str(record.get("status", "")) == BaseNetworkScript.STATUS_SITE:
			status_color = Color("6d9da8")
		if not revealed:
			status_color = Color("344a50")
		canvas.draw_rect(card, Color(0.007, 0.022, 0.029, 0.95))
		canvas.draw_rect(card, Color(status_color, 0.7), false, 1.0)
		canvas.draw_rect(Rect2(card.position, Vector2(3, card.size.y)), status_color)
		var base_icon: Texture2D = shop_icons.get("command_core" if base_id == BaseNetworkScript.COMMAND_ID else "frontier_core")
		if not revealed:
			if base_icon != null:
				canvas.draw_texture_rect(base_icon, Rect2(card.get_center() - Vector2(5.5, 5.5), Vector2(11, 11)), false, Color(0.28, 0.36, 0.38, 0.72))
			canvas.draw_string(font, card.get_center() + Vector2(-3, 4), "?", HORIZONTAL_ALIGNMENT_LEFT, 8, 8, Color("50666b"))
			continue
		if base_icon != null:
			canvas.draw_texture_rect(base_icon, Rect2(card.position + Vector2(5, 6), Vector2(10, 10)), false, Color.WHITE)
		canvas.draw_string(font, card.position + Vector2(18, 15), _base_short_name(base_id), HORIZONTAL_ALIGNMENT_LEFT, 30, 8, status_color)
		var status: String = str(record.get("status", ""))
		var status_label := "SITE"
		if status == BaseNetworkScript.STATUS_ACTIVE:
			status_label = "%03d%%" % roundi(float(record["health"]) / maxf(1.0, float(record["max_health"])) * 100.0)
		elif status == BaseNetworkScript.STATUS_ACTIVATING:
			status_label = "%02dS" % ceili(float(record.get("activation_remaining", 0.0)))
		elif status == BaseNetworkScript.STATUS_DISABLED:
			status_label = "OFF"
		canvas.draw_string(font, card.position + Vector2(5, 28), status_label, HORIZONTAL_ALIGNMENT_LEFT, 42, 7, Color("b7cbd0"))
		if status == BaseNetworkScript.STATUS_ACTIVE:
			var health_ratio := clampf(float(record["health"]) / maxf(1.0, float(record["max_health"])), 0.0, 1.0)
			canvas.draw_rect(Rect2(card.position + Vector2(5, 31), Vector2(42, 3)), Color("132c33"))
			var bar_offset := sin(Time.get_ticks_msec() * 0.035) * attack_flash * 1.5 if attack_flash > 0.0 else 0.0
			canvas.draw_rect(Rect2(card.position + Vector2(5, 31.0 + bar_offset), Vector2(42.0 * health_ratio, 3)), status_color)


func _draw_base_alert_indicators(canvas: CanvasItem) -> void:
	for base_id: String in base_network.active_ids():
		if not _base_is_under_attack(base_id) and float(hud_base_attack_flash.get(base_id, 0.0)) <= 0.0:
			continue
		var cell: Vector2i = base_network.get_cell(base_id)
		var marker := _minimap_edge_marker_for_cell(cell)
		var pulse := 2.2 + sin(Time.get_ticks_msec() * 0.02) * 1.1
		canvas.draw_circle(marker, pulse, Color("ef675f", 0.9))
		_draw_minimap_edge_tick(canvas, marker, Color("ff9c8f"), cell)


func _hotbar_slot_label(stack: Dictionary) -> String:
	var kind := str(stack.get("kind", OperatorLoadoutScript.KIND_EMPTY))
	match kind:
		OperatorLoadoutScript.KIND_EMPTY:
			return "-"
		OperatorLoadoutScript.KIND_MINING_TOOL:
			return "CUT"
		OperatorLoadoutScript.KIND_WEAPON:
			var names: Array[String] = ["PST", "SHT", "LSR", "SMG", "RAL", "FLM"]
			var wid := int(stack.get("id", 0))
			return names[wid] if wid >= 0 and wid < names.size() else "WPN"
		OperatorLoadoutScript.KIND_BUILD:
			var build_kind := int(stack.get("build_kind", 0))
			if build_kind == BUILD_BARRICADE:
				return "BRC"
			if build_kind == BUILD_TORCH:
				return "TRC"
			return "STY"
		OperatorLoadoutScript.KIND_BLOCK:
			return "BLK"
		OperatorLoadoutScript.KIND_DEPLOYABLE:
			var id := str(stack.get("id", ""))
			if id == TORCH_STOCK_ID:
				return "TRC"
			if id.length() >= 3:
				return id.substr(0, 3).to_upper()
			return id.to_upper()
	return "?"


func _draw_holster_chip(canvas: CanvasItem, font: Font, rect: Rect2, label: String, selected: bool, filled: bool, icon: Texture2D = null, count: int = 0, show_index: bool = false) -> void:
	var slot_texture := "hud_slot_cyan" if selected else ("hud_slot_dark" if filled else "hud_slot_locked")
	if not USE_IMPORTED_HUD_SKINS or not _draw_ui_nine_patch(canvas, slot_texture, rect, 3.0, HUD_CHROME_TINT):
		canvas.draw_rect(rect, Color(0.02, 0.06, 0.08, 0.96) if selected else (Color(0.015, 0.04, 0.05, 0.94) if filled else Color(0.008, 0.018, 0.022, 0.88)))
		canvas.draw_rect(rect, RealmVisualStyleScript.CYAN if selected else (Color("4a6e78") if filled else Color("26383d")), false, 2.0 if selected else 1.0)
	if selected:
		canvas.draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2)), RealmVisualStyleScript.CYAN)
	if icon != null:
		var pad := 3.0 if not show_index else 4.0
		var icon_size := minf(rect.size.x, rect.size.y) - pad
		var icon_rect := Rect2(rect.get_center() - Vector2(icon_size, icon_size) * 0.5 + Vector2(0, 1), Vector2(icon_size, icon_size))
		canvas.draw_texture_rect(icon, icon_rect, false, Color.WHITE if selected else Color(0.82, 0.9, 0.92, 0.94))
	elif filled:
		canvas.draw_string(font, rect.position + Vector2(3, 8), label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 4, 7, Color("dff8fb") if selected else Color("77949b"))
	if show_index:
		canvas.draw_string(font, rect.position + Vector2(1, 6), label, HORIZONTAL_ALIGNMENT_LEFT, 10, 6, RealmVisualStyleScript.CYAN if selected else Color("72949a"))
	if count > 1:
		canvas.draw_string(font, rect.position + Vector2(rect.size.x - 12, rect.size.y - 3), str(count), HORIZONTAL_ALIGNMENT_RIGHT, 12, 6, Color("ffd36b"))


func _draw_hotbar(canvas: CanvasItem) -> void:
	var font: Font = ThemeDB.fallback_font
	if operator_loadout == null:
		return
	var origin := RealmVisualStyleScript.HUD_WEAPON_START
	var card_h: float = RealmVisualStyleScript.HUD_WEAPON_CARD_SIZE.y
	var x := origin.x
	var cutter_rect := Rect2(x, origin.y, RealmVisualStyleScript.HUD_WEAPON_CUTTER_WIDTH, card_h)
	var cutter_on := operator_loadout.is_cutter_selected()
	_draw_holster_chip(canvas, font, cutter_rect, "CUT", cutter_on, true, _holster_cutter_icon())
	x += RealmVisualStyleScript.HUD_WEAPON_CUTTER_WIDTH + 2.0
	var gun_step: float = RealmVisualStyleScript.HUD_WEAPON_CARD_STEP
	for gun_i in range(operator_loadout.gun_slot_count()):
		var rect := Rect2(x, origin.y, gun_step - 2.0, card_h)
		var wid: int = operator_loadout.holster_guns[gun_i]
		var selected := operator_loadout.holster_index == gun_i + 1
		var label := WEAPON_HUD_LABELS[wid] if wid >= 0 and wid < WEAPON_HUD_LABELS.size() else "-"
		_draw_holster_chip(canvas, font, rect, label, selected, wid >= 0, _weapon_hud_icon(wid))
		x += gun_step
	x += 6.0
	var pip: float = RealmVisualStyleScript.HUD_WEAPON_BUILD_PIP
	for build_i in range(operator_loadout.build_slot_count()):
		var rect := Rect2(x, origin.y, pip - 1.0, card_h)
		var stack: Dictionary = operator_loadout.hotbar[build_i]
		var selected := build_i == operator_loadout.hotbar_index
		var filled := str(stack.get("kind", OperatorLoadoutScript.KIND_EMPTY)) != OperatorLoadoutScript.KIND_EMPTY
		var count := int(stack.get("count", 0))
		_draw_holster_chip(canvas, font, rect, str(build_i + 1), selected, filled, _hotbar_stack_icon(stack), count, true)
		x += pip


func _draw_minimap(canvas: CanvasItem) -> void:
	var font: Font = ThemeDB.fallback_font
	var card := RealmVisualStyleScript.HUD_MINIMAP_CARD
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	if not USE_IMPORTED_HUD_SKINS or not _draw_ui_nine_patch(canvas, "hud_display_panel", card, 8.0, HUD_CHROME_TINT):
		if not _draw_ui_texture_rect(canvas, "hud_window_square", card):
			canvas.draw_rect(card, Color(0.005, 0.018, 0.024, 0.95))
			canvas.draw_rect(card, RealmVisualStyleScript.PANEL_BORDER, false, 1.0)
	canvas.draw_rect(Rect2(card.position, Vector2(card.size.x, 2)), RealmVisualStyleScript.CYAN)
	canvas.draw_string(
		font,
		card.position + Vector2(5, 14),
		"TACTICAL MAP // %02d/%02d" % [explored_sectors.size(), total_survey_sectors],
		HORIZONTAL_ALIGNMENT_LEFT,
		card.size.x - 10,
		8,
		Color("a9cbd1")
	)
	canvas.draw_rect(map_rect, Color("071116"))
	if minimap_cache_texture == null:
		_mark_minimap_dirty(0.0)
	if minimap_cache_texture != null:
		canvas.draw_texture_rect(minimap_cache_texture, map_rect, false)
	var sweep_x := map_rect.position.x + map_rect.size.x * hud_minimap_sweep
	canvas.draw_line(Vector2(sweep_x, map_rect.position.y), Vector2(sweep_x, map_rect.end.y), Color(0.55, 0.9, 1.0, 0.18), 1.0)
	if hud_minimap_bloom > 0.0:
		var bloom_pos = _minimap_position_for_cell(hud_minimap_bloom_cell)
		if bloom_pos != null:
			canvas.draw_circle(bloom_pos, 4.0 + hud_minimap_bloom * 3.0, Color("8eeaff", hud_minimap_bloom * 0.55))
	for spider: Spider in enemies:
		if not _minimap_enemy_visible(spider):
			continue
		var enemy_pos = _minimap_position_for_cell(grid.world_to_cell(spider.position))
		if enemy_pos == null:
			continue
		canvas.draw_circle(enemy_pos, 1.6, Color("ef675f", 0.95))
	for base_id: String in _hud_base_order():
		var record: Dictionary = base_network.get_base(base_id)
		if not bool(record.get("revealed", false)):
			continue
		var cell: Vector2i = record["cell"]
		var marker = _minimap_position_for_cell(cell)
		var color := RealmVisualStyleScript.CYAN if base_id == BaseNetworkScript.COMMAND_ID else Color("72e8ff")
		if marker == null:
			marker = _minimap_edge_marker_for_cell(cell)
			_draw_minimap_edge_tick(canvas, marker, color, cell)
		else:
			canvas.draw_rect(Rect2(marker - Vector2(1.5, 1.5), Vector2(3, 3)), color)
	var player_marker = _minimap_position_for_cell(grid.world_to_cell(player_position))
	if player_marker != null:
		canvas.draw_circle(player_marker, 2.2, Color("dff8fb"))


func _draw_camera_vignette(canvas: CanvasItem, visible_rect: Rect2) -> void:
	# Five cheap hard-edged bands echo the menu's deep framing without a shader.
	for band in range(5):
		var inset := float(band * 7)
		var alpha := 0.052 - float(band) * 0.007
		var inner := visible_rect.grow(-inset)
		var strip_color := Color(0.002, 0.008, 0.013, alpha)
		canvas.draw_rect(Rect2(inner.position, Vector2(inner.size.x, 7)), strip_color)
		canvas.draw_rect(Rect2(inner.position + Vector2(0, inner.size.y - 7), Vector2(inner.size.x, 7)), strip_color)
		canvas.draw_rect(Rect2(inner.position, Vector2(7, inner.size.y)), strip_color)
		canvas.draw_rect(Rect2(inner.position + Vector2(inner.size.x - 7, 0), Vector2(7, inner.size.y)), strip_color)

func _weapon_hud_icon(weapon_id: int) -> Texture2D:
	if weapon_id < 0 or weapon_id >= WEAPON_ICON_NAMES.size():
		return null
	return shop_icons.get(WEAPON_ICON_NAMES[weapon_id])


func _holster_cutter_icon() -> Texture2D:
	var texture: Texture2D = _combat_texture(CombatVfxScript.mining_gun_texture_id(_mining_tool_tier(), "right"))
	if texture != null:
		return texture
	return shop_icons.get("repair")


func _hotbar_stack_icon(stack: Dictionary) -> Texture2D:
	var kind := str(stack.get("kind", OperatorLoadoutScript.KIND_EMPTY))
	match kind:
		OperatorLoadoutScript.KIND_WEAPON:
			return _weapon_hud_icon(int(stack.get("id", -1)))
		OperatorLoadoutScript.KIND_MINING_TOOL:
			return _holster_cutter_icon()
		OperatorLoadoutScript.KIND_BUILD:
			var build_kind := int(stack.get("build_kind", BUILD_BARRICADE))
			if build_kind == BUILD_TORCH:
				return _torch_icon()
			return shop_icons.get(_build_icon_name(build_kind))
		OperatorLoadoutScript.KIND_BLOCK:
			return shop_icons.get(str(stack.get("id", "")), shop_icons.get("stone_block"))
		OperatorLoadoutScript.KIND_DEPLOYABLE:
			var id := str(stack.get("id", ""))
			if id == TORCH_STOCK_ID:
				return _torch_icon()
			var icon: Texture2D = shop_icons.get(id)
			if icon != null:
				return icon
			for build_kind: int in BUILD_STOCK_KEYS.keys():
				if str(BUILD_STOCK_KEYS[build_kind]) == id:
					return _build_preview_texture(build_kind)
	return null
