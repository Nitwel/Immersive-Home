extends "../info_card.gd"
## todo: the open items of a to-do list (shopping list, chores, ...). The state is
## the number of open items; the items themselves are fetched with HomeApi.get_todo_items.

const MAX_ITEMS = 8
const ROW_HEIGHT = 0.024

## One [checkbox icon, text] label pair per shown item.
var rows: Array = []
## Bumped on every fetch, so a slow older response doesn't overwrite a newer one.
var _fetch_id := 0

func _init():
	card_width = 0.24

func _build():
	for i in MAX_ITEMS:
		var box = UI.label(self, "check_box_outline_blank", 18, Vector3.ZERO, HORIZONTAL_ALIGNMENT_CENTER, true)
		var text = UI.label(self, "", 16, Vector3.ZERO)
		rows.append([box, text])

func _show(_state: String, _attributes: Dictionary):
	icon.value = "checklist"
	value_label.text = ""
	if UI.is_unavailable(state):
		detail_label.text = state.capitalize()
	elif state.is_valid_int():
		var count = int(state)
		detail_label.text = "Nothing to do" if count == 0 else "%d open item%s" % [count, "" if count == 1 else "s"]
	_fetch_items()

func _fetch_items():
	_fetch_id += 1
	var fetch_id = _fetch_id
	var items = await HomeApi.get_todo_items(entity_id)
	if fetch_id != _fetch_id or not is_inside_tree():
		return
	_show_items(items if items is Array else [])

func _show_items(items: Array):
	# Open items first, then a few completed ones.
	var open = items.filter(func(item): return item.get("status") != "completed")
	var done = items.filter(func(item): return item.get("status") == "completed")
	var shown = (open + done).slice(0, MAX_ITEMS)
	# Too many open items: the last row says how many more there are.
	var more = open.size() - (MAX_ITEMS - 1) if open.size() > MAX_ITEMS else 0
	if more > 0:
		shown = open.slice(0, MAX_ITEMS - 1)

	for i in MAX_ITEMS:
		var has_row = i < shown.size()
		rows[i][0].visible = has_row
		rows[i][1].visible = has_row
		if not has_row:
			continue
		var completed = shown[i].get("status") == "completed"
		var summary = str(shown[i].get("summary", ""))
		var due = UI.parse_timestamp(shown[i].get("due"))
		if due >= 0 and not completed:
			summary += " · " + UI.format_day(due)
		rows[i][0].text = "check_box" if completed else "check_box_outline_blank"
		UI.fit_label(rows[i][1], summary, card_width - 0.05)
		var alpha = 0.45 if completed else 1.0
		rows[i][0].modulate = Color(1, 1, 1, alpha)
		rows[i][1].modulate = Color(1, 1, 1, alpha)

	if more > 0:
		var last = rows[MAX_ITEMS - 1]
		last[0].visible = false
		last[1].visible = true
		last[1].text = "+%d more" % more
		last[1].modulate = Color(1, 1, 1, 0.6)
	_layout()

func _layout_extra(y: float) -> float:
	if rows.is_empty():
		return y
	y -= 0.004
	for row in rows:
		if not row[1].visible:
			continue
		row[0].position = Vector3(-card_width / 2 + 0.022, y - ROW_HEIGHT / 2, 0)
		row[1].position = Vector3(-card_width / 2 + 0.036, y - ROW_HEIGHT / 2, 0)
		y -= ROW_HEIGHT
	return y
