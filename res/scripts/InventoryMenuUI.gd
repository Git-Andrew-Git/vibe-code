extends Control

## InventoryMenuUI - Manages the PDA inventory grid and Fabricator crafting station.
## Toggled via Tab/I or EventBus.ui_toggle_requested("inventory").

const PlayerClass = preload("res://res/scripts/Player.gd")
const ItemDatabaseClass = preload("res://res/scripts/ItemDatabase.gd")
const RecipeDataClass = preload("res://res/scripts/RecipeData.gd")

@onready var slots_container: GridContainer = $CenterContainer/Panel/HBox/InventorySection/Grid
@onready var recipes_container: VBoxContainer = $CenterContainer/Panel/HBox/FabricatorSection/Scroll/RecipeList
@onready var equip_tank_label: Label = $CenterContainer/Panel/HBox/InventorySection/EquipStatus/TankLabel
@onready var equip_fins_label: Label = $CenterContainer/Panel/HBox/InventorySection/EquipStatus/FinsLabel
@onready var close_button: Button = $CenterContainer/Panel/Header/CloseButton

func _ready() -> void:
	visible = false
	EventBus.ui_toggle_requested.connect(_on_toggle_requested)
	EventBus.inventory_updated.connect(_refresh_ui)
	if close_button:
		close_button.pressed.connect(hide_menu)
	_refresh_ui()

func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("toggle_inventory") or event.is_action_pressed("ui_cancel")):
		hide_menu()
		get_viewport().set_input_as_handled()

func _on_toggle_requested(menu_name: String) -> void:
	if menu_name == "inventory":
		if visible:
			hide_menu()
		else:
			show_menu()

func show_menu() -> void:
	visible = true
	_refresh_ui()

func hide_menu() -> void:
	visible = false

func _refresh_ui() -> void:
	if not visible:
		return
	_populate_inventory_grid()
	_populate_fabricator_recipes()
	_update_equipment_labels()

func _populate_inventory_grid() -> void:
	if not slots_container:
		return

	for child in slots_container.get_children():
		child.queue_free()

	for i in range(GameState.INVENTORY_CAPACITY):
		var slot_btn := Button.new()
		slot_btn.custom_minimum_size = Vector2(90, 70)

		if i < GameState.inventory.size():
			var slot_data: Dictionary = GameState.inventory[i]
			var item_data: Resource = ItemDatabaseClass.get_item(slot_data["item_id"])
			if item_data:
				var item_name: String = item_data.get("name")
				var color_tint: Color = item_data.get("color_tint")
				slot_btn.text = "%s\nx%d" % [item_name, slot_data["amount"]]
				slot_btn.modulate = color_tint.lightened(0.2)
				var idx := i
				slot_btn.pressed.connect(func(): GameState.use_or_equip_slot(idx))
		else:
			slot_btn.text = "Empty"
			slot_btn.disabled = true
			slot_btn.modulate = Color(0.4, 0.45, 0.5, 0.5)

		slots_container.add_child(slot_btn)

func _populate_fabricator_recipes() -> void:
	if not recipes_container:
		return

	for child in recipes_container.get_children():
		child.queue_free()

	var recipes := ItemDatabaseClass.get_all_recipes()
	for r in recipes:
		var recipe: Resource = r
		var res_id: String = recipe.get("result_item_id")
		var res_amt: int = recipe.get("result_amount")
		var ingredients: Dictionary = recipe.get("ingredients")
		var result_data: Resource = ItemDatabaseClass.get_item(res_id)
		if not result_data:
			continue

		var res_name: String = result_data.get("name")

		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 50)

		# Recipe Info
		var info_box := VBoxContainer.new()
		info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = "%s (x%d)" % [res_name, res_amt]
		name_label.add_theme_font_size_override("font_size", 14)

		var cost_parts := []
		var can_afford := true
		for ingr_id: String in ingredients:
			var needed: int = ingredients[ingr_id]
			var current: int = GameState.get_item_count(ingr_id)
			var ingr_data: Resource = ItemDatabaseClass.get_item(ingr_id)
			var ingr_name: String = ingr_data.get("name") if ingr_data else ingr_id
			cost_parts.append("%s: %d/%d" % [ingr_name, current, needed])
			if current < needed:
				can_afford = false

		var cost_label := Label.new()
		cost_label.text = ", ".join(cost_parts)
		cost_label.add_theme_font_size_override("font_size", 11)
		cost_label.modulate = Color(0.4, 0.95, 0.5) if can_afford else Color(0.95, 0.45, 0.4)

		info_box.add_child(name_label)
		info_box.add_child(cost_label)

		# Craft Button
		var craft_btn := Button.new()
		craft_btn.text = "Craft"
		craft_btn.custom_minimum_size = Vector2(75, 36)
		craft_btn.disabled = not can_afford
		craft_btn.pressed.connect(func():
			GameState.craft_recipe(recipe)
			_refresh_ui()
		)

		row.add_child(info_box)
		row.add_child(craft_btn)
		recipes_container.add_child(row)

func _update_equipment_labels() -> void:
	if equip_tank_label:
		if GameState.equipped_tank != "":
			var tank_data: Resource = ItemDatabaseClass.get_item(GameState.equipped_tank)
			var t_name: String = tank_data.get("name") if tank_data else GameState.equipped_tank
			equip_tank_label.text = "O2 Tank: %s" % t_name
		else:
			equip_tank_label.text = "O2 Tank: None (Standard 100s)"

	if equip_fins_label:
		if GameState.equipped_fins != "":
			var fin_data: Resource = ItemDatabaseClass.get_item(GameState.equipped_fins)
			var f_name: String = fin_data.get("name") if fin_data else GameState.equipped_fins
			equip_fins_label.text = "Fins: %s (+35%% Speed)" % f_name
		else:
			equip_fins_label.text = "Fins: None (Standard Swim Speed)"
