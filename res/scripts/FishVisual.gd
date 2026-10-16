extends Node2D

## FishVisual - Procedural 2D vector renderer for passive alien ribbon fish.
## Displays bioluminescent cyan markings and animated undulating caudal fin.

var tail_phase: float = 0.0

func set_tail_phase(phase: float) -> void:
	tail_phase = phase
	queue_redraw()

func _draw() -> void:
	var body_color := Color(0.18, 0.78, 0.88, 0.95)
	var belly_color := Color(0.35, 0.95, 1.0, 0.95)
	var fin_color := Color(0.25, 0.85, 0.95, 0.65)
	var eye_color := Color(1.0, 0.78, 0.22, 1.0)
	var eye_pupil := Color(0.08, 0.12, 0.18, 1.0)

	var tail_wag := sin(tail_phase) * 8.0

	# 1. Undulating Tail Fin
	var tail_pts := PackedVector2Array([
		Vector2(-14.0, 0.0),
		Vector2(-26.0 + tail_wag * 0.3, -9.0 + tail_wag),
		Vector2(-32.0 + tail_wag * 0.5, 0.0 + tail_wag * 1.2),
		Vector2(-26.0 + tail_wag * 0.3, 9.0 + tail_wag)
	])
	draw_colored_polygon(tail_pts, fin_color)

	# 2. Sleek Torso & Flank
	var body_pts := PackedVector2Array([
		Vector2(16.0, 0.0),      # Snout
		Vector2(8.0, -8.0),      # Head top
		Vector2(-4.0, -6.0),     # Back
		Vector2(-14.0, 0.0),     # Tail base
		Vector2(-4.0, 6.0),      # Belly rear
		Vector2(8.0, 6.0)        # Belly front
	])
	draw_colored_polygon(body_pts, body_color)
	draw_polyline(body_pts, belly_color, 1.5)

	# 3. Translucent Dorsal Ribbon Fin
	var dorsal_pts := PackedVector2Array([
		Vector2(4.0, -7.0),
		Vector2(-2.0, -14.0),
		Vector2(-12.0, -5.0)
	])
	draw_colored_polygon(dorsal_pts, fin_color)

	# 4. Bioluminescent Large Eye
	draw_circle(Vector2(9.0, -2.0), 3.5, eye_color)
	draw_circle(Vector2(10.0, -2.0), 1.5, eye_pupil)
	draw_circle(Vector2(9.0, -3.0), 0.8, Color.WHITE) # Glint

