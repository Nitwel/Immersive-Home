@tool
extends EditorPlugin

var globals = preload("globals.gd")

# A class member to hold the export plugin during its lifecycle.
var meta_export_plugin : GodotOpenXREditorExportPlugin
var pico_export_plugin : GodotOpenXREditorExportPlugin
var lynx_export_plugin : GodotOpenXREditorExportPlugin
var khronos_export_plugin : GodotOpenXREditorExportPlugin


func _enter_tree():
	var plugin_version = get_plugin_version()
	
	# Initializing the export plugins
	meta_export_plugin = preload("meta/godot_openxr_meta_editor_export_plugin.gd").new()
	meta_export_plugin._setup(globals.META_VENDOR_NAME, plugin_version)
	
	pico_export_plugin = preload("pico/godot_openxr_pico_editor_export_plugin.gd").new()
	pico_export_plugin._setup(globals.PICO_VENDOR_NAME, plugin_version)
	
	lynx_export_plugin = preload("lynx/godot_openxr_lynx_editor_export_plugin.gd").new()
	lynx_export_plugin._setup(globals.LYNX_VENDOR_NAME, plugin_version)
	
	khronos_export_plugin = preload("khronos/godot_openxr_khronos_editor_export_plugin.gd").new()
	khronos_export_plugin._setup(globals.KHRONOS_VENDOR_NAME, plugin_version)
	
	add_export_plugin(meta_export_plugin)
	add_export_plugin(pico_export_plugin)
	add_export_plugin(lynx_export_plugin)
	add_export_plugin(khronos_export_plugin)


func _exit_tree():
	# Cleaning up the export plugins
	remove_export_plugin(meta_export_plugin)
	remove_export_plugin(pico_export_plugin)
	remove_export_plugin(lynx_export_plugin)
	remove_export_plugin(khronos_export_plugin)
	
	meta_export_plugin = null
	pico_export_plugin = null
	lynx_export_plugin = null
	khronos_export_plugin = null


class GodotOpenXREditorExportPlugin extends EditorExportPlugin:
	
	## Base class for the vendor editor export plugin

	var globals = preload("globals.gd")

	var _vendor: String
	var _plugin_version: String

	func _setup(vendor: String, version: String):
		_vendor = vendor
		_plugin_version = version


	func _get_name() -> String:
		return "GodotOpenXR" + _vendor.capitalize()


	# Path to the Android library aar file
	# If this is not available, we fall back to the maven central dependency
	func _get_android_aar_file_path(debug: bool) -> String:
		var debug_label = "debug" if debug else "release"
		return "res://addons/godotopenxrvendors/" + _vendor + "/.bin/" + debug_label + "/godotopenxr" + _vendor + "-" + debug_label + ".aar"


	# Maven central dependency used as fall back when the Android library aar file is not available
	func _get_android_maven_central_dependency() -> String:
		return "org.godotengine:godot-openxr-vendors-" + _vendor + ":" + _plugin_version


	func _get_vendor_toggle_option_name(vendor_name: String = _vendor) -> String:
		return "xr_features/enable_" + vendor_name + "_plugin"


	func _get_vendor_toggle_option(vendor_name: String = _vendor) -> Dictionary:
		var toggle_option = {
			"option": {
				"name": _get_vendor_toggle_option_name(vendor_name),
				"class_name": "",
				"type": TYPE_BOOL,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		"default_value": false,
		"update_visibility": false,
		}
		return toggle_option


	func _is_openxr_enabled() -> bool:
		return _get_int_option("xr_features/xr_mode", 0) == globals.OPENXR_MODE_VALUE


	func _get_export_options(platform) -> Array[Dictionary]:
		if not _supports_platform(platform):
			return []

		return [
			_get_vendor_toggle_option(),
		]


	func _get_export_option_warning(platform, option) -> String:
		if not _supports_platform(platform):
			return ""

		if option != _get_vendor_toggle_option_name():
			return ""

		if not(_is_openxr_enabled()) and _get_bool_option(option):
			return "\"Enable " + _vendor.capitalize() + " Plugin\" requires \"XR Mode\" to be \"OpenXR\".\n"

		if _is_vendor_plugin_enabled():
			for vendor_name in globals.VENDORS_LIST:
				if (vendor_name != _vendor) and _is_vendor_plugin_enabled(vendor_name):
					return "\"Disable " + _vendor.capitalize() + " Plugin before enabling another. Multiple plugins are not supported!\""

		return ""


	func _supports_platform(platform) -> bool:
		if platform is EditorExportPlatformAndroid:
			return true
		return false


	func _get_bool_option(option: String) -> bool:
		var option_enabled = get_option(option)
		if option_enabled is bool:
			return option_enabled
		return false


	func _get_int_option(option: String, default_value: int) -> int:
		var option_value = get_option(option)
		if option_value is int:
			return option_value
		return default_value


	func _is_vendor_plugin_enabled(vendor_name: String = _vendor) -> bool:
		return _get_bool_option(_get_vendor_toggle_option_name(vendor_name))


	func _is_android_aar_file_available(debug: bool) -> bool:
		return FileAccess.file_exists(_get_android_aar_file_path(debug))


	func _get_android_dependencies(platform, debug) -> PackedStringArray:
		if not _supports_platform(platform):
			return PackedStringArray()

		if _is_vendor_plugin_enabled() and not _is_android_aar_file_available(debug):
			return PackedStringArray([_get_android_maven_central_dependency()])

		return PackedStringArray()


	func _get_android_libraries(platform, debug) -> PackedStringArray:
		if not _supports_platform(platform):
			return PackedStringArray()
			
		if _is_vendor_plugin_enabled() and _is_android_aar_file_available(debug):
			return PackedStringArray([_get_android_aar_file_path(debug)])

		return PackedStringArray()


	func _get_android_dependencies_maven_repos(platform, debug) -> PackedStringArray:
		var maven_repos = PackedStringArray()
		
		if not _supports_platform(platform):
			return maven_repos
		
		if _is_vendor_plugin_enabled() and not _is_android_aar_file_available(debug) and _plugin_version.ends_with("-SNAPSHOT"):
			maven_repos.append("https://s01.oss.sonatype.org/content/repositories/snapshots/")
		
		return maven_repos
