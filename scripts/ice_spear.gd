extends Area2D


var level = 1
var hp = 1
var speed = 100.0
var damage = 5
var knockback_amount = 100
var attack_size = 1.0
var target = Vector2.ZERO
var angle = Vector2.ZERO
@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(0)
	match level:
		1:
			hp = 1
			speed = 100.0
			damage = 5.0
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 1
			speed = 100.0
			damage = 5.0
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 2
			speed = 100.0
			damage = 8.0
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 2
			speed = 100.0
			damage = 8.0
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta: float) -> void:
	position += angle * speed * delta


func enemy_hit(damage = 1):
	hp -= damage
	if hp <= 0:
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
