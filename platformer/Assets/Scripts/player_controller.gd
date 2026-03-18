extends CharacterBody2D
class_name PlayerController

@export var input_prefix: String = "P1"   # "P1" or "P2"
@export var speed: float = 18.0
@export var jump_pwr: float = 10.0
@export var dash_power: float = 600.0
@export var dash_duration: float = 0.2
@export var can_dash: bool = true
@export var dash_cooldown: float = 1.0
@export var camera: Camera2D

@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var animator: AnimationPlayer = $PlayerAnimator/AnimationPlayer

var speed_multiplier: float = 30.0
var jump_multiplier: float = -30.0
var dash_timer: float = 0.0
var dash_on_cooldown: bool = false

var direction: int = 0
var is_dashing: bool = false
var animation_state: String = "idle"

func _ready() -> void:
	camera.make_current()

func _input(event) -> void:
	if event.is_action_pressed(input_prefix + "Jump") and is_on_floor():
		jump()

	if event.is_action_pressed(input_prefix + "MoveDown"):
		set_collision_mask_value(10, false)
	else:
		set_collision_mask_value(10, true)

	if event.is_action_pressed(input_prefix + "Dash") and not is_dashing and direction != 0 and can_dash and not dash_on_cooldown:
		start_dash()

func _physics_process(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta

		direction = Input.get_axis(input_prefix + "MoveLeft", input_prefix + "MoveRight")

		if direction != 0:
			velocity.x = direction * speed * speed_multiplier
		else:
			velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	if is_on_floor() and dash_on_cooldown:
		dash_on_cooldown = false

	move_and_slide()
	update_animation()

func start_dash() -> void:
	is_dashing = true
	dash_timer = dash_duration
	var dash_dir = Vector2(direction, 0).normalized()
	velocity = dash_dir * dash_power
	dash_on_cooldown = true
	await get_tree().create_timer(dash_cooldown).timeout

func teleport_to_location(new_location: Vector2) -> void:
	camera.position_smoothing_enabled = false
	position = new_location
	await get_tree().physics_frame
	camera.position_smoothing_enabled = true

func jump() -> void:
	if is_on_floor():
		velocity.y = jump_pwr * jump_multiplier
		jump_sound.play()

func update_animation() -> void:
	if is_on_floor():
		if direction != 0:
			animation_state = "Move"
		else:
			animation_state = "Idle"
	else:
		animation_state = "Jump"

	animator.play(animation_state)
