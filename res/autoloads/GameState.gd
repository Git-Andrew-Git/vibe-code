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

func _process(delta: float) -> void:
	_update_time(delta)

func _update_time(delta: float) -> void:
	current_time_hours += (delta * time_scale) / 3600.0
	if current_time_hours >= 24.0:
		current_time_hours -= 24.0

	var hour := int(current_time_hours)
	var minute := int((current_time_hours - hour) * 60.0)
	EventBus.time_of_day_changed.emit(hour, minute)

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
		return true
	return false
