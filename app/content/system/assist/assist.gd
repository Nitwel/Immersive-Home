extends Node3D

const VoiceAssistant = preload ("res://lib/home_apis/voice_handler.gd")
const sample_hold = preload ("res://lib/utils/sample_hold.gd")
const Chat = preload ("./chat.gd")

const audio_freq = 44100
const target_freq = 16000
const sample_rate_ratio: float = audio_freq / target_freq * 1.5

var effect: AudioEffectCapture
@export var input_threshold: float = 0.05
@onready var audio_recorder: AudioStreamPlayer = $AudioStreamRecord
@onready var audio_timer: Timer = $AudioTimer
@onready var visual_timer: Timer = $VisualTimer
@onready var audio_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var chat_user: Chat = $ChatUser
@onready var chat_assistant: Chat = $ChatAssistant
@onready var loader: Node3D = $Loader
@onready var camera = $"/root/Main/XROrigin3D/XRCamera3D"

var running := false
var voice_assistant: VoiceAssistant

func _ready():
	var index = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(index, 0)

	if !HomeApi.has_connected():
		await HomeApi.on_connect

	voice_assistant = HomeApi.get_voice_assistant()

	if voice_assistant == null:
		return

	finish()

	chat_assistant.flip = true

	audio_timer.timeout.connect(func():
		voice_assistant.send_data(PackedByteArray())
	)

	voice_assistant.on_wake_word.connect(func(_text):
		loader.visible=true
		chat_user.visible=false
		chat_assistant.visible=false
		global_position=camera.global_position + camera.global_transform.basis.z * - 0.5
		global_position.y *= 0.7
		global_transform.basis=Basis.looking_at((camera.global_position - global_position) * - 1)
		running=true
	)

	voice_assistant.on_stt_message.connect(func(text):
		loader.visible=false
		chat_user.visible=true
		chat_user.text=text
	)
	voice_assistant.on_tts_message.connect(func(text):
		chat_assistant.visible=true
		chat_assistant.text=text
	)

	voice_assistant.on_tts_sound.connect(func(audio):
		audio_player_3d.stream=audio
		audio_player_3d.play()
		visual_timer.start()
		running=false
	)

	voice_assistant.on_error.connect(func():
		running=false
		finish()
	)

	visual_timer.timeout.connect(func():
		if audio_player_3d.playing == false:
			finish()
		else:
			await audio_player_3d.finished
			finish()
	)

func finish():
	if running:
		return

	chat_user.visible = false
	chat_assistant.visible = false
	loader.visible = false

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
		if audio_timer.is_stopped():
			voice_assistant.start_wakeword()

		audio_timer.start()

	if audio_timer.is_stopped() == false:
		voice_assistant.send_data(data)
