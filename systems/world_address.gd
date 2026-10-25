class_name WorldAddress
extends RefCounted

# Authoritative signed 64-bit address math for the unbounded-world migration.
# Runtime rendering still uses local Vector2/Vector2i adapters until floating
# origin work lands, but save/UI/generator code can use these values directly.
const REGION_SIZE := 24


static func split_cell(cell_x: int, cell_y: int, region_size: int = REGION_SIZE) -> Dictionary:
	return {
		"region_x": floor_div(cell_x, region_size),
		"region_y": floor_div(cell_y, region_size),
		"local_x": floor_mod(cell_x, region_size),
		"local_y": floor_mod(cell_y, region_size),
	}


static func compose_cell(region_x: int, region_y: int, local_x: int, local_y: int, region_size: int = REGION_SIZE) -> Dictionary:
	return {
		"x": region_x * region_size + floor_mod(local_x, region_size),
		"y": region_y * region_size + floor_mod(local_y, region_size),
	}


static func floor_div(value: int, divisor: int) -> int:
	assert(divisor > 0)
	@warning_ignore("integer_division")
	var quotient: int = value / divisor
	if value < 0 and value % divisor != 0:
		quotient -= 1
	return quotient


static func floor_mod(value: int, divisor: int) -> int:
	assert(divisor > 0)
	return posmod(value, divisor)


static func compact_label(cell_x: int, cell_y: int, region_size: int = REGION_SIZE) -> String:
	var address := split_cell(cell_x, cell_y, region_size)
	return "C %+07d,%+07d  R %+05d,%+05d" % [
		cell_x,
		cell_y,
		int(address["region_x"]),
		int(address["region_y"]),
	]
