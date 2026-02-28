extends CharacterBody2D

class_name PlayerController

@export var speed = 18.0
@export var jump_pwr = 10.0
@export var dash_power = 600.0       # strength of dash
@export var dash_duration = 0.2      # how long dash lasts (seconds)
@export var can_dash = true          # toggle option in Inspector
@export var dash_cooldown = 1.0      # cooldown time in seconds (Inspector)
@export var camera : Camera2D

@onready var jump_sound: AudioStreamPlayer = $JumpSound

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0
var is_dashing = false
var dash_timer = 0.0
var dash_on_cooldown = false

func _input(event):
	if event.is_action_pressed("Jump") and is_on_floor():
		velocity.y = jump_pwr * jump_multiplier
		jump_sound.play()

	if event.is_action_pressed("MoveDown"):
		set_collision_mask_value(10, false)
	else:
		set_collision_mask_value(10, true)

	# Dash input (only if enabled and not on cooldown)
	if event.is_action_pressed("Dash") and not is_dashing and direction != 0 and can_dash and not dash_on_cooldown:
		start_dash()

func _physics_process(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Movement
		direction = Input.get_axis("MoveLeft", "MoveRight")
		if direction:
			velocity.x = direction * speed * speed_multiplier
		else:
			velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	# 🔹 Reset cooldown when landing
	if is_on_floor() and dash_on_cooldown:
		dash_on_cooldown = false

	move_and_slide()

func start_dash():
	is_dashing = true
	dash_timer = dash_duration

	# Dash in the direction the player is facing
	var dash_dir = Vector2(direction, 0).normalized()
	velocity = dash_dir * dash_power

	# Put dash on cooldown
	dash_on_cooldown = true
	await get_tree().create_timer(dash_cooldown).timeout
	# Cooldown will auto-reset when landing, but this ensures a minimum wait


func teleport_to_location(new_location):
	camera.position_smoothing_enabled = false
	position = new_location
	await get_tree().physics_frame
	camera.position_smoothing_enabled = true
	
