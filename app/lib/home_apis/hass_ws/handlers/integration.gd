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

	# Home Assistant also answers when the integration isn't installed, with success: false
	integration_exists = response.status == Promise.Status.RESOLVED&&response.payload.get("success") == true

	if integration_exists:
		api.on_integration_ready.emit()
