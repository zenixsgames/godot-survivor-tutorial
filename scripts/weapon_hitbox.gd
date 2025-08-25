extends Area2D


@export var damage = 10
@export var attack_speed = 0.5
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer


func short_disable():
	collision_shape_2d.call_deferred("set", "disable", true)
	timer.start()


func _on_timer_timeout() -> void:
	collision_shape_2d.call_deferred("set", "disable", true)


func _ready() -> void:
	timer.wait_time = attack_speed
