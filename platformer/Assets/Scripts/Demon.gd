extends CharacterBody2D

@onready var vision = $Vision
@onready var path_follow = get_parent() as PathFollow2D
@onready var anim = $AnimatedSprite2D

var can_shoot = true
@export var shoot_cooldown = 1.0
@export var move_speed = 100.0

var target: Node2D = null
var last_target_pos: Vector2 = Vector2.ZERO
var direction: int = 1
var is_attacking: bool = false
var pending_final_attack: bool = false   # NEW flag

func _ready():
	vision.connect("body_entered", Callable(self, "_on_body_entered"))
	vision.connect("body_exited", Callable(self, "_on_body_exited"))
	anim.connect("frame_changed", Callable(self, "_on_frame_changed"))
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))
	path_follow.progress = 0.0
	path_follow.loop = false
	anim.play("Flying")

func _process(delta):
	# Only move if not attacking
	if not is_attacking:
		path_follow.progress += move_speed * delta * direction
		if path_follow.progress_ratio >= 1.0:
			direction = -1
		elif path_follow.progress_ratio <= 0.0:
			direction = 1

	# Rotate toward player if inside vision
	if target != null:
		look_at(target.global_position)
		rotation += deg_to_rad(-90)
		last_target_pos = target.global_position

	# If cooldown is ready, attack again
	if can_shoot and not is_attacking and (target != null or pending_final_attack):
		is_attacking = true
		anim.play("Attack")

func _on_body_entered(body):
	if body.is_in_group("player"):
		target = body
		last_target_pos = body.global_position

func _on_body_exited(body):
	if body == target:
		target = null
		pending_final_attack = true   # mark one last attack

func _on_frame_changed():
	# Fire at frame 3 of Attack animation
	if anim.animation == "Attack" and anim.frame == 3 and can_shoot:
		shoot_projectile(last_target_pos)
		start_cooldown()
	
	if anim.animation == "Flying" and anim.frame == 1:
		var sounds_node
		var player = get_tree().get_first_node_in_group("player")
		if player and global_position.distance_to(player.global_position) < 300:
			sounds_node = get_tree().get_first_node_in_group("sounds")
			if sounds_node:
				var flap_sound = sounds_node.get_node_or_null("Flap")
				if flap_sound and flap_sound is AudioStreamPlayer and flap_sound.stream:
					flap_sound.play()




func _on_animation_finished():
	if anim.animation == "Attack":
		is_attacking = false
		anim.play("Flying")
		pending_final_attack = false   # clear final attack flag

		rotation = 0

func shoot_projectile(target_pos: Vector2):
	var projectile = preload("res://Assets/Scenes/fire_ball.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.direction = (target_pos - global_position).normalized()

func start_cooldown():
	can_shoot = false
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
