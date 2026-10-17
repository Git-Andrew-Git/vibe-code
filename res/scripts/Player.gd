extends CharacterBody2D
class_name Player

## Player - 2D Open-World Survival Character Controller
## Handles side-view movement, swimming vs. walking physics,
## depth-based oxygen & survival consumption, hotbar input, and visual effects.

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
@export var swim_buoyancy: float = 45.0
@export var swim_rotation_speed: float = 8.0

# Walking Physics (Platforming & gravity)
@export_group("Walking Physics")
@export var walk_speed: float = 210.0
@export var walk_sprint_speed: float = 340.0
@export var walk_acceleration: float = 1400.0
@export var walk_friction: float = 1600.0
@export var walk_rotation_speed: float = 14.0
@export var gravity: float = 400.0
@export var jump_velocity: float = -220.0

# Survival Rates (Units per second)
@export_group("Survival Consumption Rates")
@export var oxygen_drain_swim: float = 1.2
@export var oxygen_recovery_walk: float = 35.0
@export var stamina_sprint_cost: float = 18.0
@export var stamina_recovery_rate: float = 12.0
@export var suffocation_damage: float = 8.0

var is_sprinting: bool = false
var facing_direction: Vector2 = Vector2.RIGHT
var depth_meters: float = 0.0
var _kick_phase: float = 0.0
var _prev_y: float = 0.0

@onready var visual_root: Node2D = $Visual
@onready var bubbles: CPUParticles2D = $Visual/Bubbles
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("Player")
	EventBus.player_died.connect(_on_player_died)
	_prev_y = global_position.y

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		EventBus.ui_toggle_requested.emit("inventory")
	elif event.is_action_pressed("hotbar_1"):
		GameState.use_or_equip_slot(0)
	elif event.is_action_pressed("hotbar_2"):
		GameState.use_or_equip_slot(1)
	elif event.is_action_pressed("hotbar_3"):
		GameState.use_or_equip_slot(2)
	elif event.is_action_pressed("hotbar_4"):
		GameState.use_or_equip_slot(3)
	elif event.is_action_pressed("hotbar_5"):
		GameState.use_or_equip_slot(4)

func _physics_process(delta: float) -> void:
	_check_surface_transition()
	_update_depth_and_zone()
	_handle_input_and_movement(delta)
	_handle_survival_stats(delta)
	_update_animation_and_visuals(delta)
	move_and_slide()

func _check_surface_transition() -> void:
	# When player crosses Y=0 downward -> switch to SWIMMING
	if _prev_y <= 0.0 and global_position.y > 0.0:
		if mode != MovementMode.SWIMMING:
			set_movement_mode(MovementMode.SWIMMING)
	_prev_y = global_position.y

func _update_depth_and_zone() -> void:
	depth_meters = maxf(0.0, global_position.y / 25.0)

	var target_zone: String
	if global_position.y < 0.0:
		target_zone = "Surface"
	elif global_position.y < 1500.0:
		target_zone = "Alien Shallows"
	elif global_position.y < 4000.0:
		target_zone = "Mid-Waters"
	else:
		target_zone = "Deep Trenches"

	GameState.set_zone(target_zone)

func _handle_input_and_movement(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_stamina := GameState.get_stat("stamina")

	# Check sprint capability
	var wants_sprint := Input.is_action_pressed("sprint") and input_vector != Vector2.ZERO
	is_sprinting = wants_sprint and current_stamina > 2.0

	# Fins equipment bonus
	var fin_bonus: float = 1.35 if GameState.equipped_fins != "" else 1.0

	if mode == MovementMode.SWIMMING:
		var target_speed := (swim_sprint_speed if is_sprinting else swim_speed) * fin_bonus

		# Horizontal movement (A / D) with fluid drag
		if input_vector.x != 0.0:
			velocity.x = move_toward(velocity.x, input_vector.x * target_speed, swim_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, swim_friction * delta)

		# Vertical movement (W / S)
		if global_position.y < 0.0:
			# Above water: gravity pulls player back down toward water surface
			velocity.y += gravity * delta
			if input_vector.y > 0.0:
				velocity.y = move_toward(velocity.y, input_vector.y * target_speed, swim_acceleration * delta)
		else:
			# In water (Y >= 0.0): W swims up (toward surface), S swims down (deeper)
			if input_vector.y != 0.0:
				velocity.y = move_toward(velocity.y, input_vector.y * target_speed, swim_acceleration * delta)
			else:
				# Gentle buoyancy force pulling player upward (negative Y) — player slowly floats up if no input
				velocity.y = move_toward(velocity.y, -swim_buoyancy, swim_friction * delta)

		# Horizontal flip: visual_root.scale.x = -1.0 when moving left, 1.0 when moving right (no 360° rotation!)
		if velocity.x > 15.0 or input_vector.x > 0.1:
			visual_root.scale.x = 1.0
			facing_direction = Vector2.RIGHT
		elif velocity.x < -15.0 or input_vector.x < -0.1:
			visual_root.scale.x = -1.0
			facing_direction = Vector2.LEFT

		# Small pitch tilt based on vertical velocity: clamp rotation to ±30° (nose up when ascending, nose down when descending)
		var max_tilt := deg_to_rad(30.0)
		var tilt_ratio := clampf(velocity.y / swim_speed, -1.0, 1.0)
		var target_tilt := tilt_ratio * max_tilt
		visual_root.rotation = lerp_angle(visual_root.rotation, target_tilt, swim_rotation_speed * delta)

	else:
		# WALKING mode (on pod platform or seabed ledges)
		var target_walk_speed := walk_sprint_speed if is_sprinting else walk_speed

		# Apply gravity
		velocity.y += gravity * delta

		# A/D = walk left/right on the platform
		if input_vector.x != 0.0:
			velocity.x = move_toward(velocity.x, input_vector.x * target_walk_speed, walk_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, walk_friction * delta)

		# Jump: use input action "jump"
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

		# Horizontal flip same as swimming
		if velocity.x > 15.0 or input_vector.x > 0.1:
			visual_root.scale.x = 1.0
			facing_direction = Vector2.RIGHT
		elif velocity.x < -15.0 or input_vector.x < -0.1:
			visual_root.scale.x = -1.0
			facing_direction = Vector2.LEFT

		# NO rotation while walking
		visual_root.rotation = lerp_angle(visual_root.rotation, 0.0, walk_rotation_speed * delta)

func _handle_survival_stats(delta: float) -> void:
	# Stamina
	if is_sprinting:
		GameState.modify_stat("stamina", -stamina_sprint_cost * delta)
	else:
		GameState.modify_stat("stamina", stamina_recovery_rate * delta)

	# Oxygen
	if mode == MovementMode.SWIMMING and global_position.y > 0.0:
		# Deeper diving increases oxygen consumption due to water pressure
		var depth_mult: float = 1.0 + clampf(depth_meters * 0.015, 0.0, 1.2)
		var drain := oxygen_drain_swim * depth_mult

		var current_oxygen := GameState.modify_stat("oxygen", -drain * delta)
		if current_oxygen <= 0.0:
			GameState.modify_stat("health", -suffocation_damage * delta)
	else:
		GameState.modify_stat("oxygen", oxygen_recovery_walk * delta)

func _update_animation_and_visuals(delta: float) -> void:
	var speed := velocity.length()
	var is_moving := speed > 15.0

	# Bubbles emission when swimming & moving underwater
	if bubbles:
		bubbles.emitting = (mode == MovementMode.SWIMMING) and is_moving and global_position.y > 0.0
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
			velocity *= 0.5 # Braking entering land / platform
			if visual_root:
				visual_root.rotation = 0.0

func _on_player_died() -> void:
	print("Player health depleted. Game over triggered.")
