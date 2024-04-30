class_name TransformTools

## Calculate the transform that would transform the source position, direction and up vector to the target position, direction and up vector
## Basically a bit more fancy Inputs for a Transform3D
static func calc_delta_transform(source_pos: Vector3, source_dir: Vector3, source_up: Vector3, target_pos: Vector3, target_dir: Vector3, target_up: Vector3) -> Transform3D:
	var source_transform = Transform3D()
	source_transform.basis = Basis(source_dir, source_up, source_dir.cross(source_up)).orthonormalized() * (1.0 / source_dir.length())
	source_transform.origin = source_pos

	var target_transform = Transform3D()
	target_transform.basis = Basis(target_dir, target_up, target_dir.cross(target_up)).orthonormalized() * (target_dir.length())
	target_transform.origin = target_pos

	return target_transform * source_transform.inverse()

## Rotate a transform around a point by an angle around an axis
static func rotate_around_point_axis(transform: Transform3D, point: Vector3, axis: Vector3, angle: float) -> Transform3D:
	return transform.translated( - point).rotated(axis, angle).translated(point)
	
static func rotate_around_point(transform: Transform3D, point: Vector3, rotation: Vector3, rotation_order: EulerOrder=EULER_ORDER_YXZ) -> Transform3D:
	transform = transform.translated( - point)
	var axis1 = Vector3()
	var axis2 = Vector3()
	var axis3 = Vector3()

	match rotation_order:
		EULER_ORDER_XYZ:
			axis1 = Vector3(1, 0, 0)
			axis2 = Vector3(0, 1, 0)
			axis3 = Vector3(0, 0, 1)
		EULER_ORDER_XZY:
			axis1 = Vector3(1, 0, 0)
			axis2 = Vector3(0, 0, 1)
			axis3 = Vector3(0, 1, 0)
			rotation = Vector3(rotation.x, rotation.z, rotation.y)
		EULER_ORDER_YXZ:
			axis1 = Vector3(0, 1, 0)
			axis2 = Vector3(1, 0, 0)
			axis3 = Vector3(0, 0, 1)
			rotation = Vector3(rotation.y, rotation.x, rotation.z)
		EULER_ORDER_YZX:
			axis1 = Vector3(0, 1, 0)
			axis2 = Vector3(0, 0, 1)
			axis3 = Vector3(1, 0, 0)
			rotation = Vector3(rotation.y, rotation.z, rotation.x)
		EULER_ORDER_ZXY:
			axis1 = Vector3(0, 0, 1)
			axis2 = Vector3(1, 0, 0)
			axis3 = Vector3(0, 1, 0)
			rotation = Vector3(rotation.z, rotation.x, rotation.y)
		EULER_ORDER_ZYX:
			axis1 = Vector3(0, 0, 1)
			axis2 = Vector3(0, 1, 0)
			axis3 = Vector3(1, 0, 0)
			rotation = Vector3(rotation.z, rotation.y, rotation.x)

	transform = transform.rotated(axis1, rotation.x).rotated(axis2, rotation.y).rotated(axis3, rotation.z)
	return transform.translated(point)
