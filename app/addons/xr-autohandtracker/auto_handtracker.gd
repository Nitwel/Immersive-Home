@tool
extends Node3D

# Settings that can be changed dynamically in the debugger to 
# see how they alter the mapping to the hand skeleton
@export var coincidemiddleknuckle : bool = true   # false means we match wristnode to wristnode
@export var visiblehandtrackskeleton : bool = true
@export var visiblehandtrackskeletonRaw : bool = false
@export var enableautotracker : bool = true
@export var controllersourcefingertracking : bool = true

# Local origin for the hand tracking positions
var xr_origin : XROrigin3D

signal hand_active_changed(hand: int, active: bool)

# Controller and its tracker with the aim pose that we can use when hand-tracking active
var islefthand = true
var xr_controller_node : XRController3D = null
var controllertracker_name : String 
var xr_controllertracker : XRPositionalTracker = null  # should be XRControllerTracker but for the use by the XRSimulator
var handtracker_name : String
var xr_handtracker : XRHandTracker = null

var handtrackingsource = OpenXRInterface.HAND_TRACKED_SOURCE_UNKNOWN

# readings from OpenXR interface that can be pre-calculated by OpenXRHandData
var handtrackingactive = false
var handtrackingvalid = false
var oxrktransRaw = [ ]
var oxrktrans = [ ]
var oxrktransRaw_updated = false
var oxrktrans_updated = false
var oxrkradii = [ ]

var handnode = null
var skel = null
var handanimationtree = null

# values calculated from the hand skeleton itself
var handtoskeltransform
var wristboneindex
var wristboneresttransform
var wristboneresthandtransform

var fingerboneindexes = [ ]
var fingerboneresttransforms = [ ]
var bYalignedAxes = false

func extractrestfingerbones():
	print(handnode.name)
	var lr = "L" if islefthand else "R"
	var lrN = "Left" if islefthand else "Right"
	handtoskeltransform = handnode.global_transform.inverse()*skel.global_transform
	wristboneindex = skel.find_bone("Wrist_" + lr)
	if wristboneindex == -1:
		wristboneindex = skel.find_bone(lrN + "Hand")
	wristboneresttransform = skel.get_bone_rest(wristboneindex)
	wristboneresthandtransform = handtoskeltransform * wristboneresttransform
	assert (len(fingerboneindexes) == 0 and len(fingerboneresttransforms) == 0)
	for f in ["Thumb", "Index", "Middle", "Ring", "Little"]:
		fingerboneindexes.push_back([ ])
		fingerboneresttransforms.push_back([ ])
		for b in ["Metacarpal", "Proximal", "Intermediate", "Distal", "Tip"]:
			var name = f + "_" + b + "_" + lr
			var nameN = lrN + f + b
			var ix = skel.find_bone(name)
			if ix == -1:
				ix = skel.find_bone(nameN)
			if ix != -1:
				fingerboneindexes[-1].push_back(ix)
				fingerboneresttransforms[-1].push_back(skel.get_bone_rest(ix))
			else:
				assert (f == "Thumb" and b == "Intermediate")

	bYalignedAxes = true
	for f in range(FINGERCOUNT):
		for i in range(len(fingerboneresttransforms[f])-1):
			var restvec = fingerboneresttransforms[f][i+1].origin
			if not is_zero_approx(restvec.x) or not is_zero_approx(restvec.z):
				bYalignedAxes = false
	print("bYalignedAxes ", bYalignedAxes)


func _xr_controller_node_tracking_changed(tracking):
	var xr_pose = xr_controller_node.get_pose()
	prints("_xr_controller_node_tracking_changed", tracking, xr_pose.name if xr_pose else "<none>")

func xrserver_tracker_added(tracker_name: StringName, type: int):
	if tracker_name == handtracker_name: 
		assert (type == XRServer.TRACKER_HAND)
		xr_handtracker = XRServer.get_tracker(handtracker_name)
	elif tracker_name == controllertracker_name: 
		assert (type == XRServer.TRACKER_CONTROLLER)
		xr_controllertracker = XRServer.get_tracker(controllertracker_name)
	

func xrserver_tracker_removed(tracker_name: StringName, type: int):
	if tracker_name == handtracker_name: 
		print("Invalidating hand tracker ", handtracker_name)
		assert (type == XRServer.TRACKER_HAND)
		xr_handtracker = null
	elif tracker_name == controllertracker_name: 
		print("Invalidating controller tracker ", controllertracker_name)
		assert (type == XRServer.TRACKER_CONTROLLER)
		xr_controllertracker = null

func findxrnodesandtrackers():
	if not (get_parent() is XRController3D):
		push_error("Autohand not a child of XRController3D")
		return false
	xr_controller_node = get_parent()
	controllertracker_name = xr_controller_node.tracker
	islefthand = (controllertracker_name == "left_hand")
	assert (controllertracker_name == ("left_hand" if islefthand else "right_hand"))
	if not (xr_controller_node.get_parent() is XROrigin3D):
		push_error("XRController3D not child of XROrigin3D")
		return false
	xr_origin = xr_controller_node.get_parent()
	xr_controller_node.tracking_changed.connect(_xr_controller_node_tracking_changed)

	for cch in xr_origin.get_children():
		if cch is XRCamera3D:
			$AutoTracker.xr_camera_node = cch

	xr_controllertracker = XRServer.get_tracker(controllertracker_name)
	assert ((xr_controllertracker == null) or (xr_controller_node.get_tracker_hand() == xr_controllertracker.hand))
	assert ((xr_controllertracker != null) or (xr_controller_node.get_tracker_hand() == XRPositionalTracker.TRACKER_HAND_UNKNOWN))

	handtracker_name = "/user/hand_tracker/left" if islefthand else "/user/hand_tracker/right"
	xr_handtracker = XRServer.get_tracker(handtracker_name)

	$AutoTracker.setupautotracker(xr_controller_node, islefthand)

	return true

func findhandnodes():
	for ch in xr_controller_node.get_children():
		var lskel = ch.find_child("Skeleton3D")
		if lskel and ch.visible:
			if lskel.get_bone_count() >= 25:
				handnode = ch
			else:
				print("unrecognized skeleton in controller ", lskel.get_bone_count())
	if handnode == null:
		print("Warning, no handnode (mesh and animationtree) detected")
		return false
	skel = handnode.find_child("Skeleton3D")
	if skel == null:
		print("Warning, no Skeleton3D found")
		return false
	handanimationtree = handnode.get_node_or_null("AnimationTree")
	extractrestfingerbones()


func _ready():
	XRServer.tracker_removed.connect(xrserver_tracker_removed)
	XRServer.tracker_added.connect(xrserver_tracker_added)
	
	for j in range(OpenXRInterface.HAND_JOINT_MAX):
		oxrktransRaw.push_back(Transform3D())
		oxrktrans.push_back(Transform3D())
		oxrkradii.push_back(0.0) 
	oxrktrans_updated = false
	if not ProjectSettings.get_setting("xr/openxr/extensions/hand_tracking"):
		print("Warning ProjectSettings: xr/openxr/extensions/hand_tracking is not enabled")
	if findxrnodesandtrackers():
		findhandnodes()
	
func update_oxrktransRaw():
	for j in range(OpenXRInterface.HAND_JOINT_MAX):
		oxrktransRaw[j] = xr_handtracker.get_hand_joint_transform(j)

func calchandnodetransform(oxrktrans):
	#  measured joints:
	var hjleftproximal = (OpenXRInterface.HAND_JOINT_RING_PROXIMAL if islefthand else OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL)
	var hjrightproximal = (OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL if islefthand else OpenXRInterface.HAND_JOINT_RING_PROXIMAL)
	var wristorigin = oxrktrans[OpenXRInterface.HAND_JOINT_WRIST].origin
	var middleknuckle = oxrktrans[OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL].origin
	var leftknuckle = oxrktrans[hjleftproximal].origin
	var rightknuckle = oxrktrans[hjrightproximal].origin

	# avatar relative bone positions
	var ileftfinger = (3 if islefthand else 1)
	var irightfinger = (1 if islefthand else 3)
	var middleknucklerestwristtransform = fingerboneresttransforms[2][0] * fingerboneresttransforms[2][1]
	var leftknucklerestwristtransform = fingerboneresttransforms[ileftfinger][0] * fingerboneresttransforms[ileftfinger][1]
	var rightknucklerestwristtransform = fingerboneresttransforms[irightfinger][0] * fingerboneresttransforms[irightfinger][1]

	# solving for handnodetransform
	# Let: 
	#     avatarwristtrans = handnodetransform * wristboneresthandtransform
	#     avatarmiddleknuckletransform = avatarwristtrans * middlerestreltransform
	# and align: avatarwristtrans.origin -> avatarmiddleknuckletransform.origin
	#      with: wristorigin -> middleknuckle
	# then rotate about this axis so that the plane between the wrist, left and right knuckles coincide
	var knucklevector = leftknucklerestwristtransform.origin - rightknucklerestwristtransform.origin
	var hnbasis = AutoHandFuncs.rotationtoalignB(
		wristboneresthandtransform.basis*middleknucklerestwristtransform.origin, middleknuckle - wristorigin, 
		wristboneresthandtransform.basis*knucklevector, leftknuckle - rightknuckle)

	# now decide if the origin is to align the wrist or the middle knuckle
	var hnorigin
	if coincidemiddleknuckle:
		hnorigin = middleknuckle - hnbasis*(wristboneresthandtransform*middleknucklerestwristtransform).origin 
	else:
		hnorigin = wristorigin - hnbasis*wristboneresthandtransform.origin
	return Transform3D(hnbasis, hnorigin)
	
		
const carpallist = [ OpenXRInterface.HAND_JOINT_THUMB_METACARPAL, 
					OpenXRInterface.HAND_JOINT_INDEX_METACARPAL, OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL, 
					OpenXRInterface.HAND_JOINT_RING_METACARPAL, OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL ]
const FINGERCOUNT = 5

func calcboneposesDisplaceOrigins(oxrktrans, handnodetransform):
	var fingerbonetransformsOut = fingerboneresttransforms.duplicate(true)
	for f in range(FINGERCOUNT):
		var mfg = handnodetransform * wristboneresthandtransform
		# (A.basis, A.origin) * (B.basis, B.origin) = (A.basis*B.basis, A.origin + A.basis*B.origin)
		
		for i in range(len(fingerboneresttransforms[f])-1):
			mfg = mfg*fingerboneresttransforms[f][i]
			# (tIbasis,atIorigin)*fingerboneresttransforms[f][i+1]).origin = mfg.inverse()*kpositions[f][i+1]
			# tIbasis*fingerboneresttransforms[f][i+1] = mfg.inverse()*kpositions[f][i+1] - atIorigin
			var atIorigin = Vector3(0,0,0)  
			var kpositionsfip1 = oxrktrans[carpallist[f] + i+1].origin
			var tIbasis = AutoHandFuncs.rotationtoalignUnScaled(fingerboneresttransforms[f][i+1].origin, mfg.affine_inverse()*kpositionsfip1 - atIorigin)
			var tIorigin = mfg.affine_inverse()*kpositionsfip1 - tIbasis*fingerboneresttransforms[f][i+1].origin # should be 0
			var tI = Transform3D(tIbasis, tIorigin)
			fingerbonetransformsOut[f][i] = fingerboneresttransforms[f][i]*tI
			mfg = mfg*tI
	return fingerbonetransformsOut


func copyouttransformstoskel(fingerbonetransformsOut):
	for f in range(len(fingerboneindexes)):
		for i in range(len(fingerboneindexes[f])):
			var ix = fingerboneindexes[f][i]
			var t = fingerbonetransformsOut[f][i]
			assert (ix >= 0 and ix < skel.get_bone_count())

			skel.set_bone_pose_rotation(ix, t.basis.get_rotation_quaternion())
			skel.set_bone_pose_position(ix, t.origin)
			#skel.set_bone_pose_scale(ix, t.basis.get_scale())
			
			# there will be a rant about not working!  skel.set_bone_pose(ix, t)
			# see https://github.com/godotengine/godot-proposals/issues/8869#issuecomment-2577587098
			
func process_handtrackingsource():
	if xr_handtracker == null:
		handtrackingactive = false
		handtrackingvalid = false
		return
			
	var lhandtrackingsource = xr_handtracker.hand_tracking_source
	if handtrackingsource != lhandtrackingsource:
		handtrackingsource = lhandtrackingsource
		handtrackingactive = (handtrackingsource == OpenXRInterface.HAND_TRACKED_SOURCE_UNOBSTRUCTED) or (controllersourcefingertracking and (handtrackingsource == OpenXRInterface.HAND_TRACKED_SOURCE_CONTROLLER))
		handnode.top_level = handtrackingactive

		# OpenXRInterface.HAND_TRACKING_SOURCE_NOT_TRACKED == 3
		if handanimationtree:
			handanimationtree.active = not handtrackingactive
		print("setting hand tracking source "+str(islefthand)+": ", handtrackingsource)
		hand_active_changed.emit(OpenXRInterface.Hand.HAND_LEFT if islefthand else OpenXRInterface.Hand.HAND_RIGHT, handtrackingactive)
		if handtrackingsource == OpenXRInterface.HAND_TRACKED_SOURCE_UNOBSTRUCTED:
			if enableautotracker:
				$AutoTracker.activateautotracker(xr_controller_node)
		else:
			if $AutoTracker.autotrackeractive:
				$AutoTracker.deactivateautotracker(xr_controller_node, xr_controllertracker)
			handnode.transform = Transform3D()

		for j in range(OpenXRInterface.HAND_JOINT_MAX):
			oxrkradii[j] = xr_handtracker.get_hand_joint_radius(j)

	handtrackingvalid = handtrackingactive and ((xr_handtracker.get_hand_joint_flags(XRHandTracker.HAND_JOINT_WRIST) & XRHandTracker.HAND_JOINT_FLAG_POSITION_VALID) != 0)
	$VisibleHandTrackSkeleton.visible = visiblehandtrackskeleton and handtrackingvalid
	
	
func _process(delta):
	if not oxrktransRaw_updated:
		process_handtrackingsource()
	if not handtrackingvalid:
		return
	if not oxrktrans_updated:
		if not oxrktransRaw_updated:
			update_oxrktransRaw()
			oxrktransRaw_updated = true
		for j in range(OpenXRInterface.HAND_JOINT_MAX):
			oxrktrans[j] = oxrktransRaw[j]
		oxrktransRaw_updated = false
		oxrktrans_updated = true

	var xrt = xr_origin.global_transform*XRServer.get_reference_frame()
	if $AutoTracker.autotrackeractive:
		$AutoTracker.autotrackgestures(oxrktrans, xrt)
	var handnodetransform = calchandnodetransform(oxrktrans)

	# much other function calls done here attempting to stretch in Y, which didn't work due to non-conformal bone problems that need to be reported
	# if bYalignedAxes:  fingerbonetransformsOut = calcboneposesScaledInYbadconformal(oxrktrans, handnodetransform)
	var fingerbonetransformsOut = calcboneposesDisplaceOrigins(oxrktrans, handnodetransform)
		
	handnode.transform = xrt*handnodetransform
	copyouttransformstoskel(fingerbonetransformsOut)
	
	if visible and $VisibleHandTrackSkeleton.visible:
		$VisibleHandTrackSkeleton.updatevisiblehandskeleton(oxrktransRaw if visiblehandtrackskeletonRaw else oxrktrans, xrt)

#	if xr_controllertracker != null:
#		var xr_aimpose = xr_controllertracker.get_pose("aim")
#		if xr_aimpose != null and $AutoTracker.autotrackeractive:
#			$AutoTracker.xr_autotracker.set_pose(xr_controller_node.pose, xr_aimpose.transform, xr_aimpose.linear_velocity, xr_aimpose.angular_velocity, xr_aimpose.tracking_confidence)
		
	oxrktrans_updated = false


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not (get_parent() is XRController3D):
		warnings.append("This node must be a child of an XRController3D node")
	return warnings
