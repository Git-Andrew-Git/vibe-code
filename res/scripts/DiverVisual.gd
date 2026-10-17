extends Node2D

## DiverVisual - Procedural high-detail 2D vector diver graphics (Side-View)
## Renders side-profile wetsuit, single back oxygen tank, gold visor,
## animated swimming flippers, and forward-projecting flashlight beam.

var kick_phase: float = 0.0
var is_swimming: bool = true

func set_kick_phase(phase: float, in_water: bool = true) -> void:
	kick_phase = phase
	is_swimming = in_water
	queue_redraw()

func update_kick(phase: float) -> void:
	kick_phase = phase
	queue_redraw()

func _draw() -> void:
	# Palette aligned with Art Bible (cyans, teals, amber accents)
	var suit_color := Color(0.12, 0.38, 0.48, 1.0)
	var suit_highlight := Color(0.20, 0.55, 0.68, 1.0)
	var tank_color := Color(0.92, 0.62, 0.15, 1.0)
	var tank_strap := Color(0.15, 0.18, 0.22, 1.0)
	var tank_cap := Color(0.72, 0.78, 0.85, 1.0)
	var visor_glow := Color(0.98, 0.82, 0.25, 0.95)
	var fin_color := Color(0.08, 0.25, 0.35, 1.0)
	var fin_back_color := Color(0.05, 0.18, 0.26, 1.0)

	# 1. Animated Flippers (kicking back and forth behind/below the diver)
	# Divers face +X, legs extend behind (-X) and oscillate in Y
	var kick_1: float = sin(kick_phase) * 10.0 if is_swimming else sin(kick_phase) * 4.0
	var kick_2: float = -sin(kick_phase) * 10.0 if is_swimming else -sin(kick_phase) * 4.0

	# Background Leg & Fin (drawn behind body)
	var back_leg := PackedVector2Array([
		Vector2(-4.0, 6.0),
		Vector2(-14.0, 10.0 + kick_2 * 0.2),
		Vector2(-18.0, 14.0 + kick_2 * 0.3),
		Vector2(-7.0, 10.0)
	])
	draw_colored_polygon(back_leg, suit_color.darkened(0.2))

	var back_fin := PackedVector2Array([
		Vector2(-16.0, 13.0 + kick_2 * 0.3),
		Vector2(-34.0, 16.0 + kick_2),
		Vector2(-33.0, 23.0 + kick_2),
		Vector2(-18.0, 17.0 + kick_2 * 0.3)
	])
	draw_colored_polygon(back_fin, fin_back_color)

	# 2. Single Oxygen Tank on Back (-X side behind diver)
	# Cylinder body
	draw_rect(Rect2(-16.0, -14.0, 8.0, 22.0), tank_color, true)
	# Tank valve / regulator at top
	draw_rect(Rect2(-14.0, -17.0, 4.0, 3.0), tank_cap, true)
	# Harness straps securing tank across shoulder and waist
	draw_line(Vector2(-12.0, -10.0), Vector2(0.0, -6.0), tank_strap, 3.0)
	draw_line(Vector2(-12.0, 2.0), Vector2(2.0, 4.0), tank_strap, 3.0)

	# 3. Torso / Wetsuit in Side Profile
	# Streamlined side silhouette: back at -X, chest/stomach at +X
	var torso_pts := PackedVector2Array([
		Vector2(-8.0, -10.0),  # Upper back
		Vector2(3.0, -10.0),   # Front neck
		Vector2(9.0, -3.0),    # Chest
		Vector2(7.0, 7.0),     # Abdomen / waist
		Vector2(-2.0, 11.0),   # Groin / pelvic base
		Vector2(-8.0, 7.0),    # Lower back / buttock
		Vector2(-10.0, -2.0)   # Mid back
	])
	draw_colored_polygon(torso_pts, suit_color)
	draw_polyline(torso_pts, suit_highlight, 2.0)

	# 4. Foreground Leg & Fin
	var fore_leg := PackedVector2Array([
		Vector2(-2.0, 7.0),
		Vector2(-12.0, 12.0 + kick_1 * 0.2),
		Vector2(-16.0, 16.0 + kick_1 * 0.3),
		Vector2(-5.0, 11.0)
	])
	draw_colored_polygon(fore_leg, suit_color)

	var fore_fin := PackedVector2Array([
		Vector2(-14.0, 15.0 + kick_1 * 0.3),
		Vector2(-32.0, 19.0 + kick_1),
		Vector2(-31.0, 26.0 + kick_1),
		Vector2(-16.0, 19.0 + kick_1 * 0.3)
	])
	draw_colored_polygon(fore_fin, fin_color)

	# 5. Arm & Flashlight Device
	# Shoulder at (2, -5), forearm extending forward to hand at (18, 0)
	draw_line(Vector2(2.0, -5.0), Vector2(10.0, 0.0), suit_color, 5.0)
	draw_line(Vector2(10.0, 0.0), Vector2(17.0, 0.0), suit_highlight, 4.0)
	# Handheld diving light casing
	draw_rect(Rect2(16.0, -3.0, 7.0, 6.0), Color(0.22, 0.28, 0.34), true)
	draw_circle(Vector2(23.0, 0.0), 3.0, Color(0.9, 0.96, 1.0))

	# 6. Helmet & Front Visor (Side Profile)
	# Dome of helmet centered slightly forward
	draw_circle(Vector2(4.0, -16.0), 11.0, suit_highlight)
	# Gold visor on the front (+X) side of the helmet
	var visor_pts := PackedVector2Array([
		Vector2(8.0, -22.0),
		Vector2(14.0, -19.0),
		Vector2(15.0, -13.0),
		Vector2(11.0, -9.0),
		Vector2(7.0, -10.0)
	])
	draw_colored_polygon(visor_pts, visor_glow)
	# Curved glint highlight on visor glass
	draw_line(Vector2(10.0, -19.0), Vector2(13.0, -15.0), Color.WHITE, 1.5)

	# 7. Flashlight beam cone (translucent forward lighting in +X direction)
	var light_cone := PackedVector2Array([
		Vector2(23.0, 0.0),
		Vector2(200.0, -60.0),
		Vector2(220.0, 0.0),
		Vector2(200.0, 60.0)
	])
	draw_colored_polygon(light_cone, Color(0.9, 0.95, 1.0, 0.12))

