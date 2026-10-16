extends Node2D

## ReefVisual - Procedural bioluminescent alien coral and kelp formations
## Adds visual landmarks in the Alien Shallows biome.

@export var reef_radius: float = 65.0
@export var coral_color: Color = Color(0.18, 0.65, 0.72, 0.85) # Bioluminescent cyan
@export var accent_color: Color = Color(0.85, 0.22, 0.65, 0.9) # Magenta flora accents

func _draw() -> void:
	# Base coral mound
	draw_circle(Vector2.ZERO, reef_radius, coral_color)
	draw_circle(Vector2(reef_radius * 0.4, -reef_radius * 0.2), reef_radius * 0.5, accent_color)
	draw_circle(Vector2(-reef_radius * 0.3, reef_radius * 0.3), reef_radius * 0.4, coral_color.lightened(0.2))

	# Bioluminescent spore nodes
	for i in range(5):
		var angle := i * (TAU / 5.0)
		var pos := Vector2(cos(angle), sin(angle)) * (reef_radius * 0.65)
		draw_circle(pos, 5.0, Color(0.9, 0.98, 1.0, 0.95))
