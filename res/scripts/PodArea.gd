extends Area2D

## PodArea - Life Pod dry platform area.
## Transitions player to WALKING state when aboard, and SWIMMING when diving into ocean.

const PlayerClass = preload("res://res/scripts/Player.gd")

@export var water_surface_y: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerClass or body.has_method("set_movement_mode"):
		body.set_movement_mode(PlayerClass.MovementMode.WALKING)

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerClass or body.has_method("set_movement_mode"):
		# If exiting into the ocean water (at or below water surface), transition to SWIMMING.
		# If jumping upward into the air above the platform, remain in walking state so gravity and jumping continue smoothly.
		if body.global_position.y >= water_surface_y:
			body.set_movement_mode(PlayerClass.MovementMode.SWIMMING)
