extends Node

## GameState - Global manager for world state, player stats, time, and save/load system.

const SAVE_PATH := "user://savegame.json"

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

func _ready() -> void:
	_ensure_default_inputs()
	_emit_time(true)
	EventBus.zone_entered.emit(current_zone)
	_emit_all_stats()

func _process(delta: float) -> void:
	_update_time(delta)

func _update_time(delta: float) -> void:
	current_time_hours += (delta * time_scale) / 3600.0
	if current_time_hours >= 24.0:
		current_time_hours -= 24.0
	_emit_time()

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

func _ensure_default_inputs() -> void:
	var default_mappings := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"sprint": [KEY_SHIFT],
		"interact": [KEY_E, KEY_F, KEY_SPACE]
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
		"zone": current_zone
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
		current_zone = data.get("zone", "Alien Shallows")
		_emit_all_stats()
		return true
	return false
