extends Node3D

@onready var _controller := XRHelpers.get_xr_controller(self)
@export var ray: RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_controller.button_pressed.connect(self._on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed(button):
	print(button)
	if button != "trigger_click":
		return
	
	var collider = ray.get_collider()

	if collider == null:
		return

	print(collider)

	if collider.has_method("_on_toggle"):
		collider._on_toggle()
