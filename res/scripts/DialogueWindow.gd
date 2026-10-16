extends Control

## DialogueWindow - Handles displaying dialogue with typewriter effect and optional choices.

signal dialogue_finished(dialogue_id: String)

@onready var speaker_label: Label = $VBoxContainer/SpeakerLabel
@onready var text_label: RichTextLabel = $VBoxContainer/TextLabel
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer

var _dialogue_data: Array = []
var _current_index: int = 0
var _dialogue_id: String = ""
var _typing_speed: float = 0.02 # seconds per character

func _ready() -> void:
	hide()
	choices_container.hide()

func start(dialogue_id: String, data: Array) -> void:
	_dialogue_id = dialogue_id
	_dialogue_data = data
	_current_index = 0
	show()
	_process_next_line()

func _process_next_line() -> void:
	if _current_index >= _dialogue_data.size():
		_dialogue_complete()
		return

	var entry: Dictionary = _dialogue_data[_current_index]
	speaker_label.text = entry.get("speaker", "")
	text_label.clear()
	choices_container.hide()
	# Typewriter effect
	var full_text: String = entry.get("text", "")
	call_deferred("_typewriter", full_text, 0)

func _typewriter(full_text: String, pos: int) -> void:
	if pos >= full_text.length():
		# After text is fully shown, check for choices
		var entry: Dictionary = _dialogue_data[_current_index]
		if entry.has("choices"):
			_show_choices(entry["choices"])
		else:
			# Auto‑advance after a short pause
			await get_tree().create_timer(0.8).timeout
			_current_index += 1
			_process_next_line()
		return
	text_label.append_text(full_text.substr(pos, 1))
	await get_tree().create_timer(_typing_speed).timeout
	_typewriter(full_text, pos + 1)

func _show_choices(choices: Array) -> void:
	choices_container.clear()
	for choice_dict in choices:
		var btn = Button.new()
		btn.text = choice_dict.get("choice", "")
		btn.pressed.connect(func(): _on_choice_selected(choice_dict))
		choices_container.add_child(btn)
	choices_container.show()

func _on_choice_selected(choice_dict: Dictionary) -> void:
	# Jump to the index specified by "next" (0‑based). If omitted, just continue.
	if choice_dict.has("next"):
		_current_index = int(choice_dict["next"])
	else:
		_current_index += 1
	_process_next_line()

func _dialogue_complete() -> void:
	hide()
	emit_signal("dialogue_finished", _dialogue_id)
	# Notify story log that a dialogue concluded
	EventBus.story_log_updated.emit("Dialogue %s finished" % _dialogue_id)

