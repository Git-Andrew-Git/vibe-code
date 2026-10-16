extends CharacterBody2D
class_name PredatorFauna

## PredatorFauna - Territorial predator AI state machine
## Features PATROL, PURSUIT, ATTACK lunge, and tactical RETREAT cooldown.

enum AIState {
	PATROL,
	PURSUIT,
	ATTACK,
	RETREAT
}

@export var patrol_speed: float = 110.0
@export var pursuit_speed: float = 330.0
@export var attack_speed: float = 480.0
@export var aggro_range: float = 380.0
@export var bite_range: float = 65.0
@export var bite_damage: float = 22.0

var state: AIState = AIState.PATROL
var target_node: Node2D = null
var state_timer: float = 0.0
var patrol_direction: Vector2 = Vector2.RIGHT
var undulation_phase: float = 0.0
var is_jaw_open: bool = false

@onready var visual_root: Node2D = $Visual
@onready var alert_label: Label = $AlertLabel

func _ready() -> void:
	add_to_group("PredatorFauna")
	patrol_direction = Vector2.RIGHT.rotated(randf() * TAU)
	state_timer = randf_range(3.0, 6.0)
	if alert_label:
		alert_label.visible = false

func _physics_process(delta: float) -> void:
	_update_ai_state(delta)
	_update_movement_and_steering(delta)
	_update_visuals(delta)
	move_and_slide()

func _update_ai_state(delta: float) -> void:
	state_timer -= delta

	# Look for player as primary target
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0 and players[0] is Node2D:
		target_node = players[0]
	else:
		target_node = null

	match state:
		AIState.PATROL:
			is_jaw_open = false
			if alert_label:
				alert_label.visible = false

			# Check if player enters territory
			if target_node:
				var dist := global_position.distance_to(target_node.global_position)
				if dist < aggro_range:
					state = AIState.PURSUIT
					state_timer = 8.0
					if alert_label:
						alert_label.text = "!"
						alert_label.visible = true
					EventBus.notification_posted.emit("Aggressive Fauna Detected", "danger")

			if state_timer <= 0.0:
				state_timer = randf_range(3.0, 6.0)
				patrol_direction = Vector2.RIGHT.rotated(randf() * TAU)

		AIState.PURSUIT:
			is_jaw_open = true
			if not target_node:
				state = AIState.PATROL
				return

			var dist := global_position.distance_to(target_node.global_position)
			if dist <= bite_range:
				# Trigger Attack Lunge
				state = AIState.ATTACK
				state_timer = 0.6
			elif dist > aggro_range * 1.5 or state_timer <= 0.0:
				# Player managed to escape
				state = AIState.PATROL
				state_timer = 4.0

		AIState.ATTACK:
			is_jaw_open = true
			if target_node and state_timer <= 0.0:
				var dist := global_position.distance_to(target_node.global_position)
				if dist <= bite_range * 1.3:
					# Bite connects!
					GameState.modify_stat("health", -bite_damage)
					EventBus.notification_posted.emit("WARNING: Predator Bite! (-%d HP)" % int(bite_damage), "danger")

				# Tactical wheel away after bite
				state = AIState.RETREAT
				state_timer = 3.5

		AIState.RETREAT:
			is_jaw_open = false
			if alert_label:
				alert_label.visible = false
			if state_timer <= 0.0:
				state = AIState.PATROL
				state_timer = randf_range(4.0, 7.0)

func _update_movement_and_steering(delta: float) -> void:
	var target_vel := Vector2.ZERO

	match state:
		AIState.PATROL:
			target_vel = patrol_direction * patrol_speed
		AIState.PURSUIT:
			if target_node:
				var dir := (target_node.global_position - global_position).normalized()
				target_vel = dir * pursuit_speed
		AIState.ATTACK:
			if target_node:
				var dir := (target_node.global_position - global_position).normalized()
				target_vel = dir * attack_speed
		AIState.RETREAT:
			if target_node:
				# Disengage away from player
				var away_dir := (global_position - target_node.global_position).normalized()
				target_vel = away_dir * (patrol_speed * 1.6)

	velocity = velocity.move_toward(target_vel, 600.0 * delta)

	if velocity.length() > 10.0:
		var target_angle := velocity.angle()
		visual_root.rotation = lerp_angle(visual_root.rotation, target_angle, delta * 7.0)

func _update_visuals(delta: float) -> void:
	var spd := velocity.length()
	undulation_phase += delta * (spd / 18.0)
	if visual_root and visual_root.has_node("StalkerMesh"):
		var mesh: Node2D = visual_root.get_node("StalkerMesh")
		if mesh.has_method("set_visual_state"):
			mesh.set_visual_state(undulation_phase, is_jaw_open, state == AIState.ATTACK)

