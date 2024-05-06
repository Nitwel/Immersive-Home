extends Node3D

# The autotracker is swapped onto the xr_controller_node when hand-tracking is active 
# so that we can insert in our own button and float signals from the hand gestures, 
# as well as setting the pose from the xr_aimpose (which is filtered by the system during hand tracking)
# Calling set_pose emits a pose_changed signal that copies its values into the xr_controller_node 
var xr_autotracker : XRPositionalTracker = null
var xr_autopose : XRPose = null
var autotrackeractive = false

var graspsqueezer = SqueezeButton.new()
var pinchsqueezer = SqueezeButton.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	$ThumbstickBoundaries/InnerRing.mesh.outer_radius = innerringrad
	$ThumbstickBoundaries/InnerRing.mesh.inner_radius = 0.95*innerringrad
	$ThumbstickBoundaries/OuterRing.mesh.outer_radius = outerringrad
	$ThumbstickBoundaries/OuterRing.mesh.inner_radius = 0.95*outerringrad
	$ThumbstickBoundaries/UpDisc.transform.origin.y = updowndistbutton
	$ThumbstickBoundaries/DownDisc.transform.origin.y = -updowndistbutton

func setupautotracker(tracker_nhand, islefthand, xr_controller_node):
	xr_autotracker = XRPositionalTracker.new()
	xr_autotracker.hand = tracker_nhand
	xr_autotracker.name = "left_autohand" if islefthand else "right_autohand"
	xr_autotracker.profile = "/interaction_profiles/autohand" # "/interaction_profiles/none"
	xr_autotracker.type = 2

	xr_autotracker.set_pose(xr_controller_node.pose, Transform3D(), Vector3(), Vector3(), XRPose.TrackingConfidence.XR_TRACKING_CONFIDENCE_NONE)
	xr_autopose = xr_autotracker.get_pose(xr_controller_node.pose)

	graspsqueezer.setinputstrings(xr_autotracker, "grip", "", "grip_click")
	pinchsqueezer.setinputstrings(xr_autotracker, "trigger", "trigger_touch", "trigger_click")
	
	XRServer.add_tracker(xr_autotracker)

func activateautotracker(xr_controller_node):
	xr_controller_node.set_tracker(xr_autotracker.name)
	autotrackeractive = true
	
func deactivateautotracker(xr_controller_node, xr_tracker):
	setaxbybuttonstatus(0)
	graspsqueezer.applysqueeze(graspsqueezer.touchbuttondistance + 1)	
	pinchsqueezer.applysqueeze(pinchsqueezer.touchbuttondistance + 1)	
	xr_controller_node.set_tracker(xr_tracker.name)
	autotrackeractive = false

func autotrackgestures(oxrjps, xrt, xr_camera_node):
	thumbsticksimulation(oxrjps, xrt, xr_camera_node)

	# detect forming a fist
	var middleknuckletip = (oxrjps[OpenXRInterface.HAND_JOINT_MIDDLE_TIP] - oxrjps[OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL]).length()
	var ringknuckletip = (oxrjps[OpenXRInterface.HAND_JOINT_RING_TIP] - oxrjps[OpenXRInterface.HAND_JOINT_RING_PROXIMAL]).length()
	var littleknuckletip = (oxrjps[OpenXRInterface.HAND_JOINT_LITTLE_TIP] - oxrjps[OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL]).length()
	var avgknuckletip = (middleknuckletip + ringknuckletip + littleknuckletip)/3
	graspsqueezer.applysqueeze(avgknuckletip)

	# detect the finger pinch
	var pinchdist = (oxrjps[OpenXRInterface.HAND_JOINT_INDEX_TIP] - oxrjps[OpenXRInterface.HAND_JOINT_THUMB_TIP]).length()
	pinchsqueezer.applysqueeze(pinchdist*2)

	#$GraspMarker.global_transform.origin = xrt*oxrjps[OpenXRInterface.HAND_JOINT_MIDDLE_TIP] 
	#$GraspMarker.visible = buttoncurrentlyclicked
	
	
	
var thumbstickstartpt = null
const thumbdistancecontact = 0.025
const thumbdistancerelease = 0.045
const innerringrad = 0.05
const outerringrad = 0.22
const updowndisttouch = 0.08
const updowndistbutton = 0.12
var thumbsticktouched = false
var axbybuttonstatus = 0 # -2:by_button, -1:by_touch, 1:ax_touch, 1:ax_button
var by_is_up = true

	
func setaxbybuttonstatus(newaxbybuttonstatus):
	if axbybuttonstatus == newaxbybuttonstatus:
		return
	if abs(axbybuttonstatus) == 2:
		xr_autotracker.set_input("ax_button" if axbybuttonstatus > 0 else "by_button", false)
		axbybuttonstatus = 1 if axbybuttonstatus > 0 else -1
	if axbybuttonstatus == newaxbybuttonstatus:
		return
	xr_autotracker.set_input("ax_touch" if axbybuttonstatus > 0 else "by_touch", false)
	axbybuttonstatus = 0
	if axbybuttonstatus == newaxbybuttonstatus:
		return
	xr_autotracker.set_input("ax_touch" if newaxbybuttonstatus > 0 else "by_touch", true)
	axbybuttonstatus = 1 if newaxbybuttonstatus > 0 else -1
	if axbybuttonstatus == newaxbybuttonstatus:
		return
	xr_autotracker.set_input("ax_button" if newaxbybuttonstatus > 0 else "by_button", true)
	axbybuttonstatus = newaxbybuttonstatus

func thumbsticksimulation(oxrjps, xrt, xr_camera_node):
	var middletip = oxrjps[OpenXRInterface.HAND_JOINT_MIDDLE_TIP]
	var thumbtip = oxrjps[OpenXRInterface.HAND_JOINT_THUMB_TIP]
	var ringtip = oxrjps[OpenXRInterface.HAND_JOINT_RING_TIP]
	var tipcen = (middletip + thumbtip + ringtip)/3.0
	var middleknuckle = oxrjps[OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL]
	var thumbdistance = max((middletip - tipcen).length(), (thumbtip - tipcen).length(), (ringtip - tipcen).length())
	if thumbstickstartpt == null:
		if thumbdistance < thumbdistancecontact and middleknuckle.y < tipcen.y - 0.029:
			thumbstickstartpt = tipcen
			visible = true
			global_transform.origin = xrt*tipcen
			$ThumbstickBoundaries.global_transform.origin = xrt*thumbstickstartpt
	else:
		if thumbdistance > thumbdistancerelease:
			thumbstickstartpt = null
			if thumbsticktouched:
				xr_autotracker.set_input("primary", Vector2(0.0, 0.0))
				xr_autotracker.set_input("primary_touch", true)
				thumbsticktouched = false
			setaxbybuttonstatus(0)

	visible = (thumbstickstartpt != null)
	if thumbstickstartpt != null:
		$DragRod.global_transform = sticktransformB(xrt*thumbstickstartpt, xrt*tipcen)
		var facingangle = Vector2(xr_camera_node.transform.basis.z.x, xr_camera_node.transform.basis.z.z).angle() if xr_camera_node != null else 0.0
		var hvec = Vector2(tipcen.x - thumbstickstartpt.x, tipcen.z - thumbstickstartpt.z)
		var hv = hvec.rotated(deg_to_rad(90) - facingangle)
		var hvlen = hv.length()
		if not thumbsticktouched:
			var frat = hvlen/max(hvlen, innerringrad)
			frat = frat*frat*frat 
			$ThumbstickBoundaries/InnerRing.get_surface_override_material(0).albedo_color.a = frat
			$ThumbstickBoundaries/OuterRing.get_surface_override_material(0).albedo_color.a = frat
			if hvlen > innerringrad:
				xr_autotracker.set_input("primary_touch", true)
				thumbsticktouched = true
			
		if thumbsticktouched:
			var hvN = hv/max(hvlen, outerringrad)
			xr_autotracker.set_input("primary", Vector2(hvN.x, -hvN.y))

		var ydist = (tipcen.y - thumbstickstartpt.y)
		var rawnewaxbybuttonstatus = 0
		if ydist > updowndisttouch:
			$ThumbstickBoundaries/UpDisc.visible = true
			$ThumbstickBoundaries/UpDisc.get_surface_override_material(0).albedo_color.a = (ydist - updowndisttouch)/(updowndistbutton - updowndisttouch)*0.5 if ydist < updowndistbutton else 1.0
			rawnewaxbybuttonstatus = 2 if ydist > updowndistbutton else 1
		else:
			$ThumbstickBoundaries/UpDisc.visible = false
		if ydist < -updowndisttouch:
			$ThumbstickBoundaries/DownDisc.visible = true
			$ThumbstickBoundaries/DownDisc.get_surface_override_material(0).albedo_color.a = (-ydist - updowndisttouch)/(updowndistbutton - updowndisttouch)*0.5 if -ydist < updowndistbutton else 1.0
			rawnewaxbybuttonstatus = -2 if -ydist > updowndistbutton else -1
		else:
			$ThumbstickBoundaries/DownDisc.visible = false
		setaxbybuttonstatus(rawnewaxbybuttonstatus*(1 if by_is_up else -1))


class SqueezeButton:
	const touchbuttondistance = 0.07
	const depressbuttondistance = 0.04
	const clickbuttononratio = 0.6
	const clickbuttonoffratio = 0.4

	var xr_autotracker = null
	var squeezestring = ""
	var touchstring = ""
	var clickstring = ""
	
	var buttoncurrentlyclicked = false
	var buttoncurrentlytouched = false

	func setinputstrings(lxr_autotracker, lsqueezestring, ltouchstring, lclickstring):
		xr_autotracker = lxr_autotracker
		squeezestring = lsqueezestring
		touchstring = ltouchstring
		clickstring = lclickstring

	func xrsetinput(name, value):
		if xr_autotracker and name:
			xr_autotracker.set_input(name, value)

	func applysqueeze(squeezedistance):
		var buttonratio = min(inverse_lerp(touchbuttondistance, depressbuttondistance, squeezedistance), 1.0)
		if buttonratio < 0.0:
			if buttoncurrentlytouched:
				xrsetinput(squeezestring, 0.0)
				xrsetinput(touchstring, false)
				buttoncurrentlytouched = false
		else:
			xrsetinput(squeezestring, buttonratio)
			if not buttoncurrentlytouched:
				xrsetinput(touchstring, true)
				buttoncurrentlytouched = true
		var buttonclicked = (buttonratio > (clickbuttonoffratio if buttoncurrentlyclicked else clickbuttononratio))
		if buttonclicked != buttoncurrentlyclicked:
			xrsetinput(clickstring, buttonclicked)
			buttoncurrentlyclicked = buttonclicked


const stickradius = 0.01
static func sticktransformB(j1, j2):
	var v = j2 - j1
	var vlen = v.length()
	var b
	if vlen != 0:
		var vy = v/vlen
		var vyunaligned = Vector3(0,1,0) if abs(vy.y) < abs(vy.x) + abs(vy.z) else Vector3(1,0,0)
		var vz = vy.cross(vyunaligned)
		var vx = vy.cross(vz)
		b = Basis(vx*stickradius, v, vz*stickradius)
	else:
		b = Basis().scaled(Vector3(0.01, 0.0, 0.01))
	return Transform3D(b, (j1 + j2)*0.5)
	
