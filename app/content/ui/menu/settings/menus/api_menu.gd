extends Node3D

const SetupCode = preload ("res://lib/home_apis/hass_ws/setup_code.gd")
const Discovery = preload ("res://lib/home_apis/hass_ws/discovery.gd")

@onready var status_label = $LabelStatus
@onready var input_url = $InputURL
@onready var input_token = $InputToken
@onready var button_connect = $Connect
@onready var button_discover = $Discover
@onready var button_demo = $Demo

var discovering := false
## Installs found by the last discovery, pressing discover again cycles through them.
var discovered: Array[Dictionary] = []
var discovered_index := -1

func _ready():
	var settings_store = Store.settings.state

	if Store.settings.is_loaded() == false:
		await Store.settings.on_loaded

	input_url.text = settings_store.url
	input_token.text = settings_store.token

	button_connect.on_button_down.connect(_connect)
	button_discover.on_button_down.connect(_on_discover_pressed)

	# Before connecting the handler, setting active emits on_toggled.
	button_demo.active = settings_store.type == "DEMO"
	button_demo.on_toggled.connect(_on_demo_toggled)

	if HomeApi.has_connected():
		_show_connected()

	HomeApi.on_connect.connect(_show_connected)

	HomeApi.on_disconnect.connect(func():
		status_label.text="Status: Disconnected"
	)

	visibility_changed.connect(func():
		# Help with the first setup by looking for Home Assistant right away.
		if is_visible_in_tree()&&input_url.text.strip_edges() == ""&&discovered.is_empty():
			_discover()
	)

func _show_connected():
	status_label.text = "Status: Demo mode" if HomeApi.is_demo() else "Status: Connected"

func _connect():
	var settings_store = Store.settings.state
	var url = input_url.text.strip_edges()
	var token = input_token.text.strip_edges()

	HomeApi.start_adapter("hass_ws", url, token)

	settings_store.type = "HASS_WS"
	settings_store.url = url
	settings_store.token = token

	Store.settings.save_local()

	button_demo.active = false

## Turning demo mode on builds a fresh demo apartment around you, turning it off
## connects to Home Assistant again with the settings above.
func _on_demo_toggled(active: bool):
	if active == HomeApi.is_demo():
		return

	if active:
		HomeApi.start_demo()
		EventSystem.notify("Demo mode: a made-up home was built around you.", EventNotify.Type.SUCCESS)
	else:
		HomeApi.stop_demo()
		status_label.text = "Status: Disconnected"
		EventSystem.notify("Demo mode off, connecting to Home Assistant.", EventNotify.Type.INFO)

## Fills in the connection settings from a QR code scanned with the keyboard.
func _on_qr_scan(event: EventQr):
	var setup = SetupCode.parse(event.text)

	if setup.url == ""&&setup.token == "":
		# Not connection settings, let the keyboard type the text into the input.
		return

	event.bubbling = false

	if setup.url != "":
		input_url.text = setup.url

	if setup.token != "":
		input_token.text = setup.token

	if setup.token == "":
		EventSystem.notify("Home Assistant URL added.", EventNotify.Type.SUCCESS)
		return

	if input_url.text.strip_edges() == "":
		await _discover()

	if input_url.text.strip_edges() == "":
		EventSystem.notify("Token added. Enter the URL of Home Assistant to connect.", EventNotify.Type.SUCCESS)
		return

	EventSystem.notify("Token added, connecting to Home Assistant.", EventNotify.Type.SUCCESS)
	_connect()

func _on_discover_pressed():
	if discovered.size() > 1:
		_select_discovered((discovered_index + 1) % discovered.size())
		return

	_discover()

func _discover():
	if discovering:
		return

	discovering = true
	button_discover.disabled = true
	EventSystem.notify("Searching for Home Assistant on your network...")

	discovered = await Discovery.discover(get_tree())

	discovering = false
	button_discover.disabled = false

	if discovered.is_empty():
		EventSystem.notify("No Home Assistant found on your network. Enter the URL manually.", EventNotify.Type.WARNING)
		return

	_select_discovered(0)

func _select_discovered(index: int):
	discovered_index = index
	var install = discovered[index]
	input_url.text = install.url

	var message = "Found Home Assistant \"%s\"." % install.name
	if discovered.size() > 1:
		message += " Press search again for the next one (%d/%d)." % [index + 1, discovered.size()]

	EventSystem.notify(message, EventNotify.Type.SUCCESS)
