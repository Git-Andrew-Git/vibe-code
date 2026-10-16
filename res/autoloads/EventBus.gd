extends Node

## EventBus - Centralized signal bus for decoupled communication across the game.

# Player signals
signal player_health_changed(current: float, max_health: float)
signal player_stamina_changed(current: float, max_stamina: float)
signal player_oxygen_changed(current: float, max_oxygen: float)
signal player_died

# Inventory & Crafting signals
signal inventory_updated
signal item_crafted(item_id: String, amount: int)
signal item_picked_up(item_id: String, amount: int)

# Environment & World signals
signal time_of_day_changed(hour: int, minute: int)
signal weather_changed(weather_type: String)
signal zone_entered(zone_name: String)

# Story & Quest signals
signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String)
signal objective_updated(objective_id: String, status: String)

# UI signals
signal ui_toggle_requested(menu_name: String)
signal notification_posted(message: String, type: String)
