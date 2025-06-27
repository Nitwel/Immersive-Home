extends GPUParticles3D

var tween = null
func gotinselpttopt(p0, p1):
	var d = (p1 - p0).length()
	tween = get_tree().create_tween()
	if d > 0.1:
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		position = p0
		rotation.y = Vector2(p1.z - p0.z, p1.x - p0.x).angle()
		$NoDepthSphere.visible = true
		$CyberTruck.visible = true
		tween.tween_property(self, "emitting", true, 0.1)
		tween.tween_property($AudioStreamPlayer3D, "playing", true, 0)
		tween.tween_property(self, "position", p1, d*0.9)
		tween.tween_property(self, "position", p1+Vector3(0,0.2,0), 2)
		tween.tween_property($AudioStreamPlayer3D, "playing", false, 0)
	tween.tween_property(self, "emitting", false, 0.1)
	tween.tween_property($NoDepthSphere, "visible", false, 0.0)
	tween.tween_property($CyberTruck, "visible", false, 0.0)
	return tween
	
