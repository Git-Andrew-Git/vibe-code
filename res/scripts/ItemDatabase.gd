extends RefCounted
class_name ItemDatabase

## ItemDatabase - Master registry for all survival items and fabricator recipes.

const ItemDataClass = preload("res://res/scripts/ItemData.gd")
const RecipeDataClass = preload("res://res/scripts/RecipeData.gd")

static var _items: Dictionary = {}
static var _recipes: Array = []
static var _initialized: bool = false

static func init_database() -> void:
	if _initialized:
		return
	_initialized = true

	# --- Resources ---
	_register_item("titanium", "Titanium", "Basic structural building block harvested from mineral outcrops.", ItemDataClass.ItemCategory.RESOURCE, 30, {}, Color(0.75, 0.8, 0.85))
	_register_item("copper_ore", "Copper Ore", "Conductive mineral vital for wiring and batteries.", ItemDataClass.ItemCategory.RESOURCE, 30, {}, Color(0.88, 0.52, 0.32))
	_register_item("kelp_fiber", "Kelp Fiber", "Tough, flexible organic fiber cut from giant alien kelp.", ItemDataClass.ItemCategory.RESOURCE, 30, {}, Color(0.25, 0.75, 0.45))
	_register_item("silicone_rubber", "Silicone Rubber", "Synthetic waterproof elastomer synthesized from kelp resin.", ItemDataClass.ItemCategory.RESOURCE, 30, {}, Color(0.9, 0.9, 0.95))
	_register_item("coral_sample", "Coral Sample", "Living bioluminescent coral tissue harvested with a survival blade.", ItemDataClass.ItemCategory.RESOURCE, 20, {}, Color(0.85, 0.3, 0.65))
	_register_item("creepvine_seed", "Kelp Seed Cluster", "Bioluminescent seed pod rich in organic lubricating oils.", ItemDataClass.ItemCategory.RESOURCE, 20, {}, Color(0.95, 0.82, 0.2))

	# --- Equipment ---
	_register_item("standard_o2_tank", "Standard O2 Tank", "Pressurized air cylinder adding +60s oxygen capacity.", ItemDataClass.ItemCategory.EQUIPMENT, 1, {"max_oxygen": 60.0}, Color(0.35, 0.85, 0.95))
	_register_item("high_capacity_o2_tank", "High-Capacity O2 Tank", "Reinforced titanium reservoir adding +120s oxygen capacity.", ItemDataClass.ItemCategory.EQUIPMENT, 1, {"max_oxygen": 120.0}, Color(0.2, 0.65, 0.98))
	_register_item("swim_fins", "Hydrodynamic Fins", "Increases underwater swimming velocity by 35%.", ItemDataClass.ItemCategory.EQUIPMENT, 1, {"swim_speed_mult": 1.35}, Color(0.15, 0.45, 0.65))

	# --- Tools ---
	_register_item("survival_knife", "Survival Knife", "Hardened titanium blade for sample collection and defense.", ItemDataClass.ItemCategory.TOOL, 1, {}, Color(0.9, 0.8, 0.3))

	# --- Consumables ---
	_register_item("raw_fish", "Ribbon Fish", "Docile alien filter-feeder. Best cooked before consumption.", ItemDataClass.ItemCategory.CONSUMABLE, 5, {"hunger": 15.0, "health": -5.0}, Color(0.25, 0.85, 0.85))
	_register_item("cooked_fish", "Cooked Ribbon Fish", "Succulent cooked alien fillet. Restores 45 hunger and 15 health.", ItemDataClass.ItemCategory.CONSUMABLE, 10, {"hunger": 45.0, "health": 15.0}, Color(0.95, 0.65, 0.25))
	_register_item("filtered_water", "Filtered Water", "Purified drinking water pouch. Restores 35 thirst.", ItemDataClass.ItemCategory.CONSUMABLE, 10, {"thirst": 35.0}, Color(0.4, 0.85, 1.0))
	_register_item("nutrient_brick", "Nutrient Brick", "Standard survival ration. Restores 40 hunger and 10 health.", ItemDataClass.ItemCategory.CONSUMABLE, 10, {"hunger": 40.0, "health": 10.0}, Color(0.85, 0.65, 0.3))

	# --- Recipes ---
	_register_recipe("silicone_rubber", "silicone_rubber", 1, {"kelp_fiber": 2}, "Basic Materials")
	_register_recipe("standard_o2_tank", "standard_o2_tank", 1, {"titanium": 3}, "Survival Gear")
	_register_recipe("high_capacity_o2_tank", "high_capacity_o2_tank", 1, {"standard_o2_tank": 1, "titanium": 2}, "Survival Gear")
	_register_recipe("swim_fins", "swim_fins", 1, {"silicone_rubber": 2}, "Survival Gear")
	_register_recipe("survival_knife", "survival_knife", 1, {"titanium": 1, "silicone_rubber": 1}, "Tools")
	_register_recipe("filtered_water", "filtered_water", 1, {"kelp_fiber": 1}, "Sustenance")
	_register_recipe("cooked_fish", "cooked_fish", 1, {"raw_fish": 1}, "Sustenance")
	_register_recipe("nutrient_brick", "nutrient_brick", 1, {"raw_fish": 1, "kelp_fiber": 1}, "Sustenance")

static func _register_item(id: String, item_name: String, desc: String, cat: int, max_stk: int, mods: Dictionary, tint: Color) -> void:
	var item: Resource = ItemDataClass.new()
	item.set("id", id)
	item.set("name", item_name)
	item.set("description", desc)
	item.set("category", cat)
	item.set("max_stack", max_stk)
	item.set("stat_modifiers", mods)
	item.set("color_tint", tint)
	_items[id] = item

static func _register_recipe(id: String, result_id: String, amount: int, ingr: Dictionary, cat: String) -> void:
	var r: Resource = RecipeDataClass.new()
	r.set("id", id)
	r.set("result_item_id", result_id)
	r.set("result_amount", amount)
	r.set("ingredients", ingr)
	r.set("category", cat)
	_recipes.append(r)

static func get_item(id: String) -> Resource:
	init_database()
	return _items.get(id, null)

static func get_all_recipes() -> Array:
	init_database()
	return _recipes
