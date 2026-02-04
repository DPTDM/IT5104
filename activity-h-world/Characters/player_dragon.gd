extends CharacterBody2D

@export var move_speed : float = 100

@onready var animation_tree = $AnimationTree

func _physics_process(_delta):
	
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	#print(input_direction)
	update_animation_parameters(input_direction)

	velocity = input_direction * move_speed
	
	
	move_and_slide()



func update_animation_parameters(move_input : Vector2):
	
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/walk/blend_position", move_input)
