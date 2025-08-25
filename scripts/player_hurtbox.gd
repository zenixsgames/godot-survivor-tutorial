extends Area2D


@export var immmune_time = 0.5
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
signal hurt(damage: Variant)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		# short-immune when player hurt
		collision_shape_2d.call_deferred("set", "disabled", true)
		timer.start()
		if area.has_method("short_disable"):
			# enemy's attack speed
			area.short_disable()
		emit_signal("hurt", area.damage)


func _on_timer_timeout() -> void:
	collision_shape_2d.call_deferred("set", "disabled", false)


func _ready() -> void:
	timer.wait_time = immmune_time
