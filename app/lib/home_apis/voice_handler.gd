signal on_wake_word(wake_word: String)
signal on_stt_message(message: String)
signal on_tts_message(message: String)
signal on_tts_sound(sound: AudioStreamMP3)
signal on_error()

func start_wakeword() -> bool:
	return false

func send_data(data: PackedByteArray) -> void:
	pass