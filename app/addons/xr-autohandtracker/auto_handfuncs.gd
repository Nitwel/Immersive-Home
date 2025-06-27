class_name AutoHandFuncs

const carpallist = [ OpenXRInterface.HAND_JOINT_THUMB_METACARPAL, 
					OpenXRInterface.HAND_JOINT_INDEX_METACARPAL, OpenXRInterface.HAND_JOINT_MIDDLE_METACARPAL, 
					OpenXRInterface.HAND_JOINT_RING_METACARPAL, OpenXRInterface.HAND_JOINT_LITTLE_METACARPAL ]
const FINGERCOUNT = 5

static func basisfromA(a, v):
	var vx = a.normalized()
	var vy = vx.cross(v.normalized())
	var vz = vx.cross(vy)
	return Basis(vx, vy, vz)

static func rotationtoalignB(a, b, va, vb):
	return basisfromA(b, vb)*basisfromA(a, va).inverse()

static func rotationtoalignUnScaled(a, b):
	#assert (is_zero_approx(a.x) and is_zero_approx(a.z))
	var axis = a.cross(b).normalized()
	var rot = Basis()
	if (axis.length_squared() != 0):
		var dot = a.dot(b)/(a.length()*b.length())
		dot = clamp(dot, -1.0, 1.0)
		var angle_rads = acos(dot)
		rot = Basis(axis, angle_rads)
	return rot

static func rotationtoalignScaled(a, b):
	var axis = a.cross(b).normalized()
	var sca = b.length()/a.length()
	if (axis.length_squared() != 0):
		var dot = a.dot(b)/(a.length()*b.length())
		dot = clamp(dot, -1.0, 1.0)
		var angle_rads = acos(dot)
		return Basis(axis, angle_rads).scaled(Vector3(sca,sca,sca))
	return Basis().scaled(Vector3(sca,sca,sca))


# Saved functions
"""
func calcboneposes(oxrktrans, handnodetransform, xrt):
	var fingerbonetransformsOut = fingerboneresttransforms.duplicate(true)
	for f in range(FINGERCOUNT):
		var mfg = handnodetransform * wristboneresthandtransform
		# (A.basis, A.origin) * (B.basis, B.origin) = (A.basis*B.basis, A.origin + A.basis*B.origin)
		
		for i in range(len(fingerboneresttransforms[f])-1):
			mfg = mfg*fingerboneresttransforms[f][i]
			# (tIbasis,atIorigin)*fingerboneresttransforms[f][i+1]).origin = mfg.inverse()*kpositions[f][i+1]
			# tIbasis*fingerboneresttransforms[f][i+1] = mfg.inverse()*kpositions[f][i+1] - atIorigin
			var atIorigin = Vector3(0,0,0)  
			var kpositionsfip1 = xrt*oxrktrans[carpallist[f] + i+1].origin
			var tIbasis = AutoHandFuncs.rotationtoalignScaled(fingerboneresttransforms[f][i+1].origin, mfg.affine_inverse()*kpositionsfip1 - atIorigin)
			var tIorigin = mfg.affine_inverse()*kpositionsfip1 - tIbasis*fingerboneresttransforms[f][i+1].origin # should be 0
			assert (tIorigin.is_zero_approx())
			var tI = Transform3D(tIbasis, tIorigin)
			fingerbonetransformsOut[f][i] = fingerboneresttransforms[f][i]*tI
			mfg = mfg*tI
	return fingerbonetransformsOut



# (A.basis, A.origin) * (B.basis, B.origin) = (A.basis*B.basis, A.origin + A.basis*B.origin)
# https://github.com/godotengine/godot/issues/99330
func calcboneposesScaledInYbadconformal(oxrktrans, handnodetransform, xrt):
	var fingerbonetransformsOut = fingerboneresttransforms.duplicate(true)
	for f in range(FINGERCOUNT):
		var mfg = handnodetransform * wristboneresthandtransform
		#print(mfg.basis.get_scale())
		for i in range(len(fingerboneresttransforms[f])-1):
			var kpositionsfip0 = xrt*oxrktrans[carpallist[f] + i].origin
			var bonerestvec0 = fingerboneresttransforms[f][i].origin
			var kpos0 = mfg*bonerestvec0 # the spot we are at
			#var kpos0 = mfg.origin + mfg.basis*bonerestvec0 # the spot we are at
			# if i != 0 then kpos0 = kpositionsfip0
			var kpositionsfip1 = xrt*oxrktrans[carpallist[f] + i+1].origin # the spot we want to go to
			var bonerestvec1 = fingerboneresttransforms[f][i+1].origin # (0,ly,0)
			assert (is_zero_approx(bonerestvec1.x) and is_zero_approx(bonerestvec1.z))
			var bonetargetvec1 = kpositionsfip1 - kpos0
			var bonetargetvec1len = bonetargetvec1.length()
				
			# given mfg1 = mfg*F, F = fingerbonetransformsOut[f][i], Fr = fingerboneresttransforms[f][i]
			# require F.origin = Fr.origin, kpositionsfip1 = mfg1*bonerestvec1
			#   and F.basis = rot*scale
			
			# kpositionsfip1 = mfg1*bonerestvec1 = mfg1.origin + mfg1.basis*bonerestvec1
			# mfg1.origin = mfg.origin + mfg.basis*F.origin = kpos0
			# mfg1.basis = mfg.basis*F.basis
			# kpositionsfip1 - mfg1.origin = mfg1.basis*bonerestvec1
			# bonetargetvec1 = kpositionsfip1 - kpos0 = mfg.basis*F.basis*bonerestvec1
			# F.basis*bonerestvec1 = mfg.basis.inverse()*bonetargetvec1
			var fbv = mfg.basis.inverse()*bonetargetvec1
			var rot = AutoHandFuncs.rotationtoalignUnScaled(bonerestvec1, fbv)
			
			var mfgR = mfg.basis*rot
			# bonetargetvec1 = mfg.basis*rot*sca*bonerestvec1
			var scay = fbv.length()/bonerestvec1.length()
			var sca = Vector3(1, scay, 1)
#			prints("n", bonetargetvec1.length(), (mfgR.y*bonerestvec1.y*scay).length())
			#prints("r", (mfgR.x).length())
			
			var F = Transform3D(rot*Basis.from_scale(sca), fingerboneresttransforms[f][i].origin)
			#print("mm ", mfg.basis*F.basis*bonerestvec1 - bonetargetvec1)
			fingerbonetransformsOut[f][i] = F
			var mfg1 = mfg*F
			#prints(i, mfg1.basis.get_scale())
			assert ((fingerbonetransformsOut[f][i].origin - fingerboneresttransforms[f][i].origin).is_zero_approx())

			mfg = mfg1  # mfg*fingerbonetransformsOut[f][i]
			
	return fingerbonetransformsOut

# (A.basis, A.origin) * (B.basis, B.origin) = (A.basis*B.basis, A.origin + A.basis*B.origin)
# https://github.com/godotengine/godot/issues/99330
func calcboneposesScaledInY(oxrktrans, handnodetransform, xrt):
	var fingerbonetransformsOut = fingerboneresttransforms.duplicate(true)
	for f in range(FINGERCOUNT):
		var mfg = handnodetransform * wristboneresthandtransform
		#print(mfg.basis.get_scale())
		var prevscale = 1.0
		for i in range(len(fingerboneresttransforms[f])-1):
			var kpositionsfip0 = xrt*oxrktrans[carpallist[f] + i].origin
			var bonerestvec0 = fingerboneresttransforms[f][i].origin
			var kpos0 = mfg*bonerestvec0 # the spot we are at
			#var kpos0 = mfg.origin + mfg.basis*bonerestvec0 # the spot we are at
			# if i != 0 then kpos0 = kpositionsfip0
			var kpositionsfip1 = xrt*oxrktrans[carpallist[f] + i+1].origin # the spot we want to go to
			var bonerestvec1 = fingerboneresttransforms[f][i+1].origin # (0,ly,0)
			assert (is_zero_approx(bonerestvec1.x) and is_zero_approx(bonerestvec1.z))
			var bonetargetvec1 = kpositionsfip1 - kpos0
			var bonetargetvec1len = bonetargetvec1.length()
			var sca = bonetargetvec1len/bonerestvec1.length()
				
			# we need to find mfg1 (transform for the next bone) such that 
			# kpositionsfip1 = mfg1*bonerestvec1 = mfg1.origin + mfg1.basis*bonerestvec1
			# and mfg1.basis = rot*Basis(1,sca,1)
			# and mfg1 = mfg*fingerbonetransformsOut[f][i]
			# where fingerbonetransformsOut[f][i] = (b, bonerestvec0)
			# so mfg1.basis = mfg.basis*b
			# and mfg1.origin = mfg.origin + mfg.basis*bonerestvec0
			# therefore kpositionsfip1 = mfg.origin + mfg.basis*bonerestvec0 + mfg1.basis*bonerestvec1
			# so mfg1.basicalcboneposesScaledInYs*bonerestvec1 = kpositionsfip1 - mfg.origin - mfg.basis*bonerestvec0
			# so mfg1.basis*bonerestvec1 = kpositionsfip1 - kpos0
			var ktarg = bonetargetvec1.normalized()
			#var Drot = rotationtoalignUnScaled(bonerestvec1, bonetargetvec1)
			
			var mfgrest1basis = mfg.basis*fingerboneresttransforms[f][i].basis
			mfgrest1basis = mfgrest1basis.orthonormalized()
			var roty = bonetargetvec1*(1.0/bonetargetvec1len)  # normalized
			var rotz = (mfgrest1basis.x.cross(roty)).normalized()
			var rotx = roty.cross(rotz)
			#var rot = Basis(rotx, roty, rotz)
			var mfg1origin = mfg.origin + mfg.basis*bonerestvec0
			var mfg1basis = Basis(rotx, roty, rotz)*Basis.from_scale(Vector3(1,sca,1))
			#var mfg1basis = Basis.from_scale(Vector3(1,1.0/prevscale,1))*Basis(rotx, roty, rotz)*Basis.from_scale(Vector3(1,sca,1))

			if f == 1:
				prints(f, i, kpositionsfip1, mfg1origin)

			var mfg1 = Transform3D(mfg1basis, mfg1origin)

			fingerbonetransformsOut[f][i] = mfg.affine_inverse()*mfg1
			#prints(i, mfg1.basis.get_scale())
			assert ((fingerbonetransformsOut[f][i].origin - fingerboneresttransforms[f][i].origin).is_zero_approx())

			mfg = mfg1  # mfg*fingerbonetransformsOut[f][i]
			prevscale = sca
			
	return fingerbonetransformsOut

"""
