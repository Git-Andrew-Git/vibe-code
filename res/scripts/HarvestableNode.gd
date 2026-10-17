extends Area2D

## HarvestableNode - Harvestable mineral outcrops and flora in the open ocean.
## Shows an interaction prompt when the player is near, and adds harvested items to inventory.

const ItemDatabaseClass = preload("res://res/scripts/ItemDatabase.gd")

@export var item_id: String = "titanium"
@export var yield_amount: int = 1
@export var prompt_text: String = "Harvest"

var is_player_in_range: bool = false
var is_harvested: bool = false

@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if prompt_label:
		prompt_label.visible = false
		var item_data: Resource = ItemDatabaseClass.get_item(item_id)
		var name_str: String = item_data.get("name") if item_data else item_id
		prompt_label.text = "[E] %s %s" % [prompt_text, name_str]

func _unhandled_input(event: InputEvent) -> void:
	if is_player_in_range and not is_harvested and event.is_action_pressed("interact"):
		harvest()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_harvested:
		is_player_in_range = true
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false
		if prompt_label:
			prompt_label.visible = false

func harvest() -> void:
	is_harvested = true
	is_player_in_range = false
	if prompt_label:
		prompt_label.visible = false

	GameState.add_item(item_id, yield_amount)

	# Bonus flora harvesting if player has the survival knife
	if GameState.get_item_count("survival_knife") > 0:
		if item_id == "kelp_fiber":
			GameState.add_item("creepvine_seed", 1)
		elif item_id == "coral_sample":
			GameState.add_item("coral_sample", 1)

	# Quick harvest shrink animation
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _draw() -> void:
	# Procedural mineral rock & flora visual (Side-View)
	if item_id == "copper_ore":
		# Side-view mineral rock formation resting on a ledge/ground
		var rock_pts := PackedVector2Array([
			Vector2(-20.0, 14.0),
			Vector2(-18.0, 3.0),
			Vector2(-12.0, -8.0),
			Vector2(-4.0, -16.0),
			Vector2(7.0, -11.0),
			Vector2(16.0, -3.0),
			Vector2(20.0, 14.0)
		])
		draw_colored_polygon(rock_pts, Color(0.32, 0.25, 0.20))
		draw_polyline(rock_pts, Color(0.45, 0.36, 0.28), 1.5)

		# Embedded raw copper nuggets and shiny veins on rock face
		var copper_vein1 := PackedVector2Array([
			Vector2(-10.0, -6.0), Vector2(-3.0, -13.0),
			Vector2(4.0, -8.0), Vector2(-3.0, -2.0)
		])
		draw_colored_polygon(copper_vein1, Color(0.90, 0.54, 0.30))
		draw_polyline(copper_vein1, Color(1.0, 0.72, 0.48), 1.5)

		var copper_vein2 := PackedVector2Array([
			Vector2(5.0, -3.0), Vector2(13.0, 2.0),
			Vector2(9.0, 9.0), Vector2(3.0, 3.0)
		])
		draw_colored_polygon(copper_vein2, Color(0.85, 0.48, 0.25))

		# Bright metallic glint specks
		draw_circle(Vector2(-3.0, -8.0), 2.5, Color(1.0, 0.85, 0.65))
		draw_circle(Vector2(8.0, 3.0), 2.0, Color(1.0, 0.85, 0.65))

	elif item_id == "kelp_fiber":
		# Tall kelp stalk growing UPWARD from seabed (positive Y toward negative Y)
		# Holdfast base anchored to ground
		draw_line(Vector2(-8.0, 16.0), Vector2(8.0, 16.0), Color(0.12, 0.42, 0.22), 4.0)

		# Sinuous, undulating central stalk rising upward
		var stalk_curve := PackedVector2Array([
			Vector2(0.0, 16.0),
			Vector2(3.0, 4.0),
			Vector2(-4.0, -14.0),
			Vector2(4.0, -32.0),
			Vector2(-2.0, -48.0),
			Vector2(0.0, -58.0)
		])
		draw_polyline(stalk_curve, Color(0.16, 0.58, 0.30), 6.0)

		# Wavy side-view kelp fronds extending outward and floating upward
		# Lower frond (left)
		var frond1 := PackedVector2Array([
			Vector2(2.0, 6.0), Vector2(-14.0, -2.0),
			Vector2(-20.0, -12.0), Vector2(-8.0, -6.0)
		])
		draw_colored_polygon(frond1, Color(0.24, 0.72, 0.38))

		# Mid frond (right)
		var frond2 := PackedVector2Array([
			Vector2(-2.0, -16.0), Vector2(16.0, -22.0),
			Vector2(22.0, -32.0), Vector2(6.0, -26.0)
		])
		draw_colored_polygon(frond2, Color(0.26, 0.76, 0.42))

		# Upper frond (left)
		var frond3 := PackedVector2Array([
			Vector2(2.0, -34.0), Vector2(-12.0, -40.0),
			Vector2(-16.0, -50.0), Vector2(-4.0, -44.0)
		])
		draw_colored_polygon(frond3, Color(0.28, 0.78, 0.44))

		# Top canopy blade
		var frond_top := PackedVector2Array([
			Vector2(0.0, -50.0), Vector2(8.0, -58.0),
			Vector2(2.0, -66.0), Vector2(-4.0, -58.0)
		])
		draw_colored_polygon(frond_top, Color(0.32, 0.84, 0.48))

		# Glowing golden Creepvine seed clusters along the stem
		var seed_color := Color(0.98, 0.82, 0.22, 0.95)
		for spos in [Vector2(2.0, 2.0), Vector2(-3.0, -18.0), Vector2(3.0, -36.0)]:
			draw_circle(spos, 6.0, Color(1.0, 0.85, 0.2, 0.3)) # Glow halo
			draw_circle(spos, 3.5, seed_color) # Seed pod

	elif item_id == "coral_sample":
		# Side-view branching coral growing upward from rock base
		draw_line(Vector2(-10.0, 14.0), Vector2(10.0, 14.0), Color(0.3, 0.2, 0.35), 4.0)

		# Upward branching stems (magenta bioluminescent structure)
		var coral_color := Color(0.86, 0.24, 0.64)
		var coral_light := Color(0.95, 0.42, 0.76)

		# Central trunk
		draw_line(Vector2(0.0, 14.0), Vector2(0.0, 0.0), coral_color, 7.0)

		# Left branch & fork
		draw_line(Vector2(0.0, 2.0), Vector2(-10.0, -10.0), coral_color, 5.0)
		draw_line(Vector2(-10.0, -10.0), Vector2(-16.0, -22.0), coral_light, 3.5)
		draw_line(Vector2(-10.0, -10.0), Vector2(-6.0, -24.0), coral_light, 3.5)

		# Right branch & fork
		draw_line(Vector2(0.0, 2.0), Vector2(9.0, -8.0), coral_color, 5.0)
		draw_line(Vector2(9.0, -8.0), Vector2(6.0, -22.0), coral_light, 3.5)
		draw_line(Vector2(9.0, -8.0), Vector2(16.0, -20.0), coral_light, 3.5)

		# Center tall tip
		draw_line(Vector2(0.0, 0.0), Vector2(0.0, -26.0), coral_light, 3.5)

		# Glowing cyan polyp tips at the branch ends
		var cyan_tip := Color(0.35, 0.95, 0.88, 0.95)
		for tip in [Vector2(-16.0, -22.0), Vector2(-6.0, -24.0), Vector2(0.0, -26.0), Vector2(6.0, -22.0), Vector2(16.0, -20.0)]:
			draw_circle(tip, 5.0, Color(0.2, 0.9, 0.85, 0.3))
			draw_circle(tip, 2.8, cyan_tip)

	else:
		# Titanium outcrop - side-view rock ledge with protruding angular metallic shards
		var base_rock := PackedVector2Array([
			Vector2(-22.0, 14.0),
			Vector2(-18.0, 2.0),
			Vector2(-10.0, -6.0),
			Vector2(8.0, -6.0),
			Vector2(18.0, 2.0),
			Vector2(22.0, 14.0)
		])
		draw_colored_polygon(base_rock, Color(0.24, 0.28, 0.34))
		draw_polyline(base_rock, Color(0.36, 0.40, 0.48), 1.5)

		# Angular silvery titanium shards protruding upward
		# Main tall shard
		var shard_main := PackedVector2Array([
			Vector2(-5.0, 2.0),
			Vector2(-3.0, -20.0),
			Vector2(5.0, -16.0),
			Vector2(7.0, 2.0)
		])
		draw_colored_polygon(shard_main, Color(0.74, 0.82, 0.90))
		draw_polyline(shard_main, Color(0.90, 0.95, 1.0), 1.5)

		# Left angled shard
		var shard_left := PackedVector2Array([
			Vector2(-16.0, 4.0),
			Vector2(-14.0, -12.0),
			Vector2(-6.0, -6.0),
			Vector2(-8.0, 6.0)
		])
		draw_colored_polygon(shard_left, Color(0.62, 0.70, 0.80))
		draw_polyline(shard_left, Color(0.82, 0.88, 0.96), 1.0)

		# Right angled shard
		var shard_right := PackedVector2Array([
			Vector2(5.0, 4.0),
			Vector2(14.0, -10.0),
			Vector2(17.0, 0.0),
			Vector2(8.0, 6.0)
		])
		draw_colored_polygon(shard_right, Color(0.66, 0.74, 0.84))
		draw_polyline(shard_right, Color(0.85, 0.90, 0.98), 1.0)

		# Specular gleam highlight line
		draw_line(Vector2(-2.0, -19.0), Vector2(4.0, -15.0), Color.WHITE, 1.5)
