extends Node

## AudioManager - Manages background music layers, ambient tracks, and sound effects.

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambience_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(music_player)
	add_child(ambience_player)
	add_child(sfx_player)
	
	music_player.bus = &"Music"
	ambience_player.bus = &"Ambience"
	sfx_player.bus = &"SFX"

func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	if fade_duration > 0.0 and music_player.playing:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		await tween.finished
	music_player.stream = stream
	music_player.volume_db = 0.0
	music_player.play()

func play_ambience(stream: AudioStream) -> void:
	ambience_player.stream = stream
	ambience_player.play()

func play_sfx(stream: AudioStream) -> void:
	sfx_player.stream = stream
	sfx_player.play()
