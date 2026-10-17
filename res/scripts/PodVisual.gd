extends Node2D

## PodVisual - Procedural 2D render for the emergency escape pod (Side-View)
## Amber hull floating at waterline (Y=0), rooftop solar panels & beacon,
## interior cabin cross-section with fabricator area, and bottom exit hatch/ladder.

func _draw() -> void:
	# Pod colors (warm amber for player structures per Art Bible)
	var hull_color := Color(0.88, 0.56, 0.18, 1.0)
	var deck_color := Color(0.22, 0.25, 0.30, 1.0)
	var rim_color := Color(0.98, 0.72, 0.30, 1.0)
	var solar_blue := Color(0.12, 0.45, 0.75, 1.0)
	var beacon_red := Color(1.0, 0.25, 0.25, 0.9)
	var interior_bg := Color(0.13, 0.16, 0.21, 1.0)
	var water_accent := Color(0.18, 0.65, 0.80, 0.5)

	# 1. Outer Pod Hull Profile (~240px wide x 150px tall, centered at Y=0 waterline)
	# Upper hull (above water, Y < 0) and lower submerged hull (underwater, Y > 0)
	var hull_pts := PackedVector2Array([
		Vector2(-65.0, -66.0),   # Upper roof left
		Vector2(65.0, -66.0),    # Upper roof right
		Vector2(115.0, -15.0),   # Upper sponson right
		Vector2(120.0, 0.0),     # Waterline right
		Vector2(110.0, 30.0),    # Submerged curve right
		Vector2(75.0, 68.0),     # Lower keel right
		Vector2(32.0, 74.0),     # Bottom hatch rim right
		Vector2(-32.0, 74.0),    # Bottom hatch rim left
		Vector2(-75.0, 68.0),    # Lower keel left
		Vector2(-110.0, 30.0),   # Submerged curve left
		Vector2(-120.0, 0.0),    # Waterline left
		Vector2(-115.0, -15.0)   # Upper sponson left
	])
	draw_colored_polygon(hull_pts, hull_color)
	draw_polyline(hull_pts, rim_color, 3.5)

	# Waterline buoyancy collar trim (amber/gold band along Y=0)
	draw_rect(Rect2(-120.0, -8.0, 240.0, 16.0), rim_color.darkened(0.15), true)
	draw_rect(Rect2(-118.0, -4.0, 236.0, 8.0), rim_color, true)

	# 2. Interior Cabin Cross-Section (cutaway view)
	var interior_pts := PackedVector2Array([
		Vector2(-55.0, -52.0),
		Vector2(55.0, -52.0),
		Vector2(95.0, -12.0),
		Vector2(92.0, 28.0),
		Vector2(58.0, 52.0),
		Vector2(26.0, 56.0),
		Vector2(-26.0, 56.0),
		Vector2(-58.0, 52.0),
		Vector2(-92.0, 28.0),
		Vector2(-95.0, -12.0)
	])
	draw_colored_polygon(interior_pts, interior_bg)
	draw_polyline(interior_pts, deck_color.lightened(0.2), 2.0)

	# Interior floor deck plates (left and right of central moonpool hatch)
	draw_rect(Rect2(-92.0, 28.0, 66.0, 8.0), deck_color, true)
	draw_rect(Rect2(26.0, 28.0, 66.0, 8.0), deck_color, true)

	# 3. Fabricator Area (inside cabin, left wall)
	# Fabricator main console housing
	draw_rect(Rect2(-86.0, -22.0, 36.0, 48.0), deck_color.lightened(0.1), true)
	draw_rect(Rect2(-86.0, -22.0, 36.0, 48.0), rim_color, false, 1.5)
	# Holographic fabrication chamber alcove
	draw_rect(Rect2(-82.0, -2.0, 28.0, 24.0), Color(0.08, 0.12, 0.18), true)
	draw_rect(Rect2(-80.0, 0.0, 24.0, 20.0), Color(0.2, 0.75, 0.9, 0.35), true)
	# Glowing cyan fabricator screen & user interface
	draw_rect(Rect2(-82.0, -18.0, 28.0, 12.0), Color(0.15, 0.82, 0.92, 0.95), true)
	draw_line(Vector2(-80.0, -12.0), Vector2(-60.0, -12.0), Color.WHITE, 1.5)
	# Status indicator LEDs
	draw_circle(Vector2(-56.0, -14.0), 2.5, Color(0.2, 0.95, 0.4))
	draw_circle(Vector2(-56.0, -6.0), 2.5, Color(0.95, 0.75, 0.2))

	# Storage Bay / Supply Locker (inside cabin, right wall)
	draw_rect(Rect2(52.0, -10.0, 34.0, 36.0), deck_color.lightened(0.08), true)
	draw_rect(Rect2(52.0, -10.0, 34.0, 36.0), rim_color.darkened(0.2), false, 1.5)
	draw_line(Vector2(68.0, -10.0), Vector2(68.0, 26.0), deck_color.darkened(0.3), 2.0)
	draw_rect(Rect2(65.0, 4.0, 6.0, 8.0), rim_color, true)

	# 4. Bottom Hatch & Moonpool Exit Ladder (leading down into ocean)
	# Submerged hatch opening (center floor, leading out the bottom)
	draw_rect(Rect2(-26.0, 28.0, 52.0, 48.0), water_accent, true)
	draw_line(Vector2(-26.0, 28.0), Vector2(-26.0, 75.0), rim_color, 2.5)
	draw_line(Vector2(26.0, 28.0), Vector2(26.0, 75.0), rim_color, 2.5)

	# Steel diving ladder extending down through hatch into the water
	var ladder_rail_color := Color(0.72, 0.78, 0.85, 1.0)
	var ladder_left_x := -12.0
	var ladder_right_x := 12.0
	# Vertical rails extending down past hull bottom to Y=88
	draw_line(Vector2(ladder_left_x, 14.0), Vector2(ladder_left_x, 88.0), ladder_rail_color, 2.5)
	draw_line(Vector2(ladder_right_x, 14.0), Vector2(ladder_right_x, 88.0), ladder_rail_color, 2.5)
	# Horizontal rungs
	for ry in [20.0, 34.0, 48.0, 62.0, 76.0, 86.0]:
		draw_line(Vector2(ladder_left_x - 1.0, ry), Vector2(ladder_right_x + 1.0, ry), ladder_rail_color, 2.0)

	# 5. Solar Panel Arrays on Upper Roof (above water)
	# Mounting frame struts
	draw_line(Vector2(-50.0, -66.0), Vector2(-55.0, -78.0), Color(0.4, 0.45, 0.5), 3.0)
	draw_line(Vector2(50.0, -66.0), Vector2(55.0, -78.0), Color(0.4, 0.45, 0.5), 3.0)
	# Left solar panel wing
	draw_rect(Rect2(-68.0, -82.0, 56.0, 14.0), solar_blue, true)
	draw_rect(Rect2(-68.0, -82.0, 56.0, 14.0), Color.WHITE, false, 1.5)
	for sx in [-54.0, -40.0, -26.0]:
		draw_line(Vector2(sx, -82.0), Vector2(sx, -68.0), Color(0.6, 0.85, 1.0, 0.8), 1.0)
	# Right solar panel wing
	draw_rect(Rect2(12.0, -82.0, 56.0, 14.0), solar_blue, true)
	draw_rect(Rect2(12.0, -82.0, 56.0, 14.0), Color.WHITE, false, 1.5)
	for sx in [26.0, 40.0, 54.0]:
		draw_line(Vector2(sx, -82.0), Vector2(sx, -68.0), Color(0.6, 0.85, 1.0, 0.8), 1.0)

	# 6. Emergency Beacon Antenna Mast & Flashing Light (top left)
	draw_line(Vector2(-75.0, -60.0), Vector2(-75.0, -96.0), Color(0.7, 0.72, 0.76), 3.0)
	# Beacon red light bulb
	draw_circle(Vector2(-75.0, -98.0), 6.0, beacon_red)
	draw_circle(Vector2(-75.0, -98.0), 10.0, Color(1.0, 0.25, 0.25, 0.35))
	draw_circle(Vector2(-75.0, -98.0), 2.0, Color.WHITE)

	# 7. Waterline indicator shimmer (Y=0)
	draw_line(Vector2(-135.0, 0.0), Vector2(-115.0, 0.0), Color(0.5, 0.9, 1.0, 0.65), 2.0)
	draw_line(Vector2(115.0, 0.0), Vector2(135.0, 0.0), Color(0.5, 0.9, 1.0, 0.65), 2.0)

