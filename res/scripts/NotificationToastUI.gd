extends VBoxContainer

## NotificationToastUI - Displays short animated notification toasts for item pickups,
## crafting achievements, and equipment changes.

func _ready() -> void:
	EventBus.notification_posted.connect(_on_notification_posted)

func _on_notification_posted(message: String, type: String) -> void:
	var label := Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 14)

	# Type tinting
	match type:
		"pickup":
			label.modulate = Color(0.35, 0.95, 0.85)
		"craft":
			label.modulate = Color(0.98, 0.85, 0.35)
		"equip":
			label.modulate = Color(0.45, 0.80, 1.0)
		"consume":
			label.modulate = Color(0.55, 0.95, 0.45)
		_:
			label.modulate = Color.WHITE

	add_child(label)

	# Fade out and queue_free
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)
