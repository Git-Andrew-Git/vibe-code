extends Node2D

## EcosystemManager - Spawns and manages schools of passive fish and prowling predators.
## Maintains active ecosystem populations in the Alien Shallows and surrounding reefs.

const PassiveFaunaScene = preload("res://res/scenes/PassiveFauna.tscn")
const PredatorFaunaScene = preload("res://res/scenes/PredatorFauna.tscn")

@export var max_passive_fish: int = 12
@export var max_predators: int = 2

func _ready() -> void:
	_spawn_initial_ecosystem()

func _spawn_initial_ecosystem() -> void:
	# 1. Spawn Passive Ribbon Fish in schools around the Shallows
	var school_centers := [
		Vector2(-350.0, -220.0),
		Vector2(400.0, 260.0),
		Vector2(-200.0, 380.0)
	]

	for center in school_centers:
		for i in range(4):
			var fish := PassiveFaunaScene.instantiate() as CharacterBody2D
			var offset := Vector2(randf_range(-60.0, 60.0), randf_range(-60.0, 60.0))
			fish.position = center + offset
			add_child(fish)

	# 2. Spawn Territorial Predators patrolling outer reefs
	var predator_spawns := [
		Vector2(850.0, -550.0),
		Vector2(-750.0, 650.0)
	]

	for pos in predator_spawns:
		var stalker := PredatorFaunaScene.instantiate() as CharacterBody2D
		stalker.position = pos
		add_child(stalker)
