extends Area2D


var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0
var target = Vector2.ZERO
var angle = Vector2.ZERO
@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(0)


func _physics_process(delta: float) -> void:
	position += angle * speed * delta


func enemy_hit(damage = 1):
	hp -= damage
	if hp <= 0:
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
