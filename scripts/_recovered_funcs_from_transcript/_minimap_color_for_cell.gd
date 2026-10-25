func _minimap_color_for_cell(cell: Vector2i) -> Color:
	match _visual_material_id(cell):
		RealmVisualStyleScript.MATERIAL_HIVE:
			return Color("55425c")
		RealmVisualStyleScript.MATERIAL_BUNKER:
			return Color("3e5c64")
		RealmVisualStyleScript.MATERIAL_CRYSTAL:
			return Color("3f6678")
		RealmVisualStyleScript.MATERIAL_FOUNDRY:
			return Color("5a4338")
		RealmVisualStyleScript.MATERIAL_SULFUR:
			return Color("56602a")
		RealmVisualStyleScript.MATERIAL_IRON:
			return Color("4a5058")
	return Color("38505a")
