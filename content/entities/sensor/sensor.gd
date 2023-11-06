extends StaticBody3D

@export var entity_id = "sensor.sun_next_dawn"
@onready var label: Label3D = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	var stateInfo = await HomeAdapters.adapter.get_state(entity_id)
	label.text = stateInfo["state"]

	await HomeAdapters.adapter.watch_state(entity_id, func(new_state):
		label.text = new_state["state"]
	)

func _on_click(event):
	pass