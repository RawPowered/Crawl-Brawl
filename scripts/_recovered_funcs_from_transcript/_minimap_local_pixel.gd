func _minimap_local_pixel(cell: Vector2i) -> Vector2i:
    var local := cell - minimap_view_origin
    var view_size := _minimap_view_size()
    if local.x < 0 or local.y < 0 or local.x >= view_size.x or local.y >= view_size.y:
        return Vector2i(-1, -1)
    return local
