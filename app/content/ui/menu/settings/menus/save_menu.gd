extends Node3D

@onready var save = $Save
@onready var clear_save = $ClearSave
@onready var clear_entities = $ClearEntities

func _ready():

	save.on_button_down.connect(func():
		App.house.save_all_entities()
	)

	clear_save.on_button_down.connect(func():
		Store.house.clearhouse(false)
		App.house.update_house()
	)

	clear_entities.on_button_down.connect(func():
		Store.house.clearhouse(true)
		App.house.update_house()
	)
