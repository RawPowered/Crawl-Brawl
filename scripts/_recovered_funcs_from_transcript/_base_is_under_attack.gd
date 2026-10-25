func _base_is_under_attack(base_id: String) -> bool:
	_refresh_bases_under_attack_cache()
	return bool(_cached_bases_under_attack["bases"].get(base_id, false))
