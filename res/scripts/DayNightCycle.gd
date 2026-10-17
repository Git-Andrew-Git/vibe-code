extends CanvasModulate

## DayNightCycle - Controls dynamic environmental tone-mapping via CanvasModulate.
## Responds to GameState/EventBus time_of_day_changed to create dawn, day, sunset, and bioluminescent night.
## Incorporates depth-based darkness: deeper water is darker regardless of time of day.

@export var smoothing_speed: float = 3.0
@export var player_path: NodePath = NodePath("../Player")

var target_color: Color = Color.WHITE
var surface_color: Color = Color.WHITE
var player: Node2D = null

# 24-hour color palette table
const SCHEDULE := [
	{"hour": 0.0, "color": Color(0.12, 0.15, 0.26, 1.0)},   # Deep Midnight
	{"hour": 4.5, "color": Color(0.12, 0.15, 0.26, 1.0)},   # Night
	{"hour": 5.5, "color": Color(0.24, 0.26, 0.42, 1.0)},   # Pre-dawn Twilight
	{"hour": 7.0, "color": Color(0.92, 0.68, 0.52, 1.0)},   # Golden Dawn
	{"hour": 8.5, "color": Color(1.0, 1.0, 1.0, 1.0)},       # Full Daylight
	{"hour": 16.5, "color": Color(1.0, 1.0, 1.0, 1.0)},      # Afternoon
	{"hour": 18.0, "color": Color(0.90, 0.55, 0.45, 1.0)},   # Amber Sunset
	{"hour": 19.5, "color": Color(0.35, 0.22, 0.52, 1.0)},   # Violet Dusk
	{"hour": 21.0, "color": Color(0.12, 0.15, 0.26, 1.0)},   # Return to Night
	{"hour": 24.0, "color": Color(0.12, 0.15, 0.26, 1.0)}
]

func _ready() -> void:
	EventBus.time_of_day_changed.connect(_on_time_changed)
	_find_player()
	_evaluate_surface_color(GameState.current_time_hours)
	_update_target_color()
	color = target_color

func _process(delta: float) -> void:
	_update_target_color()
	color = color.lerp(target_color, delta * smoothing_speed)

func _on_time_changed(hour: int, minute: int) -> void:
	var time_val := float(hour) + float(minute) / 60.0
	_evaluate_surface_color(time_val)

func _evaluate_surface_color(time_val: float) -> void:
	for i in range(SCHEDULE.size() - 1):
		var k1: Dictionary = SCHEDULE[i]
		var k2: Dictionary = SCHEDULE[i + 1]
		var h1: float = k1["hour"]
		var h2: float = k2["hour"]

		if time_val >= h1 and time_val <= h2:
			var t := (time_val - h1) / (h2 - h1)
			var c1: Color = k1["color"]
			var c2: Color = k2["color"]
			surface_color = c1.lerp(c2, t)
			return
	surface_color = SCHEDULE[0]["color"]

## Backward compatibility if called externally
func _evaluate_target_color(time_val: float) -> void:
	_evaluate_surface_color(time_val)
	_update_target_color()

func _find_player() -> void:
	if player_path and has_node(player_path):
		player = get_node(player_path) as Node2D
	elif is_inside_tree():
		player = get_tree().get_first_node_in_group("Player") as Node2D

func _get_player_depth() -> float:
	if not player:
		_find_player()
	if player:
		var d = player.get("depth_meters")
		if d != null:
			return float(d)
		elif "global_position" in player:
			return maxf(0.0, player.global_position.y / 25.0)
	return 0.0

func _update_target_color() -> void:
	var depth := _get_player_depth()

	# At surface or above water, full time-of-day surface lighting
	if depth <= 0.0:
		target_color = surface_color
		return

	# Depth attenuation factor:
	# 0m -> 1.0 (surface daylight/night schedule)
	# 100m (Y=2500) -> 0.12 (very dark ambient regardless of surface time)
	# 200m (Y=5000) -> 0.02 (nearly pitch black)
	# >200m -> pitch black deep abyss
	var depth_factor: float
	if depth <= 100.0:
		var t := depth / 100.0
		depth_factor = lerpf(1.0, 0.12, t)
	elif depth <= 200.0:
		var t := (depth - 100.0) / 100.0
		depth_factor = lerpf(0.12, 0.02, t)
	else:
		var t := clampf((depth - 200.0) / 100.0, 0.0, 1.0)
		depth_factor = lerpf(0.02, 0.008, t)

	# Deep abyssal ambient color
	var deep_abyss_color := Color(0.015, 0.02, 0.035, 1.0)
	var abyss_weight := clampf(depth / 200.0, 0.0, 1.0)

	var dimmed_surface := surface_color * depth_factor
	dimmed_surface.a = 1.0

	var blended: Color = dimmed_surface.lerp(deep_abyss_color, abyss_weight * 0.75)

	# Ensure that at depth >= 100m, ambient light is very dark regardless of surface daytime brightness
	if depth >= 100.0:
		var max_allowed := lerpf(0.12, 0.02, clampf((depth - 100.0) / 100.0, 0.0, 1.0))
		blended.r = minf(blended.r, max_allowed)
		blended.g = minf(blended.g, max_allowed)
		blended.b = minf(blended.b, max_allowed * 1.35)

	blended.a = 1.0
	target_color = blended
