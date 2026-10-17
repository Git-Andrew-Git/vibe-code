extends TileMapLayer

## WorldGenerator - Generates a 2D side-view vertical underwater world.
## Renders a vertical cross-section of Alien Shallows, Mid-Waters, and Deep Trenches
## with narrowing canyons, shelves, ledges, and abyssal passages.

enum TileType {
	SAND = 0,
	CORAL = 1,
	ROCK = 2,
	TRENCH = 3,
	ABYSSAL = 4
}

@export var map_width: int = 50 # 50 tiles wide (~6400 px)
@export var map_depth: int = 80 # 80 tiles deep (~10240 px)

func _ready() -> void:
	_ensure_physics_layer()
	generate_seabed()

func _ensure_physics_layer() -> void:
	if not tile_set:
		return
	if tile_set.get_physics_layers_count() == 0:
		tile_set.add_physics_layer()
		# Add default box collision to atlas tiles if source exists
		if tile_set.has_source(0):
			var source := tile_set.get_source(0)
			if source is TileSetAtlasSource:
				var half_size := Vector2(tile_set.tile_size) * 0.5
				var box_polygon := PackedVector2Array([
					Vector2(-half_size.x, -half_size.y),
					Vector2(half_size.x, -half_size.y),
					Vector2(half_size.x, half_size.y),
					Vector2(-half_size.x, half_size.y)
				])
				var count := source.get_tiles_count()
				for i in range(count):
					var coord := source.get_tile_id(i)
					var tile_data: TileData = source.get_tile_data(coord, 0)
					if tile_data and tile_data.get_collision_polygons_count(0) == 0:
						tile_data.add_collision_polygon(0)
						tile_data.set_collision_polygon_points(0, 0, box_polygon)

func get_tile_atlas_coord(tile_type: int, x: int, y: int) -> Vector2i:
	var vx := absi(x) % 2
	var vy := absi(y) % 2
	match tile_type:
		TileType.SAND:
			return Vector2i(vx, vy)
		TileType.CORAL:
			return Vector2i(vx, 2 + vy)
		TileType.ROCK:
			return Vector2i(2 + vx, vy)
		TileType.TRENCH:
			return Vector2i(2 + vx, 2)
		TileType.ABYSSAL:
			return Vector2i(2 + vx, 3)
		_:
			return Vector2i(vx, vy)

func place_tile(coords: Vector2i, tile_type: int) -> void:
	var atlas_coord := get_tile_atlas_coord(tile_type, coords.x, coords.y)
	set_cell(coords, 0, atlas_coord)

func generate_seabed() -> void:
	clear()

	var half_w := map_width / 2

	# 1. Outer boundary containment walls above water level (y < 0)
	for y in range(-4, 0):
		for x in range(-half_w - 2, half_w + 3):
			if x <= -half_w or x >= half_w:
				place_tile(Vector2i(x, y), TileType.SAND)

	# 2. Main vertical world (y = 0 to map_depth)
	for y in range(0, map_depth + 1):
		# Solid abyssal ocean floor at deepest point (y >= map_depth - 2)
		if y >= map_depth - 2:
			for x in range(-half_w - 2, half_w + 3):
				place_tile(Vector2i(x, y), TileType.ABYSSAL)
			continue

		# Surface zone (y = 0..2)
		if y < 3:
			_generate_surface_row(y, half_w)
		# Shallow zone (y = 3..11, Y < 1500 px)
		elif y < 12:
			_generate_shallow_row(y, half_w)
		# Mid-waters (y = 12..31, Y < 4000 px)
		elif y < 32:
			_generate_midwater_row(y, half_w)
		# Deep trenches (y = 32..map_depth - 3, Y >= 4000 px)
		else:
			_generate_trench_row(y, half_w)

func _generate_surface_row(y: int, half_w: int) -> void:
	# Flat sandy seabed shelf near the pod (keep pod center [-4, 4] clear of solid tiles)
	for x in range(-half_w - 2, half_w + 3):
		if x <= -22 or x >= 22:
			place_tile(Vector2i(x, y), TileType.SAND)

	# Ledges / sandy shelf adjacent to pod
	if y == 1:
		for x in range(5, 15):
			place_tile(Vector2i(x, y), TileType.SAND)
		for x in range(-14, -4):
			place_tile(Vector2i(x, y), TileType.SAND)
	elif y == 2:
		for x in range(4, 16):
			place_tile(Vector2i(x, y), TileType.SAND)
		for x in range(-15, -3):
			place_tile(Vector2i(x, y), TileType.SAND)

func _generate_shallow_row(y: int, half_w: int) -> void:
	var x_left := -22 + int(sin(float(y) * 0.7) * 1.5)
	var x_right := 22 - int(cos(float(y) * 0.6) * 1.5)

	# Outer walls with coral shelves and small cave hollows
	for x in range(-half_w - 2, half_w + 3):
		if x <= x_left or x >= x_right:
			# Small cave hollows in the walls
			if (y >= 5 and y <= 7 and x >= -24 and x <= -20):
				continue # Cave pocket in left wall
			if (y >= 8 and y <= 10 and x >= 20 and x <= 23):
				continue # Cave pocket in right wall

			var coral_noise := sin(float(x) * 0.5 + float(y) * 0.4)
			var tile := TileType.CORAL if coral_noise > 0.2 else TileType.SAND
			place_tile(Vector2i(x, y), tile)

	# Scattered coral shelves and sandy ledges for resting
	match y:
		3:
			for x in range(-16, -8):
				place_tile(Vector2i(x, y), TileType.SAND)
		4:
			for x in range(11, 19):
				place_tile(Vector2i(x, y), TileType.CORAL)
		6:
			for x in range(-7, 1):
				place_tile(Vector2i(x, y), TileType.CORAL)
		7:
			for x in range(8, 16):
				place_tile(Vector2i(x, y), TileType.SAND)
		9:
			for x in range(-18, -9):
				place_tile(Vector2i(x, y), TileType.CORAL)
		10:
			for x in range(5, 14):
				place_tile(Vector2i(x, y), TileType.SAND)

func _generate_midwater_row(y: int, half_w: int) -> void:
	var t := float(y - 12) / (31.0 - 12.0)
	var open_half := lerpf(21.0, 11.5, t)
	var x_left := int(-open_half + sin(float(y) * 0.9) * 1.8)
	var x_right := int(open_half - cos(float(y) * 0.85) * 1.8)

	# Narrowing canyon walls with vertical cliff faces
	for x in range(-half_w - 2, half_w + 3):
		if x <= x_left or x >= x_right:
			# Cave hollows inside canyon walls
			if (y >= 18 and y <= 20 and x >= -21 and x <= -16):
				continue
			if (y >= 25 and y <= 27 and x >= 16 and x <= 21):
				continue

			var tile: int
			if y < 16 and sin(float(x) * 0.4 + float(y) * 0.5) > 0.3:
				tile = TileType.CORAL
			elif y >= 27:
				tile = TileType.TRENCH
			else:
				tile = TileType.ROCK
			place_tile(Vector2i(x, y), tile)

	# Rocky outcrops and platforms jutting into the canyon
	match y:
		13:
			for x in range(x_right - 5, x_right):
				place_tile(Vector2i(x, y), TileType.ROCK)
		16:
			for x in range(x_left, x_left + 6):
				place_tile(Vector2i(x, y), TileType.ROCK)
		19:
			for x in range(-2, 4):
				place_tile(Vector2i(x, y), TileType.ROCK)
		22:
			for x in range(x_right - 6, x_right):
				place_tile(Vector2i(x, y), TileType.ROCK)
		26:
			for x in range(x_left, x_left + 7):
				place_tile(Vector2i(x, y), TileType.ROCK)
		29:
			for x in range(-4, 3):
				place_tile(Vector2i(x, y), TileType.ROCK)

func _generate_trench_row(y: int, half_w: int) -> void:
	var center_x := sin(float(y) * 0.22) * 4.5
	var passage_half: float
	if y < 50:
		passage_half = lerpf(11.0, 6.5, float(y - 32) / 18.0)
	else:
		passage_half = 6.0 + sin(float(y) * 0.5) * 1.5

	var x_left := int(center_x - passage_half)
	var x_right := int(center_x + passage_half)

	var wall_tile := TileType.ABYSSAL if y >= 55 else TileType.TRENCH

	for x in range(-half_w - 2, half_w + 3):
		if x <= x_left or x >= x_right:
			place_tile(Vector2i(x, y), wall_tile)

	# Jagged spires and ledges inside narrow abyssal passages
	match y:
		35:
			for x in range(x_left, int(center_x - 1)):
				place_tile(Vector2i(x, y), TileType.TRENCH)
		41:
			for x in range(int(center_x + 1), x_right):
				place_tile(Vector2i(x, y), TileType.TRENCH)
		47:
			for x in range(int(center_x - 1), int(center_x + 3)):
				place_tile(Vector2i(x, y), TileType.TRENCH)
		53:
			for x in range(x_left, int(center_x)):
				place_tile(Vector2i(x, y), TileType.ABYSSAL)
		61:
			for x in range(int(center_x), x_right):
				place_tile(Vector2i(x, y), TileType.ABYSSAL)
		69:
			for x in range(int(center_x - 3), int(center_x + 4)):
				place_tile(Vector2i(x, y), TileType.ABYSSAL)
