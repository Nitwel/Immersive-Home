extends Node3D

const Proxy = preload("res://lib/utils/proxy.gd")
const Notification = preload("res://content/ui/components/notification/notification.tscn")

@onready var menu_root = $AnimationContainer
@onready var content = $AnimationContainer/Content
@onready var nav = $AnimationContainer/Navigation
@onready var animation_player = $AnimationPlayer
@onready var notify_place = $AnimationContainer/NotifyPlace

var selected_nav = null

var show_menu := false:
	set(value):
		show_menu = value
		if value:
			animation_player.play_backwards("hide_menu")
			AudioPlayer.play_effect("open_menu")
		else:
			animation_player.play("hide_menu")
			AudioPlayer.play_effect("close_menu")

func _ready():
	EventSystem.on_notify.connect(func(event: EventNotify):
		var notification_node = Notification.instantiate()
		notification_node.text = event.message
		notification_node.type = event.type

		for child in notify_place.get_children():
			child.position += Vector3(0, 0, -0.06)

		notify_place.add_child(notification_node)
	)
