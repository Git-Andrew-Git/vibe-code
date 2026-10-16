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
	# Procedural mineral rock & flora visual
	if item_id == "copper_ore":
		draw_circle(Vector2.ZERO, 20.0, Color(0.35, 0.28, 0.22))
		draw_circle(Vector2(-4.0, -4.0), 10.0, Color(0.88, 0.52, 0.32)) # Copper vein
		draw_circle(Vector2(6.0, 5.0), 6.0, Color(0.95, 0.65, 0.45))
	elif item_id == "kelp_fiber":
		draw_line(Vector2(0, 24), Vector2(0, -28), Color(0.18, 0.65, 0.35), 8.0)
		draw_circle(Vector2(-8, -12), 12.0, Color(0.25, 0.75, 0.42))
		draw_circle(Vector2(8, 6), 10.0, Color(0.22, 0.70, 0.38))
	elif item_id == "coral_sample":
		draw_circle(Vector2.ZERO, 20.0, Color(0.85, 0.25, 0.65)) # Bioluminescent magenta coral
		draw_circle(Vector2(-5, -5), 9.0, Color(0.95, 0.45, 0.75))
		draw_circle(Vector2(6, 6), 7.0, Color(0.35, 0.95, 0.85))
	else:
		# Titanium outcrop
		draw_circle(Vector2.ZERO, 22.0, Color(0.28, 0.32, 0.38))
		draw_polygon(PackedVector2Array([
			Vector2(-12.0, -8.0), Vector2(4.0, -14.0),
			Vector2(14.0, 6.0), Vector2(-6.0, 14.0)
		]), [Color(0.75, 0.82, 0.90)]) # Silver titanium shard
