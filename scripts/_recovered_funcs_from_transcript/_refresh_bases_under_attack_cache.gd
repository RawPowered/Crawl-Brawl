func _refresh_bases_under_attack_cache() -> void:
	if _cached_bases_under_attack_tick == _combat_frame_tick:
		return
	var count := 0
	var attacked: Dictionary = {}
	for base_id: String in base_network.active_ids():
		if _enemies_near_base(base_id, 96.0):
			count += 1
			attacked[base_id] = true
	_cached_bases_under_attack = {"count": count, "bases": attacked}
	_cached_bases_under_attack_tick = _combat_frame_tick
