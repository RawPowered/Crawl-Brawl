func _close_chest() -> void:
	using_chest_index = -1
	if is_instance_valid(chest_panel):
		chest_panel.visible = false
