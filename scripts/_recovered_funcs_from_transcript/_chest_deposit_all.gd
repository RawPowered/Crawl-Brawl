func _chest_deposit_all() -> void:
	if using_chest_index < 0:
		return
	_chest_auto_dump(using_chest_index)
	_refresh_chest_panel()
