extends Node

const Main = preload ("res://content/main.gd")
const House = preload ("res://content/system/house/house.gd")
const Menu = preload ("res://content/ui/menu/menu.gd")
const Miniature = preload ("res://content/system/miniature/miniature.gd")
const ControllerLeft = preload ("res://content/system/controller_left/controller_left.gd")
const ControllerRight = preload ("res://content/system/controller_right/controller_right.gd")

@onready var main: Main = get_node_or_null("/root/Main")
@onready var house: House = get_node_or_null("/root/Main/House")
@onready var menu: Menu = get_node_or_null("/root/Main/Menu")
@onready var camera: XRCamera3D = get_node_or_null("/root/Main/XROrigin3D/XRCamera3D")
@onready var miniature: Miniature = get_node_or_null("/root/Main/Miniature")
@onready var controller_left: ControllerLeft = get_node_or_null("/root/Main/XROrigin3D/XRControllerLeft")
@onready var controller_right: ControllerRight = get_node_or_null("/root/Main/XROrigin3D/XRControllerRight")