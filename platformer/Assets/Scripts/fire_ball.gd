extends Area2D

@export var speed = 300.0
var direction: Vector2 = Vector2.ZERO

@onready var anim = $AnimatedSprite2D   # reference to your AnimatedSprite2D

func _ready():
	# Play the default animation on loop
	anim.play("default")
	add_to_group("fireball")

	# Auto-destroy after 5 seconds
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _process(delta):
	# Move projectile along its direction
	position += direction * speed * delta

	# Continuously rotate to face movement direction
	if direction != Vector2.ZERO:
		rotation = direction.angle()

func _on_body_entered(body: Node2D):
	if body is PlayerController:
		GameManager.death()
