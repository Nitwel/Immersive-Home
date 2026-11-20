extends Entity

const Entity = preload ("../entity.gd")

@onready var label: Label3D = $Label
@onready var collision_shape = $CollisionShape3D
@onready var chart_button = $Button

var sensor_data = {}
var unit = null
var is_text = true

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	icon.value = "sensors"

	var stateInfo = await HomeApi.get_state(entity_id)
	set_text(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_text(new_state)
	)

	remove_child(chart_button)

	chart_button.on_button_down.connect(func():
		App.house.create_entity(entity_id, global_position, "line_chart")
		remove_child(chart_button)
	)

func _on_click(_event):
	if is_text:
		return

	if chart_button.is_inside_tree() == false:
		add_child(chart_button)
	else:
		remove_child(chart_button)

func set_text(stateInfo):
	if stateInfo == null:
		return

	var state = str(stateInfo["state"])
	var attributes = stateInfo.get("attributes", {})
	if attributes == null:
		attributes = {}

	is_text = state.is_valid_float() == false&&state.is_valid_int() == false
	var unavailable = state == "unavailable"||state == "unknown"

	var text = state.capitalize() if unavailable else state

	if attributes.get("unit_of_measurement") != null:
		unit = str(attributes["unit_of_measurement"])
		# "Unavailable %" reads like a value; only show the unit next to real values.
		if not unavailable:
			text += " " + unit

	# Not every entity has a name; fall back to its id like the other entities do.
	var friendly_name = attributes.get("friendly_name")
	text = (str(friendly_name) if friendly_name != null else entity_id) + "\n" + text

	if attributes.get("device_class") != null:
		sensor_data[attributes["device_class"]] = state

	label.text = text

	var font = label.get_font()
	var width = 0
	var height = 0

	var size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, label.width, label.font_size)

	collision_shape.shape.size.x = size.x * label.pixel_size * 0.5
	collision_shape.shape.size.y = size.y * label.pixel_size * 0.25

func get_sensor_data(type: String):
	if sensor_data.has(type) == false:
		return null

	return sensor_data[type]

func get_sensor_unit(type: String):
	if sensor_data.has(type) == false:
		return null

	return unit
