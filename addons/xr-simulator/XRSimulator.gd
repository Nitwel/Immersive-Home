extends Node

enum ControllerSelectionMode {Hold, Toggle}

@export var enabled: bool
@export var disable_xr_in_editor: bool = true
@export var controller_selection_mode: ControllerSelectionMode = ControllerSelectionMode.Hold
@export var device_x_sensitivity: float = 1
@export var device_y_sensitivity: float = 1
@export var scroll_sensitivity: float = 1
@export var is_camera_height_limited: bool = true
@export var min_camera_height: float = 0.5
@export var max_camera_height: float = 2.0
@export var xr_origin: NodePath

var origin: XROrigin3D
var camera: XRCamera3D
var left_controller: XRController3D
var right_controller: XRController3D
var left_tracker: XRPositionalTracker
var right_tracker: XRPositionalTracker

var toggle_left_controller = false
var toggle_right_controller = false
var toggle_shift = false

var key_map = {
	KEY_1: "by_button",
	KEY_2: "ax_button",
	KEY_3: "by_touch",
	KEY_4: "ax_touch",
	KEY_5: "trigger_touch",
	KEY_6: "grip_touch",
	KEY_7: "secondary_click",
	KEY_8: "secondary_touch",
	KEY_9: "",
	KEY_0: "",
	KEY_MINUS: "primary_click",
	KEY_EQUAL: "primary_touch",
	KEY_BACKSPACE: "",
	KEY_ENTER: "menu_button"
}

@onready var viewport: Viewport = get_viewport()

func _ready():
	if not enabled or not OS.has_feature("editor"):
		enabled = false
		return
		
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	origin = get_node(xr_origin)

	camera = origin.get_node("XRCamera3D")
	
	var left_hand = XRServer.get_tracker("left_hand")
	if left_hand == null:
		left_tracker = XRPositionalTracker.new()
		left_tracker.type = XRServer.TRACKER_CONTROLLER
		left_tracker.hand = XRPositionalTracker.TRACKER_HAND_LEFT
		left_tracker.name = "left_hand"
	else:
		left_tracker = left_hand
	
	var right_hand = XRServer.get_tracker("right_hand")
	if right_hand == null:
		right_tracker = XRPositionalTracker.new()
		right_tracker.type = XRServer.TRACKER_CONTROLLER
		right_tracker.hand = XRPositionalTracker.TRACKER_HAND_RIGHT
		right_tracker.name = "right_hand"
	else:
		right_tracker = right_hand
	
	for child in origin.get_children():
		if child.get("tracker"):
			var pose = child.pose
			if child.tracker == "left_hand":
				left_controller = child
				left_tracker.set_pose(pose, child.transform, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
				XRServer.add_tracker(left_tracker)
			elif child.tracker == "right_hand":
				right_controller = child
				right_tracker.set_pose(pose, child.transform, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
				XRServer.add_tracker(right_tracker)
	

func _process(_delta):
	if enabled and disable_xr_in_editor and OS.has_feature("editor") and viewport.use_xr:
		viewport.use_xr = false

func _input(event):
	if not enabled or not origin.current or not OS.has_feature("editor"):
		return
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	simulate_joysticks()
	var is_any_controller_selected = false
	if event is InputEventMouseMotion:
		if Input.is_physical_key_pressed(KEY_Q) or toggle_left_controller:
			is_any_controller_selected = true
			if Input.is_key_pressed(KEY_SHIFT):
				rotate_device(event, left_controller)
			else:
				move_controller(event, left_controller)
		if Input.is_physical_key_pressed(KEY_E) or toggle_right_controller:
			is_any_controller_selected = true
			if Input.is_key_pressed(KEY_SHIFT):
				rotate_device(event, right_controller)
			else:
				move_controller(event, right_controller)
		if not is_any_controller_selected:
			rotate_device(event, camera)
	elif event is InputEventMouseButton:
		if Input.is_physical_key_pressed(KEY_Q) or toggle_left_controller:
			is_any_controller_selected = true
			attract_controller(event, left_controller)
			simulate_trigger(event, left_controller)
			simulate_grip(event, left_controller)
		if Input.is_physical_key_pressed(KEY_E) or toggle_right_controller:
			is_any_controller_selected = true
			attract_controller(event, right_controller)
			simulate_trigger(event, right_controller)
			simulate_grip(event, right_controller)
		if not is_any_controller_selected:
			camera_height(event)
	elif event is InputEventKey:
		if controller_selection_mode == ControllerSelectionMode.Toggle and event.pressed:
			if event.keycode == KEY_Q:
				toggle_left_controller = !toggle_left_controller
			elif event.keycode == KEY_E:
				toggle_right_controller = !toggle_right_controller
			
		if Input.is_physical_key_pressed(KEY_Q) or toggle_left_controller:
			simulate_buttons(event, left_controller)
		if Input.is_physical_key_pressed(KEY_E) or toggle_right_controller:
			simulate_buttons(event, right_controller)
			
func camera_height(event: InputEventMouseButton):
	var direction = -1
	
	if not event.pressed:
		return
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		direction = 1
	elif event.button_index != MOUSE_BUTTON_WHEEL_DOWN:
		return
	
	var pos = camera.transform.origin
	var camera_y = pos.y + (scroll_sensitivity * direction)/20
	if (camera_y >= max_camera_height or camera_y <= min_camera_height) and is_camera_height_limited:
		camera_y = pos.y
	camera.transform.origin = Vector3(pos.x, camera_y , pos.z)

func simulate_joysticks():
	var vec_left = vector_key_mapping(KEY_D, KEY_A, KEY_W, KEY_S)
	left_tracker.set_input("primary", vec_left)
	
	var vec_right = vector_key_mapping(KEY_RIGHT, KEY_LEFT, KEY_UP, KEY_DOWN)
	
	right_tracker.set_input("primary", vec_right)

func simulate_trigger(event: InputEventMouseButton, controller: XRController3D):
	if event.button_index == MOUSE_BUTTON_LEFT:
		if controller.tracker == "left_hand":
			left_tracker.set_input("trigger", float(event.pressed))
			left_tracker.set_input("trigger_click", event.pressed)
		else:
			right_tracker.set_input("trigger", float(event.pressed))
			right_tracker.set_input("trigger_click", event.pressed)

func simulate_grip(event: InputEventMouseButton, controller: XRController3D):
	if event.button_index == MOUSE_BUTTON_RIGHT:
		if controller.tracker == "left_hand":
			left_tracker.set_input("grip", float(event.pressed))
			left_tracker.set_input("grip_click", event.pressed)
		else:
			right_tracker.set_input("grip", float(event.pressed))
			right_tracker.set_input("grip_click", event.pressed)

func simulate_buttons(event: InputEventKey, controller: XRController3D):
	if key_map.has(event.keycode):
		var button = key_map[event.keycode]
		if controller.tracker == "left_hand":
			left_tracker.set_input(button, event.pressed)
		else:
			right_tracker.set_input(button, event.pressed)

func move_controller(event: InputEventMouseMotion, controller: XRController3D):
	var movement = Vector3()
	movement += camera.global_transform.basis.x * event.relative.x * device_x_sensitivity/1000
	movement += camera.global_transform.basis.y * event.relative.y * -device_y_sensitivity/1000
	controller.global_translate(movement)
	
func attract_controller(event: InputEventMouseButton, controller: XRController3D):
	var direction = -1
	
	if not event.pressed:
		return
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		direction = 1
	elif event.button_index != MOUSE_BUTTON_WHEEL_DOWN:
		return
	
	var distance_vector = controller.global_transform.origin - camera.global_transform.origin
	var forward = distance_vector.normalized() * direction
	var movement = distance_vector + forward * (scroll_sensitivity/20)
	if distance_vector.length() > 0.1 and movement.length() > 0.1:
		controller.global_translate(forward * (scroll_sensitivity/20))

func rotate_device(event: InputEventMouseMotion, device: Node3D):
	var motion = event.relative
	device.rotate_y(motion.x * -device_x_sensitivity/1000)
	device.rotate(device.transform.basis.x, motion.y * -device_y_sensitivity/1000)
	
func vector_key_mapping(key_positive_x: int, key_negative_x: int, key_positive_y: int, key_negative_y: int):
	var x = 0
	var y = 0
	if Input.is_physical_key_pressed (key_positive_y):
		y = 1
	elif Input.is_physical_key_pressed (key_negative_y):
		y = -1
	
	if Input.is_physical_key_pressed (key_positive_x):
		x = 1
	elif Input.is_physical_key_pressed (key_negative_x):
		x = -1
	
	var vec = Vector2(x, y)
	
	if vec:
		vec = vec.normalized()
	
	return vec
