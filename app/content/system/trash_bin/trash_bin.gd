extends Node3D

const Entity = preload ("res://content/entities/entity.gd")

@onready var trash_bin = $trash_bin
@onready var bin_area = $trash_bin/Area3D

@onready var delete_sound = $DeleteSound
@onready var animation = $AnimationPlayer

var to_delete = []
var trash_bin_visible: bool = true:
	set(value):
		if trash_bin_visible == value:
			return

		if value:
			add_child(trash_bin)
		else:
			if animation.is_playing():
				await animation.animation_finished
			remove_child(trash_bin)

		trash_bin_visible = value

var trash_bin_large: bool = false:
	set(value):
		if trash_bin_large == value:
			return

		if value:
			animation.play("add_trashbin")
		else:
			animation.play_backwards("add_trashbin")

		trash_bin_large = value

func _ready():
	trash_bin_visible = false

	EventSystem.on_grab_down.connect(func(event: EventPointer):
		trash_bin_visible=_get_entity(event.target) != null
	)

	EventSystem.on_grab_move.connect(func(event):
		if !trash_bin_visible:
			return

		var entity=_get_entity(event.target)

		if entity is Entity&&bin_area.overlaps_body(entity):
			if !to_delete.has(entity):
				to_delete.append(entity)
			trash_bin_large=true
			
		else:
			to_delete.erase(entity)
			trash_bin_large=false
			
	)

	EventSystem.on_grab_up.connect(func(_event: EventPointer):
		if !trash_bin_visible:
			return

		if to_delete.size() > 0:
			delete_sound.play()

		for entity in to_delete:
			entity.get_parent().remove_child(entity)
			entity.queue_free()
		to_delete.clear()
		trash_bin_large=false
		trash_bin_visible=false

		App.house.save_all_entities()
	)

func _get_entity(node: Node):
	if node is Entity:
		return node

	if node.get_parent() == null:
		return null

	return _get_entity(node.get_parent())