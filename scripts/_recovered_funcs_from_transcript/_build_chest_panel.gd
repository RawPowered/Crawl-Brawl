func _build_chest_panel() -> void:
	chest_panel = ColorRect.new()
	chest_panel.position = Vector2(72, 36)
	chest_panel.size = Vector2(496, 288)
	chest_panel.color = Color(0.012, 0.024, 0.028, 0.985)
	chest_panel.z_index = 110
	chest_panel.visible = false
	chest_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay_root.add_child(chest_panel)

	var top_accent := ColorRect.new()
	top_accent.size = Vector2(496, 3)
	top_accent.color = Color("d7b36a")
	top_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chest_panel.add_child(top_accent)

	chest_title = Label.new()
	chest_title.position = Vector2(16, 10)
	chest_title.size = Vector2(360, 18)
	chest_title.add_theme_font_size_override("font_size", 13)
	chest_title.add_theme_color_override("font_color", Color("ffd36b"))
	chest_panel.add_child(chest_title)

	chest_status = Label.new()
	chest_status.position = Vector2(16, 30)
	chest_status.size = Vector2(460, 14)
	chest_status.add_theme_font_size_override("font_size", 8)
	chest_status.add_theme_color_override("font_color", Color("9db5b8"))
	chest_panel.add_child(chest_status)

	chest_player_heading = Label.new()
	chest_player_heading.text = "FIELD PACK"
	chest_player_heading.position = Vector2(16, 52)
	chest_player_heading.size = Vector2(200, 12)
	chest_player_heading.add_theme_font_size_override("font_size", 8)
	chest_player_heading.add_theme_color_override("font_color", Color("8eeaff"))
	chest_panel.add_child(chest_player_heading)

	chest_vault_heading = Label.new()
	chest_vault_heading.text = "VAULT CARGO"
	chest_vault_heading.position = Vector2(260, 52)
	chest_vault_heading.size = Vector2(200, 12)
	chest_vault_heading.add_theme_font_size_override("font_size", 8)
	chest_vault_heading.add_theme_color_override("font_color", Color("ffd36b"))
	chest_panel.add_child(chest_vault_heading)

	chest_player_list = GridContainer.new()
	chest_player_list.columns = 4
	chest_player_list.position = Vector2(16, 68)
	chest_player_list.size = Vector2(220, 160)
	chest_panel.add_child(chest_player_list)

	chest_vault_list = GridContainer.new()
	chest_vault_list.columns = 4
	chest_vault_list.position = Vector2(260, 68)
	chest_vault_list.size = Vector2(220, 160)
	chest_panel.add_child(chest_vault_list)

	chest_actions.clear()
	var deposit := _overlay_button("DEPOSIT ALL")
	deposit.position = Vector2(16, 244)
	deposit.size = Vector2(220, 24)
	deposit.pressed.connect(_chest_deposit_all)
	chest_panel.add_child(deposit)
	chest_actions.append(deposit)

	var withdraw := _overlay_button("WITHDRAW ALL")
	withdraw.position = Vector2(260, 244)
	withdraw.size = Vector2(220, 24)
	withdraw.pressed.connect(_chest_withdraw_all)
	chest_panel.add_child(withdraw)
	chest_actions.append(withdraw)

	var close := _overlay_button("CLOSE  //  F / B / I")
	close.position = Vector2(16, 272)
	close.size = Vector2(464, 22)
	close.pressed.connect(_close_chest)
	chest_panel.add_child(close)
