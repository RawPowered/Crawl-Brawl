## Crawl Brawl world presentation component - Phase 1 monolith extraction
## Authoritative gameplay/save state remains on CrawlBrawlRun and is proxied here during migration.
extends RefCounted

var host

func _init(run_host) -> void:
	host = run_host

## Dependency-closed compile-time constant mirror from CrawlBrawlRun.
const WorldGridScript := preload("res://systems/world_grid.gd")

const FlowFieldScript := preload("res://systems/flow_field.gd")

const RealmVisualStyleScript := preload("res://systems/realm_visual_style.gd")

const MATERIAL_MACRO_CELLS := 2

const MATERIAL_MACRO_SIZE := 32

const MATERIAL_SUBPATCH_SIZE := 16

const CAVE_MACRO_SIZE := 32

const CAVE_ATLAS_COLUMNS := 4

const CAVE_ATLAS_ROWS := 4

const VISUAL_BOUNDARY_DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

const VIEW_SIZE := Vector2(640, 360)

const MINIMAP_REBUILD_DELAY := 0.18

const TERRAIN_FLOW_REBUILD_DELAY := 0.9

const LIGHTING_PROP_THROTTLE_FRAMES := 2

const LIGHTING_CULL_MARGIN := 80.0

const TERRAIN_CHUNK_BLEED_CELLS := 2

const TERRAIN_CHUNK_BACKING := Color("121820")

## Mutable run-state proxies. Ownership remains on CrawlBrawlRun in Phase 1.
var _camera_stable_frames:
	get:
		return host._camera_stable_frames
	set(value):
		host._camera_stable_frames = value

var _chunk_formations_cache:
	get:
		return host._chunk_formations_cache
	set(value):
		host._chunk_formations_cache = value

var _chunk_macro_floor_ok:
	get:
		return host._chunk_macro_floor_ok
	set(value):
		host._chunk_macro_floor_ok = value

var _chunk_macro_rock_ok:
	get:
		return host._chunk_macro_rock_ok
	set(value):
		host._chunk_macro_rock_ok = value

var _combat_frame_tick:
	get:
		return host._combat_frame_tick
	set(value):
		host._combat_frame_tick = value

var _minimap_flush_frame:
	get:
		return host._minimap_flush_frame
	set(value):
		host._minimap_flush_frame = value

var _pending_visual_region_builds:
	get:
		return host._pending_visual_region_builds
	set(value):
		host._pending_visual_region_builds = value

var _pending_visual_region_set:
	get:
		return host._pending_visual_region_set
	set(value):
		host._pending_visual_region_set = value

var _recent_mine_flow_tick:
	get:
		return host._recent_mine_flow_tick
	set(value):
		host._recent_mine_flow_tick = value

var _terrain_chunk_draw_lean:
	get:
		return host._terrain_chunk_draw_lean
	set(value):
		host._terrain_chunk_draw_lean = value

var _terrain_draw_stream_regions:
	get:
		return host._terrain_draw_stream_regions
	set(value):
		host._terrain_draw_stream_regions = value

var base_network:
	get:
		return host.base_network
	set(value):
		host.base_network = value

var bunker_material:
	get:
		return host.bunker_material
	set(value):
		host.bunker_material = value

var cave_texture:
	get:
		return host.cave_texture
	set(value):
		host.cave_texture = value

var chest_alert_position:
	get:
		return host.chest_alert_position
	set(value):
		host.chest_alert_position = value

var chest_alert_text:
	get:
		return host.chest_alert_text
	set(value):
		host.chest_alert_text = value

var chest_alert_time:
	get:
		return host.chest_alert_time
	set(value):
		host.chest_alert_time = value

var crystal_material:
	get:
		return host.crystal_material
	set(value):
		host.crystal_material = value

var damage_flash:
	get:
		return host.damage_flash
	set(value):
		host.damage_flash = value

var discovery_hive_cells:
	get:
		return host.discovery_hive_cells
	set(value):
		host.discovery_hive_cells = value

var enemies:
	get:
		return host.enemies
	set(value):
		host.enemies = value

var explored_sectors:
	get:
		return host.explored_sectors
	set(value):
		host.explored_sectors = value

var formation_materials:
	get:
		return host.formation_materials
	set(value):
		host.formation_materials = value

var foundry_material:
	get:
		return host.foundry_material
	set(value):
		host.foundry_material = value

var grid:
	get:
		return host.grid
	set(value):
		host.grid = value

var hive_material:
	get:
		return host.hive_material
	set(value):
		host.hive_material = value

var iron_material:
	get:
		return host.iron_material
	set(value):
		host.iron_material = value

var material_backing_colors:
	get:
		return host.material_backing_colors
	set(value):
		host.material_backing_colors = value

var mecha_level:
	get:
		return host.mecha_level
	set(value):
		host.mecha_level = value

var mecha_spiders:
	get:
		return host.mecha_spiders
	set(value):
		host.mecha_spiders = value

var minimap_cache_dirty:
	get:
		return host.minimap_cache_dirty
	set(value):
		host.minimap_cache_dirty = value

var minimap_cache_image:
	get:
		return host.minimap_cache_image
	set(value):
		host.minimap_cache_image = value

var minimap_cache_texture:
	get:
		return host.minimap_cache_texture
	set(value):
		host.minimap_cache_texture = value

var minimap_patch_pending:
	get:
		return host.minimap_patch_pending
	set(value):
		host.minimap_patch_pending = value

var minimap_rebuild_cooldown:
	get:
		return host.minimap_rebuild_cooldown
	set(value):
		host.minimap_rebuild_cooldown = value

var minimap_view_origin:
	get:
		return host.minimap_view_origin
	set(value):
		host.minimap_view_origin = value

var mining_beam_valid:
	get:
		return host.mining_beam_valid
	set(value):
		host.mining_beam_valid = value

var mob_textures:
	get:
		return host.mob_textures
	set(value):
		host.mob_textures = value

var muzzle_flash:
	get:
		return host.muzzle_flash
	set(value):
		host.muzzle_flash = value

var patch_backing_cache:
	get:
		return host.patch_backing_cache
	set(value):
		host.patch_backing_cache = value

var placeable_blocks:
	get:
		return host.placeable_blocks
	set(value):
		host.placeable_blocks = value

var player_camera:
	get:
		return host.player_camera
	set(value):
		host.player_camera = value

var player_flow_stale:
	get:
		return host.player_flow_stale
	set(value):
		host.player_flow_stale = value

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

var recovery_cache:
	get:
		return host.recovery_cache
	set(value):
		host.recovery_cache = value

var region_floor_materials:
	get:
		return host.region_floor_materials
	set(value):
		host.region_floor_materials = value

var score:
	get:
		return host.score
	set(value):
		host.score = value

var spawns_remaining:
	get:
		return host.spawns_remaining
	set(value):
		host.spawns_remaining = value

var sulfur_material:
	get:
		return host.sulfur_material
	set(value):
		host.sulfur_material = value

var surface_portal_cell:
	get:
		return host.surface_portal_cell
	set(value):
		host.surface_portal_cell = value

var terrain_chunk_committed:
	get:
		return host.terrain_chunk_committed
	set(value):
		host.terrain_chunk_committed = value

var terrain_chunk_layers:
	get:
		return host.terrain_chunk_layers
	set(value):
		host.terrain_chunk_layers = value

var terrain_chunk_lean_pending:
	get:
		return host.terrain_chunk_lean_pending
	set(value):
		host.terrain_chunk_lean_pending = value

var terrain_chunk_redraw_queue:
	get:
		return host.terrain_chunk_redraw_queue
	set(value):
		host.terrain_chunk_redraw_queue = value

var terrain_flow_dirty:
	get:
		return host.terrain_flow_dirty
	set(value):
		host.terrain_flow_dirty = value

var terrain_flow_rebuild_cooldown:
	get:
		return host.terrain_flow_rebuild_cooldown
	set(value):
		host.terrain_flow_rebuild_cooldown = value

var tunnel_material:
	get:
		return host.tunnel_material
	set(value):
		host.tunnel_material = value

var visual_biome_cache:
	get:
		return host.visual_biome_cache
	set(value):
		host.visual_biome_cache = value

var visual_formation_cache:
	get:
		return host.visual_formation_cache
	set(value):
		host.visual_formation_cache = value

var visual_landmark_cache:
	get:
		return host.visual_landmark_cache
	set(value):
		host.visual_landmark_cache = value

var visual_prop_cache:
	get:
		return host.visual_prop_cache
	set(value):
		host.visual_prop_cache = value

var wave_active:
	get:
		return host.wave_active
	set(value):
		host.wave_active = value

var world_textures:
	get:
		return host.world_textures
	set(value):
		host.world_textures = value

func _draw_world(canvas: CanvasItem) -> void:
	# Parent backing renders once beneath all regional chunks so sibling chunk
	# fills never paint opaque rects over neighboring region tiles.
	var stream_regions: Dictionary = _terrain_draw_stream_regions
	if stream_regions.is_empty():
		stream_regions = host._active_stream_regions()
	var visible_bounds := _visible_cell_bounds(1)
	for region_value: Variant in stream_regions.keys():
		var region: Vector2i = region_value
		var bounds := Rect2i(region * WorldGridScript.REGION_SIZE, Vector2i.ONE * WorldGridScript.REGION_SIZE)
		if not bounds.intersects(visible_bounds):
			continue
		var chunk_rect := Rect2(
			Vector2(bounds.position * grid.tile_size),
			Vector2(bounds.size * grid.tile_size)
		)
		canvas.draw_rect(chunk_rect.grow(1.0), TERRAIN_CHUNK_BACKING)

func _terrain_chunk_draw_bounds(region: Vector2i) -> Rect2i:
	var bounds := Rect2i(region * WorldGridScript.REGION_SIZE, Vector2i.ONE * WorldGridScript.REGION_SIZE)
	var stream_regions: Dictionary = _terrain_draw_stream_regions
	if stream_regions.is_empty():
		stream_regions = host._active_stream_regions()
	if _region_available_for_bleed(region + Vector2i.LEFT, stream_regions):
		bounds.position.x -= TERRAIN_CHUNK_BLEED_CELLS
		bounds.size.x += TERRAIN_CHUNK_BLEED_CELLS
	if _region_available_for_bleed(region + Vector2i.RIGHT, stream_regions):
		bounds.size.x += TERRAIN_CHUNK_BLEED_CELLS
	if _region_available_for_bleed(region + Vector2i.UP, stream_regions):
		bounds.position.y -= TERRAIN_CHUNK_BLEED_CELLS
		bounds.size.y += TERRAIN_CHUNK_BLEED_CELLS
	if _region_available_for_bleed(region + Vector2i.DOWN, stream_regions):
		bounds.size.y += TERRAIN_CHUNK_BLEED_CELLS
	return bounds

func _region_available_for_bleed(region: Vector2i, stream_regions: Dictionary) -> bool:
	if grid.is_authored_region(region):
		return grid.region_readiness(region) >= WorldGridScript.RegionReadiness.PREPARED
	return stream_regions.has(region) or grid.region_readiness(region) >= WorldGridScript.RegionReadiness.PREPARED

func _terrain_stream_draw_bounds() -> Rect2i:
	var stream_regions: Dictionary = _terrain_draw_stream_regions
	if stream_regions.is_empty():
		stream_regions = host._active_stream_regions()
	if stream_regions.is_empty():
		return Rect2i()
	var merged := Rect2i()
	var first := true
	for region_value: Variant in stream_regions.keys():
		var bounds := _terrain_chunk_draw_bounds(region_value)
		if first:
			merged = bounds
			first = false
		else:
			merged = merged.merge(bounds)
	return merged

func _lighting_cull_rect() -> Rect2:
	return Rect2(_effective_camera_center() - VIEW_SIZE * 0.5, VIEW_SIZE).grow(LIGHTING_CULL_MARGIN)

func _lighting_rect_has_point(position: Vector2, cull_rect: Rect2) -> bool:
	return cull_rect.has_point(position)

func _should_draw_heavy_lighting() -> bool:
	if host._primary_break_held() or mining_beam_valid:
		return terrain_chunk_redraw_queue.size() <= 4
	if muzzle_flash > 0.0 or damage_flash > 0.0:
		return true
	if _camera_stable_frames < 2:
		return true
	if player_moving and _combat_frame_tick % LIGHTING_PROP_THROTTLE_FRAMES != 0:
		return false
	return true

func _draw_terrain_chunk(canvas: CanvasItem, region: Vector2i) -> void:
	_chunk_macro_floor_ok.clear()
	_chunk_macro_rock_ok.clear()
	# Decide quality before touching formation/prop caches. BV5.6 correctly made
	# active terrain lean, but the old order still generated the expensive full
	# formation cache before discovering that none of it would be drawn.
	var lean_draw := true
	if terrain_chunk_lean_pending.has(region):
		lean_draw = bool(terrain_chunk_lean_pending[region])
		terrain_chunk_lean_pending.erase(region)
	else:
		lean_draw = host._should_lean_terrain_chunk_draw(terrain_chunk_redraw_queue.size() + 1)
	# Active chunks draw their owned 24x24 cells only. The shared terrain backing
	# already covers seams, and each neighbor owns its own border cells. Bleeding a
	# lean chunk by two cells inflated both the tile and wall-edge loops by ~36%.
	var bounds := (
		Rect2i(region * WorldGridScript.REGION_SIZE, Vector2i.ONE * WorldGridScript.REGION_SIZE)
		if lean_draw
		else _terrain_chunk_draw_bounds(region)
	)
	_chunk_formations_cache = {} if lean_draw else _visual_formations_for_region(region)
	_terrain_chunk_draw_lean = lean_draw
	_draw_grid_cells(canvas, bounds)
	_draw_wall_edges_in_bounds(canvas, bounds)
	if grid.region_readiness(region) >= WorldGridScript.RegionReadiness.PREPARED:
		if not lean_draw:
			_draw_region_visual_props_in_bounds(canvas, region, bounds)
		_draw_discovery_scars_in_region(canvas, region)
	# Rebind instead of clear — formations cache returns the live dictionary.
	_chunk_formations_cache = {}
	_chunk_macro_floor_ok.clear()
	_chunk_macro_rock_ok.clear()
	_terrain_chunk_draw_lean = false
	terrain_chunk_committed[region] = true
	host._terrain_chunk_draw_committed(region, lean_draw)

func _draw_actors(canvas: CanvasItem) -> void:
	host._draw_core(canvas)
	host._draw_structure_contact_shadows(canvas)
	host._draw_structures(canvas)
	host._draw_mining_beam(canvas)
	_draw_recovery_cache(canvas)
	host._draw_brood_nests(canvas)
	host._draw_enemies(canvas)
	_draw_mecha_spiders(canvas)
	_draw_surface_portal(canvas)
	host._draw_player(canvas)

func _draw_mecha_spiders(canvas: CanvasItem) -> void:
	for mecha in mecha_spiders:
		var texture: Texture2D = mob_textures.get(mecha.role)
		var pulse := sin(mecha.visual_motion) * 1.5
		canvas.draw_circle(mecha.position, mecha.radius + 7.0 + pulse, Color(0.2, 0.85, 1.0, 0.13))
		canvas.draw_arc(mecha.position, mecha.radius + 5.0, 0.0, TAU, 24, Color("63e6ff"), 2.0)
		if texture != null:
			canvas.draw_set_transform(mecha.position, mecha.facing_angle + PI, Vector2.ONE * 0.72)
			canvas.draw_texture_rect(texture, Rect2(Vector2(-24, -22), Vector2(48, 44)), false, Color("8defff"))
			canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		canvas.draw_string(ThemeDB.fallback_font, mecha.position + Vector2(-28, -22), "MECHA MK%d" % mecha_level, HORIZONTAL_ALIGNMENT_CENTER, 56, 6, Color("c8f8ff"))

func _draw_surface_portal(canvas: CanvasItem) -> void:
	if surface_portal_cell.x < 0:
		return
	var center = grid.cell_to_world(surface_portal_cell)
	var pulse := sin(Time.get_ticks_msec() * 0.006) * 3.0
	canvas.draw_circle(center, 18.0 + pulse, Color(0.35, 0.72, 1.0, 0.12))
	canvas.draw_arc(center, 13.0 + pulse * 0.35, 0.0, TAU, 32, Color("8eeaff"), 3.0)
	canvas.draw_arc(center, 8.0, 0.0, TAU, 24, Color("d58cff"), 2.0)
	canvas.draw_string(ThemeDB.fallback_font, center + Vector2(-28, -20), "SURFACE", HORIZONTAL_ALIGNMENT_CENTER, 56, 7, Color("d8f8ff"))

func _draw_recovery_cache(canvas: CanvasItem) -> void:
	if not bool(recovery_cache.get("active", false)):
		return
	var position: Vector2 = recovery_cache.get("position", Vector2.ZERO)
	var pulse := 6.0 + sin(Time.get_ticks_msec() * 0.008) * 1.5
	canvas.draw_circle(position, pulse, Color(0.45, 0.78, 1.0, 0.12))
	canvas.draw_arc(position, pulse, 0.0, TAU, 16, Color("8edcff"), 1.5)
	canvas.draw_rect(Rect2(position - Vector2(4, 3), Vector2(8, 6)), Color("172a38"))
	canvas.draw_rect(Rect2(position - Vector2(4, 3), Vector2(8, 6)), Color("b7edff"), false, 1.0)

func _draw_effects(canvas: CanvasItem) -> void:
	host._draw_bullets(canvas)
	host._draw_combat_impacts(canvas)
	host._draw_pickups(canvas)
	host._draw_sparks(canvas)
	host._draw_targeting(canvas)
	_draw_chest_alerts(canvas)

func _draw_chest_alerts(canvas: CanvasItem) -> void:
	if chest_alert_time > 0.0:
		var font: Font = ThemeDB.fallback_font
		var alpha: float = clampf(chest_alert_time * 2.0, 0.0, 1.0)
		var float_up: float = (2.0 - chest_alert_time) * 12.0
		canvas.draw_string(font, chest_alert_position + Vector2(0, -float_up), chest_alert_text, HORIZONTAL_ALIGNMENT_CENTER, 100, 10, Color(Color("ef8b72"), alpha))

func _draw_lighting(canvas: CanvasItem) -> void:
	host._draw_atmosphere(canvas)

func _tile_draw_rect(rect: Rect2) -> Rect2:
	# Textures always draw at their exact 16x16 source size (no stretch).
	# The gl_compatibility renderer can still leave a hairline sub-pixel gap
	# between two independently-rasterized texture quads, which used to show
	# the void background as a dark seam grid. Callers draw a same-color solid
	# backing rect at this slightly grown size *underneath* the texture, so
	# any such gap reveals more of the matching base tone instead of void
	# black. A flat color fill has no "source" to stretch, so growing it is
	# free of the resample-mismatch seam a grown *texture* rect would cause.
	return rect.grow(1.0)

func _draw_grid(canvas: CanvasItem) -> void:
	var bounds: Rect2i = _visible_cell_bounds(3)
	_draw_grid_cells(canvas, bounds)
	_draw_wall_edges_in_bounds(canvas, bounds)
	_draw_environment_props(canvas)

func _draw_grid_cells(canvas: CanvasItem, bounds: Rect2i) -> void:
	_chunk_macro_floor_ok.clear()
	_chunk_macro_rock_ok.clear()
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var cell := Vector2i(x, y)
			if not grid.in_bounds(cell):
				continue
			var rect := Rect2(Vector2(x * grid.tile_size, y * grid.tile_size), Vector2(grid.tile_size, grid.tile_size))
			var value: int = grid.get_cell(cell)
			if value == WorldGridScript.FLOOR:
				var floor_macro_origin := _macro_block_origin(cell)
				var floor_macro_ok := _chunk_floor_macro_drawable(floor_macro_origin)
				if floor_macro_ok and cell == floor_macro_origin:
					_draw_floor_macro_block(canvas, floor_macro_origin)
				elif not floor_macro_ok or not bounds.has_point(floor_macro_origin):
					_draw_floor_cell(canvas, cell, rect)
			elif value == WorldGridScript.BEDROCK:
				canvas.draw_rect(rect, Color("0b1115"))
				if (x + y) % 3 == 0:
					canvas.draw_line(rect.position + Vector2(2, 3), rect.position + Vector2(13, 11), Color("182129"), 1.0)
			else:
				var rock_macro_origin := _macro_block_origin(cell)
				var rock_macro_ok := _chunk_rock_macro_drawable(rock_macro_origin)
				if rock_macro_ok and cell == rock_macro_origin:
					_draw_rock_macro_block(canvas, rock_macro_origin)
				elif not rock_macro_ok or not bounds.has_point(rock_macro_origin):
					_draw_rock_cell(canvas, cell, rect)

func _visible_cell_bounds(margin: int = 2) -> Rect2i:
	var half_view := VIEW_SIZE * 0.5
	var camera_center: Vector2 = _effective_camera_center()
	var top_left: Vector2 = camera_center - half_view
	var bottom_right: Vector2 = camera_center + half_view
	var from_cell := Vector2i(
		floori(top_left.x / grid.tile_size) - margin,
		floori(top_left.y / grid.tile_size) - margin
	)
	var to_cell := Vector2i(
		ceili(bottom_right.x / grid.tile_size) + margin,
		ceili(bottom_right.y / grid.tile_size) + margin
	)
	return Rect2i(from_cell, to_cell - from_cell)

func _effective_camera_center() -> Vector2:
	if is_instance_valid(player_camera):
		return player_camera.position
	return player_position

func _draw_mineral_seam(canvas: CanvasItem, rect: Rect2, mineral_type: String) -> void:
	var color := Color("bc7046")
	if mineral_type == WorldGridScript.MINERAL_SILVER:
		color = Color("c9d7dc")
	elif mineral_type == WorldGridScript.MINERAL_GOLD:
		color = Color("e7b83f")
	elif mineral_type == WorldGridScript.MINERAL_CRYSTAL:
		color = Color("58d8ef")
	elif mineral_type == WorldGridScript.MINERAL_DIAMOND:
		color = Color("dcfbff")
	elif mineral_type == WorldGridScript.MINERAL_CACHE:
		color = Color("ffd36b")
	elif mineral_type == WorldGridScript.MINERAL_GRANITE:
		color = Color("a6a29c")
	elif mineral_type == WorldGridScript.MINERAL_BASALT:
		color = Color("59616a")
	elif mineral_type == WorldGridScript.MINERAL_QUARTZ:
		color = Color("eadfff")
	elif mineral_type == WorldGridScript.MINERAL_IRON:
		color = Color("b96e4e")
	elif mineral_type == WorldGridScript.MINERAL_TITANIUM:
		color = Color("83b8ef")
	elif mineral_type == WorldGridScript.MINERAL_SULFUR:
		color = Color("e5d344")
	elif mineral_type == WorldGridScript.MINERAL_COAL:
		color = Color("4b4f57")
	canvas.draw_circle(rect.position + Vector2(7, 7), 3.2, Color(color, 0.18))
	canvas.draw_circle(rect.position + Vector2(5, 9), 1.7, Color(color, 0.82))
	canvas.draw_circle(rect.position + Vector2(9, 6), 1.5, color)
	canvas.draw_circle(rect.position + Vector2(11, 9), 1.0, Color(color.lightened(0.28), 0.88))

func _draw_geology_tell(canvas: CanvasItem, rect: Rect2, cell: Vector2i) -> void:
	# Concealed deposits never expose their material color. A restrained fracture
	# rewards observant exploration without turning the surprise into a marker.
	var offset := float(posmod(cell.x * 7 + cell.y * 11, 3))
	var tell_color := Color(0.58, 0.66, 0.62, 0.24)
	canvas.draw_line(rect.position + Vector2(4 + offset, 12), rect.position + Vector2(7, 8), tell_color, 1.0)
	canvas.draw_line(rect.position + Vector2(7, 8), rect.position + Vector2(10 - offset, 5), Color(tell_color, 0.17), 1.0)

func _macro_block_origin(cell: Vector2i) -> Vector2i:
	return Vector2i(
		(cell.x / MATERIAL_MACRO_CELLS) * MATERIAL_MACRO_CELLS,
		(cell.y / MATERIAL_MACRO_CELLS) * MATERIAL_MACRO_CELLS
	)

func _macro_block_is_complete_floor(macro_origin: Vector2i) -> bool:
	for offset_y: int in range(MATERIAL_MACRO_CELLS):
		for offset_x: int in range(MATERIAL_MACRO_CELLS):
			var cell := macro_origin + Vector2i(offset_x, offset_y)
			if not grid.in_bounds(cell) or grid.get_cell(cell) != WorldGridScript.FLOOR:
				return false
	return true

func _macro_block_has_uniform_floor_material(macro_origin: Vector2i) -> bool:
	var expected: Texture2D = _material_for_cell(macro_origin)
	for offset_y: int in range(MATERIAL_MACRO_CELLS):
		for offset_x: int in range(MATERIAL_MACRO_CELLS):
			var cell := macro_origin + Vector2i(offset_x, offset_y)
			if _material_for_cell(cell) != expected:
				return false
	return true

func _macro_block_is_complete_rock(macro_origin: Vector2i) -> bool:
	for offset_y: int in range(MATERIAL_MACRO_CELLS):
		for offset_x: int in range(MATERIAL_MACRO_CELLS):
			var cell := macro_origin + Vector2i(offset_x, offset_y)
			if not grid.in_bounds(cell) or grid.get_cell(cell) != WorldGridScript.ROCK:
				return false
	return true

func _chunk_floor_macro_drawable(macro_origin: Vector2i) -> bool:
	if _chunk_macro_floor_ok.has(macro_origin):
		return bool(_chunk_macro_floor_ok[macro_origin])
	var ok := _macro_block_is_complete_floor(macro_origin) and _macro_block_has_uniform_floor_material(macro_origin)
	_chunk_macro_floor_ok[macro_origin] = ok
	return ok

func _chunk_rock_macro_drawable(macro_origin: Vector2i) -> bool:
	if _chunk_macro_rock_ok.has(macro_origin):
		return bool(_chunk_macro_rock_ok[macro_origin])
	var ok := _macro_block_is_complete_rock(macro_origin)
	_chunk_macro_rock_ok[macro_origin] = ok
	return ok

func _material_for_macro_block(macro_origin: Vector2i) -> Texture2D:
	return _material_for_cell(macro_origin)

func _sample_patch_edge_color(texture: Texture2D, source_rect: Rect2) -> Color:
	if texture == null:
		return Color("121820")
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return Color("121820")
	var x0 := clampi(int(source_rect.position.x), 0, image.get_width() - 1)
	var y0 := clampi(int(source_rect.position.y), 0, image.get_height() - 1)
	var x1 := clampi(int(source_rect.end.x) - 1, 0, image.get_width() - 1)
	var y1 := clampi(int(source_rect.end.y) - 1, 0, image.get_height() - 1)
	if x1 < x0 or y1 < y0:
		return image.get_pixel(x0, y0)
	var red := 0.0
	var green := 0.0
	var blue := 0.0
	var count := 0
	for x: int in range(x0, x1 + 1):
		for y: int in [y0, y1]:
			var pixel: Color = image.get_pixel(x, y)
			red += pixel.r
			green += pixel.g
			blue += pixel.b
			count += 1
	for y: int in range(y0 + 1, y1):
		for x: int in [x0, x1]:
			var pixel: Color = image.get_pixel(x, y)
			red += pixel.r
			green += pixel.g
			blue += pixel.b
			count += 1
	if count <= 0:
		return image.get_pixel(x0, y0)
	return Color(red / count, green / count, blue / count)

func _backing_color_for_source(texture: Texture2D, source_rect: Rect2) -> Color:
	if texture == null:
		return Color("121820")
	var cache_key := "%s|%d,%d" % [texture.get_rid(), int(source_rect.position.x), int(source_rect.position.y)]
	if patch_backing_cache.has(cache_key):
		return patch_backing_cache[cache_key]
	var color: Color = _sample_patch_edge_color(texture, source_rect)
	patch_backing_cache[cache_key] = color
	return color

func _sample_atlas_corner_color(texture: Texture2D) -> Color:
	if texture == null:
		return Color("121820")
	return _sample_patch_edge_color(texture, Rect2(Vector2.ZERO, Vector2(MATERIAL_MACRO_SIZE, MATERIAL_MACRO_SIZE)))

func _cache_terrain_backing_colors() -> void:
	material_backing_colors.clear()
	for material: Texture2D in [
		tunnel_material, hive_material, bunker_material, crystal_material,
		foundry_material, sulfur_material, iron_material,
	]:
		if material != null:
			material_backing_colors[material] = _sample_atlas_corner_color(material)
	if cave_texture != null:
		material_backing_colors[cave_texture] = _sample_patch_edge_color(cave_texture, Rect2(Vector2.ZERO, Vector2(CAVE_MACRO_SIZE, CAVE_MACRO_SIZE)))

func _floor_backing_color_for_material(material: Texture2D) -> Color:
	if material != null and material_backing_colors.has(material):
		return material_backing_colors[material]
	return _floor_base_color_for_material(material)

func _draw_floor_macro_block(canvas: CanvasItem, macro_origin: Vector2i) -> void:
	var material: Texture2D = _material_for_macro_block(macro_origin)
	var world_macro_size := float(MATERIAL_MACRO_CELLS * grid.tile_size)
	var rect := Rect2(
		Vector2(macro_origin.x * grid.tile_size, macro_origin.y * grid.tile_size),
		Vector2(world_macro_size, world_macro_size)
	)
	var salt: int = _material_salt(material)
	var source_rect: Rect2 = _macro_block_texture_region(material, macro_origin, salt)
	var backing: Color = _floor_backing_color_for_material(material) if _terrain_chunk_draw_lean else _backing_color_for_source(material, source_rect)
	var tint: Color = _floor_tint_for_material(material)
	canvas.draw_rect(_tile_draw_rect(rect), backing)
	if material != null:
		canvas.draw_texture_rect_region(material, rect, source_rect, Color(tint, 1.0))
	if _terrain_chunk_draw_lean:
		return
	for offset_y: int in range(MATERIAL_MACRO_CELLS):
		for offset_x: int in range(MATERIAL_MACRO_CELLS):
			var cell := macro_origin + Vector2i(offset_x, offset_y)
			var cell_rect := Rect2(
				Vector2(cell.x * grid.tile_size, cell.y * grid.tile_size),
				Vector2(grid.tile_size, grid.tile_size)
			)
			_draw_floor_formation_overlay(canvas, cell, cell_rect, material)
			_draw_floor_cell_overlays(canvas, cell, cell_rect, material)

func _draw_rock_macro_block(canvas: CanvasItem, macro_origin: Vector2i) -> void:
	if cave_texture == null:
		return
	var world_macro_size := float(MATERIAL_MACRO_CELLS * grid.tile_size)
	var rect := Rect2(
		Vector2(macro_origin.x * grid.tile_size, macro_origin.y * grid.tile_size),
		Vector2(world_macro_size, world_macro_size)
	)
	var source_rect: Rect2 = _macro_block_texture_region(cave_texture, macro_origin, 41)
	var backing: Color = material_backing_colors.get(cave_texture, Color("121820")) if _terrain_chunk_draw_lean else _backing_color_for_source(cave_texture, source_rect)
	var tint: Color = _cave_cell_tint(macro_origin)
	canvas.draw_rect(_tile_draw_rect(rect), backing)
	canvas.draw_texture_rect_region(cave_texture, rect, source_rect, tint)
	if _terrain_chunk_draw_lean:
		return
	_draw_wall_macro_overlay(canvas, macro_origin, rect)
	for offset_y: int in range(MATERIAL_MACRO_CELLS):
		for offset_x: int in range(MATERIAL_MACRO_CELLS):
			var cell := macro_origin + Vector2i(offset_x, offset_y)
			var cell_rect := Rect2(
				Vector2(cell.x * grid.tile_size, cell.y * grid.tile_size),
				Vector2(grid.tile_size, grid.tile_size)
			)
			_draw_rock_cell_overlays(canvas, cell, cell_rect)

func _draw_floor_cell(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	var material: Texture2D = _material_for_cell(cell)
	var source_rect: Rect2 = _floor_texture_region(material, cell, _material_salt(material))
	var backing: Color = _floor_backing_color_for_material(material) if _terrain_chunk_draw_lean else _backing_color_for_source(material, source_rect)
	var tint: Color = _floor_tint_for_material(material)
	canvas.draw_rect(_tile_draw_rect(rect), backing)
	if material != null:
		canvas.draw_texture_rect_region(material, rect, source_rect, Color(tint, 1.0))
	if _terrain_chunk_draw_lean:
		return
	_draw_floor_formation_overlay(canvas, cell, rect, material)
	_draw_floor_cell_overlays(canvas, cell, rect, material)

func _draw_floor_formation_overlay(canvas: CanvasItem, cell: Vector2i, rect: Rect2, material: Texture2D) -> void:
	var region = grid.region_for_cell(cell)
	var formations: Dictionary = _chunk_formations_cache if not _chunk_formations_cache.is_empty() else _visual_formations_for_region(region)
	var macro_origin := _macro_block_origin(cell)
	if not formations.has(macro_origin):
		return
	var record: Dictionary = formations[macro_origin]
	var material_id := _visual_material_id_for_texture(material)
	if int(record["material_id"]) != material_id:
		return
	var formation_texture: Texture2D = formation_materials.get(material_id)
	if formation_texture == null:
		return
	var atlas_index := int(record["atlas_index"])
	var macro_cols := maxi(1, formation_texture.get_width() / MATERIAL_MACRO_SIZE)
	var variant_x := atlas_index % macro_cols
	var variant_y := atlas_index / macro_cols
	var sub_x := posmod(cell.x, MATERIAL_MACRO_CELLS)
	var sub_y := posmod(cell.y, MATERIAL_MACRO_CELLS)
	var source_rect := Rect2(
		Vector2(
			variant_x * MATERIAL_MACRO_SIZE + sub_x * MATERIAL_SUBPATCH_SIZE,
			variant_y * MATERIAL_MACRO_SIZE + sub_y * MATERIAL_SUBPATCH_SIZE
		),
		Vector2(MATERIAL_SUBPATCH_SIZE, MATERIAL_SUBPATCH_SIZE)
	)
	var tint := _floor_tint_for_material(material)
	canvas.draw_texture_rect_region(formation_texture, rect, source_rect, Color(tint, float(record["strength"])))

func _draw_floor_cell_overlays(canvas: CanvasItem, cell: Vector2i, rect: Rect2, material: Texture2D = null) -> void:
	if material == null:
		material = _material_for_cell(cell)
	if material == bunker_material:
		if (cell.x + cell.y * 3) % 13 == 0:
			canvas.draw_circle(rect.position + Vector2(3, 3), 1.0, Color("82969a"))
	elif material == hive_material:
		if (cell.x * 5 + cell.y * 11) % 17 == 0:
			canvas.draw_circle(rect.position + Vector2(8, 8), 6.0, Color(0.38, 0.68, 0.16, 0.06))
			canvas.draw_circle(rect.position + Vector2(8, 8), 1.2, Color("a9eb55"))
	elif material == crystal_material:
		if (cell.x * 3 + cell.y * 5) % 17 == 0:
			canvas.draw_circle(rect.position + Vector2(8, 8), 1.0, Color("7ec4d8"))
	elif material == sulfur_material:
		if (cell.x * 2 + cell.y * 7) % 13 == 0:
			canvas.draw_circle(rect.position + Vector2(8, 8), 2.0, Color(0.62, 0.78, 0.18, 0.12))
	else:
		if (cell.x * 7 + cell.y * 11) % 19 == 0:
			canvas.draw_rect(Rect2(rect.position + Vector2(4, 6), Vector2(4, 1)), Color(0.62, 0.52, 0.42, 0.34))
		if (cell.x * 5 + cell.y * 13) % 29 == 0:
			canvas.draw_circle(rect.position + Vector2(11, 4), 1.0, Color("9a8268"))

func _draw_rock_cell(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	var tint := _cave_cell_tint(cell)
	if placeable_blocks != null and placeable_blocks.has_placed(cell):
		var biome_id = placeable_blocks.biome_at(cell, host._biome_for_cell(cell))
		var floor_tex := _floor_material_for_biome(biome_id)
		if floor_tex != null:
			var source_rect: Rect2 = _macro_texture_region(floor_tex, cell, 41)
			canvas.draw_texture_rect_region(floor_tex, rect, source_rect, Color(0.55, 0.58, 0.62, 1.0))
			tint = Color(0.75, 0.78, 0.82, 1.0)
	if cave_texture != null:
		var source_rect2: Rect2 = _macro_texture_region(cave_texture, cell, 41)
		var backing: Color = material_backing_colors.get(cave_texture, Color("121820")) if _terrain_chunk_draw_lean else _backing_color_for_source(cave_texture, source_rect2)
		if not (placeable_blocks != null and placeable_blocks.has_placed(cell)):
			canvas.draw_rect(_tile_draw_rect(rect), backing)
		canvas.draw_texture_rect_region(cave_texture, rect, source_rect2, tint)
	if _terrain_chunk_draw_lean:
		var mineral_type: String = grid.get_mineral_type(cell)
		if not mineral_type.is_empty() and _has_floor_neighbor(cell) and not grid.is_mineral_concealed(cell):
			_draw_mineral_seam(canvas, rect, mineral_type)
		return
	_draw_wall_cell_overlay(canvas, cell, rect)
	_draw_rock_cell_overlays(canvas, cell, rect)

func _dominant_wall_material_id(counts: Dictionary, salt_cell: Vector2i) -> int:
	var best_material := -1
	var best_count := -1
	var best_tie := -1
	for material_value: Variant in counts.keys():
		var material_id := int(material_value)
		var count := int(counts[material_id])
		var tie := posmod(RealmVisualStyleScript.stable_cell_hash(grid.realm_seed, salt_cell, 1601 + material_id), 1000)
		if count > best_count or (count == best_count and tie > best_tie):
			best_material = material_id
			best_count = count
			best_tie = tie
	return best_material

func _wall_material_id_for_cell(cell: Vector2i) -> int:
	var counts: Dictionary = {}
	for direction: Vector2i in FlowFieldScript.DIRECTIONS:
		var neighbor := cell + direction
		if not grid.in_bounds(neighbor) or not grid.is_walkable(neighbor):
			continue
		var material_id := _visual_material_id(neighbor)
		counts[material_id] = int(counts.get(material_id, 0)) + 1
	return _dominant_wall_material_id(counts, cell)

func _wall_material_id_for_macro(macro_origin: Vector2i) -> int:
	var counts: Dictionary = {}
	for offset_y: int in range(MATERIAL_MACRO_CELLS):
		for offset_x: int in range(MATERIAL_MACRO_CELLS):
			var cell := macro_origin + Vector2i(offset_x, offset_y)
			for direction: Vector2i in FlowFieldScript.DIRECTIONS:
				var neighbor := cell + direction
				if not grid.in_bounds(neighbor) or not grid.is_walkable(neighbor):
					continue
				var material_id := _visual_material_id(neighbor)
				counts[material_id] = int(counts.get(material_id, 0)) + 1
	return _dominant_wall_material_id(counts, macro_origin)

func _wall_macro_source_rect(texture: Texture2D, macro_origin: Vector2i, material_id: int) -> Rect2:
	var atlas_index := RealmVisualStyleScript.wall_atlas_index(grid.realm_seed, macro_origin, material_id)
	var macro_cols := maxi(1, texture.get_width() / MATERIAL_MACRO_SIZE)
	return Rect2(
		Vector2((atlas_index % macro_cols) * MATERIAL_MACRO_SIZE, (atlas_index / macro_cols) * MATERIAL_MACRO_SIZE),
		Vector2(MATERIAL_MACRO_SIZE, MATERIAL_MACRO_SIZE)
	)

func _draw_wall_macro_overlay(canvas: CanvasItem, macro_origin: Vector2i, rect: Rect2) -> void:
	var material_id := _wall_material_id_for_macro(macro_origin)
	if material_id < 0:
		return
	var texture: Texture2D = formation_materials.get(material_id)
	if texture == null:
		return
	var source_rect := _wall_macro_source_rect(texture, macro_origin, material_id)
	var material := _floor_material_for_biome(material_id)
	canvas.draw_texture_rect_region(texture, rect, source_rect, Color(_floor_tint_for_material(material), 0.34))

func _draw_wall_cell_overlay(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	var material_id := _wall_material_id_for_cell(cell)
	if material_id < 0:
		return
	var texture: Texture2D = formation_materials.get(material_id)
	if texture == null:
		return
	var macro_origin := _macro_block_origin(cell)
	var source_rect := _wall_macro_source_rect(texture, macro_origin, material_id)
	source_rect = Rect2(
		source_rect.position + Vector2(
			posmod(cell.x, MATERIAL_MACRO_CELLS) * MATERIAL_SUBPATCH_SIZE,
			posmod(cell.y, MATERIAL_MACRO_CELLS) * MATERIAL_SUBPATCH_SIZE
		),
		Vector2(MATERIAL_SUBPATCH_SIZE, MATERIAL_SUBPATCH_SIZE)
	)
	var material := _floor_material_for_biome(material_id)
	canvas.draw_texture_rect_region(texture, rect, source_rect, Color(_floor_tint_for_material(material), 0.34))

func _draw_rock_cell_overlays(canvas: CanvasItem, cell: Vector2i, rect: Rect2) -> void:
	if _has_floor_neighbor(cell) and (cell.x * 11 + cell.y * 17) % 31 == 0:
		var fungus_color := Color("56d96e") if (cell.x + cell.y) % 2 == 0 else Color("55d8e8")
		canvas.draw_circle(rect.position + Vector2(7, 9), 4.5, Color(fungus_color, 0.12))
		canvas.draw_circle(rect.position + Vector2(7, 9), 1.2, fungus_color)
	if (cell.x * 3 + cell.y * 5) % 23 == 0:
		match posmod(cell.x + cell.y, 4):
			0:
				canvas.draw_circle(rect.position + Vector2(5, 11), 1.5, Color("c48a5a"))
			1:
				canvas.draw_circle(rect.position + Vector2(10, 6), 1.2, Color("7a9cb8"))
			2:
				canvas.draw_rect(Rect2(rect.position + Vector2(3, 8), Vector2(3, 2)), Color("b8926a"))
			_:
				canvas.draw_circle(rect.position + Vector2(8, 12), 1.0, Color("8f7a62"))
	var mineral_type: String = grid.get_mineral_type(cell)
	if not mineral_type.is_empty() and _has_floor_neighbor(cell):
		if grid.is_mineral_concealed(cell):
			# Buried ore often leaves a generic fracture once exposed, without
			# revealing its material. Supply caches retain the true surprise rule.
			if mineral_type != WorldGridScript.MINERAL_CACHE and posmod(cell.x * 5 + cell.y * 13 + grid.realm_seed, 3) != 0:
				_draw_geology_tell(canvas, rect, cell)
		else:
			_draw_mineral_seam(canvas, rect, mineral_type)

func _floor_base_color_for_material(material: Texture2D) -> Color:
	if material == hive_material:
		return Color("17121e")
	if material == bunker_material:
		return Color("101c21")
	if material == crystal_material:
		return Color("121820")
	if material == foundry_material:
		return Color("151311")
	if material == sulfur_material:
		return Color("12160c")
	if material == iron_material:
		return Color("121316")
	return Color("172126")

func _floor_tint_for_material(material: Texture2D) -> Color:
	if material == hive_material:
		return Color(0.9, 0.8, 0.88)
	if material == bunker_material:
		return Color(0.9, 0.84, 0.78)
	if material == crystal_material:
		return Color(0.78, 0.88, 0.92)
	if material == foundry_material:
		return Color(0.88, 0.8, 0.72)
	if material == sulfur_material:
		return Color(0.9, 0.92, 0.62)
	if material == iron_material:
		return Color(0.86, 0.84, 0.88)
	return Color(0.92, 0.86, 0.78)

func _cave_cell_tint(origin: Vector2i) -> Color:
	match posmod(origin.x * 17 + origin.y * 31, 6):
		0:
			return Color(1.0, 0.98, 0.94)
		1:
			return Color(0.96, 0.99, 1.0)
		2:
			return Color(1.0, 0.95, 0.9)
		3:
			return Color(0.94, 0.98, 0.96)
		4:
			return Color(1.0, 0.97, 0.92)
		_:
			return Color(0.97, 0.99, 1.0)

func _cave_backing_color_for_cell(cell: Vector2i) -> Color:
	for direction: Vector2i in FlowFieldScript.DIRECTIONS:
		var neighbor := cell + direction
		if grid.in_bounds(neighbor) and grid.is_walkable(neighbor):
			var material: Texture2D = _material_for_cell(neighbor)
			var source_rect: Rect2 = _floor_texture_region(material, neighbor, _material_salt(material))
			return _backing_color_for_source(material, source_rect)
	if cave_texture != null:
		var fallback_rect: Rect2 = _macro_texture_region(cave_texture, cell, 41)
		return _backing_color_for_source(cave_texture, fallback_rect)
	return Color("121820")

func _material_salt(material: Texture2D) -> int:
	if material == hive_material:
		return 17
	if material == bunker_material:
		return 73
	if material == crystal_material:
		return 91
	if material == foundry_material:
		return 107
	if material == sulfur_material:
		return 119
	if material == iron_material:
		return 131
	return 43

func _tile_texture_region(texture: Texture2D, cell: Vector2i, salt: int, patch_size: int = -1) -> Rect2:
	if texture == null:
		return Rect2(Vector2.ZERO, Vector2(grid.tile_size, grid.tile_size))
	if patch_size < 0:
		patch_size = grid.tile_size
	var patch_columns := maxi(1, texture.get_width() / patch_size)
	var patch_rows := maxi(1, texture.get_height() / patch_size)
	var variant_x := posmod(cell.x + salt, patch_columns)
	var variant_y := posmod(cell.y + salt * 3, patch_rows)
	return Rect2(Vector2(variant_x * patch_size, variant_y * patch_size), Vector2(patch_size, patch_size))

func _floor_texture_region(texture: Texture2D, cell: Vector2i, salt: int) -> Rect2:
	return _macro_texture_region(texture, cell, salt)

func _macro_variant_index(texture: Texture2D, macro_cell: Vector2i, salt: int) -> int:
	if texture == null:
		return 0
	if texture != cave_texture:
		return RealmVisualStyleScript.base_atlas_index(
			grid.realm_seed,
			macro_cell,
			_visual_material_id_for_texture(texture),
			salt
		)
	var macro_cols := CAVE_ATLAS_COLUMNS
	var macro_rows := CAVE_ATLAS_ROWS
	var variant_count := maxi(1, macro_cols * macro_rows)
	return posmod(RealmVisualStyleScript.stable_cell_hash(grid.realm_seed, macro_cell, salt), variant_count)

func _macro_block_texture_region(texture: Texture2D, macro_cell: Vector2i, salt: int) -> Rect2:
	if texture == null:
		return Rect2(Vector2.ZERO, Vector2(MATERIAL_MACRO_SIZE, MATERIAL_MACRO_SIZE))
	var macro_cols := CAVE_ATLAS_COLUMNS if texture == cave_texture else maxi(1, texture.get_width() / MATERIAL_MACRO_SIZE)
	var variant_index := _macro_variant_index(texture, macro_cell, salt)
	var variant_x := variant_index % macro_cols
	var variant_y := variant_index / macro_cols
	return Rect2(
		Vector2(variant_x * MATERIAL_MACRO_SIZE, variant_y * MATERIAL_MACRO_SIZE),
		Vector2(MATERIAL_MACRO_SIZE, MATERIAL_MACRO_SIZE)
	)

func _macro_texture_region(texture: Texture2D, cell: Vector2i, salt: int) -> Rect2:
	if texture == null:
		return Rect2(Vector2.ZERO, Vector2(MATERIAL_SUBPATCH_SIZE, MATERIAL_SUBPATCH_SIZE))
	var macro_cell := _macro_block_origin(cell)
	var sub_x := posmod(cell.x, MATERIAL_MACRO_CELLS)
	var sub_y := posmod(cell.y, MATERIAL_MACRO_CELLS)
	var macro_region := _macro_block_texture_region(texture, macro_cell, salt)
	return Rect2(
		macro_region.position + Vector2(sub_x * MATERIAL_SUBPATCH_SIZE, sub_y * MATERIAL_SUBPATCH_SIZE),
		Vector2(MATERIAL_SUBPATCH_SIZE, MATERIAL_SUBPATCH_SIZE)
	)

func _material_for_cell(cell: Vector2i) -> Texture2D:
	if maxi(absi(cell.x - grid.core_cell.x), absi(cell.y - grid.core_cell.y)) <= 4:
		return bunker_material
	if maxi(absi(cell.x - grid.spawn_cell.x), absi(cell.y - grid.spawn_cell.y)) <= 4:
		return hive_material
	if _terrain_chunk_draw_lean:
		# Boundary contamination is visual refinement, not active simulation. On the
		# lean path use the deterministic region material directly instead of running
		# four-neighbor biome blending for hundreds of cells during first visibility.
		return _floor_material_for_biome(grid.region_biome(grid.region_for_cell(cell)))
	if _cell_uses_discovery_hive_material(cell):
		return hive_material
	return _floor_material_for_biome(_visual_biome_for_cell(cell))

func _visual_biome_for_cell(cell: Vector2i) -> int:
	var region = grid.region_for_cell(cell)
	var region_cache: Dictionary = visual_biome_cache.get(region, {})
	if region_cache.has(cell):
		return int(region_cache[cell])
	var current_biome = grid.region_biome(region)
	var region_start = region * WorldGridScript.REGION_SIZE
	var local = cell - region_start
	var best_biome = current_biome
	var best_score := -1
	for side_index: int in range(VISUAL_BOUNDARY_DIRECTIONS.size()):
		var direction: Vector2i = VISUAL_BOUNDARY_DIRECTIONS[side_index]
		var neighbor_region = region + direction
		var neighbor_biome = grid.region_biome(neighbor_region)
		if neighbor_biome == current_biome:
			continue
		var distance_to_border := 99
		var boundary_cell := cell
		var crossed := false
		var displacement := 0
		if direction == Vector2i.LEFT:
			distance_to_border = local.x
			boundary_cell = Vector2i(region_start.x, cell.y)
			displacement = RealmVisualStyleScript.boundary_displacement(grid.realm_seed, boundary_cell, true)
			crossed = cell.x < boundary_cell.x + displacement
		elif direction == Vector2i.RIGHT:
			distance_to_border = WorldGridScript.REGION_SIZE - 1 - local.x
			boundary_cell = Vector2i(region_start.x + WorldGridScript.REGION_SIZE, cell.y)
			displacement = RealmVisualStyleScript.boundary_displacement(grid.realm_seed, boundary_cell, true)
			crossed = cell.x >= boundary_cell.x + displacement
		elif direction == Vector2i.UP:
			distance_to_border = local.y
			boundary_cell = Vector2i(cell.x, region_start.y)
			displacement = RealmVisualStyleScript.boundary_displacement(grid.realm_seed, boundary_cell, false)
			crossed = cell.y < boundary_cell.y + displacement
		else:
			distance_to_border = WorldGridScript.REGION_SIZE - 1 - local.y
			boundary_cell = Vector2i(cell.x, region_start.y + WorldGridScript.REGION_SIZE)
			displacement = RealmVisualStyleScript.boundary_displacement(grid.realm_seed, boundary_cell, false)
			crossed = cell.y >= boundary_cell.y + displacement
		var contaminated := RealmVisualStyleScript.boundary_contamination(
			grid.realm_seed,
			cell,
			current_biome,
			neighbor_biome,
			distance_to_border
		)
		if not crossed and not contaminated:
			continue
		var score := (100 if crossed else 10) + maxi(0, 3 - distance_to_border) * 2
		score += posmod(RealmVisualStyleScript.stable_cell_hash(grid.realm_seed, cell, 1501 + side_index), 2)
		if score > best_score:
			best_score = score
			best_biome = neighbor_biome
	region_cache[cell] = best_biome
	visual_biome_cache[region] = region_cache
	return best_biome

func _cell_uses_discovery_hive_material(cell: Vector2i) -> bool:
	if discovery_hive_cells.has(cell):
		return bool(discovery_hive_cells[cell])
	for center_value: Variant in grid.revealed_discoveries.keys():
		var center: Vector2i = center_value
		if maxi(absi(cell.x - center.x), absi(cell.y - center.y)) <= 2:
			_mark_discovery_revealed(center)
			return true
	discovery_hive_cells[cell] = false
	return false

func _floor_material_for_region(region: Vector2i) -> Texture2D:
	if region_floor_materials.has(region):
		return region_floor_materials[region]
	var material := _floor_material_for_biome(grid.region_biome(region))
	region_floor_materials[region] = material
	return material

func _floor_material_for_biome(biome_id: int) -> Texture2D:
	var material: Texture2D = tunnel_material
	match biome_id:
		grid.BIOME_HIVE:
			material = hive_material
		grid.BIOME_SULFUR:
			material = sulfur_material
		grid.BIOME_BUNKER:
			material = bunker_material
		grid.BIOME_FOUNDRY:
			material = foundry_material
		grid.BIOME_IRON:
			material = iron_material
		grid.BIOME_CRYSTAL:
			material = crystal_material
	return material

func _mark_discovery_revealed(center: Vector2i) -> void:
	for y_offset in range(-2, 3):
		for x_offset in range(-2, 3):
			var painted := center + Vector2i(x_offset, y_offset)
			if grid.in_bounds(painted):
				discovery_hive_cells[painted] = true

func _rebuild_discovery_hive_cells() -> void:
	discovery_hive_cells.clear()
	for center_value: Variant in grid.revealed_discoveries.keys():
		_mark_discovery_revealed(center_value)

func _reset_render_caches(clear_minimap: bool) -> void:
	visual_prop_cache.clear()
	visual_formation_cache.clear()
	visual_landmark_cache.clear()
	visual_biome_cache.clear()
	region_floor_materials.clear()
	terrain_chunk_committed.clear()
	for region_value: Variant in terrain_chunk_layers.keys():
		terrain_chunk_redraw_queue[region_value] = true
	_rebuild_discovery_hive_cells()
	if clear_minimap:
		minimap_cache_texture = null
		minimap_cache_image = null
		minimap_patch_pending = false
		minimap_cache_dirty = true
		minimap_rebuild_cooldown = 0.0

func _has_floor_neighbor(cell: Vector2i) -> bool:
	for direction: Vector2i in FlowFieldScript.DIRECTIONS:
		if grid.is_walkable(cell + direction):
			return true
	return false

func _draw_wall_edges(canvas: CanvasItem) -> void:
	var bounds: Rect2i = _visible_cell_bounds(3)
	_draw_wall_edges_in_bounds(canvas, bounds)

func _draw_wall_edges_in_bounds(canvas: CanvasItem, bounds: Rect2i) -> void:
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var cell := Vector2i(x, y)
			if not grid.in_bounds(cell):
				continue
			if grid.is_walkable(cell):
				continue
			if grid.get_cell(cell) == WorldGridScript.BEDROCK:
				continue
			# Cardinal adjacency is both the draw condition and the edge data. The old
			# code first scanned all eight flow directions, then queried these four again.
			var floor_down = grid.is_walkable(cell + Vector2i.DOWN)
			var floor_up = grid.is_walkable(cell + Vector2i.UP)
			var floor_right = grid.is_walkable(cell + Vector2i.RIGHT)
			var floor_left = grid.is_walkable(cell + Vector2i.LEFT)
			if not (floor_down or floor_up or floor_right or floor_left):
				continue
			var top_left := Vector2(x * grid.tile_size, y * grid.tile_size)
			var tile_size = grid.tile_size
			# Full refinement blends wall lips from surrounding floor materials. Active
			# lean rendering uses the cell's regional material and avoids another eight
			# neighbor/material queries per exposed wall cell.
			var material_id := _visual_material_id(cell) if _terrain_chunk_draw_lean else _wall_material_id_for_cell(cell)
			var lip := RealmVisualStyleScript.wall_edge_color(material_id)
			var lip_soft := Color(lip, 0.28)
			if floor_down:
				canvas.draw_rect(Rect2(top_left + Vector2(0, tile_size - 2), Vector2(tile_size, 2)), Color(lip, 0.42))
			if floor_up:
				canvas.draw_rect(Rect2(top_left, Vector2(tile_size, 2)), lip_soft)
			if floor_right:
				canvas.draw_rect(Rect2(top_left + Vector2(tile_size - 2, 0), Vector2(2, tile_size)), lip_soft)
			if floor_left:
				canvas.draw_rect(Rect2(top_left, Vector2(2, tile_size)), lip_soft)

			var floor_side_count := int(floor_up) + int(floor_right) + int(floor_down) + int(floor_left)
			if floor_side_count == 1:
				# A single exposed face gets a restrained inset shadow so it reads as a wall, not a floor stripe.
				if floor_down:
					canvas.draw_line(top_left + Vector2(3, tile_size - 4), top_left + Vector2(tile_size - 3, tile_size - 4), Color(lip, 0.18), 1.0)
				elif floor_up:
					canvas.draw_line(top_left + Vector2(3, 3), top_left + Vector2(tile_size - 3, 3), Color(lip, 0.15), 1.0)
				elif floor_right:
					canvas.draw_line(top_left + Vector2(tile_size - 4, 3), top_left + Vector2(tile_size - 4, tile_size - 3), Color(lip, 0.15), 1.0)
				else:
					canvas.draw_line(top_left + Vector2(3, 3), top_left + Vector2(3, tile_size - 3), Color(lip, 0.15), 1.0)
			elif floor_side_count == 2:
				if floor_up and floor_down:
					canvas.draw_line(top_left + Vector2(tile_size * 0.5, 3), top_left + Vector2(tile_size * 0.5, tile_size - 3), Color(lip, 0.32), 1.0)
				elif floor_left and floor_right:
					canvas.draw_line(top_left + Vector2(3, tile_size * 0.5), top_left + Vector2(tile_size - 3, tile_size * 0.5), Color(lip, 0.32), 1.0)
				else:
					var corner := Vector2.ZERO
					if floor_up and floor_right:
						corner = Vector2(tile_size - 3, 0)
					elif floor_right and floor_down:
						corner = Vector2(tile_size - 3, tile_size - 3)
					elif floor_down and floor_left:
						corner = Vector2(0, tile_size - 3)
					canvas.draw_rect(Rect2(top_left + corner, Vector2(3, 3)), Color(lip, 0.46))
			elif floor_side_count >= 3:
				# Three/four exposed sides are isolated wall pillars or tight connectors.
				var center_rect := Rect2(top_left + Vector2.ONE * (tile_size * 0.5 - 2.0), Vector2(4, 4))
				canvas.draw_rect(center_rect, Color(lip, 0.16))
				canvas.draw_rect(center_rect, Color(lip, 0.46), false, 1.0)

func _draw_environment_props(canvas: CanvasItem) -> void:
	_draw_region_visual_props(canvas)
	# Discovery scars are gameplay state, so they remain explicit. All decorative
	# lamps, crates, webs, veins, and grates now come from biome formations and
	# rare landmark compositions rather than fixed world-coordinate lists.
	for center_value: Variant in grid.revealed_discoveries.keys():
		var center: Vector2i = center_value
		_draw_discovery_scar(canvas, center, str(grid.revealed_discoveries[center]))

func _draw_discovery_scars_in_region(canvas: CanvasItem, region: Vector2i) -> void:
	for center_value: Variant in grid.revealed_discoveries.keys():
		var center: Vector2i = center_value
		if grid.region_for_cell(center) != region:
			continue
		_draw_discovery_scar(canvas, center, str(grid.revealed_discoveries[center]))

func _draw_discovery_scar(canvas: CanvasItem, center: Vector2i, discovery_kind: String) -> void:
	var center_position: Vector2 = grid.cell_to_world(center)
	var scar_color: Color = Color("a7e64e") if discovery_kind != "guardian" else Color("d36be8")
	canvas.draw_circle(center_position, 13.0 if discovery_kind == "guardian" else 9.0, Color(scar_color, 0.09))
	canvas.draw_arc(center_position, 8.0, 0.0, TAU, 12, Color(scar_color, 0.62), 1.0)
	for egg_index in range(5 if discovery_kind == "guardian" else 3):
		var egg_position: Vector2 = center_position + Vector2.from_angle(float(egg_index) * TAU / 5.0) * 6.0
		canvas.draw_circle(egg_position, 1.6, scar_color)

func _draw_region_visual_props(canvas: CanvasItem) -> void:
	var visible_bounds := _visible_cell_bounds(1)
	for region_value: Variant in grid.loaded_regions.keys():
		var region: Vector2i = region_value
		_draw_region_visual_props_in_bounds(canvas, region, visible_bounds)

func _draw_region_visual_props_in_bounds(canvas: CanvasItem, region: Vector2i, bounds: Rect2i) -> void:
	for prop_value: Variant in _visual_props_for_region(region):
		var prop: Dictionary = prop_value
		var cell: Vector2i = prop["cell"]
		if not bounds.has_point(cell):
			continue
		_draw_region_prop(canvas, cell, int(prop["kind"]), int(prop["variant"]), prop.get("offset", Vector2.ZERO))

func _visual_formations_for_region(region: Vector2i) -> Dictionary:
	if visual_formation_cache.has(region):
		return visual_formation_cache[region]
	if grid.region_readiness(region) < WorldGridScript.RegionReadiness.PREPARED:
		return {}
	var formations: Dictionary = {}
	var material_id = grid.region_biome(region)
	var formation_count := RealmVisualStyleScript.formation_count_for_region(grid.realm_seed, region, material_id)
	if formation_count <= 0:
		visual_formation_cache[region] = formations
		return formations
	var region_start: Vector2i = region * WorldGridScript.REGION_SIZE
	var candidates: Array = []
	for local_macro_y: int in [2, 6, 9]:
		for local_macro_x: int in [2, 6, 9]:
			var base_anchor := region_start + Vector2i(local_macro_x, local_macro_y) * MATERIAL_MACRO_CELLS
			var jitter_hash := RealmVisualStyleScript.stable_cell_hash(grid.realm_seed, base_anchor, 1009 + material_id * 43)
			var jitter := Vector2i(posmod(jitter_hash, 3) - 1, posmod(jitter_hash / 5, 3) - 1) * MATERIAL_MACRO_CELLS
			var anchor := _macro_block_origin(base_anchor + jitter)
			var field := RealmVisualStyleScript.formation_field(grid.realm_seed, anchor, material_id)
			var tie_break := float(posmod(jitter_hash, 100)) * 0.00001
			candidates.append({"anchor": anchor, "score": field + tie_break})
	for formation_index: int in range(mini(formation_count, candidates.size())):
		var best_candidate_index := 0
		for candidate_index: int in range(1, candidates.size()):
			if float(candidates[candidate_index]["score"]) > float(candidates[best_candidate_index]["score"]):
				best_candidate_index = candidate_index
		var candidate: Dictionary = candidates[best_candidate_index]
		candidates.remove_at(best_candidate_index)
		var anchor: Vector2i = candidate["anchor"]
		var field_score := clampf(float(candidate["score"]), 0.0, 1.0)
		var stamp_index := RealmVisualStyleScript.formation_stamp_index(grid.realm_seed, anchor, material_id)
		var stamp: Array = RealmVisualStyleScript.formation_stamp(stamp_index)
		for component_index: int in range(stamp.size()):
			var offset: Vector2i = stamp[component_index]
			var macro_origin := anchor + offset * MATERIAL_MACRO_CELLS
			if grid.region_for_cell(macro_origin) != region:
				continue
			if not _macro_block_is_complete_floor(macro_origin) or not _visual_prop_clear_of_landmark(macro_origin):
				continue
			var record := {
				"atlas_index": RealmVisualStyleScript.formation_atlas_index(grid.realm_seed, anchor, material_id, component_index),
				"material_id": material_id,
				"strength": 0.46 + field_score * 0.18,
				"score": field_score,
				"anchor": offset == Vector2i.ZERO,
				"stamp_index": stamp_index,
			}
			if not formations.has(macro_origin) or float(formations[macro_origin]["score"]) < field_score:
				formations[macro_origin] = record
	# Avoid sticky empty caches while streamed floors are still settling. Only
	# an authored zero-budget region may permanently cache an empty set.
	if not formations.is_empty() or formation_count <= 0:
		visual_formation_cache[region] = formations
	return formations

func _visual_landmarks_for_region(region: Vector2i) -> Array:
	if visual_landmark_cache.has(region):
		return visual_landmark_cache[region]
	if grid.region_readiness(region) < WorldGridScript.RegionReadiness.PREPARED:
		return []
	var material_id = grid.region_biome(region)
	var formation_count := RealmVisualStyleScript.formation_count_for_region(grid.realm_seed, region, material_id)
	var formations: Dictionary = _visual_formations_for_region(region)
	if formation_count > 0 and not visual_formation_cache.has(region):
		return []
	var landmarks: Array = []
	var target_count := RealmVisualStyleScript.landmark_count_for_region(grid.realm_seed, region, material_id)
	if target_count <= 0:
		visual_landmark_cache[region] = landmarks
		return landmarks
	var candidates: Array = []
	for macro_value: Variant in formations.keys():
		var macro_origin: Vector2i = macro_value
		var formation: Dictionary = formations[macro_origin]
		if not bool(formation["anchor"]):
			continue
		candidates.append({
			"anchor": macro_origin,
			"score": RealmVisualStyleScript.stable_cell_hash(grid.realm_seed, macro_origin, 1801 + material_id * 67),
		})
	var occupied_cells: Dictionary = {}
	for landmark_index: int in range(mini(target_count, candidates.size())):
		var selected_index := 0
		for candidate_index: int in range(1, candidates.size()):
			if int(candidates[candidate_index]["score"]) < int(candidates[selected_index]["score"]):
				selected_index = candidate_index
		var anchor: Vector2i = candidates[selected_index]["anchor"]
		candidates.remove_at(selected_index)
		var landmark_variant := RealmVisualStyleScript.landmark_variant(grid.realm_seed, anchor, material_id, landmark_index)
		var composition: Array = RealmVisualStyleScript.landmark_composition(material_id, landmark_variant)
		var proposed: Array = []
		var valid := true
		for component_index: int in range(composition.size()):
			var component: Dictionary = composition[component_index]
			var cell := anchor + Vector2i(component["cell_offset"])
			if grid.region_for_cell(cell) != region or not grid.is_walkable(cell) or not _visual_prop_clear_of_landmark(cell) or occupied_cells.has(cell):
				valid = false
				break
			proposed.append({
				"cell": cell,
				"kind": int(component["kind"]),
				"variant": posmod(RealmVisualStyleScript.prop_variant(grid.realm_seed, cell) + component_index, 4),
				"offset": Vector2.ONE * float(grid.tile_size) * 0.5 + Vector2(component["pixel_offset"]),
				"material_id": material_id,
				"landmark": true,
				"landmark_anchor": anchor,
			})
		if not valid:
			continue
		for record_value: Variant in proposed:
			var record: Dictionary = record_value
			occupied_cells[record["cell"]] = true
			landmarks.append(record)
	visual_landmark_cache[region] = landmarks
	return landmarks

func _visual_props_for_region(region: Vector2i) -> Array:
	if visual_prop_cache.has(region):
		return visual_prop_cache[region]
	if grid.region_readiness(region) < WorldGridScript.RegionReadiness.PREPARED:
		return []
	var material_id = grid.region_biome(region)
	var formation_count := RealmVisualStyleScript.formation_count_for_region(grid.realm_seed, region, material_id)
	var formations: Dictionary = _visual_formations_for_region(region)
	if formation_count > 0 and not visual_formation_cache.has(region):
		return []
	var landmarks: Array = _visual_landmarks_for_region(region)
	var props: Array = landmarks.duplicate(true)
	var landmark_cells: Dictionary = {}
	var landmark_anchors: Dictionary = {}
	for landmark_value: Variant in landmarks:
		var landmark: Dictionary = landmark_value
		landmark_cells[landmark["cell"]] = true
		landmark_anchors[landmark["landmark_anchor"]] = true
	var region_start: Vector2i = region * WorldGridScript.REGION_SIZE
	var region_end := region_start + Vector2i.ONE * WorldGridScript.REGION_SIZE
	for y in range(region_start.y, region_end.y):
		for x in range(region_start.x, region_end.x):
			var cell := Vector2i(x, y)
			if not grid.is_walkable(cell) or not _visual_prop_clear_of_landmark(cell) or landmark_cells.has(cell):
				continue
			if formations.has(_macro_block_origin(cell)):
				continue
			var near_wall := false
			for direction: Vector2i in FlowFieldScript.DIRECTIONS:
				if not grid.is_walkable(cell + direction):
					near_wall = true
					break
			var kind := RealmVisualStyleScript.decoration_for_cell(
				grid.realm_seed,
				cell,
				_visual_material_id(cell),
				near_wall,
				grid.region_biome(grid.region_for_cell(cell))
			)
			if kind != RealmVisualStyleScript.PROP_NONE:
				props.append({"cell": cell, "kind": kind, "variant": RealmVisualStyleScript.prop_variant(grid.realm_seed, cell), "material_id": _visual_material_id(cell)})
	for macro_value: Variant in formations.keys():
		var macro_origin: Vector2i = macro_value
		var formation: Dictionary = formations[macro_origin]
		if not bool(formation["anchor"]):
			continue
		if landmark_anchors.has(macro_origin):
			continue
		var prop_roll := posmod(RealmVisualStyleScript.stable_cell_hash(grid.realm_seed, macro_origin, 1103), 100)
		if prop_roll >= 72:
			continue
		var prop_material_id := int(formation["material_id"])
		var offset := Vector2.ONE * float(grid.tile_size) * 0.5
		offset += RealmVisualStyleScript.formation_prop_offset(grid.realm_seed, macro_origin, prop_material_id)
		props.append({
			"cell": macro_origin,
			"kind": RealmVisualStyleScript.formation_prop_kind(grid.realm_seed, macro_origin, prop_material_id),
			"variant": RealmVisualStyleScript.prop_variant(grid.realm_seed, macro_origin),
			"offset": offset,
			"material_id": prop_material_id,
		})
	visual_prop_cache[region] = props
	return props

func _visual_material_id(cell: Vector2i) -> int:
	return _visual_material_id_for_texture(_material_for_cell(cell))

func _visual_material_id_for_texture(material: Texture2D) -> int:
	if material == hive_material:
		return RealmVisualStyleScript.MATERIAL_HIVE
	if material == bunker_material:
		return RealmVisualStyleScript.MATERIAL_BUNKER
	if material == crystal_material:
		return RealmVisualStyleScript.MATERIAL_CRYSTAL
	if material == foundry_material:
		return RealmVisualStyleScript.MATERIAL_FOUNDRY
	if material == sulfur_material:
		return RealmVisualStyleScript.MATERIAL_SULFUR
	if material == iron_material:
		return RealmVisualStyleScript.MATERIAL_IRON
	return RealmVisualStyleScript.MATERIAL_TUNNEL

func _visual_prop_clear_of_landmark(cell: Vector2i) -> bool:
	for base_value: Variant in base_network.bases.values():
		var base_record: Dictionary = base_value
		var base_cell: Vector2i = base_record["cell"]
		if maxi(absi(cell.x - base_cell.x), absi(cell.y - base_cell.y)) <= 2:
			return false
	return true

func _draw_region_prop(canvas: CanvasItem, cell: Vector2i, kind: int, variant: int, draw_offset: Vector2 = Vector2.ZERO) -> void:
	var center = grid.cell_to_world(cell) + draw_offset
	match kind:
		RealmVisualStyleScript.PROP_LAMP:
			var lamp_texture: Texture2D = world_textures.get("lamp")
			if lamp_texture != null:
				canvas.draw_texture_rect(lamp_texture, Rect2(center - Vector2(4, 6), Vector2(8, 12)), false, Color.WHITE)
			else:
				canvas.draw_rect(Rect2(center + Vector2(-2, -5), Vector2(4, 7)), Color("4e4436"))
				canvas.draw_rect(Rect2(center + Vector2(-1, -4), Vector2(2, 3)), RealmVisualStyleScript.AMBER)
				canvas.draw_line(center + Vector2(-4, 3), center + Vector2(4, 3), Color("211c18"), 1.0)
		RealmVisualStyleScript.PROP_CRATE:
			var crate_texture: Texture2D = world_textures.get("crate")
			if crate_texture != null:
				canvas.draw_texture_rect(crate_texture, Rect2(center - Vector2(6, 6), Vector2(12, 12)), false, Color.WHITE)
			else:
				canvas.draw_rect(Rect2(center + Vector2(-5, -4), Vector2(10, 8)), Color("4b3b2b"))
				canvas.draw_rect(Rect2(center + Vector2(-5, -4), Vector2(10, 8)), Color("9c7546"), false, 1.0)
				canvas.draw_line(center + Vector2(-4, 2), center + Vector2(4, -2), Color("705437"), 1.0)
		RealmVisualStyleScript.PROP_RUBBLE:
			var rubble_texture: Texture2D = world_textures.get("rubble")
			if rubble_texture != null:
				canvas.draw_texture_rect(rubble_texture, Rect2(center - Vector2(7, 6), Vector2(14, 12)), false, Color.WHITE)
			else:
				for stone_index in range(3):
					var offset := Vector2(-4 + stone_index * 4, 2 - posmod(variant + stone_index, 3))
					canvas.draw_circle(center + offset, 1.0 + float(posmod(variant + stone_index, 2)), Color("596468"))
		RealmVisualStyleScript.PROP_WEB:
			var web_texture: Texture2D = world_textures.get("web")
			if web_texture != null:
				canvas.draw_texture_rect(web_texture, Rect2(center - Vector2(8, 8), Vector2(16, 16)), false, Color(1.0, 1.0, 1.0, 0.42))
			else:
				canvas.draw_line(center + Vector2(-6, -5), center + Vector2(6, 5), Color(0.78, 0.8, 0.72, 0.34), 1.0)
				canvas.draw_line(center + Vector2(5, -6), center + Vector2(-4, 5), Color(0.78, 0.8, 0.72, 0.25), 1.0)
				canvas.draw_line(center + Vector2(-5, 0), center + Vector2(5, 0), Color(0.78, 0.8, 0.72, 0.18), 1.0)
		RealmVisualStyleScript.PROP_EGGS:
			var eggs_texture: Texture2D = world_textures.get("eggs")
			if eggs_texture != null:
				canvas.draw_texture_rect(eggs_texture, Rect2(center - Vector2(8, 8), Vector2(16, 16)), false, Color.WHITE)
			else:
				canvas.draw_circle(center + Vector2(-3, 2), 2.2, Color("70624f"))
				canvas.draw_circle(center + Vector2(2, -1), 2.8, Color("8eaa43"))
				canvas.draw_circle(center + Vector2(2, -2), 0.9, Color("d7ed7d"))
		RealmVisualStyleScript.PROP_ACID:
			var acid_texture: Texture2D = world_textures.get("acid")
			if acid_texture != null:
				canvas.draw_texture_rect(acid_texture, Rect2(center - Vector2(8, 8), Vector2(16, 16)), false, Color(1.0, 1.0, 1.0, 0.72))
			else:
				canvas.draw_circle(center + Vector2(1, 2), 5.0, Color(0.31, 0.55, 0.08, 0.22))
				canvas.draw_circle(center + Vector2(-2, 1), 1.3, RealmVisualStyleScript.ACID)
		RealmVisualStyleScript.PROP_GRATE:
			var grate_texture: Texture2D = world_textures.get("grate")
			if grate_texture != null:
				canvas.draw_texture_rect(grate_texture, Rect2(center + Vector2(-6, -4), Vector2(12, 8)), false, Color.WHITE)
			else:
				canvas.draw_rect(Rect2(center + Vector2(-6, -4), Vector2(12, 8)), Color("0c1519"))
				for slit in range(3):
					canvas.draw_line(center + Vector2(-4 + slit * 4, -3), center + Vector2(-4 + slit * 4, 3), Color("52666a"), 1.0)
		RealmVisualStyleScript.PROP_CONDUIT:
			var conduit_color := RealmVisualStyleScript.CYAN if variant % 2 == 0 else RealmVisualStyleScript.AMBER
			var conduit_texture: Texture2D = world_textures.get("conduit")
			if conduit_texture != null:
				canvas.draw_texture_rect(conduit_texture, Rect2(center + Vector2(-8, -2), Vector2(16, 8)), false, Color.WHITE)
				canvas.draw_line(center + Vector2(-6, 2), center + Vector2(6, 2), Color(conduit_color, 0.52), 1.0)
			else:
				canvas.draw_line(center + Vector2(-7, 3), center + Vector2(7, 3), Color("17262b"), 3.0)
				canvas.draw_line(center + Vector2(-7, 2), center + Vector2(7, 2), Color(conduit_color, 0.58), 1.0)
		RealmVisualStyleScript.PROP_CRYSTAL_SHARD:
			var shard_texture: Texture2D = world_textures.get("crystal_shard")
			if shard_texture != null:
				canvas.draw_texture_rect(shard_texture, Rect2(center - Vector2(8, 8), Vector2(16, 16)), false, Color.WHITE)
			else:
				canvas.draw_polygon(PackedVector2Array([center + Vector2(0, -6), center + Vector2(4, 0), center + Vector2(0, 6), center + Vector2(-4, 0)]), [Color("9de9ff")])
		RealmVisualStyleScript.PROP_SULFUR_VENT:
			var vent_texture: Texture2D = world_textures.get("sulfur_vent")
			if vent_texture != null:
				canvas.draw_texture_rect(vent_texture, Rect2(center - Vector2(8, 8), Vector2(16, 16)), false, Color.WHITE)
			else:
				canvas.draw_circle(center + Vector2(0, 2), 4.0, Color(0.42, 0.52, 0.16, 0.35))
				canvas.draw_circle(center + Vector2(0, -2), 2.0, Color("b8e842"))
		RealmVisualStyleScript.PROP_SLAG_HEAP:
			var slag_texture: Texture2D = world_textures.get("slag_heap")
			if slag_texture != null:
				canvas.draw_texture_rect(slag_texture, Rect2(center - Vector2(8, 8), Vector2(16, 16)), false, Color.WHITE)
			else:
				canvas.draw_polygon(PackedVector2Array([center + Vector2(-5, 4), center + Vector2(0, -4), center + Vector2(5, 4)]), [Color("96502a")])

func _invalidate_visual_region(cell: Vector2i) -> void:
	var region = grid.region_for_cell(cell)
	# Hot-path mining/building keeps the existing decoration cache for the lean
	# redraw. The host invalidates/rebuilds it later during idle refinement.
	host._schedule_terrain_refine(region)
	host._mark_terrain_cell_dirty(cell)

func _mark_minimap_dirty(delay: float = MINIMAP_REBUILD_DELAY) -> void:
	minimap_cache_dirty = true
	minimap_rebuild_cooldown = delay

func _should_draw_terrain_cell(_cell: Vector2i) -> bool:
	return true

func _on_terrain_cell_opened(cell: Vector2i) -> void:
	# WorldGrid.terrain_cell_changed already queued the immediate mutation patch.
	# This hook owns gameplay consequences only; doing visual invalidation here too
	# scheduled every mined cell twice.
	host._mark_visual_dirty(8) # VIS_DIRTY_LIGHTING on CrawlBrawlRun
	var player_cell: Vector2i = grid.world_to_cell(player_position)
	if not enemies.is_empty() and maxi(absi(cell.x - player_cell.x), absi(cell.y - player_cell.y)) <= 28:
		player_flow_stale = true
	host._mark_flow_region_dirty(grid.region_for_cell(cell))
	if not enemies.is_empty():
		terrain_flow_dirty = true
		terrain_flow_rebuild_cooldown = maxf(terrain_flow_rebuild_cooldown, TERRAIN_FLOW_REBUILD_DELAY)
		_recent_mine_flow_tick = _combat_frame_tick
	if minimap_cache_image != null and grid.is_walkable(cell):
		_patch_minimap_cell(cell)
	elif minimap_cache_texture == null:
		_mark_minimap_dirty()

func _update_terrain_debounce(delta: float) -> void:
	if terrain_flow_rebuild_cooldown > 0.0:
		terrain_flow_rebuild_cooldown = maxf(0.0, terrain_flow_rebuild_cooldown - delta)
		if terrain_flow_rebuild_cooldown <= 0.0 and terrain_flow_dirty:
			# Mining owns the frame. The newly opened cell is already immediately usable
			# by collision/local routing; the regional terrain-flow rebuild can wait until
			# the cutter is released instead of landing 0.45s after each mined wall.
			if host._primary_break_held() or mining_beam_valid:
				terrain_flow_rebuild_cooldown = 0.12
			else:
				terrain_flow_dirty = false
				var routing_repair := bool(host.routing_flow_rebuild_pending)
				host.routing_flow_rebuild_pending = false
				# Mining redraws keep the small local rebuild. Mob no-flow repairs use a
				# route-aware regional corridor so the source region is connected to the
				# target instead of being an isolated island in the allowed-region set.
				host._rebuild_base_flows(false, false, not routing_repair, routing_repair)
				if routing_repair:
					host._routing_flow_repair_requests.clear()
	if minimap_rebuild_cooldown > 0.0:
		minimap_rebuild_cooldown = maxf(0.0, minimap_rebuild_cooldown - delta)
	if minimap_cache_dirty and minimap_rebuild_cooldown <= 0.0:
		_rebuild_minimap_cache()
	_flush_minimap_patches()

func _minimap_view_size() -> Vector2i:
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	return Vector2i(int(map_rect.size.x), int(map_rect.size.y))

func _minimap_view_origin_for(player_cell: Vector2i) -> Vector2i:
	return player_cell - _minimap_view_size() / 2

func _advance_minimap_view(new_origin: Vector2i) -> void:
	if new_origin == minimap_view_origin:
		return
	if minimap_cache_image == null:
		minimap_view_origin = new_origin
		_rebuild_minimap_cache()
		return
	var delta = new_origin - minimap_view_origin
	if absi(delta.x) <= 4 and absi(delta.y) <= 4:
		_scroll_minimap_cache(new_origin, delta)
	else:
		minimap_view_origin = new_origin
		_mark_minimap_dirty(0.0)

func _scroll_minimap_cache(new_origin: Vector2i, delta: Vector2i) -> void:
	var view_size := _minimap_view_size()
	var width := view_size.x
	var height := view_size.y
	var shifted := Image.create(width, height, false, Image.FORMAT_RGBA8)
	shifted.fill(Color("071116"))
	for y in range(height):
		for x in range(width):
			var source_x := x + delta.x
			var source_y := y + delta.y
			if source_x >= 0 and source_x < width and source_y >= 0 and source_y < height:
				shifted.set_pixel(x, y, minimap_cache_image.get_pixel(source_x, source_y))
	minimap_view_origin = new_origin
	var view_end := new_origin + view_size
	if delta.x > 0:
		var column_x := view_end.x - 1
		for y in range(new_origin.y, view_end.y):
			_write_minimap_world_cell(shifted, Vector2i(column_x, y))
	elif delta.x < 0:
		var column_x := new_origin.x
		for y in range(new_origin.y, view_end.y):
			_write_minimap_world_cell(shifted, Vector2i(column_x, y))
	if delta.y > 0:
		var row_y := view_end.y - 1
		for x in range(new_origin.x, view_end.x):
			_write_minimap_world_cell(shifted, Vector2i(x, row_y))
	elif delta.y < 0:
		var row_y := new_origin.y
		for x in range(new_origin.x, view_end.x):
			_write_minimap_world_cell(shifted, Vector2i(x, row_y))
	minimap_cache_image = shifted
	minimap_patch_pending = true
	minimap_cache_dirty = false

func _write_minimap_world_cell(image: Image, cell: Vector2i) -> void:
	if not _sector_is_explored(cell) or not grid.is_walkable(cell):
		return
	var pixel = cell - minimap_view_origin
	if pixel.x < 0 or pixel.y < 0 or pixel.x >= image.get_width() or pixel.y >= image.get_height():
		return
	image.set_pixel(pixel.x, pixel.y, _minimap_terrain_pixel_color(cell))

func _minimap_local_pixel(cell: Vector2i) -> Vector2i:
	var local = cell - minimap_view_origin
	var view_size := _minimap_view_size()
	if local.x < 0 or local.y < 0 or local.x >= view_size.x or local.y >= view_size.y:
		return Vector2i(-1, -1)
	return local

func _minimap_color_for_cell(cell: Vector2i) -> Color:
	match _visual_material_id(cell):
		RealmVisualStyleScript.MATERIAL_HIVE:
			return Color("55425c")
		RealmVisualStyleScript.MATERIAL_BUNKER:
			return Color("3e5c64")
		RealmVisualStyleScript.MATERIAL_CRYSTAL:
			return Color("3f6678")
		RealmVisualStyleScript.MATERIAL_FOUNDRY:
			return Color("5a4338")
		RealmVisualStyleScript.MATERIAL_SULFUR:
			return Color("56602a")
		RealmVisualStyleScript.MATERIAL_IRON:
			return Color("4a5058")
	return Color("38505a")

func _minimap_terrain_pixel_color(cell: Vector2i) -> Color:
	## Dim open floors, brighten wall-adjacent cells so rooms read as outlines.
	var base := _minimap_color_for_cell(cell)
	var touches_rock := false
	for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if not grid.is_walkable(cell + offset):
			touches_rock = true
			break
	if touches_rock:
		return Color(base.lightened(0.42), 1.0)
	return Color(base.darkened(0.28), 0.92)

func _patch_minimap_cell(cell: Vector2i) -> void:
	if minimap_cache_image == null:
		_rebuild_minimap_cache()
		if minimap_cache_image == null:
			return
	var pixel := _minimap_local_pixel(cell)
	if pixel.x < 0 or not grid.is_walkable(cell):
		return
	minimap_cache_image.set_pixel(pixel.x, pixel.y, _minimap_terrain_pixel_color(cell))
	minimap_patch_pending = true

func _patch_minimap_sector(sector: Vector2i) -> void:
	if minimap_cache_image == null:
		_mark_minimap_dirty()
		return
	var sector_start := sector * 12
	for y in range(sector_start.y, sector_start.y + 12):
		for x in range(sector_start.x, sector_start.x + 12):
			var map_cell := Vector2i(x, y)
			if not grid.is_walkable(map_cell):
				continue
			_patch_minimap_cell(map_cell)

func _patch_minimap_region(region: Vector2i) -> void:
	if minimap_cache_image == null:
		_mark_minimap_dirty()
		return
	var region_start: Vector2i = region * WorldGridScript.REGION_SIZE
	var region_end := region_start + Vector2i(WorldGridScript.REGION_SIZE, WorldGridScript.REGION_SIZE)
	for y in range(region_start.y, region_end.y):
		for x in range(region_start.x, region_end.x):
			var map_cell := Vector2i(x, y)
			if not _sector_is_explored(map_cell) or not grid.is_walkable(map_cell):
				continue
			_patch_minimap_cell(map_cell)

func _flush_minimap_patches() -> void:
	if not minimap_patch_pending or minimap_cache_texture == null or minimap_cache_image == null:
		return
	if (_combat_frame_tick - _minimap_flush_frame) < 2:
		return
	_minimap_flush_frame = _combat_frame_tick
	minimap_cache_texture.update(minimap_cache_image)
	minimap_patch_pending = false

func _invalidate_minimap() -> void:
	_mark_minimap_dirty(0.0)

func _sector_is_explored(cell: Vector2i) -> bool:
	var sector := Vector2i(floori(float(cell.x) / 12.0), floori(float(cell.y) / 12.0))
	return explored_sectors.has(sector)

func _rebuild_minimap_cache() -> void:
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	var cache_width := int(map_rect.size.x)
	var cache_height := int(map_rect.size.y)
	var player_cell = grid.world_to_cell(player_position)
	minimap_view_origin = _minimap_view_origin_for(player_cell)
	var view_end = minimap_view_origin + Vector2i(cache_width, cache_height)
	var image := Image.create(cache_width, cache_height, false, Image.FORMAT_RGBA8)
	image.fill(Color("071116"))
	for y in range(minimap_view_origin.y, view_end.y):
		for x in range(minimap_view_origin.x, view_end.x):
			var map_cell := Vector2i(x, y)
			if not _sector_is_explored(map_cell) or not grid.is_walkable(map_cell):
				continue
			var pixel := Vector2i(x - minimap_view_origin.x, y - minimap_view_origin.y)
			image.set_pixel(pixel.x, pixel.y, _minimap_terrain_pixel_color(map_cell))
	minimap_cache_image = image
	minimap_cache_texture = ImageTexture.create_from_image(image)
	minimap_patch_pending = false
	minimap_cache_dirty = false

func _minimap_position_for_cell(cell: Vector2i) -> Variant:
	var local := _minimap_local_pixel(cell)
	if local.x < 0:
		return null
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	return map_rect.position + Vector2(local) + Vector2(0.5, 0.5)

func _minimap_edge_marker_for_cell(cell: Vector2i) -> Vector2:
	var in_view = _minimap_position_for_cell(cell)
	if in_view != null:
		return in_view
	var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
	var center := map_rect.get_center()
	var player_cell = grid.world_to_cell(player_position)
	var delta := Vector2(cell - player_cell)
	if delta.length_squared() < 0.001:
		return center
	var dir := delta.normalized()
	var half := map_rect.size * 0.5 - Vector2(2.5, 2.5)
	var scale_x := half.x / absf(dir.x) if absf(dir.x) > 0.0001 else INF
	var scale_y := half.y / absf(dir.y) if absf(dir.y) > 0.0001 else INF
	return center + dir * minf(scale_x, scale_y)

func _draw_minimap_edge_tick(canvas: CanvasItem, position: Vector2, color: Color, toward: Vector2i) -> void:
	var player_cell = grid.world_to_cell(player_position)
	var dir := Vector2(toward - player_cell).normalized()
	if dir.length_squared() < 0.001:
		dir = Vector2.UP
	canvas.draw_line(position, position - dir * 3.0, color, 2.0)
	canvas.draw_circle(position, 1.5, color)

func _minimap_enemy_visible(spider) -> bool:
	var cell = grid.world_to_cell(spider.position)
	return grid.is_region_loaded(cell) or not base_network.powered_base_for(cell).is_empty() or host._torch_reveals_position(spider.position) or spider.is_brood_carrier or spider.cleanup_recalled

func _prune_visual_prop_cache() -> void:
	for region_value: Variant in visual_prop_cache.keys():
		if not grid.loaded_regions.has(region_value):
			visual_prop_cache.erase(region_value)
	for region_value: Variant in visual_formation_cache.keys():
		if not grid.loaded_regions.has(region_value):
			visual_formation_cache.erase(region_value)
	for region_value: Variant in visual_landmark_cache.keys():
		if not grid.loaded_regions.has(region_value):
			visual_landmark_cache.erase(region_value)
	for region_value: Variant in visual_biome_cache.keys():
		if not grid.loaded_regions.has(region_value):
			visual_biome_cache.erase(region_value)
	if _pending_visual_region_builds.is_empty():
		return
	var kept: Array[Vector2i] = []
	_pending_visual_region_set.clear()
	for region: Vector2i in _pending_visual_region_builds:
		if not grid.loaded_regions.has(region):
			continue
		kept.append(region)
		_pending_visual_region_set[region] = true
	_pending_visual_region_builds = kept

