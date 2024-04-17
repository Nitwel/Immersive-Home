extends Node3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")
const Finger = preload ("res://lib/utils/touch/finger.gd")
const Touch = preload ("res://lib/utils/touch/touch.gd")
const Collide = preload ("res://lib/utils/touch/collide.gd")
const Miniature = preload ("res://content/system/house/mini/miniature.gd")

@onready var main = $"/root/Main"
@onready var hand_right: OpenXRHand = $XRHandRight
@onready var hand_left: OpenXRHand = $XRHandLeft
@onready var palm = $XRHandLeft/Palm
@onready var quick_actions = $XRHandLeft/Palm/QuickActions
@onready var mini_view_button = $XRHandLeft/Palm/QuickActions/MiniView
@onready var temperature_button = $XRHandLeft/Palm/QuickActions/Temperature
@onready var humidity_button = $XRHandLeft/Palm/QuickActions/Humidity
@export var ray_left: RayCast3D
@export var ray_right: RayCast3D
var initiator: Initiator = Initiator.new()
var touch: Touch
var collide: Collide
var pointer: Pointer
var press_distance = 0.03
var grip_distance = 0.03
var close_distance = 0.1

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

	_ready_hand(hand_right)

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

func _ready_hand(hand: OpenXRHand):
	initiator.type = Initiator.Type.HAND_RIGHT if hand == hand_right else Initiator.Type.HAND_LEFT
	initiator.node = ray_left.get_parent() if hand == hand_left else ray_right.get_parent()

	pointer = Pointer.new(initiator, ray_left if hand == hand_left else ray_right)
	add_child(pointer)

func _process(_delta):
	if main.camera.global_transform.basis.z.dot(palm.global_transform.basis.y) > 0.85:
		if quick_actions.is_inside_tree() == false: palm.add_child(quick_actions)
	else:
		if quick_actions.is_inside_tree(): palm.remove_child(quick_actions)

func _physics_process(_delta):
	_process_hand(hand_left)
	_process_hand(hand_right)

func _process_hand(hand: OpenXRHand):
	var index_tip = hand.get_node("IndexTip/Marker3D")
	var thumb_tip = hand.get_node("ThumbTip/Marker3D")
	var middle_tip = hand.get_node("MiddleTip/Marker3D")

	var _ray = ray_left if hand == hand_left else ray_right

	var distance_trigger = index_tip.global_position.distance_to(thumb_tip.global_position)
	var distance_grab = middle_tip.global_position.distance_to(thumb_tip.global_position)

	var distance_target = _ray.get_collision_point().distance_to(_ray.global_position)

	var trigger_close = distance_trigger <= press_distance
	var grab_close = distance_grab <= grip_distance
	var distance_close = distance_target <= close_distance

	if hand == hand_left:
		
		if !distance_close:
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
		else:
			if trigger_close&&!grabbed_right:
				initiator.on_press.emit(Initiator.EventType.GRIP)
				grabbed_right = true
			elif !trigger_close&&grabbed_right:
				initiator.on_release.emit(Initiator.EventType.GRIP)
				grabbed_right = false
	else:
		if !distance_close:
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

		else:
			if trigger_close&&!grabbed_right:
				initiator.on_press.emit(Initiator.EventType.GRIP)
				grabbed_right = true
			elif !trigger_close&&grabbed_right:
				initiator.on_release.emit(Initiator.EventType.GRIP)
				grabbed_right = false