extends Node3D

@onready var background = $Background
@onready var add_button = $Interface/TabsContent3D/AreasMenu/AddButton
@onready var name_input = $Interface/TabsContent3D/AreasMenu/NameInput

func _ready():
	background.visible = false

	visibility_changed.connect(func():
		App.areas.editing=visible
	)

	tree_entered.connect(func():
		App.areas.editing=true
	)

	tree_exiting.connect(func():
		App.areas.editing=false
	)

	add_button.on_button_up.connect(func():
		App.areas.create_area(name_input.text)
	)
