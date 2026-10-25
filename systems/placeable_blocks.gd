class_name PlaceableBlocks
extends RefCounted

## Mk2+ mined biome rock blocks: inventory ids + placed cell overrides.

const BLOCK_PREFIX := "rock_biome_"

var placed_block_cells: Dictionary = {} ## cell_key -> biome_id (int)


static func block_id_for_biome(biome_id: int) -> String:
	return "%s%d" % [BLOCK_PREFIX, biome_id]


static func biome_from_block_id(block_id: String) -> int:
	if not block_id.begins_with(BLOCK_PREFIX):
		return -1
	return int(block_id.substr(BLOCK_PREFIX.length()))


static func is_rock_block_id(block_id: String) -> bool:
	return block_id.begins_with(BLOCK_PREFIX)


func clear() -> void:
	placed_block_cells.clear()


func cell_key(cell: Vector2i) -> String:
	return "%d:%d" % [cell.x, cell.y]


func parse_cell_key(key: String) -> Vector2i:
	var parts := key.split(":")
	if parts.size() != 2:
		return Vector2i(-999999, -999999)
	return Vector2i(int(parts[0]), int(parts[1]))


func set_placed(cell: Vector2i, biome_id: int) -> void:
	placed_block_cells[cell_key(cell)] = int(biome_id)


func clear_placed(cell: Vector2i) -> void:
	placed_block_cells.erase(cell_key(cell))


func has_placed(cell: Vector2i) -> bool:
	return placed_block_cells.has(cell_key(cell))


func biome_at(cell: Vector2i, fallback: int = 0) -> int:
	var key := cell_key(cell)
	if placed_block_cells.has(key):
		return int(placed_block_cells[key])
	return fallback


func serialize() -> Dictionary:
	var out := {}
	for key: Variant in placed_block_cells.keys():
		out[str(key)] = int(placed_block_cells[key])
	return out


func deserialize(data: Variant) -> void:
	placed_block_cells.clear()
	if data is Dictionary:
		for key: Variant in data.keys():
			placed_block_cells[str(key)] = int(data[key])
