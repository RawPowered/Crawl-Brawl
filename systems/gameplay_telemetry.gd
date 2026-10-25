class_name GameplayTelemetry
extends RefCounted

## Lightweight play-session counters for routing / siege pace.
## Enabled when CRAWL_BRAWL_TELEMETRY=1 or --crawl-telemetry is on the cmdline.

const ENV_ENABLE := "CRAWL_BRAWL_TELEMETRY"
const ENV_LOG_PATH := "CRAWL_BRAWL_TELEMETRY_LOG"
const FLAG_ARG := "--crawl-telemetry"
const DEFAULT_RELATIVE_LOG := "logs/gameplay_telemetry.ndjson"
const SUMMARY_RELATIVE_PATH := "diagnostics/LAST_SESSION.json"
const FLUSH_INTERVAL_SEC := 2.0

var enabled := false
var log_path := ""
var _elapsed := 0.0
var _buffer: PackedStringArray = []
var _session_started_msec := 0

var route_flow_ok := 0
var route_dead_end := 0
var route_greedy := 0
var route_no_flow := 0
var route_refresh_request := 0
var route_refresh_batch := 0
var route_stall_recover := 0
var route_foot_aim_blocked := 0
var route_local_build := 0
var route_local_reuse := 0
var route_flow_breach := 0
var route_flow_step_build := 0
var route_flow_step_reuse := 0
var enemies_peak := 0
var samples := 0
# Compact frame/chunk diagnostics are written outside logs so Launcher v3.2's
# source handoff can include one tiny last-session summary without shipping logs.
var frame_samples := 0
var frame_peak_ms := 0.0
var frame_over_25ms := 0
var frame_over_33ms := 0
var mining_frames := 0
var mining_frame_peak_ms := 0.0
var mining_frame_over_25ms := 0
var simulation_regions_peak := 0
var render_regions_peak := 0
var preload_pending_peak := 0
var stream_regions_generated := 0
var stream_mining_paused_frames := 0
var terrain_mutations := 0
var terrain_mutation_peak_us := 0
var mining_commits := 0
var mining_open_cell_peak_us := 0
var mining_commit_peak_us := 0
var enemy_update_samples := 0
var enemy_update_peak_us := 0
var enemy_update_over_4ms := 0
var streaming_update_samples := 0
var streaming_update_peak_us := 0
var streaming_update_over_4ms := 0
var ecology_update_samples := 0
var ecology_update_peak_us := 0
var ecology_update_over_2ms := 0
var terrain_draw_samples := 0
var terrain_draw_peak_us := 0
var terrain_draw_over_8ms := 0
var actor_draw_samples := 0
var actor_draw_peak_us := 0
var lighting_draw_samples := 0
var lighting_draw_peak_us := 0
var ecology_phase_peak_us: Dictionary = {}
var ecology_phase_over_2ms: Dictionary = {}
var pacing_awareness_points := 0
var pacing_awareness_tier := 0
var pacing_pressure := 0
var pacing_encounters := 0
var pacing_brood_nests := 0
var pacing_encounter_cooldown := 0.0
var pacing_awareness_tier_peak := 0
var pacing_pressure_peak := 0
var pacing_brood_nests_peak := 0
var _prev_flow_ok := 0
var _prev_greedy := 0
var _prev_dead_end := 0
var _prev_no_flow := 0
var _prev_stall_recover := 0
var _prev_foot_aim := 0
var _prev_local_build := 0
var _prev_local_reuse := 0
var _prev_flow_breach := 0
var _prev_flow_step_build := 0
var _prev_flow_step_reuse := 0


func configure_from_environment() -> void:
	var env_flag := OS.get_environment(ENV_ENABLE).strip_edges().to_lower()
	enabled = env_flag in ["1", "true", "yes", "on"]
	for arg: String in OS.get_cmdline_user_args():
		if arg == FLAG_ARG:
			enabled = true
	for arg: String in OS.get_cmdline_args():
		if arg == FLAG_ARG:
			enabled = true
	if not enabled:
		return
	log_path = OS.get_environment(ENV_LOG_PATH).strip_edges()
	if log_path.is_empty():
		log_path = ProjectSettings.globalize_path("res://%s" % DEFAULT_RELATIVE_LOG)
	_session_started_msec = Time.get_ticks_msec()
	_ensure_log_dir()
	_emit("session_start", {
		"log_path": log_path,
		"godot": Engine.get_version_info().get("string", ""),
	})
	flush(true)


func tick(delta: float, enemy_count: int = 0) -> void:
	# Backward-compatible telemetry facade retained for tests/tools.
	tick_runtime(delta, enemy_count)


func tick_runtime(
	delta: float,
	enemy_count: int = 0,
	mining_active: bool = false,
	simulation_regions: int = 0,
	render_regions: int = 0,
	preload_pending: int = 0
) -> void:
	if not enabled:
		return
	enemies_peak = maxi(enemies_peak, enemy_count)
	var frame_ms := delta * 1000.0
	frame_samples += 1
	frame_peak_ms = maxf(frame_peak_ms, frame_ms)
	if frame_ms >= 25.0:
		frame_over_25ms += 1
	if frame_ms >= 33.0:
		frame_over_33ms += 1
	if mining_active:
		mining_frames += 1
		mining_frame_peak_ms = maxf(mining_frame_peak_ms, frame_ms)
		if frame_ms >= 25.0:
			mining_frame_over_25ms += 1
	simulation_regions_peak = maxi(simulation_regions_peak, simulation_regions)
	render_regions_peak = maxi(render_regions_peak, render_regions)
	preload_pending_peak = maxi(preload_pending_peak, preload_pending)
	_elapsed += delta
	if _elapsed >= FLUSH_INTERVAL_SEC:
		_elapsed = 0.0
		_emit_snapshot()
		flush(false)


func note_enemy_update_cost(cost_us: int) -> void:
	if not enabled:
		return
	enemy_update_samples += 1
	enemy_update_peak_us = maxi(enemy_update_peak_us, maxi(0, cost_us))
	if cost_us >= 4000:
		enemy_update_over_4ms += 1


func note_streaming_update_cost(cost_us: int) -> void:
	if not enabled:
		return
	streaming_update_samples += 1
	streaming_update_peak_us = maxi(streaming_update_peak_us, maxi(0, cost_us))
	if cost_us >= 4000:
		streaming_update_over_4ms += 1


func note_ecology_update_cost(cost_us: int) -> void:
	if not enabled:
		return
	ecology_update_samples += 1
	ecology_update_peak_us = maxi(ecology_update_peak_us, maxi(0, cost_us))
	if cost_us >= 2000:
		ecology_update_over_2ms += 1


func note_ecology_phase_cost(phase: String, cost_us: int) -> void:
	if not enabled:
		return
	cost_us = maxi(0, cost_us)
	ecology_phase_peak_us[phase] = maxi(int(ecology_phase_peak_us.get(phase, 0)), cost_us)
	if cost_us >= 2000:
		ecology_phase_over_2ms[phase] = int(ecology_phase_over_2ms.get(phase, 0)) + 1


func note_pacing_state(awareness_points: int, awareness_tier: int, pressure: int, encounters: int, brood_nests: int, encounter_cooldown: float) -> void:
	if not enabled:
		return
	pacing_awareness_points = maxi(0, awareness_points)
	pacing_awareness_tier = maxi(0, awareness_tier)
	pacing_pressure = maxi(0, pressure)
	pacing_encounters = maxi(0, encounters)
	pacing_brood_nests = maxi(0, brood_nests)
	pacing_encounter_cooldown = maxf(0.0, encounter_cooldown)
	pacing_awareness_tier_peak = maxi(pacing_awareness_tier_peak, pacing_awareness_tier)
	pacing_pressure_peak = maxi(pacing_pressure_peak, pacing_pressure)
	pacing_brood_nests_peak = maxi(pacing_brood_nests_peak, pacing_brood_nests)


func note_draw_cost(kind: String, cost_us: int) -> void:
	if not enabled:
		return
	cost_us = maxi(0, cost_us)
	match kind:
		"terrain":
			terrain_draw_samples += 1
			terrain_draw_peak_us = maxi(terrain_draw_peak_us, cost_us)
			if cost_us >= 8000:
				terrain_draw_over_8ms += 1
		"actors":
			actor_draw_samples += 1
			actor_draw_peak_us = maxi(actor_draw_peak_us, cost_us)
		"lighting":
			lighting_draw_samples += 1
			lighting_draw_peak_us = maxi(lighting_draw_peak_us, cost_us)


func note_streaming_work(generated_regions: int, mining_paused: bool) -> void:
	if not enabled:
		return
	stream_regions_generated += maxi(0, generated_regions)
	if mining_paused:
		stream_mining_paused_frames += 1


func note_terrain_mutation(cost_us: int) -> void:
	if not enabled:
		return
	terrain_mutations += 1
	terrain_mutation_peak_us = maxi(terrain_mutation_peak_us, maxi(0, cost_us))


func note_mining_commit(open_cell_us: int, total_commit_us: int) -> void:
	if not enabled:
		return
	mining_commits += 1
	mining_open_cell_peak_us = maxi(mining_open_cell_peak_us, maxi(0, open_cell_us))
	mining_commit_peak_us = maxi(mining_commit_peak_us, maxi(0, total_commit_us))


func note_flow_ok() -> void:
	if enabled:
		route_flow_ok += 1


func note_dead_end() -> void:
	if enabled:
		route_dead_end += 1


func note_greedy() -> void:
	if enabled:
		route_greedy += 1


func note_no_flow() -> void:
	if enabled:
		route_no_flow += 1


func note_refresh_request() -> void:
	if enabled:
		route_refresh_request += 1


func note_refresh_batch(region_count: int) -> void:
	if not enabled:
		return
	route_refresh_batch += 1
	_emit("spider_flow_batch", {"regions": region_count})


func note_stall_recover() -> void:
	if enabled:
		route_stall_recover += 1


func note_foot_aim_blocked() -> void:
	if enabled:
		route_foot_aim_blocked += 1


func note_local_route_build() -> void:
	if enabled:
		route_local_build += 1


func note_local_route_reuse() -> void:
	if enabled:
		route_local_reuse += 1


func note_flow_breach() -> void:
	if enabled:
		route_flow_breach += 1


func note_flow_step_build() -> void:
	if enabled:
		route_flow_step_build += 1


func note_flow_step_reuse() -> void:
	if enabled:
		route_flow_step_reuse += 1


func shutdown() -> void:
	if not enabled:
		return
	_emit_snapshot()
	var uptime_ms := Time.get_ticks_msec() - _session_started_msec
	_emit("session_end", {
		"uptime_ms": uptime_ms,
	})
	flush(true)
	_write_last_session_summary(uptime_ms)


func _emit_snapshot() -> void:
	samples += 1
	var delta_flow := route_flow_ok - _prev_flow_ok
	var delta_greedy := route_greedy - _prev_greedy
	var delta_dead := route_dead_end - _prev_dead_end
	var delta_no_flow := route_no_flow - _prev_no_flow
	var delta_stall := route_stall_recover - _prev_stall_recover
	var delta_foot := route_foot_aim_blocked - _prev_foot_aim
	var delta_local_build := route_local_build - _prev_local_build
	var delta_local_reuse := route_local_reuse - _prev_local_reuse
	var delta_flow_breach := route_flow_breach - _prev_flow_breach
	var delta_flow_step_build := route_flow_step_build - _prev_flow_step_build
	var delta_flow_step_reuse := route_flow_step_reuse - _prev_flow_step_reuse
	# flow_ok, flow_breach and greedy are mutually exclusive movement modes.
	# dead_end/no_flow explain fallback cause and are not movement modes.
	var route_total := maxi(1, delta_flow + delta_flow_breach + delta_greedy)
	_emit("route_snapshot", {
		"sample": samples,
		"flow_ok": route_flow_ok,
		"dead_end": route_dead_end,
		"greedy": route_greedy,
		"no_flow": route_no_flow,
		"refresh_request": route_refresh_request,
		"refresh_batch": route_refresh_batch,
		"stall_recover": route_stall_recover,
		"foot_aim_blocked": route_foot_aim_blocked,
		"local_route_build": route_local_build,
		"local_route_reuse": route_local_reuse,
		"flow_breach": route_flow_breach,
		"flow_step_build": route_flow_step_build,
		"flow_step_reuse": route_flow_step_reuse,
		"enemies_peak": enemies_peak,
		"dt_flow_ok": delta_flow,
		"dt_greedy": delta_greedy,
		"dt_dead_end": delta_dead,
		"dt_no_flow": delta_no_flow,
		"dt_stall_recover": delta_stall,
		"dt_foot_aim_blocked": delta_foot,
		"dt_local_route_build": delta_local_build,
		"dt_local_route_reuse": delta_local_reuse,
		"dt_flow_breach": delta_flow_breach,
		"dt_flow_step_build": delta_flow_step_build,
		"dt_flow_step_reuse": delta_flow_step_reuse,
		"flow_share": snappedf(float(delta_flow + delta_flow_breach) / float(route_total), 0.001),
		"breach_share": snappedf(float(delta_flow_breach) / float(route_total), 0.001),
		"greedy_share": snappedf(float(delta_greedy) / float(route_total), 0.001),
		"frame_peak_ms": snappedf(frame_peak_ms, 0.01),
		"frame_over_25ms": frame_over_25ms,
		"mining_frame_peak_ms": snappedf(mining_frame_peak_ms, 0.01),
		"mining_frame_over_25ms": mining_frame_over_25ms,
		"simulation_regions_peak": simulation_regions_peak,
		"render_regions_peak": render_regions_peak,
		"preload_pending_peak": preload_pending_peak,
		"enemy_update_peak_us": enemy_update_peak_us,
		"enemy_update_over_4ms": enemy_update_over_4ms,
		"streaming_update_peak_us": streaming_update_peak_us,
		"streaming_update_over_4ms": streaming_update_over_4ms,
	})
	_prev_flow_ok = route_flow_ok
	_prev_greedy = route_greedy
	_prev_dead_end = route_dead_end
	_prev_no_flow = route_no_flow
	_prev_stall_recover = route_stall_recover
	_prev_foot_aim = route_foot_aim_blocked
	_prev_local_build = route_local_build
	_prev_local_reuse = route_local_reuse
	_prev_flow_breach = route_flow_breach
	_prev_flow_step_build = route_flow_step_build
	_prev_flow_step_reuse = route_flow_step_reuse


func _write_last_session_summary(uptime_ms: int) -> void:
	var summary_path := ProjectSettings.globalize_path("res://%s" % SUMMARY_RELATIVE_PATH)
	var dir_path := summary_path.get_base_dir()
	if not dir_path.is_empty():
		DirAccess.make_dir_recursive_absolute(dir_path)
	var summary := {
		"schema": 1,
		"generated_at_unix": Time.get_unix_time_from_system(),
		"godot": Engine.get_version_info().get("string", ""),
		"uptime_ms": uptime_ms,
		"frames": {
			"samples": frame_samples,
			"peak_ms": snappedf(frame_peak_ms, 0.01),
			"over_25ms": frame_over_25ms,
			"over_33ms": frame_over_33ms,
			"mining_samples": mining_frames,
			"mining_peak_ms": snappedf(mining_frame_peak_ms, 0.01),
			"mining_over_25ms": mining_frame_over_25ms,
		},
		"world_streaming": {
			"simulation_regions_peak": simulation_regions_peak,
			"render_regions_peak": render_regions_peak,
			"preload_pending_peak": preload_pending_peak,
			"regions_generated_during_session": stream_regions_generated,
			"mining_paused_stream_frames": stream_mining_paused_frames,
		},
		"runtime_phases": {
			"enemy_update_samples": enemy_update_samples,
			"enemy_update_peak_us": enemy_update_peak_us,
			"enemy_update_over_4ms": enemy_update_over_4ms,
			"streaming_update_samples": streaming_update_samples,
			"streaming_update_peak_us": streaming_update_peak_us,
			"streaming_update_over_4ms": streaming_update_over_4ms,
			"ecology_update_samples": ecology_update_samples,
			"ecology_update_peak_us": ecology_update_peak_us,
			"ecology_update_over_2ms": ecology_update_over_2ms,
			"ecology_phase_peak_us": ecology_phase_peak_us.duplicate(true),
			"ecology_phase_over_2ms": ecology_phase_over_2ms.duplicate(true),
			"terrain_draw_samples": terrain_draw_samples,
			"terrain_draw_peak_us": terrain_draw_peak_us,
			"terrain_draw_over_8ms": terrain_draw_over_8ms,
			"actor_draw_samples": actor_draw_samples,
			"actor_draw_peak_us": actor_draw_peak_us,
			"lighting_draw_samples": lighting_draw_samples,
			"lighting_draw_peak_us": lighting_draw_peak_us,
		},
		"pacing": {
			"awareness_points": pacing_awareness_points,
			"awareness_tier": pacing_awareness_tier,
			"awareness_tier_peak": pacing_awareness_tier_peak,
			"pressure": pacing_pressure,
			"pressure_peak": pacing_pressure_peak,
			"encounters": pacing_encounters,
			"brood_nests": pacing_brood_nests,
			"brood_nests_peak": pacing_brood_nests_peak,
			"encounter_cooldown_remaining": snappedf(pacing_encounter_cooldown, 0.01),
		},
		"terrain": {
			"mutations": terrain_mutations,
			"mutation_queue_peak_us": terrain_mutation_peak_us,
			"mining_commits": mining_commits,
			"open_cell_peak_us": mining_open_cell_peak_us,
			"mining_commit_peak_us": mining_commit_peak_us,
		},
		"routing": {
			"flow_ok": route_flow_ok,
			"dead_end": route_dead_end,
			"greedy": route_greedy,
			"no_flow": route_no_flow,
			"refresh_request": route_refresh_request,
			"refresh_batch": route_refresh_batch,
			"stall_recover": route_stall_recover,
			"foot_aim_blocked": route_foot_aim_blocked,
			"local_route_build": route_local_build,
			"local_route_reuse": route_local_reuse,
			"flow_breach": route_flow_breach,
			"flow_step_build": route_flow_step_build,
			"flow_step_reuse": route_flow_step_reuse,
			"enemies_peak": enemies_peak,
		},
	}
	var file := FileAccess.open(summary_path, FileAccess.WRITE)
	if file == null:
		push_warning("GameplayTelemetry could not write %s" % summary_path)
		return
	file.store_string(JSON.stringify(summary, "\t"))
	file.close()


func _emit(message: String, data: Dictionary = {}) -> void:
	var payload := {
		"ts_ms": Time.get_ticks_msec(),
		"message": message,
		"data": data,
	}
	_buffer.append(JSON.stringify(payload))


func _ensure_log_dir() -> void:
	var dir_path := log_path.get_base_dir()
	if dir_path.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(dir_path)


func flush(force: bool) -> void:
	if not enabled:
		return
	if _buffer.is_empty() and not force:
		return
	_ensure_log_dir()
	var file := FileAccess.open(log_path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(log_path, FileAccess.WRITE)
	else:
		file.seek_end()
	if file == null:
		push_warning("GameplayTelemetry could not open %s" % log_path)
		_buffer.clear()
		return
	for line: String in _buffer:
		file.store_line(line)
	file.close()
	_buffer.clear()
