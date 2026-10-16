extends Node2D

## Main - Game scene controller
## Connects UI HUD to EventBus signals (time, zone, player vitals, movement mode, depth).

const PlayerClass = preload("res://res/scripts/Player.gd")

@onready var player: CharacterBody2D = $Player
@onready var time_label: Label = $UI/HUD/InfoContainer/TimeLabel
@onready var zone_label: Label = $UI/HUD/InfoContainer/ZoneLabel
@onready var depth_label: Label = $UI/HUD/InfoContainer/DepthLabel
@onready var mode_label: Label = $UI/HUD/InfoContainer/MovementModeLabel

@onready var health_label: Label = $UI/HUD/VitalsContainer/HealthSection/HealthLabel
@onready var health_bar: ProgressBar = $UI/HUD/VitalsContainer/HealthSection/HealthBar

@onready var oxygen_label: Label = $UI/HUD/VitalsContainer/OxygenSection/OxygenLabel
@onready var oxygen_bar: ProgressBar = $UI/HUD/VitalsContainer/OxygenSection/OxygenBar

@onready var stamina_label: Label = $UI/HUD/VitalsContainer/StaminaSection/StaminaLabel
@onready var stamina_bar: ProgressBar = $UI/HUD/VitalsContainer/StaminaSection/StaminaBar

@onready var hunger_label: Label = $UI/HUD/VitalsContainer/HungerSection/HungerLabel
@onready var hunger_bar: ProgressBar = $UI/HUD/VitalsContainer/HungerSection/HungerBar

@onready var thirst_label: Label = $UI/HUD/VitalsContainer/ThirstSection/ThirstLabel
@onready var thirst_bar: ProgressBar = $UI/HUD/VitalsContainer/ThirstSection/ThirstBar

@onready var pda_button: Button = $UI/HUD/PDAButton

func _ready() -> void:
	print("Game initialized successfully.")
	print("Target Native Resolution: 1920x1080 (Canvas Items scaling enabled)")

	# Connect World & Time signals
	EventBus.time_of_day_changed.connect(_on_time_changed)
	EventBus.zone_entered.connect(_on_zone_changed)

	# Connect Player Vitals signals
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_oxygen_changed.connect(_on_oxygen_changed)
	EventBus.player_stamina_changed.connect(_on_stamina_changed)
	EventBus.player_died.connect(_on_player_died)

	if pda_button:
		pda_button.pressed.connect(func(): EventBus.ui_toggle_requested.emit("inventory"))

	# Initial values from GameState
	_update_all_vitals()

func _process(_delta: float) -> void:
	_update_movement_mode_ui()
	_update_metabolism_ui()
	_update_depth_ui()

func _update_movement_mode_ui() -> void:
	if not player or not mode_label:
		return

	var is_swimming: bool = player.get("mode") == PlayerClass.MovementMode.SWIMMING
	var is_sprinting: bool = player.get("is_sprinting")

	if is_swimming:
		if is_sprinting:
			mode_label.text = "State: SWIMMING (Fast Sprint)"
			mode_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.95))
		else:
			mode_label.text = "State: SWIMMING (Underwater)"
			mode_label.add_theme_color_override("font_color", Color(0.3, 0.75, 0.95))
	else:
		if is_sprinting:
			mode_label.text = "State: WALKING (Aboard Pod - Running)"
			mode_label.add_theme_color_override("font_color", Color(0.98, 0.85, 0.35))
		else:
			mode_label.text = "State: WALKING (Aboard Pod)"
			mode_label.add_theme_color_override("font_color", Color(0.95, 0.72, 0.25))

func _update_metabolism_ui() -> void:
	var hunger := GameState.get_stat("hunger")
	var max_hunger := GameState.get_max_stat("hunger")
	if hunger_bar and hunger_label:
		hunger_bar.max_value = max_hunger
		hunger_bar.value = hunger
		hunger_label.text = "FOOD: %d / %d" % [int(hunger), int(max_hunger)]

	var thirst := GameState.get_stat("thirst")
	var max_thirst := GameState.get_max_stat("thirst")
	if thirst_bar and thirst_label:
		thirst_bar.max_value = max_thirst
		thirst_bar.value = thirst
		thirst_label.text = "WATER: %d / %d" % [int(thirst), int(max_thirst)]

func _update_depth_ui() -> void:
	if player and depth_label:
		var d: float = player.get("depth_meters")
		depth_label.text = "Depth: %dm" % int(d)

func _on_time_changed(hour: int, minute: int) -> void:
	time_label.text = "Time: %02d:%02d" % [hour, minute]

func _on_zone_changed(zone_name: String) -> void:
	zone_label.text = "Zone: %s" % zone_name

func _on_health_changed(current: float, max_val: float) -> void:
	health_bar.max_value = max_val
	health_bar.value = current
	health_label.text = "HEALTH: %d / %d" % [int(current), int(max_val)]

func _on_oxygen_changed(current: float, max_val: float) -> void:
	oxygen_bar.max_value = max_val
	oxygen_bar.value = current
	oxygen_label.text = "OXYGEN: %d / %d" % [int(current), int(max_val)]

func _on_stamina_changed(current: float, max_val: float) -> void:
	stamina_bar.max_value = max_val
	stamina_bar.value = current
	stamina_label.text = "STAMINA: %d / %d" % [int(current), int(max_val)]

func _on_player_died() -> void:
	mode_label.text = "State: CRITICAL CONDITION (Depleted)"
	mode_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))

func _update_all_vitals() -> void:
	_on_health_changed(GameState.get_stat("health"), GameState.get_max_stat("health"))
	_on_oxygen_changed(GameState.get_stat("oxygen"), GameState.get_max_stat("oxygen"))
	_on_stamina_changed(GameState.get_stat("stamina"), GameState.get_max_stat("stamina"))
	_update_metabolism_ui()
	zone_label.text = "Zone: %s" % GameState.current_zone
