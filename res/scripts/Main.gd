extends Node2D

@onready var time_label: Label = $UI/HUD/TimeLabel
@onready var zone_label: Label = $UI/HUD/ZoneLabel

func _ready() -> void:
	print("Game initialized successfully.")
	print("Target Native Resolution: 1920x1080 (Canvas Items scaling enabled)")
	
	EventBus.time_of_day_changed.connect(_on_time_changed)
	EventBus.zone_entered.connect(_on_zone_changed)

func _on_time_changed(hour: int, minute: int) -> void:
	time_label.text = "Time: %02d:%02d" % [hour, minute]

func _on_zone_changed(zone_name: String) -> void:
	zone_label.text = "Zone: %s" % zone_name
