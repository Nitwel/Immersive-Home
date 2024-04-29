extends Node3D

const BoundingBoxTools = preload ("res://lib/utils/mesh/bounding_box_tools.gd")
const ConstructRoomMesh = preload ("res://lib/utils/mesh/construct_room_mesh.gd")

const material_selected = preload ("../room_selected.tres")
const material_unselected = preload ("../room_unselected.tres")

var selectable = R.state(true)
var selected_door = R.state(null)

func _ready():
	R.effect(func(_arg):
		var rooms=Store.house.state.rooms
		var doors=Store.house.state.doors

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

		for door in doors:
			var door_points=[
				Vector2(door.room1_position1.x, door.room1_position1.z),
				Vector2(door.room1_position2.x, door.room1_position2.z),
				Vector2(door.room2_position2.x, door.room2_position2.z),
				Vector2(door.room2_position1.x, door.room2_position1.z)
			]
			var mesh=ConstructRoomMesh.generate_ceiling_mesh(door_points)
			
			if mesh == null:
				continue

			var body=StaticBody3D.new()
			body.name=str(door.id)
			body.position.x=box_transform.origin.x
			body.position.z=box_transform.origin.y
			body.set_collision_layer_value(1, false)
			body.set_collision_layer_value(2, true)
			
			var mesh_instance=MeshInstance3D.new()
			mesh_instance.name="Mesh"
			mesh_instance.mesh=mesh
			mesh_instance.material_override=material_unselected if selected_door.value != door.id else material_selected

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

	var door_id = int(str(event.target.name))

	if selected_door.value == door_id:
		selected_door.value = null
		return

	selected_door.value = door_id

func get_room(door_id):
	if door_id == null:
		return null

	if has_node(str(door_id)):
		return get_node(str(door_id))
	return null
