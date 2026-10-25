func _holster_cutter_icon() -> Texture2D:
	var texture: Texture2D = _combat_texture(CombatVfxScript.mining_gun_texture_id(_mining_tool_tier(), "right"))
	if texture != null:
		return texture
	return shop_icons.get("repair")
