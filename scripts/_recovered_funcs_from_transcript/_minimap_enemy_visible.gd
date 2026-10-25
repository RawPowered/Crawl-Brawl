func _minimap_enemy_visible(spider: Spider) -> bool:
	var cell := grid.world_to_cell(spider.position)
	return grid.is_region_loaded(cell) or not base_network.powered_base_for(cell).is_empty() or _torch_reveals_position(spider.position) or spider.hunts_turrets or spider.is_brood_carrier or spider.cleanup_recalled
