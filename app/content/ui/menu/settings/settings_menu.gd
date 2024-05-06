extends Node3D

@onready var credits = $Content/Credits/Clickable
@onready var background = $Background
@onready var version_label = $Content/LabelVersion

func _ready():
	_load_game_version()
	
	background.visible = false

func _load_game_version():
	var presets = ConfigFile.new()
	presets.load("res://export_presets.cfg")

	version_label.text = "%s (%s)" % [presets.get_value("preset.1.options", "version/name", "v0.0.0"), presets.get_value("preset.1.options", "version/code", 0)]
