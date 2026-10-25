class_name OperatorLoadout
extends RefCounted

## Build bar (9) + pack (27) stacks, max 99. Guns live on a size-6 holster; cutter is not a stack.

const STACK_MAX := 99
const HOTBAR_SIZE := 9
const BACKPACK_SIZE := 27
const HOLSTER_SIZE := 6

const KIND_EMPTY := "empty"
const KIND_WEAPON := "weapon"
const KIND_MINING_TOOL := "mining_tool"
const KIND_DEPLOYABLE := "deployable"
const KIND_BLOCK := "block"
const KIND_BUILD := "build"

const MINING_CUTTER_ID := "mining_cutter"
const BUILD_BARRICADE := 0
const BUILD_SENTRY := 1
const EMPTY_GUN := -1

static func empty_stack() -> Dictionary:
	return {"kind": KIND_EMPTY, "id": "", "build_kind": -1, "count": 0}


static func make_stack(kind: String, id: Variant = "", count: int = 1, build_kind: int = -1) -> Dictionary:
	return {
		"kind": kind,
		"id": id,
		"build_kind": build_kind,
		"count": clampi(count, 0, STACK_MAX),
	}


static func stacks_match(a: Dictionary, b: Dictionary) -> bool:
	if str(a.get("kind", "")) != str(b.get("kind", "")):
		return false
	if str(a.get("kind", "")) == KIND_EMPTY:
		return true
	if str(a.get("kind", "")) == KIND_BUILD:
		return int(a.get("build_kind", -1)) == int(b.get("build_kind", -1))
	return str(a.get("id", "")) == str(b.get("id", ""))


static func is_placeable(stack: Dictionary) -> bool:
	var kind := str(stack.get("kind", KIND_EMPTY))
	return kind in [KIND_DEPLOYABLE, KIND_BLOCK, KIND_BUILD] and int(stack.get("count", 0)) > 0


static func is_weapon(stack: Dictionary) -> bool:
	return str(stack.get("kind", "")) == KIND_WEAPON and int(stack.get("count", 0)) > 0


static func can_mine_with(stack: Dictionary) -> bool:
	return str(stack.get("kind", KIND_EMPTY)) == KIND_MINING_TOOL


static func gun_slot_count_for_tier(tier: int) -> int:
	return clampi(2 + clampi(tier, 1, 4), 3, 6)


static func build_slot_count_for_tier(tier: int) -> int:
	match clampi(tier, 1, 4):
		1:
			return 5
		2:
			return 6
		3:
			return 8
		_:
			return 9


var hotbar: Array[Dictionary] = []
var backpack: Array[Dictionary] = []
var holster_guns: Array[int] = []
var hotbar_index := 0
var holster_index := 0
var pack_tier := 1


func _init() -> void:
	reset_empty()


func reset_empty() -> void:
	hotbar.clear()
	backpack.clear()
	holster_guns.clear()
	for _i in range(HOTBAR_SIZE):
		hotbar.append(empty_stack())
	for _i in range(BACKPACK_SIZE):
		backpack.append(empty_stack())
	for _j in range(HOLSTER_SIZE):
		holster_guns.append(EMPTY_GUN)
	hotbar_index = 0
	holster_index = 0


func set_pack_tier(tier: int) -> void:
	pack_tier = clampi(tier, 1, 4)
	if hotbar_index >= build_slot_count():
		hotbar_index = 0
	_promote_pack_guns()
	sanitize_holster_index()


func _promote_pack_guns() -> void:
	for i in range(gun_slot_count()):
		if holster_guns[i] >= 0:
			continue
		for p in range(backpack.size()):
			if str(backpack[p].get("kind", "")) != KIND_WEAPON:
				continue
			holster_guns[i] = int(backpack[p].get("id", EMPTY_GUN))
			backpack[p] = empty_stack()
			break


func gun_slot_count() -> int:
	return gun_slot_count_for_tier(pack_tier)


func build_slot_count() -> int:
	return build_slot_count_for_tier(pack_tier)


func is_cutter_selected() -> bool:
	return holster_index <= 0


func is_gun_selected() -> bool:
	var wid := selected_weapon_id()
	return wid >= 0


func selected_weapon_id() -> int:
	if holster_index <= 0:
		return EMPTY_GUN
	var gi := holster_index - 1
	if gi < 0 or gi >= gun_slot_count():
		return EMPTY_GUN
	return holster_guns[gi]


func sanitize_holster_index() -> void:
	if holster_index <= 0:
		holster_index = 0
		return
	var gi := holster_index - 1
	if gi >= gun_slot_count() or holster_guns[gi] < 0:
		holster_index = 0


func active_stack() -> Dictionary:
	if hotbar_index < 0 or hotbar_index >= hotbar.size():
		return empty_stack()
	return hotbar[hotbar_index]


func set_hotbar_index(index: int) -> bool:
	if index < 0 or index >= build_slot_count():
		return false
	hotbar_index = index
	return true


func cycle_hotbar(direction: int) -> void:
	var n := build_slot_count()
	if n <= 0:
		return
	hotbar_index = posmod(hotbar_index + direction, n)


func cycle_holster(direction: int) -> void:
	var filled: Array[int] = [0]
	for i in range(gun_slot_count()):
		if holster_guns[i] >= 0:
			filled.append(i + 1)
	var pos := filled.find(holster_index)
	if pos < 0:
		holster_index = 0
		return
	holster_index = filled[posmod(pos + direction, filled.size())]


func slot_count(where: String) -> int:
	if where == "hotbar":
		return HOTBAR_SIZE
	if where == "holster":
		return HOLSTER_SIZE
	return BACKPACK_SIZE


func get_slot(where: String, index: int) -> Dictionary:
	if where == "holster":
		if index < 0 or index >= HOLSTER_SIZE:
			return empty_stack()
		var wid: int = holster_guns[index]
		if wid < 0:
			return empty_stack()
		return make_stack(KIND_WEAPON, wid, 1)
	var arr := hotbar if where == "hotbar" else backpack
	if index < 0 or index >= arr.size():
		return empty_stack()
	return arr[index]


func set_slot(where: String, index: int, stack: Dictionary) -> void:
	var kind := str(stack.get("kind", KIND_EMPTY))
	var count := int(stack.get("count", 0))
	if where == "holster":
		if index < 0 or index >= gun_slot_count():
			return
		if count <= 0 or kind == KIND_EMPTY:
			holster_guns[index] = EMPTY_GUN
			sanitize_holster_index()
			return
		if kind != KIND_WEAPON:
			return
		holster_guns[index] = int(stack.get("id", EMPTY_GUN))
		return
	if where == "hotbar":
		if kind in [KIND_WEAPON, KIND_MINING_TOOL]:
			return
		if index >= build_slot_count() and kind != KIND_EMPTY and count > 0:
			return
	var arr := hotbar if where == "hotbar" else backpack
	if index < 0 or index >= arr.size():
		return
	if count <= 0 or kind == KIND_EMPTY:
		arr[index] = empty_stack()
	else:
		var copy := stack.duplicate(true)
		copy["count"] = clampi(int(copy.get("count", 0)), 0, STACK_MAX)
		arr[index] = copy


func clear_slot(where: String, index: int) -> void:
	set_slot(where, index, empty_stack())


func occupied_backpack_slots() -> int:
	var used := 0
	for stack: Dictionary in backpack:
		if str(stack.get("kind", KIND_EMPTY)) != KIND_EMPTY and int(stack.get("count", 0)) > 0:
			used += 1
	return used


func free_backpack_slots() -> int:
	return maxi(0, BACKPACK_SIZE - occupied_backpack_slots())


func has_placeable_room() -> bool:
	if free_backpack_slots() > 0:
		return true
	for i in range(build_slot_count()):
		if str(hotbar[i].get("kind", KIND_EMPTY)) == KIND_EMPTY:
			return true
	return false


func can_accept_stack(proto: Dictionary, amount: int = 1) -> bool:
	## Pure capacity query. Shop previews must never mutate inventory just to test room.
	var wanted: int = maxi(0, amount)
	if wanted <= 0:
		return true
	var kind: String = str(proto.get("kind", KIND_EMPTY))
	if kind not in [KIND_DEPLOYABLE, KIND_BLOCK]:
		return has_placeable_room()
	var capacity: int = 0
	for i in range(build_slot_count()):
		var hot_stack: Dictionary = hotbar[i]
		if stacks_match(hot_stack, proto):
			capacity += maxi(0, STACK_MAX - int(hot_stack.get("count", 0)))
		elif str(hot_stack.get("kind", KIND_EMPTY)) == KIND_EMPTY:
			capacity += STACK_MAX
	for pack_stack: Dictionary in backpack:
		if stacks_match(pack_stack, proto):
			capacity += maxi(0, STACK_MAX - int(pack_stack.get("count", 0)))
		elif str(pack_stack.get("kind", KIND_EMPTY)) == KIND_EMPTY:
			capacity += STACK_MAX
	return capacity >= wanted


func block_counts() -> Dictionary:
	var result: Dictionary = {}
	for hot_stack: Dictionary in hotbar:
		if str(hot_stack.get("kind", "")) == KIND_BLOCK and int(hot_stack.get("count", 0)) > 0:
			var hot_block_id: String = str(hot_stack.get("id", ""))
			result[hot_block_id] = int(result.get(hot_block_id, 0)) + int(hot_stack.get("count", 0))
	for pack_stack: Dictionary in backpack:
		if str(pack_stack.get("kind", "")) == KIND_BLOCK and int(pack_stack.get("count", 0)) > 0:
			var pack_block_id: String = str(pack_stack.get("id", ""))
			result[pack_block_id] = int(result.get(pack_block_id, 0)) + int(pack_stack.get("count", 0))
	return result


func block_total() -> int:
	var total: int = 0
	for amount: Variant in block_counts().values():
		total += int(amount)
	return total


func count_of(kind: String, id: Variant = "", build_kind: int = -1) -> int:
	if kind == KIND_MINING_TOOL:
		return 1
	var total := 0
	if kind == KIND_WEAPON:
		var wid := int(id) if str(id) != "" else EMPTY_GUN
		for gun_id: int in holster_guns:
			if gun_id < 0:
				continue
			if wid < 0 or gun_id == wid:
				total += 1
	for stack: Dictionary in hotbar:
		total += _stack_count_if_match(stack, kind, id, build_kind)
	for stack: Dictionary in backpack:
		total += _stack_count_if_match(stack, kind, id, build_kind)
	return total


func _stack_count_if_match(stack: Dictionary, kind: String, id: Variant, build_kind: int) -> int:
	if str(stack.get("kind", "")) != kind:
		return 0
	if kind == KIND_BUILD:
		return int(stack.get("count", 0)) if int(stack.get("build_kind", -1)) == build_kind else 0
	if kind == KIND_EMPTY or kind == KIND_MINING_TOOL:
		return int(stack.get("count", 0))
	return int(stack.get("count", 0)) if str(stack.get("id", "")) == str(id) else 0


func has_mining_cutter() -> bool:
	return true


func has_weapon(weapon_id: int) -> bool:
	return count_of(KIND_WEAPON, weapon_id) > 0


func _place_weapon(weapon_id: int) -> String:
	if weapon_id < 0 or has_weapon(weapon_id):
		return "have"
	for i in range(gun_slot_count()):
		if holster_guns[i] < 0:
			holster_guns[i] = weapon_id
			return "holster"
	for i in range(backpack.size()):
		if str(backpack[i].get("kind", KIND_EMPTY)) == KIND_EMPTY:
			backpack[i] = make_stack(KIND_WEAPON, weapon_id, 1)
			return "pack"
	return "lost"


## Add stacks. Placeables fill unlocked build slots first, then pack. Guns fill holster then pack.
func add_stacks(stack: Dictionary) -> int:
	var leftover := clampi(int(stack.get("count", 0)), 0, 9999)
	if leftover <= 0 or str(stack.get("kind", "")) == KIND_EMPTY:
		return 0
	var kind := str(stack.get("kind", ""))
	if kind == KIND_MINING_TOOL:
		return 0
	if kind == KIND_WEAPON:
		if has_weapon(int(stack.get("id", EMPTY_GUN))):
			return leftover
		var dest := _place_weapon(int(stack.get("id", EMPTY_GUN)))
		return 0 if dest in ["holster", "pack", "have"] else leftover
	leftover = _merge_into(hotbar, stack, leftover, build_slot_count())
	leftover = _merge_into(backpack, stack, leftover, backpack.size())
	leftover = _fill_empty(hotbar, stack, leftover, build_slot_count())
	leftover = _fill_empty(backpack, stack, leftover, backpack.size())
	return leftover


func _merge_into(arr: Array[Dictionary], proto: Dictionary, leftover: int, limit: int) -> int:
	if leftover <= 0:
		return 0
	var kind := str(proto.get("kind", ""))
	if kind in [KIND_WEAPON, KIND_MINING_TOOL, KIND_BUILD]:
		return leftover
	var n := mini(arr.size(), limit)
	for i in range(n):
		if leftover <= 0:
			break
		var slot: Dictionary = arr[i]
		if not stacks_match(slot, proto):
			continue
		var space := STACK_MAX - int(slot.get("count", 0))
		if space <= 0:
			continue
		var take := mini(space, leftover)
		slot["count"] = int(slot.get("count", 0)) + take
		arr[i] = slot
		leftover -= take
	return leftover


func _fill_empty(arr: Array[Dictionary], proto: Dictionary, leftover: int, limit: int) -> int:
	if leftover <= 0:
		return 0
	var kind := str(proto.get("kind", ""))
	if kind in [KIND_WEAPON, KIND_MINING_TOOL]:
		return leftover
	var n := mini(arr.size(), limit)
	for i in range(n):
		if leftover <= 0:
			break
		if str(arr[i].get("kind", KIND_EMPTY)) != KIND_EMPTY:
			continue
		var take := mini(STACK_MAX, leftover)
		if kind == KIND_BUILD:
			take = 1
		arr[i] = make_stack(kind, proto.get("id", ""), take, int(proto.get("build_kind", -1)))
		leftover -= take
	return leftover


func set_deployable_total(stock_id: String, amount: int) -> void:
	_remove_all_kind(KIND_DEPLOYABLE, stock_id)
	amount = maxi(0, amount)
	while amount > 0:
		var chunk := mini(STACK_MAX, amount)
		var left := add_stacks(make_stack(KIND_DEPLOYABLE, stock_id, chunk))
		amount -= chunk - left
		if left > 0:
			break


func _remove_all_kind(kind: String, id: Variant = "", build_kind: int = -1) -> void:
	for i in range(hotbar.size()):
		if _stack_count_if_match(hotbar[i], kind, id, build_kind) > 0:
			hotbar[i] = empty_stack()
	for i in range(backpack.size()):
		if _stack_count_if_match(backpack[i], kind, id, build_kind) > 0:
			backpack[i] = empty_stack()


func consume_kind(kind: String, id: Variant = "", amount: int = 1, build_kind: int = -1) -> bool:
	if count_of(kind, id, build_kind) < amount:
		return false
	var remaining := amount
	remaining = _consume_from_arr(hotbar, kind, id, build_kind, remaining)
	remaining = _consume_from_arr(backpack, kind, id, build_kind, remaining)
	return remaining <= 0


func consume_active(amount: int = 1) -> bool:
	var stack := active_stack()
	if int(stack.get("count", 0)) < amount:
		return false
	stack["count"] = int(stack.get("count", 0)) - amount
	if int(stack["count"]) <= 0:
		hotbar[hotbar_index] = empty_stack()
	else:
		hotbar[hotbar_index] = stack
	return true


func _consume_from_arr(arr: Array[Dictionary], kind: String, id: Variant, build_kind: int, remaining: int) -> int:
	for i in range(arr.size()):
		if remaining <= 0:
			break
		var n := _stack_count_if_match(arr[i], kind, id, build_kind)
		if n <= 0:
			continue
		var take := mini(n, remaining)
		arr[i]["count"] = int(arr[i].get("count", 0)) - take
		if int(arr[i]["count"]) <= 0:
			arr[i] = empty_stack()
		remaining -= take
	return remaining


func _can_land(where: String, index: int, stack: Dictionary) -> bool:
	var kind := str(stack.get("kind", KIND_EMPTY))
	if kind == KIND_EMPTY or int(stack.get("count", 0)) <= 0:
		return true
	if kind == KIND_MINING_TOOL:
		return false
	if where == "holster":
		return kind == KIND_WEAPON and index >= 0 and index < gun_slot_count()
	if where == "hotbar":
		if kind == KIND_WEAPON:
			return false
		return index >= 0 and index < build_slot_count()
	return where == "backpack" and index >= 0 and index < BACKPACK_SIZE


func swap_slots(where_a: String, index_a: int, where_b: String, index_b: int) -> void:
	var a := get_slot(where_a, index_a)
	var b := get_slot(where_b, index_b)
	if not _can_land(where_b, index_b, a) or not _can_land(where_a, index_a, b):
		return
	if str(a.get("kind", "")) != KIND_EMPTY and str(b.get("kind", "")) != KIND_EMPTY and stacks_match(a, b):
		var kind := str(a.get("kind", ""))
		if kind in [KIND_DEPLOYABLE, KIND_BLOCK]:
			var total := int(a.get("count", 0)) + int(b.get("count", 0))
			var first := mini(STACK_MAX, total)
			var second := total - first
			set_slot(where_b, index_b, make_stack(kind, a.get("id", ""), first, int(a.get("build_kind", -1))))
			if second > 0:
				set_slot(where_a, index_a, make_stack(kind, a.get("id", ""), second, int(a.get("build_kind", -1))))
			else:
				clear_slot(where_a, index_a)
			return
	set_slot(where_a, index_a, b)
	set_slot(where_b, index_b, a)
	sanitize_holster_index()


func move_one(where_from: String, index_from: int, where_to: String, index_to: int) -> bool:
	var src := get_slot(where_from, index_from)
	if str(src.get("kind", KIND_EMPTY)) == KIND_EMPTY or int(src.get("count", 0)) <= 0:
		return false
	if not _can_land(where_to, index_to, make_stack(str(src.get("kind", "")), src.get("id", ""), 1, int(src.get("build_kind", -1)))):
		return false
	var dst := get_slot(where_to, index_to)
	var kind := str(src.get("kind", ""))
	if str(dst.get("kind", KIND_EMPTY)) == KIND_EMPTY:
		set_slot(where_to, index_to, make_stack(kind, src.get("id", ""), 1, int(src.get("build_kind", -1))))
		src["count"] = int(src.get("count", 0)) - 1
		set_slot(where_from, index_from, src)
		return true
	if stacks_match(src, dst) and kind in [KIND_DEPLOYABLE, KIND_BLOCK] and int(dst.get("count", 0)) < STACK_MAX:
		dst["count"] = int(dst.get("count", 0)) + 1
		set_slot(where_to, index_to, dst)
		src["count"] = int(src.get("count", 0)) - 1
		set_slot(where_from, index_from, src)
		return true
	return false


func ensure_mining_cutter() -> void:
	pass


func ensure_weapon(weapon_id: int) -> String:
	if has_weapon(weapon_id):
		return "have"
	return _place_weapon(weapon_id)


func ensure_build_pointer(build_kind: int) -> void:
	if count_of(KIND_BUILD, "", build_kind) > 0:
		return
	add_stacks(make_stack(KIND_BUILD, "build", 1, build_kind))


func find_hotbar_kind(kind: String, id: Variant = "") -> int:
	for i in range(hotbar.size()):
		if str(hotbar[i].get("kind", "")) != kind:
			continue
		if kind == KIND_MINING_TOOL or str(hotbar[i].get("id", "")) == str(id) or id == null or str(id) == "":
			return i
	return -1


func select_mining_cutter() -> void:
	holster_index = 0


func apply_default_new_run(unlocked_weapons: Array) -> void:
	reset_empty()
	pack_tier = 1
	var gun_slot := 0
	for weapon_id in range(mini(unlocked_weapons.size(), HOLSTER_SIZE)):
		if gun_slot >= gun_slot_count():
			break
		if bool(unlocked_weapons[weapon_id]):
			holster_guns[gun_slot] = int(weapon_id)
			gun_slot += 1
	hotbar[0] = make_stack(KIND_BUILD, "build", 1, BUILD_BARRICADE)
	hotbar[1] = make_stack(KIND_BUILD, "build", 1, BUILD_SENTRY)
	hotbar_index = 0
	holster_index = 0


func migrate_from_deployable_stock(stock: Dictionary, current_weapon: int, unlocked_weapons: Array) -> void:
	apply_default_new_run(unlocked_weapons)
	if current_weapon >= 0 and has_weapon(current_weapon):
		for i in range(gun_slot_count()):
			if holster_guns[i] == current_weapon:
				holster_index = i + 1
				break
	for stock_id: Variant in stock.keys():
		var amount := int(stock[stock_id])
		while amount > 0:
			var chunk := mini(STACK_MAX, amount)
			var left := add_stacks(make_stack(KIND_DEPLOYABLE, str(stock_id), chunk))
			amount -= chunk - left
			if left > 0:
				break
	holster_index = 0


func serialize() -> Dictionary:
	var guns: Array = []
	for wid: int in holster_guns:
		guns.append(wid)
	return {
		"hotbar": _serialize_arr(hotbar),
		"backpack": _serialize_arr(backpack),
		"hotbar_index": hotbar_index,
		"holster_guns": guns,
		"holster_index": holster_index,
		"pack_tier": pack_tier,
	}


func deserialize(data: Dictionary) -> void:
	reset_empty()
	pack_tier = clampi(int(data.get("pack_tier", pack_tier)), 1, 4)
	if data.has("holster_guns"):
		_deserialize_arr(hotbar, data.get("hotbar", []), HOTBAR_SIZE)
		_deserialize_arr(backpack, data.get("backpack", []), BACKPACK_SIZE)
		_load_holster_guns(data.get("holster_guns", []))
		hotbar_index = clampi(int(data.get("hotbar_index", 0)), 0, maxi(0, build_slot_count() - 1))
		holster_index = clampi(int(data.get("holster_index", 0)), 0, HOLSTER_SIZE)
		_strip_weapons_from_bars()
	else:
		_migrate_mixed_hotbar(data)
	sanitize_holster_index()
	_strip_invalid_build_bar()


func _load_holster_guns(raw: Variant) -> void:
	var seen: Dictionary = {}
	if not raw is Array:
		return
	var source: Array = raw
	var slot := 0
	for entry: Variant in source:
		if slot >= HOLSTER_SIZE:
			break
		var wid := int(entry)
		if wid < 0 or seen.has(wid):
			continue
		seen[wid] = true
		if slot < gun_slot_count():
			holster_guns[slot] = wid
			slot += 1
		else:
			_place_weapon(wid)


func _migrate_mixed_hotbar(data: Dictionary) -> void:
	var mixed_hot: Array[Dictionary] = []
	var mixed_pack: Array[Dictionary] = []
	for _i in range(HOTBAR_SIZE):
		mixed_hot.append(empty_stack())
	for _j in range(BACKPACK_SIZE):
		mixed_pack.append(empty_stack())
	_deserialize_arr(mixed_hot, data.get("hotbar", []), HOTBAR_SIZE)
	_deserialize_arr(mixed_pack, data.get("backpack", []), BACKPACK_SIZE)
	for stack: Dictionary in mixed_hot:
		_ingest_migrated_stack(stack)
	for stack: Dictionary in mixed_pack:
		_ingest_migrated_stack(stack)
	hotbar_index = 0
	holster_index = 0


func _ingest_migrated_stack(stack: Dictionary) -> void:
	var kind := str(stack.get("kind", KIND_EMPTY))
	if kind == KIND_EMPTY or int(stack.get("count", 0)) <= 0:
		return
	if kind == KIND_MINING_TOOL:
		return
	if kind == KIND_WEAPON:
		_place_weapon(int(stack.get("id", EMPTY_GUN)))
		return
	add_stacks(stack)


func _strip_weapons_from_bars() -> void:
	for i in range(hotbar.size()):
		if str(hotbar[i].get("kind", "")) in [KIND_WEAPON, KIND_MINING_TOOL]:
			if str(hotbar[i].get("kind", "")) == KIND_WEAPON:
				_place_weapon(int(hotbar[i].get("id", EMPTY_GUN)))
			hotbar[i] = empty_stack()
	for i in range(backpack.size()):
		if str(backpack[i].get("kind", "")) == KIND_MINING_TOOL:
			backpack[i] = empty_stack()


func _strip_invalid_build_bar() -> void:
	for i in range(build_slot_count(), HOTBAR_SIZE):
		var stack: Dictionary = hotbar[i]
		if str(stack.get("kind", KIND_EMPTY)) == KIND_EMPTY:
			continue
		add_stacks(stack)
		hotbar[i] = empty_stack()


func _serialize_arr(arr: Array[Dictionary]) -> Array:
	var out: Array = []
	for stack: Dictionary in arr:
		out.append({
			"kind": str(stack.get("kind", KIND_EMPTY)),
			"id": stack.get("id", ""),
			"build_kind": int(stack.get("build_kind", -1)),
			"count": int(stack.get("count", 0)),
		})
	return out


func _deserialize_arr(arr: Array[Dictionary], raw: Variant, expected: int) -> void:
	if not raw is Array:
		return
	var source: Array = raw
	for i in range(mini(expected, source.size())):
		var entry: Variant = source[i]
		if entry is Dictionary:
			var d: Dictionary = entry
			var count := int(d.get("count", 0))
			var kind := str(d.get("kind", KIND_EMPTY))
			if count <= 0 or kind == KIND_EMPTY:
				arr[i] = empty_stack()
			else:
				arr[i] = make_stack(kind, d.get("id", ""), count, int(d.get("build_kind", -1)))


func cargo_stacks_snapshot() -> Array:
	return _serialize_arr(backpack) + _serialize_arr(hotbar)


func clear_cargo_stacks() -> void:
	for i in range(hotbar.size()):
		var kind := str(hotbar[i].get("kind", ""))
		if kind in [KIND_DEPLOYABLE, KIND_BLOCK]:
			hotbar[i] = empty_stack()
	for i in range(backpack.size()):
		var kind := str(backpack[i].get("kind", ""))
		if kind in [KIND_DEPLOYABLE, KIND_BLOCK]:
			backpack[i] = empty_stack()


func restore_cargo_stacks(stacks: Array, prefer_pack: bool = true) -> Array:
	var leftovers: Array = []
	for entry: Variant in stacks:
		if not entry is Dictionary:
			continue
		var d: Dictionary = entry
		var kind := str(d.get("kind", KIND_EMPTY))
		if kind not in [KIND_DEPLOYABLE, KIND_BLOCK]:
			continue
		var count := int(d.get("count", 0))
		if count <= 0:
			continue
		var left := add_stacks(make_stack(kind, d.get("id", ""), count, int(d.get("build_kind", -1))))
		if left > 0:
			leftovers.append(make_stack(kind, d.get("id", ""), left, int(d.get("build_kind", -1))))
	return leftovers


func deployable_stock_mirror(keys: Array) -> Dictionary:
	var out := {}
	for key: Variant in keys:
		out[str(key)] = count_of(KIND_DEPLOYABLE, str(key))
	return out
