func _fill_chest_material_list(list: GridContainer, source: Dictionary, from_pack: bool) -> void:
	for child in list.get_children():
		child.queue_free()
	for material_id: String in material_economy.RAW_ORDER:
		var amount := int(source.get(material_id, 0))
		if amount <= 0 and not from_pack:
			continue
		if amount <= 0:
			continue
		var chip := Label.new()
		chip.text = "%s %d" % [material_id.substr(0, mini(4, material_id.length())).to_upper(), amount]
		chip.custom_minimum_size = Vector2(50, 16)
		chip.add_theme_font_size_override("font_size", 7)
		chip.add_theme_color_override("font_color", Color("d5eceb"))
		list.add_child(chip)
