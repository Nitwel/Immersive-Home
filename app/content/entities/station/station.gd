extends Entity

const Entity = preload ("../entity.gd")

@onready var station_node = preload("res://content/entities/station/station.tscn")
@onready var text_edit_button = $TextEditButton
@onready var input = $Input
@onready var station_text = $StationText
@onready var station_icon = $StationIcon

var station_name = "Blank name"
var next_station = null
var previous_station = null
var station_text_R = R.state("Blank Station")
var next_stations = ""
var mqtt = null
var dev_state = false
var station_id = "unknown"

var vidname = ""
var vidplace = null
var nextstations = [ ]

var event = EventPointer

func _ready():
	super()
	station_icon.visible = false
	$NextButtons/NextButtonContainer/NextButton.on_button_down.connect(nextbuttondown.bind(0))
	$NextButtons/NextButtonContainer2/NextButton.on_button_down.connect(nextbuttondown.bind(1))
	
	# Our new text edit button
	text_edit_button.on_button_down.connect(text_edit)
	
	get_node("/root/Main/").dev_state_changed.connect(_dev_state_changed)
	R.effect(func(_arg):
		if station_text_R.value != null: 
			station_text.text = station_text_R.value
	)
	
	get_node("/root/Main/").reset.connect(_reset)
	
	# These following things need to wait for everything to get loaded,
	# so i've added a manual delay for now. - PCJ
	await get_tree().create_timer(0.1).timeout

	for x in Store.house.state.entities:
		#print("stateentities ", var_to_str(global_position) + var_to_str(x.position))
		if global_position.is_equal_approx(x.position):
			#print(x._node_iid)
			x._node_iid = get_instance_id()
			#print(x._node_iid)

	await HomeApi.watch_state(entity_id, set_options)
	
	if next_station != null:
		station_icon.visible = true
	else:
		station_icon.visible = false
	if previous_station != null and previous_station.station_icon.visible:
		station_icon.visible = false
	mqtt = get_node("/root/Main/MQTT")

# When we bring up/hide our input that we use to change the body text
func text_edit():
	input.visible = !input.visible
	_state_update()

func _on_activate_button_on_button_down():
	activate(null, true)

func setvisibility(visibility):
	$MeshInstance3D.visible = visibility
	$CollisionShape3D.disabled = not visibility
	$StationText.visible = visibility
	if not visibility:
		input.visible = false
		$StationIcon.visible = false
	processnextbuttonvisibilities(visibility)
	
func processstationtext():
	nextstations = [ ]
	var ns = next_stations.split(" ")
	for nsi in ns:
		if nsi:
			var nextstation = get_node("/root/Main/House").find_station_byid(nsi)
			var stationname = nextstation.station_name if nextstation else ""
			nextstations.append({"station":nextstation, "stationname":stationname, 
								 "label":"Next", "icon":"arrow_forward", "stationid":nsi})
	var text = station_text_R.value
	vidname = ""
	vidplace = null
	var regex = RegEx.new()
	regex.compile("(?<coloncommand>Video[^:]*|NextButtonDef): (?<colonvalue>\\S+)\\s*")
	var result = regex.search_all(text)
	for cc in result:
		var coloncommand = cc.get_string("coloncommand")
		var colonvalue = cc.get_string("colonvalue")
		if coloncommand.begins_with("Video"):
			vidname = cc.get_string("colonvalue")
			vidplace = get_node_or_null(coloncommand)
			if not vidplace:
				print("Vid place ", coloncommand, " not found")
				vidplace = get_node("VideoPlaceTop")
		elif coloncommand == "NextButtonDef":
			var nextbuttonval = colonvalue.split(",")
			#print("NextButtonDef working with ", nextbuttonval)
			#var DD = get_node("/root/Main/House").allstationsoptions()
			#print(DD)
			if len(nextbuttonval) == 3:
				for nss in nextstations:
					if len(nextbuttonval[0]) == 0 or nss["stationname"].find(nextbuttonval[0]) != -1:
						if nextbuttonval[1]:
							nss["label"] = nextbuttonval[1]
						if nextbuttonval[2]:
							nss["icon"] = nextbuttonval[2]
			else:
				print("NextButtonDef not 3 csvs: ", colonvalue)

		else:
			print("unknown colon command: ", coloncommand, ": ", colonvalue)
	station_text.text = text  # should be text.subs(regex, "")

func processnextbuttonvisibilities(visibility):
	for i in range($NextButtons.get_child_count()):
		var nextbuttoncontainer = $NextButtons.get_child(i)
		if i < len(nextstations) and visibility:
			nextbuttoncontainer.updatenextstationdata(nextstations[i])
		else:
			nextbuttoncontainer.updatenextstationdata(null)

func activate(frompt, hiderest):
	if hiderest:
		for room in get_node("/root/Main/House/Rooms").get_children():
			for entity in room.get_node("Entities").get_children():
				if entity.entity_id.split(".")[0] == "text": # station entity
					if entity != self:
						entity.setvisibility(false)

	processstationtext()
	setvisibility(true)

	await get_tree().process_frame  
	var laabb = $StationText.get_aabb()
	if laabb:
		print("sss ", laabb)
		$MeshInstance3D.position = laabb.get_center() + Vector3($StationText.position.x, $StationText.position.y, 0.0)
		$MeshInstance3D.mesh.size = Vector2(laabb.size.x+0.04, laabb.size.y+0.04)
		$CollisionShape3D.position = $MeshInstance3D.position
		$CollisionShape3D.shape.size = Vector3($MeshInstance3D.mesh.size.x, $MeshInstance3D.mesh.size.y, $CollisionShape3D.shape.size.z)
		$NextButtons.position = $MeshInstance3D.position + Vector3($MeshInstance3D.mesh.size.x/2 - 0.02, -$MeshInstance3D.mesh.size.y/2 - 0.03, 0.0)

	if vidname and vidplace:
		get_node("/root/Main/MediaBrowserObjects").playvideo(vidname, vidplace.global_transform, true)

	if frompt != null:
		var tween : Tween = get_node("/root/Main/MagicTinsel").gotinselpttopt(frompt, $KeyboardPlace.global_position)
		await tween.finished

	var ns = next_stations.split(" ")
	next_station = null
	if ns and ns[0]:
		next_station = get_node("/root/Main/House").find_station_byid(ns[0])
	
func nextbuttondown(nextbuttonnumber):
	var nss = nextstations[nextbuttonnumber]["station"]
	setvisibility(false)
	if nss != null:
		get_node("/root/Main/MediaBrowserObjects").stopvideo()
		var bpos = ($NextButtons/NextButtonContainer/NextButton.global_position if nextbuttonnumber == 0 else $NextButtons/NextButtonContainer2/NextButton.global_position)
		nss.activate(bpos, false)
		App.controller_right.get_node("hand_r/Compass Base").set_target(next_station)
	else:
		App.controller_right.get_node("hand_r/Compass Base").set_target(null)

func _reset():
	setvisibility(true)
	_state_update()

func _state_update() -> void:
	if next_station != null:
		station_icon.visible = true
		App.controller_right.get_node("hand_r/Compass Base").get_script().set_target(self)
	else:
		station_icon.visible = false
	if previous_station != null and previous_station.station_icon.visible:
		station_icon.visible = false

# Change our body text with the input element we just brought up
func _on_input_on_text_changed(text: String) -> void:
	station_text.text = text
	#_text_R.set_state(entity_id, "_text", {"_text": text})
	station_text_R.value = text

func get_options():
	return {
		"station_text": station_text_R.value,
		"station_name": station_name,
		"next_stations": next_stations,
		"station_id": station_id
	}

func set_options(options):
	if options.has("station_text"): 
		station_text_R.value = options["station_text"]
	if options.has("station_name"):
		station_name = options["station_name"]
		$FriendlyName.text = station_name
	if options.has("next_stations"):
		next_stations = options["next_stations"]
	if options.has("station_id"):
		station_id = options["station_id"]

func _dev_state_changed(value):
	#text_edit_button.visible = value
	#text_edit_button.disabled = not value
	$Devmarker.visible = value
	$ActivateButton.visible = value
	$ActivateButton.disabled = not value
	$FriendlyName.visible = value
	if value:
		$FriendlyName.text = station_name
		processstationtext()
	processnextbuttonvisibilities($MeshInstance3D.visible)
	for i in range(min(len(nextstations), $NextButtons.get_child_count())):
		var nss = nextstations[i] if value else null
		$NextButtons.get_child(i).setpreviewtrail(nss)
	
