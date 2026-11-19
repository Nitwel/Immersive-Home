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

func set_text(value: String, insert: bool=false):
	var old_text = text
	text = value

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

func get_caret_position():
	return gap_offsets[caret_position] - gap_offsets[char_offset]

func update_caret_position(click_pos_x: float):
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
