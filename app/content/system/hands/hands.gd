extends Node3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")
const Finger = preload ("res://lib/utils/touch/finger.gd")
const Touch = preload ("res://lib/utils/touch/touch.gd")
const Collide = preload ("res://lib/utils/touch/collide.gd")
const Miniature = preload ("res://content/system/house/mini/miniature.gd")

@onready var main = $"/root/Main"
@onready var palm = $XRHandLeft/Palm
@onready var quick_actions = $XRHandLeft/Palm/QuickActions
@onready var mini_view_button = $XRHandLeft/Palm/QuickActions/MiniView
@onready var temperature_button = $XRHandLeft/Palm/QuickActions/Temperature
@onready var humidity_button = $XRHandLeft/Palm/QuickActions/Humidity
@export var ray_left: RayCast3D
@export var ray_right: RayCast3D
@export var hand_left: Node3D
@export var hand_right: Node3D

@onready var bone_attachments_right = [$XRHandRight/IndexTip, $XRHandRight/ThumbTip, $XRHandRight/MiddleTip]
@onready var bone_attachments_left = [$XRHandLeft/IndexTip, $XRHandLeft/ThumbTip, $XRHandLeft/MiddleTip]

enum Fingers {INDEX, THUMB, MIDDLE}

var left_initiator: Initiator = Initiator.new()
var right_initiator: Initiator = Initiator.new()
var touch: Touch
var collide: Collide
var left_pointer: Pointer
var right_pointer: Pointer
var press_distance = 0.03
var grip_distance = 0.03

var pressed_left = false
var pressed_right = false
var grabbed_left = false
var grabbed_right = false

func _ready():
	var fingers = {
		Finger.Type.INDEX_RIGHT: $XRHandRight/IndexTip/TouchArea,
		Finger.Type.INDEX_LEFT: $XRHandLeft/IndexTip/TouchArea,
		Finger.Type.MIDDLE_RIGHT: $XRHandRight/MiddleTip/TouchArea,
		Finger.Type.MIDDLE_LEFT: $XRHandLeft/MiddleTip/TouchArea
	}

	touch = Touch.new(fingers)
	collide = Collide.new(hand_left, hand_right, $XRHandLeft/IndexTip/TouchArea, $XRHandRight/IndexTip/TouchArea)
	add_child(touch)
	add_child(collide)

	_ready_hand()

	mini_view_button.on_button_up.connect(func():
		House.body.mini_view.small.value=!House.body.mini_view.small.value
	)

	temperature_button.on_button_up.connect(func():
		if House.body.mini_view.heatmap_type.value == Miniature.HeatmapType.TEMPERATURE:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.NONE
		else:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.TEMPERATURE
	)

	humidity_button.on_button_up.connect(func():
		if House.body.mini_view.heatmap_type.value == Miniature.HeatmapType.HUMIDITY:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.NONE
		else:
			House.body.mini_view.heatmap_type.value=Miniature.HeatmapType.HUMIDITY
	)

func _ready_hand():
	left_initiator.type = Initiator.Type.HAND_LEFT
	left_initiator.node = ray_left.get_parent()

	left_pointer = Pointer.new(left_initiator, ray_left)
	add_child(left_pointer)

	right_initiator.type = Initiator.Type.HAND_RIGHT
	right_initiator.node = ray_right.get_parent()

	right_pointer = Pointer.new(right_initiator, ray_right)
	add_child(right_pointer)

func _process(_delta):
	if main.camera.global_transform.basis.z.dot(palm.global_transform.basis.y) > 0.85:
		if quick_actions.is_inside_tree() == false: palm.add_child(quick_actions)
	else:
		if quick_actions.is_inside_tree(): palm.remove_child(quick_actions)

func _physics_process(_delta):
	_process_hand_left(hand_left)
	_process_hand_right(hand_right)

func _process_hand_left(hand: Node3D):
	var index_tip = bone_attachments_left[Fingers.INDEX].get_node("Marker3D")
	var thumb_tip = bone_attachments_left[Fingers.THUMB].get_node("Marker3D")
	var middle_tip = bone_attachments_left[Fingers.MIDDLE].get_node("Marker3D")

	var _ray = ray_left if hand == hand_left else ray_right
	var initiator = left_initiator if hand == hand_left else right_initiator

	var distance_trigger = index_tip.global_position.distance_to(thumb_tip.global_position)
	var distance_grab = middle_tip.global_position.distance_to(thumb_tip.global_position)

	var trigger_close = distance_trigger <= press_distance
	var grab_close = distance_grab <= grip_distance

	if trigger_close&&!pressed_left:
		initiator.on_press.emit(Initiator.EventType.TRIGGER)
		pressed_left = true
	elif !trigger_close&&pressed_left:
		initiator.on_release.emit(Initiator.EventType.TRIGGER)
		pressed_left = false

	if grab_close&&!grabbed_left:
		initiator.on_press.emit(Initiator.EventType.GRIP)
		grabbed_left = true
	elif !grab_close&&grabbed_left:
		initiator.on_release.emit(Initiator.EventType.GRIP)
		grabbed_left = false

func _process_hand_right(hand: Node3D):
	var index_tip = bone_attachments_right[Fingers.INDEX].get_node("Marker3D")
	var thumb_tip = bone_attachments_right[Fingers.THUMB].get_node("Marker3D")
	var middle_tip = bone_attachments_right[Fingers.MIDDLE].get_node("Marker3D")

	var _ray = ray_left if hand == hand_left else ray_right
	var initiator = left_initiator if hand == hand_left else right_initiator

	var distance_trigger = index_tip.global_position.distance_to(thumb_tip.global_position)
	var distance_grab = middle_tip.global_position.distance_to(thumb_tip.global_position)

	var trigger_close = distance_trigger <= press_distance
	var grab_close = distance_grab <= grip_distance

	if trigger_close&&!pressed_right:
		initiator.on_press.emit(Initiator.EventType.TRIGGER)
		pressed_right = true
	elif !trigger_close&&pressed_right:
		initiator.on_release.emit(Initiator.EventType.TRIGGER)
		pressed_right = false

	if grab_close&&!grabbed_right:
		initiator.on_press.emit(Initiator.EventType.GRIP)
		grabbed_right = true
	elif !grab_close&&grabbed_right:
		initiator.on_release.emit(Initiator.EventType.GRIP)
		grabbed_right = false