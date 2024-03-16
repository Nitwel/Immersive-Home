extends Node3D
## Calculates collision for fingers and FingerAreas

const Finger = preload ("res://lib/utils/touch/finger.gd")

## Record<Finger.Type, Area3D>
var finger_areas: Dictionary

## Record<TouchBody3D, Array<Finger.Type>>
var bodies_entered = {}
var hand_left: Node3D
var hand_right: Node3D

func _init(hand_left: OpenXRHand, hand_right: OpenXRHand, finger_areas: Dictionary):
	self.finger_areas = finger_areas
	self.hand_left = hand_left.get_node("left_hand/Armature_001/Skeleton3D/vr_glove_left_slim")
	self.hand_right = hand_right.get_node("right_hand/Armature/Skeleton3D/vr_glove_right_slim")

func _ready():
	for finger_type in finger_areas.keys():

		finger_areas[finger_type].area_entered.connect(func(body):
			if body is TouchBody3D:
				_on_body_entered(finger_type, body)
		)

		finger_areas[finger_type].area_exited.connect(func(body):
			if body is TouchBody3D:
				_on_body_exited(finger_type, body)
		)

func _physics_process(_delta):
	hand_left.position = Vector3.ZERO
	hand_right.position = Vector3.ZERO

	for body in bodies_entered.keys():
		var fingers = bodies_entered[body]

		for finger in fingers:
			if finger == Finger.Type.INDEX_LEFT:
				var start_pos = finger_areas[finger].get_parent().global_position
				var end_pos = body.to_global(body.plane.project(body.to_local(start_pos)))

				hand_left.global_position = end_pos + (hand_left.global_position - start_pos)

			elif finger == Finger.Type.INDEX_RIGHT:
				var start_pos = finger_areas[finger].get_parent().global_position
				var end_pos = body.to_global(body.plane.project(body.to_local(start_pos)))

				hand_right.global_position = end_pos + (hand_right.global_position - start_pos)

func _on_body_entered(finger_type, body):
	if bodies_entered.has(body):
		if !bodies_entered[body].has(finger_type):
			bodies_entered[body].append(finger_type)
	else:
		bodies_entered[body] = [finger_type]

func _on_body_exited(finger_type, body):
	if bodies_entered.has(body):
		if bodies_entered[body].has(finger_type):
			bodies_entered[body].erase(finger_type)

		if bodies_entered[body].size() == 0:
			bodies_entered.erase(body)