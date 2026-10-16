@tool
extends SceneTree

func _init() -> void:
	print("Generating procedural tileset atlas...")
	var size := 512
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)

	var half := size / 2

	# Color definitions
	var sand_base := Color(0.16, 0.38, 0.46)
	var sand_ridge := Color(0.22, 0.48, 0.56)
	var deep_base := Color(0.04, 0.10, 0.18)
	var deep_sediment := Color(0.06, 0.14, 0.24)
	var coral_base := Color(0.10, 0.35, 0.42)
	var coral_cyan := Color(0.20, 0.85, 0.80)
	var coral_magenta := Color(0.85, 0.25, 0.65)
	var rock_base := Color(0.07, 0.16, 0.22)
	var rock_vein := Color(0.15, 0.60, 0.68)

	for y in range(size):
		for x in range(size):
			var col: Color
			if x < half and y < half:
				# 1. Top-Left: Shallow Sand with gentle wave ripples
				var wave := sin(float(x) * 0.12 + float(y) * 0.06) * 0.5 + 0.5
				col = sand_base.lerp(sand_ridge, wave * 0.7)
				# Subtle grain noise
				var grain := fposmod(sin(float(x * 12 + y * 34)) * 43758.5453, 1.0)
				col = col.lightened(grain * 0.08)

			elif x >= half and y < half:
				# 2. Top-Right: Deep Trench Seabed
				var deep_wave := sin(float(x) * 0.08 - float(y) * 0.08) * 0.5 + 0.5
				col = deep_base.lerp(deep_sediment, deep_wave * 0.5)
				var speck := fposmod(sin(float(x * 97 + y * 43)) * 12345.6789, 1.0)
				if speck > 0.96:
					col = Color(0.12, 0.35, 0.45) # glowing mineral fleck

			elif x < half and y >= half:
				# 3. Bottom-Left: Bioluminescent Coral Bed
				col = coral_base
				var cx := float(x % half) - float(half / 2)
				var cy := float(y % half) - float(half / 2)
				var dist := sqrt(cx * cx + cy * cy)
				var ring := sin(dist * 0.15) * 0.5 + 0.5
				if ring > 0.65:
					col = coral_cyan
				elif ring < 0.25:
					col = coral_magenta
				else:
					col = coral_base.lerp(coral_cyan, ring * 0.4)

			else:
				# 4. Bottom-Right: Abyssal Rock with bioluminescent veins
				col = rock_base
				var vein_noise := sin(float(x) * 0.1 + sin(float(y) * 0.15) * 2.0)
				if abs(vein_noise) < 0.15:
					col = rock_vein
				else:
					var facet := sin(float(x * 5 + y * 7)) * 0.05
					col = col.lightened(facet)

			img.set_pixel(x, y, col)

	var err := img.save_png("res://assets/tilesets/seabed_tileset.png")
	if err == OK:
		print("Successfully saved assets/tilesets/seabed_tileset.png")
	else:
		printerr("Failed to save seabed_tileset.png, code: ", err)

	quit()
