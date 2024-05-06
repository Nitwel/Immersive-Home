extends Node3D

@onready var save = $Save
@onready var clear_save = $ClearSave

func _ready():

	save.on_button_down.connect(func():
		House.body.save_all_entities()
		Store.house.save_local()
	)

	clear_save.on_button_down.connect(func():
		Store.house.clear()
		House.body.update_house()
	)
