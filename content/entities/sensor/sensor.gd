extends StaticBody3D

@export var entity_id = "sensor.sun_next_dawn"
@onready var label: Label3D = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	if HomeApi.has_connected() == false:
		await HomeApi.on_connect

	var stateInfo = await HomeApi.get_state(entity_id)
	set_text(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_text(new_state)
	)

func set_text(stateInfo):
	var text = stateInfo["state"]

	if stateInfo["attributes"]["friendly_name"] != null:
		text = stateInfo["attributes"]["friendly_name"] + "\n" + text

	if stateInfo["attributes"].has("unit_of_measurement") && stateInfo["attributes"]["unit_of_measurement"] != null:
		text += " " + stateInfo["attributes"]["unit_of_measurement"]

	label.text = text

func _save():
	return {
		"transform": transform,
		"entity_id": entity_id
	}