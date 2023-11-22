extends XRController3D

@onready var area = $trash_bin/Area3D
@onready var trash_bin = $trash_bin
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

	EventSystem.on_grab_down.connect(func(event: EventRay):
		trash_bin_visible = event.target.is_in_group("entity")
	)

	EventSystem.on_grab_move.connect(func(event):
		if !trash_bin_visible:
			return

		if event.target.is_in_group("entity") && area.overlaps_body(event.target):
			if !to_delete.has(event.target):
				to_delete.append(event.target)
			trash_bin_large = true
			
		else:
			to_delete.erase(event.target)
			trash_bin_large = false
			
	)

	EventSystem.on_grab_up.connect(func(_event: EventRay):
		if !trash_bin_visible:
			return

		for entity in to_delete:
			entity.queue_free()
		to_delete.clear()
		trash_bin_large = false
		trash_bin_visible = false
	)
