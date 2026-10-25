func _sector_is_explored(cell: Vector2i) -> bool:
	var sector := Vector2i(floori(float(cell.x) / 12.0), floori(float(cell.y) / 12.0))
	return explored_sectors.has(sector)
