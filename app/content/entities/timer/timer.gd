extends Entity

const Entity = preload ("../entity.gd")

@onready var time_label: Label3D = $TimerLabel
@onready var name_label: Label3D = $NameLabel
@onready var icon_label: Label3D = $IconLabel

@onready var play_button: Button3D = $PlayButton
@onready var stop_button: Button3D = $StopButton

var duration = "00:00:00"
var finishes_at = null
var running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	var stateInfo = await HomeApi.get_state(entity_id)

	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	play_button.on_button_up.connect(func():
		if running == false:
			HomeApi.set_state(entity_id, "start")
		else:
			HomeApi.set_state(entity_id, "pause")
	)

	stop_button.on_button_up.connect(func():
		HomeApi.set_state(entity_id, "cancel")
	)

	EventSystem.on_slow_tick.connect(_slow_tick)

func _slow_tick(_delta: float):
	if running == false:
		return

	if finishes_at != null:
		var time_left = finishes_at - round(Time.get_unix_time_from_system())
		if time_left < 0:
			time_left = 0

		var time_dict = Time.get_time_dict_from_unix_time(time_left)
		time_label.text = "%01d:%02d:%02d" % [time_dict["hour"],time_dict["minute"],time_dict["second"]]

func set_state(stateInfo):
	if stateInfo == null:
		return

	print("stateInfo: ", stateInfo)

	var state = stateInfo["state"]
	var attributes = stateInfo["attributes"]

	# if attributes.has("icon")&&attributes["icon"] != null&&attributes["icon"].begins_with("mdi:"):
	# 	icon_label.text = attributes["icon"].split(":")[1]
	# else:
	# 	icon_label.text = "timer"

	if attributes.has("friendly_name")&&attributes["friendly_name"] != null:
		name_label.text = attributes["friendly_name"]
	else:
		name_label.text = "Timer"

	if attributes.has("duration")&&attributes["duration"] != null:
		duration = attributes["duration"]
	else:
		duration = "00:00:00"

	stop_button.visible = state == "active"||state == "paused"
	stop_button.disabled = state == "idle"

	match state:
		"idle":
			running = false
			finishes_at = null
			time_label.text = duration
			play_button.position.x = 0
			play_button.label = "play_arrow"
		"paused":
			running = false
			play_button.position.x = -0.03
			play_button.label = "resume"
		"active":
			if attributes.has("finishes_at")&&attributes["finishes_at"] != null:
				finishes_at = Time.get_unix_time_from_datetime_string(attributes["finishes_at"])
				running = true

			play_button.position.x = -0.03
			play_button.label = "pause"