@tool
extends EditorPlugin

# A class member to hold the editor export plugin during its lifecycle.
var export_plugin : AndroidExportPlugin

## adds the ExoPlayer.gd as a Singleton autoload
const AUTOLOAD_NAME = "ExoPlayer"

func _enter_tree():
	# Initialization of the plugin goes here.
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_export_plugin(export_plugin)
	export_plugin = null

func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/godot_exoplayer/ExoPlayer.gd")

func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_NAME)

class AndroidExportPlugin extends EditorExportPlugin:
	# TODO: Update to your plugin's name.
	var _plugin_name = "godot_exoplayer"

	func _supports_platform(platform):
		if platform is EditorExportPlatformAndroid:
			return true
		return false

	func _get_android_libraries(platform, debug):
		if debug:
			return PackedStringArray([_plugin_name + "/bin/debug/" + _plugin_name + "-debug.aar"])
		else:
			return PackedStringArray([_plugin_name + "/bin/release/" + _plugin_name + "-release.aar"])

	func _get_android_dependencies(platform, debug):
		# TODO: Add remote dependices here.
		if debug:
			return PackedStringArray(["androidx.media3:media3-exoplayer:1.4.1","androidx.media3:media3-exoplayer-dash:1.4.1","androidx.media3:media3-ui:1.4.1"])
		else:
			return PackedStringArray(["androidx.media3:media3-exoplayer:1.4.1","androidx.media3:media3-exoplayer-dash:1.4.1","androidx.media3:media3-ui:1.4.1"])

	func _get_name():
		return _plugin_name
