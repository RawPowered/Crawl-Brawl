class_name TextureLoader
extends RefCounted

## Prefer Godot's imported texture so exported builds can read packaged assets.
## Decode the source PNG only in clean checkouts without an import cache.
static func load_png(resource_path: String) -> Texture2D:
	# Editor runs use the current source PNG so stale imported textures cannot
	# reintroduce old magenta backgrounds after an art regeneration.
	if OS.has_feature("editor"):
		var source_texture := _decode_source_png(resource_path)
		if source_texture != null:
			return source_texture
	var imported: Resource = ResourceLoader.load(resource_path)
	if imported is Texture2D:
		return imported
	return _decode_source_png(resource_path)


static func _decode_source_png(resource_path: String) -> Texture2D:
	if not FileAccess.file_exists(resource_path):
		return null
	var png_bytes: PackedByteArray = FileAccess.get_file_as_bytes(resource_path)
	var image := Image.new()
	var load_error: Error = image.load_png_from_buffer(png_bytes)
	if load_error != OK or image.is_empty():
		push_error("Texture load failed (decode): %s (%s)" % [resource_path, error_string(load_error)])
		return null
	return ImageTexture.create_from_image(image)
