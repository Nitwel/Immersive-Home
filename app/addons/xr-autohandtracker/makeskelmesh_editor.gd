@tool
extends EditorScript

func _run():
	var s = Skeleton3D.new()
	s.add_bone("one")
	var rot = Basis(Vector3(1,0,0), deg_to_rad(10))
	var scaA = Basis.from_scale(Vector3(1,0.5,1))
	var scaB = Basis.from_scale(Vector3(1,2,1))
	var b = rot*scaA
	var t = Transform3D(b, Vector3(0,0,0))
	s.set_bone_pose(0, t)
	var r = s.get_bone_pose(0)
	print(r)
	print(t)

func D_run():
	var x = load("res://Hand_low_L.gltf").instantiate()
	var skel : Skeleton3D = x.get_node("Armature/Skeleton3D")
	var meshnode = skel.get_child(0)
	var mesh = meshnode.mesh

	for ibone in range(skel.get_bone_count()):
		var iboneparent = skel.get_bone_parent(ibone)
		if iboneparent == -1:
			continue
		var t1 = skel.get_bone_global_pose(ibone)
		var t0 = skel.get_bone_global_pose(iboneparent)
		prints(ibone, iboneparent)
		print(t0.basis.y)
		print((t1.origin - t0.origin).normalized())

	var boxmesh = BoxMesh.new()
	boxmesh.size = Vector3(0.01,0.5,0.2)
	var boxmesharrays = boxmesh.get_mesh_arrays()

	mesh = ArrayMesh.new()
	var g = mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, boxmesharrays)
	print(g)
	print(mesh.surface_get_arrays(0))
	return

	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	print(mdt.get_vertex_count())
	#for i in range(0, mdt.get_vertex_count(), 40):
	for i in range(0, 8, 2):
		print()
		print(i)
		print(mdt.get_vertex(i))
		print(mdt.get_vertex_normal(i))
		print(mdt.get_vertex_tangent(i))
#		print(mdt.get_vertex_bones(i))
#		print(mdt.get_vertex_weights(i))
	print(mdt.get_format())
	print(mdt.get_face_count())
	print(mdt.get_face_vertex(0, 0))
	print(mdt.get_face_vertex(0, 1))
	print(mdt.get_face_vertex(0, 2))
	print(mdt.get_face_vertex(1, 0))
	print(mdt.get_face_vertex(1, 1))
	print(mdt.get_face_vertex(1, 2))
	
	ArrayMesh.ARRAY_FORMAT_VERTEX
	ArrayMesh.ARRAY_FORMAT_NORMAL
	ArrayMesh.ARRAY_FORMAT_TANGENT
	ArrayMesh.ARRAY_FORMAT_TEX_UV
	ArrayMesh.ARRAY_FORMAT_BONES
	ArrayMesh.ARRAY_FORMAT_WEIGHTS
	ArrayMesh.ARRAY_FORMAT_INDEX
	# 100000000000000000000001110000010111
	# 100000000000000000000001000000010111
	
	
