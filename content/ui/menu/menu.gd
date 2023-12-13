extends Node3D

const Proxy = preload("res://lib/utils/proxy.gd")
const Notification = preload("res://content/ui/components/notification/notification.tscn")

@onready var _controller := XRHelpers.get_xr_controller(self)

@onready var nav_view = $AnimationContainer/Navigation/View
@onready var nav_edit: Button3D = $AnimationContainer/Navigation/Edit
@onready var menu_edit: Node3D = $AnimationContainer/Content/EditMenu
@onready var nav_room = $AnimationContainer/Navigation/Room
@onready var menu_room: Node3D = $AnimationContainer/Content/RoomMenu
@onready var nav_automate = $AnimationContainer/Navigation/Automate
@onready var nav_settings = $AnimationContainer/Navigation/Settings
@onready var menu_settings: Node3D = $AnimationContainer/Content/SettingsMenu

@onready var menu_root = $AnimationContainer
@onready var content = $AnimationContainer/Content
@onready var nav = $AnimationContainer/Navigation
@onready var animation_player = $AnimationPlayer
@onready var notify_place = $AnimationContainer/NotifyPlace

var selected_nav = null

var show_menu := true:
	set(value):
		show_menu = value
		if value:
			animation_player.play_backwards("hide_menu")
			AudioPlayer.play_effect("open_menu")
		else:
			animation_player.play("hide_menu")
			AudioPlayer.play_effect("close_menu")

func _ready():
	_controller.button_pressed.connect(func(button):
		if button == "by_button":
			show_menu = !show_menu
	)

	EventSystem.on_notify.connect(func(event: EventNotify):
		var notification_node = Notification.instantiate()
		notification_node.text = event.message
		notification_node.type = event.type

		for child in notify_place.get_children():
			child.position += Vector3(0, 0, -0.06)

		notify_place.add_child(notification_node)

		
		
		
	)

	var nav_buttons = [
		nav_view,
		nav_edit,
		nav_room,
		nav_automate,
		nav_settings
	]

	for nav_button in nav_buttons:
		var getter = func():
			return nav_button == selected_nav
		
		var setter = func(value):
			if value:
				select_menu(nav_button)

		nav_button.external_value = Proxy.new(getter, setter)

	select_menu(nav_edit)

func select_menu(nav):
	if _is_valid_nav(nav) == false || selected_nav == nav:
		return

	for child in content.get_children():
		content.remove_child(child)

	var old_nav = selected_nav

	selected_nav = nav

	if old_nav != null:
		old_nav.update_animation()

	if selected_nav != null:
		selected_nav.update_animation()
		var menu = _nav_to_menu(selected_nav)
		if menu != null:
			content.add_child(menu)
			menu.visible = true

func _is_valid_nav(nav):
	return nav == nav_view || nav == nav_edit || nav == nav_room || nav == nav_automate || nav == nav_settings		

func _nav_to_menu(nav):
	match nav:
		nav_view:
			return null
		nav_edit:
			return menu_edit
		nav_room:
			return menu_room
		nav_automate:
			return null
		nav_settings:
			return menu_settings
	return null
