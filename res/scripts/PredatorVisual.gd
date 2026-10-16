extends Node2D

## PredatorVisual - Procedural 2D vector renderer for the territorial Abyssal Stalker.
## Features armored carapace plates, glowing predatory eyes, and articulated razor mandibles.

var phase: float = 0.0
var jaw_open: bool = false
var is_lunging: bool = false

func set_visual_state(p: float, open_jaws: bool, lunging: bool) -> void:
	phase = p
	jaw_open = open_jaws
	is_lunging = lunging
	queue_redraw()

func _draw() -> void:
	var armor_color := Color(0.08, 0.15, 0.22, 1.0)
	var armor_highlight := Color(0.15, 0.32, 0.42, 1.0)
	var eye_color := Color(1.0, 0.18, 0.18, 1.0)
	var spine_color := Color(0.92, 0.32, 0.15, 0.9)
	var tooth_color := Color(0.95, 0.95, 0.98, 1.0)

	var tail_wag := sin(phase) * 14.0

	# 1. Articulated Tail & Dorsal Spine
	var tail_pts := PackedVector2Array([
		Vector2(-20.0, 0.0),
		Vector2(-42.0 + tail_wag * 0.3, -10.0 + tail_wag * 0.7),
		Vector2(-64.0 + tail_wag * 0.6, 0.0 + tail_wag * 1.3),
		Vector2(-42.0 + tail_wag * 0.3, 10.0 + tail_wag * 0.7)
	])
	draw_colored_polygon(tail_pts, armor_color)

	# Tail fin flukes
	draw_line(Vector2(-50.0 + tail_wag * 0.5, 0.0 + tail_wag), Vector2(-70.0 + tail_wag * 0.7, -16.0 + tail_wag * 1.4), spine_color, 4.0)
	draw_line(Vector2(-50.0 + tail_wag * 0.5, 0.0 + tail_wag), Vector2(-70.0 + tail_wag * 0.7, 16.0 + tail_wag * 1.4), spine_color, 4.0)

	# 2. Heavy Armored Torso
	var body_pts := PackedVector2Array([
		Vector2(25.0, 0.0),     # Snout base
		Vector2(12.0, -14.0),   # Head crest
		Vector2(-8.0, -12.0),   # Dorsal ridge
		Vector2(-20.0, 0.0),    # Tail junction
		Vector2(-8.0, 12.0),    # Ventral ridge
		Vector2(12.0, 14.0)     # Throat
	])
	draw_colored_polygon(body_pts, armor_color)
	draw_polyline(body_pts, armor_highlight, 2.0)

	# Dorsal spines
	draw_line(Vector2(2.0, -13.0), Vector2(-4.0, -26.0), spine_color, 3.0)
	draw_line(Vector2(-10.0, -10.0), Vector2(-16.0, -22.0), spine_color, 3.0)

	# 3. Predatory Glowing Eyes (Dual angled slit eyes)
	draw_circle(Vector2(14.0, -6.0), 3.5, eye_color)
	draw_circle(Vector2(14.0, 6.0), 3.5, eye_color)
	draw_circle(Vector2(16.0, -6.0), 1.2, Color.WHITE)
	draw_circle(Vector2(16.0, 6.0), 1.2, Color.WHITE)

	# 4. Articulated Mandibles (Jaws open during pursuit/attack)
	var jaw_spread := 10.0 if jaw_open else 3.0
	if is_lunging:
		jaw_spread = 14.0

	# Upper Mandible
	var upper_jaw := PackedVector2Array([
		Vector2(22.0, -4.0),
		Vector2(42.0, -jaw_spread),
		Vector2(32.0, -1.0)
	])
	draw_colored_polygon(upper_jaw, armor_highlight)
	# Upper Fangs
	draw_line(Vector2(30.0, -jaw_spread * 0.6), Vector2(30.0, 2.0), tooth_color, 2.0)
	draw_line(Vector2(38.0, -jaw_spread * 0.8), Vector2(38.0, 0.0), tooth_color, 2.0)

	# Lower Mandible
	var lower_jaw := PackedVector2Array([
		Vector2(22.0, 4.0),
		Vector2(42.0, jaw_spread),
		Vector2(32.0, 1.0)
	])
	draw_colored_polygon(lower_jaw, armor_highlight)
	# Lower Fangs
	draw_line(Vector2(30.0, jaw_spread * 0.6), Vector2(30.0, -2.0), tooth_color, 2.0)
	draw_line(Vector2(38.0, jaw_spread * 0.8), Vector2(38.0, 0.0), tooth_color, 2.0)

