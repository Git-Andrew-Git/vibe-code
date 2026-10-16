extends Node

## GameState - Global manager for world state, player stats, time, inventory, and save/load system.

const ItemDataClass = preload("res://res/scripts/ItemData.gd")
const RecipeDataClass = preload("res://res/scripts/RecipeData.gd")
const ItemDatabaseClass = preload("res://res/scripts/ItemDatabase.gd")

const SAVE_PATH := "user://savegame.json"
const INVENTORY_CAPACITY := 24
const HOTBAR_CAPACITY := 5

var current_time_hours: float = 8.0 # Starts at 08:00 AM
var time_scale: float = 60.0 # 1 real second = 1 game minute

var player_stats := {
	"health": 100.0,
	"max_health": 100.0,
	"stamina": 100.0,
	"max_stamina": 100.0,
	"oxygen": 100.0,
	"max_oxygen": 100.0,
	"hunger": 100.0,
	"max_hunger": 100.0,
	"thirst": 100.0,
	"max_thirst": 100.0
}

var current_zone: String = "Alien Shallows"
var _last_minute: int = -1

# Inventory & Equipment
var inventory: Array[Dictionary] = []
var equipped_tank: String = ""
var equipped_fins: String = ""
var selected_hotbar_slot: int = 0

# ---- Story Log ----
var story_entries: Array[String] = []

func _ready() -> void:
	ItemDatabaseClass.init_database()
	_ensure_default_inputs()
	_init_starter_inventory()
	_emit_time(true)
	EventBus.zone_entered.emit(current_zone)
	_emit_all_stats()

func _init_starter_inventory() -> void:
	inventory.clear()
	# Starter supplies from the escape pod emergency locker
	add_item("nutrient_brick", 2)
	add_item("filtered_water", 2)
	add_item("titanium", 4)
	add_item("kelp_fiber", 2)

func _process(delta: float) -> void:
	_update_time(delta)
	_update_metabolism(delta)

func _update_time(delta: float) -> void:
	current_time_hours += (delta * time_scale) / 3600.0
	if current_time_hours >= 24.0:
		current_time_hours -= 24.0
	_emit_time()

func _update_metabolism(delta: float) -> void:
	# Gradual hunger and thirst depletion
	modify_stat("hunger", -0.20 * delta)
	modify_stat("thirst", -0.32 * delta)

	# Starvation & Dehydration damage
	if player_stats.hunger <= 0.0 or player_stats.thirst <= 0.0:
		modify_stat("health", -1.8 * delta)

func _emit_time(force: bool = false) -> void:
	var hour := int(current_time_hours)
	var minute := int((current_time_hours - hour) * 60.0)
	if force or minute != _last_minute:
		_last_minute = minute
		EventBus.time_of_day_changed.emit(hour, minute)

func set_zone(new_zone: String) -> void:
	if current_zone != new_zone:
		current_zone = new_zone
		EventBus.zone_entered.emit(current_zone)

func modify_stat(stat: String, amount: float) -> float:
	var max_key := "max_" + stat
	if not player_stats.has(stat) or not player_stats.has(max_key):
		return 0.0
	var max_val: float = player_stats[max_key]
	var current_val: float = clampf(player_stats[stat] + amount, 0.0, max_val)
	player_stats[stat] = current_val

	match stat:
		"health":
			EventBus.player_health_changed.emit(current_val, max_val)
			if current_val <= 0.0:
				EventBus.player_died.emit()
		"stamina":
			EventBus.player_stamina_changed.emit(current_val, max_val)
		"oxygen":
			EventBus.player_oxygen_changed.emit(current_val, max_val)
	return current_val

func get_stat(stat: String) -> float:
	return player_stats.get(stat, 0.0)

func get_max_stat(stat: String) -> float:
	return player_stats.get("max_" + stat, 0.0)

func _emit_all_stats() -> void:
	EventBus.player_health_changed.emit(player_stats.health, player_stats.max_health)
	EventBus.player_stamina_changed.emit(player_stats.stamina, player_stats.max_stamina)
	EventBus.player_oxygen_changed.emit(player_stats.oxygen, player_stats.max_oxygen)

# --- Inventory Operations ---

func add_item(item_id: String, amount: int = 1) -> bool:
	var data: Resource = ItemDatabaseClass.get_item(item_id)
	if not data:
		return false

	var max_stack: int = data.get("max_stack")
	var item_name: String = data.get("name")
	var remaining := amount

	# 1. Stack into existing slots
	for slot in inventory:
		if slot["item_id"] == item_id and slot["amount"] < max_stack:
			var space: int = max_stack - slot["amount"]
			var to_add: int = mini(space, remaining)
			slot["amount"] += to_add
			remaining -= to_add
			if remaining <= 0:
				break

	# 2. Fill empty slots
	while remaining > 0 and inventory.size() < INVENTORY_CAPACITY:
		var to_add: int = mini(max_stack, remaining)
		inventory.append({"item_id": item_id, "amount": to_add})
		remaining -= to_add

	EventBus.inventory_updated.emit()
	EventBus.item_picked_up.emit(item_id, amount - remaining)
	EventBus.notification_posted.emit("+%d %s" % [amount - remaining, item_name], "pickup")
	return remaining == 0

func remove_item(item_id: String, amount: int = 1) -> bool:
	if get_item_count(item_id) < amount:
		return false

	var needed := amount
	var i := inventory.size() - 1
	while i >= 0 and needed > 0:
		if inventory[i]["item_id"] == item_id:
			var slot_amt: int = inventory[i]["amount"]
			if slot_amt <= needed:
				needed -= slot_amt
				inventory.remove_at(i)
			else:
				inventory[i]["amount"] -= needed
				needed = 0
		i -= 1

	EventBus.inventory_updated.emit()
	return true

func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in inventory:
		if slot["item_id"] == item_id:
			total += slot["amount"]
	return total

func has_ingredients(ingredients: Dictionary) -> bool:
	for req_id: String in ingredients:
		var req_amt: int = ingredients[req_id]
		if get_item_count(req_id) < req_amt:
			return false
	return true

func craft_recipe(recipe: Resource) -> bool:
	if not recipe:
		return false
	var ingredients: Dictionary = recipe.get("ingredients")
	if not has_ingredients(ingredients):
		return false

	for req_id: String in ingredients:
		remove_item(req_id, ingredients[req_id])

	var res_id: String = recipe.get("result_item_id")
	var res_amt: int = recipe.get("result_amount")
	add_item(res_id, res_amt)

	var result_data: Resource = ItemDatabaseClass.get_item(res_id)
	var item_name: String = result_data.get("name") if result_data else res_id
	EventBus.item_crafted.emit(res_id, res_amt)
	EventBus.notification_posted.emit("Crafted: %s" % item_name, "craft")
	return true

func use_or_equip_slot(slot_idx: int) -> bool:
	if slot_idx < 0 or slot_idx >= inventory.size():
		return false

	var slot := inventory[slot_idx]
	var item_id: String = slot["item_id"]
	var data: Resource = ItemDatabaseClass.get_item(item_id)
	if not data:
		return false

	var cat: int = data.get("category")
	var mods: Dictionary = data.get("stat_modifiers")
	var item_name: String = data.get("name")

	if cat == ItemDataClass.ItemCategory.CONSUMABLE:
		for stat_name: String in mods:
			var val: float = mods[stat_name]
			modify_stat(stat_name, val)
		remove_item(item_id, 1)
		EventBus.notification_posted.emit("Consumed %s" % item_name, "consume")
		return true

	elif cat == ItemDataClass.ItemCategory.EQUIPMENT:
		if mods.has("max_oxygen"):
			equipped_tank = item_id
			recalculate_equipment()
			EventBus.notification_posted.emit("Equipped %s" % item_name, "equip")
			return true
		elif mods.has("swim_speed_mult"):
			equipped_fins = item_id
			recalculate_equipment()
			EventBus.notification_posted.emit("Equipped %s" % item_name, "equip")
			return true

	return false

func recalculate_equipment() -> void:
	var base_oxygen := 100.0
	if equipped_tank == "standard_o2_tank":
		base_oxygen += 60.0
	elif equipped_tank == "high_capacity_o2_tank":
		base_oxygen += 120.0

	player_stats["max_oxygen"] = base_oxygen
	player_stats["oxygen"] = minf(player_stats["oxygen"], base_oxygen)
	EventBus.player_oxygen_changed.emit(player_stats["oxygen"], player_stats["max_oxygen"])

func _ensure_default_inputs() -> void:
	var default_mappings := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"sprint": [KEY_SHIFT],
		"interact": [KEY_E, KEY_F, KEY_SPACE],
		"toggle_inventory": [KEY_TAB, KEY_I],
		"hotbar_1": [KEY_1],
		"hotbar_2": [KEY_2],
		"hotbar_3": [KEY_3],
		"hotbar_4": [KEY_4],
		"hotbar_5": [KEY_5]
	}
	for action: String in default_mappings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for key_code in default_mappings[action]:
				var ev := InputEventKey.new()
				ev.physical_keycode = key_code
				InputMap.action_add_event(action, ev)

func save_game() -> bool:
	var data := {
		"version": "0.1.0",
		"time": current_time_hours,
		"player_stats": player_stats,
		"zone": current_zone,
		"inventory": inventory,
		"equipped_tank": equipped_tank,
		"equipped_fins": equipped_fins,
		"story_entries": story_entries
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to save game")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_text) == OK:
		var data: Dictionary = json.get_data()
		current_time_hours = data.get("time", 8.0)
		player_stats = data.get("player_stats", player_stats)
		var loaded_inv: Array = data.get("inventory", [])
		inventory.clear()
		for item in loaded_inv:
			if item is Dictionary:
				inventory.append(item)
		equipped_tank = data.get("equipped_tank", "")
		equipped_fins = data.get("equipped_fins", "")
		recalculate_equipment()
		story_entries = data.get("story_entries", [])
		_emit_all_stats()
		EventBus.inventory_updated.emit()
		return true
	return false
