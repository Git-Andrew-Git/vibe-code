extends Node2D

## ReefVisual - Procedural bioluminescent alien coral and kelp formations (Side-View)
## Renders seabed coral reef formations growing upward: branching corals,
## tube sponges, fan corals, and glowing bioluminescent spore nodes.

@export var reef_radius: float = 65.0
@export var coral_color: Color = Color(0.18, 0.65, 0.72, 0.85) # Bioluminescent cyan
@export var accent_color: Color = Color(0.85, 0.22, 0.65, 0.9) # Magenta flora accents

func _draw() -> void:
	var r := reef_radius
	var bio_glow := Color(0.85, 0.98, 1.0, 0.95)
	var bio_accent := Color(1.0, 0.55, 0.9, 0.95)

	# 1. Seabed Base Mound (anchoring the reef at the bottom of the node)
	var base_pts := PackedVector2Array([
		Vector2(-r * 1.05, r * 0.35),
		Vector2(-r * 0.8, r * 0.15),
		Vector2(-r * 0.3, r * 0.08),
		Vector2(r * 0.2, r * 0.12),
		Vector2(r * 0.7, r * 0.18),
		Vector2(r * 1.05, r * 0.35),
		Vector2(r * 0.8, r * 0.45),
		Vector2(-r * 0.8, r * 0.45)
	])
	draw_colored_polygon(base_pts, coral_color.darkened(0.6))
	draw_polyline(base_pts, coral_color.darkened(0.3), 2.0)

	# 2. Tube Sponges (Left side - cylindrical hollow tubes growing upward)
	# Tube Sponge 1 (tall)
	var tube1_pts := PackedVector2Array([
		Vector2(-r * 0.56, r * 0.15),
		Vector2(-r * 0.52, -r * 0.75),
		Vector2(-r * 0.38, -r * 0.75),
		Vector2(-r * 0.40, r * 0.15)
	])
	draw_colored_polygon(tube1_pts, coral_color.darkened(0.15))
	draw_polyline(tube1_pts, coral_color, 1.5)
	# Hollow tube opening rim at top
	draw_ellipse(Vector2(-r * 0.45, -r * 0.75), r * 0.07, r * 0.03, coral_color.darkened(0.5))
	draw_arc(Vector2(-r * 0.45, -r * 0.75), r * 0.07, 0, TAU, 16, bio_glow, 1.5)

	# Tube Sponge 2 (medium, slightly tilted)
	var tube2_pts := PackedVector2Array([
		Vector2(-r * 0.38, r * 0.12),
		Vector2(-r * 0.33, -r * 0.50),
		Vector2(-r * 0.22, -r * 0.50),
		Vector2(-r * 0.24, r * 0.12)
	])
	draw_colored_polygon(tube2_pts, coral_color)
	draw_polyline(tube2_pts, coral_color.lightened(0.2), 1.5)
	draw_ellipse(Vector2(-r * 0.275, -r * 0.50), r * 0.055, r * 0.025, coral_color.darkened(0.45))
	draw_arc(Vector2(-r * 0.275, -r * 0.50), r * 0.055, 0, TAU, 16, bio_glow, 1.5)

	# 3. Branching Coral Formations (Center - antler-like branches reaching upward)
	# Main central trunk
	draw_line(Vector2(-r * 0.05, r * 0.12), Vector2(0.0, -r * 0.20), coral_color.lightened(0.15), 6.0)

	# Left branch splits
	draw_line(Vector2(0.0, -r * 0.20), Vector2(-r * 0.18, -r * 0.55), coral_color.lightened(0.1), 4.5)
	draw_line(Vector2(-r * 0.18, -r * 0.55), Vector2(-r * 0.28, -r * 0.85), coral_color.lightened(0.2), 3.0)
	draw_line(Vector2(-r * 0.18, -r * 0.55), Vector2(-r * 0.12, -r * 0.88), coral_color.lightened(0.2), 3.0)

	# Center branch splits
	draw_line(Vector2(0.0, -r * 0.20), Vector2(r * 0.04, -r * 0.65), coral_color.lightened(0.15), 4.5)
	draw_line(Vector2(r * 0.04, -r * 0.65), Vector2(-r * 0.02, -r * 0.98), coral_color.lightened(0.25), 3.0)
	draw_line(Vector2(r * 0.04, -r * 0.65), Vector2(r * 0.12, -r * 0.92), coral_color.lightened(0.25), 3.0)

	# Right branch splits
	draw_line(Vector2(0.0, -r * 0.20), Vector2(r * 0.20, -r * 0.48), coral_color.lightened(0.1), 4.0)
	draw_line(Vector2(r * 0.20, -r * 0.48), Vector2(r * 0.28, -r * 0.78), coral_color.lightened(0.2), 3.0)

	# 4. Fan Coral (Right side - delicate fan lattice spreading upward in accent color)
	var fan_origin := Vector2(r * 0.45, r * 0.15)
	# Fan trunk
	draw_line(fan_origin, Vector2(r * 0.48, -r * 0.05), accent_color.darkened(0.2), 4.0)
	# Radiating fan ribs
	var fan_tips := [
		Vector2(r * 0.22, -r * 0.58),
		Vector2(r * 0.38, -r * 0.78),
		Vector2(r * 0.56, -r * 0.82),
		Vector2(r * 0.72, -r * 0.68),
		Vector2(r * 0.84, -r * 0.45)
	]
	# Semi-transparent fan web background
	var fan_poly := PackedVector2Array([Vector2(r * 0.48, -r * 0.05)])
	for tip in fan_tips:
		fan_poly.append(tip)
	draw_colored_polygon(fan_poly, Color(accent_color.r, accent_color.g, accent_color.b, 0.28))

	# Fan ribs & connecting arches
	for tip in fan_tips:
		draw_line(Vector2(r * 0.48, -r * 0.05), tip, accent_color, 2.0)
	for j in range(fan_tips.size() - 1):
		draw_line(fan_tips[j], fan_tips[j + 1], accent_color.lightened(0.15), 2.0)
		var mid1 := fan_origin.lerp(fan_tips[j], 0.55)
		var mid2 := fan_origin.lerp(fan_tips[j + 1], 0.55)
		draw_line(mid1, mid2, accent_color, 1.5)

	# 5. Bioluminescent Spores / Nodes (glowing tips and nodes)
	var spore_positions := [
		Vector2(-r * 0.28, -r * 0.85),
		Vector2(-r * 0.12, -r * 0.88),
		Vector2(-r * 0.02, -r * 0.98),
		Vector2(r * 0.12, -r * 0.92),
		Vector2(r * 0.28, -r * 0.78),
		Vector2(-r * 0.45, -r * 0.75),
		Vector2(-r * 0.275, -r * 0.50),
		Vector2(r * 0.38, -r * 0.78),
		Vector2(r * 0.56, -r * 0.82),
		Vector2(r * 0.72, -r * 0.68)
	]

	for i in range(spore_positions.size()):
		var spos: Vector2 = spore_positions[i]
		var col: Color = bio_accent if (i >= 7) else bio_glow
		# Outer glow halo
		draw_circle(spos, 6.0, Color(col.r, col.g, col.b, 0.25))
		# Bright core
		draw_circle(spos, 3.2, col)


