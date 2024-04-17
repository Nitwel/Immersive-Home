extends Entity

const Entity = preload ("../entity.gd")

@onready var line_chart = $LineChart
@onready var timer = $Timer
@onready var label = $Label3D

func _ready():
	super()

	icon.value = "finance"

	label.text = entity_id

	if HomeApi.has_connected() == false:
		await HomeApi.on_connect

	var stateInfo = await HomeApi.get_state(entity_id)
	if stateInfo["attributes"]["friendly_name"] != null:
		label.text = stateInfo["attributes"]["friendly_name"]

	request_history()

	timer.timeout.connect(request_history)

func request_history():
	# Request history from the server

	var now = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())

	# 2 days ago
	var two_days_ago = now - 2 * 24 * 60 * 60

	var start = Time.get_datetime_string_from_unix_time(two_days_ago) + ".000Z"

	var result = await HomeApi.get_history(entity_id, start)

	var points = result.data.map(func(point):
		# Divide by 1000 to convert milliseconds to seconds
		return Vector2((point.start + point.end) / (2 * 1000), point.mean)
	)

	line_chart.points.value = points
	line_chart.y_axis_label.value = result.unit

func get_interface():
	return "line_chart"
