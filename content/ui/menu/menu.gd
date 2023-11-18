extends Node3D

@onready var nav_view = $Navigation/View
@onready var nav_edit: Button3D = $Navigation/Edit
@onready var menu_edit: Node3D = $Content/EditMenu
@onready var nav_room = $Navigation/Room
@onready var nav_automate = $Navigation/Automate
@onready var nav_settings = $Navigation/Settings

enum Menu {
	VIEW,
	EDIT,
	ROOM,
	AUTOMATE,
	SETTINGS
}

var selected_menu := Menu.EDIT

func _ready():
	pass

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
	for child in $Content.get_children():
		if child.is_visible():
			child.hide()

	var menu_node = enum_to_menu(menu)
	var nav_node = enum_to_nav(menu)

	if nav_node != null:
		nav_node.disabled = true

	if menu_node != null:
		menu_node.show()

	for child in $Navigation.get_children():
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
			return null
		Menu.AUTOMATE:
			return null
		Menu.SETTINGS:
			return null