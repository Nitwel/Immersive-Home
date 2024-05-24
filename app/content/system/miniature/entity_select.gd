extends Marker3D

const DotScene = preload ("res://content/system/dot/dot.tscn")
const Entity = preload ("res://content/entities/entity.gd")

@onready var dots = $"../Small/Dots"

var active_type = null
var editing = R.state([])
var group_entity = null

func _ready():
	await App.main.ready

	# Update Group Entity
	R.effect(func(_arg):
		if App.miniature.small.value == false||editing.value.size() == 0:
			if group_entity != null:
				remove_child(group_entity)
				group_entity.queue_free()
				group_entity=null
		elif group_entity == null:
			var id=HomeApi.groups.create(editing.value.map(func(entity): return entity.entity_id))
			group_entity=EntityFactory.create_entity(id, active_type)
			for entity_node in group_entity.get_children():
				if entity_node is Movable:
					entity_node.disabled=true

			group_entity.transform=Transform3D().looking_at(to_local((App.camera.global_position)), Vector3.UP, true)
			add_child(group_entity)
		else:
			HomeApi.groups.update_entities(group_entity.entity_id, editing.value.map(func(entity): return entity.entity_id))
	)

	var dots_disabled = R.computed(func(_arg):
		return App.miniature.small.value == false
	)

	# Update Entities
	R.effect(func(_arg):
		if App.house.loaded.value == false:
			return

		if Store.house.state.entities.size() == 0:
			return

		for old_dot in dots.get_children():
			dots.remove_child(old_dot)
			old_dot.free()

		for room in App.house.get_rooms():
			for entity in room.get_node("Entities").get_children():
				var dot=DotScene.instantiate()

				dot.position=App.house.to_local(entity.global_position)
				dot.entity=entity
				dot.active=R.computed(func(_arg2):
					return editing.value.has(entity)
				)
				dot.disabled=dots_disabled
				dots.add_child(dot)
	)

func selection_active():
	return editing.value.size() > 0

func toggle(entity: Entity):
	if active_type == null:
		active_type = entity.entity_id.split(".")[0]
	elif active_type != entity.entity_id.split(".")[0]:
		return

	if editing.value.has(entity):
		editing.value.erase(entity)
		if editing.value.size() == 0:
			active_type = null
	else:
		editing.value.append(entity)

	editing.value = editing.value