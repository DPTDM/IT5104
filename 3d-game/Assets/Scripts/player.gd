extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 5.0
const CAMERA_ROTATION_LERP: float = 0.08
const CAMERA_OFFSET: Vector3 = Vector3(0, 0.8, -2.0)  # closer chase cam

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input relative to camera
	var input_dir: Vector2 = Input.get_vector("Left", "Right", "Forward", "Backward")
	var cam_basis: Basis = $Camera_Controller.global_transform.basis
	var direction: Vector3 = (cam_basis.x * input_dir.x + cam_basis.z * input_dir.y).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		var target_rotation: float = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# --- Camera collision handling ---
	var ideal_pos: Vector3 = global_transform.origin + global_transform.basis * CAMERA_OFFSET
	var space_state = get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.new()
	query.from = global_position
	query.to = ideal_pos
	query.collision_mask = 0xFFFFFFFF  # check all layers

	var result := space_state.intersect_ray(query)

	var target_cam_pos: Vector3 = ideal_pos
	if result:
		target_cam_pos = result.position + (global_position - result.position).normalized() * 0.2

	$Camera_Controller.global_position = lerp(
		$Camera_Controller.global_position,
		target_cam_pos,
		0.1
	)

	# Smoothly rotate camera to look at player
	var desired_rotation: Vector3 = (global_position - $Camera_Controller.global_position).normalized()
	var current_forward: Vector3 = -$Camera_Controller.global_transform.basis.z
	var blended_forward: Vector3 = current_forward.lerp(desired_rotation, CAMERA_ROTATION_LERP)

	$Camera_Controller.look_at($Camera_Controller.global_position + blended_forward, Vector3.UP)
