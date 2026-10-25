func _weapon_hud_icon(weapon_id: int) -> Texture2D:
	if weapon_id < 0 or weapon_id >= WEAPON_ICON_NAMES.size():
		return null
	return shop_icons.get(WEAPON_ICON_NAMES[weapon_id])
