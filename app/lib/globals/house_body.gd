extends Node
## Shortcut to get the House node from the Main scene

const HouseClass = preload ("res://content/system/house/house.gd")

@onready var body: HouseClass = get_node_or_null("/root/Main/House")