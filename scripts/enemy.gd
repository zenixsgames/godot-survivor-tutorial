extends CharacterBody2D


@export var enemy_speed = 20.0
@export var enemy_hp = 10
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var knockback = Vector2.ZERO
var knockback_recovery = 2.5


func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * enemy_speed
	velocity += knockback
	if velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
	if direction.x > 0:
		animated_sprite_2d.flip_h = true
	elif direction.x < 0:
		animated_sprite_2d.flip_h = false
	
	move_and_slide()


func _on_enemy_hurtbox_hit(damage, angle, knockback_amount) -> void:
	enemy_hp -= damage
	knockback = angle * knockback_amount
	if enemy_hp <= 0:
		queue_free()
