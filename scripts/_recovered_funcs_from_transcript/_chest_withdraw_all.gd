func _chest_withdraw_all() -> void:
	if using_chest_index < 0 or using_chest_index >= structures.size():
		return
	var chest: Structure = structures[using_chest_index]
	var moved := 0
	for material_id: String in chest.inventory.keys():
		var amount := int(chest.inventory.get(material_id, 0))
		if amount <= 0:
			continue
		material_economy.raw[material_id] = int(material_economy.raw.get(material_id, 0)) + amount
		moved += amount
	chest.inventory.clear()
	if moved > 0:
		_burst(chest.position, Color("ffd36b"), 8, 28.0)
		_save_run()
	_refresh_chest_panel()
