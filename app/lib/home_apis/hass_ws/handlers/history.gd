const HASS_API = preload ("../hass.gd")

var api: HASS_API
var integration_exists: bool = false

func _init(hass: HASS_API):
	self.api = hass

## Recorded states (with attributes, e.g. GPS positions) of [param entity_ids] since
## [param start] (ISO time): {entity_id: [{state, attributes, time (unix)}]}, oldest
## first. Uses the same call as Home Assistant's history and map panels.
func get_state_history(entity_ids: Array, start: String, end=null) -> Dictionary:
	var packet = {
		"type": "history/history_during_period",
		"start_time": start,
		"entity_ids": entity_ids,
		"include_start_time_state": true,
		# Every position update, not only state changes (home -> not_home)
		"significant_changes_only": false,
		"minimal_response": false,
		"no_attributes": false,
	}
	if end != null:
		packet["end_time"] = end

	var response = await api.connection.send_request_packet(packet)
	if response.status != OK:
		return {}

	var result = response.payload.get("result")
	if not result is Dictionary:
		return {}

	# Compressed state format: s = state, a = attributes, lu = last updated (unix)
	var history = {}
	for entity_id in result:
		history[entity_id] = result[entity_id].map(func(entry):
			return {"state": entry.get("s"), "attributes": entry.get("a", {}), "time": float(entry.get("lu", 0))}
		)
	return history

func get_history(entity_id: String, start: String, interval: String="5minute", end=null):
	var meta_response = await api.connection.send_request_packet({
		"type": "recorder/get_statistics_metadata",
		"statistic_ids": [
			entity_id
		]
	})

	if meta_response.status != OK:
		return null

	var metadata = meta_response.payload.get("result")

	if not (metadata is Array)||metadata.is_empty():
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

	return {
		"unit": metadata[0]["display_unit_of_measurement"],
		"has_mean": metadata[0]["has_mean"],
		"unit_class": metadata[0]["unit_class"],
		"data": data_response.payload.result[entity_id] if data_response.payload.result.has(entity_id) else []
	}
