@tool
extends "../godot_openxr_export_plugin.gd".GodotOpenXREditorExportPlugin


func _get_android_manifest_activity_element_contents(platform, debug) -> String:
	if not _supports_platform(platform) or not(_is_vendor_plugin_enabled()):
		return ""
	
	var contents = """
				<intent-filter>\n
					<action android:name=\"android.intent.action.MAIN\" />\n
					<category android:name=\"android.intent.category.LAUNCHER\" />\n
					\n
					<!-- OpenXR category tag to indicate the activity starts in an immersive OpenXR mode. \n
					See https://registry.khronos.org/OpenXR/specs/1.0/html/xrspec.html#android-runtime-category. -->\n
					<category android:name=\"org.khronos.openxr.intent.category.IMMERSIVE_HMD\" />\n
					\n
					<!-- Enable VR access on HTC Vive Focus devices. -->\n
					<category android:name=\"com.htc.intent.category.VRAPP\" />\n
				</intent-filter>\n
	"""
	
	return contents
