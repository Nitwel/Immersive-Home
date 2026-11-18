extends Node3D

const VoiceAssistant = preload ("res://lib/home_apis/voice_handler.gd")
const Downsampler = preload ("res://lib/utils/downsampler.gd")
const Chat = preload ("./chat.gd")

## Sample rate Home Assistant expects (see the assist handler's pipeline input).
const target_freq = 16000

var effect: AudioEffectCapture
var downsampler: Downsampler
@export var input_threshold: float = 0.05
@onready var audio_recorder: AudioStreamPlayer = $AudioStreamRecord
@onready var audio_timer: Timer = $AudioTimer
@onready var visual_timer: Timer = $VisualTimer
@onready var audio_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var chat_user: Chat = $ChatUser
@onready var chat_assistant: Chat = $ChatAssistant
@onready var loader: Node3D = $Loader

var running := false
var voice_assistant: VoiceAssistant

func _ready():
	var index = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(index, 0)
	# The capture effect delivers frames at the engine's mix rate, which differs per device.
	downsampler = Downsampler.new(AudioServer.get_mix_rate(), target_freq)

	chat_assistant.visible = false
	chat_user.visible = false
	loader.visible = false

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
		global_position=App.camera.global_position + App.camera.global_transform.basis.z * - 0.5
		global_position.y *= 0.7
		global_transform.basis=Basis.looking_at((App.camera.global_position - global_position) * - 1)
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
	if voice_assistant == null:
		return

	var sterioData: PackedVector2Array = effect.get_buffer(effect.get_frames_available())

	if sterioData.size() == 0:
		return

	var result := downsampler.process(sterioData)
	var data: PackedByteArray = result.data

	if result.peak > input_threshold:
		if audio_timer.is_stopped():
			voice_assistant.start_wakeword()

		audio_timer.start()

	if audio_timer.is_stopped() == false:
		voice_assistant.send_data(data)
