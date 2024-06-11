const HASS_API = preload ("../hass.gd")

var api: HASS_API
var integration_exists: bool = false

func _init(hass: HASS_API):
	self.api = hass
	test_integration.call_deferred()

func test_integration():
	var response = await api.connection.send_request_packet({
		"type": "immersive_home/register",
		"device_id": OS.get_unique_id(),
		"name": OS.get_model_name(),
		"version": OS.get_version(),
		"platform": OS.get_name(),
	})

	if response.status == Promise.Status.RESOLVED:
		integration_exists = true

func create_area(id: int, name: String):
	if integration_exists == false:
		return

	var response = await api.connection.send_request_packet({
		"type": "immersive_home/add_area",
		"device_id": OS.get_unique_id(),
		"area_id": id,
		"name": name,
	})

	if response.status == Promise.Status.RESOLVED:
		print("Area created")
	else:
		print("Failed to create area")

func set_area_state(id: int, state: bool):
	if integration_exists == false:
		return

	var response = await api.connection.send_request_packet({
		"type": "immersive_home/update_area",
		"device_id": OS.get_unique_id(),
		"area_id": id,
		"active": state,
	})

	if response.status == Promise.Status.RESOLVED:
		print("Area state set")
	else:
		print("Failed to set area state")