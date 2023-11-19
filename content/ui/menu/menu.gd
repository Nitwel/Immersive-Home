extends Node3D

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

enum Menu {
	VIEW,
	EDIT,
	ROOM,
	AUTOMATE,
	SETTINGS
}

var selected_menu := Menu.EDIT
var show_menu := true:
	get:
		return show_menu
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
		print(button)
		if button == "by_button":
			show_menu = !show_menu
	)

	select_menu(selected_menu)

func _on_click(event):
	if event.target == nav_view:
		select_menu(Menu.VIEW)
	elif event.target == nav_edit:
		select_menu(Menu.EDIT)
	elif event.target == nav_room:
		select_menu(Menu.ROOM)
	elif event.target == nav_automate:
		select_menu(Menu.AUTOMATE)
	elif event.target == nav_settings:
		select_menu(Menu.SETTINGS)

func select_menu(menu: Menu):
	selected_menu = menu
	for child in content.get_children():
		content.remove_child(child)

	var menu_node = enum_to_menu(menu)
	var nav_node = enum_to_nav(menu)

	if nav_node != null:
		nav_node.disabled = true

	if menu_node != null:
		menu_node.visible = true
		content.add_child(menu_node)

	for child in nav.get_children():
		if child.active && child != nav_node:
			child.active = false
			child.disabled = false
		
func enum_to_nav(menu: Menu):
	match menu:
		Menu.VIEW:
			return nav_view
		Menu.EDIT:
			return nav_edit
		Menu.ROOM:
			return nav_room
		Menu.AUTOMATE:
			return nav_automate
		Menu.SETTINGS:
			return nav_settings

func enum_to_menu(menu: Menu):
	match menu:
		Menu.VIEW:
			return null
		Menu.EDIT:
			return menu_edit
		Menu.ROOM:
			return menu_room
		Menu.AUTOMATE:
			return null
		Menu.SETTINGS:
			return menu_settings
