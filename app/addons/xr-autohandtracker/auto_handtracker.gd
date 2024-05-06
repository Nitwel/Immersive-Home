extends Node3D

# Settings that can be changed dynamically in the debugger to 
# see how they alter the mapping to the hand skeleton
@export var applymiddlefingerfix : bool = true
@export var applyscaling : bool = true
@export var coincidewristorknuckle : bool = true
@export var visiblehandtrackskeleton : bool = true
@export var enableautotracker : bool = true

# Hand tracking data access object
var xr_interface : OpenXRInterface

# Local origin for the hand tracking positions
var xr_origin : XROrigin3D

# Controller and its tracker with the aim pose that we can use when hand-tracking active
var xr_controller_node : XRController3D = null
var tracker_nhand : XRPositionalTracker.TrackerHand = XRPositionalTracker.TrackerHand.TRACKER_HAND_UNKNOWN
var xr_tracker : XRPositionalTracker = null
var xr_aimpose : XRPose = null
var xr_headtracker : XRPositionalTracker = null
var xr_camera_node : XRCamera3D = null


# Note the that the enumerations disagree
# XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT = 1 
# OpenXRInterface.Hand.HAND_LEFT = 0
var hand : OpenXRInterface.Hand
var tracker_name : String 
var handtrackingactive = false

var handnode = null
var skel = null
var handanimationtree = null


# values calculated from the hand skeleton itself
var handtoskeltransform
var wristboneindex
var wristboneresttransform
var hstw
var fingerboneindexes
var fingerboneresttransforms

static func basisfromA(a, v):
	var vx = a.normalized()
	var vy = vx.cross(v.normalized())
	var vz = vx.cross(vy)
	return Basis(vx, vy, vz)

static func rotationtoalignB(a, b, va, vb):
	return basisfromA(b, vb)*basisfromA(a, va).inverse()

static func rotationtoalignScaled(a, b):
	var axis = a.cross(b).normalized()
	var sca = b.length()/a.length()
	if (axis.length_squared() != 0):
		var dot = a.dot(b)/(a.length()*b.length())
		dot = clamp(dot, -1.0, 1.0)
		var angle_rads = acos(dot)
		return Basis(axis, angle_rads).scaled(Vector3(sca,sca,sca))
	return Basis().scaled(Vector3(sca,sca,sca))


func extractrestfingerbones():
	print(handnode.name)
	var lr = "L" if hand == 0 else "R"
	handtoskeltransform = handnode.global_transform.inverse()*skel.global_transform
	wristboneindex = skel.find_bone("Wrist_" + lr)
	wristboneresttransform = skel.get_bone_rest(wristboneindex)
	hstw = handtoskeltransform * wristboneresttransform
	fingerboneindexes = [ ]
	fingerboneresttransforms = [ ]
	for f in ["Thumb", "Index", "Middle", "Ring", "Little"]:
		fingerboneindexes.push_back([ ])
		fingerboneresttransforms.push_back([ ])
		for b in ["Metacarpal", "Proximal", "Intermediate", "Distal", "Tip"]:
			var name = f + "_" + b + "_" + lr
			var ix = skel.find_bone(name)
			if ix != -1:
				fingerboneindexes[-1].push_back(ix)
				fingerboneresttransforms[-1].push_back(skel.get_bone_rest(ix) if ix != -1 else null)
			else:
				assert (f == "Thumb" and b == "Intermediate")

func _xr_controller_node_tracking_changed(tracking):
	var xr_pose = xr_controller_node.get_pose()
	print("_xr_controller_node_tracking_changed ", xr_pose.name if xr_pose else "<none>")


func findxrnodes():
	# first go up the tree to find the controller and origin
	var nd = self
	while nd != null and not (nd is XRController3D):
		nd = nd.get_parent()
	if nd == null:
		print("Warning, no controller node detected")
		return false
	xr_controller_node = nd
	tracker_nhand = xr_controller_node.get_tracker_hand()
	tracker_name = xr_controller_node.tracker
	xr_controller_node.tracking_changed.connect(_xr_controller_node_tracking_changed)
	while nd != null and not (nd is XROrigin3D):
		nd = nd.get_parent()
	if nd == null:
		print("Warning, no xrorigin node detected")
		return false
	xr_origin = nd

	# Then look for the hand skeleton that we are going to map to
	for cch in xr_origin.get_children():
		if cch is XRCamera3D:
			xr_camera_node = cch

	# Finally decide if it is left or right hand and test consistency in the API
	var islefthand = (tracker_name == "left_hand")
	assert (tracker_name == ("left_hand" if islefthand else "right_hand"))
	hand = OpenXRInterface.Hand.HAND_LEFT if islefthand else OpenXRInterface.Hand.HAND_RIGHT

	print("All nodes for %s detected" % tracker_name)
	return true

func findhandnodes():
	if xr_controller_node == null:
		return
	for ch in xr_controller_node.get_children():
		var lskel = ch.find_child("Skeleton3D")
		if lskel:
			if lskel.get_bone_count() == 26:
				handnode = ch
			else:
				print("unrecognized skeleton in controller")
	if handnode == null:
		print("Warning, no handnode (mesh and animationtree) detected")
		return false
	skel = handnode.find_child("Skeleton3D")
	if skel == null:
		print("Warning, no Skeleton3D found")
		return false
	handanimationtree = handnode.get_node_or_null("AnimationTree")
	extractrestfingerbones()
	
func findxrtrackerobjects():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface == null:
		return
	var tracker_name = xr_controller_node.tracker
	xr_tracker = XRServer.get_tracker(tracker_name)
	if xr_tracker == null:
		return
	assert (xr_tracker.hand == tracker_nhand)
	print(xr_tracker.description, " ", xr_tracker.hand, " ", xr_tracker.name, " ", xr_tracker.profile, " ", xr_tracker.type)

	xr_headtracker = XRServer.get_tracker("head")
	var islefthand = (tracker_name == "left_hand")
	assert (tracker_nhand == (XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT if islefthand else XRPositionalTracker.TrackerHand.TRACKER_HAND_RIGHT))
	print(tracker_name, "  ", tracker_nhand)

	print("action_sets: ", xr_interface.get_action_sets())
	$AutoTracker.setupautotracker(tracker_nhand, islefthand, xr_controller_node)


func _ready():
	findxrnodes()
	findxrtrackerobjects()

	# As a transform we are effectively reparenting ourselves directly under the XROrigin3D
	if xr_origin != null:
		var rt = RemoteTransform3D.new()
		rt.remote_path = get_path()
		xr_origin.add_child.call_deferred(rt)

	findhandnodes()
	set_process(xr_interface != null)
	

func getoxrjointpositions():
	var oxrjps = [ ]
	for j in range(OpenXRInterface.HAND_JOINT_MAX):
		oxrjps.push_back(xr_interface.get_hand_joint_position(hand, j))
	return oxrjps
	
func getoxrjointrotations():
	var oxrjrot = [ ]
	for j in range(OpenXRInterface.HAND_JOINT_MAX):
		oxrjrot.push_back(xr_interface.get_hand_joint_rotation(hand, j))
	return oxrjrot

func fixmiddlefingerpositions(oxrjps):
	for j in [ OpenXRInterface.HAND_JOINT_MIDDLE_TIP, OpenXRInterface.HAND_JOINT_RING_TIP ]:
		var b = Basis(xr_interface.get_hand_joint_rotation(hand, j))
		oxrjps[j] += -0.01*b.y + 0.005*b.z

func calchandnodetransform(oxrjps, xrt):
	# solve for handnodetransform where
	# avatarwristtrans = handnode.get_parent().global_transform * handnodetransform * handtoskeltransform * wristboneresttransform
	# avatarwristpos = avatarwristtrans.origin
	# avatarmiddleknucklepos = avatarwristtrans * fingerboneresttransforms[2][0] * fingerboneresttransforms[2][1]
	# handwrist = xrorigintransform * oxrjps[OpenXRInterface.HAND_JOINT_WRIST]
	# handmiddleknuckle = xrorigintransform * oxrjps[OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL]
	#  so that avatarwristpos->avatarmiddleknucklepos is aligned along handwrist->handmiddleknuckle
	#  and rotated so that the line between index and ring knuckles are in the same plane
	
	# We want skel.global_transform*wristboneresttransform to have origin xrorigintransform*gg[OpenXRInterface.HAND_JOINT_WRIST].origin
	var wristorigin = xrt*oxrjps[OpenXRInterface.HAND_JOINT_WRIST]

	var middleknuckle = xrt*oxrjps[OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL]
	var leftknuckle = xrt*oxrjps[OpenXRInterface.HAND_JOINT_RING_PROXIMAL if hand == 0 else OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL]
	var rightknuckle = xrt*oxrjps[OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL if hand == 0 else OpenXRInterface.HAND_JOINT_RING_PROXIMAL]

	var middlerestreltransform = fingerboneresttransforms[2][0] * fingerboneresttransforms[2][1]
	var leftrestreltransform = fingerboneresttransforms[3 if hand == 0 else 1][0] * fingerboneresttransforms[3 if hand == 0 else 1][1]
	var rightrestreltransform = fingerboneresttransforms[1 if hand == 0 else 3][0] * fingerboneresttransforms[1 if hand == 0 else 3][1]
	
	var m2g1 = middlerestreltransform
	var skelmiddleknuckle = handnode.transform * hstw * middlerestreltransform

	var m2g1g3 = leftrestreltransform.origin - rightrestreltransform.origin
	var hnbasis = rotationtoalignB(hstw.basis*m2g1.origin, middleknuckle - wristorigin, 
								   hstw.basis*m2g1g3, leftknuckle - rightknuckle)

	var hnorigin = wristorigin - hnbasis*hstw.origin
	if not coincidewristorknuckle:
		hnorigin = middleknuckle - hnbasis*(hstw*middlerestreltransform).origin

	return Transform3D(hnbasis, hnorigin)
		
const carpallist = [ OpenXRInterface.HAND_JOINT_THUMB_METACARPAL, 
	OpenXRInterface.HAND_JOINT_INDEX_METACARPAL, OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL, 
	OpenXRInterface.HAND_JOINT_RING_METACARPAL, OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL ]
func calcboneposes(oxrjps, handnodetransform, xrt):
	var fingerbonetransformsOut = fingerboneresttransforms.duplicate(true)
	for f in range(5):
		var mfg = handnodetransform * hstw
		# (A.basis, A.origin) * (B.basis, B.origin) = (A.basis*B.basis, A.origin + A.basis*B.origin)
		for i in range(len(fingerboneresttransforms[f])-1):
			mfg = mfg*fingerboneresttransforms[f][i]
			# (tIbasis,atIorigin)*fingerboneresttransforms[f][i+1]).origin = mfg.inverse()*kpositions[f][i+1]
			# tIbasis*fingerboneresttransforms[f][i+1] = mfg.inverse()*kpositions[f][i+1] - atIorigin
			var atIorigin = Vector3(0,0,0)  
			var kpositionsfip1 = xrt*oxrjps[carpallist[f] + i+1]
			var tIbasis = rotationtoalignScaled(fingerboneresttransforms[f][i+1].origin, mfg.affine_inverse()*kpositionsfip1 - atIorigin)
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
			skel.set_bone_pose_rotation(ix, t.basis.get_rotation_quaternion())
			if not applyscaling:
				t = fingerboneresttransforms[f][i]
			skel.set_bone_pose_position(ix, t.origin)
			skel.set_bone_pose_scale(ix, t.basis.get_scale())


func _process(delta):
	var handjointflagswrist = xr_interface.get_hand_joint_flags(hand, OpenXRInterface.HAND_JOINT_WRIST);
	var lhandtrackingactive = (handjointflagswrist & OpenXRInterface.HAND_JOINT_POSITION_VALID) != 0

	if handtrackingactive != lhandtrackingactive:
		handtrackingactive = lhandtrackingactive
		handnode.top_level = handtrackingactive
		if handanimationtree:
			handanimationtree.active = not handtrackingactive
		print("setting hand "+str(hand)+" active: ", handtrackingactive)
		$VisibleHandTrackSkeleton.visible = visiblehandtrackskeleton and handtrackingactive
		if handtrackingactive:
			if enableautotracker:
				$AutoTracker.activateautotracker(xr_controller_node)
		else:
			if $AutoTracker.autotrackeractive:
				$AutoTracker.deactivateautotracker(xr_controller_node, xr_tracker)
			handnode.transform = Transform3D()

	if handtrackingactive:
		var oxrjps = getoxrjointpositions()
		var xrt = xr_origin.global_transform
		if $AutoTracker.autotrackeractive:
			$AutoTracker.autotrackgestures(oxrjps, xrt, xr_camera_node)
		if applymiddlefingerfix:
			fixmiddlefingerpositions(oxrjps)
		var handnodetransform = calchandnodetransform(oxrjps, xrt)
		var fingerbonetransformsOut = calcboneposes(oxrjps, handnodetransform, xrt)
		handnode.transform = handnodetransform
		copyouttransformstoskel(fingerbonetransformsOut)
		if visible and $VisibleHandTrackSkeleton.visible:
			var oxrjrot = getoxrjointrotations()
			$VisibleHandTrackSkeleton.updatevisiblehandskeleton(oxrjps, oxrjrot, xrt)
		if xr_aimpose == null:
			xr_aimpose = xr_tracker.get_pose("aim")
			print("...xr_aimpose ", xr_aimpose)
		if xr_aimpose != null and $AutoTracker.autotrackeractive:
			$AutoTracker.xr_autotracker.set_pose(xr_controller_node.pose, xr_aimpose.transform, xr_aimpose.linear_velocity, xr_aimpose.angular_velocity, xr_aimpose.tracking_confidence)
		


