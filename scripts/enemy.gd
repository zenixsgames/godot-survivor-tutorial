extends CharacterBody2D


@export var ENEMY_SPEED = 20.0
@export var HP = 10
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * ENEMY_SPEED
	if velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
	if direction.x > 0:
		animated_sprite_2d.flip_h = true
	elif direction.x < 0:
		animated_sprite_2d.flip_h = false
	
	move_and_slide()
