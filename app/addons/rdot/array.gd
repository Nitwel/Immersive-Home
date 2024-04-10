class_name RdotArray

static func do_set(array: Array, index: int, value):
    if index >= array.size():
        array.resize(index + 1)

    array[index] = value

static func do_get(array: Array, index: int):
    if index >= array.size():
        return null

    return array[index]