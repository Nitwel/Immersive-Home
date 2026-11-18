const HASS_API = preload ("../hass.gd")

var api: HASS_API
var integration_exists: bool = false

func _init(hass: HASS_API):
	self.api = hass

func get_history(entity_id: String, start: String, interval: String="5minute", end=null):
	var meta_response = await api.connection.send_request_packet({
		"type": "recorder/get_statistics_metadata",
		"statistic_ids": [
			entity_id
		]
	})

	if meta_response.status != OK:
		return null

	var data_response = await api.connection.send_request_packet({
		"type": "recorder/statistics_during_period",
		"start_time": start,
		"statistic_ids": [
			entity_id
		],
		"period": interval,
		"types": [
			"state",
			"mean"
		]
	})

	if data_response.status != OK:
		return null

	if meta_response.payload.result.size() == 0:
		return null

	return {
		"unit": meta_response.payload.result[0]["display_unit_of_measurement"],
		"has_mean": meta_response.payload.result[0]["has_mean"],
		"unit_class": meta_response.payload.result[0]["unit_class"],
		"data": data_response.payload.result[entity_id] if data_response.payload.result.has(entity_id) else []
	}
