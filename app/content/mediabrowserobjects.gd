extends Node3D

# see https://developers.home-assistant.io/docs/api/websocket/
# trying to get the media browser data from here, so we can download images
# direct from the HASS as an input for managing images
# https://mr5g.dynamicdevices.co.uk/media-browser/browser/app%2Cmedia-source%3A%2F%2Fimage_upload

const mediacachedir = "user://mediacachedir/"
var mediacachelist = [ ]
@onready var androidcompositionlayer = get_node("../XROrigin3D/OpenXRCompositionLayerQuad")
var exoplayer = null
const exoplayerid = 1

func _ready():
	firstpos = get_child(0).transform
	HomeApi.on_connect.connect(fetch_mediafiles)
	if not DirAccess.dir_exists_absolute(mediacachedir):
		DirAccess.make_dir_absolute(mediacachedir)
	mediacachelist = listdir(mediacachedir)
	print("mediacachelist ", mediacachelist)
	if OS.get_name() == "Android" and Engine.has_singleton("godot_exoplayer"):
		exoplayer = Engine.get_singleton("godot_exoplayer")
		exoplayer.connect("on_player_ready", on_player_ready)
		exoplayer.connect("on_video_end", on_video_end)
		exoplayer.connect("on_player_error", on_player_error)

var video_uri = null
var videoduration_secs = 0
var videoplayervolume = -1
enum VideoStatus {
	EMPTY,
	REQUESTED,
	WORKING,
	ENDED
}
	
var vidstatus : VideoStatus = VideoStatus.EMPTY

var pauseatstart = false
func playvideo(vidname, globalplacement, lpauseatstart=false):
	var video_uri = null
	pauseatstart = lpauseatstart
	for c in mediacachelist:
		if c.containsn(vidname):
			var fc = mediacachedir+c
			var fin = FileAccess.open(fc, FileAccess.READ)
			video_uri = fin.get_path_absolute()
			fin.close()
	print("video_uri ", video_uri)
	$VideoFrame/MessageLabel.visible = false
	$VideoFrame.visible = true
	if globalplacement:
		$VideoFrame.global_transform = globalplacement

	if video_uri.to_lower().ends_with(".jpg"):
		$VideoFrame/VidLengthBar.visible = false
		$VideoFrame/PlayVideoButton.visible = false
		var image = Image.load_from_file(video_uri)
		if not image:
			$VideoFrame/MessageLabel.text = "image not working"
			$VideoFrame/MessageLabel.visible = true
			return
		var mat = $VideoFrame/PhotoMesh.get_surface_override_material(0)
		mat.albedo_texture = ImageTexture.create_from_image(image)
		print(mat.albedo_texture)
		$VideoFrame/PhotoMesh.visible = true
		return

	$VideoFrame/PhotoMesh.visible = false
	$VideoFrame/VidLengthBar.visible = true
	$VideoFrame/PlayVideoButton.visible = true

	androidcompositionlayer.visible = true
	androidcompositionlayer.global_transform = $VideoFrame/CompositionLayerPosition.global_transform
	
	if exoplayer:
		var androidsurface = androidcompositionlayer.get_android_surface()
		if androidsurface:
			exoplayer.createExoPlayerSurface(exoplayerid, video_uri, androidsurface)
			exoplayer.play(exoplayerid)
			vidstatus = VideoStatus.REQUESTED
			$VideoFrame/MessageLabel.text = "loading"
			$VideoFrame/MessageLabel.visible = true
	if not $VideoFrame/MessageLabel.visible:
		$VideoFrame/MessageLabel.text = "not working"
		$VideoFrame/MessageLabel.visible = true

func on_player_ready(id, duration):
	$VideoFrame/MessageLabel.visible = false
	prints("on_player_ready ", id, duration)
	videoduration_secs = duration/1000.0
	vidstatus = VideoStatus.WORKING
	videoplayervolume = exoplayer.getVolume(exoplayerid)
	var vidresolutions  = exoplayer.getResolutions(exoplayerid)
	print("vidresolutions: ", vidresolutions)
	if vidresolutions:
		var splitText = vidresolutions[0].split(" - ")
		var resText = splitText[0]
		var resTextArray = resText.split("x")
		var width : int = int(resTextArray[0])
		var height : int = int(resTextArray[1])
		var hwfac = width*1.0/height
		#$VideoFrame/YellowMesh.scale.x = hwfac
		androidcompositionlayer.quad_size.x = androidcompositionlayer.quad_size.y*hwfac
		print("trying to select res with width: ", width, " and height: ", height)
		exoplayer.setResolution(exoplayerid, width, height)
	if pauseatstart:
		exoplayer.pause(exoplayerid)
		$VideoFrame/PlayVideoButton.visible = true
		$VideoFrame/PlayVideoButton.disabled = false

func _on_play_video_on_button_down():
	if exoplayer:
		exoplayer.play(exoplayerid)
		$VideoFrame/PlayVideoButton.visible = false
		$VideoFrame/PlayVideoButton.disabled = true


func on_video_end(id):
	print("on_video_end ", id)
	$VideoFrame/MessageLabel.text = "done"
	$VideoFrame/MessageLabel.visible = true
	
func on_player_error(id, msg):
	prints("on_player_error ", id, msg)
	$VideoFrame/MessageLabel.text = "Error: "+msg
	$VideoFrame/MessageLabel.visible = true

func stopvideo():
	if vidstatus != VideoStatus.EMPTY:
		$VideoFrame.visible = false
		androidcompositionlayer.visible = false
		vidstatus = VideoStatus.EMPTY
		if exoplayer:
			exoplayer.releaseExoPlayer(exoplayerid)

func updateplaybackposition():
	if vidstatus == VideoStatus.WORKING:
		var current_time = exoplayer.getCurrentPosition(exoplayerid) / 1000.0
		$VideoFrame/VidLengthBar.scale.x = current_time/max(1.0, videoduration_secs)

func listdir(d):
	var res = [ ]
	var dir = DirAccess.open(d)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		res.push_back(file_name)
		file_name = dir.get_next()
	return res
	
func fetch_mediafiles():
	if not HomeApi.has_connected():
		return
	var serverbase = Store.settings.state.url.replace("wss://", "https://").replace(":8123", "")
	# serverbase = "https://mr5g.dynamicdevices.co.uk"
	print("serverbase ", serverbase) # "https://mr5g.dynamicdevices.co.uk"
	var jmediacontent = { "type": "media_source/browse_media", "media_content_id":"media-source://media_source" }
	var response = await HomeApi.api.connection.send_request_packet(jmediacontent)
	if not (response.payload.get("success") and response.payload.type == "result"):
		print("fetch_mediaimages failed")
		return
	var mediabrowserobjects = response.payload.result.children
	for c in mediabrowserobjects:
		if not (c.media_class == "image" or c.media_class == "video"):
			continue
		if mediacachelist.has(c.title):
			continue
		var jmediaresolve = { "type":"media_source/resolve_media","media_content_id":c.media_content_id }
		var response2 = await HomeApi.api.connection.send_request_packet(jmediaresolve)
		if not (response2.payload.get("success") and response2.payload.get("type") == "result"):
			continue
		var url = response2.payload.result.url
		var mimetype = response2.payload.result.mime_type
		var uurl = serverbase+url
		var http_request = HTTPRequest.new()
		add_child(http_request)
		var df = mediacachedir+c.title
		http_request.download_file = df
		var error = http_request.request(uurl)
		print("uurl ", uurl)
		print("asdad ", [df, http_request.download_file])
		if error != OK:
			print("An error occurred in the HTTP request.")
			continue
		var params: Array = await http_request.request_completed  # result, response_code, headers, body
		print(" responsecode ", params[1])
		print(" headers ", params[2])
		print(" filelength ", len(params[3]))
		http_request.queue_free()
		mediacachelist = listdir(mediacachedir)


		#var fout = FileAccess.open(mediacachedir+c.title, FileAccess.WRITE)
		#params. 
				
#	var img = Image.new()
#	img.load_jpg_from_buffer(params[3])


			
#	for imageurl in imageurls:
#		await fetchurldata(imageurl)



var firstpos = null
var ngg = 1

func fetchurldata(uurl):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	#http_request.request_completed.connect(self._http_request_completed)
	var error = http_request.request(uurl)
	if error != OK:
		print("An error occurred in the HTTP request.")
		return
	var params: Array = await http_request.request_completed  #result, response_code, headers, body
	print("headers ", params[2])
	var img = Image.new()
	img.load_jpg_from_buffer(params[3])
	img.generate_mipmaps()
	var xrat = img.get_width()*1.0/img.get_height()
	var gg = load("res://content/mediabrowserbox.tscn").instantiate()
	gg.get_node("MeshInstance3D").mesh.size.x = xrat
	gg.get_node("CollisionShape3D").shape.size.x = xrat
	gg.transform = Transform3D(firstpos.basis, firstpos.origin + firstpos.basis.z*(ngg*0.3) + firstpos.basis.x*(-ngg*0.1))
	ngg += 1
	var mat = gg.get_node("MeshInstance3D").get_surface_override_material(0)
	mat.albedo_texture = ImageTexture.create_from_image(img)
	add_child(gg)
