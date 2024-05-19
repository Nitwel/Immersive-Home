extends Control

@onready var url_input = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var token_input = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/LineEdit2
@onready var connect_button = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Button
@onready var log_label = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/Label
@onready var code_input = $HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/CodeEdit

var expression = Expression.new()

func _ready():
	connect_button.button_up.connect(func():
		var url=url_input.text
		var token=token_input.text

		HomeApi.start_adapter("hass_ws", url, token)
		HomeApi.api.LOG_MESSAGES=true
	)

	code_input.text_submitted.connect(func(text):
		var error=expression.parse(text)
		if error != OK:
			print(expression.get_error_text())
			return
		expression.execute.call_deferred([], HomeApi)
	)

	HomeApi.on_connect.connect(func():
		connect_button.text="Connected ✅"
	)

	HomeApi.on_disconnect.connect(func():
		connect_button.text="Connect"
	)
