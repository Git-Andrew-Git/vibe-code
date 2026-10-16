extends HBoxContainer

## HotbarUI - Renders the 5 quick-access hotbar slots at the bottom of the HUD.
## Displays item names, stack counts, and hotkeys [1..5].

const ItemDatabaseClass = preload("res://res/scripts/ItemDatabase.gd")

func _ready() -> void:
	EventBus.inventory_updated.connect(_refresh_hotbar)
	_refresh_hotbar()

func _refresh_hotbar() -> void:
	for child in get_children():
		child.queue_free()

	for i in range(GameState.HOTBAR_CAPACITY):
		var slot_btn := Button.new()
		slot_btn.custom_minimum_size = Vector2(85, 55)

		if i < GameState.inventory.size():
			var slot_data: Dictionary = GameState.inventory[i]
			var item_data: Resource = ItemDatabaseClass.get_item(slot_data["item_id"])
			if item_data:
				var item_name: String = item_data.get("name")
				var color_tint: Color = item_data.get("color_tint")
				slot_btn.text = "[%d] %s\nx%d" % [i + 1, item_name, slot_data["amount"]]
				slot_btn.modulate = color_tint.lightened(0.2)
				var idx := i
				slot_btn.pressed.connect(func(): GameState.use_or_equip_slot(idx))
		else:
			slot_btn.text = "[%d]\nEmpty" % [i + 1]
			slot_btn.disabled = true
			slot_btn.modulate = Color(0.4, 0.45, 0.5, 0.5)

		add_child(slot_btn)
