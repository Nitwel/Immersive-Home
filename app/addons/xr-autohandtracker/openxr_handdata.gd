extends Node

var autohandleft = null
var autohandright = null

func _ready():
	for autohand in get_tree().get_nodes_in_group("AutoHandGroup"):
		var tracker_name = autohand.get_parent().tracker
		if tracker_name == "left_hand":
			autohandleft = autohand
		elif tracker_name == "right_hand":
			autohandright = autohand
		else:
			print("unknown autohand ", autohand.tracker_name)
			print("Make sure this hand data node is above the autohand in the scene tree")
	set_process(autohandleft != null and autohandright != null)

	if false:
		await get_tree().create_timer(5).timeout
		print("****")
		print(var_to_str([autohandleft.oxrktrans, autohandright.oxrktrans]))
		print("****")	
	if true:
		await get_tree().create_timer(5).timeout
		print("**RADS**")
		print(var_to_str([autohandleft.oxrkradii, autohandright.oxrkradii]))
		print("****")	

# This pre-animated thing should correspond to a special kind of get_hand_tracking_source()
var Dautohandspinchtrans = null
var xpulloffset = -0.2  # actually the movement in y
func process_pinchpull_animation(delta):
	if xpulloffset < 0.1:
		xpulloffset += delta*0.06
	var xrightoffs = max(0, xpulloffset)
	for i in range(OpenXRInterface.HAND_JOINT_MAX):
		autohandleft.oxrktransRaw[i] = Transform3D(Dautohandspinchtrans[0][i].basis, Dautohandspinchtrans[0][i].origin + Vector3(0.0, 1.1, -0.2))
	autohandleft.oxrktransRaw_updated = true
	autohandleft.handtrackingvalid = true

#	autohandleft.oxrktransRaw[OpenXRInterface.HAND_JOINT_THUMB_TIP].origin += 0.001*Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	var Dtt = Vector3(0.05,-0.05,0)
	#autohandleft.oxrktransRaw[OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL].origin += Dtt
	#autohandleft.oxrktransRaw[OpenXRInterface.HAND_JOINT_LITTLE_INTERMEDIATE].origin += Dtt
#	autohandleft.oxrktransRaw[OpenXRInterface.HAND_JOINT_LITTLE_DISTAL].origin += Dtt
#	autohandleft.oxrktransRaw[OpenXRInterface.HAND_JOINT_LITTLE_TIP].origin += Dtt

	const rightxdisp = -0.01
	for i in range(OpenXRInterface.HAND_JOINT_MAX):
		autohandright.oxrktransRaw[i] = Transform3D(Dautohandspinchtrans[1][i].basis, Dautohandspinchtrans[1][i].origin + Vector3(rightxdisp + xrightoffs*0.1, 1.1 + xrightoffs*0.9, -0.18))
	if xpulloffset < -0.12 or xpulloffset > 0.12:
		autohandright.oxrktransRaw[OpenXRInterface.HAND_JOINT_THUMB_TIP].origin.z += 0.03
	autohandright.oxrktransRaw_updated = true
	autohandright.handtrackingvalid = true
		
func _process(delta):
	if Dautohandspinchtrans != null:
		process_pinchpull_animation(delta)
		#print("ll ", autohandleft.skel.get_bone_global_pose(autohandleft.fingerboneindexes[1]p[3]))
		#print("ll ", autohandleft.skel.get_bone_pose_scale(autohandleft.fingerboneindexes[1][2]), autohandleft.skel.get_bone_pose_scale(autohandleft.fingerboneindexes[1][3]))
		return

	if Input.is_action_just_pressed("debugfingermove"):
		print("hi")
		autohandleft.oxrktransRaw
		for i in range(OpenXRInterface.HAND_JOINT_MAX):
			autohandleft.oxrktransRaw[i] = Transform3D(Dautohandspinchtrans[0][i].basis, Dautohandspinchtrans[0][i].origin + Vector3(0.0, 1.1, -0.2))
		autohandleft.oxrktransRaw_updated = true
		autohandleft.handtrackingvalid = true

	autohandleft.process_handtrackingsource()
	autohandright.process_handtrackingsource()
	if autohandleft.handtrackingvalid:
		autohandleft.update_oxrktransRaw()
		autohandleft.oxrktransRaw_updated = true
	if autohandright.handtrackingvalid:
		autohandright.update_oxrktransRaw()
		autohandright.oxrktransRaw_updated = true

func _input(event):
	if event is InputEventKey and event.is_pressed and event.keycode == KEY_P:
		var file = FileAccess.open("res://data/handspinch.var", FileAccess.READ)
		Dautohandspinchtrans = str_to_var(file.get_as_text())
		xpulloffset = -0.2
		autohandleft.get_node("VisibleHandTrackSkeleton").visible = true
		autohandright.get_node("VisibleHandTrackSkeleton").visible = true
		autohandleft.handnode.top_level = true
		autohandright.handnode.top_level = true
