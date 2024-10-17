extends Entity

const Entity = preload ("../entity.gd")

@onready var line_chart = $LineChart
@onready var timer = $Timer
@onready var label = $Label3D
@onready var settings = $Settings

enum Duration {
	ONE_HOUR,
	ONE_DAY,
	ONE_WEEK,
	ONE_MONTH,
	ONE_YEAR
}

var duration = R.state(Duration.ONE_DAY)

func _ready():
	super()

	icon.value = "finance"
	label.text = entity_id

	remove_child(settings)

	R.effect(func(_arg):
		if show_settings.value:
			add_child(settings)
		elif settings.is_inside_tree():
			remove_child(settings)
			camera_follower.reset()
			App.house.save_all_entities()
	)

	if HomeApi.has_connected() == false:
		await HomeApi.on_connect

	var stateInfo = await HomeApi.get_state(entity_id)
	if stateInfo != null&&stateInfo.has("attributes")&&stateInfo["attributes"].has("friendly_name")&&stateInfo["attributes"]["friendly_name"] != null:
		label.text = stateInfo["attributes"]["friendly_name"]

	request_history()

	R.effect(func(_arg):
		duration.value
		request_history()
	)

	timer.timeout.connect(request_history)

func request_history():
	# Request history from the server

	var now = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())

	var date

	match duration.value:
		Duration.ONE_HOUR:
			date = now - 2 * 60 * 60
		Duration.ONE_DAY:
			date = now - 24 * 60 * 60
		Duration.ONE_WEEK:
			date = now - 7 * 24 * 60 * 60
		Duration.ONE_MONTH:
			date = now - 30 * 24 * 60 * 60
		Duration.ONE_YEAR:
			date = now - 365 * 24 * 60 * 60
		_:
			date = now - 24 * 60 * 60

	var start = Time.get_datetime_string_from_unix_time(date) + ".000Z"

	var result = await HomeApi.get_history(entity_id, start, "hour")

	if result == null:
		return

	var points = result.data.map(func(point):
		# Divide by 1000 to convert milliseconds to seconds
		return Vector2((point.start + point.end) / (2 * 1000), point.mean)
	)

	line_chart.points.value = points
	line_chart.y_axis_label.value = result.unit

func get_interface():
	return "line_chart"

func get_options():
	return {
		"duration": duration.value
	}

func set_options(options: Dictionary):
	if options.has("duration"): duration.value = options["duration"]
