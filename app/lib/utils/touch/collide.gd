extends Node3D
## Calculates collision for fingers and FingerAreas

const Finger = preload ("res://lib/utils/touch/finger.gd")
const TipCollider = preload ("res://content/system/hands/tip_collider.tscn")

var tip_right: Node3D
var tip_left: Node3D

var tip_left_body: RigidBody3D
var tip_right_body: RigidBody3D

var hand_left: Node3D
var hand_right: Node3D
var hand_left_mesh: MeshInstance3D
var hand_right_mesh: MeshInstance3D

func _init(hand_left: OpenXRHand, hand_right: OpenXRHand, tip_left: Node3D, tip_right: Node3D):
	self.tip_right = tip_right
	self.tip_left = tip_left
	self.hand_left = hand_left
	self.hand_right = hand_right
	self.hand_left_mesh = hand_left.get_node("left_hand/Armature_001/Skeleton3D/vr_glove_left_slim")
	self.hand_right_mesh = hand_right.get_node("right_hand/Armature/Skeleton3D/vr_glove_right_slim")

func _ready():
	var body_container = Node3D.new()
	body_container.name = "HandBodyContainer"

	get_node("/root/Main/").add_child.call_deferred(body_container)

	tip_right_body = TipCollider.instantiate()
	tip_right_body.global_position = tip_right.global_position
	body_container.add_child(tip_right_body)

	tip_left_body = TipCollider.instantiate()
	tip_left_body.global_position = tip_left.global_position
	body_container.add_child(tip_left_body)

func _physics_process(_delta):
		_move_tip_rigidbody_to_bone(tip_left_body, tip_left)
		_move_tip_rigidbody_to_bone(tip_right_body, tip_right)

func _move_tip_rigidbody_to_bone(tip_rigidbody: RigidBody3D, tip_bone: Node3D):
	if tip_rigidbody.is_inside_tree() == false:
		return

	var move_delta: Vector3 = tip_bone.global_position - tip_rigidbody.global_position

	hand_right_mesh.global_position = hand_right.global_position - move_delta

	# Snap back the rigidbody if it's too far away.
	if move_delta.length() > 0.1:
		tip_rigidbody.global_position = tip_bone.global_position
		return

	var coef_force = 30.0
	tip_rigidbody.apply_central_force(move_delta * coef_force)
	tip_rigidbody.global_transform.basis = hand_right.global_transform.basis