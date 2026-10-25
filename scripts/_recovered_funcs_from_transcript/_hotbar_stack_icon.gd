func _hotbar_stack_icon(stack: Dictionary) -> Texture2D:
	var kind := str(stack.get("kind", OperatorLoadoutScript.KIND_EMPTY))
	match kind:
		OperatorLoadoutScript.KIND_WEAPON:
			return _weapon_hud_icon(int(stack.get("id", -1)))
		OperatorLoadoutScript.KIND_MINING_TOOL:
			return _holster_cutter_icon()
		OperatorLoadoutScript.KIND_BUILD:
			return shop_icons.get(_build_icon_name(int(stack.get("build_kind", BUILD_BARRICADE))))
		OperatorLoadoutScript.KIND_BLOCK:
			return shop_icons.get(str(stack.get("id", "")), shop_icons.get("stone_block"))
		OperatorLoadoutScript.KIND_DEPLOYABLE:
			var id := str(stack.get("id", ""))
			var icon: Texture2D = shop_icons.get(id)
			if icon != null:
				return icon
			for build_kind: int in BUILD_STOCK_KEYS.keys():
				if str(BUILD_STOCK_KEYS[build_kind]) == id:
					return shop_icons.get(_build_icon_name(build_kind))
	return null
