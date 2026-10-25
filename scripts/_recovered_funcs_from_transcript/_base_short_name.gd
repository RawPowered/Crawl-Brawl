func _base_short_name(base_id: String) -> String:
	match base_id:
		BaseNetworkScript.COMMAND_ID:
			return "CMD"
		BaseNetworkScript.NORTH_ID:
			return "CRS"
		BaseNetworkScript.SOUTH_ID:
			return "FDY"
		BaseNetworkScript.WEST_ID:
			return "HCP"
		_:
			var display := str(base_network.get_base(base_id).get("name", base_id))
			return display.substr(0, mini(3, display.length())).to_upper()
