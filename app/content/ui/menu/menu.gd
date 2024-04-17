extends Node3D

const Notification = preload ("res://content/ui/components/notification/notification.tscn")

@onready var animation_player = $AnimationPlayer
@onready var notify_place = $AnimationContainer/NotifyPlace
@onready var main = $"/root/Main"

var show_menu = R.state(false)

func _ready():
	await main.ready

	main.remove_child(self)

	R.effect(func(_arg):
		if show_menu.value:
			main.add_child(self)
			move_into_view()
			animation_player.play_backwards("hide_menu")
			AudioPlayer.play_effect("open_menu")
		else:
			animation_player.play("hide_menu")
			AudioPlayer.play_effect("close_menu")
	)

	animation_player.animation_finished.connect(func(_animation):
		if show_menu.value == false:
			main.remove_child(self)
	)

	EventSystem.on_notify.connect(func(event: EventNotify):
		var notification_node=Notification.instantiate()
		notification_node.text=event.message
		notification_node.type=event.type

		for child in notify_place.get_children():
			child.position += Vector3(0, 0, -0.06)

		notify_place.add_child(notification_node)
	)

func move_into_view():
	var camera_transform = main.camera.global_transform
	camera_transform.origin -= camera_transform.basis.z * 0.5

	camera_transform.basis = camera_transform.basis.rotated(camera_transform.basis.x, deg_to_rad(90))

	global_transform = camera_transform