func _open_chest(structure_index: int) -> void:
	if structure_index < 0 or structure_index >= structures.size():
		return
	var chest: Structure = structures[structure_index]
	if chest.kind not in [BUILD_CHEST_SMALL, BUILD_CHEST_MEDIUM, BUILD_CHEST_LARGE]:
		return
	using_chest_index = structure_index
	using_core_base = false
	using_foundry = false
	build_mode = false
	chest_title.text = "FIELD VAULT // %s" % str(BUILD_STOCK_KEYS.get(chest.kind, "chest")).to_upper()
	chest_panel.visible = true
	_refresh_chest_panel()
