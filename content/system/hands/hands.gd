extends Node3D

const Pointer = preload("res://lib/utils/pointer/pointer.gd")
const Initiator = preload("res://lib/utils/pointer/initiator.gd")

@onready var hand_right: OpenXRHand = $XRHandRight
@onready var hand_left: OpenXRHand = $XRHandLeft
@export var ray_left: RayCast3D
@export var ray_right: RayCast3D
var initiator: Initiator = Initiator.new()
var pointer: Pointer
var press_distance = 0.03
var grip_distance = 0.05

var pressed_left = false
var pressed_right = false
var grabbed_left = false
var grabbed_right = false

func _ready():
	_ready_hand(hand_right)

func _ready_hand(hand: OpenXRHand):
	initiator.type = Initiator.Type.HAND_RIGHT if hand == hand_right else Initiator.Type.HAND_LEFT
	initiator.node = ray_left.get_parent() if hand == hand_left else ray_right.get_parent()

	pointer = Pointer.new(initiator, ray_left if hand == hand_left else ray_right)
	add_child(pointer)

func _process(_delta):
	_process_hand(hand_right)

func _process_hand(hand: OpenXRHand):
	var index_tip = hand.get_node("IndexTip/Marker3D")
	var thumb_tip = hand.get_node("ThumbTip/Marker3D")
	var middle_tip = hand.get_node("MiddleTip/Marker3D")

	var _ray = ray_left if hand == hand_left else ray_right

	var distance_trigger = index_tip.global_position.distance_to(thumb_tip.global_position)
	var distance_grab = middle_tip.global_position.distance_to(thumb_tip.global_position)

	if hand == hand_left:
		if distance_trigger <= press_distance && !pressed_left:
			initiator.on_press.emit(Initiator.EventType.TRIGGER)
			pressed_left = true
		elif distance_trigger > press_distance && pressed_left:
			initiator.on_release.emit(Initiator.EventType.TRIGGER)
			pressed_left = false

		if distance_grab <= grip_distance && !grabbed_left:
			initiator.on_press.emit(Initiator.EventType.GRIP)
			grabbed_left = true
		elif distance_grab > grip_distance && grabbed_left:
			initiator.on_release.emit(Initiator.EventType.GRIP)
			grabbed_left = false
	else:
		if distance_trigger <= press_distance && !pressed_right:
			initiator.on_press.emit(Initiator.EventType.TRIGGER)
			pressed_right = true
		elif distance_trigger > press_distance && pressed_right:
			initiator.on_release.emit(Initiator.EventType.TRIGGER)
			pressed_right = false

		if distance_grab <= grip_distance && !grabbed_right:
			initiator.on_press.emit(Initiator.EventType.GRIP)
			grabbed_right = true
		elif distance_grab > grip_distance && grabbed_right:
			initiator.on_release.emit(Initiator.EventType.GRIP)
			grabbed_right = false
