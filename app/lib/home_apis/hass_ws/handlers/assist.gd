extends VoiceHandler

const HASS_API = preload ("../hass.gd")
const VoiceHandler = preload ("res://lib/home_apis/voice_handler.gd")

## Max audio kept while waiting for the pipeline to start: 5 s of 16 kHz 16 bit mono.
const MAX_PENDING_BYTES = 16000 * 2 * 5
## How long to wait for run-start before allowing a new pipeline request.
const START_TIMEOUT_MS = 10000

var api: HASS_API
var pipe_running := false
## True between requesting a pipeline run and receiving its run-start event.
var pipe_starting := false
## Audio captured while the pipeline was starting, sent once it is running.
var pending_audio := PackedByteArray()
var pipe_start_time := 0
var handler_id := 0
var wake_word = null:
	set(value):
		if value != wake_word&&value != null:
			on_wake_word.emit(value)
		wake_word = value

var stt_message = null:
	set(value):
		if value != stt_message&&value != null:
			on_stt_message.emit(value)
		stt_message = value

var tts_message = null:
	set(value):
		if value != tts_message&&value != null:
			on_tts_message.emit(value)
		tts_message = value

var tts_sound = null:
	set(value):
		if value != tts_sound&&value != null:
			on_tts_sound.emit(value)
		tts_sound = value

func _init(hass: HASS_API):
	self.api = hass

	api.connection.on_packed_received.connect(handle_message)

func start_wakeword() -> bool:
	# Give up on a start request Home Assistant never confirmed.
	if pipe_starting and Time.get_ticks_msec() - pipe_start_time > START_TIMEOUT_MS:
		pipe_starting = false

	if pipe_running or pipe_starting:
		return false

	pipe_starting = true
	pipe_start_time = Time.get_ticks_msec()
	pending_audio.clear()

	api.connection.send_packet({
		"type": "assist_pipeline/run",
		"start_stage": "wake_word",
		"end_stage": "tts",
		"input": {
			"timeout": 5,
			"sample_rate": 16000
		},
		"timeout": 60
	}, true)

	return true

func send_data(data: PackedByteArray) -> void:
	if pipe_running:
		_send_audio(data)
	elif pipe_starting and data.size() > 0:
		# Keep the first words (usually the wake word) instead of dropping them.
		pending_audio.append_array(data)
		if pending_audio.size() > MAX_PENDING_BYTES:
			pending_audio = pending_audio.slice(pending_audio.size() - MAX_PENDING_BYTES)

## Sends audio to the running pipeline, prefixed with the handler id in 8 bits.
## An empty array tells Home Assistant the audio stream has ended.
func _send_audio(data: PackedByteArray) -> void:
	var stream = PackedByteArray()

	stream.resize(1)
	stream.encode_s8(0, handler_id)
	stream.append_array(data)

	api.connection.send_raw(stream)

func handle_message(message: Dictionary):
	if message["type"] != "event":
		return

	var event = message["event"]

	if event.has("type") == false:
		return

	match event["type"]:
		"run-start":
			pipe_running = true
			pipe_starting = false
			handler_id = event["data"]["runner_data"]["stt_binary_handler_id"]

			if pending_audio.size() > 0:
				_send_audio(pending_audio)
				pending_audio.clear()
		"wake_word-end":
			if pipe_running == false:
				return

			if event["data"]["wake_word_output"].has("wake_word_phrase") == false:
				return
			
			wake_word = event["data"]["wake_word_output"]["wake_word_phrase"]
		"stt-end":
			if pipe_running == false:
				return

			if event["data"]["stt_output"].has("text") == false:
				return

			stt_message = event["data"]["stt_output"]["text"]
		"intent-end":
			if pipe_running == false:
				return

			tts_message = event["data"]["intent_output"]["response"]["speech"]["plain"]["speech"]
		"tts-end":
			if pipe_running == false:
				return

			if event["data"]["tts_output"].has("url") == false:
				return

			var headers = PackedStringArray(["Authorization: Bearer %s" % api.token, "Content-Type: application/json"])
			var url = api.get_http_url() + event["data"]["tts_output"]["url"]

			Request.request(url, headers, HTTPClient.METHOD_GET)

			var response = await Request.request_completed

			if response[0] != HTTPRequest.RESULT_SUCCESS:
				return
			
			var sound = AudioStreamMP3.new()
			sound.data = response[3]

			tts_sound = sound
		"error":
			if event["data"]["code"] == "stt-no-text-recognized":
				on_error.emit()
		"run-end":
			pipe_running = false
			pipe_starting = false
			pending_audio.clear()
			wake_word = null
			handler_id = 0
		_:
			pass
