class_name WorldGrid
extends RefCounted

signal terrain_cell_changed(cell: Vector2i)

const WorldAddressScript := preload("res://systems/world_address.gd")

const ROCK := 0
const FLOOR := 1
const BEDROCK := 2

const MINERAL_COPPER := "copper"
const MINERAL_SILVER := "silver"
const MINERAL_GOLD := "gold"
const MINERAL_CRYSTAL := "crystal"
const MINERAL_DIAMOND := "diamond"
const MINERAL_CACHE := "cache"
const MINERAL_GRANITE := "granite"
const MINERAL_BASALT := "basalt"
const MINERAL_QUARTZ := "quartz"
const MINERAL_IRON := "iron"
const MINERAL_TITANIUM := "titanium"
const MINERAL_SULFUR := "sulfur"
const MINERAL_COAL := "coal"
const REGION_SIZE := 24
const MAX_RENDER_REGIONS := 12
# Rendering and simulation are distinct tickets. The visible world stays small;
# one surrounding region ring remains simulation-active so mobs can approach
# smoothly without keeping the entire prepared horizon resident/ticking.
const SIMULATION_HALO_REGIONS := 1
const MAX_SIMULATION_REGIONS := 25
const FLOW_CORRIDOR_MAX_REGIONS := 48
const MAX_FLOW_REGIONS := 36
const MINING_FLOW_REGIONS := 12
# BV5.3: the prepare zone is a rolling generation horizon, not a permanently
# resident 1000x1000 block. Nine regions across leaves a two-region buffer
# around the 5x5 render window while keeping active terrain memory bounded.
const INITIAL_PREPARE_SIZE := REGION_SIZE * 9
const EXPANSION_EDGE_THRESHOLD := REGION_SIZE * 2
# Kept as a compatibility/public tuning constant; rolling horizons recenter
# instead of growing by this amount indefinitely.
const EXPANSION_STEP := REGION_SIZE * 4
const LEGACY_REALM_WIDTH := 192
const LEGACY_REALM_HEIGHT := 108
const PHASE_A_REALM_WIDTH := 384
const PHASE_A_REALM_HEIGHT := 216
const REALM_WIDTH := 512
const REALM_HEIGHT := 288
const REALM_TILE_SIZE := 16
const DISCOVERY_NEST_MIN_CORE_RATIO := 0.22
const DISCOVERY_GUARDIAN_MIN_CORE_RATIO := 0.14
const DISCOVERY_NEST_SPACING_RATIO := 0.14
const START_CHAMBER_INNER_RADIUS := 3
const START_CHAMBER_WALL_RADIUS := 4
const START_CHAMBER_RESERVE_RADIUS := 5
const INITIAL_HIVE_OFFSET := 28
const FIRST_BREACH_TUNNEL_LENGTH := 28
const SPAWN_FLANK_MIN_CELLS := 1.0
const SPAWN_FLANK_MAX_CELLS := 3.25
const SPAWN_REAR_MIN_CELLS := -0.75
const SPAWN_REAR_MAX_CELLS := 1.75
const BIOME_TUNNEL := 0
const BIOME_HIVE := 1
const BIOME_BUNKER := 2
const BIOME_CRYSTAL := 3
const BIOME_FOUNDRY := 4
const BIOME_SULFUR := 5
const BIOME_IRON := 6
const BIOME_NAMES: Array[String] = [
	"TUNNEL CRUST", "HIVE BAND", "BUNKER SHELL", "CRYSTAL CAVERN", "FOUNDRY DEPTHS", "SULFUR BOG", "IRON STRATA",
]
const DISCOVERY_RESOURCE_AREA_RATIO := 0.38
const BIOME_MACRO_SCALE := 4
const LAZY_TOPOLOGY_MIN_WIDTH := 448
const GENERATOR_VERSION := 2
const REGION_MIN_WALKABLE := 8
const REGION_MAX_FLOOR_RATIO := 0.45
const INFINITE_STREAMING := true

enum RegionReadiness {
	ABSENT,
	QUEUED,
	GENERATED,
	PREPARED,
	ACTIVE,
}

var width: int
var height: int
var tile_size: int
var cells := PackedInt32Array()
var core_cell := Vector2i(83, 27)
var spawn_cell := Vector2i(4, 27)
var spawn_cells: Array[Vector2i] = [Vector2i(4, 27)]
var lane_seals: Array[Vector2i] = [Vector2i(77, 27), Vector2i(77, 15), Vector2i(77, 39)]
var active_lane_count := 1
var tutorial_rock := Vector2i(77, 27)
var discovery_cells: Dictionary = {}
var revealed_discoveries: Dictionary = {}
var mineral_cells: Dictionary = {}
var mined_minerals: Dictionary = {}
var concealed_minerals: Dictionary = {}
var realm_seed := 0
var realm_title := "UNNAMED REALM"
var realm_traits: Array[String] = []
var frontier_sites: Dictionary = {}
var loaded_regions: Dictionary = {}
var visited_regions: Dictionary = {}
var populated_regions: Dictionary = {}
var region_biomes: Dictionary = {}
var cell_deltas: Dictionary = {}
var _generated_cells := PackedInt32Array()
var _track_cell_deltas := false
var _deferred_topology_branches: Array[Dictionary] = []
var _deferred_layout_specs: Array[Dictionary] = []
var _discovery_plan: Dictionary = {}
var _discovery_materialized: Dictionary = {}
var _mineral_remaining: Dictionary = {}
var _discovery_rng_seed := 0
var _region_cells: Dictionary = {}
var _region_generated: Dictionary = {}
var _topology_materialized_regions: Dictionary = {}
var _region_preload_queue: Array[Vector2i] = []
var _region_preload_seen: Dictionary = {}
var _region_preload_delta: Array[Vector2i] = []
var _stream_window_regions: Dictionary = {}
var _render_requested_regions: Dictionary = {}
var _simulation_requested_regions: Dictionary = {}
var _spawn_lane_corridors: Dictionary = {}
var _walkable_route_cache: Dictionary = {}
var _route_epoch: int = 0
var _region_route_epoch: Dictionary = {}
var _prepare_anchor := Vector2i.ZERO
var _prepared_cell_bounds := Rect2i()
var _prepare_zone_regions_cache: Array[Vector2i] = []


func _init(grid_width: int = 96, grid_height: int = 54, cell_size: int = 16) -> void:
	width = grid_width
	height = grid_height
	tile_size = cell_size
	_configure_landmarks()
	_reset_cell_storage()
	_build_expedition_layout()
	_set_default_frontier_sites()
	_seal_generated_cells()


func generate_realm(seed: int, difficulty_id: String, randomized_start: bool = true) -> void:
	_track_cell_deltas = false
	cell_deltas.clear()
	_deferred_topology_branches.clear()
	_deferred_layout_specs.clear()
	_topology_materialized_regions.clear()
	_region_route_epoch.clear()
	_route_epoch = 0
	_walkable_route_cache.clear()
	_clear_region_preload_queue()
	realm_seed = maxi(1, seed & 0x7fffffff)
	_configure_landmarks()
	_reset_cell_storage()
	_build_expedition_layout()
	var rng := RandomNumberGenerator.new()
	rng.seed = realm_seed
	_configure_realm_identity(rng, difficulty_id)
	if not uses_lazy_topology():
		_apply_seeded_variation(rng)
	_configure_seeded_frontier_sites(rng)
	if randomized_start:
		_configure_seeded_start_chamber(rng)
		# Re-queue bunker bootstrap specs using post-chamber lane_seals/core_cell.
		_refresh_deferred_layout_specs_after_chamber()
	elif uses_lazy_topology():
		_carve_rect(Rect2i(spawn_cell + Vector2i(-2, -2), Vector2i(5, 5)))
	loaded_regions.clear()
	visited_regions.clear()
	populated_regions.clear()
	_stream_window_regions.clear()
	_render_requested_regions.clear()
	_simulation_requested_regions.clear()
	_clear_region_preload_queue()
	region_biomes.clear()
	if _uses_authored_bedrock_rim():
		for x in range(width):
			set_cell(Vector2i(x, 0), BEDROCK)
			set_cell(Vector2i(x, height - 1), BEDROCK)
		for y in range(height):
			set_cell(Vector2i(0, y), BEDROCK)
			set_cell(Vector2i(width - 1, y), BEDROCK)
	_assign_realm_biomes(rng)
	_seal_generated_cells()
	if uses_lazy_topology():
		_materialize_frontier_entry_regions()
	configure_prepare_zone(core_cell)


func configure_prepare_zone(anchor_cell: Vector2i) -> void:
	_prepare_anchor = anchor_cell
	var half := INITIAL_PREPARE_SIZE / 2
	_prepared_cell_bounds = Rect2i(anchor_cell - Vector2i(half, half), Vector2i(INITIAL_PREPARE_SIZE, INITIAL_PREPARE_SIZE))
	_rebuild_prepare_zone_region_list()


func prepared_cell_bounds() -> Rect2i:
	return _prepared_cell_bounds


func prepare_zone_region_list() -> Array[Vector2i]:
	if _prepare_zone_regions_cache.is_empty():
		_rebuild_prepare_zone_region_list()
	return _prepare_zone_regions_cache


func _rebuild_prepare_zone_region_list() -> void:
	_prepare_zone_regions_cache = _regions_intersecting_cell_bounds(_prepared_cell_bounds)


func _regions_intersecting_cell_bounds(bounds: Rect2i) -> Array[Vector2i]:
	var regions: Array[Vector2i] = []
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		return regions
	var min_region := Vector2i(
		WorldAddressScript.floor_div(bounds.position.x, REGION_SIZE),
		WorldAddressScript.floor_div(bounds.position.y, REGION_SIZE)
	)
	var max_cell := bounds.position + bounds.size - Vector2i.ONE
	var max_region := Vector2i(
		WorldAddressScript.floor_div(max_cell.x, REGION_SIZE),
		WorldAddressScript.floor_div(max_cell.y, REGION_SIZE)
	)
	for region_y in range(mini(min_region.y, max_region.y), maxi(min_region.y, max_region.y) + 1):
		for region_x in range(mini(min_region.x, max_region.x), maxi(min_region.x, max_region.x) + 1):
			var region := Vector2i(region_x, region_y)
			if not _region_is_streamable(region):
				continue
			regions.append(region)
	regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		if left.x == right.x:
			return left.y < right.y
		return left.x < right.x
	)
	return regions


func _region_intersects_prepared_bounds(region: Vector2i) -> bool:
	return _prepared_cell_bounds.intersects(_region_bounds(region))


func activate_prepare_zone() -> int:
	var active := 0
	for region: Vector2i in prepare_zone_region_list():
		if uses_lazy_topology() and populated_regions.has(region) and _region_needs_topology_materialize(region):
			_materialize_topology_for_region(region)
		if not _region_is_prepared(region):
			continue
		active += 1
	return active


func compute_desired_render_regions(
	cell_bounds: Rect2i,
	center_cells: Array,
	radius: int,
	focus_cell: Vector2i
) -> Dictionary:
	var desired_regions: Dictionary = {}
	var margin_cells := REGION_SIZE
	var expanded := Rect2i(
		cell_bounds.position - Vector2i(margin_cells, margin_cells),
		cell_bounds.size + Vector2i(margin_cells * 2, margin_cells * 2)
	)
	for region: Vector2i in _regions_intersecting_cell_bounds(expanded):
		if _region_is_streamable(region):
			desired_regions[region] = true
	for center_value: Variant in center_cells:
		var window := _collect_region_window([center_value], radius)
		for region_value: Variant in window.keys():
			desired_regions[region_value] = true
	if desired_regions.size() <= MAX_RENDER_REGIONS:
		return desired_regions
	return _cap_render_regions(desired_regions, focus_cell, MAX_RENDER_REGIONS)


func _cap_render_regions(desired_regions: Dictionary, focus_cell: Vector2i, max_regions: int) -> Dictionary:
	var focus_region := region_for_cell(focus_cell)
	var ranked: Array[Dictionary] = []
	for region_value: Variant in desired_regions.keys():
		var region: Vector2i = region_value
		ranked.append({
			"region": region,
			"dist": float(region.distance_squared_to(focus_region)),
		})
	ranked.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return float(left.dist) < float(right.dist)
	)
	var capped: Dictionary = {}
	for index in range(mini(max_regions, ranked.size())):
		capped[ranked[index].region] = true
	return capped


func _simulation_regions_for_render(desired_regions: Dictionary, focus_cell: Vector2i) -> Dictionary:
	# Keep one generated ring alive outside the visible region set. This is the
	# equivalent of an entity/simulation distance: rendering can disappear first
	# while nearby mob/pathing state remains coherent for another chunk.
	var simulation_regions := expand_regions(desired_regions, SIMULATION_HALO_REGIONS)
	if simulation_regions.size() <= MAX_SIMULATION_REGIONS:
		return simulation_regions
	return _cap_render_regions(simulation_regions, focus_cell, MAX_SIMULATION_REGIONS)


func simulation_window_regions() -> Dictionary:
	return _simulation_requested_regions


func apply_render_window(desired_regions: Dictionary, focus_cell: Vector2i = Vector2i.ZERO) -> Dictionary:
	# The active-window caps are hard invariants, not caller conventions. A legacy
	# helper or resume path must never be able to leave dozens of old regions live.
	var bounded_render: Dictionary = desired_regions
	if bounded_render.size() > MAX_RENDER_REGIONS:
		bounded_render = _cap_render_regions(bounded_render, focus_cell, MAX_RENDER_REGIONS)
	else:
		bounded_render = bounded_render.duplicate()
	_render_requested_regions = bounded_render.duplicate()
	_simulation_requested_regions = _simulation_regions_for_render(bounded_render, focus_cell)
	var added: Array[Vector2i] = []
	var removed: Array[Vector2i] = []
	for region_value: Variant in _stream_window_regions.keys():
		var region: Vector2i = region_value
		if bounded_render.has(region):
			continue
		removed.append(region)
		_stream_window_regions.erase(region)
	# Keep the bounded rolling prepare horizon queued as low-priority generation
	# work while render/simulation tickets receive priority. This preserves real
	# chunk headroom without allowing stale requests outside the rolling horizon.
	var preload_keep: Dictionary = _simulation_requested_regions.duplicate()
	for prepared_region: Vector2i in prepare_zone_region_list():
		preload_keep[prepared_region] = true
	_prune_region_preload_queue(preload_keep)
	for region_value: Variant in bounded_render.keys():
		var region: Vector2i = region_value
		if _stream_window_regions.has(region):
			continue
		if _queue_render_region(region):
			added.append(region)
			visited_regions[region] = true
	for region_value: Variant in _simulation_requested_regions.keys():
		var region: Vector2i = region_value
		if _region_is_prepared(region):
			continue
		enqueue_region_preload(region)
	_sync_loaded_regions_to_window(_simulation_requested_regions)
	return {
		"added": added,
		"removed": removed,
	}


func _sync_loaded_regions_to_window(desired_regions: Dictionary) -> void:
	if INFINITE_STREAMING and uses_sparse_cells():
		var new_loaded: Dictionary = {}
		for region_value: Variant in desired_regions.keys():
			var region: Vector2i = region_value
			if _region_is_prepared(region):
				new_loaded[region] = true
		loaded_regions = new_loaded
		_evict_inactive_infinite_chunks(desired_regions)
		return
	for region_value: Variant in _stream_window_regions.keys():
		var region: Vector2i = region_value
		if _region_is_prepared(region):
			loaded_regions[region] = true
	for region_value: Variant in loaded_regions.keys():
		if not _stream_window_regions.has(region_value):
			loaded_regions.erase(region_value)


func activate_render_window(center_cells: Array, radius: int = 1, focus_cell: Vector2i = Vector2i.ZERO) -> int:
	var desired_regions := _collect_region_window(center_cells, radius)
	if focus_cell == Vector2i.ZERO and not center_cells.is_empty():
		focus_cell = center_cells[0]
	var diff := apply_render_window(desired_regions, focus_cell)
	return diff.added.size()


func activate_render_window_for_bounds(cell_bounds: Rect2i, margin_regions: int = 1, focus_cell: Vector2i = Vector2i.ZERO) -> int:
	var desired_regions: Dictionary = {}
	var margin_cells := margin_regions * REGION_SIZE
	var expanded := Rect2i(
		cell_bounds.position - Vector2i(margin_cells, margin_cells),
		cell_bounds.size + Vector2i(margin_cells * 2, margin_cells * 2)
	)
	for region: Vector2i in _regions_intersecting_cell_bounds(expanded):
		if _region_is_streamable(region):
			desired_regions[region] = true
	var diff := apply_render_window(desired_regions, focus_cell)
	return diff.added.size()


func _queue_render_region(region: Vector2i) -> bool:
	if not _region_is_streamable(region):
		return false
	if _stream_window_regions.has(region):
		return false
	if not _region_is_prepared(region):
		# Visible terrain always outranks background prepare-horizon generation.
		enqueue_region_preload(region, true)
		return false
	_stream_window_regions[region] = true
	if _region_is_prepared(region):
		loaded_regions[region] = true
	return true


func _activate_render_region(region: Vector2i) -> int:
	return 1 if _queue_render_region(region) else 0


func ensure_region_for_cell(cell: Vector2i, front: bool = false) -> void:
	var region := region_for_cell(cell)
	if not _region_is_streamable(region):
		return
	if _region_is_prepared(region):
		return
	enqueue_region_preload(region, front)


func try_expand_prepare_zone(player_cell: Vector2i) -> bool:
	# Minecraft-style rolling generation horizon: keep a bounded halo around the
	# player instead of growing one giant resident rectangle forever. Generated
	# regions remain deterministic and terrain edits live in cell_deltas, so old
	# chunks can hibernate and be reconstructed when revisited.
	var bounds := _prepared_cell_bounds
	if bounds.size == Vector2i.ZERO:
		configure_prepare_zone(player_cell)
		return true
	var left_gap := player_cell.x - bounds.position.x
	var top_gap := player_cell.y - bounds.position.y
	var right_gap := bounds.end.x - 1 - player_cell.x
	var bottom_gap := bounds.end.y - 1 - player_cell.y
	if mini(mini(left_gap, top_gap), mini(right_gap, bottom_gap)) > EXPANSION_EDGE_THRESHOLD:
		return false
	var previous: Dictionary = {}
	for region: Vector2i in _prepare_zone_regions_cache:
		previous[region] = true
	configure_prepare_zone(player_cell)
	for region: Vector2i in _prepare_zone_regions_cache:
		if previous.has(region) or _region_is_prepared(region):
			continue
		enqueue_region_preload(region)
	return true


func _configure_seeded_start_chamber(rng: RandomNumberGenerator) -> void:
	var candidate := Vector2i(width / 2, height / 2)
	for unused in range(96):
		var probe := Vector2i(
			rng.randi_range(START_CHAMBER_RESERVE_RADIUS + 8, width - START_CHAMBER_RESERVE_RADIUS - 9),
			rng.randi_range(START_CHAMBER_RESERVE_RADIUS + 8, height - START_CHAMBER_RESERVE_RADIUS - 9)
		)
		if _valid_start_chamber_center(probe):
			candidate = probe
			break
	core_cell = candidate
	_purge_deferred_specs_in_bounds(Rect2i(
		core_cell - Vector2i(START_CHAMBER_RESERVE_RADIUS, START_CHAMBER_RESERVE_RADIUS),
		Vector2i(START_CHAMBER_RESERVE_RADIUS * 2 + 1, START_CHAMBER_RESERVE_RADIUS * 2 + 1)
	))
	for y in range(-START_CHAMBER_RESERVE_RADIUS, START_CHAMBER_RESERVE_RADIUS + 1):
		for x in range(-START_CHAMBER_RESERVE_RADIUS, START_CHAMBER_RESERVE_RADIUS + 1):
			set_cell(core_cell + Vector2i(x, y), ROCK)
	_carve_rect(Rect2i(
		core_cell - Vector2i(START_CHAMBER_INNER_RADIUS, START_CHAMBER_INNER_RADIUS),
		Vector2i(START_CHAMBER_INNER_RADIUS * 2 + 1, START_CHAMBER_INNER_RADIUS * 2 + 1)
	))
	lane_seals = [
		core_cell + Vector2i.LEFT * START_CHAMBER_WALL_RADIUS,
		core_cell + Vector2i.RIGHT * START_CHAMBER_WALL_RADIUS,
		core_cell + Vector2i.UP * START_CHAMBER_WALL_RADIUS,
		core_cell + Vector2i.DOWN * START_CHAMBER_WALL_RADIUS,
	]
	var hive_direction := Vector2i.LEFT
	var primary_wall := core_cell + hive_direction * START_CHAMBER_WALL_RADIUS
	tutorial_rock = primary_wall
	spawn_cell = core_cell + hive_direction * (START_CHAMBER_WALL_RADIUS + _scaled_layout(INITIAL_HIVE_OFFSET))
	spawn_cell.x = clampi(spawn_cell.x, 3, width - 4)
	spawn_cell.y = clampi(spawn_cell.y, 3, height - 4)
	_carve_rect(Rect2i(spawn_cell + Vector2i(-2, -2), Vector2i(5, 5)))
	_carve_corridor(primary_wall + hive_direction, spawn_cell, 1)
	set_cell(primary_wall, ROCK)
	spawn_cells = [spawn_cell]
	active_lane_count = 1


func _valid_start_chamber_center(candidate: Vector2i) -> bool:
	for site_value: Variant in frontier_sites.values():
		var site: Vector2i = site_value
		if maxi(absi(candidate.x - site.x), absi(candidate.y - site.y)) < _scaled_layout(16):
			return false
	return true


func is_start_chamber_wall(cell: Vector2i) -> bool:
	var delta := cell - core_cell
	return maxi(absi(delta.x), absi(delta.y)) == START_CHAMBER_WALL_RADIUS


func is_start_chamber_reserved(cell: Vector2i) -> bool:
	var delta := cell - core_cell
	return maxi(absi(delta.x), absi(delta.y)) <= START_CHAMBER_RESERVE_RADIUS


func first_breach_direction(cell: Vector2i) -> Vector2i:
	if not is_start_chamber_wall(cell):
		return Vector2i.ZERO
	var delta := cell - core_cell
	if absi(delta.x) >= absi(delta.y):
		return Vector2i(1 if delta.x > 0 else -1, 0)
	return Vector2i(0, 1 if delta.y > 0 else -1)


func establish_first_breach(breach_cell: Vector2i) -> Vector2i:
	var direction := first_breach_direction(breach_cell)
	if direction == Vector2i.ZERO:
		return direction
	# Keep the hive route off the player's doorstep; the chosen wall still sets
	# the approach, but the actual swarm origin sits beyond a defensible tunnel.
	var tunnel_end := breach_cell + direction * _scaled_layout(FIRST_BREACH_TUNNEL_LENGTH)
	tunnel_end.x = clampi(tunnel_end.x, 2, width - 3)
	tunnel_end.y = clampi(tunnel_end.y, 2, height - 3)
	_carve_rect(Rect2i(tunnel_end + Vector2i(-2, -2), Vector2i(5, 5)))
	_carve_corridor(breach_cell + direction, tunnel_end, 1)
	spawn_cell = tunnel_end
	spawn_cells = [spawn_cell]
	active_lane_count = 1
	tutorial_rock = breach_cell
	_route_epoch += 1
	_walkable_route_cache.clear()
	for region_value: Variant in corridor_regions_between(spawn_cell, core_cell, 1).keys():
		var region: Vector2i = region_value
		if _topology_materialized_regions.has(region):
			_region_route_epoch.erase(region)
	return direction


func _set_default_frontier_sites() -> void:
	frontier_sites = {
		"crystal": Vector2i(49, 10),
		"foundry": Vector2i(59, height - 10),
		"containment": Vector2i(18, 10),
	}


func ensure_regions_around(cell: Vector2i, radius: int = 1) -> int:
	var center_region := region_for_cell(cell)
	if uses_sparse_cells() and INFINITE_STREAMING:
		# Preparation is not simulation ownership. Far nests/frontier helpers may ask
		# that nearby chunks exist, but only the bounded render/simulation window is
		# allowed to populate loaded_regions. This prevents background world systems
		# from silently growing the active entity-ticking set.
		var queued := 0
		for y_offset in range(-radius, radius + 1):
			for x_offset in range(-radius, radius + 1):
				var region := center_region + Vector2i(x_offset, y_offset)
				if not _region_is_streamable(region) or _region_is_prepared(region):
					continue
				enqueue_region_preload(region)
				queued += 1
		return queued
	var loaded_now := 0
	for y_offset in range(-radius, radius + 1):
		for x_offset in range(-radius, radius + 1):
			var region := center_region + Vector2i(x_offset, y_offset)
			if not _region_is_streamable(region):
				continue
			if not loaded_regions.has(region):
				loaded_now += 1
			if not populated_regions.has(region):
				populate_region_exploration(region)
			loaded_regions[region] = true
			visited_regions[region] = true
	return loaded_now


func materialize_route_regions(from_cell: Vector2i, to_cell: Vector2i, vertical_band: int = 2) -> void:
	if not uses_sparse_cells() and not uses_lazy_topology():
		return
	for region_value: Variant in route_regions_for_flow(from_cell, to_cell, vertical_band).keys():
		var region: Vector2i = region_value
		_ensure_region_chunk(region)
		if uses_lazy_topology() and _region_needs_topology_materialize(region):
			_materialize_topology_for_region(region)


func has_walkable_route(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	if uses_sparse_cells() and INFINITE_STREAMING:
		return has_walkable_route_in_corridor(from_cell, to_cell, 8)
	return _has_walkable_route_full(from_cell, to_cell)


func has_walkable_route_in_corridor(from_cell: Vector2i, to_cell: Vector2i, max_regions: int = 6) -> bool:
	if not in_bounds(from_cell) or not in_bounds(to_cell) or not is_walkable(to_cell):
		return false
	if from_cell == to_cell:
		return is_walkable(from_cell)
	var cache_key := _route_cache_key(from_cell, to_cell)
	if _walkable_route_cache.has(cache_key):
		return bool(_walkable_route_cache[cache_key])
	var corridor := corridor_regions_between(from_cell, to_cell, 3)
	corridor.merge(corridor_regions_between(from_cell, spawn_cell, 2))
	if corridor.size() > max_regions:
		corridor = _route_strip_regions(from_cell, to_cell)
		corridor.merge(_route_strip_regions(from_cell, spawn_cell))
	var result := _walkable_route_in_regions(from_cell, to_cell, corridor)
	_walkable_route_cache[cache_key] = result
	return result


func _route_cache_key(from_cell: Vector2i, to_cell: Vector2i) -> int:
	return hash(Vector2i(from_cell.x, from_cell.y)) ^ (hash(Vector2i(to_cell.x, to_cell.y)) << 1)


func invalidate_walkable_route_cache_for_cell(cell: Vector2i) -> void:
	if _walkable_route_cache.is_empty():
		return
	var region := region_for_cell(cell)
	# Route cache keys do not encode their traversed regions, so the previous
	# implementation ultimately invalidated the entire cache whenever this region
	# intersected any spawn-lane corridor -- but did so by copying and erasing every
	# key in interpreted GDScript on the mining frame. Preserve the same correctness
	# contract with one O(1)-style Dictionary clear once a relevant corridor is found.
	for lane_value: Variant in _spawn_lane_corridors.keys():
		var lane: Vector2i = lane_value
		var corridor: Dictionary = _spawn_lane_corridors[lane]
		if corridor.has(region):
			_walkable_route_cache.clear()
			return


func spawn_lane_corridor_regions(spawn_at: Vector2i) -> Dictionary:
	if _spawn_lane_corridors.has(spawn_at):
		return _spawn_lane_corridors[spawn_at]
	var regions := route_regions_for_flow(spawn_at, core_cell, 3)
	regions.merge(route_regions_for_flow(spawn_at, spawn_cell, 2))
	return regions


func _walkable_route_in_regions(from_cell: Vector2i, to_cell: Vector2i, allowed_regions: Dictionary) -> bool:
	var frontier: Array[Vector2i] = [from_cell]
	var head := 0
	var seen: Dictionary = {from_cell: true}
	var max_steps := maxi(1, allowed_regions.size()) * REGION_SIZE * REGION_SIZE
	var steps := 0
	while head < frontier.size() and steps < max_steps:
		var current: Vector2i = frontier[head]
		head += 1
		steps += 1
		if current == to_cell:
			return true
		for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
			var neighbor := current + direction
			if seen.has(neighbor) or not in_bounds(neighbor) or not is_walkable(neighbor):
				continue
			if not allowed_regions.has(region_for_cell(neighbor)):
				continue
			seen[neighbor] = true
			frontier.append(neighbor)
	return false


func _has_walkable_route_full(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	if not in_bounds(from_cell) or not in_bounds(to_cell) or not is_walkable(to_cell):
		return false
	if from_cell == to_cell:
		return is_walkable(from_cell)
	var frontier: Array[Vector2i] = [from_cell]
	var head := 0
	var seen: Dictionary = {from_cell: true}
	var max_steps := width * height
	var steps := 0
	while head < frontier.size() and steps < max_steps:
		var current: Vector2i = frontier[head]
		head += 1
		steps += 1
		if current == to_cell:
			return true
		for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
			var neighbor := current + direction
			if seen.has(neighbor) or not is_walkable(neighbor):
				continue
			seen[neighbor] = true
			frontier.append(neighbor)
	return false


func connect_spawn_lane_to_core(spawn_at: Vector2i) -> void:
	if not in_bounds(spawn_at):
		return
	materialize_route_regions(spawn_at, core_cell, 3)
	materialize_route_regions(spawn_at, spawn_cell, 2)


func ensure_spawn_lane_route(spawn_at: Vector2i) -> bool:
	if not in_bounds(spawn_at):
		return false
	connect_spawn_lane_to_core(spawn_at)
	if has_walkable_route(spawn_at, core_cell) or has_walkable_route(spawn_at, spawn_cell):
		return true
	if not is_walkable(spawn_at):
		open_discovery_chamber(spawn_at, 1)
	_carve_corridor(spawn_at, spawn_cell, 1)
	materialize_route_regions(spawn_at, spawn_cell, 2)
	if has_walkable_route(spawn_at, spawn_cell):
		return true
	_carve_corridor(spawn_at, core_cell, 1)
	materialize_route_regions(spawn_at, core_cell, 2)
	return has_walkable_route(spawn_at, core_cell) or has_walkable_route(spawn_at, spawn_cell)


func activate_region_window(center_cells: Array, radius: int = 1) -> int:
	schedule_region_window(center_cells, radius)
	return process_region_preload_budget(9999)


func _collect_region_window(center_cells: Array, radius: int = 1) -> Dictionary:
	var desired_regions: Dictionary = {}
	for center_value: Variant in center_cells:
		var center_cell: Vector2i = center_value
		var center_region := region_for_cell(center_cell)
		for y_offset in range(-radius, radius + 1):
			for x_offset in range(-radius, radius + 1):
				var region := center_region + Vector2i(x_offset, y_offset)
				if not _region_is_streamable(region):
					continue
				desired_regions[region] = true
	return desired_regions


func _clear_region_preload_queue() -> void:
	_region_preload_queue.clear()
	_region_preload_seen.clear()


func region_preload_pending() -> int:
	return _region_preload_queue.size()


func take_region_preload_delta() -> Array[Vector2i]:
	var delta := _region_preload_delta.duplicate()
	_region_preload_delta.clear()
	return delta


func region_spawn_retryable(cell: Vector2i) -> bool:
	var region := region_for_cell(cell)
	if not _region_is_streamable(region):
		return false
	if _stream_window_regions.has(region):
		return true
	return _region_preload_seen.has(region)


func enqueue_spawn_lane_preload(spawn_at: Vector2i) -> void:
	enqueue_regions_around_cell(spawn_at, 1)
	for region_value: Variant in corridor_regions_between(spawn_at, core_cell, 2).keys():
		enqueue_region_preload(region_value)
	for region_value: Variant in corridor_regions_between(spawn_at, spawn_cell, 2).keys():
		enqueue_region_preload(region_value)


func enqueue_region_preload(region: Vector2i, front: bool = false) -> void:
	if _region_is_prepared(region):
		return
	if _region_preload_seen.has(region):
		# A region may already be waiting as low-priority horizon preparation. If it
		# becomes visible/travel-critical, promote the existing request instead of
		# waiting behind the rest of the horizon queue.
		if front:
			var existing_index := _region_preload_queue.find(region)
			if existing_index > 0:
				_region_preload_queue.remove_at(existing_index)
				_region_preload_queue.push_front(region)
		return
	_region_preload_seen[region] = true
	if front:
		_region_preload_queue.push_front(region)
	else:
		_region_preload_queue.append(region)


func enqueue_regions_around_cell(cell: Vector2i, radius: int, front: bool = false) -> void:
	var window := _collect_region_window([cell], radius)
	for region_value: Variant in window.keys():
		enqueue_region_preload(region_value, front)


func stream_window_regions() -> Dictionary:
	return _stream_window_regions


func schedule_region_window(center_cells: Array, radius: int = 1) -> int:
	# Legacy compatibility path. Enforce the same bounded render/simulation contract
	# used by apply_render_window instead of bypassing the active-world budget.
	var desired_regions := _collect_region_window(center_cells, radius)
	var focus_cell: Vector2i = center_cells[0] if not center_cells.is_empty() else core_cell
	if desired_regions.size() > MAX_RENDER_REGIONS:
		desired_regions = _cap_render_regions(desired_regions, focus_cell, MAX_RENDER_REGIONS)
	_render_requested_regions = desired_regions.duplicate()
	_simulation_requested_regions = _simulation_regions_for_render(desired_regions, focus_cell)
	var window_changed := not _region_window_matches(_stream_window_regions, desired_regions)
	_stream_window_regions = desired_regions
	var queued := 0
	if window_changed:
		_prune_region_preload_queue(_simulation_requested_regions)
	for region_value: Variant in desired_regions.keys():
		var region: Vector2i = region_value
		visited_regions[region] = true
	for region_value: Variant in _simulation_requested_regions.keys():
		var region: Vector2i = region_value
		if _region_is_prepared(region):
			continue
		enqueue_region_preload(region)
		queued += 1
	_sync_loaded_regions_to_window(_simulation_requested_regions)
	return queued


func _region_window_matches(left: Dictionary, right: Dictionary) -> bool:
	if left.size() != right.size():
		return false
	for region_value: Variant in left.keys():
		if not right.has(region_value):
			return false
	return true


func _prune_region_preload_queue(desired_regions: Dictionary) -> void:
	# Directional prefetch changes whenever the player turns. Do not spend later
	# frames generating requests that are no longer inside the active window.
	for queue_index in range(_region_preload_queue.size() - 1, -1, -1):
		var region: Vector2i = _region_preload_queue[queue_index]
		if desired_regions.has(region):
			continue
		_region_preload_queue.remove_at(queue_index)
		_region_preload_seen.erase(region)


func process_region_preload_budget(max_regions: int) -> int:
	if max_regions <= 0:
		return 0
	var loaded_now := 0
	while loaded_now < max_regions and not _region_preload_queue.is_empty():
		var region: Vector2i = _region_preload_queue.pop_front()
		_region_preload_seen.erase(region)
		if _region_is_prepared(region):
			continue
		populate_region_exploration(region)
		# Generation is memory preparation only. Simulation and rendering are
		# independent tickets; background halo generation must not mark exploration.
		if _simulation_requested_regions.has(region):
			loaded_regions[region] = true
		if _render_requested_regions.has(region):
			_stream_window_regions[region] = true
			visited_regions[region] = true
		_region_preload_delta.append(region)
		loaded_now += 1
	return loaded_now


func prefetch_mining_beam_regions(origin: Vector2, direction: Vector2, max_distance: float) -> void:
	if direction.is_zero_approx() or max_distance <= 0.0:
		return
	var ordered_regions: Array[Vector2i] = []
	var seen: Dictionary = {}
	var distance := 0.0
	while distance <= max_distance:
		var probe := origin + direction * distance
		var region := region_for_cell(world_to_cell(probe))
		if not seen.has(region):
			seen[region] = true
			ordered_regions.append(region)
		distance += float(REGION_SIZE) * 0.5
	for beam_region: Vector2i in ordered_regions:
		enqueue_region_preload(beam_region, true)


func region_for_cell(cell: Vector2i) -> Vector2i:
	return Vector2i(
		WorldAddressScript.floor_div(cell.x, REGION_SIZE),
		WorldAddressScript.floor_div(cell.y, REGION_SIZE)
	)


func expand_regions(regions: Dictionary, radius: int = 1) -> Dictionary:
	var expanded: Dictionary = regions.duplicate()
	for region_value: Variant in regions.keys():
		var region: Vector2i = region_value
		for y_offset in range(-radius, radius + 1):
			for x_offset in range(-radius, radius + 1):
				var neighbor := region + Vector2i(x_offset, y_offset)
				if not _region_is_streamable(neighbor):
					continue
				expanded[neighbor] = true
	return expanded


func _region_is_streamable(region: Vector2i) -> bool:
	if INFINITE_STREAMING and uses_sparse_cells():
		return true
	return region.x >= 0 and region.y >= 0 and region.x < _region_columns() and region.y < _region_rows()


func corridor_regions_between(cell_a: Vector2i, cell_b: Vector2i, vertical_band: int = 2) -> Dictionary:
	# Region corridors used to scan every CELL between endpoints and insert the
	# same region key hundreds of times. That made long route/flow requests scale
	# with world-cell distance and also clamped infinite coordinates back into the
	# legacy 512x288 authored rectangle. Work directly in region coordinates.
	var min_cell := Vector2i(
		mini(cell_a.x, cell_b.x),
		mini(cell_a.y, cell_b.y) - vertical_band
	)
	var max_cell := Vector2i(
		maxi(cell_a.x, cell_b.x),
		maxi(cell_a.y, cell_b.y) + vertical_band
	)
	if not (INFINITE_STREAMING and uses_sparse_cells()):
		min_cell.x = clampi(min_cell.x, 1, maxi(1, width - 2))
		min_cell.y = clampi(min_cell.y, 1, maxi(1, height - 2))
		max_cell.x = clampi(max_cell.x, 1, maxi(1, width - 2))
		max_cell.y = clampi(max_cell.y, 1, maxi(1, height - 2))
	var min_region := region_for_cell(min_cell)
	var max_region := region_for_cell(max_cell)
	var regions: Dictionary = {}
	for region_y in range(mini(min_region.y, max_region.y), maxi(min_region.y, max_region.y) + 1):
		for region_x in range(mini(min_region.x, max_region.x), maxi(min_region.x, max_region.x) + 1):
			var region := Vector2i(region_x, region_y)
			if _region_is_streamable(region):
				regions[region] = true
	return regions


func route_regions_for_flow(from_cell: Vector2i, to_cell: Vector2i, vertical_band: int = 2) -> Dictionary:
	var corridor := corridor_regions_between(from_cell, to_cell, vertical_band)
	if corridor.size() <= FLOW_CORRIDOR_MAX_REGIONS:
		return corridor
	return _route_strip_regions(from_cell, to_cell)


func cap_regions_near_cell(regions: Dictionary, focus_cell: Vector2i, max_regions: int) -> Dictionary:
	if regions.size() <= max_regions:
		return regions
	var focus_region := region_for_cell(focus_cell)
	var ranked: Array[Dictionary] = []
	for region_value: Variant in regions.keys():
		var region: Vector2i = region_value
		ranked.append({
			"region": region,
			"dist": float(region.distance_squared_to(focus_region)),
		})
	ranked.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return float(left.dist) < float(right.dist)
	)
	var capped: Dictionary = {}
	for entry: Dictionary in ranked:
		if capped.size() >= max_regions:
			break
		capped[entry.region] = true
	return capped


func _route_strip_regions(from_cell: Vector2i, to_cell: Vector2i) -> Dictionary:
	# Fallback L-strip is also region-native. This keeps cost proportional to
	# chunk distance, not tile distance, and remains valid at signed infinite-world
	# coordinates beyond the legacy realm rectangle.
	var regions: Dictionary = {}
	var from_region := region_for_cell(from_cell)
	var to_region := region_for_cell(to_cell)
	for region_x in range(mini(from_region.x, to_region.x), maxi(from_region.x, to_region.x) + 1):
		var horizontal := Vector2i(region_x, from_region.y)
		if _region_is_streamable(horizontal):
			regions[horizontal] = true
	for region_y in range(mini(from_region.y, to_region.y), maxi(from_region.y, to_region.y) + 1):
		var vertical := Vector2i(to_region.x, region_y)
		if _region_is_streamable(vertical):
			regions[vertical] = true
	return regions


func is_region_loaded(cell: Vector2i) -> bool:
	# Loaded means simulation/render-active, not merely generated inside the
	# rolling prepare horizon. This is the entity-ticking boundary.
	return loaded_regions.has(region_for_cell(cell))


func is_region_visited(cell: Vector2i) -> bool:
	return visited_regions.has(region_for_cell(cell))


func region_readiness(region: Vector2i) -> int:
	if _region_is_prepared(region):
		if loaded_regions.has(region):
			return RegionReadiness.ACTIVE
		return RegionReadiness.PREPARED
	if populated_regions.has(region) or _region_cells.has(region) or _topology_materialized_regions.has(region):
		return RegionReadiness.GENERATED
	if _region_preload_seen.has(region):
		return RegionReadiness.QUEUED
	return RegionReadiness.ABSENT


func is_region_prepared(cell: Vector2i) -> bool:
	return region_readiness(region_for_cell(cell)) >= RegionReadiness.PREPARED


func is_region_active(cell: Vector2i) -> bool:
	return region_readiness(region_for_cell(cell)) == RegionReadiness.ACTIVE


func is_spawn_ready(cell: Vector2i) -> bool:
	return in_bounds(cell) and is_region_active(cell) and is_walkable(cell)


func prepared_spawn_cell_near(center: Vector2i, min_distance: int, max_distance: int, salt: int) -> Vector2i:
	var min_distance_sq := min_distance * min_distance
	var max_distance_sq := max_distance * max_distance
	var regions: Array[Vector2i] = []
	for region_value: Variant in loaded_regions.keys():
		var region: Vector2i = region_value
		if _region_is_prepared(region):
			regions.append(region)
	regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		return posmod(_region_seed(left) ^ salt, 2147483647) < posmod(_region_seed(right) ^ salt, 2147483647)
	)
	for region: Vector2i in regions:
		var bounds := _region_bounds(region)
		if bounds.size.x <= 0 or bounds.size.y <= 0:
			continue
		var region_salt := _region_seed(region) ^ salt
		for attempt in range(128):
			var local_x := posmod(region_salt + attempt * 17 + attempt * attempt * 3, bounds.size.x)
			var local_y := posmod(region_salt * 3 + attempt * 11 + attempt * attempt * 5, bounds.size.y)
			var candidate := bounds.position + Vector2i(local_x, local_y)
			var distance_sq := candidate.distance_squared_to(center)
			if distance_sq < min_distance_sq or distance_sq > max_distance_sq:
				continue
			if is_spawn_ready(candidate):
				return candidate
	return Vector2i(-1, -1)


func _region_is_prepared(region: Vector2i) -> bool:
	if not populated_regions.has(region):
		return false
	if uses_lazy_topology() and _region_needs_topology_materialize(region):
		return false
	return true


func uses_lazy_topology() -> bool:
	return width >= LAZY_TOPOLOGY_MIN_WIDTH


func uses_sparse_cells() -> bool:
	return width >= LAZY_TOPOLOGY_MIN_WIDTH


func _reset_cell_storage() -> void:
	_region_cells.clear()
	_region_generated.clear()
	_topology_materialized_regions.clear()
	if uses_sparse_cells():
		cells = PackedInt32Array()
	else:
		cells.resize(width * height)
		cells.fill(ROCK)


func _uses_authored_bedrock_rim() -> bool:
	return not (INFINITE_STREAMING and uses_sparse_cells())


func _is_bedrock_rim(cell: Vector2i) -> bool:
	if not _uses_authored_bedrock_rim():
		return false
	if cell.x < 0 or cell.y < 0 or cell.x >= width or cell.y >= height:
		return false
	return cell.x == 0 or cell.y == 0 or cell.x == width - 1 or cell.y == height - 1


func _region_chunk_size(region: Vector2i) -> int:
	var bounds := _region_bounds(region)
	return bounds.size.x * bounds.size.y


func _region_cell_index(cell: Vector2i, region: Vector2i) -> int:
	var bounds := _region_bounds(region)
	return (cell.y - bounds.position.y) * bounds.size.x + (cell.x - bounds.position.x)


func _ensure_region_chunk(region: Vector2i) -> PackedInt32Array:
	if _region_cells.has(region):
		return _region_cells[region]
	var chunk := PackedInt32Array()
	chunk.resize(_region_chunk_size(region))
	chunk.fill(ROCK)
	var bounds := _region_bounds(region)
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var rim_cell := Vector2i(x, y)
			if _is_bedrock_rim(rim_cell):
				chunk[_region_cell_index(rim_cell, region)] = BEDROCK
	_region_cells[region] = chunk
	return chunk


func _sparse_generated_value(region: Vector2i, local_index: int) -> int:
	if _region_generated.has(region):
		return int(_region_generated[region][local_index])
	return ROCK


func materialize_all_regions_for_tests() -> void:
	if not uses_sparse_cells():
		return
	for region_y in range(_region_rows()):
		for region_x in range(_region_columns()):
			var region := Vector2i(region_x, region_y)
			_ensure_region_chunk(region)
			if uses_lazy_topology():
				_materialize_topology_for_region(region)


func packed_cells() -> PackedInt32Array:
	if not uses_sparse_cells():
		return cells
	var packed := PackedInt32Array()
	packed.resize(width * height)
	for y in range(height):
		for x in range(width):
			packed[y * width + x] = get_cell(Vector2i(x, y))
	return packed


func materialized_region_count() -> int:
	return _region_cells.size()


func _topology_variation_params() -> Dictionary:
	var topology := realm_traits[1] if realm_traits.size() > 1 else "WIDE CHAMBERS"
	var params := {
		"room_w_min": 5,
		"room_w_max": 10,
		"room_h_min": 4,
		"room_h_max": 7,
		"corridor_half": 1,
		"cross_link_mod": 2,
		"branch_depth": 12,
	}
	match topology:
		"TIGHT PASSES":
			params["room_w_min"] = 4
			params["room_w_max"] = 7
			params["room_h_min"] = 3
			params["room_h_max"] = 5
			params["corridor_half"] = 0
			params["branch_depth"] = 8
		"WIDE CHAMBERS":
			params["room_w_min"] = 9
			params["room_w_max"] = 16
			params["room_h_min"] = 6
			params["room_h_max"] = 11
			params["corridor_half"] = 1
			params["branch_depth"] = 16
		"LOOPED SHAFTS":
			params["cross_link_mod"] = 1
			params["branch_depth"] = 14
		"DEEP BRANCHES":
			params["branch_depth"] = 22
			params["room_w_min"] = 4
			params["room_w_max"] = 8
			params["room_h_min"] = 4
			params["room_h_max"] = 6
	return params


func _topology_anchors() -> Array[Vector2i]:
	var anchors: Array[Vector2i] = []
	var anchor_count := int(round(10.0 * _layout_scale())) if width >= 160 else 6
	if width >= 320:
		anchor_count = int(round(20.0 * _layout_scale()))
	for anchor_index in range(anchor_count):
		var anchor_x := _scaled_layout(18) + floori(float(anchor_index) * float(width - _scaled_layout(44)) / float(maxi(1, anchor_count - 1)))
		anchors.append(Vector2i(anchor_x, core_cell.y))
	return anchors


func _topology_branch_seed(branch_index: int) -> int:
	return int(realm_seed ^ ((branch_index + 1) * 911382323))


func _build_topology_branch_spec(branch_index: int, anchor: Vector2i, previous_anchor: Vector2i, params: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var above := rng.randi() % 2 == 0
	var branch_depth: int = params["branch_depth"]
	var upper_limit := maxi(18, core_cell.y - branch_depth)
	var room_y := rng.randi_range(5, upper_limit) if above else rng.randi_range(core_cell.y + branch_depth, height - 6)
	var room_x := clampi(anchor.x + rng.randi_range(-5, 5), _scaled_layout(7), width - _scaled_layout(24))
	var room_w := rng.randi_range(int(params["room_w_min"]), int(params["room_w_max"]))
	var room_h := rng.randi_range(int(params["room_h_min"]), int(params["room_h_max"]))
	var center := Vector2i(room_x, room_y)
	var corridor_half: int = params["corridor_half"]
	var corridor_width := corridor_half if rng.randi() % 3 != 0 else corridor_half + 1
	var room_rect := Rect2i(center - Vector2i(floori(float(room_w) / 2.0), floori(float(room_h) / 2.0)), Vector2i(room_w, room_h))
	var cross_link := branch_index > 0 and rng.randi() % int(params["cross_link_mod"]) == 0
	var cross_target := previous_anchor + Vector2i(0, -8 if above else 8) if cross_link else Vector2i.ZERO
	return {
		"anchor": anchor,
		"center": center,
		"room_rect": room_rect,
		"corridor_half": corridor_width,
		"cross_link": cross_link,
		"cross_target": cross_target,
	}


func _apply_topology_branch_spec(spec: Dictionary) -> void:
	_carve_corridor(spec["anchor"], spec["center"], int(spec["corridor_half"]))
	_carve_rect(spec["room_rect"])
	if bool(spec["cross_link"]):
		_carve_corridor(spec["center"], spec["cross_target"], 1)


func _reassert_bunker_seal_cell(cell: Vector2i) -> void:
	if is_walkable(cell):
		return
	_set_cell_as_generated(cell, ROCK)


func _reassert_bunker_seals() -> void:
	var bunker_left: int = width - _scaled_layout(18)
	var bunker_half_height := 9 if height >= 90 else 7
	for y in range(core_cell.y - bunker_half_height, core_cell.y + bunker_half_height + 1):
		_reassert_bunker_seal_cell(Vector2i(bunker_left - 1, y))
	_reassert_bunker_seal_cell(lane_seals[0])
	for seal_index in range(1, lane_seals.size()):
		for y_offset in range(-1, 2):
			_reassert_bunker_seal_cell(lane_seals[seal_index] + Vector2i(0, y_offset))


func _bootstrap_regions(radius: int = 2) -> Dictionary:
	var regions: Dictionary = {}
	var core_region := region_for_cell(core_cell)
	for y_offset in range(-radius, radius + 1):
		for x_offset in range(-radius, radius + 1):
			regions[core_region + Vector2i(x_offset, y_offset)] = true
	return regions


func _branch_spec_touches_region(spec: Dictionary, region: Vector2i) -> bool:
	return _branch_spec_intersects_bounds(spec, _region_bounds(region))


func _branch_spec_intersects_bounds(spec: Dictionary, bounds: Rect2i) -> bool:
	if bounds.intersects(spec["room_rect"]):
		return true
	if bounds.has_point(spec["anchor"]) or bounds.has_point(spec["center"]):
		return true
	var corridor_rect := _corridor_bounds(spec["anchor"], spec["center"], int(spec.get("corridor_half", 1)))
	if bounds.intersects(corridor_rect):
		return true
	if bool(spec["cross_link"]):
		if bounds.has_point(spec["cross_target"]):
			return true
		if bounds.intersects(_corridor_bounds(spec["center"], spec["cross_target"], 1)):
			return true
	return false


func _purge_deferred_specs_in_bounds(bounds: Rect2i) -> void:
	# Deferred lazy-topology specs are materialized whenever a region is later
	# touched (frontier entry pass, player exploration, etc). If one overlaps a
	# start chamber's reserved footprint it can carve straight through a wall
	# that was already sealed, leaving the player with no barrier to break.
	var kept_layout: Array[Dictionary] = []
	for spec: Dictionary in _deferred_layout_specs:
		if not _layout_spec_intersects_bounds(spec, bounds):
			kept_layout.append(spec)
	_deferred_layout_specs = kept_layout
	var kept_branches: Array[Dictionary] = []
	for spec: Dictionary in _deferred_topology_branches:
		if not _branch_spec_intersects_bounds(spec, bounds):
			kept_branches.append(spec)
	_deferred_topology_branches = kept_branches



func _region_has_pending_topology(region: Vector2i) -> bool:
	for spec: Dictionary in _deferred_layout_specs:
		if _layout_spec_touches_region(spec, region):
			return true
	for spec: Dictionary in _deferred_topology_branches:
		if _branch_spec_touches_region(spec, region):
			return true
	return false


func _region_needs_topology_materialize(region: Vector2i) -> bool:
	if not _topology_materialized_regions.has(region):
		return true
	if _region_has_pending_topology(region):
		return true
	if _region_needs_route_refresh(region):
		return true
	return false


func _materialize_topology_for_region(region: Vector2i) -> void:
	if uses_sparse_cells():
		_ensure_region_chunk(region)
	if not _region_is_fully_authored(region):
		_generate_infinite_region_topology(region)
		_topology_materialized_regions[region] = true
		_sync_generated_cells_in_region(region)
		return
	_generate_region_topology(region)


func _generate_region_topology(region: Vector2i) -> void:
	var needs_route_refresh := _region_needs_route_refresh(region)
	if _topology_materialized_regions.has(region) and not _region_has_pending_topology(region) and not needs_route_refresh:
		return
	var remaining_layout: Array[Dictionary] = []
	for spec: Dictionary in _deferred_layout_specs:
		if _layout_spec_touches_region(spec, region):
			_apply_layout_spec(spec)
		else:
			remaining_layout.append(spec)
	_deferred_layout_specs = remaining_layout
	if needs_route_refresh:
		_carve_route_strip_in_region(region)
		_region_route_epoch[region] = _route_epoch
	elif not _topology_materialized_regions.has(region):
		_carve_region_cross_and_rooms(region)
		if _region_on_spawn_core_route(region):
			_carve_route_strip_in_region(region)
			_region_route_epoch[region] = _route_epoch
		if not _region_on_spawn_core_route(region):
			_apply_region_branches(region)
		_enforce_region_playability(region)
	_reassert_bunker_seals()
	_topology_materialized_regions[region] = true
	_sync_generated_cells_in_region(region)


func _region_on_spawn_core_route(region: Vector2i) -> bool:
	return corridor_regions_between(spawn_cell, core_cell, 1).has(region)


func _region_needs_route_refresh(region: Vector2i) -> bool:
	if not _region_on_spawn_core_route(region):
		return false
	if not _topology_materialized_regions.has(region):
		return false
	return int(_region_route_epoch.get(region, -1)) != _route_epoch


func _authored_interior_bounds() -> Rect2i:
	return Rect2i(1, 1, width - 2, height - 2)


func _clamp_rect_to_authored_interior(area: Rect2i) -> Rect2i:
	return _sanitize_rect(area).intersection(_authored_interior_bounds())


func _can_carve_authored_cell(cell: Vector2i) -> bool:
	if not _authored_interior_bounds().has_point(cell):
		return false
	if is_start_chamber_reserved(cell):
		return false
	var bunker_left: int = width - _scaled_layout(18)
	var bunker_half_height := 9 if height >= 90 else 7
	if cell.x == bunker_left - 1 and cell.y >= core_cell.y - bunker_half_height and cell.y <= core_cell.y + bunker_half_height:
		return false
	return true


func _carve_authored_rect(area: Rect2i) -> void:
	var normalized := _clamp_rect_to_authored_interior(area)
	if normalized.size.x <= 0 or normalized.size.y <= 0:
		return
	for y in range(normalized.position.y, normalized.end.y):
		for x in range(normalized.position.x, normalized.end.x):
			var cell := Vector2i(x, y)
			if _can_carve_authored_cell(cell):
				_set_cell_as_generated(cell, FLOOR)


func _carve_authored_corridor(from_cell: Vector2i, to_cell: Vector2i, half_width: int = 1) -> void:
	var cursor := from_cell
	while cursor.x != to_cell.x:
		_carve_authored_rect(Rect2i(cursor - Vector2i(0, half_width), Vector2i(1, half_width * 2 + 1)))
		cursor.x += 1 if to_cell.x > cursor.x else -1
	while cursor.y != to_cell.y:
		_carve_authored_rect(Rect2i(cursor - Vector2i(half_width, 0), Vector2i(half_width * 2 + 1, 1)))
		cursor.y += 1 if to_cell.y > cursor.y else -1
	_carve_authored_rect(Rect2i(cursor - Vector2i(half_width, half_width), Vector2i(half_width * 2 + 1, half_width * 2 + 1)))


func _carve_region_cross_and_rooms(region: Vector2i) -> void:
	var origin := region * REGION_SIZE
	var center := origin + Vector2i.ONE * (REGION_SIZE / 2)
	_carve_authored_rect(Rect2i(origin.x - 1, center.y - 1, REGION_SIZE + 2, 3))
	_carve_authored_rect(Rect2i(center.x - 1, origin.y - 1, 3, REGION_SIZE + 2))
	var rng := RandomNumberGenerator.new()
	rng.seed = _region_seed(region) ^ 0x4f57464c
	var room_count := 1 if _region_on_spawn_core_route(region) else 2
	for room_index in range(room_count):
		var room_size := Vector2i(rng.randi_range(4, 9), rng.randi_range(4, 8))
		var room_center := origin + Vector2i(
			rng.randi_range(4, REGION_SIZE - 5),
			rng.randi_range(4, REGION_SIZE - 5)
		)
		_carve_authored_rect(Rect2i(room_center - room_size / 2, room_size))
		var corridor_half := 1 if room_index > 0 else mini(1, int(_topology_variation_params()["corridor_half"]))
		_carve_authored_corridor(center, room_center, corridor_half)


func _carve_route_strip_in_region(region: Vector2i) -> void:
	if not _region_on_spawn_core_route(region):
		return
	var bounds := _region_bounds(region)
	var from := spawn_cell
	var to := core_cell
	var y_band := from.y
	for x in range(mini(from.x, to.x), maxi(from.x, to.x) + 1):
		var cell := Vector2i(x, y_band)
		if bounds.has_point(cell) and _can_carve_authored_cell(cell):
			_set_cell_as_generated(cell, FLOOR)
	var x_band := to.x
	for y in range(mini(from.y, to.y), maxi(from.y, to.y) + 1):
		var cell := Vector2i(x_band, y)
		if bounds.has_point(cell) and _can_carve_authored_cell(cell):
			_set_cell_as_generated(cell, FLOOR)


func _region_branch_count_cap() -> int:
	var topology := realm_traits[1] if realm_traits.size() > 1 else "WIDE CHAMBERS"
	match topology:
		"TIGHT PASSES":
			return 1
		"DEEP BRANCHES":
			return 2
		"LOOPED SHAFTS":
			return 2
	return 2


func _apply_region_branches(region: Vector2i) -> void:
	var bounds := _region_bounds(region)
	var region_area := bounds.size.x * bounds.size.y
	if region_area > 0 and float(_count_region_walkable(region)) / float(region_area) > 0.32:
		return
	var params := _topology_variation_params()
	var rng := RandomNumberGenerator.new()
	rng.seed = _region_seed(region) ^ 0x6272616e
	var origin := region * REGION_SIZE
	var center := origin + Vector2i.ONE * (REGION_SIZE / 2)
	var max_branches := _region_branch_count_cap()
	var branch_count := rng.randi_range(0, max_branches)
	for branch_index in range(branch_count):
		var above := rng.randi() % 2 == 0
		var branch_depth: int = params["branch_depth"]
		var upper_limit := maxi(6, center.y - branch_depth)
		var lower_limit := mini(height - 7, center.y + branch_depth)
		var room_y := rng.randi_range(origin.y + 4, upper_limit) if above else rng.randi_range(lower_limit, origin.y + REGION_SIZE - 5)
		var room_x := clampi(center.x + rng.randi_range(-5, 5), origin.x + 3, origin.x + REGION_SIZE - 4)
		var room_w := rng.randi_range(int(params["room_w_min"]), int(params["room_w_max"]))
		var room_h := rng.randi_range(int(params["room_h_min"]), int(params["room_h_max"]))
		var room_center := Vector2i(room_x, room_y)
		var corridor_half: int = mini(1, int(params["corridor_half"]))
		_carve_authored_corridor(center, room_center, corridor_half)
		_carve_authored_rect(Rect2i(room_center - Vector2i(floori(float(room_w) / 2.0), floori(float(room_h) / 2.0)), Vector2i(room_w, room_h)))


func _count_region_walkable(region: Vector2i) -> int:
	var total := 0
	var bounds := _region_bounds(region)
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			if get_cell(Vector2i(x, y)) == FLOOR:
				total += 1
	return total


func _region_has_carved_room(region: Vector2i) -> bool:
	var bounds := _region_bounds(region)
	var origin := region * REGION_SIZE
	var rng := RandomNumberGenerator.new()
	rng.seed = _region_seed(region) ^ 0x4f57464c
	var room_count := 1 if _region_on_spawn_core_route(region) else 2
	for _room_index in range(room_count):
		var room_size := Vector2i(rng.randi_range(4, 9), rng.randi_range(4, 8))
		var room_center := origin + Vector2i(
			rng.randi_range(4, REGION_SIZE - 5),
			rng.randi_range(4, REGION_SIZE - 5)
		)
		var room_rect := Rect2i(room_center - room_size / 2, room_size)
		if bounds.intersects(room_rect):
			return true
	return false


func _enforce_region_playability(region: Vector2i) -> void:
	if _is_landmark_region(region):
		return
	var bounds := _region_bounds(region)
	var region_area := bounds.size.x * bounds.size.y
	if region_area <= 0:
		return
	var walkable := _count_region_walkable(region)
	if float(walkable) / float(region_area) > REGION_MAX_FLOOR_RATIO:
		return
	if walkable >= REGION_MIN_WALKABLE and _region_has_carved_room(region):
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = _region_seed(region) ^ 0x706c6179
	var origin := region * REGION_SIZE
	var center := origin + Vector2i.ONE * (REGION_SIZE / 2)
	var room_size := Vector2i(rng.randi_range(5, 8), rng.randi_range(4, 7))
	var room_center := origin + Vector2i(rng.randi_range(5, REGION_SIZE - 6), rng.randi_range(5, REGION_SIZE - 6))
	_carve_authored_corridor(center, room_center, 1)
	_carve_authored_rect(Rect2i(room_center - room_size / 2, room_size))


func _is_bootstrap_region(region: Vector2i) -> bool:
	return _bootstrap_regions().has(region)


func _is_landmark_region(region: Vector2i) -> bool:
	if _is_bootstrap_region(region):
		return true
	var bounds := _region_bounds(region)
	if bounds.has_point(core_cell) or bounds.has_point(spawn_cell):
		return true
	var bunker_left: int = width - _scaled_layout(18)
	var bunker_rect := Rect2i(bunker_left, core_cell.y - _scaled_layout(9), _scaled_layout(17), _scaled_layout(19))
	return bounds.intersects(bunker_rect)


func _region_is_fully_authored(region: Vector2i) -> bool:
	var origin := region * REGION_SIZE
	var region_end := origin + Vector2i.ONE * REGION_SIZE
	return origin.x >= 0 and origin.y >= 0 and region_end.x <= width and region_end.y <= height


func _generate_infinite_region_topology(region: Vector2i) -> void:
	var origin := region * REGION_SIZE
	var center := origin + Vector2i.ONE * (REGION_SIZE / 2)
	var macro := Vector2i(
		WorldAddressScript.floor_div(region.x, BIOME_MACRO_SCALE),
		WorldAddressScript.floor_div(region.y, BIOME_MACRO_SCALE)
	)
	region_biomes[region] = _roll_macro_biome(macro.x, macro.y)
	# Every signed chunk owns a connected cross. Extending one cell over each
	# edge guarantees deterministic seams regardless of generation order.
	_carve_rect(Rect2i(origin.x - 1, center.y - 1, REGION_SIZE + 2, 3))
	_carve_rect(Rect2i(center.x - 1, origin.y - 1, 3, REGION_SIZE + 2))
	var rng := RandomNumberGenerator.new()
	rng.seed = _region_seed(region) ^ 0x4f57464c
	for room_index in range(3):
		var room_size := Vector2i(rng.randi_range(4, 9), rng.randi_range(4, 8))
		var room_center := origin + Vector2i(
			rng.randi_range(4, REGION_SIZE - 5),
			rng.randi_range(4, REGION_SIZE - 5)
		)
		_carve_rect(Rect2i(room_center - room_size / 2, room_size))
		_carve_corridor(center, room_center, 1 if room_index > 0 else 2)


func _corridor_bounds(from_cell: Vector2i, to_cell: Vector2i, half_width: int = 1) -> Rect2i:
	return _sanitize_rect(Rect2i(
		mini(from_cell.x, to_cell.x) - half_width,
		mini(from_cell.y, to_cell.y) - half_width,
		maxi(1, absi(to_cell.x - from_cell.x) + 1) + half_width * 2,
		maxi(1, absi(to_cell.y - from_cell.y) + 1) + half_width * 2
	))


func _collect_layout_spec_regions(spec: Dictionary, sync_regions: Dictionary) -> void:
	match str(spec.get("type", "")):
		"rect":
			_collect_rect_regions(spec["rect"], sync_regions)
		"corridor":
			_collect_rect_regions(_corridor_bounds(spec["from"], spec["to"], int(spec.get("half_width", 1))), sync_regions)
		"set_cell":
			sync_regions[region_for_cell(spec["cell"])] = true


func _collect_branch_spec_regions(spec: Dictionary, sync_regions: Dictionary) -> void:
	_collect_rect_regions(spec["room_rect"], sync_regions)
	sync_regions[region_for_cell(spec["anchor"])] = true
	sync_regions[region_for_cell(spec["center"])] = true
	_collect_rect_regions(_corridor_bounds(spec["anchor"], spec["center"], int(spec.get("corridor_half", 1))), sync_regions)
	if bool(spec.get("cross_link", false)):
		sync_regions[region_for_cell(spec["cross_target"])] = true
		_collect_rect_regions(_corridor_bounds(spec["center"], spec["cross_target"], 1), sync_regions)


func _collect_rect_regions(area: Rect2i, sync_regions: Dictionary) -> void:
	var normalized := _sanitize_rect(area)
	if normalized.size.x <= 0 or normalized.size.y <= 0:
		return
	var start_region := region_for_cell(normalized.position)
	var end_region := region_for_cell(normalized.end - Vector2i.ONE)
	for region_y in range(mini(start_region.y, end_region.y), maxi(start_region.y, end_region.y) + 1):
		for region_x in range(mini(start_region.x, end_region.x), maxi(start_region.x, end_region.x) + 1):
			sync_regions[Vector2i(region_x, region_y)] = true


func _sync_generated_cells_in_region(region: Vector2i) -> void:
	if uses_sparse_cells():
		if not _region_cells.has(region):
			return
		_region_generated[region] = _region_cells[region].duplicate()
		var bounds := _region_bounds(region)
		for y in range(bounds.position.y, bounds.end.y):
			for x in range(bounds.position.x, bounds.end.x):
				var cell := Vector2i(x, y)
				if not cell_deltas.has(cell):
					continue
				var local_index := _region_cell_index(cell, region)
				if int(cell_deltas[cell]) == int(_region_cells[region][local_index]):
					cell_deltas.erase(cell)
		return
	if _generated_cells.size() != cells.size():
		return
	var bounds := _region_bounds(region)
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var cell := Vector2i(x, y)
			var index := y * width + x
			_generated_cells[index] = cells[index]
			if cell_deltas.has(cell) and int(cell_deltas[cell]) == cells[index]:
				cell_deltas.erase(cell)


func _apply_seeded_variation(rng: RandomNumberGenerator) -> void:
	# Side chambers change travel loops and mining exposure while the authored
	# backbone guarantees a playable route in every realm.
	var params := _topology_variation_params()
	var anchors := _topology_anchors()
	for branch_index in range(anchors.size()):
		var previous_anchor := anchors[branch_index - 1] if branch_index > 0 else anchors[0]
		var spec := _build_topology_branch_spec(branch_index, anchors[branch_index], previous_anchor, params, rng)
		_apply_topology_branch_spec(spec)
	_reassert_bunker_seals()



func _configure_realm_identity(rng: RandomNumberGenerator, difficulty_id: String) -> void:
	var prefixes: Array[String] = ["ASHEN", "CHITIN", "IRON", "UMBRA", "EMBER", "HOLLOW", "COBALT", "WIDOW"]
	var suffixes: Array[String] = ["VAULT", "DEEP", "HOLD", "REACH", "WARREN", "RIFT", "BASTION", "DESCENT"]
	realm_title = "%s %s" % [prefixes[rng.randi_range(0, prefixes.size() - 1)], suffixes[rng.randi_range(0, suffixes.size() - 1)]]
	var geology: Array[String] = ["COPPER RICH", "SILVER VEINS", "GOLD POCKETS", "CRYSTAL BLOOM", "DIAMOND SCARS", "GRANITE SHELF", "BASALT DEEP", "IRON BELT", "TITANIUM FAULT", "SULFUR FIELDS"]
	var topology: Array[String] = ["TIGHT PASSES", "WIDE CHAMBERS", "LOOPED SHAFTS", "DEEP BRANCHES"]
	realm_traits = [geology[rng.randi_range(0, geology.size() - 1)], topology[rng.randi_range(0, topology.size() - 1)], difficulty_id.to_upper() + " INFESTATION"]


func _configure_seeded_frontier_sites(rng: RandomNumberGenerator) -> void:
	if width >= 320:
		frontier_sites = {
			"containment": Vector2i(rng.randi_range(int(width * 0.08), int(width * 0.14)), rng.randi_range(int(height * 0.14), int(height * 0.22))),
			"crystal": Vector2i(rng.randi_range(int(width * 0.44), int(width * 0.54)), rng.randi_range(int(height * 0.14), int(height * 0.22))),
			"foundry": Vector2i(rng.randi_range(int(width * 0.72), int(width * 0.82)), rng.randi_range(int(height * 0.76), int(height * 0.88))),
		}
	elif width >= 160:
		frontier_sites = {
			"containment": Vector2i(rng.randi_range(30, 42), rng.randi_range(18, 28)),
			"crystal": Vector2i(rng.randi_range(88, 104), rng.randi_range(16, 28)),
			"foundry": Vector2i(rng.randi_range(126, 142), rng.randi_range(height - 29, height - 17)),
		}
	else:
		frontier_sites = {
			"containment": Vector2i(rng.randi_range(14, 22), rng.randi_range(8, 12)),
			"crystal": Vector2i(rng.randi_range(46, 52), rng.randi_range(8, 12)),
			"foundry": Vector2i(rng.randi_range(56, 63), rng.randi_range(height - 12, height - 8)),
		}
	for site_cell_value: Variant in frontier_sites.values():
		var site_cell: Vector2i = site_cell_value
		var site_specs: Array[Dictionary] = [
			{"type": "rect", "rect": Rect2i(site_cell - Vector2i(2, 2), Vector2i(5, 5))},
			{"type": "corridor", "from": site_cell, "to": core_cell, "half_width": 0},
		]
		for spec: Dictionary in site_specs:
			_apply_layout_spec(spec)


func _configure_landmarks() -> void:
	var middle_y: int = floori(float(height) / 2.0)
	core_cell = Vector2i(width - _scaled_layout(13), middle_y)
	spawn_cell = Vector2i(_scaled_layout(4), middle_y)
	spawn_cells = [spawn_cell]
	var lane_offset := _scaled_layout(24) if height >= 90 else _scaled_layout(12)
	lane_seals = [
		Vector2i(width - _scaled_layout(19), middle_y),
		Vector2i(width - _scaled_layout(19), maxi(7, middle_y - lane_offset)),
		Vector2i(width - _scaled_layout(19), mini(height - 8, middle_y + lane_offset)),
	]
	tutorial_rock = lane_seals[0]


func _build_expedition_layout() -> void:
	if width >= 160 or height >= 90:
		var column_step := 24
		if width >= 480:
			column_step = 64
		elif width >= 320:
			column_step = 48
		var bunker_inset := _scaled_layout(18)
		var approach_length := _scaled_layout(30)
		if uses_lazy_topology():
			_build_scaled_realm_layout_lazy(column_step, bunker_inset, approach_length)
		else:
			_build_scaled_realm_layout(column_step, bunker_inset, approach_length)
		return
	_apply_realm_bedrock_rim()


func _build_scaled_realm_layout(column_step: int, bunker_inset: int, approach_length: int) -> void:
	for spec: Dictionary in _collect_scaled_realm_layout_specs(column_step, bunker_inset, approach_length):
		_apply_layout_spec(spec)
	_apply_realm_bedrock_rim()


func _should_defer_layout_spec(spec: Dictionary, bootstrap_bounds: Rect2i) -> bool:
	if _layout_spec_touches_bounds(spec, bootstrap_bounds):
		return false
	match str(spec.get("type", "")):
		"rect":
			return true
		"corridor":
			return true
		"set_cell":
			return false
	return true


func _build_scaled_realm_layout_lazy(column_step: int, bunker_inset: int, approach_length: int) -> void:
	_apply_realm_bedrock_rim()
	_queue_deferred_layout_specs(column_step, bunker_inset, approach_length)


func _queue_deferred_layout_specs(column_step: int, bunker_inset: int, approach_length: int) -> void:
	var bootstrap_bounds := _bootstrap_bounds_rect()
	for spec: Dictionary in _collect_scaled_realm_layout_specs(column_step, bunker_inset, approach_length):
		if _should_defer_layout_spec(spec, bootstrap_bounds):
			_deferred_layout_specs.append(spec)
		else:
			_apply_layout_spec(spec)


func _refresh_deferred_layout_specs_after_chamber() -> void:
	if not uses_lazy_topology():
		return
	var column_step := 24
	if width >= 480:
		column_step = 64
	elif width >= 320:
		column_step = 48
	_deferred_layout_specs.clear()
	_queue_deferred_layout_specs(column_step, _scaled_layout(18), _scaled_layout(30))


func _collect_scaled_realm_layout_specs(_column_step: int, bunker_inset: int, approach_length: int) -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	var middle_y := core_cell.y
	var bunker_left := width - bunker_inset
	specs.append({"type": "rect", "rect": Rect2i(bunker_left, middle_y - _scaled_layout(9), _scaled_layout(17), _scaled_layout(19))})
	for lane_index in range(1, lane_seals.size()):
		var lane_y: int = lane_seals[lane_index].y
		specs.append({"type": "corridor", "from": Vector2i(bunker_left - approach_length, lane_y), "to": Vector2i(bunker_left, lane_y), "half_width": 1})
		specs.append({"type": "corridor", "from": Vector2i(bunker_left, lane_y), "to": Vector2i(bunker_left, middle_y + (-_scaled_layout(9) if lane_y < middle_y else _scaled_layout(9))), "half_width": 1})
	for y in range(middle_y - _scaled_layout(9), middle_y + _scaled_layout(10)):
		specs.append({"type": "set_cell", "cell": Vector2i(bunker_left - 1, y), "value": ROCK})
	specs.append({"type": "set_cell", "cell": lane_seals[0], "value": ROCK})
	for seal_index in range(1, lane_seals.size()):
		for y_offset in range(-1, 2):
			specs.append({"type": "set_cell", "cell": lane_seals[seal_index] + Vector2i(0, y_offset), "value": ROCK})
	return specs


func _apply_layout_spec(spec: Dictionary) -> void:
	match str(spec.get("type", "")):
		"rect":
			_carve_rect(spec["rect"])
		"corridor":
			_carve_corridor(spec["from"], spec["to"], int(spec.get("half_width", 1)))
		"set_cell":
			var seal_cell: Vector2i = spec["cell"]
			var seal_value := int(spec["value"])
			if seal_value == ROCK and is_walkable(seal_cell):
				return
			_set_cell_as_generated(seal_cell, seal_value)


func _layout_spec_touches_bounds(spec: Dictionary, bounds: Rect2i) -> bool:
	return _layout_spec_touches_region(spec, region_for_cell(bounds.get_center())) or _layout_spec_intersects_bounds(spec, bounds)


func _layout_spec_touches_region(spec: Dictionary, region: Vector2i) -> bool:
	return _layout_spec_intersects_bounds(spec, _region_bounds(region))


func _layout_spec_intersects_bounds(spec: Dictionary, bounds: Rect2i) -> bool:
	match str(spec.get("type", "")):
		"rect":
			return bounds.intersects(_sanitize_rect(spec["rect"]))
		"corridor":
			return bounds.intersects(_corridor_bounds(spec["from"], spec["to"], int(spec.get("half_width", 1))))
		"set_cell":
			return bounds.has_point(spec["cell"])
	return false


func _bootstrap_bounds_rect(radius: int = 2) -> Rect2i:
	var bounds := Rect2i()
	var first := true
	for region_value: Variant in _bootstrap_regions(radius).keys():
		var region_bounds := _region_bounds(region_value)
		if first:
			bounds = region_bounds
			first = false
		else:
			bounds = bounds.merge(region_bounds)
	return bounds


func _materialize_frontier_entry_regions() -> void:
	var regions: Dictionary = {}
	for site_value: Variant in frontier_sites.values():
		regions.merge(expand_regions({region_for_cell(site_value): true}, 1))
	for region_value: Variant in regions.keys():
		_materialize_topology_for_region(region_value)


func _apply_realm_bedrock_rim() -> void:
	if not _uses_authored_bedrock_rim():
		return
	for x in range(width):
		set_cell(Vector2i(x, 0), BEDROCK)
		set_cell(Vector2i(x, height - 1), BEDROCK)
	for y in range(height):
		set_cell(Vector2i(0, y), BEDROCK)
		set_cell(Vector2i(width - 1, y), BEDROCK)



func _carve_rect(area: Rect2i) -> void:
	var normalized := _sanitize_rect(area)
	if normalized.size.x <= 0 or normalized.size.y <= 0:
		return
	for y in range(normalized.position.y, normalized.end.y):
		for x in range(normalized.position.x, normalized.end.x):
			_set_cell_as_generated(Vector2i(x, y), FLOOR)


func _carve_corridor(from_cell: Vector2i, to_cell: Vector2i, half_width: int = 1) -> void:
	var cursor := from_cell
	while cursor.x != to_cell.x:
		_carve_rect(Rect2i(cursor - Vector2i(0, half_width), Vector2i(1, half_width * 2 + 1)))
		cursor.x += 1 if to_cell.x > cursor.x else -1
	while cursor.y != to_cell.y:
		_carve_rect(Rect2i(cursor - Vector2i(half_width, 0), Vector2i(half_width * 2 + 1, 1)))
		cursor.y += 1 if to_cell.y > cursor.y else -1
	_carve_rect(Rect2i(cursor - Vector2i(half_width, half_width), Vector2i(half_width * 2 + 1, half_width * 2 + 1)))


func index(cell: Vector2i) -> int:
	return cell.y * width + cell.x


func in_bounds(cell: Vector2i) -> bool:
	return INFINITE_STREAMING and uses_sparse_cells() or (cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height)


func get_cell(cell: Vector2i) -> int:
	if not in_bounds(cell):
		return BEDROCK
	if uses_sparse_cells():
		if _is_bedrock_rim(cell):
			return BEDROCK
		var region := region_for_cell(cell)
		if not _region_cells.has(region):
			return ROCK
		return int(_region_cells[region][_region_cell_index(cell, region)])
	return cells[index(cell)]


func set_cell(cell: Vector2i, value: int) -> void:
	if not in_bounds(cell):
		return
	if uses_sparse_cells():
		var region := region_for_cell(cell)
		var chunk := _ensure_region_chunk(region)
		var local_index := _region_cell_index(cell, region)
		if int(chunk[local_index]) == value:
			return
		chunk[local_index] = value
		if not _track_cell_deltas:
			return
		if value == _sparse_generated_value(region, local_index):
			cell_deltas.erase(cell)
		else:
			cell_deltas[cell] = value
		# Queue the visual mutation before route-cache maintenance. Signals are
		# synchronous, so the mined/placed block becomes draw-ready first even when
		# routing invalidation has follow-up work on the same frame.
		terrain_cell_changed.emit(cell)
		if value == FLOOR or value == ROCK:
			invalidate_walkable_route_cache_for_cell(cell)
		return
	var cell_index := index(cell)
	if cells[cell_index] == value:
		return
	cells[cell_index] = value
	if not _track_cell_deltas or _generated_cells.size() != cells.size():
		return
	if value == _generated_cells[cell_index]:
		cell_deltas.erase(cell)
	else:
		cell_deltas[cell] = value
	terrain_cell_changed.emit(cell)
	if value == FLOOR or value == ROCK:
		invalidate_walkable_route_cache_for_cell(cell)


func _set_cell_as_generated(cell: Vector2i, value: int) -> void:
	if not in_bounds(cell):
		return
	if value == ROCK and int(cell_deltas.get(cell, value)) == FLOOR:
		return
	if uses_sparse_cells():
		var region := region_for_cell(cell)
		var chunk := _ensure_region_chunk(region)
		var local_index := _region_cell_index(cell, region)
		if int(chunk[local_index]) == value:
			return
		chunk[local_index] = value
		if _region_generated.has(region):
			_region_generated[region][local_index] = value
		cell_deltas.erase(cell)
		return
	var cell_index := index(cell)
	if cells[cell_index] == value:
		return
	cells[cell_index] = value
	if _generated_cells.size() == cells.size():
		_generated_cells[cell_index] = value
	cell_deltas.erase(cell)


func restore_cell_deltas(saved_deltas: Dictionary) -> int:
	var restored := 0
	for cell_value: Variant in saved_deltas.keys():
		var cell: Vector2i = cell_value
		var value := int(saved_deltas[cell_value])
		if not in_bounds(cell) or value < ROCK or value > BEDROCK:
			continue
		set_cell(cell, value)
		restored += 1
	return restored


func restore_legacy_cells(saved_cells: Variant) -> bool:
	var expected_size := width * height
	if saved_cells.size() != expected_size:
		return false
	if uses_sparse_cells():
		for cell_index in range(expected_size):
			var saved_value := int(saved_cells[cell_index])
			if saved_value < ROCK or saved_value > BEDROCK:
				return false
			var cell := Vector2i(cell_index % width, cell_index / width)
			if saved_value != get_cell(cell):
				set_cell(cell, saved_value)
		return true
	if saved_cells.size() != cells.size():
		return false
	for cell_index in range(cells.size()):
		var saved_value := int(saved_cells[cell_index])
		if saved_value < ROCK or saved_value > BEDROCK:
			return false
		if saved_value != cells[cell_index]:
			set_cell(Vector2i(cell_index % width, cell_index / width), saved_value)
	return true


func restore_legacy_cells_upscaled(saved_cells: Variant, source_width: int, source_height: int) -> bool:
	return restore_cells_upscaled(saved_cells, source_width, source_height)


func restore_cells_upscaled(saved_cells: Variant, source_width: int, source_height: int) -> bool:
	if saved_cells.size() != source_width * source_height:
		return false
	if source_width <= 0 or source_height <= 0:
		return false
	for target_y in range(height):
		for target_x in range(width):
			var source_x := clampi(int(floor(float(target_x) * float(source_width) / float(width))), 0, source_width - 1)
			var source_y := clampi(int(floor(float(target_y) * float(source_height) / float(height))), 0, source_height - 1)
			var saved_value := int(saved_cells[source_y * source_width + source_x])
			if saved_value < ROCK or saved_value > BEDROCK:
				return false
			var target_cell := Vector2i(target_x, target_y)
			if saved_value != get_cell(target_cell):
				set_cell(target_cell, saved_value)
	return true


func _seal_generated_cells() -> void:
	if uses_sparse_cells():
		_generated_cells = PackedInt32Array()
		for region_value: Variant in _region_cells.keys():
			var region: Vector2i = region_value
			_region_generated[region] = _region_cells[region].duplicate()
		cell_deltas.clear()
		_track_cell_deltas = true
		return
	_generated_cells = cells.duplicate()
	cell_deltas.clear()
	_track_cell_deltas = true


func is_walkable(cell: Vector2i) -> bool:
	return get_cell(cell) == FLOOR


func can_mine(cell: Vector2i) -> bool:
	return get_cell(cell) == ROCK


func open_cell(cell: Vector2i) -> bool:
	if not can_mine(cell):
		return false
	set_cell(cell, FLOOR)
	return true


func activate_lanes(requested_count: int) -> bool:
	var target_count := clampi(requested_count, 1, spawn_cells.size())
	var changed := target_count != active_lane_count
	active_lane_count = target_count
	return changed


func get_active_spawn_cell(lane_index: int) -> Vector2i:
	var safe_count := clampi(active_lane_count, 1, spawn_cells.size())
	return spawn_cells[posmod(lane_index, safe_count)]


func get_weighted_spawn_cell(sequence: int) -> Vector2i:
	var lane_count := clampi(active_lane_count, 1, spawn_cells.size())
	if lane_count <= 1 or sequence % 2 == 0:
		return spawn_cells[0]
	var flank_pool := lane_count - 1
	if lane_count >= 3 and spawn_cells.size() > lane_count:
		flank_pool = spawn_cells.size() - 1
	return spawn_cells[1 + posmod(floori(float(sequence) / 2.0), flank_pool)]


func offset_spawn_position(spawn_at: Vector2i, sequence: int, extra_seed: int = 0) -> Vector2:
	var center := cell_to_world(spawn_at)
	var axis := Vector2(core_cell - spawn_at)
	if axis.length_squared() <= 1.0:
		axis = Vector2.LEFT
	else:
		axis = axis.normalized()
	var flank := Vector2(-axis.y, axis.x)
	var rng := RandomNumberGenerator.new()
	rng.seed = int((spawn_at.x * 73856093) ^ (spawn_at.y * 19349663) ^ (sequence * 83492791) ^ extra_seed)
	var flank_sign := 1.0 if rng.randf() >= 0.5 else -1.0
	var flank_distance := rng.randf_range(SPAWN_FLANK_MIN_CELLS, SPAWN_FLANK_MAX_CELLS) * float(tile_size)
	var rear_pull := rng.randf_range(SPAWN_REAR_MIN_CELLS, SPAWN_REAR_MAX_CELLS) * float(tile_size)
	var micro := Vector2(rng.randf_range(-3.0, 3.0), rng.randf_range(-3.0, 3.0))
	for attempt in range(4):
		var attempt_sign := flank_sign if attempt < 2 else -flank_sign
		var attempt_distance := flank_distance * (1.0 + float(attempt % 2) * 0.45)
		var candidate := center + flank * attempt_distance * attempt_sign + axis * rear_pull + micro
		if is_walkable(world_to_cell(candidate)):
			return candidate
	return center + micro


func region_biome(region: Vector2i) -> int:
	if region_biomes.has(region):
		return int(region_biomes[region])
	return BIOME_TUNNEL


func region_biome_name(region: Vector2i) -> String:
	return BIOME_NAMES[clampi(region_biome(region), 0, BIOME_NAMES.size() - 1)]


func _region_columns() -> int:
	return ceili(float(width) / float(REGION_SIZE))


func _region_rows() -> int:
	return ceili(float(height) / float(REGION_SIZE))


func _biome_temperature(biome: int) -> int:
	match biome:
		BIOME_CRYSTAL, BIOME_IRON:
			return -1
		BIOME_FOUNDRY, BIOME_SULFUR:
			return 1
	return 0


func _assign_realm_biomes(rng: RandomNumberGenerator) -> void:
	region_biomes.clear()
	var macro_cols := maxi(1, ceili(float(_region_columns()) / float(BIOME_MACRO_SCALE)))
	var macro_rows := maxi(1, ceili(float(_region_rows()) / float(BIOME_MACRO_SCALE)))
	var macro_grid: Dictionary = {}
	for my in range(macro_rows):
		for mx in range(macro_cols):
			macro_grid[Vector2i(mx, my)] = _roll_macro_biome(mx, my)
	for my in range(macro_rows):
		for mx in range(macro_cols):
			var key := Vector2i(mx, my)
			var biome := int(macro_grid[key])
			var temp := _biome_temperature(biome)
			if temp == 0:
				continue
			for offset: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor_key: Vector2i = key + offset
				if not macro_grid.has(neighbor_key):
					continue
				var neighbor_temp := _biome_temperature(int(macro_grid[neighbor_key]))
				if neighbor_temp != 0 and neighbor_temp != temp:
					macro_grid[key] = BIOME_TUNNEL
					break
	var core_region := region_for_cell(core_cell)
	var hive_region := region_for_cell(spawn_cell)
	for ry in range(_region_rows()):
		for rx in range(_region_columns()):
			var region := Vector2i(rx, ry)
			if region == core_region:
				region_biomes[region] = BIOME_BUNKER
			elif region == hive_region:
				region_biomes[region] = BIOME_HIVE
			else:
				var macro := Vector2i(rx / BIOME_MACRO_SCALE, ry / BIOME_MACRO_SCALE)
				region_biomes[region] = int(macro_grid.get(macro, BIOME_TUNNEL))


func _roll_macro_biome(mx: int, my: int) -> int:
	var local := RandomNumberGenerator.new()
	local.seed = int(realm_seed ^ (mx * 1610612741) ^ (my * 805306457))
	var band := local.randi_range(0, 2)
	if not realm_traits.is_empty():
		match realm_traits[0]:
			"CRYSTAL BLOOM":
				band = 0 if local.randf() < 0.72 else 1
			"SULFUR FIELDS":
				band = 2 if local.randf() < 0.72 else 1
			"IRON BELT", "TITANIUM FAULT":
				band = 0 if local.randf() < 0.68 else 1
			"GOLD POCKETS", "COPPER RICH":
				band = 2 if local.randf() < 0.62 else 1
			"BASALT DEEP", "GRANITE SHELF":
				band = 1
	match band:
		0:
			var cold: Array[int] = [BIOME_CRYSTAL, BIOME_IRON, BIOME_TUNNEL]
			return cold[local.randi_range(0, cold.size() - 1)]
		2:
			var hot: Array[int] = [BIOME_FOUNDRY, BIOME_SULFUR, BIOME_TUNNEL]
			return hot[local.randi_range(0, hot.size() - 1)]
	return BIOME_TUNNEL


func populate_region_exploration(region: Vector2i) -> void:
	if populated_regions.has(region):
		var saved_region_deltas := _region_cell_delta_snapshot(region)
		if uses_lazy_topology():
			_materialize_topology_for_region(region)
		for cell_value: Variant in saved_region_deltas.keys():
			cell_deltas[cell_value] = saved_region_deltas[cell_value]
		_restore_region_cell_deltas(region)
		return
	populated_regions[region] = true
	if uses_lazy_topology():
		_materialize_topology_for_region(region)
	if uses_lazy_discoveries():
		_materialize_region_discoveries(region)
	var rng := RandomNumberGenerator.new()
	rng.seed = _region_seed(region) ^ 0x6f6f6f6f
	var biome := region_biome(region)
	var candidates := _region_exploration_candidates(region)
	_shuffle_cells(candidates, rng)
	var mineral_budget := _region_mineral_budget(biome)
	var pool := _biome_mineral_pool(biome)
	var placed := _place_region_mineral_veins(region, candidates, mineral_budget, pool, rng)
	if placed >= mineral_budget or candidates.is_empty():
		pass
	elif rng.randf() < 0.42:
		for candidate: Vector2i in candidates:
			if discovery_cells.has(candidate) or mineral_cells.has(candidate):
				continue
			if candidate.distance_to(core_cell) < realm_span() * 0.12:
				continue
			discovery_cells[candidate] = "ambush"
			break


func _place_region_mineral_veins(
	region: Vector2i,
	candidates: Array[Vector2i],
	mineral_budget: int,
	pool: Array[String],
	rng: RandomNumberGenerator
) -> int:
	if mineral_budget <= 0 or pool.is_empty():
		return 0
	var placed := 0
	var attempts := 0
	var bounds := _region_bounds(region)
	for anchor: Vector2i in candidates:
		if placed >= mineral_budget or attempts >= mineral_budget * 4:
			break
		attempts += 1
		if not _mineral_cell_available(anchor):
			continue
		if not _touches_floor(anchor) and not _near_floor(anchor, 1):
			continue
		var mineral_type: String = pool[rng.randi_range(0, pool.size() - 1)]
		# Supply caches remain isolated surprises; ores and building stone form
		# readable seams that lead away from the cave face.
		var vein_size := 1 if mineral_type == MINERAL_CACHE else mini(mineral_budget - placed, rng.randi_range(2, 4))
		var inward := _mineral_inward_direction(anchor, rng)
		var lateral := Vector2i(-inward.y, inward.x)
		for depth in range(vein_size):
			var vein_cell := anchor + inward * depth
			if depth >= 2 and rng.randf() < 0.45:
				vein_cell += lateral * rng.randi_range(-1, 1)
			if not bounds.has_point(vein_cell) or not _mineral_cell_available(vein_cell):
				continue
			mineral_cells[vein_cell] = mineral_type
			if mineral_type == MINERAL_CACHE:
				concealed_minerals[vein_cell] = true
			elif depth == 0:
				# Every ordinary vein has a visible lead so mining has a readable goal.
				concealed_minerals.erase(vein_cell)
			elif rng.randf() < minf(0.82, _conceal_chance_for(mineral_type) + float(depth) * 0.08):
				concealed_minerals[vein_cell] = true
			placed += 1
			if placed >= mineral_budget:
				break
	return placed


func _mineral_cell_available(cell: Vector2i) -> bool:
	return (
		can_mine(cell)
		and not is_start_chamber_reserved(cell)
		and not discovery_cells.has(cell)
		and not mineral_cells.has(cell)
		and not mined_minerals.has(cell)
	)


func _mineral_inward_direction(anchor: Vector2i, rng: RandomNumberGenerator) -> Vector2i:
	var inward_options: Array[Vector2i] = []
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		if is_walkable(anchor + direction):
			inward_options.append(-direction)
	if inward_options.is_empty():
		return [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP][rng.randi_range(0, 3)]
	return inward_options[rng.randi_range(0, inward_options.size() - 1)]


func _restore_region_cell_deltas(region: Vector2i) -> void:
	if not _region_cells.has(region):
		return
	var chunk: PackedInt32Array = _region_cells[region]
	var bounds := _region_bounds(region)
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var cell := Vector2i(x, y)
			if not cell_deltas.has(cell):
				continue
			chunk[_region_cell_index(cell, region)] = int(cell_deltas[cell])


func _region_cell_delta_snapshot(region: Vector2i) -> Dictionary:
	var snapshot: Dictionary = {}
	for cell_value: Variant in cell_deltas.keys():
		var cell: Vector2i = cell_value
		if region_for_cell(cell) == region:
			snapshot[cell] = cell_deltas[cell]
	return snapshot


func _evict_inactive_infinite_chunks(kept_regions: Dictionary) -> void:
	if not INFINITE_STREAMING or not uses_sparse_cells():
		return
	# The rolling prepare horizon is intentionally resident but bounded (9x9-ish).
	# It is the low-priority chunk-memory cache ahead of the player. Simulation is
	# smaller and rendering smaller again. Anything outside the rolling horizon can
	# hibernate because deterministic generation + cell_deltas is world memory.
	for region_value: Variant in _region_cells.keys():
		var region: Vector2i = region_value
		if kept_regions.has(region) or _region_intersects_prepared_bounds(region) or _region_is_fully_authored(region):
			continue
		_region_cells.erase(region)
		_region_generated.erase(region)
		_topology_materialized_regions.erase(region)


func _region_seed(region: Vector2i) -> int:
	return int(realm_seed ^ (region.x * 50331653) ^ (region.y * 12582917))


func _region_bounds(region: Vector2i) -> Rect2i:
	var origin := region * REGION_SIZE
	if INFINITE_STREAMING and uses_sparse_cells():
		return Rect2i(origin, Vector2i.ONE * REGION_SIZE)
	return Rect2i(
		origin,
		Vector2i(
			maxi(0, mini(REGION_SIZE, width - origin.x)),
			maxi(0, mini(REGION_SIZE, height - origin.y))
		)
	)


func _sanitize_rect(area: Rect2i) -> Rect2i:
	if area.size.x >= 0 and area.size.y >= 0:
		return area
	return area.abs()


func _region_exploration_candidates(region: Vector2i) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var bounds := _region_bounds(region)
	for y in range(bounds.position.y + 1, bounds.end.y - 1):
		for x in range(bounds.position.x + 1, bounds.end.x - 1):
			var candidate := Vector2i(x, y)
			if not can_mine(candidate) or is_start_chamber_reserved(candidate):
				continue
			if not _touches_floor(candidate) and not _near_floor(candidate, 1):
				continue
			if posmod(_region_seed(region) ^ (candidate.x * 92837111) ^ (candidate.y * 689287499), 100) > 62 and not _touches_floor(candidate):
				continue
			candidates.append(candidate)
	return candidates


func _near_floor(cell: Vector2i, radius: int) -> bool:
	for y_offset in range(-radius, radius + 1):
		for x_offset in range(-radius, radius + 1):
			if is_walkable(cell + Vector2i(x_offset, y_offset)):
				return true
	return false


func _region_mineral_budget(biome: int) -> int:
	match biome:
		BIOME_CRYSTAL:
			return 9
		BIOME_FOUNDRY, BIOME_IRON:
			return 8
		BIOME_SULFUR:
			return 7
		BIOME_HIVE:
			return 6
		BIOME_BUNKER:
			return 5
	return 7


func _biome_mineral_pool(biome: int) -> Array[String]:
	match biome:
		BIOME_CRYSTAL:
			return [MINERAL_CRYSTAL, MINERAL_QUARTZ, MINERAL_DIAMOND, MINERAL_SILVER, MINERAL_COPPER]
		BIOME_FOUNDRY:
			return [MINERAL_COAL, MINERAL_IRON, MINERAL_COPPER, MINERAL_SULFUR, MINERAL_CACHE]
		BIOME_SULFUR:
			return [MINERAL_SULFUR, MINERAL_COAL, MINERAL_BASALT, MINERAL_COPPER]
		BIOME_IRON:
			return [MINERAL_IRON, MINERAL_TITANIUM, MINERAL_COAL, MINERAL_GRANITE]
		BIOME_HIVE:
			return [MINERAL_COPPER, MINERAL_COAL, MINERAL_BASALT, MINERAL_SULFUR]
		BIOME_BUNKER:
			return [MINERAL_GRANITE, MINERAL_BASALT, MINERAL_IRON, MINERAL_COAL]
	return [MINERAL_COPPER, MINERAL_GRANITE, MINERAL_BASALT, MINERAL_COAL, MINERAL_QUARTZ, MINERAL_IRON]


func _conceal_chance_for(mineral_type: String) -> float:
	match mineral_type:
		MINERAL_GRANITE, MINERAL_COAL:
			return 0.24
		MINERAL_BASALT, MINERAL_IRON:
			return 0.34
		MINERAL_QUARTZ, MINERAL_SULFUR:
			return 0.46
		MINERAL_TITANIUM:
			return 0.64
		MINERAL_SILVER:
			return 0.42
		MINERAL_GOLD:
			return 0.56
		MINERAL_CRYSTAL:
			return 0.48
		MINERAL_DIAMOND:
			return 0.72
		MINERAL_CACHE:
			return 1.0
	return 0.32


func configure_discoveries(seed: int, difficulty_id: String) -> void:
	discovery_cells.clear()
	revealed_discoveries.clear()
	mineral_cells.clear()
	mined_minerals.clear()
	concealed_minerals.clear()
	populated_regions.clear()
	_discovery_plan.clear()
	_discovery_materialized.clear()
	_mineral_remaining.clear()
	_discovery_rng_seed = seed
	if uses_lazy_discoveries():
		_configure_discoveries_lazy(seed, difficulty_id)
	else:
		_configure_discoveries_full(seed, difficulty_id)


func uses_lazy_discoveries() -> bool:
	return width >= LAZY_TOPOLOGY_MIN_WIDTH


func restore_discoveries_for_visited_regions(visited: Dictionary) -> void:
	if not uses_lazy_discoveries():
		return
	var regions: Array[Vector2i] = []
	for region_value: Variant in visited.keys():
		regions.append(region_value)
	regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		if left.x == right.x:
			return left.y < right.y
		return left.x < right.x
	)
	for region: Vector2i in regions:
		populate_region_exploration(region)


func restore_visited_regions_for_load(visited: Dictionary) -> void:
	visited_regions = visited.duplicate()
	if uses_lazy_topology():
		var regions: Array[Vector2i] = []
		for region_value: Variant in visited.keys():
			var region: Vector2i = region_value
			regions.append(region)
		regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
			if left.x == right.x:
				return left.y < right.y
			return left.x < right.x
		)
		for region: Vector2i in regions:
			if uses_lazy_discoveries():
				populate_region_exploration(region)
			else:
				_materialize_topology_for_region(region)
		return
	for region_value: Variant in visited.keys():
		var region: Vector2i = region_value
		visited_regions[region] = true


func is_authored_region(region: Vector2i) -> bool:
	return _region_is_fully_authored(region)


func authored_region_list() -> Array[Vector2i]:
	var regions: Array[Vector2i] = []
	for region_y in range(_region_rows()):
		for region_x in range(_region_columns()):
			var region := Vector2i(region_x, region_y)
			if not is_authored_region(region):
				continue
			regions.append(region)
	regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		if left.x == right.x:
			return left.y < right.y
		return left.x < right.x
	)
	return regions


func populate_region_topology_only(region: Vector2i) -> void:
	_materialize_topology_for_region(region)


func populate_region_content_only(region: Vector2i) -> void:
	if populated_regions.has(region):
		return
	populated_regions[region] = true
	if uses_lazy_discoveries():
		_materialize_region_discoveries(region)
	var rng := RandomNumberGenerator.new()
	rng.seed = _region_seed(region) ^ 0x6f6f6f6f
	var biome := region_biome(region)
	var candidates := _region_exploration_candidates(region)
	_shuffle_cells(candidates, rng)
	var mineral_budget := _region_mineral_budget(biome)
	var pool := _biome_mineral_pool(biome)
	var placed := _place_region_mineral_veins(region, candidates, mineral_budget, pool, rng)
	if placed >= mineral_budget or candidates.is_empty():
		return
	if rng.randf() < 0.42:
		for candidate: Vector2i in candidates:
			if discovery_cells.has(candidate) or mineral_cells.has(candidate):
				continue
			if candidate.distance_to(core_cell) < realm_span() * 0.12:
				continue
			discovery_cells[candidate] = "ambush"
			break


func bulk_materialize_prepare_zone(progress_cb: Callable, budget: int, start_index: int = 0) -> int:
	var regions := prepare_zone_region_list()
	var index := start_index
	var processed := 0
	while index < regions.size() and processed < budget:
		var region: Vector2i = regions[index]
		populate_region_exploration(region)
		index += 1
		processed += 1
		if progress_cb.is_valid():
			progress_cb.call({
				"phase": "survey",
				"done": index,
				"total": regions.size(),
				"region": region,
			})
	return index


func prepare_zone_bulk_is_complete(next_index: int) -> bool:
	return next_index >= prepare_zone_region_list().size()


func bulk_materialize_authored(progress_cb: Callable, budget: int, start_index: int = 0) -> int:
	return bulk_materialize_prepare_zone(progress_cb, budget, start_index)


func authored_bulk_is_complete(next_index: int) -> bool:
	return prepare_zone_bulk_is_complete(next_index)


func prepare_resume_context(saved_spawn_cells: Array, breach_cell: Vector2i, lane_count: int = 1) -> void:
	if not saved_spawn_cells.is_empty():
		spawn_cells.clear()
		for cell_value: Variant in saved_spawn_cells:
			if cell_value is Vector2i:
				spawn_cells.append(cell_value)
			elif cell_value is Array and cell_value.size() == 2:
				spawn_cells.append(Vector2i(int(cell_value[0]), int(cell_value[1])))
		if spawn_cells.is_empty():
			spawn_cells = [spawn_cell]
		else:
			spawn_cell = spawn_cells[0]
		active_lane_count = clampi(lane_count, 1, maxi(1, spawn_cells.size()))
	if breach_cell != Vector2i(-1, -1) and in_bounds(breach_cell):
		tutorial_rock = breach_cell
		_replay_route_epoch_after_breach()


func _replay_route_epoch_after_breach() -> void:
	_route_epoch += 1
	_walkable_route_cache.clear()
	for region_value: Variant in corridor_regions_between(spawn_cell, core_cell, 1).keys():
		var region: Vector2i = region_value
		if _topology_materialized_regions.has(region):
			_region_route_epoch.erase(region)


func exterior_regions_in_horizon(origin_cell: Vector2i, horizon_cells: int = 100) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	var origin_region := region_for_cell(origin_cell)
	var region_radius := ceili(float(horizon_cells) / float(REGION_SIZE)) + 1
	for y_offset in range(-region_radius, region_radius + 1):
		for x_offset in range(-region_radius, region_radius + 1):
			var region := origin_region + Vector2i(x_offset, y_offset)
			if is_authored_region(region):
				continue
			if not _region_is_streamable(region):
				continue
			if _region_is_prepared(region):
				continue
			var bounds := _region_bounds(region)
			var closest := INF
			for y in range(bounds.position.y, bounds.end.y):
				for x in range(bounds.position.x, bounds.end.x):
					closest = minf(closest, origin_cell.distance_to(Vector2i(x, y)))
			if closest <= float(horizon_cells):
				results.append(region)
	results.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		if left.x == right.x:
			return left.y < right.y
		return left.x < right.x
	)
	return results


func enqueue_exterior_horizon_prefetch(origin_cell: Vector2i, horizon_cells: int = 100, max_enqueue: int = 1) -> int:
	var enqueued := 0
	for region: Vector2i in exterior_regions_in_horizon(origin_cell, horizon_cells):
		if enqueued >= max_enqueue:
			break
		if is_authored_region(region):
			continue
		if _region_preload_seen.has(region):
			continue
		enqueue_region_preload(region)
		enqueued += 1
	return enqueued


func activate_corridor_preload_burst(center_cells: Array, radius: int = 2) -> int:
	## Preload route/corridor terrain without stealing render or simulation ownership.
	## BV5.3 accidentally routed this helper through schedule_region_window(), which
	## replaced the live render/simulation tickets with the entire resume corridor.
	## On a mature save that could leave 60+ regions active until the player crossed
	## a region boundary. A preload burst is memory preparation only.
	var desired_regions := _collect_region_window(center_cells, radius)
	for region_value: Variant in desired_regions.keys():
		var region: Vector2i = region_value
		if _region_is_prepared(region):
			continue
		enqueue_region_preload(region)
	return process_region_preload_budget(9999)


func terrain_signature(sample_cells: Array[Vector2i] = []) -> int:
	var signature := 0
	var cells_to_sample: Array[Vector2i] = sample_cells
	if cells_to_sample.is_empty():
		for x in range(_scaled_layout(10), width - _scaled_layout(24), 19):
			cells_to_sample.append(Vector2i(x, core_cell.y))
	for cell: Vector2i in cells_to_sample:
		if not in_bounds(cell):
			continue
		signature = int(signature ^ ((cell.x * 92837111) ^ (cell.y * 689287499) ^ (get_cell(cell) * 17)))
	return signature


func materialize_all_discoveries_for_tests() -> void:
	if not uses_lazy_discoveries():
		return
	for region_y in range(_region_rows()):
		for region_x in range(_region_columns()):
			populate_region_exploration(Vector2i(region_x, region_y))


func _configure_discoveries_full(seed: int, difficulty_id: String) -> void:
	var valid_candidates: Array[Vector2i] = []
	for y in range(2, height - 2):
		for x in range(2, width - 2):
			var candidate := Vector2i(x, y)
			if can_mine(candidate) and _touches_floor(candidate) and not is_start_chamber_reserved(candidate):
				valid_candidates.append(candidate)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	_shuffle_cells(valid_candidates, rng)

	var nest_count := 4 if difficulty_id == "extinction" else 3
	var guardian_count := 3 if difficulty_id in ["onslaught", "extinction"] else 2
	var nest_min_distance := realm_span() * DISCOVERY_NEST_MIN_CORE_RATIO
	var nest_spacing := realm_span() * DISCOVERY_NEST_SPACING_RATIO
	var guardian_min_distance := realm_span() * DISCOVERY_GUARDIAN_MIN_CORE_RATIO
	var nest_pool: Array[Vector2i] = []
	var guardian_pool: Array[Vector2i] = []
	for candidate: Vector2i in valid_candidates:
		var core_distance: float = candidate.distance_to(core_cell)
		if core_distance >= nest_min_distance:
			nest_pool.append(candidate)
		if core_distance >= guardian_min_distance:
			guardian_pool.append(candidate)
	_place_spaced_discoveries(nest_pool, "nest", nest_count, nest_spacing, rng, nest_min_distance)
	_place_spaced_discoveries(guardian_pool, "guardian", guardian_count, nest_spacing * 0.85, rng, guardian_min_distance)
	var ambush_target := 4
	match difficulty_id:
		"onslaught":
			ambush_target = 6
		"extinction":
			ambush_target = 8
	var ambush_placed := 0
	for candidate: Vector2i in valid_candidates:
		if ambush_placed >= ambush_target:
			break
		if discovery_cells.has(candidate):
			continue
		discovery_cells[candidate] = "ambush"
		ambush_placed += 1

	var cursor := 0
	# Resource counts scale with map area. Common seams sustain exploration while
	# crystals, diamonds, and caches remain memorable prize moments.
	var resource_cells := _discovery_resource_cells()
	var target_counts := {
		MINERAL_COPPER: maxi(18, floori(float(resource_cells) / 150.0)),
		MINERAL_SILVER: maxi(12, floori(float(resource_cells) / 260.0)),
		MINERAL_GOLD: maxi(8, floori(float(resource_cells) / 430.0)),
		MINERAL_CRYSTAL: maxi(10, floori(float(resource_cells) / 310.0)),
		MINERAL_DIAMOND: maxi(5, floori(float(resource_cells) / 720.0)),
		MINERAL_CACHE: maxi(4, floori(float(resource_cells) / 950.0)),
		MINERAL_GRANITE: maxi(24, floori(float(resource_cells) / 120.0)),
		MINERAL_BASALT: maxi(18, floori(float(resource_cells) / 175.0)),
		MINERAL_QUARTZ: maxi(12, floori(float(resource_cells) / 260.0)),
		MINERAL_IRON: maxi(18, floori(float(resource_cells) / 190.0)),
		MINERAL_TITANIUM: maxi(7, floori(float(resource_cells) / 520.0)),
		MINERAL_SULFUR: maxi(10, floori(float(resource_cells) / 330.0)),
		MINERAL_COAL: maxi(16, floori(float(resource_cells) / 210.0)),
	}
	if not realm_traits.is_empty():
		match realm_traits[0]:
			"COPPER RICH":
				target_counts[MINERAL_COPPER] = int(target_counts[MINERAL_COPPER]) + 8
			"SILVER VEINS":
				target_counts[MINERAL_SILVER] = int(target_counts[MINERAL_SILVER]) + 6
			"GOLD POCKETS":
				target_counts[MINERAL_GOLD] = int(target_counts[MINERAL_GOLD]) + 5
			"CRYSTAL BLOOM":
				target_counts[MINERAL_CRYSTAL] = int(target_counts[MINERAL_CRYSTAL]) + 6
			"DIAMOND SCARS":
				target_counts[MINERAL_DIAMOND] = int(target_counts[MINERAL_DIAMOND]) + 4
			"GRANITE SHELF":
				target_counts[MINERAL_GRANITE] = int(target_counts[MINERAL_GRANITE]) + 14
			"BASALT DEEP":
				target_counts[MINERAL_BASALT] = int(target_counts[MINERAL_BASALT]) + 12
			"IRON BELT":
				target_counts[MINERAL_IRON] = int(target_counts[MINERAL_IRON]) + 12
			"TITANIUM FAULT":
				target_counts[MINERAL_TITANIUM] = int(target_counts[MINERAL_TITANIUM]) + 7
			"SULFUR FIELDS":
				target_counts[MINERAL_SULFUR] = int(target_counts[MINERAL_SULFUR]) + 9
	for mineral_type: String in [MINERAL_COPPER, MINERAL_SILVER, MINERAL_GOLD, MINERAL_CRYSTAL, MINERAL_DIAMOND, MINERAL_GRANITE, MINERAL_BASALT, MINERAL_QUARTZ, MINERAL_IRON, MINERAL_TITANIUM, MINERAL_SULFUR, MINERAL_COAL, MINERAL_CACHE]:
		for unused in range(int(target_counts[mineral_type])):
			while cursor < valid_candidates.size() and discovery_cells.has(valid_candidates[cursor]):
				cursor += 1
			if cursor >= valid_candidates.size():
				break
			mineral_cells[valid_candidates[cursor]] = mineral_type
			cursor += 1
	_configure_concealed_minerals(rng)


func _configure_discoveries_lazy(seed: int, difficulty_id: String) -> void:
	var nest_count := 4 if difficulty_id == "extinction" else 3
	var guardian_count := 3 if difficulty_id in ["onslaught", "extinction"] else 2
	var ambush_target := 4
	match difficulty_id:
		"onslaught":
			ambush_target = 6
		"extinction":
			ambush_target = 8
	var nest_min_distance := realm_span() * DISCOVERY_NEST_MIN_CORE_RATIO
	var guardian_min_distance := realm_span() * DISCOVERY_GUARDIAN_MIN_CORE_RATIO
	var nest_regions: Array[Vector2i] = []
	var guardian_regions: Array[Vector2i] = []
	var ambush_regions: Array[Vector2i] = []
	for region_y in range(_region_rows()):
		for region_x in range(_region_columns()):
			var region := Vector2i(region_x, region_y)
			var sample_cell := _region_bounds(region).position + Vector2i(2, 2)
			var core_distance := sample_cell.distance_to(core_cell)
			if core_distance >= nest_min_distance:
				nest_regions.append(region)
			if core_distance >= guardian_min_distance:
				guardian_regions.append(region)
			ambush_regions.append(region)
	nest_regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		return _region_seed(left) < _region_seed(right)
	)
	guardian_regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		return _region_seed(left) < _region_seed(right)
	)
	ambush_regions.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		return _region_seed(left) < _region_seed(right)
	)
	for region_index in range(mini(nest_count, nest_regions.size())):
		_discovery_plan_add(nest_regions[region_index], "nest")
	for region_index in range(mini(guardian_count, guardian_regions.size())):
		_discovery_plan_add(guardian_regions[region_index], "guardian")
	for region_index in range(mini(ambush_target, ambush_regions.size())):
		_discovery_plan_add(ambush_regions[region_index], "ambush")
	_mineral_remaining = _discovery_target_counts(difficulty_id).duplicate(true)


func _discovery_plan_add(region: Vector2i, discovery_type: String) -> void:
	if not _discovery_plan.has(region):
		_discovery_plan[region] = []
	var assignments: Array = _discovery_plan[region]
	if discovery_type in assignments:
		return
	assignments.append(discovery_type)


func _discovery_target_counts(difficulty_id: String) -> Dictionary:
	var resource_cells := _discovery_resource_cells()
	var target_counts := {
		MINERAL_COPPER: maxi(18, floori(float(resource_cells) / 150.0)),
		MINERAL_SILVER: maxi(12, floori(float(resource_cells) / 260.0)),
		MINERAL_GOLD: maxi(8, floori(float(resource_cells) / 430.0)),
		MINERAL_CRYSTAL: maxi(10, floori(float(resource_cells) / 310.0)),
		MINERAL_DIAMOND: maxi(5, floori(float(resource_cells) / 720.0)),
		MINERAL_CACHE: maxi(4, floori(float(resource_cells) / 950.0)),
		MINERAL_GRANITE: maxi(24, floori(float(resource_cells) / 120.0)),
		MINERAL_BASALT: maxi(18, floori(float(resource_cells) / 175.0)),
		MINERAL_QUARTZ: maxi(12, floori(float(resource_cells) / 260.0)),
		MINERAL_IRON: maxi(18, floori(float(resource_cells) / 190.0)),
		MINERAL_TITANIUM: maxi(7, floori(float(resource_cells) / 520.0)),
		MINERAL_SULFUR: maxi(10, floori(float(resource_cells) / 330.0)),
		MINERAL_COAL: maxi(16, floori(float(resource_cells) / 210.0)),
	}
	if not realm_traits.is_empty():
		match realm_traits[0]:
			"COPPER RICH":
				target_counts[MINERAL_COPPER] = int(target_counts[MINERAL_COPPER]) + 8
			"SILVER VEINS":
				target_counts[MINERAL_SILVER] = int(target_counts[MINERAL_SILVER]) + 6
			"GOLD POCKETS":
				target_counts[MINERAL_GOLD] = int(target_counts[MINERAL_GOLD]) + 5
			"CRYSTAL BLOOM":
				target_counts[MINERAL_CRYSTAL] = int(target_counts[MINERAL_CRYSTAL]) + 6
			"DIAMOND SCARS":
				target_counts[MINERAL_DIAMOND] = int(target_counts[MINERAL_DIAMOND]) + 4
			"GRANITE SHELF":
				target_counts[MINERAL_GRANITE] = int(target_counts[MINERAL_GRANITE]) + 14
			"BASALT DEEP":
				target_counts[MINERAL_BASALT] = int(target_counts[MINERAL_BASALT]) + 12
			"IRON BELT":
				target_counts[MINERAL_IRON] = int(target_counts[MINERAL_IRON]) + 12
			"TITANIUM FAULT":
				target_counts[MINERAL_TITANIUM] = int(target_counts[MINERAL_TITANIUM]) + 7
			"SULFUR FIELDS":
				target_counts[MINERAL_SULFUR] = int(target_counts[MINERAL_SULFUR]) + 9
	return target_counts


func _materialize_region_discoveries(region: Vector2i) -> void:
	if _discovery_materialized.has(region):
		return
	_discovery_materialized[region] = true
	var assignments: Variant = _discovery_plan.get(region, [])
	if assignments is Array and not assignments.is_empty():
		var rng := RandomNumberGenerator.new()
		rng.seed = _discovery_rng_seed ^ _region_seed(region) ^ 0x51c878d1
		var candidates := _region_discovery_candidates(region)
		var nest_min_distance := realm_span() * DISCOVERY_NEST_MIN_CORE_RATIO
		var guardian_min_distance := realm_span() * DISCOVERY_GUARDIAN_MIN_CORE_RATIO
		var nest_spacing := realm_span() * DISCOVERY_NEST_SPACING_RATIO
		for discovery_type_value: Variant in assignments:
			var discovery_type := str(discovery_type_value)
			var pool: Array[Vector2i] = []
			var min_distance := 0.0
			var spacing := nest_spacing
			match discovery_type:
				"nest":
					min_distance = nest_min_distance
					for candidate: Vector2i in candidates:
						if candidate.distance_to(core_cell) >= min_distance:
							pool.append(candidate)
				"guardian":
					min_distance = guardian_min_distance
					spacing = nest_spacing * 0.85
					for candidate: Vector2i in candidates:
						if candidate.distance_to(core_cell) >= min_distance:
							pool.append(candidate)
				"ambush":
					spacing = nest_spacing * 0.75
					pool = candidates.duplicate()
				_:
					continue
			if pool.is_empty():
				continue
			_place_spaced_discoveries(pool, discovery_type, 1, spacing, rng, min_distance)
	_materialize_region_minerals(region)


func _region_discovery_candidates(region: Vector2i) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var bounds := _region_bounds(region)
	for y in range(bounds.position.y + 1, bounds.end.y - 1):
		for x in range(bounds.position.x + 1, bounds.end.x - 1):
			var candidate := Vector2i(x, y)
			if not can_mine(candidate) or is_start_chamber_reserved(candidate):
				continue
			if not _touches_floor(candidate):
				continue
			candidates.append(candidate)
	return candidates


func _materialize_region_minerals(region: Vector2i) -> void:
	if _mineral_remaining.is_empty():
		return
	var remaining_total := 0
	for mineral_type: String in _mineral_remaining.keys():
		remaining_total += int(_mineral_remaining[mineral_type])
	if remaining_total <= 0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = _discovery_rng_seed ^ _region_seed(region) ^ 0x39ab41f7
	var conceal_rng := RandomNumberGenerator.new()
	conceal_rng.seed = _discovery_rng_seed ^ _region_seed(region) ^ 0x7f4a7c15
	var candidates := _region_discovery_candidates(region)
	_shuffle_cells(candidates, rng)
	# The realm-wide rarity ledger supplements local biome veins. It must not
	# drain into every exposed wall cell of whichever region prepares first.
	var regional_rare_budget := 2
	var placed_in_region := 0
	for candidate: Vector2i in candidates:
		if remaining_total <= 0 or placed_in_region >= regional_rare_budget:
			break
		if discovery_cells.has(candidate) or mineral_cells.has(candidate):
			continue
		var mineral_type := _pick_remaining_mineral(rng)
		if mineral_type.is_empty():
			break
		mineral_cells[candidate] = mineral_type
		_mineral_remaining[mineral_type] = int(_mineral_remaining[mineral_type]) - 1
		remaining_total -= 1
		if mineral_type == MINERAL_CACHE or (placed_in_region > 0 and conceal_rng.randf() < _conceal_chance_for(mineral_type)):
			concealed_minerals[candidate] = true
		else:
			concealed_minerals.erase(candidate)
		placed_in_region += 1
	if remaining_total <= 0:
		_mineral_remaining.clear()


func _pick_remaining_mineral(rng: RandomNumberGenerator) -> String:
	var options: Array[String] = []
	for mineral_type: String in _mineral_remaining.keys():
		if int(_mineral_remaining[mineral_type]) > 0:
			options.append(mineral_type)
	if options.is_empty():
		return ""
	return options[rng.randi_range(0, options.size() - 1)]


func realm_span() -> float:
	return float(maxi(width, height))


func _layout_scale() -> float:
	return float(width) / float(LEGACY_REALM_WIDTH)


func _scaled_layout(value: int) -> int:
	return maxi(value, int(round(float(value) * _layout_scale())))


func _discovery_resource_cells() -> int:
	return maxi(LEGACY_REALM_WIDTH * LEGACY_REALM_HEIGHT, int(float(width * height) * DISCOVERY_RESOURCE_AREA_RATIO))


func default_realm_size() -> Vector2i:
	return Vector2i(REALM_WIDTH, REALM_HEIGHT)


func _place_spaced_discoveries(pool: Array[Vector2i], discovery_type: String, count: int, min_spacing: float, rng: RandomNumberGenerator, min_core_distance: float) -> void:
	var placed := 0
	var core_threshold := min_core_distance
	for relax_pass in range(4):
		_shuffle_cells(pool, rng)
		for candidate: Vector2i in pool:
			if placed >= count:
				return
			if discovery_cells.has(candidate):
				continue
			if candidate.distance_to(core_cell) < core_threshold:
				continue
			if not _discovery_spacing_ok(candidate, discovery_type, min_spacing):
				continue
			discovery_cells[candidate] = discovery_type
			placed += 1
		if placed >= count:
			return
		core_threshold *= 0.82
		min_spacing *= 0.88


func _discovery_spacing_ok(cell: Vector2i, discovery_type: String, min_spacing: float) -> bool:
	for existing_cell: Variant in discovery_cells.keys():
		if str(discovery_cells[existing_cell]) != discovery_type:
			continue
		if cell.distance_to(existing_cell) < min_spacing:
			return false
	return true


func _configure_concealed_minerals(rng: RandomNumberGenerator) -> void:
	# Some deposits remain visually indistinguishable from ordinary rock until
	# the cell is opened. Rare ore and supply caches favor surprise discovery,
	# while enough common seams remain visible to teach the mining economy.
	concealed_minerals.clear()
	for cell_value: Variant in mineral_cells.keys():
		var cell: Vector2i = cell_value
		var mineral_type: String = str(mineral_cells[cell])
		var conceal_chance := 0.32
		match mineral_type:
			MINERAL_GRANITE, MINERAL_COAL:
				conceal_chance = 0.24
			MINERAL_BASALT, MINERAL_IRON:
				conceal_chance = 0.34
			MINERAL_QUARTZ, MINERAL_SULFUR:
				conceal_chance = 0.46
			MINERAL_TITANIUM:
				conceal_chance = 0.64
			MINERAL_SILVER:
				conceal_chance = 0.42
			MINERAL_GOLD:
				conceal_chance = 0.56
			MINERAL_CRYSTAL:
				conceal_chance = 0.48
			MINERAL_DIAMOND:
				conceal_chance = 0.72
			MINERAL_CACHE:
				conceal_chance = 1.0
		if rng.randf() < conceal_chance:
			concealed_minerals[cell] = true


func _shuffle_cells(values: Array[Vector2i], rng: RandomNumberGenerator) -> void:
	for index_to_shuffle in range(values.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index_to_shuffle)
		var held := values[index_to_shuffle]
		values[index_to_shuffle] = values[swap_index]
		values[swap_index] = held


func reveal_discovery(cell: Vector2i) -> String:
	if not discovery_cells.has(cell) or revealed_discoveries.has(cell):
		return ""
	var discovery_type := str(discovery_cells[cell])
	revealed_discoveries[cell] = discovery_type
	return discovery_type


func collect_mineral(cell: Vector2i) -> String:
	if not mineral_cells.has(cell) or mined_minerals.has(cell):
		return ""
	var mineral_type := str(mineral_cells[cell])
	mined_minerals[cell] = mineral_type
	return mineral_type


func get_mineral_type(cell: Vector2i) -> String:
	if mineral_cells.has(cell) and not mined_minerals.has(cell):
		return str(mineral_cells[cell])
	return ""


func is_mineral_concealed(cell: Vector2i) -> bool:
	return concealed_minerals.has(cell) and not mined_minerals.has(cell)


func register_spawn_cell(cell: Vector2i) -> bool:
	if cell == spawn_cell:
		return true
	if spawn_cells.has(cell):
		return true
	if not is_spawn_ready(cell):
		return false
	if uses_sparse_cells() and INFINITE_STREAMING:
		if has_walkable_route_in_corridor(cell, core_cell) or has_walkable_route_in_corridor(cell, spawn_cell):
			spawn_cells.append(cell)
			_spawn_lane_corridors[cell] = spawn_lane_corridor_regions(cell)
			return true
		enqueue_spawn_lane_preload(cell)
		return false
	if not ensure_spawn_lane_route(cell):
		return false
	spawn_cells.append(cell)
	_spawn_lane_corridors[cell] = spawn_lane_corridor_regions(cell)
	return true


func unregister_spawn_cell(cell: Vector2i) -> void:
	if cell == spawn_cell:
		return
	spawn_cells.erase(cell)
	active_lane_count = clampi(active_lane_count, 1, maxi(1, spawn_cells.size()))


func open_discovery_chamber(center: Vector2i, radius: int = 1) -> int:
	var opened := 0
	for y_offset in range(-radius, radius + 1):
		for x_offset in range(-radius, radius + 1):
			var target := center + Vector2i(x_offset, y_offset)
			if open_cell(target):
				opened += 1
	return opened


func _touches_floor(cell: Vector2i) -> bool:
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		if is_walkable(cell + direction):
			return true
	return false


func world_to_cell(world_position: Vector2) -> Vector2i:
	return Vector2i(floori(world_position.x / tile_size), floori(world_position.y / tile_size))


func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size + tile_size * 0.5, cell.y * tile_size + tile_size * 0.5)
