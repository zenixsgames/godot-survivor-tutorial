extends Area2D


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
signal hit(damage, angle, knockback)
var hit_once_array = []

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		if area.has_method("short_disable"):
			area.short_disable()
		var damage = area.damage
		var angle = Vector2.ZERO
		var knockback = 1
		if not area.get("angle") == null:
			angle = area.angle
		if not area.get("knockback_amount") == null:
			knockback = area.knockback_amount
		if not hit_once_array.has(area):
			hit_once_array.append(area)
			if not area.is_connected("remove_from_array", Callable(self,"remove_from_list")):
				area.connect("remove_from_array", Callable(self,"remove_from_list"))
			emit_signal("hit", damage, angle, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)


func remove_from_list(obj):
	if hit_once_array.has(obj):
		hit_once_array.erase(obj)
