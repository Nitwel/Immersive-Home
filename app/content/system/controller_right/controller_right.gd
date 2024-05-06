extends XRController3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")
const Finger = preload ("res://lib/utils/touch/finger.gd")
const Touch = preload ("res://lib/utils/touch/touch.gd")
const Collide = preload ("res://lib/utils/touch/collide.gd")
const Miniature = preload ("res://content/system/house/mini/miniature.gd")

@onready var main = $"/root/Main"
@onready var ray: RayCast3D = $Raycast
@onready var hand: Node3D = $hand_r
@onready var hand_mesh = $hand_r/Armature/Skeleton3D/mesh_Hand_R

@onready var index_tip = $IndexTip
@onready var thumb_tip = $ThumbTip
@onready var middle_tip = $MiddleTip

var initiator: Initiator = Initiator.new()
var collide: Collide
var pointer: Pointer
var press_distance = 0.02
var grip_distance = 0.02

var pressed = false
var grabbed = false

func _ready():
	TouchManager.add_finger(Finger.Type.INDEX_RIGHT, $IndexTip/TouchArea)

	collide = Collide.new(hand, hand_mesh, index_tip)
	add_child(collide)

	initiator.type = Initiator.Type.HAND_RIGHT
	initiator.node = self

	pointer = Pointer.new(initiator, ray)
	add_child(pointer)

func _physics_process(_delta):
	var distance_trigger = index_tip.global_position.distance_to(thumb_tip.global_position)
	var distance_grab = middle_tip.global_position.distance_to(thumb_tip.global_position)

	var trigger_close = distance_trigger <= press_distance
	var grab_close = distance_grab <= grip_distance

	if trigger_close&&!pressed:
		initiator.on_press.emit(Initiator.EventType.TRIGGER)
		pressed = true
	elif !trigger_close&&pressed:
		initiator.on_release.emit(Initiator.EventType.TRIGGER)
		pressed = false

	if grab_close&&!grabbed:
		initiator.on_press.emit(Initiator.EventType.GRIP)
		grabbed = true
	elif !grab_close&&grabbed:
		initiator.on_release.emit(Initiator.EventType.GRIP)
		grabbed = false