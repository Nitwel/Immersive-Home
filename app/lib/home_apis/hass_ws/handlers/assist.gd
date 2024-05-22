extends VoiceHandler

const HASS_API = preload ("../hass.gd")
const VoiceHandler = preload ("res://lib/home_apis/voice_handler.gd")

var api: HASS_API
var pipe_running := false
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

func start_wakeword():
	if pipe_running:
		return

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

func send_data(data: PackedByteArray):
	
	# prepend the handler id to the data in 8 bits
	if pipe_running:
		var stream = PackedByteArray()

		stream.resize(1)
		stream.encode_s8(0, handler_id)
		stream.append_array(data)

		api.send_raw(stream)

func handle_message(message: Dictionary):
	if message["type"] != "event":
		return

	var event = message["event"]

	if event.has("type") == false:
		return

	match event["type"]:
		"run-start":
			pipe_running = true
			handler_id = event["data"]["runner_data"]["stt_binary_handler_id"]
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
			var url = "%s://%s%s" % ["https" if api.url.begins_with("wss") else "http", api.url.split("//")[1],event["data"]["tts_output"]["url"]]

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
			wake_word = null
			handler_id = 0
		_:
			pass
