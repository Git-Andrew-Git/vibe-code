extends CharacterBody2D
class_name PassiveFauna

## PassiveFauna - Docile bioluminescent alien fish with Boids flocking and flee behavior.
## Can be caught by hand for sustenance or cooked in the fabricator.

enum State {
	WANDERING,
	FLOCKING,
	FLEEING
}

@export var wander_speed: float = 75.0
@export var flee_speed: float = 230.0
@export var swim_accel: float = 280.0
@export var detection_radius: float = 150.0

var state: State = State.WANDERING
var target_direction: Vector2 = Vector2.RIGHT
var flee_timer: float = 0.0
var wander_timer: float = 0.0
var tail_phase: float = 0.0
var is_player_in_catch_range: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var visual_root: Node2D = $Visual

func _ready() -> void:
	add_to_group("PassiveFauna")
	target_direction = Vector2.RIGHT.rotated(randf() * TAU)
	wander_timer = randf_range(2.0, 5.0)

	var catch_area: Area2D = $CatchArea
	if catch_area:
		catch_area.body_entered.connect(_on_catch_entered)
		catch_area.body_exited.connect(_on_catch_exited)

	if prompt_label:
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if is_player_in_catch_range and event.is_action_pressed("interact"):
		catch_fish()

func _physics_process(delta: float) -> void:
	_check_threats(delta)
	_update_movement(delta)
	_update_visuals(delta)
	move_and_slide()

func _check_threats(delta: float) -> void:
	if state == State.FLEEING:
		flee_timer -= delta
		if flee_timer <= 0.0:
			state = State.WANDERING
		return

	# Scan for player or predators
	var threats := get_tree().get_nodes_in_group("Player") + get_tree().get_nodes_in_group("PredatorFauna")
	for node in threats:
		if node is Node2D:
			var diff: Vector2 = global_position - node.global_position
			if diff.length() < detection_radius:
				state = State.FLEEING
				flee_timer = 2.5
				target_direction = diff.normalized()
				return

func _update_movement(delta: float) -> void:
	if state == State.FLEEING:
		velocity = velocity.move_toward(target_direction * flee_speed, swim_accel * 2.0 * delta)
	else:
		wander_timer -= delta
		if wander_timer <= 0.0:
			wander_timer = randf_range(3.0, 6.0)
			_calculate_flock_direction()

		velocity = velocity.move_toward(target_direction * wander_speed, swim_accel * delta)

	# Steer visual rotation
	if velocity.length() > 5.0:
		var target_angle := velocity.angle()
		visual_root.rotation = lerp_angle(visual_root.rotation, target_angle, delta * 8.0)

func _calculate_flock_direction() -> void:
	var neighbors := get_tree().get_nodes_in_group("PassiveFauna")
	var avg_dir := Vector2.ZERO
	var count := 0
	var separation := Vector2.ZERO

	for n in neighbors:
		if n != self and n is Node2D:
			var offset: Vector2 = n.global_position - global_position
			var dist := offset.length()
			if dist < 180.0:
				avg_dir += n.velocity.normalized()
				count += 1
				if dist < 45.0:
					separation -= offset.normalized() / maxf(dist, 1.0)

	if count > 0:
		state = State.FLOCKING
		target_direction = (avg_dir / float(count) + separation * 2.0 + Vector2.RIGHT.rotated(randf() * TAU) * 0.3).normalized()
	else:
		state = State.WANDERING
		target_direction = Vector2.RIGHT.rotated(randf() * TAU)

func _update_visuals(delta: float) -> void:
	var spd := velocity.length()
	tail_phase += delta * (spd / 12.0)
	if visual_root and visual_root.has_node("FishMesh"):
		var mesh: Node2D = visual_root.get_node("FishMesh")
		if mesh.has_method("set_tail_phase"):
			mesh.set_tail_phase(tail_phase)

func _on_catch_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_catch_range = true
		if prompt_label:
			prompt_label.text = "[E] Catch Ribbon Fish"
			prompt_label.visible = true

func _on_catch_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_catch_range = false
		if prompt_label:
			prompt_label.visible = false

func catch_fish() -> void:
	is_player_in_catch_range = false
	if prompt_label:
		prompt_label.visible = false
	GameState.add_item("raw_fish", 1)

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
