extends "../info_card.gd"
## zone: how many people are in the zone (its state) and its radius.

func _init():
	card_width = 0.2

func _show(_state: String, attributes: Dictionary):
	icon.value = "location_on"
	if state.is_valid_int():
		var count = int(state)
		value_label.text = "%d %s" % [count, "person" if count == 1 else "people"]
	else:
		value_label.text = state.capitalize()

	var lines = []
	if attributes.get("radius") != null:
		lines.append("Radius %d m" % int(attributes["radius"]))
	if attributes.get("passive") == true:
		lines.append("Passive")
	detail_label.text = " · ".join(lines)
