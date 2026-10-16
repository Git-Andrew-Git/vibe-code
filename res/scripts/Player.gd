extends CharacterBody2D
class_name Player

## Player - 2D Open-World Survival Character Controller
## Handles 8-directional top-down movement, swimming vs. walking physics,
## stamina/oxygen consumption, camera tracking, and procedural visual effects.

enum MovementMode {
	SWIMMING,
	WALKING
}

@export var mode: MovementMode = MovementMode.SWIMMING

# Swimming Physics (Fluid drag & inertia)
@export_group("Swimming Physics")
@export var swim_speed: float = 260.0
@export var swim_sprint_speed: float = 420.0
@export var swim_acceleration: float = 700.0
@export var swim_friction: float = 380.0
@export var swim_rotation_speed: float = 10.0

# Walking Physics (Higher friction & responsive footing)
@export_group("Walking Physics")
@export var walk_speed: float = 210.0
@export var walk_sprint_speed: float = 340.0
@export var walk_acceleration: float = 1400.0
@export var walk_friction: float = 1600.0
@export var walk_rotation_speed: float = 14.0

# Survival Rates (Units per second)
@export_group("Survival Consumption Rates")
@export var oxygen_drain_swim: float = 1.2
@export var oxygen_recovery_walk: float = 35.0
@export var stamina_sprint_cost: float = 18.0
@export var stamina_recovery_rate: float = 12.0
@export var suffocation_damage: float = 8.0

var is_sprinting: bool = false
var facing_direction: Vector2 = Vector2.DOWN
var _kick_phase: float = 0.0

@onready var visual_root: Node2D = $Visual
@onready var bubbles: CPUParticles2D = $Visual/Bubbles
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("Player")
	EventBus.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	_handle_input_and_movement(delta)
	_handle_survival_stats(delta)
	_update_animation_and_visuals(delta)
	move_and_slide()

func _handle_input_and_movement(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_stamina := GameState.get_stat("stamina")

	# Check sprint capability
	var wants_sprint := Input.is_action_pressed("sprint") and input_vector != Vector2.ZERO
	is_sprinting = wants_sprint and current_stamina > 2.0

	var target_speed: float
	var accel: float
	var friction: float
	var rot_speed: float

	if mode == MovementMode.SWIMMING:
		target_speed = swim_sprint_speed if is_sprinting else swim_speed
		accel = swim_acceleration
		friction = swim_friction
		rot_speed = swim_rotation_speed
	else:
		target_speed = walk_sprint_speed if is_sprinting else walk_speed
		accel = walk_acceleration
		friction = walk_friction
		rot_speed = walk_rotation_speed

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * target_speed, accel * delta)
		facing_direction = input_vector.normalized()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Smooth rotation toward movement or facing direction
	if velocity.length() > 10.0:
		var target_angle := velocity.angle()
		visual_root.rotation = lerp_angle(visual_root.rotation, target_angle + PI * 0.5, rot_speed * delta)

func _handle_survival_stats(delta: float) -> void:
	# Stamina
	if is_sprinting:
		GameState.modify_stat("stamina", -stamina_sprint_cost * delta)
	else:
		GameState.modify_stat("stamina", stamina_recovery_rate * delta)

	# Oxygen
	if mode == MovementMode.SWIMMING:
		var current_oxygen := GameState.modify_stat("oxygen", -oxygen_drain_swim * delta)
		if current_oxygen <= 0.0:
			GameState.modify_stat("health", -suffocation_damage * delta)
	else:
		GameState.modify_stat("oxygen", oxygen_recovery_walk * delta)

func _update_animation_and_visuals(delta: float) -> void:
	var speed := velocity.length()
	var is_moving := speed > 15.0

	# Bubbles emission when swimming & moving
	if bubbles:
		bubbles.emitting = (mode == MovementMode.SWIMMING) and is_moving
		if bubbles.emitting:
			bubbles.amount = 16 if is_sprinting else 8

	# Procedural fin flutter/kick cycle
	if is_moving:
		_kick_phase += delta * (speed / 30.0)
	else:
		_kick_phase = lerp(_kick_phase, 0.0, delta * 5.0)

	if visual_root and visual_root.has_node("DiverBody"):
		var diver: Node2D = visual_root.get_node("DiverBody")
		if diver.has_method("set_kick_phase"):
			diver.set_kick_phase(_kick_phase, mode == MovementMode.SWIMMING)

func set_movement_mode(new_mode: MovementMode) -> void:
	if mode != new_mode:
		mode = new_mode
		if mode == MovementMode.WALKING:
			velocity *= 0.5 # Braking entering land

func _on_player_died() -> void:
	print("Player health depleted. Game over triggered.")
