extends Area2D

## PodArea - Life Pod dry platform area.
## Transitions player to WALKING state when aboard, and SWIMMING when diving into ocean.

const PlayerClass = preload("res://res/scripts/Player.gd")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass or body.has_method("set_movement_mode"):
		body.set_movement_mode(PlayerClass.MovementMode.WALKING)

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerClass or body.has_method("set_movement_mode"):
		body.set_movement_mode(PlayerClass.MovementMode.SWIMMING)

