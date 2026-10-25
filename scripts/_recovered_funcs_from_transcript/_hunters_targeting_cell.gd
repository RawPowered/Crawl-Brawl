func _hunters_targeting_cell(cell: Vector2i) -> int:
	var count := 0
	for spider: Spider in enemies:
		if spider.hunts_turrets and spider.target_turret_cell == cell:
			count += 1
	return count
