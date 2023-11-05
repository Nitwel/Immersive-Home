extends StaticBody3D

@export var entity_id = "switch.plug_printer_2"
@onready var sprite: AnimatedSprite3D = $Icon

# Called when the node enters the scene tree for the first time.
func _ready():
	var stateInfo = await HomeAdapters.adapter_ws.get_state(entity_id)
	if stateInfo["state"] == "on":
		sprite.set_frame(0)
	else:
		sprite.set_frame(1)


func _on_toggle():
	HomeAdapters.adapter_ws.set_state(entity_id, "off" if sprite.get_frame() == 0 else "on")
	if sprite.get_frame() == 0:
		sprite.set_frame(1)
	else:
		sprite.set_frame(0)

func _on_request_completed():
	pass
