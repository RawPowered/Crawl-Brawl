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
