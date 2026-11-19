extends Node
## In-memory stand-in for a Home Assistant adapter, used by the UI gallery so
## menus that read devices and live states can be previewed without a server.

signal on_connect()
signal on_disconnect()

var states := {}
var devices := []

func _init():
	devices = [
		_device("d_ceiling", "Living Room Ceiling", "Living Room", "Signify", "LCA001", [
			["light.living_room_ceiling", "Living Room Ceiling", "on", {"brightness": 204}],
			["button.living_room_ceiling_identify", "Living Room Ceiling Identify", "unknown", {}],
			["select.living_room_ceiling_effect", "Living Room Ceiling Effect", "none", {}],
			["sensor.living_room_ceiling_signal", "Living Room Ceiling Signal Strength", "-62", {"unit_of_measurement": "dBm"}],
			["update.living_room_ceiling_firmware", "Living Room Ceiling Firmware", "off", {}],
		]),
		_device("d_huego", "Hue Go", "Living Room", "Signify", "LLC020", [
			["light.hue_go", "Hue Go", "off", {}],
			["button.hue_go_identify", "Hue Go Identify", "unknown", {}],
		]),
		_device("d_tv", "Living Room TV", "Living Room", "LG", "OLED55C3", [
			["media_player.living_room_tv", "Living Room TV", "playing", {"media_title": "Planet Earth"}],
		]),
		_device("d_sonos", "Living Room Sonos Beam", "Living Room", "Sonos", "Beam", [
			["media_player.sonos_beam", "Living Room Sonos Beam", "paused", {}],
			["number.sonos_beam_bass", "Living Room Sonos Beam Bass", "2", {}],
			["switch.sonos_beam_night_mode", "Living Room Sonos Beam Night Mode", "off", {}],
		]),
		_device("d_lr_climate", "Living Room Climate Sensor", "Living Room", "Aqara", "WSDCGQ11LM", [
			["sensor.living_room_temperature", "Living Room Temperature", "22.1", {"unit_of_measurement": "°C"}],
			["sensor.living_room_humidity", "Living Room Humidity", "46", {"unit_of_measurement": "%"}],
			["sensor.living_room_climate_battery", "Living Room Climate Sensor Battery", "87", {"unit_of_measurement": "%"}],
		]),
		_device("d_floor_plug", "Living Room Floor Lamp Plug", "Living Room", "Shelly", "Plug S", [
			["switch.floor_lamp_plug", "Living Room Floor Lamp Plug", "on", {}],
			["sensor.floor_lamp_plug_power", "Living Room Floor Lamp Plug Power", "8.4", {"unit_of_measurement": "W"}],
		]),
		_device("d_balcony_cam", "Balcony Camera", "Living Room", "Reolink", "E1 Outdoor", [
			["camera.balcony", "Balcony Camera", "idle", {}],
		]),
		_device("d_kitchen_spots", "Kitchen Spots", "Kitchen", "IKEA", "TRADFRI GU10", [
			["light.kitchen_spots", "Kitchen Spots", "on", {"brightness": 255}],
		]),
		_device("d_kitchen_sonos", "Kitchen Sonos One", "Kitchen", "Sonos", "One", [
			["media_player.kitchen_sonos", "Kitchen Sonos One", "idle", {}],
		]),
		_device("d_dishwasher", "Dishwasher Smart Plug", "Kitchen", "Shelly", "Plug S", [
			["switch.dishwasher", "Dishwasher Smart Plug", "off", {}],
			["sensor.dishwasher_power", "Dishwasher Power", "0.0", {"unit_of_measurement": "W"}],
		]),
		_device("d_kitchen_window", "Kitchen Window Sensor", "Kitchen", "Aqara", "MCCGQ11LM", [
			["binary_sensor.kitchen_window", "Kitchen Window", "off", {}],
		]),
		_device("d_bed_lamp", "Bedroom Lamp", "Bedroom", "IKEA", "TRADFRI E27", [
			["light.bedroom_lamp", "Bedroom Lamp", "off", {}],
		]),
		_device("d_bed_climate", "Bedroom Climate Sensor", "Bedroom", "Aqara", "WSDCGQ11LM", [
			["sensor.bedroom_temperature", "Bedroom Temperature", "21.4", {"unit_of_measurement": "°C"}],
			["sensor.bedroom_humidity", "Bedroom Humidity", "51", {"unit_of_measurement": "%"}],
		]),
		_device("d_office_desk", "Office Desk Light", "Office", "Signify", "LTW012", [
			["light.office_desk", "Office Desk Light", "on", {"brightness": 128}],
		]),
		_device("d_office_window", "Office Window Sensor", "Office", "Aqara", "MCCGQ11LM", [
			["binary_sensor.office_window", "Office Window", "on", {}],
		]),
		_device("d_thermostat", "Hallway Thermostat", "Hallway", "tado", "RU02", [
			["sensor.hallway_temperature", "Hallway Temperature", "19.8", {"unit_of_measurement": "°C"}],
			["number.hallway_target_temperature", "Hallway Target Temperature", "20.0", {"unit_of_measurement": "°C"}],
		]),
		_device("d_hall_motion", "Hallway Motion Sensor", "Hallway", "Philips", "SML001", [
			["binary_sensor.hallway_motion", "Hallway Motion", "off", {}],
			["sensor.hallway_illuminance", "Hallway Illuminance", "120", {"unit_of_measurement": "lx"}],
		]),
		_device("d_bath_mirror", "Bathroom Mirror Light", "Bathroom", "Signify", "LWB010", [
			["light.bathroom_mirror", "Bathroom Mirror Light", "off", {}],
		]),
		_device("d_washer", "Washing Machine Plug", "Bathroom", "Shelly", "Plug S", [
			["switch.washing_machine", "Washing Machine Plug", "on", {}],
			["sensor.washing_machine_power", "Washing Machine Power", "412", {"unit_of_measurement": "W"}],
		]),
		_device("d_front_cam", "Front Door Camera", null, "Reolink", "Doorbell", [
			["camera.front_door", "Front Door Camera", "recording", {}],
			["binary_sensor.front_door_visitor", "Front Door Visitor", "off", {}],
		]),
		_device("d_vacuum", "Robot Vacuum", null, "Roborock", "S7", [
			["vacuum.robot", "Robot Vacuum", "docked", {}],
			["sensor.robot_battery", "Robot Vacuum Battery", "100", {"unit_of_measurement": "%"}],
		]),
		_device("d_router", "FRITZ!Box 7590", null, "AVM", "FRITZ!Box 7590", [
			["update.fritzbox_firmware", "FRITZ!Box 7590 Firmware", "off", {}],
			["device_tracker.fritzbox", "FRITZ!Box 7590", "home", {}],
		]),
		_device("d_phone", "Pixel 8", null, "Google", "Pixel 8", [
			["sensor.pixel_8_battery", "Pixel 8 Battery Level", "64", {"unit_of_measurement": "%"}],
			["device_tracker.pixel_8", "Pixel 8", "home", {}],
		]),
		_device("other.weather", "Weather", null, null, null, [
			["weather.forecast_home", "Forecast Home", "partlycloudy", {"temperature": 8.9}],
		]),
		_device("other.sensor", "Sensor", null, null, null, [
			["sensor.energy_today", "Energy Today", "6.2", {"unit_of_measurement": "kWh"}],
			["sensor.outdoor_temperature", "Outdoor Temperature", "8.9", {"unit_of_measurement": "°C"}],
		]),
		_device("other.automation", "Automation", null, null, null, [
			["automation.lights_off_at_night", "Lights off at night", "on", {}],
			["automation.wake_up", "Wake up", "on", {}],
		]),
		_device("other.zone", "Zone", null, null, null, [
			["zone.home", "Home", "1", {}],
		]),
	]

func _device(id, name, area, manufacturer, model, entities: Array) -> Dictionary:
	var entity_list = []
	for e in entities:
		entity_list.append({"id": e[0], "name": e[1]})
		states[e[0]] = {"state": e[2], "attributes": e[3]}

	return {"id": id, "name": name, "area": area, "manufacturer": manufacturer, "model": model, "entities": entity_list}

func has_connected():
	return true

func get_devices():
	return devices.duplicate(true)

func get_device(_id: String):
	return null

func get_state(entity: String):
	return states.get(entity, null)

func watch_state(_entity: String, _callback: Callable):
	return func(): pass

func set_state(entity: String, state: Variant, _attributes: Dictionary={}):
	if states.has(entity):
		states[entity]["state"] = state
	return states.get(entity, null)

func has_integration():
	return true

## Replaces the HomeApi adapter with this fake and loads the sample devices
## into Store.devices, as if a Home Assistant connection was just made.
static func install() -> Node:
	var home_api = Engine.get_main_loop().root.get_node("HomeApi")
	home_api.reconnect_timer.stop()

	if home_api.api != null:
		home_api.api.on_connect.disconnect(home_api._on_connect)
		home_api.api.on_disconnect.disconnect(home_api._on_disconnect)
		home_api.remove_child(home_api.api)
		home_api.api.queue_free()

	var fake = load("res://test/ui/fake_home_api.gd").new()
	home_api.api = fake
	home_api.add_child(fake)
	home_api.on_connect.emit()
	return fake
