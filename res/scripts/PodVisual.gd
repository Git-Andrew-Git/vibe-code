extends Node2D

## PodVisual - Procedural 2D render for the emergency escape pod
## Amber hull, solar panels, boarding deck, and flashing beacon.

func _draw() -> void:
	# Pod colors (warm amber for player structures per Art Bible)
	var hull_color := Color(0.88, 0.56, 0.18, 1.0)
	var deck_color := Color(0.22, 0.25, 0.30, 1.0)
	var rim_color := Color(0.98, 0.72, 0.30, 1.0)
	var solar_blue := Color(0.12, 0.45, 0.75, 1.0)
	var beacon_red := Color(1.0, 0.25, 0.25, 0.9)

	# 1. Outer Buoyancy Ring / Float Collar
	draw_rect(Rect2(-120.0, -90.0, 240.0, 180.0), hull_color, true)
	draw_rect(Rect2(-120.0, -90.0, 240.0, 180.0), rim_color, false, 4.0)

	# 2. Walkable Interior Deck
	draw_rect(Rect2(-95.0, -70.0, 190.0, 140.0), deck_color, true)

	# 3. Solar Panel Arrays
	draw_rect(Rect2(-85.0, -60.0, 50.0, 40.0), solar_blue, true)
	draw_rect(Rect2(-85.0, -60.0, 50.0, 40.0), Color.WHITE, false, 1.5)

	# 4. Central Habitation Hatch
	draw_circle(Vector2(20.0, 0.0), 32.0, hull_color)
	draw_circle(Vector2(20.0, 0.0), 28.0, deck_color)
	draw_circle(Vector2(20.0, 0.0), 12.0, rim_color)

	# 5. Emergency Beacon Antenna
	draw_line(Vector2(-80.0, 50.0), Vector2(-80.0, 25.0), Color(0.7, 0.7, 0.7), 3.0)
	draw_circle(Vector2(-80.0, 22.0), 5.0, beacon_red)

