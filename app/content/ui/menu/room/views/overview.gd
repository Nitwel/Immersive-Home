extends Node3D



func _on_walls_button_on_toggled(active):
	App.house.blueborder_alignment(active)
	$ApplyAlignment.disabled = not active
	$MoveAlignment.disabled = not active
	$BringClose.disabled = not active

func _on_move_alignment_on_button_down():
	App.house.move_alignment()

func _on_apply_alignment_on_button_down():
	App.house.apply_alignment()

func _on_bring_close_on_button_down():
	App.house.bring_alignment_close()


func _scene_capture_completed(success : bool):
	print(" ***  _scene_capture_completed, success: ", success)
	App.main.meta_scene_manager.openxr_fb_scene_capture_completed.disconnect(_scene_capture_completed)


func _on_rescan_spatial_on_button_down():
	if not App.main.meta_scene_manager.openxr_fb_scene_capture_completed.is_connected(_scene_capture_completed):
		App.main.meta_scene_manager.openxr_fb_scene_capture_completed.connect(_scene_capture_completed)
	print(" is_scene_capture_enabled (might be wrong answer, so requesting anyway) ", App.main.meta_scene_manager.is_scene_capture_enabled())
	App.main.meta_scene_manager.request_scene_capture()
