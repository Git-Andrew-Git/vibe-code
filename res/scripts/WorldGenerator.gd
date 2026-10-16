extends TileMapLayer

## WorldGenerator - Generates a 2D open-world seabed around the player.
## Maps out the Alien Shallows, Coral Formations, and Deep Trench drop-offs.

@export var map_radius: int = 35 # Grid of 70x70 tiles (each 128x128 = ~8960x8960 px)

func _ready() -> void:
	generate_seabed()

func generate_seabed() -> void:
	clear()

	for x in range(-map_radius, map_radius):
		for y in range(-map_radius, map_radius):
			var coords := Vector2i(x, y)
			var dist := coords.length()
			var atlas_coord: Vector2i

			if dist < 12.0:
				# Shallows sand around escape pod
				var variant: int = int(abs(x * 7 + y * 13)) % 4
				atlas_coord = Vector2i(variant % 2, variant / 2)
			elif dist < 22.0:
				# Coral beds mixed with sand channels
				var coral_noise := sin(float(x) * 0.4) + cos(float(y) * 0.4)
				if coral_noise > 0.35:
					atlas_coord = Vector2i((abs(x) % 2), 2 + (abs(y) % 2))
				else:
					atlas_coord = Vector2i(abs(x) % 2, abs(y) % 2)
			else:
				# Outer trench drop-off and abyssal rock
				var rock_noise := sin(float(x) * 0.25) * cos(float(y) * 0.25)
				if rock_noise > 0.1:
					atlas_coord = Vector2i(2 + (abs(x) % 2), 2 + (abs(y) % 2))
				else:
					atlas_coord = Vector2i(2 + (abs(x) % 2), abs(y) % 2)

			set_cell(coords, 0, atlas_coord)
