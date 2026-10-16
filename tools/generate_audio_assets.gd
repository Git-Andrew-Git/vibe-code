@tool
extends SceneTree

## Tool script to generate procedural 16-bit PCM WAV audio files for UI, dialogue, and ambience.

func _init() -> void:
	print("Generating procedural audio assets...")

	# Ensure directories exist
	DirAccess.make_dir_recursive_absolute("res://assets/audio/sfx")
	DirAccess.make_dir_recursive_absolute("res://assets/audio/ambience")
	DirAccess.make_dir_recursive_absolute("res://assets/audio/music")

	_create_ui_click("res://assets/audio/sfx/ui_click.wav")
	_create_dialogue_blip("res://assets/audio/sfx/dialogue_blip.wav")
	_create_radio_chime("res://assets/audio/sfx/radio_chime.wav")
	_create_ocean_ambience("res://assets/audio/ambience/ambience_ocean_drone.wav")

	print("Audio generation complete.")
	quit()

func _create_ui_click(path: String) -> void:
	var sample_rate := 44100
	var duration := 0.04 # 40ms
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()

	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var env := 1.0 - (float(i) / float(num_samples)) # Exponential falloff
		var freq := 880.0 - t * 4000.0 # Pitch sweep down
		var val := sin(TAU * freq * t) * env * 0.4
		var sample := int(clampf(val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)

	_save_wav(path, data, sample_rate, false)

func _create_dialogue_blip(path: String) -> void:
	var sample_rate := 44100
	var duration := 0.05 # 50ms
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()

	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var env := sin(float(i) / float(num_samples) * PI) # Windowed bell
		var val := (sin(TAU * 520.0 * t) * 0.6 + sin(TAU * 1040.0 * t) * 0.4) * env * 0.35
		var sample := int(clampf(val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)

	_save_wav(path, data, sample_rate, false)

func _create_radio_chime(path: String) -> void:
	var sample_rate := 44100
	var duration := 0.6 # 600ms (3 ascending tones)
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()

	var tone_duration := duration / 3.0
	var freqs := [440.0, 554.37, 659.25] # A4, C#5, E5 (Major triad)

	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var tone_idx := mini(int(t / tone_duration), 2)
		var local_t := fmod(t, tone_duration)
		var env := (1.0 - (local_t / tone_duration)) * 0.5
		var val := sin(TAU * freqs[tone_idx] * local_t) * env
		var sample := int(clampf(val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)

	_save_wav(path, data, sample_rate, false)

func _create_ocean_ambience(path: String) -> void:
	var sample_rate := 22050
	var duration := 3.0 # 3 second loop
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()

	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		# Sub-bass low frequency ocean rumble
		var sub := sin(TAU * 48.0 * t) * 0.45
		var swell := sin(TAU * 0.33 * t) * 0.25 # Slow water swell
		var high_ripple := sin(TAU * 120.0 * t + sin(TAU * 2.0 * t)) * 0.15
		var val := (sub + swell + high_ripple) * 0.4
		var sample := int(clampf(val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample)

	_save_wav(path, data, sample_rate, true)

func _save_wav(path: String, pcm_data: PackedByteArray, sample_rate: int, loop: bool) -> void:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = pcm_data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = pcm_data.size() / 2

	var err := ResourceSaver.save(wav, path)
	if err == OK:
		print("Saved WAV: ", path)
	else:
		printerr("Failed to save: ", path, " error: ", err)

