extends Area2D


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
signal hit(damage: Variant)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		if area.has_method("short_disable"):
			area.short_disable()
		emit_signal("hit", area.damage)
		if area.has_method("enemy_hit"):
			area.enemy_hit(1)
