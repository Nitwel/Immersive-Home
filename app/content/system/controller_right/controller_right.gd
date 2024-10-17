extends XRController3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")
const Finger = preload ("res://lib/utils/touch/finger.gd")
const Touch = preload ("res://lib/utils/touch/touch.gd")
const Collide = preload ("res://lib/utils/touch/collide.gd")
const Miniature = preload ("res://content/system/miniature/miniature.gd")

@onready var ray: RayCast3D = $Raycast
@onready var hand: Node3D = $hand_r
@onready var hand_mesh = $hand_r/Armature/Skeleton3D/mesh_Hand_R
@onready var auto_hand = $AutoHandtracker

@onready var index_tip = $IndexTip
@onready var thumb_tip = $ThumbTip
@onready var middle_tip = $MiddleTip

@export var show_grid = false:
	set(value):
		show_grid = value

		if ray != null:
			ray.with_grid = value

var hand_active = false:
	set(value):
		hand_active = value

		if pointer != null:
			pointer.set_physics_process(value)
var initiator: Initiator = Initiator.new()
var collide: Collide
var pointer: Pointer
var press_distance = 0.02
var grip_distance = 0.02

var pressed = false
var grabbed = false

func _ready():
	_setup_hand()

func _setup_hand():
	TouchManager.add_finger(Finger.Type.INDEX_RIGHT, $IndexTip/TouchArea)

	collide = Collide.new(hand, hand_mesh, index_tip.get_node("Marker3D"))
	add_child(collide)

	initiator.type = Initiator.Type.HAND_RIGHT
	initiator.node = self

	pointer = Pointer.new(initiator, ray)
	add_child(pointer)

	auto_hand.hand_active_changed.connect(func(hand: int, active: bool):
		if hand != 1: return
			
		hand_active=active&&_is_hand_simulated() == false

		$IndexTip/TouchArea/CollisionShape3D.disabled=!hand_active
		hand_mesh.visible=hand_active
	)

func _physics_process(_delta):
	if !hand_active: return

	var distance_trigger = index_tip.global_position.distance_to(thumb_tip.global_position)
	var distance_grab = middle_tip.global_position.distance_to(thumb_tip.global_position)

	var trigger_close = distance_trigger <= press_distance
	var grab_close = distance_grab <= grip_distance

	if trigger_close&&!pressed:
		pointer.pressed(Initiator.EventType.TRIGGER)
		pressed = true
	elif !trigger_close&&pressed:
		pointer.released(Initiator.EventType.TRIGGER)
		pressed = false

	if grab_close&&!grabbed:
		pointer.pressed(Initiator.EventType.GRIP)
		grabbed = true
	elif !grab_close&&grabbed:
		pointer.released(Initiator.EventType.GRIP)
		grabbed = false

func _is_hand_simulated():
	var hand_trackers = XRServer.get_trackers(XRServer.TRACKER_HAND)

	for tracker in hand_trackers.values():
		if tracker.hand != XRPositionalTracker.TrackerHand.TRACKER_HAND_RIGHT:
			continue

		return tracker.hand_tracking_source == XRHandTracker.HAND_TRACKING_SOURCE_CONTROLLER

	return false