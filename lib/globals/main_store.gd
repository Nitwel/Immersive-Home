extends Node

const SettingsStore = preload("res://lib/stores/settings.gd")
const HouseStore = preload("res://lib/stores/house.gd")
const DevicesStore = preload("res://lib/stores/devices.gd")

var settings = SettingsStore.new()
var house = HouseStore.new()
var devices = DevicesStore.new()
