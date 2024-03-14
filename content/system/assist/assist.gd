extends Node3D

const sample_hold = preload ("res://lib/utils/sample_hold.gd")

const audio_freq = 44100
const target_freq = 16000
const sample_rate_ratio: float = audio_freq / target_freq * 1.5

var effect: AudioEffectCapture
@export var input_threshold: float = 0.05
@onready var audio_recorder: AudioStreamPlayer = $AudioStreamRecord
@onready var timer: Timer = $Timer

func _ready():
	var index = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(index, 0)

	timer.timeout.connect(func():
		HomeApi.api.assist_handler.send_data(PackedByteArray())
	)

func _process(_delta):
	var sterioData: PackedVector2Array = effect.get_buffer(effect.get_frames_available())

	if sterioData.size() == 0:
		return

	var monoSampled := sample_hold.sample_and_hold(sterioData, sample_rate_ratio)

	# 16 bit PCM
	var data := PackedByteArray()
	data.resize(monoSampled.size() * 2)

	var max_amplitude = 0.0

	for i in range(monoSampled.size()):
		
		var value = monoSampled[i]
		max_amplitude = max(max_amplitude, value)

		data.encode_s16(i * 2, int(value * 32767))

	if max_amplitude > input_threshold:
		if timer.is_stopped():
			HomeApi.api.assist_handler.start_wakeword()

		timer.start()

	if timer.is_stopped() == false:
		HomeApi.api.assist_handler.send_data(data)