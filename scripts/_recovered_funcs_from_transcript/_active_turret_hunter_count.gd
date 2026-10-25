func _active_turret_hunter_count() -> int:
	var count := 0
	for spider: Spider in enemies:
		if spider.hunts_turrets and spider.target_turret_cell.x >= 0:
			count += 1
	return count
