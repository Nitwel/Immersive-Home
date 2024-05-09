extends XRController3D

const Pointer = preload ("res://lib/utils/pointer/pointer.gd")
const Initiator = preload ("res://lib/utils/pointer/initiator.gd")
const Finger = preload ("res://lib/utils/touch/finger.gd")
const Touch = preload ("res://lib/utils/touch/touch.gd")
const Collide = preload ("res://lib/utils/touch/collide.gd")
const Miniature = preload ("res://content/system/house/mini/miniature.gd")

@onready var main = $"/root/Main"
@onready var hand = $hand_l
@onready var hand_mesh = $hand_l/Armature/Skeleton3D/mesh_Hand_L
@onready var auto_hand = $AutoHandtracker

@onready var index_tip = $IndexTip
@onready var thumb_tip = $ThumbTip
@onready var middle_tip = $MiddleTip

@onready var mini_view_button = $Palm/QuickActions/MiniView
@onready var temperature_button = $Palm/QuickActions/Temperature
@onready var humidity_button = $Palm/QuickActions/Humidity

@onready var palm = $Palm
@onready var ray: RayCast3D = $Raycast
@onready var quick_actions = $Palm/QuickActions

var hand_active = false
var initiator: Initiator = Initiator.new()
var collide: Collide
var pointer: Pointer
var press_distance = 0.02
var grip_distance = 0.02

var pressed = false
var grabbed = false

func _ready():

	_setup_hand()

func _process(_delta):
	if !hand_active:
		if quick_actions.is_inside_tree(): palm.remove_child(quick_actions)
		return

	if main.camera.global_transform.basis.z.dot(palm.global_transform.basis.x) > 0.85:
		if quick_actions.is_inside_tree() == false: palm.add_child(quick_actions)
	else:
		if quick_actions.is_inside_tree(): palm.remove_child(quick_actions)

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

func _setup_hand():
	TouchManager.add_finger(Finger.Type.INDEX_LEFT, $IndexTip/TouchArea)

	collide = Collide.new(hand, hand_mesh, index_tip)
	add_child(collide)

	auto_hand.hand_active_changed.connect(func(hand: int, active: bool):
		if hand != 0: return

		hand_active=active
			
		$IndexTip/TouchArea/CollisionShape3D.disabled=!active
		hand_mesh.visible=active
	)

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

	initiator.type = Initiator.Type.HAND_LEFT
	initiator.node = self

	pointer = Pointer.new(initiator, ray)
	add_child(pointer)
