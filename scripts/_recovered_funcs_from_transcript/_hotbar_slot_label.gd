func _hotbar_slot_label(stack: Dictionary) -> String:
	var kind := str(stack.get("kind", OperatorLoadoutScript.KIND_EMPTY))
	match kind:
		OperatorLoadoutScript.KIND_EMPTY:
			return "-"
		OperatorLoadoutScript.KIND_MINING_TOOL:
			return "CUT"
		OperatorLoadoutScript.KIND_WEAPON:
			var names: Array[String] = ["PST", "SHT", "LSR", "SMG", "RAL", "FLM"]
			var wid := int(stack.get("id", 0))
			return names[wid] if wid >= 0 and wid < names.size() else "WPN"
		OperatorLoadoutScript.KIND_BUILD:
			return "BRC" if int(stack.get("build_kind", 0)) == BUILD_BARRICADE else "STY"
		OperatorLoadoutScript.KIND_BLOCK:
			return "BLK"
		OperatorLoadoutScript.KIND_DEPLOYABLE:
			var id := str(stack.get("id", ""))
			if id == TORCH_STOCK_ID:
				return "TRC"
			if id.length() >= 3:
				return id.substr(0, 3).to_upper()
			return id.to_upper()
	return "?"
