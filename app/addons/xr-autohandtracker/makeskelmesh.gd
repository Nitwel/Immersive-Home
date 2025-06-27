extends Skeleton3D


func makeboneboxmesh(skel, iboneparent, ibone):
	assert (iboneparent != -1 and iboneparent == skel.get_bone_parent(ibone))
	var t0 = skel.get_bone_global_pose(iboneparent)
	var tp = skel.get_bone_pose(ibone)
	var t1 = skel.get_bone_global_pose(ibone) # = t0*tp
	var v01 = t1.origin - t0.origin
	var boneleng = tp.origin.length()
	var rot = AutoHandFuncs.rotationtoalignUnScaled(Vector3(0,1,0), v01)
	var cpos = (t0.origin + t1.origin)*0.5
	assert (is_equal_approx(boneleng, v01.length()))

	prints(ibone, iboneparent)
	print(t0.basis.y)
	print((t1.origin - t0.origin).normalized())

	var boxmesh = BoxMesh.new()
	boxmesh.size = Vector3(0.005, boneleng, 0.008)
	var boxmesharrays = boxmesh.get_mesh_arrays()
	var N =len(boxmesharrays[Mesh.ARRAY_VERTEX])
	var vertexes = boxmesharrays[Mesh.ARRAY_VERTEX]
	var normals = boxmesharrays[Mesh.ARRAY_NORMAL]
	var tangents = boxmesharrays[Mesh.ARRAY_TANGENT]

	var bones = PackedInt32Array()
	bones.resize(N*4)
	var weights = PackedFloat32Array()
	weights.resize(N*4)
	for i in range(N):
		bones[i*4] = iboneparent
		weights[i*4] = 1.0
		vertexes[i] = rot*vertexes[i] + cpos
		normals[i] = rot*normals[i]
		var tg = rot*Vector3(tangents[i*4], tangents[i*4+1], tangents[i*4+2])
		tangents[i*4] = tg.x
		tangents[i*4+1] = tg.y
		tangents[i*4+2] = tg.z
	boxmesharrays[Mesh.ARRAY_BONES] = bones
	boxmesharrays[Mesh.ARRAY_WEIGHTS] = weights
	return boxmesharrays


func _ready():
	return
	print($mesh_Hand_low_L.mesh.surface_get_primitive_type(0))
	var handmesharrays = $mesh_Hand_low_L.mesh.surface_get_arrays(0)

	$mesh_Hand_low_L.mesh = ArrayMesh.new()
	var mesh : ArrayMesh = $mesh_Hand_low_L.mesh
	#mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, boxmesharrays2)
#	handmesharrays[Mesh.ARRAY_BONES] = null
#	handmesharrays[Mesh.ARRAY_WEIGHTS] = null
#	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, handmesharrays)

	for ibone in range(get_bone_count()):
		var iboneparent = get_bone_parent(ibone)
		if iboneparent != -1:
			var boxmesharrays = makeboneboxmesh(self, iboneparent, ibone)
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, boxmesharrays)

	print(mesh.get_surface_count())
	print(mesh.surface_get_array_len(0))
	print("hi there")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
