extends Node3D
## Calculates collision for fingers and FingerAreas

const Finger = preload ("res://lib/utils/touch/finger.gd")
const TipCollider = preload ("res://content/system/hands/tip_collider.tscn")

var tip: Node3D
var tip_body: RigidBody3D
var hand: Node3D
var hand_mesh: Node3D

func _init(hand: Node3D, hand_mesh: Node3D, tip: Node3D):
	self.tip = tip
	self.hand = hand
	self.hand_mesh = hand_mesh

func _ready():
	var body_container = Node3D.new()
	body_container.name = "HandBodyContainer"
	body_container.top_level = true

	add_child(body_container)

	tip_body = TipCollider.instantiate()
	tip_body.global_position = tip.global_position
	body_container.add_child(tip_body)

func _physics_process(_delta):
		_move_tip_rigidbody_to_bone(tip_body, tip)

var last_run_active = false

func _move_tip_rigidbody_to_bone(tip_rigidbody: RigidBody3D, tip_bone: Node3D):
	if tip_rigidbody.is_inside_tree() == false:
		return

	if TouchManager.is_touching() == false:
		hand_mesh.position = Vector3.ZERO
		last_run_active = false
		return

	if last_run_active == false:
		tip_rigidbody.global_position = tip_bone.global_position

	var move_delta: Vector3 = tip_bone.global_position - tip_rigidbody.global_position

	hand_mesh.global_position = hand.global_position - move_delta

	# Snap back the rigidbody if it's too far away.
	if move_delta.length() > 0.1:
		tip_rigidbody.global_position = tip_bone.global_position
		return

	var coef_force = 30.0
	tip_rigidbody.apply_central_force(move_delta * coef_force)
	tip_rigidbody.global_transform.basis = hand.global_transform.basis

	last_run_active = true
