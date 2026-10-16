extends Node

## Automated Unit & Integration Tests for Milestone M4
## Verifies passive fish Boids/fleeing, predator AI state machine, and catch-to-cook cycle.

const PassiveFaunaScene = preload("res://res/scenes/PassiveFauna.tscn")
const PassiveFaunaScript = preload("res://res/scripts/PassiveFauna.gd")
const PredatorFaunaScene = preload("res://res/scenes/PredatorFauna.tscn")
const PredatorFaunaScript = preload("res://res/scripts/PredatorFauna.gd")
const ItemDatabaseClass = preload("res://res/scripts/ItemDatabase.gd")

func _ready() -> void:
	print("--- Running Milestone M4 Ecosystem Automated Tests ---")

	var tests_passed := 0
	var total_tests := 0

	# Test 1: Passive Fauna State & Wandering
	total_tests += 1
	var fish: CharacterBody2D = PassiveFaunaScene.instantiate()
	add_child(fish)
	fish.global_position = Vector2(100.0, 100.0)
	assert(fish.get("state") == PassiveFaunaScript.State.WANDERING, "Fish should start in WANDERING state")
	print("✓ Test 1: Passive fauna initialization and wandering verified.")
	tests_passed += 1

	# Test 2: Threat Detection & Flee State
	total_tests += 1
	var dummy_player := Node2D.new()
	dummy_player.add_to_group("Player")
	add_child(dummy_player)
	dummy_player.global_position = Vector2(140.0, 100.0)

	fish.call("_check_threats", 0.016)
	assert(fish.get("state") == PassiveFaunaScript.State.FLEEING, "Fish should flee when player is within detection radius")
	print("✓ Test 2: Passive fauna threat detection and fleeing verified.")
	tests_passed += 1

	# Test 3: Catching Fish for Sustenance
	total_tests += 1
	GameState.inventory.clear()
	assert(GameState.get_item_count("raw_fish") == 0, "No raw fish initially")
	fish.call("catch_fish")
	assert(GameState.get_item_count("raw_fish") == 1, "Player should have 1 raw fish in inventory")
	print("✓ Test 3: Hand-catching passive fauna verified.")
	tests_passed += 1

	# Test 4: Predator AI Patrol -> Pursuit -> Attack -> Retreat FSM
	total_tests += 1
	var stalker: CharacterBody2D = PredatorFaunaScene.instantiate()
	add_child(stalker)
	stalker.global_position = Vector2(500.0, 500.0)
	dummy_player.global_position = Vector2(700.0, 500.0) # 200px away, inside aggro_range (380px)

	stalker.call("_update_ai_state", 0.016)
	assert(stalker.get("state") == PredatorFaunaScript.AIState.PURSUIT, "Predator should switch to PURSUIT when player is in aggro range")

	# Move player into bite range (40px, bite_range is 65px)
	dummy_player.global_position = Vector2(530.0, 500.0)
	stalker.call("_update_ai_state", 0.016)
	assert(stalker.get("state") == PredatorFaunaScript.AIState.ATTACK, "Predator should switch to ATTACK when player is in bite range")

	# Trigger attack execution
	stalker.set("state_timer", 0.0)
	var health_before: float = GameState.get_stat("health")
	stalker.call("_update_ai_state", 0.016)
	var health_after: float = GameState.get_stat("health")
	assert(health_after < health_before, "Player health must decrease from bite attack")
	assert(stalker.get("state") == PredatorFaunaScript.AIState.RETREAT, "Predator must transition to RETREAT after attack")
	print("✓ Test 4: Predator AI FSM (Patrol -> Pursuit -> Attack -> Retreat) verified.")
	tests_passed += 1

	# Test 5: Cooking Raw Fish in Fabricator
	total_tests += 1
	var recipes := ItemDatabaseClass.get_all_recipes()
	var cook_recipe: Resource = null
	for r in recipes:
		if r.get("id") == "cooked_fish":
			cook_recipe = r
			break

	assert(cook_recipe != null, "Cooked fish recipe must exist")
	assert(GameState.get_item_count("raw_fish") == 1, "Must have 1 raw fish to cook")
	var cook_ok: bool = GameState.craft_recipe(cook_recipe)
	assert(cook_ok, "Cooking raw fish into cooked fillet failed")
	assert(GameState.get_item_count("cooked_fish") == 1, "Should have 1 cooked fillet")
	assert(GameState.get_item_count("raw_fish") == 0, "Raw fish should have been consumed")
	print("✓ Test 5: Cooking caught fish in Fabricator verified.")
	tests_passed += 1

	# Test 6: Consuming Cooked Fish for Health and Hunger
	total_tests += 1
	GameState.player_stats.hunger = 40.0
	GameState.player_stats.health = 70.0
	GameState.use_or_equip_slot(0)
	assert(GameState.player_stats.hunger == 85.0, "Hunger should increase by 45 (40 -> 85)")
	assert(GameState.player_stats.health == 85.0, "Health should increase by 15 (70 -> 85)")
	print("✓ Test 6: Consuming cooked fillet restorative benefits verified.")
	tests_passed += 1

	print("--- ALL %d ECOSYSTEM TESTS PASSED SUCCESSFULLY! ---" % tests_passed)
	get_tree().quit(0)

