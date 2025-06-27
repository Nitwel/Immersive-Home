extends Node

signal player_ready(id: int, duration:float)
signal player_error(id: int, error_message: String)
signal video_end(id: int)


var _plugin_name = "godot_exoplayer"
var _android_plugin

## Store player states: { id: {is_ready: bool, duration: float, error: Dictionary}}
var players : Dictionary = {}
var exoplayer_id_array : Array = []
var current_id : int = 1

func _ready() -> void:
	##load plugin
	if Engine.has_singleton(_plugin_name):
		_android_plugin = Engine.get_singleton(_plugin_name)
		connect_plugin_signals()


func create_exoplayer_instance(android_surface, video_uri) -> int:
	if _android_plugin and android_surface:
		var new_id = current_id
		_android_plugin.createExoPlayerSurface(current_id,video_uri,android_surface)

		players[new_id] = {
			"is_ready": false,
			"duration": -1.0,
			"error": null,
			"surface": android_surface,
			"uri": video_uri
		}


		exoplayer_id_array.append(new_id)
		current_id +=1
		return new_id
	return -1

#region Player Controls

func play(id):
	if _android_plugin:
		_android_plugin.play(id)
func pause(id):
	if _android_plugin:
		_android_plugin.pause(id)

func seekTo(id, positionMs):
	if _android_plugin:
		_android_plugin.seekTo(id, positionMs)

func seekBy(id, deltaMs):
	if _android_plugin:
		_android_plugin.seekBy(id, deltaMs)


## Returns the Playback Position in the current content in ms
func getCurrentPlaybackPosition(id):
	if _android_plugin:
		return _android_plugin.getCurrentPosition(id)

## Returns the duration of the current content in ms
func getVideoDuration(id):
	if is_player_ready(id):
		return players[id].duration
	return -1.0

func setPlayerVolume(id: int, volume: float):
	if _android_plugin:
		_android_plugin.setVolume(id, volume)
func getPlayerVolume(id:int):
	if _android_plugin:
		return _android_plugin.getVolume(id)


#endregion

#region Helpers

func is_player_ready(id: int) -> bool:
	return players.get(id,{}).get("is_ready",false)

func get_player_error(id: int) -> Dictionary:
	return players.get(id,{}).get("error",{})

func release_player(id:int) -> void:
	if _android_plugin and players.has(id):
		_android_plugin.pause(id)
		_android_plugin.releaseExoPlayer(id)
		players.erase(id)
		exoplayer_id_array.erase(id)


func getVideoResolutions(id: int) :
	if _android_plugin and players.has(id):
		var tracks  = _android_plugin.getResolutions(id)
		print("id: ", tracks)
		return tracks

func setVideoResolution(id: int, width : int, height: int):
	if _android_plugin and players.has(id):
		_android_plugin.setResolution(id, width, height)
	pass
#endregion

#region Signal Functions

func connect_plugin_signals() -> void:
	if _android_plugin:
		_android_plugin.connect("on_player_ready",_on_player_ready)
		_android_plugin.connect("on_player_error", _on_player_error)
		_android_plugin.connect("on_video_end", _on_video_end)

func _on_player_ready(id: int, duration: int) -> void:
	if players.has(id):
		players[id].is_ready = true
		players[id].duration = duration
		players[id].error = null
	emit_signal("player_ready",id, duration)

func _on_player_error(id: int, error_message: String) -> void:
	if players.has(id):
		players[id].error = {
			"message" : error_message,
			"timestamp": Time.get_ticks_msec()
		}
	emit_signal("player_error", id, error_message)
#endregion


func _on_video_end(id: int) -> void:
	emit_signal("video_end", id)

func _exit_tree() -> void:
	for id in players.keys():
		release_player(id)
