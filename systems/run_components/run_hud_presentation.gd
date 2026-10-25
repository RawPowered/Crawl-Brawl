## Crawl Brawl hud presentation component - Phase 1 monolith extraction
## Authoritative gameplay/save state remains on CrawlBrawlRun and is proxied here during migration.
extends RefCounted

var host

func _init(run_host) -> void:
	host = run_host

## Dependency-closed compile-time constant mirror from CrawlBrawlRun.
const WorldGridScript := preload("res://systems/world_grid.gd")

const BaseNetworkScript := preload("res://systems/base_network.gd")

const RealmVisualStyleScript := preload("res://systems/realm_visual_style.gd")

const DisplaySettingsScript := preload("res://systems/display_settings.gd")

const SettlementProgressionScript := preload("res://systems/settlement_progression.gd")

const VIEW_SIZE := Vector2(640, 360)

const BUILD_SENTRY := 1

const BUILD_LAND_MINE := 5

const BUILD_ROCKET_TURRET := 6

const BUILD_LASER_TURRET := 7

const BUILD_CHEST_SMALL := 9

const BUILD_CHEST_MEDIUM := 10

const BUILD_CHEST_LARGE := 11

const BUILD_FOUNDRY := 13

const BUILD_PERSONAL_BASE := 14

const BUILD_TORCH := 15

const WEAPON_SHOTGUN := 1

const WEAPON_LASER := 2

const WEAPON_SMG := 3

const WEAPON_RAILGUN := 4

const WEAPON_FLAMETHROWER := 5

const TORCH_LIGHT_POOL_BUDGET := 16

const TORCH_VISION_RADII: Array[float] = [0.0, 46.0, 68.0, 92.0]

const TORCH_DURABILITY: Array[float] = [0.0, 60.0, 140.0, 260.0]

const FLAMETHROWER_FUEL_CAP := 180

const APEX_COMPONENTS: Array[String] = ["ALPHA NEURAL CORE", "BROOD ENGINE", "CHITIN FORGE", "PHASE GLAND", "QUEEN COMMAND MATRIX"]

const VIS_DIRTY_HUD := 16

const USE_IMPORTED_HUD_SKINS := true

const HUD_CHROME_TINT := Color(0.58, 1.0, 0.98)

## Mutable run-state proxies. Ownership remains on CrawlBrawlRun in Phase 1.
var _camera_stable_frames:
	get:
		return host._camera_stable_frames
	set(value):
		host._camera_stable_frames = value

var _terrain_draw_stream_regions:
	get:
		return host._terrain_draw_stream_regions
	set(value):
		host._terrain_draw_stream_regions = value

var aim_direction:
	get:
		return host.aim_direction
	set(value):
		host.aim_direction = value

var apex_phase:
	get:
		return host.apex_phase
	set(value):
		host.apex_phase = value

var base_network:
	get:
		return host.base_network
	set(value):
		host.base_network = value

var beta_teaser_active:
	get:
		return host.beta_teaser_active
	set(value):
		host.beta_teaser_active = value

var boss_components_deposited:
	get:
		return host.boss_components_deposited
	set(value):
		host.boss_components_deposited = value

var breached:
	get:
		return host.breached
	set(value):
		host.breached = value

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

var bullets:
	get:
		return host.bullets
	set(value):
		host.bullets = value

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

var discovery_alert:
	get:
		return host.discovery_alert
	set(value):
		host.discovery_alert = value

var discovery_alert_time:
	get:
		return host.discovery_alert_time
	set(value):
		host.discovery_alert_time = value

var expedition_xp:
	get:
		return host.expedition_xp
	set(value):
		host.expedition_xp = value

var fire_patches:
	get:
		return host.fire_patches
	set(value):
		host.fire_patches = value

var first_mine_earned:
	get:
		return host.first_mine_earned
	set(value):
		host.first_mine_earned = value

var flame_fuel:
	get:
		return host.flame_fuel
	set(value):
		host.flame_fuel = value

var grid:
	get:
		return host.grid
	set(value):
		host.grid = value

var hive_awareness:
	get:
		return host.hive_awareness
	set(value):
		host.hive_awareness = value

var hud_base_attack_flash:
	get:
		return host.hud_base_attack_flash
	set(value):
		host.hud_base_attack_flash = value

var hud_breather_pulse:
	get:
		return host.hud_breather_pulse
	set(value):
		host.hud_breather_pulse = value

var hud_breather_ratio:
	get:
		return host.hud_breather_ratio
	set(value):
		host.hud_breather_ratio = value

var hud_comms_active:
	get:
		return host.hud_comms_active
	set(value):
		host.hud_comms_active = value

var hud_comms_display_text:
	get:
		return host.hud_comms_display_text
	set(value):
		host.hud_comms_display_text = value

var hud_comms_glyph_spin:
	get:
		return host.hud_comms_glyph_spin
	set(value):
		host.hud_comms_glyph_spin = value

var hud_comms_last_posted_text:
	get:
		return host.hud_comms_last_posted_text
	set(value):
		host.hud_comms_last_posted_text = value

var hud_comms_last_severity:
	get:
		return host.hud_comms_last_severity
	set(value):
		host.hud_comms_last_severity = value

var hud_comms_queue:
	get:
		return host.hud_comms_queue
	set(value):
		host.hud_comms_queue = value

var hud_comms_secondary:
	get:
		return host.hud_comms_secondary
	set(value):
		host.hud_comms_secondary = value

var hud_comms_secondary_alpha:
	get:
		return host.hud_comms_secondary_alpha
	set(value):
		host.hud_comms_secondary_alpha = value

var hud_comms_transition:
	get:
		return host.hud_comms_transition
	set(value):
		host.hud_comms_transition = value

var hud_context_idle_blink:
	get:
		return host.hud_context_idle_blink
	set(value):
		host.hud_context_idle_blink = value

var hud_energy_display:
	get:
		return host.hud_energy_display
	set(value):
		host.hud_energy_display = value

var hud_energy_low_flash:
	get:
		return host.hud_energy_low_flash
	set(value):
		host.hud_energy_low_flash = value

var hud_kill_streak:
	get:
		return host.hud_kill_streak
	set(value):
		host.hud_kill_streak = value

var hud_kill_streak_flash:
	get:
		return host.hud_kill_streak_flash
	set(value):
		host.hud_kill_streak_flash = value

var hud_kill_streak_timer:
	get:
		return host.hud_kill_streak_timer
	set(value):
		host.hud_kill_streak_timer = value

var hud_last_bases_under_attack:
	get:
		return host.hud_last_bases_under_attack
	set(value):
		host.hud_last_bases_under_attack = value

var hud_last_breather:
	get:
		return host.hud_last_breather
	set(value):
		host.hud_last_breather = value

var hud_last_pack_used:
	get:
		return host.hud_last_pack_used
	set(value):
		host.hud_last_pack_used = value

var hud_last_scrap:
	get:
		return host.hud_last_scrap
	set(value):
		host.hud_last_scrap = value

var hud_last_wave_active:
	get:
		return host.hud_last_wave_active
	set(value):
		host.hud_last_wave_active = value

var hud_level_up_flash:
	get:
		return host.hud_level_up_flash
	set(value):
		host.hud_level_up_flash = value

var hud_minimap_bloom:
	get:
		return host.hud_minimap_bloom
	set(value):
		host.hud_minimap_bloom = value

var hud_minimap_sweep:
	get:
		return host.hud_minimap_sweep
	set(value):
		host.hud_minimap_sweep = value

var hud_near_core_sp_glow:
	get:
		return host.hud_near_core_sp_glow
	set(value):
		host.hud_near_core_sp_glow = value

var hud_objective_pulse:
	get:
		return host.hud_objective_pulse
	set(value):
		host.hud_objective_pulse = value

var hud_pack_flash:
	get:
		return host.hud_pack_flash
	set(value):
		host.hud_pack_flash = value

var hud_scrap_display:
	get:
		return host.hud_scrap_display
	set(value):
		host.hud_scrap_display = value

var hud_scrap_tick:
	get:
		return host.hud_scrap_tick
	set(value):
		host.hud_scrap_tick = value

var hud_sp_pulse:
	get:
		return host.hud_sp_pulse
	set(value):
		host.hud_sp_pulse = value

var hud_suit_damage_flash:
	get:
		return host.hud_suit_damage_flash
	set(value):
		host.hud_suit_damage_flash = value

var hud_suit_display:
	get:
		return host.hud_suit_display
	set(value):
		host.hud_suit_display = value

var hud_suit_heal_flash:
	get:
		return host.hud_suit_heal_flash
	set(value):
		host.hud_suit_heal_flash = value

var hud_wave_flash:
	get:
		return host.hud_wave_flash
	set(value):
		host.hud_wave_flash = value

var hud_weapon_flash:
	get:
		return host.hud_weapon_flash
	set(value):
		host.hud_weapon_flash = value

var hud_weapon_last:
	get:
		return host.hud_weapon_last
	set(value):
		host.hud_weapon_last = value

var hud_xp_flash:
	get:
		return host.hud_xp_flash
	set(value):
		host.hud_xp_flash = value

var hud_xp_pip_ratio:
	get:
		return host.hud_xp_pip_ratio
	set(value):
		host.hud_xp_pip_ratio = value

var lantern_upgrade_target_cell:
	get:
		return host.lantern_upgrade_target_cell
	set(value):
		host.lantern_upgrade_target_cell = value

var laser_energy:
	get:
		return host.laser_energy
	set(value):
		host.laser_energy = value

var magazine:
	get:
		return host.magazine
	set(value):
		host.magazine = value

var material_economy:
	get:
		return host.material_economy
	set(value):
		host.material_economy = value

var mecha_level:
	get:
		return host.mecha_level
	set(value):
		host.mecha_level = value

var muzzle_flash:
	get:
		return host.muzzle_flash
	set(value):
		host.muzzle_flash = value

var operator_loadout:
	get:
		return host.operator_loadout
	set(value):
		host.operator_loadout = value

var player_health:
	get:
		return host.player_health
	set(value):
		host.player_health = value

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

var railgun_magazine:
	get:
		return host.railgun_magazine
	set(value):
		host.railgun_magazine = value

var railgun_reserve:
	get:
		return host.railgun_reserve
	set(value):
		host.railgun_reserve = value

var reserve_ammo:
	get:
		return host.reserve_ammo
	set(value):
		host.reserve_ammo = value

var runtime_assets_valid:
	get:
		return host.runtime_assets_valid
	set(value):
		host.runtime_assets_valid = value

var scrap:
	get:
		return host.scrap
	set(value):
		host.scrap = value

var shotgun_magazine:
	get:
		return host.shotgun_magazine
	set(value):
		host.shotgun_magazine = value

var shotgun_reserve:
	get:
		return host.shotgun_reserve
	set(value):
		host.shotgun_reserve = value

var skill_points:
	get:
		return host.skill_points
	set(value):
		host.skill_points = value

var sleeping:
	get:
		return host.sleeping
	set(value):
		host.sleeping = value

var smg_magazine:
	get:
		return host.smg_magazine
	set(value):
		host.smg_magazine = value

var smg_reserve:
	get:
		return host.smg_reserve
	set(value):
		host.smg_reserve = value

var sprint_energy:
	get:
		return host.sprint_energy
	set(value):
		host.sprint_energy = value

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

var surface_portal_cell:
	get:
		return host.surface_portal_cell
	set(value):
		host.surface_portal_cell = value

var turret_selection_active:
	get:
		return host.turret_selection_active
	set(value):
		host.turret_selection_active = value

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

var wave_active:
	get:
		return host.wave_active
	set(value):
		host.wave_active = value

func _sync_hud_motion_displays() -> void:
	hud_suit_display = player_health
	hud_energy_display = sprint_energy
	hud_scrap_display = float(scrap)
	hud_last_scrap = scrap
	hud_last_pack_used = host._backpack_used()
	hud_weapon_last = current_weapon
	var threshold := maxi(1, host._expedition_xp_threshold())
	hud_xp_pip_ratio = float(expedition_xp) / float(threshold)

func _comms_alert_priority(text: String) -> int:
	var alert_upper := text.to_upper()
	if "UNDER ATTACK" in alert_upper or "THREAT" in alert_upper or "AWAKENED" in alert_upper or "INTERCEPT" in alert_upper:
		return 3
	if "ROUTE" in alert_upper or "SURGE" in alert_upper or "BREACH" in alert_upper or "NEST" in alert_upper or "HOSTILE" in alert_upper:
		return 2
	if "LEVEL UP" in alert_upper or "COMPLETE" in alert_upper or "SURVEY" in alert_upper or "ONLINE" in alert_upper:
		return 1
	return 0

func _comms_state_from_text(text: String) -> Dictionary:
	var alert_upper := text.to_upper()
	for failure_word: String in ["FULL", "INSUFFICIENT", "DISABLED", "LOCKED", "THREAT", "AWAKENED"]:
		if failure_word in alert_upper:
			return {"text": text, "severity": "threat", "color": Color("ef8068")}
	for success_word: String in ["ONLINE", "COMPLETE", "CLEARED", "RESTORED", "REACTIVATED", "DEPLOYED", "LEVEL UP"]:
		if success_word in alert_upper:
			return {"text": text, "severity": "success", "color": Color("65df92")}
	return {"text": text, "severity": "info", "color": RealmVisualStyleScript.CYAN}

func _push_comms_alert(text: String, duration: float) -> void:
	if text.is_empty() or duration <= 0.0:
		return
	var priority := _comms_alert_priority(text)
	var entry := {"text": text, "time": duration, "priority": priority}
	if hud_comms_active.is_empty() or priority >= int(hud_comms_active.get("priority", -1)):
		if not hud_comms_active.is_empty() and float(hud_comms_active.get("time", 0.0)) > 0.35:
			hud_comms_queue.append(hud_comms_active.duplicate())
			hud_comms_secondary = hud_comms_active.duplicate()
			hud_comms_secondary_alpha = 0.55
		hud_comms_active = entry
		if text != hud_comms_display_text:
			hud_comms_transition = 0.33
			hud_comms_display_text = text
	else:
		hud_comms_queue.append(entry)

func _pop_comms_alert() -> Dictionary:
	if hud_comms_queue.is_empty():
		return {}
	var next: Dictionary = hud_comms_queue.pop_front()
	hud_comms_transition = 0.33
	hud_comms_display_text = str(next.get("text", ""))
	return next

func _update_hud_comms(delta: float) -> void:
	if discovery_alert_time > 0.0 and not discovery_alert.is_empty() and discovery_alert != hud_comms_last_posted_text:
		_push_comms_alert(discovery_alert, discovery_alert_time)
		hud_comms_last_posted_text = discovery_alert
	if discovery_alert_time <= 0.0 and hud_comms_last_posted_text == discovery_alert:
		hud_comms_last_posted_text = ""
	if not hud_comms_active.is_empty():
		hud_comms_active["time"] = maxf(0.0, float(hud_comms_active.get("time", 0.0)) - delta)
		if float(hud_comms_active.get("time", 0.0)) <= 0.0:
			if not hud_comms_queue.is_empty():
				hud_comms_secondary = hud_comms_active.duplicate()
				hud_comms_secondary_alpha = 0.5
			hud_comms_active = _pop_comms_alert()
	hud_comms_transition = maxf(0.0, hud_comms_transition - delta)
	hud_comms_secondary_alpha = maxf(0.0, hud_comms_secondary_alpha - delta * 1.8)
	if hud_comms_secondary_alpha <= 0.0:
		hud_comms_secondary = {}
	hud_objective_pulse = maxf(0.0, hud_objective_pulse - delta * 2.8)
	hud_wave_flash = maxf(0.0, hud_wave_flash - delta * 2.5)
	hud_breather_pulse = maxf(0.0, hud_breather_pulse - delta * 1.2)
	hud_xp_flash = maxf(0.0, hud_xp_flash - delta * 3.0)
	hud_minimap_bloom = maxf(0.0, hud_minimap_bloom - delta * 1.5)
	hud_minimap_sweep = fmod(hud_minimap_sweep + delta * 0.25, 1.0)
	var threshold := maxi(1, host._expedition_xp_threshold())
	hud_xp_pip_ratio = lerpf(hud_xp_pip_ratio, float(expedition_xp) / float(threshold), delta * 10.0)
	for base_id: String in hud_base_attack_flash.keys():
		hud_base_attack_flash[base_id] = maxf(0.0, float(hud_base_attack_flash[base_id]) - delta * 3.0)
		if float(hud_base_attack_flash[base_id]) <= 0.0:
			hud_base_attack_flash.erase(base_id)
	var nearby_base_id: String = host._nearby_base_id()
	var near_active_core = not nearby_base_id.is_empty() and base_network.get_status(nearby_base_id) == BaseNetworkScript.STATUS_ACTIVE
	hud_near_core_sp_glow = lerpf(hud_near_core_sp_glow, 1.0 if near_active_core and skill_points > 0 else 0.0, delta * 6.0)
	hud_context_idle_blink = fmod(hud_context_idle_blink + delta, 2.4)
	var bases_under_attack = host._bases_under_attack_count()
	if bases_under_attack > hud_last_bases_under_attack:
		for base_id: String in base_network.active_ids():
			if host._base_is_under_attack(base_id):
				hud_base_attack_flash[base_id] = 0.55
	hud_last_bases_under_attack = bases_under_attack
	if wave_active and not hud_last_wave_active: # encounter delivery edge
		hud_wave_flash = 0.45
		hud_objective_pulse = 0.4
	hud_last_wave_active = wave_active
	# Open-world pressure is action-driven. Cooldowns still pace mechanics, but
	# they are no longer presented as the primary objective loop.
	hud_breather_ratio = 0.0
	hud_last_breather = false
	hud_kill_streak_timer = maxf(0.0, hud_kill_streak_timer - delta)
	if hud_kill_streak_timer <= 0.0:
		hud_kill_streak = 0
	hud_kill_streak_flash = maxf(0.0, hud_kill_streak_flash - delta * 2.5)
	hud_comms_glyph_spin = maxf(0.0, hud_comms_glyph_spin - delta * 2.5)
	if (
		hud_suit_damage_flash > 0.0
		or hud_energy_low_flash > 0.0
		or hud_kill_streak_flash > 0.0
		or hud_wave_flash > 0.0
		or hud_objective_pulse > 0.0
		or absf(hud_suit_display - player_health) > 0.05
	):
		host._mark_visual_dirty(VIS_DIRTY_HUD)

func _register_hud_kill_streak(from_sentry: bool) -> void:
	if from_sentry:
		hud_kill_streak = 0
		hud_kill_streak_timer = 0.0
		return
	if hud_kill_streak_timer > 0.0:
		hud_kill_streak += 1
	else:
		hud_kill_streak = 1
	hud_kill_streak_timer = 2.4
	if hud_kill_streak >= 2:
		hud_kill_streak_flash = 0.55

func _active_comms_alert_text() -> String:
	if not hud_comms_active.is_empty() and float(hud_comms_active.get("time", 0.0)) > 0.0:
		return str(hud_comms_active.get("text", ""))
	if discovery_alert_time > 0.0:
		return discovery_alert
	return ""

func _update_hud_motion(delta: float) -> void:
	var suit_target = player_health
	if hud_suit_display > suit_target + 0.05:
		hud_suit_damage_flash = maxf(hud_suit_damage_flash, 0.22)
	elif suit_target > hud_suit_display + 0.05:
		hud_suit_heal_flash = maxf(hud_suit_heal_flash, 0.28)
	hud_suit_display = lerpf(hud_suit_display, suit_target, delta * 14.0)
	var energy_target = sprint_energy
	var prev_energy_ratio := clampf(hud_energy_display / 100.0, 0.0, 1.0)
	if energy_target < hud_energy_display - 0.75 and sprinting:
		hud_energy_low_flash = maxf(hud_energy_low_flash, 0.18)
	elif energy_target > hud_energy_display + 0.75 and prev_energy_ratio < 0.95:
		hud_energy_low_flash = maxf(hud_energy_low_flash, 0.12)
	var next_energy_ratio := clampf(energy_target / 100.0, 0.0, 1.0)
	if next_energy_ratio <= 0.28 and prev_energy_ratio > 0.28:
		hud_energy_low_flash = maxf(hud_energy_low_flash, 0.24)
	hud_energy_display = lerpf(hud_energy_display, energy_target, delta * 14.0)
	if scrap > hud_last_scrap or scrap < hud_last_scrap:
		hud_scrap_tick = 0.4
	hud_last_scrap = scrap
	hud_scrap_display = float(scrap)
	var pack_used = host._backpack_used()
	if host._backpack_free() <= 0 and pack_used >= hud_last_pack_used:
		hud_pack_flash = 0.35
	hud_last_pack_used = pack_used
	if current_weapon != hud_weapon_last:
		hud_weapon_flash = 0.35
		hud_weapon_last = current_weapon
	hud_suit_damage_flash = maxf(0.0, hud_suit_damage_flash - delta * 3.5)
	hud_suit_heal_flash = maxf(0.0, hud_suit_heal_flash - delta * 3.0)
	hud_energy_low_flash = maxf(0.0, hud_energy_low_flash - delta * 3.2)
	hud_scrap_tick = maxf(0.0, hud_scrap_tick - delta * 3.0)
	hud_pack_flash = maxf(0.0, hud_pack_flash - delta * 4.0)
	hud_weapon_flash = maxf(0.0, hud_weapon_flash - delta * 4.0)
	hud_level_up_flash = maxf(0.0, hud_level_up_flash - delta * 1.65)
	hud_sp_pulse = maxf(0.0, hud_sp_pulse - delta * 0.85)
	_update_hud_comms(delta)

func _hud_panel_accent_alpha() -> float:
	return 0.55 + sin(Time.get_ticks_msec() * 0.0025) * 0.45

func _hud_panel_texture_id(panel: Rect2) -> String:
	if panel == RealmVisualStyleScript.HUD_LEFT_PANEL:
		return "hud_panel_wide_teal"
	if panel == RealmVisualStyleScript.HUD_RIGHT_PANEL:
		return "hud_panel_wide_cyan"
	if panel == RealmVisualStyleScript.HUD_CONTEXT_PANEL:
		return "hud_panel_cyan"
	return "hud_display_panel"

func _draw_hud_panel(canvas: CanvasItem, panel: Rect2, accent: Color = RealmVisualStyleScript.CYAN, pulse: bool = true) -> void:
	if not USE_IMPORTED_HUD_SKINS or not host._draw_ui_nine_patch(canvas, _hud_panel_texture_id(panel), panel, 8.0, HUD_CHROME_TINT):
		canvas.draw_rect(panel, RealmVisualStyleScript.PANEL_BG)
		canvas.draw_rect(panel, RealmVisualStyleScript.PANEL_BORDER, false, 1.0)
	var accent_alpha := _hud_panel_accent_alpha() if pulse else 1.0
	canvas.draw_rect(Rect2(panel.position, Vector2(panel.size.x, 2)), Color(accent, accent_alpha))
	canvas.draw_rect(Rect2(panel.position, Vector2(3, panel.size.y)), Color(accent, accent_alpha * 0.55))

func _draw_hud(canvas: CanvasItem) -> void:
	var font: Font = ThemeDB.fallback_font
	var hud_primary := DisplaySettingsScript.font_hud_primary()
	var hud_secondary := DisplaySettingsScript.font_hud_secondary()
	var hud_tertiary := DisplaySettingsScript.font_hud_tertiary()
	var hud_comms := DisplaySettingsScript.font_hud_comms()
	if not runtime_assets_valid:
		canvas.draw_rect(Rect2(8, 8, 624, 18), Color(0.45, 0.08, 0.08, 0.88))
		canvas.draw_string(font, Vector2(12, 10), "ASSET FAULT // CHECK OUTPUT LOG", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("ffd6d0"))
	var left_panel := RealmVisualStyleScript.HUD_LEFT_PANEL
	var right_panel := RealmVisualStyleScript.HUD_RIGHT_PANEL
	_draw_hud_panel(canvas, left_panel)
	_draw_hud_panel(canvas, right_panel)
	if hud_level_up_flash > 0.0:
		var sweep_t = 1.0 - (hud_level_up_flash / 0.65)
		var sweep_width := left_panel.size.x + right_panel.size.x + 8.0
		var sweep_x = left_panel.position.x + sweep_width * sweep_t
		canvas.draw_rect(Rect2(sweep_x - 20.0, left_panel.position.y, 24.0, 2.0), Color("f0d47b", hud_level_up_flash / 0.65))
	var left_origin := left_panel.position + Vector2(7, 2)
	var scrap_color := Color("9deeff")
	if hud_scrap_tick > 0.0:
		scrap_color = Color("dff8fb", 0.82 + hud_scrap_tick * 0.18)
	var scrap_show := clampi(int(round(hud_scrap_display)), 0, 99999)
	canvas.draw_string(font, left_origin + Vector2(0, 14), "$%05d" % scrap_show, HORIZONTAL_ALIGNMENT_LEFT, 68, hud_primary, scrap_color)
	if skill_points > 0:
		var sp_alpha = 0.72 + sin(Time.get_ticks_msec() * 0.008) * 0.28 * hud_sp_pulse if hud_sp_pulse > 0.01 else 0.88
		if hud_near_core_sp_glow > 0.05:
			sp_alpha = minf(1.0, sp_alpha + hud_near_core_sp_glow * 0.12)
			canvas.draw_rect(Rect2(left_origin.x + 70, left_origin.y + 3, 46, 14), Color("f0d47b", hud_near_core_sp_glow * 0.18))
		canvas.draw_string(font, left_origin + Vector2(72, 14), "SP %02d" % skill_points, HORIZONTAL_ALIGNMENT_LEFT, 44, hud_secondary, Color("f0d47b", sp_alpha))
	var pack_color := Color("70d99c") if host._backpack_free() > 0 else Color("ef8b72")
	if hud_pack_flash > 0.0:
		pack_color = Color("ef675f", 0.72 + hud_pack_flash * 0.28)
	canvas.draw_string(font, left_origin + Vector2(0, 28), "PACK %03d/%03d [I]  //  RAW %02d" % [host._backpack_used(), host._backpack_capacity(), material_economy.raw_total()], HORIZONTAL_ALIGNMENT_LEFT, RealmVisualStyleScript.HUD_PACK_LINE_WIDTH, hud_tertiary, pack_color)
	var xp_bar := Rect2(left_origin.x, left_panel.position.y + left_panel.size.y - 4, 72, 3)
	var pip_color := Color("8eeaff")
	if hud_xp_flash > 0.0:
		pip_color = Color("dff8fb", 0.85 + hud_xp_flash * 0.15)
	host._draw_hud_meter_bar(canvas, xp_bar, hud_xp_pip_ratio, pip_color, Color.TRANSPARENT, 0.0, "hud_bar_cyan")

	var active_base_ids: Array[String] = base_network.active_ids()
	var bases_under_attack: int = 0
	for base_id: String in active_base_ids:
		if host._enemies_near_base(base_id, 96.0):
			bases_under_attack += 1
	var ammo_text := "PISTOL %02d / %03d" % [magazine, reserve_ammo]
	if current_weapon == WEAPON_SHOTGUN:
		ammo_text = "SHOTGUN %02d / %03d" % [shotgun_magazine, shotgun_reserve]
	elif current_weapon == WEAPON_LASER:
		ammo_text = "LASER %03d%%" % ceili(laser_energy)
	elif current_weapon == WEAPON_SMG:
		ammo_text = "SMG %02d / %03d" % [smg_magazine, smg_reserve]
	elif current_weapon == WEAPON_RAILGUN:
		ammo_text = "RAIL %02d / %03d" % [railgun_magazine, railgun_reserve]
	elif current_weapon == WEAPON_FLAMETHROWER:
		ammo_text = "FLAME %03d / %03d" % [flame_fuel, FLAMETHROWER_FUEL_CAP]
	var right_origin := right_panel.position + Vector2(7, 2)
	var bar_width := right_panel.size.x - 58
	var suit_ratio := clampf(hud_suit_display / 100.0, 0.0, 1.0)
	if suit_ratio <= 0.25:
		var warn_color := Color("ef675f") if suit_ratio <= 0.12 else Color("f0ad57")
		canvas.draw_rect(right_panel, Color(warn_color, 0.55), false, 1.0)
	canvas.draw_string(font, right_origin + Vector2(0, 14), "SUIT", HORIZONTAL_ALIGNMENT_LEFT, 28, hud_tertiary, Color("9deeff"))
	var suit_bar := Rect2(right_origin.x + 30, right_origin.y + 6, bar_width, 8)
	var suit_fill := Color("65df92") if suit_ratio > 0.35 else Color("ef675f")
	var suit_texture := "hud_bar_green" if suit_ratio > 0.35 else "hud_bar_amber"
	host._draw_hud_meter_bar(canvas, suit_bar, suit_ratio, suit_fill, Color.TRANSPARENT, 0.0, suit_texture)
	if hud_suit_damage_flash > 0.0:
		canvas.draw_rect(suit_bar, Color("ef675f", hud_suit_damage_flash * 0.42), false, 1.0)
	if hud_suit_heal_flash > 0.0:
		canvas.draw_rect(suit_bar, Color("65df92", hud_suit_heal_flash * 0.34), false, 1.0)
	canvas.draw_string(font, right_origin + Vector2(bar_width + 32, 14), "%03d%%" % ceili(player_health), HORIZONTAL_ALIGNMENT_RIGHT, 28, hud_tertiary, Color("c6f6ff"))
	var energy_ratio := clampf(hud_energy_display / 100.0, 0.0, 1.0)
	var energy_color := Color("62e7c3") if energy_ratio > 0.28 else Color("f0ad57")
	canvas.draw_string(font, right_origin + Vector2(0, 28), "NRG", HORIZONTAL_ALIGNMENT_LEFT, 22, hud_tertiary, Color("78dff5"))
	var energy_bar := Rect2(right_origin.x + 30, right_origin.y + 20, bar_width, 8)
	host._draw_hud_meter_bar(canvas, energy_bar, energy_ratio, energy_color, Color("f0ad57"), hud_energy_low_flash * 0.38, "hud_bar_cyan")
	canvas.draw_string(font, right_origin + Vector2(bar_width + 32, 28), "%03d%%" % ceili(sprint_energy), HORIZONTAL_ALIGNMENT_RIGHT, 28, hud_tertiary, Color("b6fff0"))
	if sprinting:
		canvas.draw_rect(Rect2(right_origin.x + 30, right_origin.y + 21, bar_width, 6), Color("b6fff0"), false, 1.0)
	canvas.draw_string(font, right_origin + Vector2(0, 42), ammo_text, HORIZONTAL_ALIGNMENT_LEFT, right_panel.size.x - 12, hud_secondary, Color("f2e3bc"))
	host._draw_base_network_cards(canvas)

	var hunter_count: int = host._active_turret_hunter_count()
	var objective_state := _hud_objective_state(bases_under_attack, hunter_count)
	var objective_panel := RealmVisualStyleScript.HUD_OBJECTIVE_PANEL
	var objective_color: Color = objective_state["color"]
	_draw_hud_panel(canvas, objective_panel, objective_color)
	canvas.draw_rect(objective_panel, Color(objective_color, 0.58), false, 1.0)
	if hud_wave_flash > 0.0 and str(objective_state["severity"]) == "threat":
		canvas.draw_rect(objective_panel, Color(RealmVisualStyleScript.AMBER, hud_wave_flash * 0.35), false, 1.0)
	if hud_breather_pulse > 0.0 and str(objective_state["severity"]) == "success":
		canvas.draw_rect(objective_panel, Color("65df92", sin(hud_breather_pulse * TAU) * 0.12 + 0.12), false, 1.0)
	if hud_objective_pulse > 0.0:
		canvas.draw_rect(objective_panel, Color(RealmVisualStyleScript.CYAN, hud_objective_pulse * 0.32), false, 1.0)
	var objective_glyph := "warning" if str(objective_state["severity"]) in ["threat", "objective"] else "core"
	if str(objective_state["severity"]) != hud_comms_last_severity:
		hud_comms_glyph_spin = 0.25
		hud_comms_last_severity = str(objective_state["severity"])
	_draw_hud_state_glyph(canvas, objective_panel.position + Vector2(10, 12), objective_glyph, objective_color, hud_comms_glyph_spin)
	var objective_text := str(objective_state["text"])
	var objective_text_pos := objective_panel.position + Vector2(20, 16)
	var objective_text_color := objective_color.lightened(0.28)
	if hud_comms_transition > 0.0:
		var transition_alpha = 1.0 - (hud_comms_transition / 0.33) * 0.55
		canvas.draw_string(font, objective_text_pos + Vector2(hud_comms_transition * 24.0, 0), objective_text, HORIZONTAL_ALIGNMENT_CENTER, objective_panel.size.x - 28, hud_secondary, Color(objective_text_color, transition_alpha))
	else:
		canvas.draw_string(font, objective_text_pos, objective_text, HORIZONTAL_ALIGNMENT_CENTER, objective_panel.size.x - 28, hud_secondary, objective_text_color)
	var comms_text := _active_comms_alert_text()
	if not comms_text.is_empty() and comms_text != objective_text:
		var comms_state := _comms_state_from_text(comms_text)
		canvas.draw_string(font, objective_panel.position + Vector2(20, 24), comms_text, HORIZONTAL_ALIGNMENT_CENTER, objective_panel.size.x - 28, hud_comms, Color(comms_state["color"], 0.88))
	elif hud_comms_secondary_alpha > 0.0 and not hud_comms_secondary.is_empty():
		canvas.draw_string(font, objective_panel.position + Vector2(20, 24), str(hud_comms_secondary.get("text", "")), HORIZONTAL_ALIGNMENT_CENTER, objective_panel.size.x - 28, hud_comms, Color(RealmVisualStyleScript.CYAN, hud_comms_secondary_alpha))
	var interaction_state := _hud_interaction_state()
	var context_panel := RealmVisualStyleScript.HUD_CONTEXT_PANEL
	var interaction_color: Color = interaction_state["color"]
	if interaction_state["glyph"] == "pack":
		interaction_color = Color(interaction_color, 0.55 + sin(hud_context_idle_blink * TAU / 2.4) * 0.45)
	_draw_hud_panel(canvas, context_panel, interaction_color)
	canvas.draw_rect(context_panel, Color(interaction_color, 0.66), false, 1.0)
	_draw_hud_state_glyph(canvas, context_panel.position + Vector2(10, 12), str(interaction_state["glyph"]), interaction_color)
	canvas.draw_string(font, context_panel.position + Vector2(18, 17), str(interaction_state["text"]), HORIZONTAL_ALIGNMENT_CENTER, context_panel.size.x - 23, hud_tertiary, interaction_color.lightened(0.22))

	host._draw_minimap(canvas)
	host._draw_hotbar(canvas)
	host._draw_base_alert_indicators(canvas)
	if hud_kill_streak >= 2 and hud_kill_streak_flash > 0.0:
		var aim = aim_direction.normalized() if aim_direction.length_squared() > 0.01 else Vector2.RIGHT
		var streak_anchor = player_position - host._effective_camera_center() + VIEW_SIZE * 0.5 + aim * 22.0
		canvas.draw_string(font, streak_anchor + Vector2(8, -8), "×%d" % hud_kill_streak, HORIZONTAL_ALIGNMENT_LEFT, 28, 11, Color("ffd36b", hud_kill_streak_flash))
	if beta_teaser_active:
		canvas.draw_rect(Rect2(72, 92, 496, 176), Color(0.008, 0.012, 0.03, 0.96))
		canvas.draw_rect(Rect2(72, 92, 496, 176), Color("8eeaff"), false, 2.0)
		canvas.draw_string(font, Vector2(102, 130), "THE SURFACE // BETA FRONTIER", HORIZONTAL_ALIGNMENT_CENTER, 436, 16, Color("aeefff"))
		canvas.draw_string(font, Vector2(102, 171), "Still gotta make this. You might be the best ever at this game!", HORIZONTAL_ALIGNMENT_CENTER, 436, 11, Color("f4f0dd"))
		canvas.draw_string(font, Vector2(102, 195), "I wonder how I will have to challenge you next!", HORIZONTAL_ALIGNMENT_CENTER, 436, 11, Color("f4f0dd"))
		canvas.draw_string(font, Vector2(102, 238), "F / CLICK // RETURN TO THE DEEP", HORIZONTAL_ALIGNMENT_CENTER, 436, 8, Color("819da8"))

func _hud_objective_state(bases_under_attack: int, hunter_count: int) -> Dictionary:
	if turret_selection_active:
		return {"text": "SELECT TURRET // CLICK OR Q/E + F // ESC CANCEL", "severity": "action", "color": RealmVisualStyleScript.CYAN}
	if bases_under_attack > 0:
		return {"text": "NETWORK ALERT // %d BASE%s UNDER ATTACK" % [bases_under_attack, "" if bases_under_attack == 1 else "S"], "severity": "threat", "color": Color("ef675f")}
	if breached and not host._opening_contact_complete():
		return {"text": "SURVIVE TUNNEL CONTACT // HOLD THE LANDING POCKET", "severity": "threat", "color": Color("ef8068")}
	if breached and not bool(host.merchant_invited):
		var field_lanterns: int = host._torch_deployed_count()
		if field_lanterns < SettlementProgressionScript.REQUIRED_FIELD_LANTERNS:
			return {"text": "STABILIZE POCKET // FIELD LANTERNS %d/%d" % [field_lanterns, SettlementProgressionScript.REQUIRED_FIELD_LANTERNS], "severity": "objective", "color": RealmVisualStyleScript.AMBER}
		return {"text": "COMMAND CORE // INVITE VOLUNTEER MERCHANT", "severity": "objective", "color": RealmVisualStyleScript.CYAN}
	if bool(host.merchant_invited) and host._merchant_store_index() < 0:
		return {"text": "PLACE MERCHANT STORE // FOUND THE FIRST SETTLEMENT", "severity": "objective", "color": RealmVisualStyleScript.CYAN}
	if apex_phase and boss_components_deposited.size() < APEX_COMPONENTS.size():
		return {"text": "FINAL FIVE // COMPONENTS SECURED %d/5" % boss_components_deposited.size(), "severity": "threat", "color": Color("d87cff")}
	if mecha_level > 0:
		if mecha_level < 3:
			return {"text": "MECHA SPIDERS MK%d // UPGRADE AT COMMAND CORE" % mecha_level, "severity": "success", "color": Color("72e8ff")}
		return {"text": "MECHA MK3 ONLINE // SURFACE EXCAVATION TECH STILL LOCKED", "severity": "success", "color": Color("72e8ff")}
	var carrier_count = host._active_brood_carrier_count()
	if carrier_count > 0:
		return {"text": "BROOD CARRIER // INTERCEPT BEFORE NESTING", "severity": "threat", "color": Color("ef8068")}
	var incubating_nests := 0
	var aggressive_nests := 0
	for nest in brood_nests:
		if nest.maturity < 1.0:
			incubating_nests += 1
		if nest.aggressive:
			aggressive_nests += 1
	if aggressive_nests > 0:
		return {"text": "BROOD BASE AGGRO // %d HIVE%s ACTIVE // THREAT MK%d" % [aggressive_nests, "" if aggressive_nests == 1 else "S", brood_escalation + 1], "severity": "threat", "color": Color("ef6b4d")}
	if incubating_nests > 0:
		return {"text": "NEST INCUBATING // %d SITE%s // HUNT NOW" % [incubating_nests, "" if incubating_nests == 1 else "S"], "severity": "objective", "color": RealmVisualStyleScript.AMBER}
	var activation_id: String = base_network.activation_base_id
	if not activation_id.is_empty():
		var activation_record: Dictionary = base_network.get_base(activation_id)
		return {"text": "ACTIVATION // %s // %02d SEC" % [host._base_short_name(activation_id), ceili(float(activation_record.get("activation_remaining", 0.0)))], "severity": "objective", "color": RealmVisualStyleScript.AMBER}
	if hunter_count > 0:
		return {"text": "EQUIPMENT THREAT // %d TURRET HUNTER%s" % [hunter_count, "" if hunter_count == 1 else "S"], "severity": "threat", "color": Color("ef675f")}
	if not first_mine_earned:
		return {"text": "MINE A WALL // EARN SCRAP TO EXPAND", "severity": "objective", "color": RealmVisualStyleScript.AMBER}
	if breached and not wave_active:
		if hive_awareness.encounter_pending:
			return {"text": "SETTLEMENT TRACKED // PREPARE BASE NETWORK", "severity": "objective", "color": RealmVisualStyleScript.AMBER}
		return {"text": "EXPLORE // ESTABLISH AND PROTECT THE SETTLEMENT", "severity": "success", "color": Color("65df92")}
	if wave_active:
		return {"text": "HUNTING PARTY ACTIVE // DEFEND BASE NETWORK", "severity": "threat", "color": Color("ef8068")}
	if discovery_alert_time > 0.0:
		var comms_text := _active_comms_alert_text()
		if not comms_text.is_empty():
			return _comms_state_from_text(comms_text)
	return {"text": "EXPAND THE REALM // HOLD THE BASE NETWORK", "severity": "objective", "color": RealmVisualStyleScript.AMBER}

func _hud_interaction_state() -> Dictionary:
	var nearby_doorway_index: int = host._nearby_doorway()
	if nearby_doorway_index >= 0 and not using_core_base and not using_foundry:
		var nearby_doorway = structures[nearby_doorway_index]
		var door_state: String = "OPEN" if nearby_doorway.is_open else "CLOSED"
		return {"text": "CLICK/F  DOOR // %s" % door_state, "glyph": "warning", "color": RealmVisualStyleScript.CYAN}
	if host._nearby_merchant_store() >= 0 and not using_core_base and not using_foundry:
		return {"text": "CLICK/F  ENTER MERCHANT STORE", "glyph": "warning", "color": RealmVisualStyleScript.CYAN}
	if host._nearby_foundry() >= 0 and not using_core_base and not using_foundry:
		return {"text": "CLICK  FOUNDRY", "glyph": "foundry", "color": RealmVisualStyleScript.CYAN}
	var nearby_base_id: String = host._nearby_base_id()
	if not nearby_base_id.is_empty() and not using_core_base and not using_foundry:
		var nearby_status: String = base_network.get_status(nearby_base_id)
		if nearby_status == BaseNetworkScript.STATUS_ACTIVE:
			return {"text": "CLICK  CORE", "glyph": "core", "color": RealmVisualStyleScript.CYAN}
		if nearby_status == BaseNetworkScript.STATUS_DISABLED:
			return {"text": "CLICK  RESTART $70", "glyph": "warning", "color": RealmVisualStyleScript.AMBER}
		return {"text": "CLICK  ACTIVATE $1000", "glyph": "warning", "color": RealmVisualStyleScript.AMBER}
	if host._nearby_chest() >= 0 and using_chest_index < 0:
		return {"text": "CLICK  VAULT", "glyph": "vault", "color": RealmVisualStyleScript.CYAN}
	if host._nearby_personal_base() >= 0 and not sleeping:
		return {"text": "F  FIELD HUT // HEAL + SAVE", "glyph": "core", "color": Color("65df92")}
	var nearby_torch_index = host._nearby_torch()
	if nearby_torch_index >= 0:
		var nearby_torch = structures[nearby_torch_index]
		if nearby_torch.cell == lantern_upgrade_target_cell:
			return {"text": "F  APPLY LANTERN MK%d" % (nearby_torch.level + 1), "glyph": "warning", "color": host._torch_light_color(nearby_torch)}
		if nearby_torch.level < TORCH_DURABILITY.size() - 1:
			return {"text": "TORCH MK%d  //  FOUNDRY CALIBRATION" % nearby_torch.level, "glyph": "warning", "color": Color("ffae4f")}
	var build_n = operator_loadout.build_slot_count() if operator_loadout else 5
	return {"text": "TAB/SCROLL GUN // 1-%d BUILD // I PACK" % build_n, "glyph": "pack", "color": Color("8eeaff")}

func _draw_hud_state_glyph(canvas: CanvasItem, center: Vector2, glyph: String, color: Color, spin: float = 0.0) -> void:
	var glyph_texture_id = host._hud_glyph_texture_id(glyph)
	if USE_IMPORTED_HUD_SKINS and not glyph_texture_id.is_empty():
		var icon_size := Vector2(14, 14)
		if spin != 0.0:
			canvas.draw_set_transform(center, spin * PI * 0.5, Vector2.ONE)
			if host._draw_ui_texture_rect(canvas, glyph_texture_id, Rect2(-icon_size * 0.5, icon_size), color):
				canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				return
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		elif host._draw_ui_texture_rect(canvas, glyph_texture_id, Rect2(center - icon_size * 0.5, icon_size), color):
			return
	var spin_angle := spin * PI * 0.5
	match glyph:
		"core":
			canvas.draw_rect(Rect2(center - Vector2(4, 4), Vector2(8, 8)), Color("102b33"))
			canvas.draw_rect(Rect2(center - Vector2(4, 4), Vector2(8, 8)), color, false, 1.0)
			canvas.draw_circle(center, 2.0, color)
		"foundry":
			canvas.draw_rect(Rect2(center - Vector2(4, 3), Vector2(8, 7)), Color("172c31"))
			canvas.draw_rect(Rect2(center - Vector2(4, 3), Vector2(8, 7)), color, false, 1.0)
			canvas.draw_line(center + Vector2(-2, -5), center + Vector2(-2, -3), color, 1.0)
			canvas.draw_line(center + Vector2(2, -5), center + Vector2(2, -3), color, 1.0)
		"vault":
			canvas.draw_rect(Rect2(center - Vector2(5, 3), Vector2(10, 7)), Color("182b30"))
			canvas.draw_rect(Rect2(center - Vector2(5, 3), Vector2(10, 7)), color, false, 1.0)
			canvas.draw_circle(center, 1.0, color)
		"warning":
			var warning_points := PackedVector2Array([center + Vector2(0, -5), center + Vector2(5, 4), center + Vector2(-5, 4)])
			if spin_angle != 0.0:
				for point_index in range(warning_points.size()):
					warning_points[point_index] = center + (warning_points[point_index] - center).rotated(spin_angle)
			canvas.draw_colored_polygon(warning_points, Color(color, 0.2))
			canvas.draw_polyline(PackedVector2Array([warning_points[0], warning_points[1], warning_points[2], warning_points[0]]), color, 1.0)
			canvas.draw_line(center + Vector2(0, -2), center + Vector2(0, 1), color, 1.0)
			canvas.draw_circle(center + Vector2(0, 3), 0.7, color)
		_:
			canvas.draw_rect(Rect2(center - Vector2(4, 4), Vector2(8, 8)), color, false, 1.0)
			canvas.draw_line(center - Vector2(2, 1), center + Vector2(2, 1), color, 1.0)

func _draw_atmosphere(canvas: CanvasItem) -> void:
	# Hybrid pixel lighting: a restrained local biome grade plus stepped light pools.
	var visible_rect := Rect2(host._effective_camera_center() - VIEW_SIZE * 0.5, VIEW_SIZE)
	var cull_rect = host._lighting_cull_rect()
	canvas.draw_rect(visible_rect, Color(0.005, 0.015, 0.025, 0.21))
	var player_material_id = host._visual_material_id(grid.world_to_cell(player_position))
	canvas.draw_rect(visible_rect, Color(RealmVisualStyleScript.ambient_grade_color(player_material_id), 0.032))
	for base_id: String in base_network.bases.keys():
		var record: Dictionary = base_network.get_base(base_id)
		if not bool(record.get("revealed", false)):
			continue
		var base_position = grid.cell_to_world(record["cell"])
		if not host._lighting_rect_has_point(base_position, cull_rect):
			continue
		var light_color: Color = Color("55dff5") if str(record["status"]) == BaseNetworkScript.STATUS_ACTIVE else Color("ffae4f")
		_draw_light_pool(canvas, base_position, 62.0 if base_id == BaseNetworkScript.COMMAND_ID else 44.0, light_color, 0.19)
	_draw_light_pool(canvas, player_position, 36.0, Color("8cecff"), 0.075)
	_draw_ambient_motes(canvas, visible_rect)
	if host._should_draw_heavy_lighting():
		_draw_region_prop_lights(canvas, visible_rect)
	for lane_index in range(mini(grid.active_lane_count, grid.spawn_cells.size())):
		var lane_position = grid.cell_to_world(grid.spawn_cells[lane_index])
		if not host._lighting_rect_has_point(lane_position, cull_rect):
			continue
		_draw_light_pool(canvas, lane_position, 25.0, Color("8fe742"), 0.09)
	for center_value: Variant in grid.revealed_discoveries.keys():
		var center: Vector2i = center_value
		var discovery_position = grid.cell_to_world(center)
		if not host._lighting_rect_has_point(discovery_position, cull_rect):
			continue
		var discovery_kind: String = str(grid.revealed_discoveries[center])
		var color: Color = Color("d55bf0") if discovery_kind == "guardian" else Color("8ee648")
		_draw_light_pool(canvas, discovery_position, 27.0, color, 0.075)
	## Budget full torch light pools to nearest on-screen torches.
	var torch_candidates: Array = []
	for structure in structures:
		if not host._lighting_rect_has_point(structure.position, cull_rect):
			continue
		if structure.kind in [BUILD_SENTRY, BUILD_LASER_TURRET]:
			_draw_light_pool(canvas, structure.position, 20.0 if structure.kind == BUILD_LASER_TURRET else 18.0, Color("69e4ff"), 0.07 if structure.kind == BUILD_LASER_TURRET else 0.055)
		elif structure.kind in [BUILD_ROCKET_TURRET, BUILD_LAND_MINE]:
			_draw_light_pool(canvas, structure.position, 18.0, Color("ff9b45"), 0.05)
		elif structure.kind == BUILD_FOUNDRY:
			_draw_light_pool(canvas, structure.position + Vector2(8, 8), 31.0, Color("ffad5a") if structure.powered else Color("8e6750"), 0.11 if structure.powered else 0.04)
		elif structure.kind == BUILD_PERSONAL_BASE:
			_draw_light_pool(canvas, structure.position + Vector2(16, 8), 28.0, Color("69e4ff") if structure.powered else Color("62808a"), 0.09 if structure.powered else 0.035)
		elif structure.kind == BUILD_TORCH:
			torch_candidates.append(structure)
		elif structure.kind in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE] and structure.powered:
			_draw_light_pool(canvas, structure.position, 14.0, Color("55dff5"), 0.035)
	if torch_candidates.size() > TORCH_LIGHT_POOL_BUDGET:
		torch_candidates.sort_custom(func(a, b) -> bool:
			return a.position.distance_squared_to(player_position) < b.position.distance_squared_to(player_position)
		)
		torch_candidates = torch_candidates.slice(0, TORCH_LIGHT_POOL_BUDGET)
	for torch in torch_candidates:
		_draw_light_pool(canvas, torch.position, TORCH_VISION_RADII[clampi(torch.level, 1, TORCH_VISION_RADII.size() - 1)], host._torch_light_color(torch), 0.11)
	if muzzle_flash > 0.0:
		_draw_light_pool(canvas, player_position + aim_direction * 13.0, 27.0, Color("ffd36b"), 0.18)
	for patch in fire_patches:
		if not host._lighting_rect_has_point(patch.position, cull_rect):
			continue
		_draw_light_pool(canvas, patch.position, patch.radius * 1.35, Color("ff7e32"), 0.10)
	for bullet in bullets:
		if bullet.enemy_round and host._lighting_rect_has_point(bullet.position, cull_rect):
			_draw_light_pool(canvas, bullet.position, 13.0, bullet.color, 0.055)
	host._draw_camera_vignette(canvas, visible_rect)
	if damage_flash > 0.0:
		var flash_alpha := clampf(damage_flash / 0.22, 0.0, 1.0) * 0.16
		canvas.draw_rect(visible_rect, Color(0.9, 0.05, 0.03, flash_alpha))

func _draw_light_pool(canvas: CanvasItem, position: Vector2, radius: float, color: Color, strength: float) -> void:
	# Four hard-edged rings read as pixel lighting and avoid airbrushed gradients.
	canvas.draw_circle(position, radius, Color(color, strength * 0.24))
	canvas.draw_circle(position, radius * 0.72, Color(color, strength * 0.28))
	canvas.draw_circle(position, radius * 0.46, Color(color, strength * 0.34))
	canvas.draw_circle(position, radius * 0.2, Color(color, strength * 0.42))

func _draw_region_prop_lights(canvas: CanvasItem, visible_rect: Rect2) -> void:
	var stream_regions: Dictionary = _terrain_draw_stream_regions
	if stream_regions.is_empty():
		stream_regions = host._active_stream_regions()
	var cull_rect := visible_rect.grow(24.0)
	for region_value: Variant in stream_regions.keys():
		var region: Vector2i = region_value
		var region_bounds := Rect2(
			Vector2(region * WorldGridScript.REGION_SIZE * grid.tile_size),
			Vector2(WorldGridScript.REGION_SIZE * grid.tile_size, WorldGridScript.REGION_SIZE * grid.tile_size)
		)
		if not cull_rect.intersects(region_bounds):
			continue
		# Lighting is a presentation pass and must never synthesize the expensive
		# decorative prop cache on demand. Full-quality terrain refinement populates
		# this cache while gameplay is frozen; active frames only consume what exists.
		var cached_props: Array = host.visual_prop_cache.get(region, [])
		for prop_value: Variant in cached_props:
			var prop: Dictionary = prop_value
			var lamp_position = grid.cell_to_world(prop["cell"]) + Vector2(prop.get("offset", Vector2.ZERO))
			if not visible_rect.grow(24.0).has_point(lamp_position):
				continue
			var material_id := int(prop.get("material_id", host._visual_material_id(prop["cell"])))
			var radius := 0.0
			var color := Color.WHITE
			var strength := 0.0
			match int(prop["kind"]):
				RealmVisualStyleScript.PROP_LAMP:
					radius = 30.0
					color = RealmVisualStyleScript.biome_light_color(material_id)
					strength = 0.11
				RealmVisualStyleScript.PROP_ACID:
					radius = 18.0
					color = RealmVisualStyleScript.ACID
					strength = 0.055
				RealmVisualStyleScript.PROP_EGGS:
					radius = 14.0
					color = Color("b8e85b")
					strength = 0.035
				RealmVisualStyleScript.PROP_CONDUIT:
					radius = 15.0
					color = RealmVisualStyleScript.biome_light_color(material_id)
					strength = 0.035
				RealmVisualStyleScript.PROP_CRYSTAL_SHARD:
					radius = 21.0
					color = RealmVisualStyleScript.biome_light_color(RealmVisualStyleScript.MATERIAL_CRYSTAL)
					strength = 0.065 if bool(prop.get("landmark", false)) else 0.04
				RealmVisualStyleScript.PROP_SULFUR_VENT:
					radius = 19.0
					color = RealmVisualStyleScript.biome_light_color(RealmVisualStyleScript.MATERIAL_SULFUR)
					strength = 0.06 if bool(prop.get("landmark", false)) else 0.035
				RealmVisualStyleScript.PROP_SLAG_HEAP:
					radius = 17.0
					color = RealmVisualStyleScript.biome_light_color(RealmVisualStyleScript.MATERIAL_FOUNDRY)
					strength = 0.045 if bool(prop.get("landmark", false)) else 0.025
				_:
					continue
			_draw_light_pool(canvas, lamp_position, radius, color, strength)

func _draw_structure_contact_shadows(canvas: CanvasItem) -> void:
	for structure in structures:
		if structure.kind == BUILD_LAND_MINE:
			continue
		var footprint := Vector2(structure.size) * float(grid.tile_size)
		var shadow_center = structure.position + (footprint - Vector2(grid.tile_size, grid.tile_size)) * 0.5 + Vector2(2, 4)
		var shadow_radius := maxf(6.0, maxf(footprint.x, footprint.y) * 0.42)
		canvas.draw_circle(shadow_center, shadow_radius, Color(0.0, 0.0, 0.0, 0.18))
		canvas.draw_circle(shadow_center + Vector2(0, 1), shadow_radius * 0.58, Color(0.0, 0.0, 0.0, 0.13))

func _draw_ambient_motes(canvas: CanvasItem, visible_rect: Rect2) -> void:
	if not player_moving and _camera_stable_frames >= 2:
		return
	# Deterministic biome motes add motion without allocating or simulating particles.
	var time := Time.get_ticks_msec() * 0.001
	const MOTE_SPACING := 64
	var start_x := floori(visible_rect.position.x / float(MOTE_SPACING)) * MOTE_SPACING
	var start_y := floori(visible_rect.position.y / float(MOTE_SPACING)) * MOTE_SPACING
	var end_x := ceili(visible_rect.end.x / float(MOTE_SPACING)) * MOTE_SPACING
	var end_y := ceili(visible_rect.end.y / float(MOTE_SPACING)) * MOTE_SPACING
	for y in range(start_y, end_y + 1, MOTE_SPACING):
		for x in range(start_x, end_x + 1, MOTE_SPACING):
			var sample_cell = grid.world_to_cell(Vector2(x + MOTE_SPACING * 0.5, y + MOTE_SPACING * 0.5))
			if not grid.in_bounds(sample_cell) or not grid.is_walkable(sample_cell):
				continue
			var material_id = host._visual_material_id(sample_cell)
			var lattice := Vector2i(floori(float(x) / MOTE_SPACING), floori(float(y) / MOTE_SPACING))
			var mote_hash := int(RealmVisualStyleScript.stable_cell_hash(grid.realm_seed, lattice, 1901 + material_id * 71))
			if posmod(mote_hash, 1000) >= RealmVisualStyleScript.mote_density(material_id):
				continue
			var seed := int(posmod(mote_hash, 17))
			var phase := time * (0.32 + float(seed) * 0.025) + float(seed * 11)
			var drift := Vector2(sin(phase) * 2.2, cos(phase * 0.71) * 3.0)
			if material_id in [RealmVisualStyleScript.MATERIAL_FOUNDRY, RealmVisualStyleScript.MATERIAL_SULFUR]:
				drift.y = -absf(drift.y) - fmod(time * (0.4 + seed * 0.02), 3.0)
			var position := Vector2(float(x + 5 + posmod(seed * 7, 29)), float(y + 6 + posmod(seed * 11, 27))) + drift
			var alpha := 0.028 + (sin(phase * 1.7) + 1.0) * 0.011
			canvas.draw_circle(
				position,
				0.65 + float(seed % 2) * 0.25,
				Color(RealmVisualStyleScript.mote_color(material_id), alpha)
			)

