const HASS_API = preload ("../hass.gd")

var api: HASS_API
var pipe_running := false
var handler_id := 0

func _init(hass: HASS_API):
	self.api = hass

func on_connect():
	pass

func start_wakeword():
	if pipe_running:
		return

	print("wake start")

	api.send_packet({
		"type": "assist_pipeline/run",
		"start_stage": "wake_word",
		"end_stage": "intent",
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

		print("sending data")

		api.send_raw(stream)

func handle_message(message: Dictionary):
	if message["type"] != "event":
		return

	var event = message["event"]

	if event.has("type") == false:
		return

	print(event["type"])

	match event["type"]:
		"run-start":
			print("Pipeline started")
			pipe_running = true
			handler_id = event["data"]["runner_data"]["stt_binary_handler_id"]
		"run-end":
			pipe_running = false
			handler_id = 0
		"wake_word-start":
			# handle trigger message
			pass
		"wake_word-end":
			# handle trigger message
			pass
		_:
			pass
