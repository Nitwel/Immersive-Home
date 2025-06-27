extends Entity

const Entity = preload ("../entity.gd")

@onready var button = $Button
@onready var long_text = $LongText
@onready var title = $Title
@onready var draggable = $DragBottom
@onready var panel = $Panel
var next_stations = ""

var event: EventPointer

func _ready():
	super()
	icon.value = "radio_button_checked"
	await HomeApi.watch_state(entity_id, func(new_state):
		set_stateevent(new_state)
	)
	
	#for Label3D in get_children(true):
	#	if is_instance_valid(Label3D.get_aabb()):
	#		print(var_to_str(Label3D.get_aabb()))

	var stateInfo = await HomeApi.get_state(entity_id)
	$entityId.text = entity_id
	# this is where we want to have backed up the text
	set_stateevent(stateInfo)

	$CollisionShape3D.scale = panel.scale
	$CollisionShape3D.transform = panel.transform
	
	await get_tree().create_timer(0.1).timeout
	
#	var merged_aabb = $Title.get_aabb()
#	merged_aabb = merged_aabb.merge(long_text.get_aabb())
#	panel.position.y = title.position.y + (title.position.y - long_text.position.y)
#	panel.size.x = merged_aabb.size.x * 2
#	panel.size.y = merged_aabb.size.y * 2
#	print("panel size: " + var_to_str(merged_aabb.size * 2))



func get_options():
	return {
		"longtext": long_text.text,
		"title":title.text,
		"next_stations":next_stations
	}

func set_options(options):
	if options.has("longtext"): 
		long_text.text = options["longtext"]
	if options.has("title"):
		title.text = options["title"]
	if options.has("next_stations"):
		next_stations = options["next_stations"]
	update_labelshape()
	
func set_stateevent(stateInfo):
	if stateInfo == null:
		pass
	elif not stateInfo.has("text"):
		long_text.text = stateInfo.state
		title.text = stateInfo.attributes.friendly_name
	else:
		print("stateInfo ", stateInfo)
		long_text.text = stateInfo.text
		title.text = stateInfo.name
		next_stations = stateInfo.next_stations
	update_labelshape()

func update_labelshape():
	var snext_stations = next_stations.split(" ")
	while snext_stations and not snext_stations[0]:
		snext_stations.remove_at(0)
	for i in range(min(len(snext_stations), 2)):
		$NextStations.get_node("Next%d/Label3D"%(i+1)).text = snext_stations[i]
		$NextStations.get_node("Next%d"%(i+1)).visible = true
		$NextStations.get_node("Next%d"%(i+1)).disabled = false
	for i in range(len(snext_stations), 2):
		$NextStations.get_node("Next%d"%(i+1)).visible = false
		$NextStations.get_node("Next%d"%(i+1)).disabled = true

	await get_tree().process_frame  
	var laabb = $LongText.get_aabb()
	if laabb:
#		$CollisionShape3D.position = laabb.get_center() + $LongText.position
#		$CollisionShape3D.shape.size.x = laabb.size.x/2
#		$CollisionShape3D.shape.size.y = laabb.size.y/2
		$CollisionShape3D.scale.x = panel.size.x * 20
		$CollisionShape3D.scale.y = panel.size.y * 20
		$CollisionShape3D.position = panel.position
		#print("Long text scale "+ var_to_str($LongText.scale))
		pass



func _on_drag_bottom_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print(var_to_str(event))
	#draggable.position.y = (event.initiator.node.global_position - event.initiator.node.global_transform.basis.z.normalized() * event.ray.get_collision_point().distance_to(event.ray.global_position)).y
