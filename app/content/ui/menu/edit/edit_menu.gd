extends Node3D
## Device and entity picker: room chips on top, the devices of the selected room
## on the left and the entities of the selected device on the right. Searching
## matches entities across all devices.

const DeviceUtils = preload ("./device_utils.gd")
const DeviceItem = preload ("./device_item.gd")
const EntityRow = preload ("./entity_row.gd")
const ButtonScene = preload ("res://content/ui/components/button/button.tscn")

const ALL = "__all__"
const NO_ROOM = "__none__"

const DEVICE_SIZE = Vector3(0.14, 0.028, 0.01)
const DEVICE_STEP = 0.033
const DEVICES_PER_PAGE = 6
const ENTITY_SIZE = Vector3(0.225, 0.028, 0.01)
const ENTITY_STEP = 0.032
const ENTITIES_PER_PAGE = 5
const CHIP_HEIGHT = 0.022
const CHIP_GAP = 0.005
const CHIP_FONT = 9
const CHIP_PADDING = 0.014
const CHIPS_WIDTH = 0.38
const TITLE_FONT = 13
const SUBTITLE_FONT = 8

@onready var search_input: Input3D = $Input
@onready var chips_root: Node3D = $Chips
@onready var devices_root: Node3D = $Devices
@onready var device_pagination: Pagination3D = $DevicePagination
@onready var back_button: Button3D = $Detail/BackButton
@onready var detail_title: Label3D = $Detail/Title
@onready var detail_subtitle: Label3D = $Detail/Subtitle
@onready var entities_root: Node3D = $Detail/Entities
@onready var entity_pagination: Pagination3D = $Detail/EntityPagination
@onready var empty_label: Label3D = $Detail/EmptyLabel
@onready var spawn_sound: AudioStreamPlayer3D = $SpawnSound

var search = R.state("")
var selected_area = R.state(ALL)
var selected_device = R.state(null)
var device_page = R.state(0)
var entity_page = R.state(0)
var chip_offset = R.state(0)

var _chip_buttons := {}
var _device_items := {}
var _entity_rows := {}
var _area_picked := false

func _ready():
	## Devices with at least one placeable entity, as DeviceUtils.device_view()
	var devices = R.computed(func(_arg):
		var result=[]
		for device in Store.devices.state.devices:
			var view=DeviceUtils.device_view(device)
			if view != null:
				result.append(view)
		return result
	)

	var words = R.computed(func(_arg):
		return DeviceUtils.search_words(search.value)
	)

	var areas = R.computed(func(_arg):
		var counts={}
		var no_room=0
		for device in devices.value:
			if _has_area(device):
				counts[device["area"]]=counts.get(device["area"], 0) + 1
			else:
				no_room += 1

		var names=counts.keys()
		names.sort_custom(func(a, b): return a.to_lower() < b.to_lower())

		var result=[ {"key": ALL, "label": "All", "count": devices.value.size()}]
		for area_name in names:
			result.append({"key": area_name, "label": area_name, "count": counts[area_name]})
		if no_room > 0:
			result.append({"key": NO_ROOM, "label": "No room", "count": no_room})
		return result
	)

	var filtered = R.computed(func(_arg):
		if !words.value.is_empty():
			return devices.value.filter(func(device): return _device_matches(device, words.value))

		var area=selected_area.value
		if area == ALL:
			return devices.value
		if area == NO_ROOM:
			return devices.value.filter(func(device): return !_has_area(device))
		# Sort by the name shown in the list, which drops the room prefix
		var in_area=devices.value.filter(func(device): return device["area"] == area)
		in_area.sort_custom(func(a, b):
			return DeviceUtils.strip_prefix(a["name"], area).to_lower() < DeviceUtils.strip_prefix(b["name"], area).to_lower()
		)
		return in_area
	)

	## The device whose entities are shown. Null while showing search results.
	var current_device = R.computed(func(_arg):
		for device in filtered.value:
			if device["id"] == selected_device.value:
				return device

		if !words.value.is_empty()||filtered.value.is_empty():
			return null
		return filtered.value[0]
	)

	## Entries shown on the right: {id, name, context}
	var entity_entries = R.computed(func(_arg):
		var device=current_device.value
		if device != null:
			return device["entities"].map(func(entity):
				return {"id": entity["id"], "name": DeviceUtils.strip_prefix(entity["name"], device["name"]), "context": ""}
			)

		if words.value.is_empty():
			return []

		var supported=[]
		var unsupported=[]
		for match_device in filtered.value:
			for entity in match_device["entities"]:
				if DeviceUtils.matches(words.value, _entity_haystack(entity, match_device)):
					var entry={"id": entity["id"], "name": entity["name"], "context": match_device["name"]}
					if EntityFactory.is_supported(entity["id"]):
						supported.append(entry)
					else:
						unsupported.append(entry)
		return supported + unsupported
	)

	var placed = R.computed(func(_arg):
		var ids={}
		for entity in Store.house.state.entities:
			ids[entity["id"]]=true
		return ids
	)

	var device_pages = R.computed(func(_arg):
		return maxi(1, ceili(filtered.value.size() / float(DEVICES_PER_PAGE)))
	)

	var visible_devices = R.computed(func(_arg):
		var page=clampi(device_page.value, 0, device_pages.value - 1)
		return filtered.value.slice(page * DEVICES_PER_PAGE, (page + 1) * DEVICES_PER_PAGE)
	)

	var entity_pages = R.computed(func(_arg):
		return maxi(1, ceili(entity_entries.value.size() / float(ENTITIES_PER_PAGE)))
	)

	var visible_entities = R.computed(func(_arg):
		var page=clampi(entity_page.value, 0, entity_pages.value - 1)
		return entity_entries.value.slice(page * ENTITIES_PER_PAGE, (page + 1) * ENTITIES_PER_PAGE)
	)

	# --- Search ---

	R.bind(search_input, "text", search, search_input.on_text_changed)

	search_input.on_text_changed.connect(func(text):
		selected_device.value=null
		device_page.value=0
		entity_page.value=0
		if text.strip_edges() != "":
			selected_area.value=ALL
			chip_offset.value=0
	)

	# --- Room chips ---

	R.effect(func(_arg):
		_build_chips(areas.value, chip_offset.value)
		_untracked(func(): _sync_chips(selected_area.value))
	)

	R.effect(func(_arg):
		_sync_chips(selected_area.value)
	)

	R.effect(func(_arg):
		if !_area_picked&&devices.value.size() > 0:
			_area_picked=true
			_pick_initial_area.call_deferred(areas)
	)

	# --- Device list ---

	R.bind(device_pagination, "pages", device_pages)
	R.bind(device_pagination, "page", device_page, device_pagination.on_page_changed)

	R.effect(func(_arg):
		_set_shown(device_pagination, device_pages.value > 1)
	)

	R.effect(func(_arg):
		var searching=!words.value.is_empty()
		var area=selected_area.value

		_clear(devices_root)
		_device_items={}

		var index=0
		for device in visible_devices.value:
			var display_name=device["name"]
			if !searching&&area != ALL&&area != NO_ROOM:
				display_name=DeviceUtils.strip_prefix(display_name, area)

			var item=DeviceItem.new(device, display_name, DEVICE_SIZE)
			item.position=Vector3(DEVICE_SIZE.x / 2, -DEVICE_SIZE.y / 2 - index * DEVICE_STEP, 0)
			var device_id=device["id"]
			item.on_select.connect(func(): _select_device(device_id))
			devices_root.add_child(item)
			_device_items[device_id]=item
			index += 1

		_untracked(func(): _sync_device_selection(current_device.value))
	)

	R.effect(func(_arg):
		_sync_device_selection(current_device.value)
	)

	# --- Detail column ---

	R.bind(entity_pagination, "pages", entity_pages)
	R.bind(entity_pagination, "page", entity_page, entity_pagination.on_page_changed)

	R.effect(func(_arg):
		_set_shown(entity_pagination, entity_pages.value > 1)
	)

	back_button.on_button_up.connect(func():
		selected_device.value=null
		entity_page.value=0
	)

	R.effect(func(_arg):
		var device=current_device.value
		var searching=!words.value.is_empty()
		var with_back=searching&&device != null
		var title=""
		var subtitle=""
		var empty=""

		if Store.devices.state.devices.is_empty():
			empty="Connect to Home Assistant to see your devices here."
		elif device != null:
			title=device["name"]
			var parts=[]
			if device["details"] != "":
				parts.append(device["details"])
			if _has_area(device):
				parts.append(device["area"])
			subtitle=" · ".join(parts)
		elif searching:
			var count=entity_entries.value.size()
			title="Results"
			subtitle="%d %s match \"%s\"" % [count, "entity" if count == 1 else "entities", search.value.strip_edges()]
			if count == 0:
				empty="Nothing matches \"%s\"." % search.value.strip_edges()
		else:
			empty="No devices in this room."

		var offset=0.026 if with_back else 0.0
		_set_shown(back_button, with_back)
		detail_title.position.x=offset
		detail_subtitle.position.x=offset
		detail_title.text=DeviceUtils.fit_text(title, TITLE_FONT, ENTITY_SIZE.x - offset)
		detail_subtitle.text=DeviceUtils.fit_text(subtitle, SUBTITLE_FONT, ENTITY_SIZE.x - offset)
		empty_label.text=empty
		empty_label.visible=empty != ""
	)

	R.effect(func(_arg):
		_clear(entities_root)
		_entity_rows={}

		var index=0
		for entry in visible_entities.value:
			var row=EntityRow.new(entry["id"], entry["name"], entry["context"], ENTITY_SIZE)
			row.position=Vector3(ENTITY_SIZE.x / 2, -ENTITY_SIZE.y / 2 - index * ENTITY_STEP, 0)
			var entity_id=entry["id"]
			row.on_place.connect(func(): place_entity(entity_id))
			entities_root.add_child(row)
			_entity_rows[entity_id]=row
			index += 1

		_untracked(func(): _sync_placed(placed.value))
	)

	R.effect(func(_arg):
		_sync_placed(placed.value)
	)

# --- Grab to place ---
# Holding grip on an entity row pulls a preview out of the menu. Releasing it
# inside a room places the entity there. The thumbstick pushes it further away
# or pulls it closer, like moving other objects.

const PanelScene = preload ("res://content/ui/components/panel/panel.tscn")
const GHOST_SIZE = 0.07

var _drag = null

func _on_grab_down(event: EventPointer):
	var row = _row_from(event.target)
	if row == null||!row.supported||_drag != null:
		return

	# Keep the menu itself from being moved by this grab
	event.bubbling = false

	var origin = event.ray.global_position
	var distance = origin.distance_to(event.ray.get_collision_point()) - 0.05

	_drag = {
		"entity_id": row.entity_id,
		"initiator": event.initiator,
		"distance": max(distance, 0.1),
		"ghost": _create_ghost(row),
		"valid": false,
	}
	EventSystem.on_action_value.connect(_on_drag_action)
	_update_drag(event.ray)

func _on_grab_move(event: EventPointer):
	if _drag == null||event.initiator != _drag["initiator"]:
		return
	event.bubbling = false
	_update_drag(event.ray)

func _on_grab_up(event: EventPointer):
	if _drag == null||event.initiator != _drag["initiator"]:
		return
	event.bubbling = false

	var drag = _drag
	_end_drag()

	if drag["valid"]:
		place_entity(drag["entity_id"], drag["position"])

func _on_drag_action(event: EventAction):
	if _drag == null||event.name != "primary"||event.initiator != _drag["initiator"]:
		return
	_drag["distance"] = clamp(_drag["distance"] + event.value.y * 0.05, 0.1, 10.0)

func _update_drag(ray: RayCast3D):
	var direction = (ray.global_transform.basis * ray.target_position).normalized()
	var point = ray.global_position + direction * _drag["distance"]
	var ghost: Node3D = _drag["ghost"]
	ghost.global_position = point

	var camera = App.camera if App.camera != null else get_viewport().get_camera_3d()
	if camera != null&&!camera.global_position.is_equal_approx(point):
		ghost.look_at(camera.global_position, Vector3.UP, true)

	var valid = App.house != null&&App.house.find_room_at(point) != null
	_drag["position"] = point
	_drag["valid"] = valid
	ghost.get_node("Panel").active = !valid
	ghost.get_node("Hint").text = "Release to place" if valid else "Not in a room"

func _end_drag():
	if _drag == null:
		return
	if EventSystem.on_action_value.is_connected(_on_drag_action):
		EventSystem.on_action_value.disconnect(_on_drag_action)
	if is_instance_valid(_drag["ghost"]):
		_drag["ghost"].queue_free()
	_drag = null

func _create_ghost(row) -> Node3D:
	var ghost = Node3D.new()

	var panel = PanelScene.instantiate()
	panel.name = "Panel"
	panel.size = Vector2(GHOST_SIZE, GHOST_SIZE)
	panel.corner_radius = GHOST_SIZE
	ghost.add_child(panel)

	var icon = DeviceUtils.make_label(44, 1.0, HORIZONTAL_ALIGNMENT_CENTER, true)
	icon.text = EntityFactory.get_entity_icon(DeviceUtils.domain_of(row.entity_id))
	icon.position = Vector3(0, 0, 0.001)
	ghost.add_child(icon)

	var title = DeviceUtils.make_label(10, 1.0, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = DeviceUtils.fit_text(row.display_name, 10, 0.16)
	title.position = Vector3(0, -GHOST_SIZE / 2 - 0.01, 0.001)
	ghost.add_child(title)

	var hint = DeviceUtils.make_label(8, 0.75, HORIZONTAL_ALIGNMENT_CENTER)
	hint.name = "Hint"
	hint.position = Vector3(0, -GHOST_SIZE / 2 - 0.023, 0.001)
	ghost.add_child(hint)

	var parent = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
	parent.add_child(ghost)
	return ghost

func _row_from(node):
	while node != null&&node != self:
		if node.get_script() == EntityRow:
			return node
		node = node.get_parent()
	return null

func _exit_tree():
	_end_drag()

## Spawns the entity in the room at [param at] (the menu's position by default).
## Returns the created entity or null.
func place_entity(entity_id: String, at=null):
	if App.house == null:
		EventSystem.notify("Entities can only be placed inside a room", EventNotify.Type.INFO)
		return null

	var entity = App.house.create_entity(entity_id, global_position if at == null else at)

	if typeof(entity) == TYPE_BOOL&&entity == false:
		EventSystem.notify("Entity is not in Room", EventNotify.Type.INFO)
		return null

	if entity == null:
		EventSystem.notify("This Entity is not supported yet", EventNotify.Type.INFO)
		return null

	spawn_sound.play()
	return entity

func _select_area(key: String):
	if search.value != "":
		search.value = ""
	selected_area.value = key
	selected_device.value = null
	device_page.value = 0
	entity_page.value = 0

func _select_device(device_id: String):
	selected_device.value = device_id
	entity_page.value = 0

## Selects the area matching the room the user is standing in.
func _pick_initial_area(areas):
	if App.house == null||App.camera == null:
		return

	var room = App.house.find_room_at(App.camera.global_position)
	if room == null:
		return

	var room_name = String(room.name).to_lower()
	var list = areas.value
	for index in range(list.size()):
		if list[index]["key"] != ALL&&list[index]["key"] != NO_ROOM&&list[index]["key"].to_lower() == room_name:
			selected_area.value = list[index]["key"]
			chip_offset.value = _chip_offset_showing(list, index)
			return

# --- Chips ---

func _chip_text(chip: Dictionary) -> String:
	return "%s  %d" % [chip["label"], chip["count"]]

func _chip_widths(list: Array) -> Array:
	return list.map(func(chip): return DeviceUtils.text_width(_chip_text(chip), CHIP_FONT) + CHIP_PADDING)

## Index of the first chip that is visible when the window starts at [param offset],
## plus the index of the last one. Returns [first, last].
func _chip_window(widths: Array, offset: int) -> Array:
	var x = (CHIP_HEIGHT + CHIP_GAP) if offset > 0 else 0.0
	var last = offset
	for index in range(offset, widths.size()):
		var reserve = (CHIP_HEIGHT + CHIP_GAP) if index < widths.size() - 1 else 0.0
		if index > offset&&x + widths[index] > CHIPS_WIDTH - reserve:
			break
		x += widths[index] + CHIP_GAP
		last = index
	return [offset, last]

## Smallest window offset that still shows the chip at [param index].
func _chip_offset_showing(list: Array, index: int) -> int:
	var widths = _chip_widths(list)
	for offset in range(0, index + 1):
		if _chip_window(widths, offset)[1] >= index:
			return offset
	return index

func _build_chips(list: Array, offset: int):
	_clear(chips_root)
	_chip_buttons = {}

	offset = clampi(offset, 0, maxi(0, list.size() - 1))
	var widths = _chip_widths(list)
	var last = _chip_window(widths, offset)[1]
	var x = 0.0

	if offset > 0:
		var previous = _arrow_button("chevron_left", x)
		previous.on_button_up.connect(func():
			var target=offset
			while target > 0&&_chip_window(widths, target - 1)[1] >= offset - 1:
				target -= 1
			chip_offset.value=target
		)
		x += CHIP_HEIGHT + CHIP_GAP

	for index in range(offset, last + 1):
		var chip = list[index]
		var button = ButtonScene.instantiate()
		button.size = Vector3(widths[index], CHIP_HEIGHT, 0.01)
		button.font_size = CHIP_FONT
		button.label = _chip_text(chip)
		button.toggleable = true
		button.position = Vector3(x + widths[index] / 2, 0, 0)
		var key = chip["key"]
		button.on_button_down.connect(func(): _select_area(key))
		chips_root.add_child(button)
		_chip_buttons[key] = button
		x += widths[index] + CHIP_GAP

	if last < list.size() - 1:
		var next = _arrow_button("chevron_right", CHIPS_WIDTH - CHIP_HEIGHT)
		next.on_button_up.connect(func(): chip_offset.value=last + 1)

func _arrow_button(icon_name: String, x: float) -> Button3D:
	var button = ButtonScene.instantiate()
	button.size = Vector3(CHIP_HEIGHT, CHIP_HEIGHT, 0.01)
	button.icon = true
	button.label = icon_name
	button.position = Vector3(x + CHIP_HEIGHT / 2, 0, 0)
	chips_root.add_child(button)
	return button

func _sync_chips(area: String):
	for key in _chip_buttons:
		var button = _chip_buttons[key]
		button.active = key == area
		button.disabled = key == area

# --- Devices and entities ---

func _sync_device_selection(device):
	for device_id in _device_items:
		_device_items[device_id].selected = device != null&&device["id"] == device_id

func _sync_placed(placed_ids: Dictionary):
	for entity_id in _entity_rows:
		_entity_rows[entity_id].placed = placed_ids.has(entity_id)

func _has_area(device: Dictionary) -> bool:
	return device["area"] != null&&str(device["area"]) != ""

func _entity_haystack(entity: Dictionary, device: Dictionary) -> String:
	return "%s %s %s %s" % [entity["name"], entity["id"], device["name"], device["area"] if _has_area(device) else ""]

func _device_matches(device: Dictionary, words: Array) -> bool:
	if DeviceUtils.matches(words, "%s %s %s" % [device["name"], device["area"] if _has_area(device) else "", device["details"]]):
		return true

	for entity in device["entities"]:
		if DeviceUtils.matches(words, _entity_haystack(entity, device)):
			return true
	return false

# --- Helpers ---

func _clear(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

## Detaches hidden nodes so their buttons can't be hit by the pointer ray.
func _set_shown(node: Node3D, shown: bool):
	if !node.has_meta("home_parent"):
		node.set_meta("home_parent", node.get_parent())

	if shown&&node.get_parent() == null:
		node.get_meta("home_parent").add_child(node)
	elif !shown&&node.get_parent() != null:
		node.get_parent().remove_child(node)

func _untracked(callable: Callable):
	var graph = RdotGraph.getInstance()
	var previous = graph.setActiveConsumer(null)
	callable.call()
	graph.setActiveConsumer(previous)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for node in [back_button, device_pagination, entity_pagination]:
			if is_instance_valid(node)&&node.get_parent() == null:
				node.free()
