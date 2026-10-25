func _minimap_view_size() -> Vector2i:
    var map_rect := RealmVisualStyleScript.HUD_MINIMAP_MAP
    return Vector2i(int(map_rect.size.x), int(map_rect.size.y))
