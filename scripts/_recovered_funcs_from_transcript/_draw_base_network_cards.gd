func _draw_base_network_cards(canvas: CanvasItem) -> void:
	var font: Font = ThemeDB.fallback_font
	var origin := RealmVisualStyleScript.HUD_BASE_START
	var card_size := RealmVisualStyleScript.HUD_BASE_CARD_SIZE
	var step := RealmVisualStyleScript.HUD_BASE_CARD_STEP
	var order: Array[String] = _hud_base_order()
	for card_index in range(order.size()):
		var base_id: String = order[card_index]
		var record: Dictionary = base_network.get_base(base_id)
		var revealed := bool(record.get("revealed", false))
		var card := Rect2(origin + Vector2(float(card_index) * float(step), 0.0), card_size)
		var status_color := RealmVisualStyleScript.CYAN
		var attack_flash := float(hud_base_attack_flash.get(base_id, 0.0))
		if _base_is_under_attack(base_id) or attack_flash > 0.0:
			status_color = Color("ef675f")
		elif str(record.get("status", "")) == BaseNetworkScript.STATUS_DISABLED:
			status_color = Color("8d6967")
		elif str(record.get("status", "")) == BaseNetworkScript.STATUS_ACTIVATING:
			status_color = RealmVisualStyleScript.AMBER
		elif str(record.get("status", "")) == BaseNetworkScript.STATUS_SITE:
			status_color = Color("6d9da8")
		if not revealed:
			status_color = Color("344a50")
		canvas.draw_rect(card, Color(0.007, 0.022, 0.029, 0.95))
		canvas.draw_rect(card, Color(status_color, 0.7), false, 1.0)
		canvas.draw_rect(Rect2(card.position, Vector2(3, card.size.y)), status_color)
		var base_icon: Texture2D = shop_icons.get("command_core" if base_id == BaseNetworkScript.COMMAND_ID else "frontier_core")
		if not revealed:
			if base_icon != null:
				canvas.draw_texture_rect(base_icon, Rect2(card.get_center() - Vector2(5.5, 5.5), Vector2(11, 11)), false, Color(0.28, 0.36, 0.38, 0.72))
			canvas.draw_string(font, card.get_center() + Vector2(-3, 4), "?", HORIZONTAL_ALIGNMENT_LEFT, 8, 8, Color("50666b"))
			continue
		if base_icon != null:
			canvas.draw_texture_rect(base_icon, Rect2(card.position + Vector2(5, 6), Vector2(10, 10)), false, Color.WHITE)
		canvas.draw_string(font, card.position + Vector2(18, 15), _base_short_name(base_id), HORIZONTAL_ALIGNMENT_LEFT, 30, 8, status_color)
		var status: String = str(record.get("status", ""))
		var status_label := "SITE"
		if status == BaseNetworkScript.STATUS_ACTIVE:
			status_label = "%03d%%" % roundi(float(record["health"]) / maxf(1.0, float(record["max_health"])) * 100.0)
		elif status == BaseNetworkScript.STATUS_ACTIVATING:
			status_label = "%02dS" % ceili(float(record.get("activation_remaining", 0.0)))
		elif status == BaseNetworkScript.STATUS_DISABLED:
			status_label = "OFF"
		canvas.draw_string(font, card.position + Vector2(5, 28), status_label, HORIZONTAL_ALIGNMENT_LEFT, 42, 7, Color("b7cbd0"))
		if status == BaseNetworkScript.STATUS_ACTIVE:
			var health_ratio := clampf(float(record["health"]) / maxf(1.0, float(record["max_health"])), 0.0, 1.0)
			canvas.draw_rect(Rect2(card.position + Vector2(5, 31), Vector2(42, 3)), Color("132c33"))
			var bar_offset := sin(Time.get_ticks_msec() * 0.035) * attack_flash * 1.5 if attack_flash > 0.0 else 0.0
			canvas.draw_rect(Rect2(card.position + Vector2(5, 31.0 + bar_offset), Vector2(42.0 * health_ratio, 3)), status_color)
