extends Node

## AudioManager - Manages background music layers, ambient tracks, and sound effects.

const SFX_VOICE_LIMIT := 8

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambience_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _sfx_pool: Array[AudioStreamPlayer] = []
var _music_tween: Tween

func _ready() -> void:
	add_child(music_player)
	add_child(ambience_player)

	music_player.bus = &"Music"
	ambience_player.bus = &"Ambience"

	for i in range(SFX_VOICE_LIMIT):
		var sfx := AudioStreamPlayer.new()
		sfx.bus = &"SFX"
		add_child(sfx)
		_sfx_pool.append(sfx)

func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	if fade_duration > 0.0 and music_player.playing:
		_music_tween = create_tween()
		_music_tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		await _music_tween.finished

	music_player.stream = stream
	music_player.volume_db = -80.0 if fade_duration > 0.0 else 0.0
	music_player.play()

	if fade_duration > 0.0:
		_music_tween = create_tween()
		_music_tween.tween_property(music_player, "volume_db", 0.0, fade_duration)

func play_ambience(stream: AudioStream) -> void:
	ambience_player.stream = stream
	ambience_player.play()

func play_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = pitch_scale
			player.play()
			return

	# Fallback: steal oldest voice if all voices are busy
	var fallback := _sfx_pool[0]
	fallback.stop()
	fallback.stream = stream
	fallback.pitch_scale = pitch_scale
	fallback.play()
