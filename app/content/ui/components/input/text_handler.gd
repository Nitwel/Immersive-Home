extends RefCounted

var label: Label3D

var text: String = ""
var width: float = 0.2:
	set(value):
		width = max(0.0, value)
		gap_offsets = _calculate_text_gaps()
		overflow_index = _calculate_overflow_index()
		caret_position = 0
var gap_offsets = null
var overflow_index: int = -1
var char_offset: int = 0
var caret_position: int = 3:
	set(value):
		caret_position = clampi(value, 0, text.length())

## Selected range as character indices [selection_start, selection_end).
## Both are -1 when nothing is selected.
var selection_start: int = -1
var selection_end: int = -1

func set_text(value: String, insert: bool=false):
	var old_text = text
	text = value
	clear_selection()

	if label == null:
		return

	gap_offsets = _calculate_text_gaps()
	if insert == false:
		var text_diff = text.length() - old_text.length()
		caret_position += text_diff
		if text_diff < 0:
			char_offset = max(0, char_offset + text_diff)
	else:
		caret_position = 0

	overflow_index = _calculate_overflow_index()
	focus_caret()

func get_display_text():
	# In case all chars fit, return the whole text.
	if overflow_index == - 1:
		return text.substr(char_offset)
	return text.substr(char_offset, overflow_index - char_offset)

func focus_caret():
	if overflow_index == - 1:
		char_offset = 0
		return

	while caret_position > overflow_index:
		char_offset += caret_position - overflow_index
		overflow_index = _calculate_overflow_index()
		if overflow_index == - 1:
			break

	while caret_position < char_offset:
		char_offset = caret_position
		overflow_index = _calculate_overflow_index()
		if overflow_index == - 1:
			break

	# After deleting text, scroll back left so the box doesn't show empty
	# space on the right while earlier characters are hidden.
	while char_offset > 0 and gap_offsets[text.length()] - gap_offsets[char_offset - 1] < width:
		char_offset -= 1
	overflow_index = _calculate_overflow_index()

func has_selection() -> bool:
	return selection_start >= 0 and selection_end > selection_start

func clear_selection():
	selection_start = -1
	selection_end = -1

## Selects the word under [param index]. On whitespace, selects the run of whitespace.
func select_word_at(index: int):
	index = clampi(index, 0, text.length())
	if text.is_empty():
		return

	# The caret sits between characters: prefer the character to its right,
	# but use the one to the left at the end of a word / the text.
	var probe = index if index < text.length() else index - 1
	if index > 0 and index < text.length() and _is_space(text[index]) and not _is_space(text[index - 1]):
		probe = index - 1
	var space = _is_space(text[probe])

	var start = probe
	while start > 0 and _is_space(text[start - 1]) == space:
		start -= 1
	var end = probe + 1
	while end < text.length() and _is_space(text[end]) == space:
		end += 1

	_select(start, end)

func select_all():
	_select(0, text.length())

func _select(start: int, end: int):
	selection_start = start
	selection_end = end
	caret_position = end
	focus_caret()

func _is_space(c: String) -> bool:
	return c == " " or c == "\t" or c == "\n"

## Returns [start, end] of the selection in label-local x, clipped to the
## visible part of the text, or an empty array if nothing visible is selected.
func get_selection_rect() -> Array:
	if not has_selection():
		return []

	var visible_width = gap_offsets[overflow_index] - gap_offsets[char_offset]
	var start = clampf(gap_offsets[selection_start] - gap_offsets[char_offset], 0.0, visible_width)
	var end = clampf(gap_offsets[selection_end] - gap_offsets[char_offset], 0.0, visible_width)

	if end <= start:
		return []
	return [start, end]

func get_caret_position():
	return gap_offsets[caret_position] - gap_offsets[char_offset]

func update_caret_position(click_pos_x: float):
	clear_selection()
	caret_position = _calculate_caret_position(click_pos_x)
	focus_caret()

## Returns the gap closest to [param click_pos_x], so clicking the right half
## of a character puts the caret after it rather than before it.
## Gaps before [member char_offset] have negative positions, so a click/drag
## past the left edge selects a hidden character and focus_caret() scrolls to it.
func _calculate_caret_position(click_pos_x: float):
	for i in range(1, gap_offsets.size()):
		var left = gap_offsets[i - 1] - gap_offsets[char_offset]
		var right = gap_offsets[i] - gap_offsets[char_offset]

		if click_pos_x < (left + right) / 2.0:
			return i - 1

	return gap_offsets.size() - 1

func _calculate_text_gaps():
	var offsets = [0.0]

	if label.font == null:
		offsets.resize(text.length() + 1)
		offsets.fill(0.0)
		return offsets

	for i in range(text.length()):
		var chars = text.substr(0, i + 1) # Can't use single chars because of kerning.
		# Measure as one unbounded line. Passing label.width (as FontTools does)
		# caps the result at the label width, so long text would get zero-width
		# gaps and overflow the input.
		var size = label.font.get_string_size(chars, HORIZONTAL_ALIGNMENT_LEFT, -1, label.font_size) * label.pixel_size

		offsets.append(size.x)

	return offsets

func _calculate_overflow_index():
	for i in range(char_offset, gap_offsets.size()):
		if gap_offsets[i] - gap_offsets[char_offset] >= width:
			return i - 1
	return gap_offsets.size() - 1
