extends CanvasModulate

## DayNightCycle - Controls dynamic environmental tone-mapping via CanvasModulate.
## Responds to GameState/EventBus time_of_day_changed to create dawn, day, sunset, and bioluminescent night.

@export var smoothing_speed: float = 3.0

var target_color: Color = Color.WHITE

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
	_evaluate_target_color(GameState.current_time_hours)
	color = target_color

func _process(delta: float) -> void:
	color = color.lerp(target_color, delta * smoothing_speed)

func _on_time_changed(hour: int, minute: int) -> void:
	var time_val := float(hour) + float(minute) / 60.0
	_evaluate_target_color(time_val)

func _evaluate_target_color(time_val: float) -> void:
	for i in range(SCHEDULE.size() - 1):
		var k1: Dictionary = SCHEDULE[i]
		var k2: Dictionary = SCHEDULE[i + 1]
		var h1: float = k1["hour"]
		var h2: float = k2["hour"]

		if time_val >= h1 and time_val <= h2:
			var t := (time_val - h1) / (h2 - h1)
			var c1: Color = k1["color"]
			var c2: Color = k2["color"]
			target_color = c1.lerp(c2, t)
			return
	target_color = SCHEDULE[0]["color"]

