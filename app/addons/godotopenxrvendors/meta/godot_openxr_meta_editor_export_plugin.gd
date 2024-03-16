@tool
extends "../godot_openxr_export_plugin.gd".GodotOpenXREditorExportPlugin

const EYE_TRACKING_NONE_VALUE = 0
const EYE_TRACKING_OPTIONAL_VALUE = 1
const EYE_TRACKING_REQUIRED_VALUE = 2

const PASSTHROUGH_NONE_VALUE = 0
const PASSTHROUGH_OPTIONAL_VALUE = 1
const PASSTHROUGH_REQUIRED_VALUE = 2

const HAND_TRACKING_NONE_VALUE = 0
const HAND_TRACKING_OPTIONAL_VALUE = 1
const HAND_TRACKING_REQUIRED_VALUE = 2

const HAND_TRACKING_FREQUENCY_LOW_VALUE = 0
const HAND_TRACKING_FREQUENCY_HIGH_VALUE = 1

const EYE_TRACKING_OPTION = {
	"option": {
		"name": "meta_xr_features/eye_tracking",
		"class_name": "",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "None,Optional,Required",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": EYE_TRACKING_NONE_VALUE,
	"update_visibility": false,
}

const HAND_TRACKING_OPTION = {
	"option": {
		"name": "meta_xr_features/hand_tracking",
		"class_name": "",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "None,Optional,Required",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": HAND_TRACKING_NONE_VALUE,
	"update_visibility": false,	
}

const HAND_TRACKING_FREQUENCY_OPTION = {
	"option": {
		"name": "meta_xr_features/hand_tracking_frequency",
		"class_name": "",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Low,High",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": HAND_TRACKING_FREQUENCY_LOW_VALUE,
	"update_visibility": false,
}

const PASSTHROUGH_OPTION = {
	"option": {
		"name": "meta_xr_features/passthrough",
		"class_name": "",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "None,Optional,Required",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": PASSTHROUGH_NONE_VALUE,
	"update_visibility": false,
}

const USE_ANCHOR_API_OPTION = {
	"option": {
		"name": "meta_xr_features/use_anchor_api",
		"class_name": "",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": false,
	"update_visibility": false,
}

const SUPPORT_QUEST_1_OPTION = {
	"option": {
		"name": "meta_xr_features/quest_1_support",
		"class_name": "",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": false,
	"update_visibility": false,
}

const SUPPORT_QUEST_2_OPTION = {
	"option": {
		"name": "meta_xr_features/quest_2_support",
		"class_name": "",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": true,
	"update_visibility": false,
}

const SUPPORT_QUEST_3_OPTION = {
	"option": {
		"name": "meta_xr_features/quest_3_support",
		"class_name": "",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": true,
	"update_visibility": false,
}

const SUPPORT_QUEST_PRO_OPTION = {
	"option": {
		"name": "meta_xr_features/quest_pro_support",
		"class_name": "",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"usage": PROPERTY_USAGE_DEFAULT,
	},
	"default_value": true,
	"update_visibility": false,
}

func _get_export_options(platform) -> Array[Dictionary]:
	if not _supports_platform(platform):
		return []
	
	return [
		_get_vendor_toggle_option(),
		EYE_TRACKING_OPTION,
		HAND_TRACKING_OPTION,
		HAND_TRACKING_FREQUENCY_OPTION, 
		PASSTHROUGH_OPTION,
		USE_ANCHOR_API_OPTION,
		SUPPORT_QUEST_1_OPTION,
		SUPPORT_QUEST_2_OPTION,
		SUPPORT_QUEST_3_OPTION,
		SUPPORT_QUEST_PRO_OPTION,
	]


func _get_supported_devices() -> PackedStringArray:
	var supported_devices = PackedStringArray()

	if _get_bool_option("meta_xr_features/quest_1_support"):
		supported_devices.append("quest")
	if _get_bool_option("meta_xr_features/quest_2_support"):
		supported_devices.append("quest2")
	if _get_bool_option("meta_xr_features/quest_3_support"):
		supported_devices.append("quest3")
	if _get_bool_option("meta_xr_features/quest_pro_support"):
		supported_devices.append("questpro")

	return supported_devices


func _is_eye_tracking_enabled() -> bool:
	var eye_tracking_project_setting_enabled = ProjectSettings.get_setting_with_override("xr/openxr/extensions/eye_gaze_interaction")
	if not(eye_tracking_project_setting_enabled):
		return false

	var eye_tracking_option_value = _get_int_option("meta_xr_features/eye_tracking", EYE_TRACKING_NONE_VALUE)
	return eye_tracking_option_value > EYE_TRACKING_NONE_VALUE


func _get_export_features(platform, debug) -> PackedStringArray:
	var features = PackedStringArray()

	if not _supports_platform(platform):
		return features

	# Add the eye tracking feature if necessary
	if _is_eye_tracking_enabled():
		features.append(globals.EYE_GAZE_INTERACTION_FEATURE)

	return features


func _get_export_option_warning(platform, option) -> String:
	if not _supports_platform(platform):
		return ""
	
	var warning = ""
	var openxr_enabled = _is_openxr_enabled()
	match (option):
		"meta_xr_features/eye_tracking":
			var eye_tracking_project_setting_enabled = ProjectSettings.get_setting_with_override("xr/openxr/extensions/eye_gaze_interaction")
			var eye_tracking_option_value = _get_int_option("meta_xr_features/eye_tracking", EYE_TRACKING_NONE_VALUE)
			if eye_tracking_option_value > EYE_TRACKING_NONE_VALUE and not(eye_tracking_project_setting_enabled):
				warning = "\"Eye Tracking\" project setting must be enabled!\n"

		"meta_xr_features/hand_tracking":
			if not(openxr_enabled) and _get_int_option(option, HAND_TRACKING_NONE_VALUE) > HAND_TRACKING_NONE_VALUE:
				warning = "\"Hand Tracking\" requires \"XR Mode\" to be \"OpenXR\".\n"
				
		"meta_xr_features/passthrough":
			if not(openxr_enabled) and _get_int_option(option, PASSTHROUGH_NONE_VALUE) > PASSTHROUGH_NONE_VALUE:
				warning = "\"Passthrough\" requires \"XR Mode\" to be \"OpenXR\".\n"
				
		"meta_xr_features/use_anchor_api":
			if not(openxr_enabled) and _get_bool_option(option):
				warning = "\"Use anchor API\" is only valid when \"XR Mode\" is \"OpenXR\"."

		_:
			warning = super._get_export_option_warning(platform, option)
	
	return warning


func _get_android_manifest_element_contents(platform, debug) -> String:
	if not _supports_platform(platform) or not(_is_vendor_plugin_enabled()):
		return ""
	
	var contents = ""
	
	# Check for eye tracking
	if _is_eye_tracking_enabled():
		contents += "    <uses-permission android:name=\"com.oculus.permission.EYE_TRACKING\" />\n"

		var eye_tracking_value = _get_int_option("meta_xr_features/eye_tracking", EYE_TRACKING_NONE_VALUE)
		if eye_tracking_value == EYE_TRACKING_OPTIONAL_VALUE:
			contents += "    <uses-feature android:name=\"oculus.software.eye_tracking\" android:required=\"false\" />\n"
		elif eye_tracking_value == EYE_TRACKING_REQUIRED_VALUE:
			contents += "    <uses-feature android:name=\"oculus.software.eye_tracking\" android:required=\"true\" />\n"


	# Check for hand tracking
	var hand_tracking_value = _get_int_option("meta_xr_features/hand_tracking", HAND_TRACKING_NONE_VALUE)
	if hand_tracking_value > HAND_TRACKING_NONE_VALUE:
		contents += "    <uses-permission android:name=\"com.oculus.permission.HAND_TRACKING\" />\n"
		if hand_tracking_value == HAND_TRACKING_OPTIONAL_VALUE:
			contents += "    <uses-feature tools:node=\"replace\" android:name=\"oculus.software.handtracking\" android:required=\"false\" />\n"
		elif hand_tracking_value == HAND_TRACKING_REQUIRED_VALUE:
			contents += "    <uses-feature tools:node=\"replace\" android:name=\"oculus.software.handtracking\" android:required=\"true\" />\n"
	
	# Check for passthrough
	var passthrough_mode = _get_int_option("meta_xr_features/passthrough", PASSTHROUGH_NONE_VALUE)
	if passthrough_mode == PASSTHROUGH_OPTIONAL_VALUE:
		contents += "    <uses-feature tools:node=\"replace\" android:name=\"com.oculus.feature.PASSTHROUGH\" android:required=\"false\" />\n"
	elif passthrough_mode == PASSTHROUGH_REQUIRED_VALUE:
		contents += "    <uses-feature tools:node=\"replace\" android:name=\"com.oculus.feature.PASSTHROUGH\" android:required=\"true\" />\n"
	
	# Check for anchor api
	var use_anchor_api = _get_bool_option("meta_xr_features/use_anchor_api")
	if use_anchor_api:
		contents += "    <uses-permission android:name=\"com.oculus.permission.USE_ANCHOR_API\" />\n"

	return contents


func _get_android_manifest_application_element_contents(platform, debug) -> String:
	if not _supports_platform(platform) or not(_is_vendor_plugin_enabled()):
		return ""
	
	var contents = ""

	var supported_devices = "|".join(_get_supported_devices())
	contents += "        <meta-data tools:node=\"replace\" android:name=\"com.oculus.supportedDevices\" android:value=\"%s\" />\n" % supported_devices

	var hand_tracking_enabled = _get_int_option("meta_xr_features/hand_tracking", HAND_TRACKING_NONE_VALUE) > HAND_TRACKING_NONE_VALUE
	if hand_tracking_enabled:
		var hand_tracking_frequency = _get_int_option("meta_xr_features/hand_tracking_frequency", HAND_TRACKING_FREQUENCY_LOW_VALUE)
		var hand_tracking_frequency_label = "LOW" if hand_tracking_frequency == HAND_TRACKING_FREQUENCY_LOW_VALUE else "HIGH"
		contents += "        <meta-data tools:node=\"replace\" android:name=\"com.oculus.handtracking.frequency\" android:value=\"%s\" />\n" % hand_tracking_frequency_label
		contents += "        <meta-data tools:node=\"replace\" android:name=\"com.oculus.handtracking.version\" android:value=\"V2.0\" />\n"
		
	return contents

func _get_android_manifest_activity_element_contents(platform, debug) -> String:
	if not _supports_platform(platform) or not(_is_vendor_plugin_enabled()):
		return ""
	
	var contents = """
				<intent-filter>\n
					<action android:name=\"android.intent.action.MAIN\" />\n
					<category android:name=\"android.intent.category.LAUNCHER\" />\n
					\n
					<!-- Enable access to OpenXR on Oculus mobile devices, no-op on other Android\n
					platforms. -->\n
					<category android:name=\"com.oculus.intent.category.VR\" />\n
					\n
					<!-- OpenXR category tag to indicate the activity starts in an immersive OpenXR mode. \n
					See https://registry.khronos.org/OpenXR/specs/1.0/html/xrspec.html#android-runtime-category. -->\n
					<category android:name=\"org.khronos.openxr.intent.category.IMMERSIVE_HMD\" />\n
				</intent-filter>\n
	"""
	
	return contents
