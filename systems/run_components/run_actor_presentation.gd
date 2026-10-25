## Crawl Brawl actor presentation component - Phase 1 monolith extraction
## Authoritative gameplay/save state remains on CrawlBrawlRun and is proxied here during migration.
extends RefCounted

var host

func _init(run_host) -> void:
	host = run_host

## Dependency-closed compile-time constant mirror from CrawlBrawlRun.
const BaseNetworkScript := preload("res://systems/base_network.gd")

const MaterialEconomyScript := preload("res://systems/material_economy.gd")

const FoundryUnitScript := preload("res://systems/foundry_unit.gd")

const ShelterUnitScript := preload("res://systems/shelter_unit.gd")

const SettlementProgressionScript := preload("res://systems/settlement_progression.gd")

const RealmVisualStyleScript := preload("res://systems/realm_visual_style.gd")

const CombatVfxScript := preload("res://systems/combat_vfx.gd")

const BiomeBestiaryScript := preload("res://systems/biome_bestiary.gd")

const VIEW_SIZE := Vector2(640, 360)

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

const WEAPON_SHOTGUN := 1

const WEAPON_LASER := 2

const WEAPON_RAILGUN := 4

const WEAPON_FLAMETHROWER := 5

const WEAPON_COUNT := 6

const TORCH_STOCK_ID := "torch"

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

const PLAYER_STYLE_SLUGS: Array[String] = ["survey", "foundry", "containment", "veteran"]

const ROLE_LEAPER := 1

const ROLE_SPITTER := 2

const ROLE_BRUTE := 3

const ROLE_BROODLING := 4

const ROLE_GUARDIAN := 5

const BROOD_CARRIER_CHANNEL := 7.0

const PICKUP_PISTOL_AMMO := "pistol_ammo"

const PICKUP_SHOTGUN_AMMO := "shotgun_ammo"

const PICKUP_SMG_AMMO := "smg_ammo"

const PICKUP_RAIL_AMMO := "rail_ammo"

const USE_IMPORTED_RETICLES := true

## Mutable run-state proxies. Ownership remains on CrawlBrawlRun in Phase 1.
var aim_direction:
	get:
		return host.aim_direction
	set(value):
		host.aim_direction = value

var backpack_open:
	get:
		return host.backpack_open
	set(value):
		host.backpack_open = value

var base_network:
	get:
		return host.base_network
	set(value):
		host.base_network = value

var brood_escalation:
	get:
		return host.brood_escalation
	set(value):
		host.brood_escalation = value

var brood_nests:
	get:
		return host.brood_nests
	set(value):
		host.brood_nests = value

var build_mode:
	get:
		return host.build_mode
	set(value):
		host.build_mode = value

var build_orientation:
	get:
		return host.build_orientation
	set(value):
		host.build_orientation = value

var build_target:
	get:
		return host.build_target
	set(value):
		host.build_target = value

var bullets:
	get:
		return host.bullets
	set(value):
		host.bullets = value

var checkpoint_base_id:
	get:
		return host.checkpoint_base_id
	set(value):
		host.checkpoint_base_id = value

var checkpoint_exists:
	get:
		return host.checkpoint_exists
	set(value):
		host.checkpoint_exists = value

var choosing_upgrade:
	get:
		return host.choosing_upgrade
	set(value):
		host.choosing_upgrade = value

var combat_fx_phase:
	get:
		return host.combat_fx_phase
	set(value):
		host.combat_fx_phase = value

var current_weapon:
	get:
		return host.current_weapon
	set(value):
		host.current_weapon = value

var damage_flash:
	get:
		return host.damage_flash
	set(value):
		host.damage_flash = value

var dash_cooldown:
	get:
		return host.dash_cooldown
	set(value):
		host.dash_cooldown = value

var deployable_stock:
	get:
		return host.deployable_stock
	set(value):
		host.deployable_stock = value

var door_hold_time:
	get:
		return host.door_hold_time
	set(value):
		host.door_hold_time = value

var enemies:
	get:
		return host.enemies
	set(value):
		host.enemies = value

var fire_patches:
	get:
		return host.fire_patches
	set(value):
		host.fire_patches = value

var flame_fuel:
	get:
		return host.flame_fuel
	set(value):
		host.flame_fuel = value

var game_over:
	get:
		return host.game_over
	set(value):
		host.game_over = value

var grid:
	get:
		return host.grid
	set(value):
		host.grid = value

var laser_active:
	get:
		return host.laser_active
	set(value):
		host.laser_active = value

var laser_end:
	get:
		return host.laser_end
	set(value):
		host.laser_end = value

var laser_visual_phase:
	get:
		return host.laser_visual_phase
	set(value):
		host.laser_visual_phase = value

var locomotion_phase:
	get:
		return host.locomotion_phase
	set(value):
		host.locomotion_phase = value

var mine_progress:
	get:
		return host.mine_progress
	set(value):
		host.mine_progress = value

var mining_beam_end:
	get:
		return host.mining_beam_end
	set(value):
		host.mining_beam_end = value

var mining_beam_valid:
	get:
		return host.mining_beam_valid
	set(value):
		host.mining_beam_valid = value

var mining_emitter_tier:
	get:
		return host.mining_emitter_tier
	set(value):
		host.mining_emitter_tier = value

var mining_feedback_time:
	get:
		return host.mining_feedback_time
	set(value):
		host.mining_feedback_time = value

var mining_speed_tier:
	get:
		return host.mining_speed_tier
	set(value):
		host.mining_speed_tier = value

var muzzle_flash:
	get:
		return host.muzzle_flash
	set(value):
		host.muzzle_flash = value

var muzzle_flash_max:
	get:
		return host.muzzle_flash_max
	set(value):
		host.muzzle_flash_max = value

var operator_loadout:
	get:
		return host.operator_loadout
	set(value):
		host.operator_loadout = value

var paused:
	get:
		return host.paused
	set(value):
		host.paused = value

var pickups:
	get:
		return host.pickups
	set(value):
		host.pickups = value

var player_active_direction_textures:
	get:
		return host.player_active_direction_textures
	set(value):
		host.player_active_direction_textures = value

var player_camera:
	get:
		return host.player_camera
	set(value):
		host.player_camera = value

var player_direction_textures:
	get:
		return host.player_direction_textures
	set(value):
		host.player_direction_textures = value

var player_dot_time:
	get:
		return host.player_dot_time
	set(value):
		host.player_dot_time = value

var player_hit_recoil:
	get:
		return host.player_hit_recoil
	set(value):
		host.player_hit_recoil = value

var player_hit_time:
	get:
		return host.player_hit_time
	set(value):
		host.player_hit_time = value

var player_move_direction:
	get:
		return host.player_move_direction
	set(value):
		host.player_move_direction = value

var player_moving:
	get:
		return host.player_moving
	set(value):
		host.player_moving = value

var player_position:
	get:
		return host.player_position
	set(value):
		host.player_position = value

var player_slow_time:
	get:
		return host.player_slow_time
	set(value):
		host.player_slow_time = value

var player_style_id:
	get:
		return host.player_style_id
	set(value):
		host.player_style_id = value

var reload_time:
	get:
		return host.reload_time
	set(value):
		host.reload_time = value

var relocating_structure_index:
	get:
		return host.relocating_structure_index
	set(value):
		host.relocating_structure_index = value

var relocation_target:
	get:
		return host.relocation_target
	set(value):
		host.relocation_target = value

var selected_build:
	get:
		return host.selected_build
	set(value):
		host.selected_build = value

var shop_icons:
	get:
		return host.shop_icons
	set(value):
		host.shop_icons = value

var sparks:
	get:
		return host.sparks
	set(value):
		host.sparks = value

var sprinting:
	get:
		return host.sprinting
	set(value):
		host.sprinting = value

var structures:
	get:
		return host.structures
	set(value):
		host.structures = value

var suppress_primary_fire_until_release:
	get:
		return host.suppress_primary_fire_until_release
	set(value):
		host.suppress_primary_fire_until_release = value

var turret_selection_active:
	get:
		return host.turret_selection_active
	set(value):
		host.turret_selection_active = value

var turret_selection_cursor:
	get:
		return host.turret_selection_cursor
	set(value):
		host.turret_selection_cursor = value

var turret_selection_indices:
	get:
		return host.turret_selection_indices
	set(value):
		host.turret_selection_indices = value

var turret_textures:
	get:
		return host.turret_textures
	set(value):
		host.turret_textures = value

var using_chest_index:
	get:
		return host.using_chest_index
	set(value):
		host.using_chest_index = value

var using_core_base:
	get:
		return host.using_core_base
	set(value):
		host.using_core_base = value

var using_foundry:
	get:
		return host.using_foundry
	set(value):
		host.using_foundry = value

var world_textures:
	get:
		return host.world_textures
	set(value):
		host.world_textures = value

var xp_highlights:
	get:
		return host.xp_highlights
	set(value):
		host.xp_highlights = value

func _draw_core(canvas: CanvasItem) -> void:
	for base_id: String in base_network.bases.keys():
		var record: Dictionary = base_network.bases[base_id]
		if not bool(record.get("revealed", false)):
			continue
		var center: Vector2 = grid.cell_to_world(record["cell"])
		var status: String = str(record["status"])
		if status == BaseNetworkScript.STATUS_ACTIVE:
			var radius: float = float(base_network.territory_radius(base_id) * grid.tile_size)
			canvas.draw_circle(center, radius, Color(0.16, 0.75, 0.88, 0.025))
			canvas.draw_arc(center, radius, 0.0, TAU, 64, Color(0.32, 0.82, 0.94, 0.18), 1.0)
		var shell_color: Color = Color("173844")
		var glow_color: Color = Color("73efff")
		if status == BaseNetworkScript.STATUS_SITE:
			shell_color = Color("3a3324")
			glow_color = Color("ffd36b")
		elif status == BaseNetworkScript.STATUS_ACTIVATING:
			shell_color = Color("4b3418")
			glow_color = Color("ff9f43")
		elif status == BaseNetworkScript.STATUS_DISABLED:
			shell_color = Color("292d30")
			glow_color = Color("727b7e")
		var core_half_size := 13.0 if base_id == BaseNetworkScript.COMMAND_ID else 16.0
		var core_size := core_half_size * 2.0
		canvas.draw_rect(Rect2(center - Vector2.ONE * core_half_size, Vector2.ONE * core_size), Color("091a21"))
		var corner_offset := core_half_size - 2.0
		for corner: Vector2 in [Vector2(-corner_offset, -corner_offset), Vector2(corner_offset - 3.0, -corner_offset), Vector2(-corner_offset, corner_offset - 3.0), Vector2(corner_offset - 3.0, corner_offset - 3.0)]:
			canvas.draw_rect(Rect2(center + corner, Vector2(4, 4)), Color("71868a"))
		var shell_half_size := core_half_size - 3.0
		canvas.draw_rect(Rect2(center - Vector2.ONE * shell_half_size, Vector2.ONE * shell_half_size * 2.0), shell_color)
		canvas.draw_rect(Rect2(center - Vector2.ONE * shell_half_size, Vector2.ONE * shell_half_size * 2.0), glow_color, false, 2.0)
		var core_radius := 8.0 if base_id == BaseNetworkScript.COMMAND_ID else 10.0
		canvas.draw_circle(center, core_radius, Color(0.03, 0.17, 0.22, 0.62))
		canvas.draw_arc(center, core_radius, 0.0, TAU, 16, glow_color, 2.0)
		var pulse: float = (4.0 if base_id == BaseNetworkScript.COMMAND_ID else 5.0) + sin(Time.get_ticks_msec() * 0.005) * 1.0
		canvas.draw_circle(center, pulse, Color(glow_color, 0.34))
		# The packaged Core sprite is the final layer; the former procedural orb
		# covered it completely and left only a generic target symbol visible.
		var core_icon_name := "command_core" if base_id == BaseNetworkScript.COMMAND_ID else "frontier_core"
		var core_icon: Texture2D = shop_icons.get(core_icon_name)
		if core_icon != null:
			var icon_size := 28.0 if base_id == BaseNetworkScript.COMMAND_ID else 30.0
			canvas.draw_texture_rect(core_icon, Rect2(center - Vector2.ONE * icon_size * 0.5, Vector2.ONE * icon_size), false, Color.WHITE)
		var label: String = "CMD" if base_id == BaseNetworkScript.COMMAND_ID else ("SITE" if status == BaseNetworkScript.STATUS_SITE else "MK%d" % int(record["tier"]))
		canvas.draw_string(ThemeDB.fallback_font, center + Vector2(-13, 25), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, glow_color)
		if status in [BaseNetworkScript.STATUS_ACTIVE, BaseNetworkScript.STATUS_ACTIVATING]:
			var health_ratio: float = clampf(float(record["health"]) / maxf(1.0, float(record["max_health"])), 0.0, 1.0)
			var under_attack: bool = host._enemies_near_base(base_id, 96.0)
			var health_color := Color("62e0a0") if health_ratio > 0.4 else Color("ef6b62")
			canvas.draw_rect(Rect2(center + Vector2(-16, -22), Vector2(32, 3)), Color("25171a"))
			canvas.draw_rect(Rect2(center + Vector2(-16, -22), Vector2(32.0 * health_ratio, 3)), health_color)
			if under_attack:
				var attack_pulse: float = 20.0 + sin(Time.get_ticks_msec() * 0.012) * 2.0
				canvas.draw_arc(center, attack_pulse, 0.0, TAU, 24, Color("ff725f"), 2.0)

func _draw_structures(canvas: CanvasItem) -> void:
	var cull_rect := Rect2(host._effective_camera_center() - VIEW_SIZE * 0.5, VIEW_SIZE).grow(64.0)
	for structure in structures:
		if not cull_rect.has_point(structure.position):
			continue
		if structure.kind != BUILD_LAND_MINE:
			var shadow_position: Vector2 = structure.position
			if structure.kind in [BUILD_FOUNDRY, BUILD_MERCHANT_STORE]:
				shadow_position = grid.cell_to_world(structure.cell) + Vector2(structure.size - Vector2i.ONE) * float(grid.tile_size) * 0.5
			var shadow_radius: float = 20.0 if structure.kind == BUILD_MERCHANT_STORE else (14.0 if structure.kind == BUILD_FOUNDRY else (8.0 if structure.kind in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET] else 6.0))
			canvas.draw_set_transform(shadow_position + Vector2(0, 4), 0.0, Vector2(1.0, 0.42))
			canvas.draw_circle(Vector2.ZERO, shadow_radius, Color(0.008, 0.015, 0.018, 0.58))
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if structure.kind in [BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER]:
			var barrier_icon_name := "barricade" if structure.kind == BUILD_BARRICADE else str(BUILD_STOCK_KEYS.get(structure.kind, "granite_barrier"))
			var barrier_texture: Texture2D = world_textures.get("barrier")
			var barrier_rect := Rect2(Vector2(-12, -9), Vector2(24, 18))
			canvas.draw_set_transform(structure.position, structure.aim_direction.angle(), Vector2.ONE)
			if barrier_texture != null:
				var barrier_tint := Color("716e64") if structure.is_ruin else _barrier_world_tint(structure.kind)
				canvas.draw_texture_rect(barrier_texture, barrier_rect, false, barrier_tint)
			elif structure.kind == BUILD_STEEL_BARRIER:
				# Steel barrier: draw granite sprite with a steel-blue modulation
				var granite_tex: Texture2D = shop_icons.get("granite_barrier")
				if granite_tex != null:
					canvas.draw_texture_rect(granite_tex, barrier_rect, false, Color(0.55, 0.82, 1.0, 1.0))
				else:
					canvas.draw_rect(Rect2(Vector2(-8, -6), Vector2(16, 12)), Color("3d6a7a"))
			elif barrier_texture != null:
				canvas.draw_texture_rect(barrier_texture, barrier_rect, false)
			else:
				canvas.draw_rect(Rect2(Vector2(-8, -6), Vector2(16, 12)), Color("59616a"))
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			if structure.is_ruin:
				canvas.draw_circle(structure.position + Vector2(4, 5), 2.0, Color("302d28"))
		elif structure.kind == BUILD_LAND_MINE:
			var defense_icon_name := str(BUILD_STOCK_KEYS.get(structure.kind, "land_mine"))
			var defense_texture: Texture2D = shop_icons.get(defense_icon_name)
			if defense_texture != null:
				canvas.draw_texture_rect(defense_texture, Rect2(structure.position - Vector2(8, 8), Vector2(16, 16)), false)
			canvas.draw_arc(structure.position, 7.0 + sin(Time.get_ticks_msec() * 0.008), 0.0, TAU, 16, Color("ff9b45"), 1.0)
		elif structure.kind == BUILD_FOUNDRY:
			var foundry_index = structures.find(structure)
			FoundryUnitScript.ensure_state(structure)
			var foundry_origin = grid.cell_to_world(structure.cell) - Vector2.ONE * float(grid.tile_size) * 0.5
			var foundry_size := Vector2(structure.size) * float(grid.tile_size)
			var foundry_center = foundry_origin + foundry_size * 0.5
			var foundry_rect := Rect2(foundry_origin + Vector2(2, 2), foundry_size - Vector2(4, 4))
			var foundry_online = host._foundry_operational(foundry_index)
			canvas.draw_rect(foundry_rect, Color("10282c") if foundry_online else Color("252629"))
			canvas.draw_rect(foundry_rect, Color("f0a54a") if foundry_online else Color("6e7475"), false, 2.0)
			var foundry_texture: Texture2D = world_textures.get("foundry")
			var foundry_texture_size := foundry_size - Vector2(2, 2)
			if foundry_texture != null:
				canvas.draw_texture_rect(foundry_texture, Rect2(foundry_center - foundry_texture_size * 0.5, foundry_texture_size), false, Color.WHITE if foundry_online else Color(0.55, 0.58, 0.59, 0.9))
			else:
				foundry_texture = shop_icons.get("foundry_furnace")
				if foundry_texture != null:
					canvas.draw_texture_rect(foundry_texture, Rect2(foundry_center - Vector2(13, 13), Vector2(26, 26)), false, Color.WHITE if foundry_online else Color(0.55, 0.58, 0.59, 0.9))
			for tier_pip in range(maxi(1, structure.level)):
				canvas.draw_circle(foundry_center + Vector2(float(tier_pip - 1) * 5.0, 10.0), 1.5, Color("ffca68") if foundry_online else Color("747b7d"))
			var active_recipe_id := FoundryUnitScript.active_recipe(structure)
			if not active_recipe_id.is_empty():
				var production_ratio := FoundryUnitScript.active_progress(structure)
				canvas.draw_rect(Rect2(foundry_center + Vector2(-13, 14), Vector2(26, 3)), Color("251d17"))
				canvas.draw_rect(Rect2(foundry_center + Vector2(-13, 14), Vector2(26.0 * production_ratio, 3)), Color("ffb04f") if foundry_online else Color("846b4f"))
				if foundry_online:
					var heat_pulse := 15.0 + sin(Time.get_ticks_msec() * 0.009) * 1.5
					canvas.draw_arc(foundry_center, heat_pulse, -PI * 0.9, -PI * 0.1, 14, Color(1.0, 0.48, 0.18, 0.55), 1.5)
		elif structure.kind == BUILD_PERSONAL_BASE:
			var shelter_origin = grid.cell_to_world(structure.cell) - Vector2.ONE * float(grid.tile_size) * 0.5
			var shelter_size := Vector2(structure.size) * float(grid.tile_size)
			var shelter_rect := Rect2(shelter_origin + Vector2(2, 2), shelter_size - Vector2(4, 4))
			var shelter_color := Color("233641") if structure.powered else Color("272c30")
			var shelter_texture: Texture2D = world_textures.get("personal_base")
			if shelter_texture != null:
				canvas.draw_texture_rect(shelter_texture, shelter_rect, false, Color.WHITE if structure.powered else Color(0.55, 0.58, 0.59, 0.9))
			else:
				canvas.draw_rect(shelter_rect, shelter_color)
				canvas.draw_rect(shelter_rect, Color("79dced") if structure.powered else Color("69747a"), false, 2.0)
				canvas.draw_rect(Rect2(shelter_rect.position + Vector2(5, 6), Vector2(24, 12)), Color("101b24"))
				canvas.draw_rect(Rect2(shelter_rect.position + Vector2(7, 8), Vector2(9, 8)), Color("6a7696"))
				canvas.draw_line(shelter_rect.position + Vector2(17, 8), shelter_rect.position + Vector2(27, 16), Color("a8b9dc"), 1.0)
				var entrance := Rect2(shelter_rect.end - Vector2(19, 12), Vector2(12, 12))
				canvas.draw_rect(entrance, Color("071116"))
				canvas.draw_rect(entrance, Color("9ce9ff"), false, 1.0)
			if checkpoint_exists and checkpoint_base_id == host._personal_base_anchor_id(structure):
				var anchor_center := shelter_rect.position + Vector2(36, 7)
				canvas.draw_circle(anchor_center, 3.0 + sin(Time.get_ticks_msec() * 0.006), Color(0.55, 0.86, 1.0, 0.24))
				canvas.draw_circle(anchor_center, 1.5, Color("c7f4ff"))
			for tier_pip in range(ShelterUnitScript.clamp_tier(structure.level)):
				canvas.draw_circle(shelter_rect.position + Vector2(8.0 + float(tier_pip) * 5.0, shelter_rect.size.y - 6.0), 1.5, Color("79dced") if structure.powered else Color("69747a"))
			if structure.cooldown > 0.0:
				var cooldown_ratio := 1.0 - clampf(structure.cooldown / ShelterUnitScript.cooldown(structure.level), 0.0, 1.0)
				canvas.draw_rect(Rect2(shelter_rect.position + Vector2(4, shelter_rect.size.y - 4), Vector2(shelter_rect.size.x - 8, 2)), Color("0b1218"))
				canvas.draw_rect(Rect2(shelter_rect.position + Vector2(4, shelter_rect.size.y - 4), Vector2((shelter_rect.size.x - 8) * cooldown_ratio, 2)), Color("5ec9de"))
		elif structure.kind == BUILD_MERCHANT_STORE:
			var store_origin: Vector2 = grid.cell_to_world(structure.cell) - Vector2.ONE * float(grid.tile_size) * 0.5
			var store_size: Vector2 = Vector2(structure.size) * float(grid.tile_size)
			var store_rect: Rect2 = Rect2(store_origin + Vector2(2, 2), store_size - Vector2(4, 4))
			var store_center: Vector2 = store_rect.get_center()
			canvas.draw_rect(store_rect, Color("172b31"))
			canvas.draw_rect(store_rect, Color("e5bd6a"), false, 2.0)
			# Rugged descending-settlement storefront: awning, two windows, sealed entry.
			canvas.draw_rect(Rect2(store_rect.position + Vector2(3, 4), Vector2(store_rect.size.x - 6, 7)), Color("8b512e"))
			for awning_x in range(0, maxi(1, int((store_rect.size.x - 8.0) / 8.0))):
				var stripe_x := store_rect.position.x + 4.0 + float(awning_x) * 8.0
				canvas.draw_rect(Rect2(Vector2(stripe_x, store_rect.position.y + 4.0), Vector2(4, 7)), Color("d3a451") if awning_x % 2 == 0 else Color("713d2b"))
			var window_y := store_rect.position.y + 16.0
			canvas.draw_rect(Rect2(Vector2(store_rect.position.x + 7.0, window_y), Vector2(14, 9)), Color("6bd8df", 0.38))
			canvas.draw_rect(Rect2(Vector2(store_rect.end.x - 21.0, window_y), Vector2(14, 9)), Color("6bd8df", 0.38))
			var door_rect: Rect2 = Rect2(Vector2(store_center.x - 6.0, store_rect.end.y - 15.0), Vector2(12, 13))
			canvas.draw_rect(door_rect, Color("071116"))
			canvas.draw_rect(door_rect, Color("8eeaff"), false, 1.0)
			canvas.draw_string(ThemeDB.fallback_font, Vector2(store_center.x - 15.0, store_rect.position.y + 21.0), "STORE", HORIZONTAL_ALIGNMENT_CENTER, 30, 6, Color("ffe39a"))
			var beacon: Vector2 = store_center + Vector2(0, -2)
			canvas.draw_circle(beacon, 2.0 + sin(Time.get_ticks_msec() * 0.008) * 0.5, Color("8eeaff"))
			if store_center.distance_to(player_position) < SettlementProgressionScript.MERCHANT_STORE_SAFE_RADIUS_CELLS * float(grid.tile_size) + 36.0:
				var safe_radius: float = SettlementProgressionScript.MERCHANT_STORE_SAFE_RADIUS_CELLS * float(grid.tile_size)
				canvas.draw_arc(store_center, safe_radius, 0.0, TAU, 64, Color(0.42, 0.91, 1.0, 0.20), 1.0)
			if store_center.distance_to(player_position) < 58.0:
				canvas.draw_string(ThemeDB.fallback_font, store_center + Vector2(-24, store_rect.size.y * 0.5 + 9), "F  ENTER", HORIZONTAL_ALIGNMENT_CENTER, 48, 7, Color("d9fbff"))
		elif structure.kind == BUILD_TORCH:
			var torch_texture: Texture2D = _torch_icon()
			var torch_color = host._torch_light_color(structure)
			var flame_pulse := sin(Time.get_ticks_msec() * 0.011 + float(structure.cell.x * 7 + structure.cell.y * 13))
			if torch_texture != null:
				canvas.draw_texture_rect(torch_texture, Rect2(structure.position - Vector2(6, 10), Vector2(12, 20)), false, Color.WHITE)
			else:
				canvas.draw_line(structure.position + Vector2(0, 5), structure.position + Vector2(0, -4), Color("7d5a3b"), 2.0)
			canvas.draw_circle(structure.position + Vector2(0, 1), 7.0 + flame_pulse, Color(torch_color, 0.12))
			canvas.draw_circle(structure.position + Vector2(0, -5), 3.0 + flame_pulse * 0.55, torch_color)
			canvas.draw_circle(structure.position + Vector2(0, -5), 1.4, torch_color.lightened(0.45))
			var torch_contacts = host._torch_contact_count(structure)
			if torch_contacts > 0:
				var contact_pulse := 11.0 + sin(Time.get_ticks_msec() * 0.014) * 1.4
				canvas.draw_arc(structure.position, contact_pulse, 0.0, TAU, 16, Color("ff715c"), 1.25)
				canvas.draw_string(ThemeDB.fallback_font, structure.position + Vector2(7, -8), "!%d" % torch_contacts, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("ffd06b"))
			if structure.position.distance_to(player_position) < 42.0:
				canvas.draw_arc(structure.position, 10.0, 0.0, TAU, 16, Color(1.0, 0.72, 0.26, 0.7), 1.0)
		elif structure.kind in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
			var chest_icon_name: String = str(BUILD_STOCK_KEYS.get(structure.kind, "chest_small"))
			var chest_tex: Texture2D = shop_icons.get(chest_icon_name)
			var chest_sizes := {BUILD_CHEST_SMALL: Vector2(16, 12), BUILD_CHEST_MEDIUM: Vector2(22, 16), BUILD_CHEST_LARGE: Vector2(28, 20)}
			var chest_dim: Vector2 = chest_sizes.get(structure.kind, Vector2(16, 12))
			var chest_half: Vector2 = chest_dim * 0.5
			if chest_tex != null:
				canvas.draw_texture_rect(chest_tex, Rect2(structure.position - chest_half, chest_dim), false)
			else:
				var chest_colors := {BUILD_CHEST_SMALL: Color("6aafbd"), BUILD_CHEST_MEDIUM: Color("c8aa40"), BUILD_CHEST_LARGE: Color("b85050")}
				canvas.draw_rect(Rect2(structure.position - chest_half, chest_dim), chest_colors.get(structure.kind, Color("888888")))
				canvas.draw_rect(Rect2(structure.position - chest_half, chest_dim), Color("dddddd"), false, 1.5)
			# Fill indicator bar
			var fill_ratio: float = clampf(float(host._chest_used(structure)) / float(structure.chest_capacity), 0.0, 1.0) if structure.chest_capacity > 0 else 0.0
			canvas.draw_rect(Rect2(structure.position + Vector2(-chest_half.x, chest_half.y + 1), Vector2(chest_dim.x, 2)), Color("112018"))
			canvas.draw_rect(Rect2(structure.position + Vector2(-chest_half.x, chest_half.y + 1), Vector2(chest_dim.x * fill_ratio, 2)), Color("5cd97a"))
			# Glow when nearby
			if structure.position.distance_to(player_position) < 48.0 and using_chest_index < 0:
				canvas.draw_arc(structure.position, chest_half.length() + 2.0 + sin(Time.get_ticks_msec() * 0.007) * 1.2, 0.0, TAU, 20, Color(1.0, 0.87, 0.35, 0.72), 1.5)
			if structure.fortress_chest and not structure.fortress_reward_claimed:
				canvas.draw_string(ThemeDB.fallback_font, structure.position + Vector2(-18, -15), "RELIC", HORIZONTAL_ALIGNMENT_CENTER, 36, 6, Color("ffe394"))
		elif structure.kind == BUILD_HEAVY_DOORWAY:
			# Compute world rect from multi-cell footprint
			var door_pixel_size := Vector2(structure.size) * float(grid.tile_size)
			var door_origin = grid.cell_to_world(structure.cell) - Vector2(grid.tile_size * 0.5, grid.tile_size * 0.5)
			var door_rect := Rect2(door_origin, door_pixel_size)
			var door_center = door_origin + door_pixel_size * 0.5
			var door_color: Color
			var border_color: Color
			if structure.is_open:
				door_color = Color(0.05, 0.35, 0.1, 0.35)
				border_color = Color(0.2, 0.9, 0.35, 0.85)
			else:
				var damage_ratio := clampf(structure.health / structure.max_health, 0.0, 1.0)
				door_color = Color(0.08, 0.18, 0.26, 0.9).lerp(Color(0.4, 0.1, 0.05, 0.9), 1.0 - damage_ratio)
				border_color = Color("5ba8c2") if structure.level == 1 else (Color("c8a030") if structure.level == 2 else Color("e87050"))
			var doorway_texture: Texture2D = world_textures.get("heavy_doorway")
			canvas.draw_rect(door_rect, door_color)
			if doorway_texture != null and not structure.is_open:
				canvas.draw_set_transform(door_center, PI * 0.5 if structure.rotated else 0.0, Vector2.ONE)
				canvas.draw_texture_rect(doorway_texture, Rect2(Vector2(-16, -8), Vector2(32, 16)), false, Color.WHITE)
				canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			canvas.draw_rect(door_rect, border_color, false, 2.0 + float(structure.level - 1) * 0.5)
			# Level pips in the center
			for pip in range(structure.level):
				var pip_x = door_center.x + float(pip - (structure.level - 1) * 0.5) * 5.0
				canvas.draw_circle(Vector2(pip_x, door_center.y), 1.5, border_color)
			# OPEN indicator
			if structure.is_open:
				canvas.draw_string(ThemeDB.fallback_font, door_center + Vector2(-8, 4), "OPEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.3, 1.0, 0.5, 0.9))
			# Hold-to-open progress arc when player is nearby
			var is_near_door := false
			for ox2 in range(structure.size.x):
				for oy2 in range(structure.size.y):
					if grid.cell_to_world(structure.cell + Vector2i(ox2, oy2)).distance_to(player_position) < 52.0:
						is_near_door = true
			if is_near_door and door_hold_time > 0.0:
				var progress := clampf(door_hold_time / 0.45, 0.0, 1.0)
				canvas.draw_arc(door_center, 10.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 20, Color(1.0, 0.85, 0.1, 0.9), 2.0)
		elif structure.kind in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET]:
			var turret_texture: Texture2D = turret_textures.get(structure.kind)
			var turret_size := 24.0 if structure.kind == BUILD_SENTRY else 27.0
			if turret_texture != null:
				canvas.draw_set_transform(structure.position, _turret_sprite_rotation(structure), Vector2.ONE)
				canvas.draw_texture_rect(turret_texture, Rect2(Vector2.ONE * -turret_size * 0.5, Vector2.ONE * turret_size), false, Color.WHITE if structure.powered else Color(0.58, 0.64, 0.66, 0.9))
				canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				canvas.draw_circle(structure.position, 7.0, Color("17262b"))
				canvas.draw_line(structure.position, structure.position + structure.aim_direction * 9.0, Color("d4fbff"), 2.0)
			for tier_ring in range(structure.level - 1):
				canvas.draw_arc(structure.position, 8.0 + tier_ring, -PI * 0.75, PI * 0.75, 10, Color("8eeaff"), 1.0)
			if not structure.powered:
				canvas.draw_line(structure.position + Vector2(-5, -5), structure.position + Vector2(5, 5), Color("ef675f"), 1.0)
			var hunters_targeting: int = host._hunters_targeting_cell(structure.cell)
			if hunters_targeting > 0:
				var threat_pulse: float = 9.5 + sin(Time.get_ticks_msec() * 0.016) * 1.2
				canvas.draw_arc(structure.position, threat_pulse, 0.0, TAU, 18, Color("ff7b58"), 1.5)
				canvas.draw_string(ThemeDB.fallback_font, structure.position + Vector2(8, -9), "!%d" % hunters_targeting, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("ffd06b"))
		if structure.health < structure.max_health or structure.kind in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET]:
			var structure_ratio := clampf(structure.health / structure.max_health, 0.0, 1.0)
			var condition_position = structure.position
			if structure.kind == BUILD_FOUNDRY:
				condition_position = grid.cell_to_world(structure.cell) + Vector2(structure.size - Vector2i.ONE) * float(grid.tile_size) * 0.5
			canvas.draw_rect(Rect2(condition_position + Vector2(-7, -9), Vector2(14, 2)), Color("2b1717"))
			var condition_color := Color("7bdc82") if structure_ratio > 0.55 else (Color("f0b45a") if structure_ratio > 0.3 else Color("ef675f"))
			canvas.draw_rect(Rect2(condition_position + Vector2(-7, -9), Vector2(14 * structure_ratio, 2)), condition_color)
			if structure_ratio < 0.35:
				canvas.draw_line(condition_position + Vector2(-4, -2), condition_position + Vector2(2, 3), Color("241517"), 1.0)
				canvas.draw_line(condition_position + Vector2(2, 3), condition_position + Vector2(5, 0), Color("241517"), 1.0)

func _turret_sprite_rotation(structure) -> float:
	var calibration := 0.0
	if structure.kind == BUILD_ROCKET_TURRET:
		calibration = 0.48
	elif structure.kind == BUILD_LASER_TURRET:
		calibration = 0.78
	return structure.aim_direction.angle() + calibration

func _barrier_world_tint(kind: int) -> Color:
	match kind:
		BUILD_GRANITE_BARRIER:
			return Color("a5c1ca")
		BUILD_STEEL_BARRIER:
			return Color("80c7dc")
		BUILD_REINFORCED_BARRIER:
			return Color("e1b46a")
		BUILD_BLAST_BARRIER:
			return Color("ed7e62")
	return Color.WHITE

func _draw_enemies(canvas: CanvasItem) -> void:
	var visible_rect := Rect2(player_camera.position - VIEW_SIZE * 0.5 - Vector2(48, 48), VIEW_SIZE + Vector2(96, 96))
	for spider in enemies:
		if not visible_rect.has_point(spider.position):
			continue
		var texture: Texture2D = host._mob_texture_for_spider(spider)
		var sprite_size: Vector2 = Vector2(24, 20) if spider.is_brood_carrier else _mob_sprite_size(spider.role)
		var pulse: float = sin(spider.visual_motion + spider.stream_phase)
		var stride: float = sin(spider.visual_motion * 1.9 + spider.stream_phase)
		var sprite_scale := Vector2(1.0 + pulse * 0.035, 1.0 - pulse * 0.025)
		var sprite_rotation = spider.facing_angle
		var sprite_offset := Vector2(0.0, pulse * 0.65)
		if spider.big:
			# Large source art faces opposite the standard mob sheet.
			sprite_rotation += PI
			sprite_scale *= 1.14
		if spider.role == ROLE_BROODLING:
			sprite_rotation += stride * 0.13
			sprite_offset += Vector2(-sin(spider.facing_angle), cos(spider.facing_angle)) * stride * 0.8
		elif spider.role == ROLE_LEAPER and spider.windup > 0.0:
			sprite_scale = Vector2(0.82, 1.18)
			sprite_offset -= Vector2.from_angle(spider.facing_angle) * 2.0
		elif spider.role == ROLE_LEAPER:
			sprite_scale *= Vector2(1.0 + absf(stride) * 0.08, 1.0 - absf(stride) * 0.06)
			sprite_offset += Vector2.from_angle(spider.facing_angle) * maxf(0.0, stride) * 1.3
		elif spider.role == ROLE_SPITTER:
			sprite_scale *= Vector2(1.0 - pulse * 0.025, 1.0 + pulse * 0.065)
			sprite_rotation += stride * 0.035
		elif spider.role == ROLE_BRUTE:
			sprite_offset.y += absf(stride) * 0.8
			sprite_rotation += stride * 0.025
		elif spider.role == ROLE_GUARDIAN:
			sprite_scale *= 1.0 + sin(Time.get_ticks_msec() * 0.006) * 0.035
			sprite_rotation += sin(spider.visual_motion * 0.55) * 0.02
		else:
			sprite_rotation += stride * 0.055
			sprite_offset += Vector2(-sin(spider.facing_angle), cos(spider.facing_angle)) * stride * 0.5
		if spider.attack_cooldown > 0.48:
			sprite_scale *= Vector2(1.13, 0.91)
			sprite_offset += Vector2.from_angle(spider.facing_angle) * 1.5
		if spider.hit_reaction > 0.0:
			var hit_ratio := clampf(spider.hit_reaction / 0.16, 0.0, 1.0)
			sprite_offset += spider.hit_recoil_direction * hit_ratio * 4.0
			sprite_rotation += sin(spider.hit_reaction * 92.0) * 0.12 * hit_ratio
			sprite_scale *= Vector2(1.12, 0.88)

		# Snap textured bodies to the pixel grid. Logical collision/aim positions stay
		# untouched, so presentation no longer shimmers without changing combat.
		var sprite_center: Vector2 = (spider.position + sprite_offset).round()
		var shadow_center: Vector2 = spider.position.round() + Vector2(0, 3)
		# A tight contact shadow anchors the larger art to the collision plane.
		canvas.draw_set_transform(shadow_center, sprite_rotation, Vector2(1.0, 0.38))
		canvas.draw_circle(Vector2.ZERO, sprite_size.x * 0.30, Color(0.015, 0.02, 0.018, 0.58))
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		if spider.role == ROLE_SPITTER:
			canvas.draw_circle(spider.position, spider.radius + 5.5, Color(0.48, 0.95, 0.17, 0.11))
		elif spider.role == ROLE_BROODLING:
			canvas.draw_circle(spider.position, spider.radius + 3.0, Color(0.55, 1.0, 0.22, 0.13))
		elif spider.role == ROLE_GUARDIAN:
			var guardian_pulse := 2.0 + sin(Time.get_ticks_msec() * 0.008) * 1.0
			canvas.draw_circle(spider.position, spider.radius + 9.0, Color(0.82, 0.25, 0.92, 0.10))
			canvas.draw_arc(spider.position, spider.radius + 6.0 + guardian_pulse, 0.0, TAU, 28, Color(0.94, 0.48, 1.0, 0.70), 2.0)
		elif spider.big:
			var alpha_pulse := 2.0 + sin(Time.get_ticks_msec() * 0.01 + spider.stream_phase) * 1.2
			canvas.draw_circle(spider.position, spider.radius + 8.0, Color(0.9, 0.18, 0.08, 0.10))
			canvas.draw_arc(spider.position, spider.radius + 5.0 + alpha_pulse, 0.0, TAU, 24, Color(1.0, 0.42, 0.18, 0.72), 2.0)

		if texture != null:
			var tint := Color("c9ef8a") if spider.is_brood_carrier else Color.WHITE
			if spider.hit_flash > 0.0:
				tint = Color("eaffd7")
			canvas.draw_set_transform(sprite_center, sprite_rotation, sprite_scale)
			canvas.draw_texture_rect(texture, Rect2(-sprite_size * 0.5, sprite_size), false, tint)
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			# Missing art fails visibly without making the enemy disappear.
			canvas.draw_circle(spider.position, spider.radius, Color("d96f59") if spider.hit_flash <= 0.0 else Color("eaffd7"))
		if spider.windup > 0.0:
			var telegraph_radius := maxf(spider.radius + 4.0, sprite_size.x * 0.43) + sin(Time.get_ticks_msec() * 0.02) * 1.5
			canvas.draw_arc(spider.position, telegraph_radius, 0.0, TAU, 16, Color("ff9a59"), 1.5)
		if spider.target_torch_cell.x >= 0:
			var torch_position: Vector2 = grid.cell_to_world(spider.target_torch_cell)
			var torch_direction: Vector2 = (torch_position - spider.position).normalized()
			canvas.draw_arc(spider.position, maxf(spider.radius + 4.0, sprite_size.x * 0.43), -PI * 0.3, PI * 0.3, 8, Color("ffb45c"), 1.5)
			canvas.draw_line(spider.position + torch_direction * (spider.radius + 5.0), spider.position + torch_direction * (spider.radius + 10.0), Color("ffe18a"), 2.0)
		elif spider.hunts_turrets and spider.target_turret_cell.x >= 0:
			var turret_position: Vector2 = grid.cell_to_world(spider.target_turret_cell)
			var hunt_direction: Vector2 = (turret_position - spider.position).normalized()
			var hunter_pulse: float = maxf(spider.radius + 4.0, sprite_size.x * 0.43) + sin(Time.get_ticks_msec() * 0.015 + spider.stream_phase) * 1.0
			canvas.draw_arc(spider.position, hunter_pulse, -PI * 0.3, PI * 0.3, 8, Color("ff7b58"), 1.5)
			canvas.draw_line(spider.position + hunt_direction * hunter_pulse, spider.position + hunt_direction * (hunter_pulse + 5.0), Color("ffd06b"), 2.0)
		if spider.is_brood_carrier:
			var carrier_pulse := maxf(spider.radius + 7.0, sprite_size.x * 0.5) + sin(Time.get_ticks_msec() * 0.012) * 1.5
			canvas.draw_arc(spider.position, carrier_pulse, 0.0, TAU, 20, Color("c8f06b"), 2.0)
			canvas.draw_circle(spider.position + Vector2(0, -sprite_size.y * 0.42), 2.5, Color("d9ff82"))
			if spider.carrier_channel > 0.0:
				canvas.draw_arc(spider.position, carrier_pulse + 3.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(spider.carrier_channel / BROOD_CARRIER_CHANNEL, 0.0, 1.0), 24, Color("ffae4f"), 2.0)
		if spider.health < spider.max_health or spider.big:
			var ratio := clampf(spider.health / spider.max_health, 0.0, 1.0)
			var bar_half_width := maxf(spider.radius, sprite_size.x * 0.32)
			var bar_y := -maxf(spider.radius, sprite_size.y * 0.5) - 5.0
			var bar_height := 4.0 if spider.big else 2.0
			canvas.draw_rect(Rect2(spider.position + Vector2(-bar_half_width, bar_y), Vector2(bar_half_width * 2.0, bar_height)), Color("210c10"))
			canvas.draw_rect(Rect2(spider.position + Vector2(-bar_half_width, bar_y), Vector2(bar_half_width * 2.0 * ratio, bar_height)), Color("d95c45") if spider.big else Color("83e05e"))
			if spider.big:
				var threat_label := "BROOD ALPHA" if spider.brood_nest_cell.x >= 0 else (
					"HIVE GUARDIAN" if spider.role == ROLE_GUARDIAN else BiomeBestiaryScript.display_name_for_role(
						spider.biome_id if spider.biome_id >= 0 else host._biome_for_cell(grid.world_to_cell(spider.position)),
						spider.role
					)
				)
				canvas.draw_string(ThemeDB.fallback_font, spider.position + Vector2(-32, bar_y - 3), threat_label, HORIZONTAL_ALIGNMENT_CENTER, 64, 6, Color("ffd0a3"))

func _draw_brood_nests(canvas: CanvasItem) -> void:
	var visible_rect := Rect2(player_camera.position - VIEW_SIZE * 0.5 - Vector2(40, 40), VIEW_SIZE + Vector2(80, 80))
	for nest in brood_nests:
		var center = grid.cell_to_world(nest.cell)
		if not visible_rect.has_point(center):
			continue
		var maturity_ratio := clampf(nest.maturity, 0.0, 1.0)
		var radius := 8.0 + maturity_ratio * 5.0
		var pulse := sin(Time.get_ticks_msec() * 0.007 + nest.cell.x) * 1.2
		canvas.draw_circle(center + Vector2(0, 3), radius + 4.0, Color(0.02, 0.04, 0.02, 0.72))
		canvas.draw_circle(center, radius + pulse, Color("263f20"))
		var nest_texture: Texture2D = world_textures.get("brood_nest")
		if nest_texture != null:
			var nest_size := Vector2.ONE * (20.0 + maturity_ratio * 8.0)
			canvas.draw_texture_rect(nest_texture, Rect2(center - nest_size * 0.5, nest_size), false, Color.WHITE)
		canvas.draw_arc(center, radius + 2.0, 0.0, TAU, 24, Color("91d85b") if maturity_ratio >= 1.0 else Color("f0ad57"), 2.0)
		if nest_texture == null:
			for egg_index in range(5):
				var egg_offset := Vector2.from_angle(float(egg_index) * TAU / 5.0 + 0.4) * (radius * 0.55)
				canvas.draw_circle(center + egg_offset, 2.0 + maturity_ratio, Color("b8e85b"))
				canvas.draw_circle(center + egg_offset + Vector2(-0.5, -0.8), 0.7, Color("e6ff9a"))
		var health_ratio := clampf(nest.health / nest.max_health, 0.0, 1.0)
		var bar_position = center + Vector2(-26, -radius - 13)
		var nest_label = "APEX // " + nest.apex_id if not nest.apex_id.is_empty() else ("SPIDER LAIR" if nest.is_lair else "BROOD BASE // MK%d" % (brood_escalation + 1))
		canvas.draw_string(ThemeDB.fallback_font, bar_position + Vector2(-18, -2), nest_label, HORIZONTAL_ALIGNMENT_CENTER, 88, 6, Color("e9a0ff") if not nest.apex_id.is_empty() else (Color("ffb57b") if nest.aggressive else Color("c6e996")))
		canvas.draw_rect(Rect2(bar_position + Vector2(0, 1), Vector2(52, 5)), Color("210c10"))
		canvas.draw_rect(Rect2(bar_position + Vector2(0, 1), Vector2(52.0 * health_ratio, 5)), Color("e45d45") if nest.aggressive else Color("9ed657"))
		if maturity_ratio < 1.0:
			canvas.draw_arc(center, radius + 5.0, -PI * 0.5, -PI * 0.5 + TAU * maturity_ratio, 28, Color("ffae4f"), 1.5)

func _mob_sprite_size(role: int) -> Vector2:
	match role:
		ROLE_BROODLING:
			return Vector2(13, 11)
		ROLE_LEAPER:
			return Vector2(27, 21)
		ROLE_SPITTER:
			return Vector2(24, 24)
		ROLE_BRUTE:
			return Vector2(40, 32)
		ROLE_GUARDIAN:
			return Vector2(58, 54)
		_:
			return Vector2(22, 21)

func _draw_bullets(canvas: CanvasItem) -> void:
	var visible_rect: Rect2 = Rect2(host._effective_camera_center() - VIEW_SIZE * 0.5, VIEW_SIZE).grow(96.0)
	for patch in fire_patches:
		if not visible_rect.has_point(patch.position):
			continue
		var ratio := clampf(patch.life / patch.max_life, 0.0, 1.0)
		if patch.player_only:
			_draw_enemy_hazard_patch(canvas, patch, ratio)
			continue
		var patch_texture = host._combat_texture("flame_patch")
		if patch_texture != null:
			var patch_size = Vector2.ONE * patch.radius * (1.2 + ratio * 0.35)
			canvas.draw_set_transform(patch.position, 0.0, Vector2.ONE)
			canvas.draw_texture_rect(patch_texture, Rect2(-patch_size * 0.5, patch_size), false, Color(1.0, 1.0, 1.0, 0.72 + ratio * 0.28))
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			canvas.draw_circle(patch.position, patch.radius * (0.72 + ratio * 0.28), Color(1.0, 0.18, 0.03, 0.10 + ratio * 0.12))
			canvas.draw_arc(patch.position, patch.radius * 0.58, 0.0, TAU, 14, Color("ff8d35", 0.45 + ratio * 0.28), 1.0)
		var ember_texture = host._combat_texture("flame_ember")
		if ember_texture != null:
			host._draw_oriented_combat_sprite(canvas, ember_texture, patch.position + Vector2(0, -2), Vector2.RIGHT, Vector2(8, 8), Color(1.0, 1.0, 1.0, 0.55 + ratio * 0.25))
		else:
			canvas.draw_circle(patch.position + Vector2(0, -2), 4.0 + sin(combat_fx_phase * 4.0) * 1.2, Color("ffb34f", 0.55))
	for bullet in bullets:
		if not visible_rect.has_point(bullet.position):
			continue
		var direction = bullet.velocity.normalized() if bullet.velocity.length_squared() > 0.0001 else Vector2.RIGHT
		var draw_position = bullet.position
		var spin_angle := INF
		var trail_scale := 1.0
		var body_modulate = Color.WHITE if not bullet.enemy_round else bullet.color
		if bullet.enemy_round:
			body_modulate = Color(0.92, 0.85, 1.0) if bullet.is_cyst else Color.WHITE
			var wobble_offset = Vector2(-direction.y, direction.x) * sin(bullet.age * 9.0 + combat_fx_phase) * bullet.visual_wobble
			draw_position += wobble_offset
			if bullet.is_special_lob or bullet.is_cyst:
				draw_position.y -= sin(bullet.age * 6.5) * 2.5
			spin_angle = direction.angle() + bullet.age * bullet.visual_spin_rate
			trail_scale = maxf(1.0, bullet.trail_stretch)
		var projectile_texture = host._projectile_texture_for_bullet(bullet)
		var projectile_size = host._projectile_size_for_bullet(bullet)
		var trail_texture = host._projectile_trail_texture_for_bullet(bullet)
		if trail_texture != null:
			host._draw_oriented_combat_sprite(
				canvas,
				trail_texture,
				draw_position - direction * (projectile_size.x * 0.55),
				direction,
				projectile_size * Vector2(1.15 * trail_scale, 0.85),
				Color(body_modulate, 0.72) if bullet.enemy_round else Color(bullet.color, 0.72),
				spin_angle if bullet.enemy_round else INF
			)
		elif bullet.enemy_round:
			canvas.draw_circle(draw_position, bullet.radius + 4.0, Color(0.5, 0.9, 0.25, 0.14))
			canvas.draw_line(draw_position, draw_position - direction * 7.0, Color(0.58, 0.95, 0.27, 0.45), 2.0)
		elif bullet.projectile_kind == "laser_turret":
			canvas.draw_line(bullet.position, bullet.position - direction * 13.0, Color(0.2, 0.9, 1.0, 0.28), 5.0)
			canvas.draw_line(bullet.position, bullet.position - direction * 11.0, Color("d9feff"), 1.5)
		else:
			canvas.draw_line(bullet.position, bullet.position - direction * 7.0, Color(bullet.color, 0.28), 4.0)
			canvas.draw_line(bullet.position, bullet.position - direction * 5.0, bullet.color, 2.0)
		if projectile_texture != null:
			host._draw_oriented_combat_sprite(
				canvas,
				projectile_texture,
				draw_position,
				direction,
				projectile_size,
				body_modulate,
				spin_angle if bullet.enemy_round else INF
			)
		elif bullet.enemy_round:
			canvas.draw_circle(draw_position, bullet.radius, bullet.color)
		elif bullet.projectile_kind == "rocket":
			canvas.draw_circle(bullet.position, 4.0, Color(1.0, 0.42, 0.12, 0.22))
			canvas.draw_line(bullet.position, bullet.position - direction * 11.0, Color("ff8a38"), 4.0)
			canvas.draw_circle(bullet.position, 2.4, Color("fff0a6"))

func _draw_enemy_hazard_patch(canvas: CanvasItem, patch, ratio: float) -> void:
	var hazard_id := CombatVfxScript.hazard_texture_id(patch.source_damage_type)
	var patch_texture = host._combat_texture(hazard_id) if not hazard_id.is_empty() else null
	var alpha := clampf(0.35 + ratio * 0.2, 0.0, 0.55)
	if patch_texture != null:
		var patch_size = Vector2.ONE * patch.radius * (1.15 + ratio * 0.25)
		canvas.draw_set_transform(patch.position, 0.0, Vector2.ONE)
		canvas.draw_texture_rect(patch_texture, Rect2(-patch_size * 0.5, patch_size), false, Color(1.0, 1.0, 1.0, alpha + 0.15))
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		var fallback := CombatVfxScript.hazard_fallback_color(patch.source_damage_type)
		fallback.a = minf(0.55, fallback.a + ratio * 0.08)
		canvas.draw_circle(patch.position, patch.radius * (0.78 + ratio * 0.18), fallback)
		canvas.draw_arc(patch.position, patch.radius * 0.62, 0.0, TAU, 14, Color(fallback.r, fallback.g, fallback.b, minf(0.55, fallback.a + 0.1)), 1.0)
	var accent_id := CombatVfxScript.hazard_accent_texture_id(patch.source_damage_type)
	var accent = host._combat_texture(accent_id) if not accent_id.is_empty() else null
	if accent != null:
		host._draw_oriented_combat_sprite(
			canvas,
			accent,
			patch.position + Vector2(0, -2),
			Vector2.RIGHT,
			Vector2(8, 8),
			Color(1.0, 1.0, 1.0, 0.45 + ratio * 0.2)
		)

func _draw_player(canvas: CanvasItem) -> void:
	if laser_active:
		var beam_start: Vector2 = _player_muzzle_position()
		var beam_normal := Vector2(-aim_direction.y, aim_direction.x)
		var beam_wobble := sin(laser_visual_phase) * 1.15
		canvas.draw_line(beam_start, laser_end, Color(0.10, 0.52, 1.0, 0.18), 10.0)
		canvas.draw_line(beam_start + beam_normal * beam_wobble, laser_end + beam_normal * beam_wobble, Color(0.18, 0.78, 1.0, 0.56), 5.0)
		canvas.draw_line(beam_start, laser_end, Color("d8fbff"), 1.5)
		host._draw_laser_segment_chain(canvas, beam_start, laser_end, aim_direction)
		var laser_muzzle_texture = host._combat_texture("laser_muzzle")
		if laser_muzzle_texture != null:
			host._draw_oriented_combat_sprite(canvas, laser_muzzle_texture, beam_start, aim_direction, Vector2(12, 12), Color(1.0, 1.0, 1.0, 0.92))
		else:
			canvas.draw_circle(beam_start, 5.0 + sin(laser_visual_phase * 1.7), Color(0.45, 0.92, 1.0, 0.34))
			canvas.draw_circle(beam_start, 2.0, Color("f4ffff"))
		var laser_impact_texture = host._combat_texture("laser_impact")
		if laser_impact_texture != null:
			var impact_pulse := 0.85 + sin(laser_visual_phase * 1.35) * 0.15
			host._draw_oriented_combat_sprite(canvas, laser_impact_texture, laser_end, aim_direction, Vector2(12, 12) * impact_pulse, Color(1.0, 1.0, 1.0, 0.92))
		else:
			var impact_pulse := 5.0 + sin(laser_visual_phase * 1.35) * 1.8
			canvas.draw_circle(laser_end, impact_pulse + 4.0, Color(0.18, 0.72, 1.0, 0.16))
			canvas.draw_arc(laser_end, impact_pulse, 0.0, TAU, 16, Color("8eefff"), 2.0)
			canvas.draw_circle(laser_end, 2.5, Color("ffffff"))
	_draw_player_weapon(canvas, false)
	_draw_player_sprite(canvas)
	_draw_player_status_overlay(canvas)
	_draw_player_weapon(canvas, true)
	if current_weapon == WEAPON_FLAMETHROWER and not build_mode and not suppress_primary_fire_until_release and Input.is_action_pressed("fire") and flame_fuel >= 5:
		var stream_key := "flame_stream_a" if int(Time.get_ticks_msec() / 80) % 2 == 0 else "flame_stream_b"
		var stream_texture = host._combat_texture(stream_key)
		if stream_texture != null:
			host._draw_oriented_combat_sprite(
				canvas,
				stream_texture,
				_player_muzzle_position() + aim_direction * 16.0,
				aim_direction,
				Vector2(24, 12),
				Color(1.0, 1.0, 1.0, 0.92)
			)
	if muzzle_flash > 0.0 and current_weapon != WEAPON_LASER:
		var flash_alpha := clampf(muzzle_flash / maxf(0.001, muzzle_flash_max), 0.35, 1.0)
		var muzzle_texture_id := CombatVfxScript.muzzle_texture_id(current_weapon)
		var muzzle_texture = host._combat_texture(muzzle_texture_id)
		if muzzle_texture != null:
			host._draw_oriented_combat_sprite(
				canvas,
				muzzle_texture,
				_player_muzzle_position(),
				aim_direction,
				Vector2(16, 12),
				Color(1.0, 1.0, 1.0, flash_alpha)
			)
		else:
			canvas.draw_circle(_player_muzzle_position(), 3.5, Color("ffe29a"))
		var recoil_texture_id := CombatVfxScript.recoil_texture_id(current_weapon)
		var recoil_texture = host._combat_texture(recoil_texture_id)
		if recoil_texture != null:
			host._draw_oriented_combat_sprite(
				canvas,
				recoil_texture,
				_player_muzzle_position() - aim_direction * 6.0,
				aim_direction,
				Vector2(16, 16),
				Color(1.0, 1.0, 1.0, flash_alpha * 0.85)
			)
	if reload_time > 0.0:
		var reload_duration = host._weapon_reload_duration(current_weapon)
		canvas.draw_arc(player_position, 9.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - reload_time / reload_duration), 16, Color("86eaff"), 1.5)
	if dash_cooldown > 0.0:
		canvas.draw_arc(player_position, 10.5, 0.0, TAU * (1.0 - dash_cooldown / 1.15), 18, Color(0.35, 0.8, 0.95, 0.55), 1.0)

func _player_direction_texture(use_active_pose: bool = false) -> Texture2D:
	if player_style_id < 0 or player_style_id >= PLAYER_STYLE_SLUGS.size():
		return null
	var direction_key := "%s_%s" % [PLAYER_STYLE_SLUGS[player_style_id], _player_direction_name()]
	if use_active_pose:
		return player_active_direction_textures.get(direction_key, player_direction_textures.get(direction_key))
	return player_direction_textures.get(direction_key)

func _draw_player_sprite(canvas: CanvasItem) -> void:
	var texture: Texture2D = _player_direction_texture(_should_draw_held_weapon())
	if texture == null:
		canvas.draw_circle(player_position, 6.0, Color("59b9d0"))
		return
	var visual_state: Dictionary = _player_visual_state()
	var sprite_position: Vector2 = Vector2(visual_state["position"]).round()
	var gait_scale: Vector2 = visual_state["scale"]
	var shadow_scale_x: float = 1.0 + (0.16 if sprinting else 0.06) * absf(float(visual_state["stride"]))
	canvas.draw_set_transform(player_position + Vector2(0, 3), 0.0, Vector2(shadow_scale_x, 0.58))
	canvas.draw_circle(Vector2.ZERO, 7.5 + (1.0 if sprinting else 0.0), Color(0.01, 0.03, 0.04, 0.65))
	canvas.draw_set_transform(sprite_position, float(visual_state["rotation"]), gait_scale)
	var sprite_modulate := Color("ff8f86") if damage_flash > 0.0 else Color.WHITE
	canvas.draw_texture_rect(texture, Rect2(Vector2(-14, -15), Vector2(28, 30)), false, sprite_modulate)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if sprinting:
		var afterimage_color := Color(0.35, 0.86, 1.0, 0.16)
		canvas.draw_texture_rect(texture, Rect2(sprite_position - player_move_direction * 4.0 - Vector2(14, 15), Vector2(28, 30)), false, afterimage_color)

func _draw_player_status_overlay(canvas: CanvasItem) -> void:
	## Slow rim wins over DoT pulse — never draw both.
	var visual_state: Dictionary = _player_visual_state()
	var overlay_position: Vector2 = visual_state["position"]
	if player_slow_time > 0.0:
		var rim = host._combat_texture("status_venom_rim")
		var rim_alpha := 0.55 + sin(combat_fx_phase * 5.0) * 0.12
		if rim != null:
			canvas.draw_set_transform(overlay_position, 0.0, Vector2.ONE)
			canvas.draw_texture_rect(rim, Rect2(Vector2(-12, -12), Vector2(24, 24)), false, Color(1.0, 1.0, 1.0, rim_alpha))
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			canvas.draw_arc(overlay_position, 11.0, 0.0, TAU, 20, Color(0.45, 0.95, 0.35, rim_alpha), 1.5)
		return
	if player_dot_time <= 0.0:
		return
	var pulse = host._combat_texture("status_dot_pulse")
	var pulse_alpha := 0.4 + sin(combat_fx_phase * 7.0) * 0.15
	var pulse_scale := 0.9 + sin(combat_fx_phase * 7.0) * 0.08
	if pulse != null:
		var size := Vector2(22, 22) * pulse_scale
		canvas.draw_set_transform(overlay_position, 0.0, Vector2.ONE)
		canvas.draw_texture_rect(pulse, Rect2(-size * 0.5, size), false, Color(1.0, 1.0, 1.0, pulse_alpha))
		canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		canvas.draw_circle(overlay_position, 9.0 * pulse_scale, Color(0.75, 0.35, 0.85, pulse_alpha * 0.55))

func _player_visual_state() -> Dictionary:
	var idle_bob := sin(float(Time.get_ticks_msec()) * 0.008) * 0.35
	var stride := sin(locomotion_phase)
	var gait_bob := 0.0
	var gait_rotation := 0.0
	var gait_scale := Vector2.ONE
	var gait_sway := Vector2.ZERO
	if player_moving:
		gait_bob = -absf(stride) * (2.0 if sprinting else 1.15)
		gait_rotation = stride * (0.07 if sprinting else 0.045)
		gait_scale = Vector2(1.0 + absf(stride) * 0.035, 1.0 - absf(stride) * 0.025)
		var movement_normal := Vector2(-player_move_direction.y, player_move_direction.x)
		gait_sway = movement_normal * stride * (0.85 if sprinting else 0.5)
	var tool_recoil := Vector2.ZERO
	if mining_feedback_time > 0.0:
		tool_recoil = -aim_direction * (1.0 + sin(float(Time.get_ticks_msec()) * 0.045) * 0.75)
	elif laser_active:
		tool_recoil = -aim_direction * 0.8
	var hit_ratio := clampf(player_hit_time / 0.24, 0.0, 1.0)
	var hit_shake := Vector2(sin(player_hit_time * 110.0), cos(player_hit_time * 83.0)) * hit_ratio * 1.5
	var hit_rotation := sin(player_hit_time * 95.0) * hit_ratio * 0.16
	if hit_ratio > 0.0:
		gait_scale *= Vector2(1.13, 0.86)
	return {
		"position": player_position + Vector2(0, -6.0 + idle_bob + gait_bob) + gait_sway + tool_recoil + player_hit_recoil * hit_ratio + hit_shake,
		"rotation": gait_rotation + hit_rotation,
		"scale": gait_scale,
		"stride": stride,
	}

func _player_hand_offset(direction_name: String) -> Vector2:
	match direction_name:
		"right":
			return Vector2(5.0, 1.0)
		"left":
			return Vector2(-5.0, 1.0)
		"up":
			return Vector2(0.0, -4.0)
		_:
			return Vector2(0.0, 4.0)

func _player_tool_pose(mining_tool: bool = false) -> Dictionary:
	var visual_state: Dictionary = _player_visual_state()
	var visual_position: Vector2 = visual_state["position"]
	var direction_name: String = _player_direction_name()
	if mining_tool:
		var mining_mount = visual_position + _player_hand_offset(direction_name) * 0.35 + aim_direction * 9.0
		return {
			"mount": mining_mount,
			"muzzle": mining_mount + aim_direction * 14.0,
			"rotation": 0.0,
			"weapon_id": -1,
			"mining_tool": true,
		}
	var mount_position = visual_position + _player_hand_offset(direction_name) + aim_direction * 2.0
	var weapon_id: int = clampi(current_weapon, 0, WEAPON_COUNT - 1)
	var spec: Dictionary = CombatVfxScript.held_weapon_spec(weapon_id)
	return {
		"mount": mount_position,
		"muzzle": _held_weapon_muzzle_world(mount_position, spec, aim_direction),
		"rotation": float(_held_weapon_draw_transform(spec, aim_direction)["angle"]),
		"weapon_id": weapon_id,
		"mining_tool": mining_tool,
		"texture": host._combat_texture(str(spec.get("texture", ""))),
	}

func _player_weapon_draws_behind() -> bool:
	return false

func _should_draw_held_weapon() -> bool:
	return _should_draw_mining_gun() or _should_draw_combat_crosshair()

func _should_draw_mining_gun() -> bool:
	if relocating_structure_index >= 0 or host._primary_break_held() or mining_beam_valid:
		return true
	return operator_loadout != null and operator_loadout.is_cutter_selected()

func _mining_tool_tier() -> int:
	return clampi(maxi(mining_speed_tier, mining_emitter_tier), 1, 5)

func _held_weapon_draw_transform(spec: Dictionary, direction: Vector2) -> Dictionary:
	var dir := direction.normalized() if direction.length_squared() > 0.0001 else Vector2.RIGHT
	var barrel: Vector2 = spec["muzzle"] - spec["grip"]
	if barrel.length_squared() <= 0.0001:
		return {"angle": dir.angle(), "scale": Vector2.ONE}
	return {"angle": dir.angle() - barrel.angle(), "scale": Vector2.ONE}

func _held_weapon_muzzle_world(mount_position: Vector2, spec: Dictionary, direction: Vector2) -> Vector2:
	var barrel: Vector2 = spec["muzzle"] - spec["grip"]
	var xf: Dictionary = _held_weapon_draw_transform(spec, direction)
	return mount_position + barrel.rotated(xf["angle"])

func _draw_held_weapon_sprite(canvas: CanvasItem, tool_pose: Dictionary) -> void:
	var weapon_id: int = int(tool_pose.get("weapon_id", current_weapon))
	var texture_id: String = CombatVfxScript.held_weapon_texture_id(weapon_id)
	var texture: Texture2D = host._combat_texture(texture_id)
	if texture == null:
		_draw_procedural_held_weapon(canvas, tool_pose)
		return
	var spec: Dictionary = CombatVfxScript.held_weapon_spec(weapon_id)
	var grip: Vector2 = spec["grip"]
	var size: Vector2 = spec["size"]
	var mount_position: Vector2 = Vector2(tool_pose["mount"]).round()
	var xf: Dictionary = _held_weapon_draw_transform(spec, aim_direction)
	canvas.draw_set_transform(mount_position, float(xf["angle"]), xf["scale"])
	canvas.draw_texture_rect(texture, Rect2(-grip, size), false, Color.WHITE)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_procedural_held_weapon(canvas: CanvasItem, tool_pose: Dictionary) -> void:
	var mount_position: Vector2 = tool_pose["mount"]
	var muzzle: Vector2 = tool_pose["muzzle"]
	var weapon_id: int = int(tool_pose.get("weapon_id", current_weapon))
	var mining_tool: bool = bool(tool_pose.get("mining_tool", false))
	var normal := Vector2(-aim_direction.y, aim_direction.x)
	var grip_color := Color("5a8a92") if mining_tool else Color("5f6d74")
	var barrel_color := Color("8aa0a8")
	match weapon_id:
		WEAPON_LASER:
			barrel_color = Color("62b8d4")
		WEAPON_FLAMETHROWER:
			barrel_color = Color("c8843a")
		WEAPON_RAILGUN:
			barrel_color = Color("a8bcc8")
		WEAPON_SHOTGUN:
			barrel_color = Color("7a8890")
	var barrel_width := 3.0 if weapon_id in [WEAPON_SHOTGUN, WEAPON_RAILGUN, WEAPON_FLAMETHROWER] else 2.0
	canvas.draw_line(mount_position - normal * 1.6, mount_position + normal * 1.6, grip_color, 2.0)
	canvas.draw_line(mount_position, muzzle, barrel_color, barrel_width)
	if weapon_id == WEAPON_LASER or mining_tool:
		canvas.draw_circle(muzzle, 1.4, Color("9cecff"))

func _player_muzzle_position(mining_tool: bool = false) -> Vector2:
	var tool_pose: Dictionary = _player_tool_pose(mining_tool)
	var desired_muzzle: Vector2 = tool_pose["muzzle"]
	if not is_instance_valid(grid):
		return desired_muzzle
	var desired_offset = desired_muzzle - player_position
	var desired_forward := maxf(0.0, desired_offset.dot(aim_direction))
	if desired_forward <= 0.0:
		return desired_muzzle
	var safe_forward = host._ray_terrain_distance(player_position, aim_direction, desired_forward)
	if safe_forward >= desired_forward:
		return desired_muzzle
	var lateral_offset = desired_offset - aim_direction * desired_forward
	var clamp_ratio = safe_forward / desired_forward
	return player_position + aim_direction * safe_forward + lateral_offset * clamp_ratio

func _draw_player_weapon(canvas: CanvasItem, foreground: bool) -> void:
	if not _should_draw_held_weapon():
		return
	if _player_weapon_draws_behind() != (not foreground):
		return
	if _should_draw_mining_gun():
		_draw_mining_gun_sprite(canvas, _player_tool_pose(true))
	else:
		_draw_held_weapon_sprite(canvas, _player_tool_pose(false))

func _draw_mining_gun_sprite(canvas: CanvasItem, tool_pose: Dictionary) -> void:
	var direction_name := CombatVfxScript.mining_gun_direction(aim_direction)
	var texture_id := CombatVfxScript.mining_gun_texture_id(_mining_tool_tier(), direction_name)
	var texture: Texture2D = host._combat_texture(texture_id)
	var mount_position: Vector2 = Vector2(tool_pose["mount"]).round()
	if texture != null:
		canvas.draw_texture_rect(texture, Rect2(mount_position - Vector2(16, 16), CombatVfxScript.MINING_GUN_CANVAS), false, Color.WHITE)
		return
	_draw_procedural_held_weapon(canvas, tool_pose)

func _player_direction_name() -> String:
	if absf(aim_direction.x) > absf(aim_direction.y):
		return "right" if aim_direction.x >= 0.0 else "left"
	return "down" if aim_direction.y >= 0.0 else "up"

func _draw_sparks(canvas: CanvasItem) -> void:
	var visible_rect: Rect2 = Rect2(host._effective_camera_center() - VIEW_SIZE * 0.5, VIEW_SIZE).grow(72.0)
	for spark in sparks:
		if not visible_rect.has_point(spark.position):
			continue
		var color = spark.color
		color.a = clampf(spark.life / spark.max_life, 0.0, 1.0)
		canvas.draw_rect(Rect2(spark.position, Vector2.ONE * spark.size), color)
	for highlight in xp_highlights:
		if not visible_rect.has_point(highlight.position):
			continue
		var alpha := clampf(highlight.life / highlight.max_life, 0.0, 1.0)
		var text_color := Color(highlight.color, alpha)
		var shadow_color := Color(0.04, 0.08, 0.12, alpha * 0.85)
		canvas.draw_string(ThemeDB.fallback_font, highlight.position + Vector2(1, 1), highlight.text, HORIZONTAL_ALIGNMENT_CENTER, 72, 8, shadow_color)
		canvas.draw_string(ThemeDB.fallback_font, highlight.position, highlight.text, HORIZONTAL_ALIGNMENT_CENTER, 72, 8, text_color)

func _draw_pickups(canvas: CanvasItem) -> void:
	var now := float(Time.get_ticks_msec()) * 0.006
	for pickup in pickups:
		if pickup.position.distance_to(host._effective_camera_center()) > 390.0:
			continue
		var bob := sin(now + pickup.phase) * 2.0
		var draw_position = (pickup.position + Vector2(0, bob)).round()
		var texture: Texture2D = world_textures.get("pickup")
		canvas.draw_circle(draw_position, 6.5, Color(1.0, 0.72, 0.22, 0.10))
		canvas.draw_arc(draw_position, 5.5 + sin(now * 1.7 + pickup.phase) * 0.5, 0.0, TAU, 12, Color(1.0, 0.82, 0.38, 0.62), 1.0)
		if texture != null:
			canvas.draw_texture_rect(texture, Rect2(draw_position - Vector2(6, 6), Vector2(12, 12)), false, _pickup_world_tint(pickup.kind))
		else:
			texture = _pickup_icon(pickup.kind)
			if texture != null:
				canvas.draw_texture_rect(texture, Rect2(draw_position - Vector2(5, 5), Vector2(10, 10)), false)
			else:
				canvas.draw_rect(Rect2(draw_position - Vector2(3, 3), Vector2(6, 6)), Color("ffd36b"))

func _pickup_world_tint(kind: String) -> Color:
	match kind:
		PICKUP_SHOTGUN_AMMO, PICKUP_SMG_AMMO, PICKUP_RAIL_AMMO:
			return Color("ffd27a")
		PICKUP_PISTOL_AMMO:
			return Color("d6f4ff")
	if kind in [MaterialEconomyScript.ENERGY_CRYSTAL, MaterialEconomyScript.QUARTZ, MaterialEconomyScript.ROUGH_DIAMOND]:
		return Color("b1f4ff")
	if kind in [MaterialEconomyScript.GOLD_ORE, MaterialEconomyScript.SULFUR]:
		return Color("ffd475")
	return Color("a9e899")

func _pickup_icon(kind: String) -> Texture2D:
	var raw_icons := {
		MaterialEconomyScript.COPPER_ORE: "copper_ore", MaterialEconomyScript.SILVER_ORE: "silver_ore",
		MaterialEconomyScript.GOLD_ORE: "gold_ore", MaterialEconomyScript.ENERGY_CRYSTAL: "energy_crystal",
		MaterialEconomyScript.ROUGH_DIAMOND: "rough_diamond", MaterialEconomyScript.GRANITE: "granite",
		MaterialEconomyScript.BASALT: "basalt", MaterialEconomyScript.QUARTZ: "quartz",
		MaterialEconomyScript.IRON_ORE: "iron_ore", MaterialEconomyScript.TITANIUM_ORE: "titanium_ore",
		MaterialEconomyScript.SULFUR: "sulfur", MaterialEconomyScript.COAL: "coal",
	}
	if raw_icons.has(kind):
		return shop_icons.get(str(raw_icons[kind]))
	match kind:
		PICKUP_SHOTGUN_AMMO:
			return shop_icons.get("shotgun_ammo")
		PICKUP_SMG_AMMO:
			return shop_icons.get("smg_mag")
		PICKUP_RAIL_AMMO:
			return shop_icons.get("rail_slug")
	return shop_icons.get("pistol_ammo")

func _draw_mining_beam(canvas: CanvasItem) -> void:
	if not host._primary_break_held() or not mining_beam_valid:
		return
	var target_position: Vector2 = mining_beam_end
	var feedback_position := _mining_feedback_position(target_position)
	var beam_start: Vector2 = _player_muzzle_position(true)
	var mining_normal := Vector2(-aim_direction.y, aim_direction.x)
	var vibration := sin(float(Time.get_ticks_msec()) * 0.05) * 1.4
	var beam_width: float = host._mining_beam_width()
	canvas.draw_line(beam_start, target_position, Color(0.22, 0.70, 0.85, 0.20), beam_width)
	canvas.draw_line(beam_start + mining_normal * vibration, target_position + mining_normal * vibration, Color("77e9ff"), maxf(2.5, beam_width * 0.34))
	canvas.draw_line(beam_start, target_position, Color("f4fdff"), 1.0 + float(mining_emitter_tier - 1) * 0.15)
	var progress_width := clampf(mine_progress / host._mining_cycle_duration(), 0.0, 1.0) * 14.0
	canvas.draw_rect(Rect2(feedback_position + Vector2(-7, -10), Vector2(14, 2)), Color("1c3238"))
	canvas.draw_rect(Rect2(feedback_position + Vector2(-7, -10), Vector2(progress_width, 2)), Color("72e8ff"))
	canvas.draw_arc(feedback_position, 6.0 + vibration * 0.35, 0.0, TAU, 12, Color("f0b866"), 1.5)
	for crack_index in range(3):
		var crack_angle = float(crack_index) * TAU / 3.0 + mine_progress * 5.0
		canvas.draw_line(feedback_position + Vector2.from_angle(crack_angle) * 2.0, feedback_position + Vector2.from_angle(crack_angle) * (4.0 + mine_progress * 8.0), Color("e8c18a"), 1.0)

func _mining_feedback_position(target_position: Vector2) -> Vector2:
	var minimum_forward := minf(32.0, host._mining_beam_reach())
	var current_forward = (target_position - player_position).dot(aim_direction)
	if current_forward >= minimum_forward:
		return target_position
	return target_position + aim_direction * (minimum_forward - current_forward)

func _draw_targeting(canvas: CanvasItem) -> void:
	if turret_selection_active and not turret_selection_indices.is_empty():
		for selection_index in range(turret_selection_indices.size()):
			var sentry = structures[turret_selection_indices[selection_index]]
			var selected: bool = selection_index == turret_selection_cursor
			var ring_color := Color("ffe06b") if selected else Color(0.45, 0.85, 0.95, 0.5)
			canvas.draw_arc(sentry.position, 13.0 if selected else 10.0, 0.0, TAU, 24, ring_color, 2.0 if selected else 1.0)
			if selected:
				canvas.draw_string(ThemeDB.fallback_font, sentry.position + Vector2(-28, -17), host._turret_id(sentry), HORIZONTAL_ALIGNMENT_CENTER, 56, 7, Color("fff2a8"))
	if relocating_structure_index >= 0:
		_draw_relocation_hologram(canvas)
	if build_mode:
		_draw_build_hologram(canvas)

	if _should_draw_combat_crosshair():
		_draw_combat_crosshair(canvas, host._combat_pointer_world())

func _should_draw_combat_crosshair() -> bool:
	if paused or backpack_open or game_over or choosing_upgrade or using_core_base or using_foundry or using_chest_index >= 0 or turret_selection_active:
		return false
	if relocating_structure_index >= 0:
		return false
	if host._primary_break_held():
		return false
	return true

func _draw_relocation_hologram(canvas: CanvasItem) -> void:
	if relocating_structure_index < 0 or relocating_structure_index >= structures.size():
		return
	var structure = structures[relocating_structure_index]
	var valid = host._can_place_relocated_structure(relocation_target)
	var tile_size := float(grid.tile_size)
	var origin = grid.cell_to_world(relocation_target) - Vector2.ONE * tile_size * 0.5
	var pixel_size := Vector2(structure.size) * tile_size
	var center = origin + pixel_size * 0.5
	var edge := Color("62eaff") if valid else Color("ff665d")
	canvas.draw_line(_player_muzzle_position(true), center, Color(edge, 0.36), 1.0)
	for x: int in range(structure.size.x):
		for y: int in range(structure.size.y):
			var cell_rect := Rect2(origin + Vector2(x * tile_size, y * tile_size), Vector2.ONE * tile_size)
			canvas.draw_rect(cell_rect.grow(-1.0), Color(edge, 0.16))
			canvas.draw_rect(cell_rect.grow(-1.0), Color(edge, 0.82), false, 1.0)
	canvas.draw_rect(Rect2(origin, pixel_size), Color(edge, 0.28), false, 2.0)
	canvas.draw_string(ThemeDB.fallback_font, center + Vector2(-36, -12), "FIRE: PLACE", HORIZONTAL_ALIGNMENT_CENTER, 72, 7, Color(edge, 0.96))

func _draw_combat_crosshair(canvas: CanvasItem, center: Vector2) -> void:
	var color := Color("72e8ff")
	if build_mode:
		color = Color("ffc45c")
	elif host._primary_break_held():
		color = Color("f2fbff")
	elif current_weapon == WEAPON_FLAMETHROWER:
		color = Color("ff944d")
	elif current_weapon == WEAPON_RAILGUN:
		color = Color("b8f6ff")
	var pulse := 0.82 + sin(float(Time.get_ticks_msec()) * 0.009) * 0.18
	var reticle_size := Vector2(24, 24)
	var texture_id = host._crosshair_reticle_texture_id()
	var hotspot := CombatVfxScript.reticle_hotspot(texture_id)
	var reticle_rect := Rect2(center - hotspot, reticle_size)
	if USE_IMPORTED_RETICLES and host._draw_ui_texture_rect(canvas, texture_id, reticle_rect, Color(color, pulse)):
		return
	var shadow := Color(0.005, 0.015, 0.02, 0.94)
	canvas.draw_circle(center, 4.0, shadow)
	canvas.draw_circle(center, 1.8, Color("f7ffff"))
	canvas.draw_arc(center, 9.0 + pulse * 4.0, 0.0, TAU, 24, shadow, 4.0)
	canvas.draw_arc(center, 9.0 + pulse * 4.0, 0.0, TAU, 24, color, 1.5)
	for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		var inner := center + direction * 12.0
		var outer := center + direction * 18.0
		canvas.draw_line(inner, outer, shadow, 4.0)
		canvas.draw_line(inner, outer, color.lightened(0.25), 1.5)

func _build_icon_name(build_kind: int) -> String:
	if build_kind == BUILD_BARRICADE:
		return "barricade"
	if build_kind == BUILD_SENTRY:
		return "sentry"
	if build_kind == BUILD_FOUNDRY:
		return "foundry_furnace"
	if build_kind == BUILD_PERSONAL_BASE:
		return "command_core"
	if build_kind == BUILD_MERCHANT_STORE:
		return "command_core"
	if build_kind == BUILD_HEAVY_DOORWAY:
		return "steel_barrier"
	if build_kind == BUILD_STEEL_BARRIER:
		return "granite_barrier"
	if build_kind == BUILD_TORCH:
		return "lamp"
	return str(BUILD_STOCK_KEYS.get(build_kind, "barricade"))

func _torch_icon() -> Texture2D:
	var lamp: Texture2D = world_textures.get("lamp")
	if lamp != null:
		return lamp
	return shop_icons.get("repair")

func _build_preview_texture(build_kind: int) -> Texture2D:
	if build_kind == BUILD_TORCH:
		return _torch_icon()
	return shop_icons.get(_build_icon_name(build_kind))

func _build_role_label(build_kind: int) -> String:
	if build_kind in [BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER]:
		return "BARRIER"
	if build_kind in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET, BUILD_LAND_MINE]:
		return "DEFENSE"
	if build_kind in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
		return "STORAGE"
	if build_kind == BUILD_FOUNDRY:
		return "PRODUCTION"
	if build_kind == BUILD_PERSONAL_BASE:
		return "CHECKPOINT"
	if build_kind == BUILD_MERCHANT_STORE:
		return "SETTLEMENT"
	return "ACCESS"

func _build_available_amount(build_kind: int) -> int:
	if build_kind == BUILD_BARRICADE or build_kind == BUILD_SENTRY:
		return -1
	if build_kind == BUILD_FOUNDRY:
		return host._foundry_stock_available()
	return int(deployable_stock.get(str(BUILD_STOCK_KEYS.get(build_kind, "")), 0))

func _build_range(build_kind: int) -> float:
	if build_kind == BUILD_SENTRY:
		return 128.0
	if build_kind == BUILD_ROCKET_TURRET:
		return 160.0
	if build_kind == BUILD_LASER_TURRET:
		return 176.0
	if build_kind == BUILD_LAND_MINE:
		return 14.0
	return 0.0

func _draw_build_hologram(canvas: CanvasItem) -> void:
	var valid = host._can_place_structure(build_target)
	var footprint = host._footprint_for_build(selected_build, build_orientation)
	var tile_size := float(grid.tile_size)
	var origin = grid.cell_to_world(build_target) - Vector2.ONE * tile_size * 0.5
	var pixel_size := Vector2(footprint) * tile_size
	var center = origin + pixel_size * 0.5
	var edge := Color("62eaff") if valid else Color("ff665d")
	var tint := Color(0.56, 0.93, 1.0, 0.82) if valid else Color(1.0, 0.38, 0.32, 0.82)
	var pulse := 0.72 + sin(Time.get_ticks_msec() * 0.012) * 0.14
	for x in range(footprint.x):
		for y in range(footprint.y):
			var cell_rect := Rect2(origin + Vector2(x * tile_size, y * tile_size), Vector2.ONE * tile_size)
			canvas.draw_rect(cell_rect.grow(-1.0), Color(edge, 0.10 + pulse * 0.10))
			canvas.draw_rect(cell_rect.grow(-1.0), Color(edge, 0.72), false, 1.0)
	canvas.draw_rect(Rect2(origin, pixel_size), Color(edge, 0.22), false, 2.0)

	var build_range := _build_range(selected_build)
	if build_range > 0.0:
		var range_color := Color("77eaff") if selected_build != BUILD_LAND_MINE else Color("ffb05a")
		canvas.draw_circle(center, build_range, Color(range_color, 0.035))
		canvas.draw_arc(center, build_range, 0.0, TAU, 40, Color(range_color, 0.38), 1.0)
		if selected_build == BUILD_LAND_MINE:
			canvas.draw_arc(center, 42.0, 0.0, TAU, 24, Color("ff9b45", 0.22), 1.0)

	if selected_build in [BUILD_SENTRY, BUILD_ROCKET_TURRET, BUILD_LASER_TURRET]:
		var turret_preview: Texture2D = turret_textures.get(selected_build)
		var turret_size := 24.0 if selected_build == BUILD_SENTRY else 27.0
		if turret_preview != null:
			canvas.draw_set_transform(center, aim_direction.angle(), Vector2.ONE)
			canvas.draw_texture_rect(turret_preview, Rect2(Vector2.ONE * -turret_size * 0.5, Vector2.ONE * turret_size), false, tint)
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			canvas.draw_circle(center, 8.0, tint)
			canvas.draw_line(center, center + aim_direction * 12.0, edge, 2.0)
	elif selected_build == BUILD_HEAVY_DOORWAY:
		canvas.draw_rect(Rect2(origin + Vector2(3, 3), pixel_size - Vector2(6, 6)), Color("25465b", 0.72))
		canvas.draw_rect(Rect2(origin + Vector2(3, 3), pixel_size - Vector2(6, 6)), edge, false, 2.0)
		canvas.draw_line(center - Vector2(7, 0) if footprint.x > footprint.y else center - Vector2(0, 7), center + Vector2(7, 0) if footprint.x > footprint.y else center + Vector2(0, 7), Color("d9f9ff", 0.9), 2.0)
	elif selected_build == BUILD_PERSONAL_BASE:
		canvas.draw_rect(Rect2(origin + Vector2(3, 3), pixel_size - Vector2(6, 6)), Color("193847", 0.74))
		canvas.draw_rect(Rect2(origin + Vector2(3, 3), pixel_size - Vector2(6, 6)), edge, false, 2.0)
		canvas.draw_circle(center, 8.0, Color("12242d", 0.9))
		canvas.draw_arc(center, 8.0, 0.0, TAU, 16, Color("d8f7ff", 0.9), 1.5)
		canvas.draw_line(center + Vector2(-4, 0), center + Vector2(4, 0), Color("d8f7ff", 0.9), 1.0)
		canvas.draw_line(center + Vector2(0, -4), center + Vector2(0, 4), Color("d8f7ff", 0.9), 1.0)
	elif selected_build == BUILD_MERCHANT_STORE:
		var store_preview_rect: Rect2 = Rect2(origin + Vector2(3, 3), pixel_size - Vector2(6, 6))
		canvas.draw_rect(store_preview_rect, Color("172b31", 0.78))
		canvas.draw_rect(store_preview_rect, Color(edge, 0.92), false, 2.0)
		canvas.draw_rect(Rect2(store_preview_rect.position + Vector2(3, 4), Vector2(store_preview_rect.size.x - 6, 6)), Color("b87b3e", 0.78))
		canvas.draw_rect(Rect2(Vector2(store_preview_rect.get_center().x - 5, store_preview_rect.end.y - 13), Vector2(10, 11)), Color("071116", 0.9))
		canvas.draw_string(ThemeDB.fallback_font, store_preview_rect.position + Vector2(8, 20), "STORE", HORIZONTAL_ALIGNMENT_CENTER, maxi(24, int(store_preview_rect.size.x - 16)), 7, Color("ffe39a"))
	elif selected_build in [BUILD_BARRICADE, BUILD_GRANITE_BARRIER, BUILD_STEEL_BARRIER, BUILD_REINFORCED_BARRIER, BUILD_BLAST_BARRIER]:
		var barrier_preview: Texture2D = shop_icons.get(_build_icon_name(selected_build))
		if barrier_preview != null:
			canvas.draw_set_transform(center, aim_direction.angle(), Vector2.ONE)
			canvas.draw_texture_rect(barrier_preview, Rect2(Vector2(-12, -9), Vector2(24, 18)), false, tint)
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			canvas.draw_circle(center, 7.0, tint)
	elif selected_build == BUILD_TORCH:
		var torch_preview: Texture2D = _torch_icon()
		if torch_preview != null:
			canvas.draw_texture_rect(torch_preview, Rect2(center - Vector2(6, 10), Vector2(12, 20)), false, tint)
		else:
			canvas.draw_circle(center, 7.0, tint)
	else:
		var preview_texture: Texture2D = _build_preview_texture(selected_build)
		if preview_texture != null:
			var icon_size := 30.0 if selected_build == BUILD_FOUNDRY else 24.0
			canvas.draw_texture_rect(preview_texture, Rect2(center - Vector2.ONE * icon_size * 0.5, Vector2.ONE * icon_size), false, tint)
		else:
			canvas.draw_circle(center, 7.0, tint)

	var orientation_hint := "R ROTATE" if selected_build == BUILD_HEAVY_DOORWAY else "%dx%d FOOTPRINT" % [footprint.x, footprint.y]
	canvas.draw_string(ThemeDB.fallback_font, origin + Vector2(0, -5), orientation_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(edge, 0.95))

func _draw_build_belt(canvas: CanvasItem) -> void:
	var available: Array[int] = host._available_build_types()
	if available.is_empty():
		return
	var current_index := available.find(selected_build)
	if current_index < 0:
		current_index = 0
	var slots: Array[int] = [available[posmod(current_index - 1, available.size())], available[current_index], available[posmod(current_index + 1, available.size())]]
	var rects: Array[Rect2] = [Rect2(190, 287, 54, 34), Rect2(250, 278, 120, 48), Rect2(376, 287, 54, 34)]
	var font: Font = ThemeDB.fallback_font
	for slot_index in range(slots.size()):
		var kind: int = slots[slot_index]
		var selected := slot_index == 1
		var amount := _build_available_amount(kind)
		var usable := amount != 0
		var rect: Rect2 = rects[slot_index]
		var border := RealmVisualStyleScript.CYAN if selected and usable else (Color("ef8068") if selected else Color("35535d"))
		canvas.draw_rect(rect, Color("0a2028", 0.96) if usable else Color("18191c", 0.94))
		canvas.draw_rect(rect, border, false, 2.0 if selected else 1.0)
		if selected:
			canvas.draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2)), border)
		var texture: Texture2D = shop_icons.get(_build_icon_name(kind))
		var icon_size := 25.0 if selected else 16.0
		var icon_position := rect.position + Vector2(12, rect.size.y * 0.5 - icon_size * 0.5) if selected else rect.get_center() - Vector2.ONE * icon_size * 0.5
		if kind == BUILD_PERSONAL_BASE:
			var shelter_rect := Rect2(icon_position, Vector2(icon_size, icon_size * 0.68))
			canvas.draw_rect(shelter_rect, Color("234854") if usable else Color("3a3435"))
			canvas.draw_rect(shelter_rect, Color("c9f7ff") if usable else Color("8d6967"), false, 1.0)
			var shelter_center := shelter_rect.get_center()
			canvas.draw_circle(shelter_center, icon_size * 0.18, Color("11242c"))
			canvas.draw_line(shelter_center - Vector2(icon_size * 0.11, 0), shelter_center + Vector2(icon_size * 0.11, 0), Color("d9fbff"), 1.0)
			canvas.draw_line(shelter_center - Vector2(0, icon_size * 0.11), shelter_center + Vector2(0, icon_size * 0.11), Color("d9fbff"), 1.0)
		elif kind == BUILD_HEAVY_DOORWAY:
			var door_rect := Rect2(icon_position + Vector2(icon_size * 0.18, 0), Vector2(icon_size * 0.64, icon_size))
			canvas.draw_rect(door_rect, Color("24445a") if usable else Color("363435"))
			canvas.draw_rect(door_rect, Color("8eeaff") if usable else Color("8d6967"), false, 1.0)
			canvas.draw_line(door_rect.get_center() - Vector2(0, icon_size * 0.28), door_rect.get_center() + Vector2(0, icon_size * 0.28), Color("d9fbff"), 1.0)
		elif texture != null:
			canvas.draw_texture_rect(texture, Rect2(icon_position, Vector2.ONE * icon_size), false, Color.WHITE if usable else Color(0.45, 0.48, 0.5, 0.8))
		if selected:
			var title_color := Color("d9fbff") if usable else Color("ff9c8f")
			canvas.draw_string(font, rect.position + Vector2(42, 17), host._build_name(kind), HORIZONTAL_ALIGNMENT_LEFT, 73, 8, title_color)
			var amount_text := "$%d" % (25 if kind == BUILD_BARRICADE else 60) if kind in [BUILD_BARRICADE, BUILD_SENTRY] else ("KIT %d" % amount if amount >= 0 else "READY")
			canvas.draw_string(font, rect.position + Vector2(42, 31), "%s  //  %s" % [_build_role_label(kind), amount_text], HORIZONTAL_ALIGNMENT_LEFT, 73, 7, Color("82b7c2") if usable else Color("b96f67"))
		else:
			canvas.draw_string(font, rect.position + Vector2(4, 30), "Q" if slot_index == 0 else "E", HORIZONTAL_ALIGNMENT_LEFT, 12, 7, Color("6d9da8"))
	canvas.draw_string(font, Vector2(250, 274), "BUILD KIT // Q/E CYCLE // CLICK DEPLOY", HORIZONTAL_ALIGNMENT_LEFT, 120, 6, Color("8fb7c0"))

