extends Node2D

## DiverVisual - Procedural high-detail 2D vector diver graphics
## Renders wetsuit, oxygen tank, gold visor, and animated swimming flippers.

var kick_phase: float = 0.0
var is_swimming: bool = true

func set_kick_phase(phase: float, in_water: bool) -> void:
	kick_phase = phase
	is_swimming = in_water
	queue_redraw()

func _draw() -> void:
	# Palette aligned with Art Bible (cyans, teals, amber accents)
	var suit_color := Color(0.12, 0.38, 0.48, 1.0)
	var suit_highlight := Color(0.20, 0.55, 0.68, 1.0)
	var tank_color := Color(0.92, 0.62, 0.15, 1.0)
	var tank_strap := Color(0.15, 0.18, 0.22, 1.0)
	var visor_glow := Color(0.98, 0.82, 0.25, 0.95)
	var fin_color := Color(0.08, 0.25, 0.35, 1.0)

	# 1. Animated Flippers (kicking back and forth)
	var left_kick: float = sin(kick_phase) * 12.0 if is_swimming else sin(kick_phase) * 6.0
	var right_kick: float = -sin(kick_phase) * 12.0 if is_swimming else -sin(kick_phase) * 6.0

	# Left Fin
	var left_fin := PackedVector2Array([
		Vector2(-9.0, 16.0),
		Vector2(-14.0 + left_kick * 0.3, 34.0 + left_kick),
		Vector2(-6.0 + left_kick * 0.3, 36.0 + left_kick),
		Vector2(-4.0, 18.0)
	])
	draw_colored_polygon(left_fin, fin_color)

	# Right Fin
	var right_fin := PackedVector2Array([
		Vector2(4.0, 18.0),
		Vector2(6.0 + right_kick * 0.3, 36.0 + right_kick),
		Vector2(14.0 + right_kick * 0.3, 34.0 + right_kick),
		Vector2(9.0, 16.0)
	])
	draw_colored_polygon(right_fin, fin_color)

	# 2. Oxygen Tanks (Dual back cylinders)
	draw_rect(Rect2(-11.0, -10.0, 7.0, 24.0), tank_color, true)
	draw_rect(Rect2(4.0, -10.0, 7.0, 24.0), tank_color, true)
	draw_rect(Rect2(-12.0, -2.0, 24.0, 4.0), tank_strap, true) # Harness strap

	# 3. Torso / Wetsuit
	var body_pts := PackedVector2Array([
		Vector2(-14.0, -12.0),
		Vector2(14.0, -12.0),
		Vector2(12.0, 16.0),
		Vector2(-12.0, 16.0)
	])
	draw_colored_polygon(body_pts, suit_color)
	draw_polyline(body_pts, suit_highlight, 2.0)

	# 4. Arms
	draw_line(Vector2(-14.0, -8.0), Vector2(-18.0, 6.0), suit_color, 6.0)
	draw_line(Vector2(14.0, -8.0), Vector2(18.0, 6.0), suit_color, 6.0)

	# 5. Helmet & Gold Visor
	draw_circle(Vector2(0.0, -18.0), 12.0, suit_highlight)
	# Oval visor facing forward (-Y)
	draw_rect(Rect2(-8.0, -26.0, 16.0, 8.0), visor_glow, true)
	draw_rect(Rect2(-7.0, -25.0, 6.0, 2.0), Color.WHITE, true) # Glint

	# 6. Flashlight beam cone (translucent forward lighting)
	var light_cone := PackedVector2Array([
		Vector2(0.0, -24.0),
		Vector2(-70.0, -220.0),
		Vector2(70.0, -220.0)
	])
	draw_colored_polygon(light_cone, Color(0.9, 0.95, 1.0, 0.12))
