extends Node3D

@onready var menu_button = $Menu
@onready var mini_button = $Mini
@onready var clock = $Clock
@onready var main = $"/root/Main"

func _ready():
	menu_button.on_button_down.connect(func():
		main.toggle_menu()
	)

	mini_button.on_button_down.connect(func():
		House.body.mini_view = !House.body.mini_view
	)
