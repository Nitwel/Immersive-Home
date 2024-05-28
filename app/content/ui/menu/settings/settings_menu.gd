extends Node3D

@onready var credits = $Content/Credits/Clickable
@onready var background = $Background
@onready var version_label = $Content/LabelVersion
@onready var report_bug_button = $Content/ReportBugButton

func _ready():
	_load_game_version()
	
	background.visible = false

	report_bug_button.on_button_up.connect(func():
		OS.shell_open("https://github.com/Nitwel/Immersive-Home/issues")
	)

func _load_game_version():
	var presets = ConfigFile.new()
	presets.load("res://export_presets.cfg")

	version_label.text = "%s (%s)" % [presets.get_value("preset.1.options", "version/name", "v0.0.0"), presets.get_value("preset.1.options", "version/code", 0)]
