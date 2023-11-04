extends Node3D

@onready var _controller := XRHelpers.get_xr_controller(self)
@export var light: StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_controller.button_pressed.connect(self._on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed(button):
	print("right: ", button)
	if button != "trigger_click":
		return

	if light == null:
		return
	
	# set light position to controller position
	light.transform.origin = _controller.transform.origin
