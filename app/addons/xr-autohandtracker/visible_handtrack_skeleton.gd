extends Node3D



const hjsticks = [ [ OpenXRInterface.HAND_JOINT_WRIST, OpenXRInterface.HAND_JOINT_THUMB_METACARPAL, OpenXRInterface.HAND_JOINT_THUMB_PROXIMAL, OpenXRInterface.HAND_JOINT_THUMB_DISTAL, OpenXRInterface.HAND_JOINT_THUMB_TIP ],
				 [ OpenXRInterface.HAND_JOINT_WRIST, OpenXRInterface.HAND_JOINT_INDEX_METACARPAL, OpenXRInterface.HAND_JOINT_INDEX_PROXIMAL, OpenXRInterface.HAND_JOINT_INDEX_INTERMEDIATE, OpenXRInterface.HAND_JOINT_INDEX_DISTAL, OpenXRInterface.HAND_JOINT_INDEX_TIP ],
				 [ OpenXRInterface.HAND_JOINT_WRIST, OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL, OpenXRInterface.HAND_JOINT_MIDDLE_PROXIMAL, OpenXRInterface.HAND_JOINT_MIDDLE_INTERMEDIATE, OpenXRInterface.HAND_JOINT_MIDDLE_DISTAL, OpenXRInterface.HAND_JOINT_MIDDLE_TIP ],
				 [ OpenXRInterface.HAND_JOINT_WRIST, OpenXRInterface.HAND_JOINT_RING_METACARPAL, OpenXRInterface.HAND_JOINT_RING_PROXIMAL, OpenXRInterface.HAND_JOINT_RING_INTERMEDIATE, OpenXRInterface.HAND_JOINT_RING_DISTAL, OpenXRInterface.HAND_JOINT_RING_TIP ],
				 [ OpenXRInterface.HAND_JOINT_WRIST, OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL, OpenXRInterface.HAND_JOINT_LITTLE_PROXIMAL, OpenXRInterface.HAND_JOINT_LITTLE_INTERMEDIATE, OpenXRInterface.HAND_JOINT_LITTLE_DISTAL, OpenXRInterface.HAND_JOINT_LITTLE_TIP ]
			   ]

func _ready():
	var sticknode = $ExampleStick
	remove_child(sticknode)
	var jointnode = $ExampleJoint
	remove_child(jointnode)
	for j in range(OpenXRInterface.HAND_JOINT_MAX):
		var rj = jointnode.duplicate()
		rj.name = "J%d" % j
		rj.scale = Vector3(0.01, 0.01, 0.01)
		add_child(rj)

	for hjstick in hjsticks:
		for i in range(0, len(hjstick)-1):
			var rstick = sticknode.duplicate()
			var j1 = hjstick[i]
			var j2 = hjstick[i+1]
			rstick.name = "S%d_%d" % [j1, j2]
			rstick.scale = Vector3(0.01, 0.01, 0.01)
			add_child(rstick)
			#get_node("J%d" % hjstick[i+1]).get_node("Sphere").visible = (i > 0)


const knuckleradius = 0.01
func updatevisiblehandskeleton(oxrjps, oxrjrot, xrt):
	for j in range(OpenXRInterface.HAND_JOINT_MAX):
		get_node("J%d" % j).global_transform = Transform3D(xrt.basis*Basis(oxrjrot[j]).scaled(Vector3(knuckleradius, knuckleradius, knuckleradius)), xrt*oxrjps[j])

	for hjstick in hjsticks:
		for i in range(0, len(hjstick)-1):
			var j1 = hjstick[i]
			var j2 = hjstick[i+1]
			var rstick = get_node("S%d_%d" % [j1, j2])
			rstick.global_transform = sticktransformB(xrt*oxrjps[j1], xrt*oxrjps[j2])


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
