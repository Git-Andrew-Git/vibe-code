extends Resource
class_name RecipeData

## RecipeData - Resource schema for Fabricator crafting recipes.

@export var id: String = ""
@export var result_item_id: String = ""
@export var result_amount: int = 1
@export var ingredients: Dictionary = {} # item_id -> int required
@export var craft_time: float = 1.0
@export var category: String = "Survival"

