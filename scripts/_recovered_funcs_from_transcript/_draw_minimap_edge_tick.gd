func _draw_minimap_edge_tick(canvas: CanvasItem, position: Vector2, color: Color, toward: Vector2i) -> void:
	var player_cell := grid.world_to_cell(player_position)
	var dir := Vector2(toward - player_cell).normalized()
	if dir.length_squared() < 0.001:
		dir = Vector2.UP
	canvas.draw_line(position, position - dir * 3.0, color, 2.0)
	canvas.draw_circle(position, 1.5, color)
