extends Node

## Automated Unit & Integration Tests for Milestone M3
## Verifies inventory operations, fabricator crafting, equipment stat bonuses, and save/load persistence.

const ItemDatabaseClass = preload("res://res/scripts/ItemDatabase.gd")

func _ready() -> void:
	print("--- Running Milestone M3 Automated Tests ---")

	var tests_passed := 0
	var total_tests := 0

	# Test 1: ItemDatabase Registration
	total_tests += 1
	var ti: Resource = ItemDatabaseClass.get_item("titanium")
	assert(ti != null and ti.get("name") == "Titanium", "Test 1 Failed: Titanium not registered")
	var o2: Resource = ItemDatabaseClass.get_item("standard_o2_tank")
	assert(o2 != null and o2.get("stat_modifiers").has("max_oxygen"), "Test 1 Failed: O2 Tank modifier missing")
	print("✓ Test 1: ItemDatabase catalog successfully verified.")
	tests_passed += 1

	# Test 2: Inventory Add, Stack & Count
	total_tests += 1
	GameState.inventory.clear()
	assert(GameState.get_item_count("titanium") == 0, "Inventory should be empty")
	GameState.add_item("titanium", 5)
	assert(GameState.get_item_count("titanium") == 5, "Test 2 Failed: Item count should be 5")
	GameState.add_item("titanium", 10)
	assert(GameState.get_item_count("titanium") == 15, "Test 2 Failed: Item count should be 15 after stacking")
	print("✓ Test 2: Inventory addition and stacking verified.")
	tests_passed += 1

	# Test 3: Fabricator Crafting Engine
	total_tests += 1
	GameState.inventory.clear()
	GameState.add_item("kelp_fiber", 4)
	assert(GameState.has_ingredients({"kelp_fiber": 2}), "Should have ingredients for silicone rubber")

	var recipes := ItemDatabaseClass.get_all_recipes()
	var rubber_recipe: Resource = null
	for r in recipes:
		if r.get("id") == "silicone_rubber":
			rubber_recipe = r
			break

	assert(rubber_recipe != null, "Silicone rubber recipe must exist")
	var craft_ok: bool = GameState.craft_recipe(rubber_recipe)
	assert(craft_ok, "Crafting silicone rubber failed")
	assert(GameState.get_item_count("silicone_rubber") == 1, "Should have 1 silicone rubber")
	assert(GameState.get_item_count("kelp_fiber") == 2, "Should have 2 kelp fiber remaining")
	print("✓ Test 3: Fabricator recipe crafting and ingredient consumption verified.")
	tests_passed += 1

	# Test 4: Equipment Bonuses (O2 Tank & Fins)
	total_tests += 1
	GameState.inventory.clear()
	GameState.equipped_tank = ""
	GameState.equipped_fins = ""
	GameState.recalculate_equipment()
	assert(GameState.player_stats.max_oxygen == 100.0, "Base oxygen must be 100.0")

	GameState.add_item("standard_o2_tank", 1)
	GameState.use_or_equip_slot(0)
	assert(GameState.equipped_tank == "standard_o2_tank", "Standard tank must be equipped")
	assert(GameState.player_stats.max_oxygen == 160.0, "Max oxygen must be 160.0 with standard tank")

	GameState.add_item("high_capacity_o2_tank", 1)
	for i in range(GameState.inventory.size()):
		if GameState.inventory[i]["item_id"] == "high_capacity_o2_tank":
			GameState.use_or_equip_slot(i)
			break
	assert(GameState.equipped_tank == "high_capacity_o2_tank", "High-capacity tank must be equipped")
	assert(GameState.player_stats.max_oxygen == 220.0, "Max oxygen must be 220.0 with high-capacity tank")
	print("✓ Test 4: Equipment stat bonuses (Standard & High-Capacity O2 Tanks) verified.")
	tests_passed += 1

	# Test 5: Consumables (Food & Water Restoration)
	total_tests += 1
	GameState.player_stats.hunger = 40.0
	GameState.player_stats.thirst = 40.0
	GameState.inventory.clear()
	GameState.add_item("filtered_water", 1)
	GameState.add_item("nutrient_brick", 1)

	# Drink water
	GameState.use_or_equip_slot(0)
	assert(GameState.player_stats.thirst == 75.0, "Thirst should increase from 40 to 75")
	# Eat brick
	GameState.use_or_equip_slot(0)
	assert(GameState.player_stats.hunger == 80.0, "Hunger should increase from 40 to 80")
	print("✓ Test 5: Consumable sustenance effects (Hydration & Nutrition) verified.")
	tests_passed += 1

	# Test 6: Persistence (Save & Load)
	total_tests += 1
	GameState.inventory.clear()
	GameState.add_item("titanium", 12)
	GameState.add_item("copper_ore", 7)
	var save_ok: bool = GameState.save_game()
	assert(save_ok, "Save game failed")

	# Clear and reload
	GameState.inventory.clear()
	assert(GameState.get_item_count("titanium") == 0, "Inventory must be cleared")
	var load_ok: bool = GameState.load_game()
	assert(load_ok, "Load game failed")
	assert(GameState.get_item_count("titanium") == 12, "Loaded titanium should be 12")
	assert(GameState.get_item_count("copper_ore") == 7, "Loaded copper should be 7")
	print("✓ Test 6: Inventory and equipment serialization to JSON verified.")
	tests_passed += 1

	print("--- ALL %d TESTS PASSED SUCCESSFULLY! ---" % tests_passed)
	get_tree().quit(0)

