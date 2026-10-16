extends Resource
class_name ItemData

## ItemData - Resource schema for inventory items, equipment, and resources.

enum ItemCategory {
	RESOURCE,
	EQUIPMENT,
	TOOL,
	CONSUMABLE
}

@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""
@export var category: ItemCategory = ItemCategory.RESOURCE
@export var max_stack: int = 20
@export var stat_modifiers: Dictionary = {}
@export var color_tint: Color = Color.WHITE

func can_use() -> bool:
	return category == ItemCategory.CONSUMABLE or category == ItemCategory.EQUIPMENT
