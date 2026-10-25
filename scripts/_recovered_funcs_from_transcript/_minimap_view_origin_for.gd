func _minimap_view_origin_for(anchor_cell: Vector2i) -> Vector2i:
    return anchor_cell - _minimap_view_size() / 2
