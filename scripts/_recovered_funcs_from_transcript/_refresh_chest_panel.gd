func _refresh_chest_panel() -> void:
	if using_chest_index < 0 or using_chest_index >= structures.size() or not is_instance_valid(chest_panel):
		return
	var chest: Structure = structures[using_chest_index]
	chest_status.text = "CAPACITY  %d/%d  //  PACK RAW %d" % [
		_chest_used(chest),
		chest.chest_capacity,
		material_economy.raw_total(),
	]
	_fill_chest_material_list(chest_player_list, material_economy.raw, true)
	_fill_chest_material_list(chest_vault_list, chest.inventory, false)
	var pack_has := material_economy.raw_total() > 0
	var vault_has := _chest_used(chest) > 0
	var vault_space := chest.chest_capacity - _chest_used(chest)
	chest_actions[0].disabled = not pack_has or vault_space <= 0
	chest_actions[1].disabled = not vault_has
