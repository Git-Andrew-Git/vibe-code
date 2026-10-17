extends Node2D

## EcosystemManager - Spawns and manages schools of passive fish and prowling predators.
## Maintains active ecosystem populations in the Alien Shallows, Mid-waters, and Deep Trenches.

const PassiveFaunaScene = preload("res://res/scenes/PassiveFauna.tscn")
const PredatorFaunaScene = preload("res://res/scenes/PredatorFauna.tscn")

@export var max_passive_fish: int = 12
@export var max_predators: int = 2

func _ready() -> void:
	_spawn_initial_ecosystem()

func _spawn_initial_ecosystem() -> void:
	# 1. Spawn Passive Ribbon Fish in schools at various depths (spread horizontally)
	var school_centers := [
		Vector2(-300.0, 400.0),   # School 1: Shallows (near pod)
		Vector2(400.0, 800.0),    # School 2: Shallows
		Vector2(-200.0, 2000.0)   # School 3: Mid-waters
	]

	for center in school_centers:
		for i in range(4):
			var fish := PassiveFaunaScene.instantiate() as CharacterBody2D
			var offset := Vector2(randf_range(-70.0, 70.0), randf_range(-30.0, 30.0))
			fish.position = center + offset
			add_child(fish)

	# 2. Spawn Territorial Predators in deeper zones
	var predator_spawns := [
		Vector2(500.0, 3000.0),   # Predator 1: Mid-waters
		Vector2(-300.0, 5000.0)   # Predator 2: Deep trench
	]

	for pos in predator_spawns:
		var stalker := PredatorFaunaScene.instantiate() as CharacterBody2D
		stalker.position = pos
		add_child(stalker)
