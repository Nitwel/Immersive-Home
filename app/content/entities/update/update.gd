extends "../info_card.gd"
## update: installed and latest version, release summary, and Install / Skip buttons
## while an update is available. Shows the progress while installing.

## UpdateEntityFeature flags
const FEATURE_INSTALL = 1
const FEATURE_PROGRESS = 4

var install_button: Button3D
var install_caption: Label3D
var skip_button: Button3D
var skip_caption: Label3D
var latest_version = null

func _init():
	card_width = 0.26

func _build():
	install_button = UI.icon_button(self, "download", Vector3.ZERO, 0.04)
	install_caption = UI.label(self, "Install", 12, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
	skip_button = UI.icon_button(self, "skip_next", Vector3.ZERO, 0.04)
	skip_caption = UI.label(self, "Skip", 12, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
	install_button.on_button_up.connect(func(): HomeApi.set_state(entity_id, "install"))
	skip_button.on_button_up.connect(func(): HomeApi.set_state(entity_id, "skip"))

func _show(_state: String, attributes: Dictionary):
	var installed = attributes.get("installed_version")
	latest_version = attributes.get("latest_version")
	# in_progress is a bool; older Home Assistant versions sent the percentage there instead.
	var in_progress = attributes.get("in_progress")
	var progress = attributes.get("update_percentage")
	if progress == null and (in_progress is int or in_progress is float):
		progress = in_progress
	var installing = in_progress == true or progress != null

	icon.value = "system_update" if state == "on" else "check_circle"
	if installing:
		value_label.text = "Installing… %d %%" % int(progress) if progress != null else "Installing…"
	elif state == "on":
		value_label.text = "Update available"
	elif state == "off":
		value_label.text = "Up to date"
	else:
		value_label.text = state.capitalize()

	var lines = []
	if state == "on" and installed != null and latest_version != null:
		lines.append("%s → %s" % [installed, latest_version])
	elif installed != null:
		lines.append("Version %s" % installed)
	var summary = attributes.get("release_summary")
	if state == "on" and summary != null and str(summary) != "":
		# The summary can be long Markdown; keep the first lines.
		var text = str(summary).strip_edges()
		lines.append(text.substr(0, 140) + ("…" if text.length() > 140 else ""))
	detail_label.text = "\n".join(lines)

	var features = UI.features_of(attributes, FEATURE_INSTALL)
	var can_install = state == "on" and (features & FEATURE_INSTALL) != 0
	for node in [install_button, skip_button]:
		UI.set_shown(node, can_install)
		node.disabled = installing
		UI.dim_button(node, installing)
	install_caption.visible = can_install
	skip_caption.visible = can_install

func _layout_extra(y: float) -> float:
	if not install_button.visible:
		return y
	for entry in [[install_button, install_caption, -0.03], [skip_button, skip_caption, 0.03]]:
		entry[0].position = Vector3(entry[2], y - 0.025, 0)
		entry[1].position = Vector3(entry[2], y - 0.054, 0)
	return y - 0.062
