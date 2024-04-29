extends Node3D

const BoundingBoxTools = preload ("res://lib/utils/mesh/bounding_box_tools.gd")
const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")

const material_selected = preload ("../room_selected.tres")
const material_unselected = preload ("../room_unselected.tres")

var selectable = R.state(true)
var selected_room = R.state(null)

func _ready():
	R.effect(func(_arg):
		var rooms=Store.house.state.rooms

		for old_room in get_children():
			remove_child(old_room)
			old_room.queue_free()

		if rooms.size() == 0:
			return

		var target_rect=Rect2(0.0, 0.0, 0.2, 0.2)
		var rooms_rect=Rect2()

		for room in rooms:
			rooms_rect=rooms_rect.merge(BoundingBoxTools.get_bounding_box_2d(room.corners))

		var box_transform=BoundingBoxTools.resize_bounding_box_2d(rooms_rect, target_rect)

		for room in rooms:
			var mesh=ConstructRoomMesh.generate_ceiling_mesh(room.corners)
			
			if mesh == null:
				continue

			var body=StaticBody3D.new()
			body.name=room.name
			body.position.x=box_transform.origin.x
			body.position.z=box_transform.origin.y
			body.set_collision_layer_value(1, false)
			body.set_collision_layer_value(2, true)
			
			var mesh_instance=MeshInstance3D.new()
			mesh_instance.name="Mesh"
			mesh_instance.mesh=mesh
			mesh_instance.material_override=material_unselected if selected_room.value != room.name else material_selected

			body.add_child(mesh_instance)

			var collision_shape=CollisionShape3D.new()
			collision_shape.shape=mesh.create_trimesh_shape()
			body.add_child(collision_shape)

			add_child(body)

		var box_scale=box_transform.get_scale()
		var min_scale=min(box_scale.x, box_scale.y)
		scale=Vector3(min_scale, min_scale, min_scale)
	)

func _on_click(event: EventPointer):
	if selectable.value == false:
		return

	var previous_room = get_room(selected_room.value)

	if previous_room != null:
		previous_room.get_node("Mesh").material_override = material_unselected

	var room_name = event.target.name

	if selected_room.value == room_name:
		selected_room.value = null
		return

	selected_room.value = room_name
	get_room(selected_room.value).get_node("Mesh").material_override = material_selected

func get_room(room_name):
	if room_name == null:
		return null

	if has_node(str(room_name)):
		return get_node(str(room_name))
	return null
