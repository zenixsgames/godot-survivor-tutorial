extends CharacterBody2D


@export var PLAYER_SPEED = 100.0
@export var HP = 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var x_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_direction = Input.get_action_strength("down") - Input.get_action_strength("up")
	var direction = Vector2(x_direction, y_direction)
	
	if direction.x > 0:
		animated_sprite_2d.flip_h = true
	elif direction.x < 0:
		animated_sprite_2d.flip_h = false
	
	velocity = direction.normalized() * PLAYER_SPEED
	if velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
	
	move_and_slide()
