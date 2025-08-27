extends Area2D


@export var immmune_time = 5.0
@onready var player_collision_shape_2d: CollisionShape2D = $"../CollisionShape2D"
@onready var hurtbox_collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
signal hurt(damage: Variant)
var immune_state: bool = false


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		# short-immune when player hurt
		hurtbox_collision_shape_2d.set_deferred("disabled", true)
		timer.start()
		if area.has_method("short_disable"):
			# enemy's attack speed
			area.short_disable()
		if not immune_state:
			immune_state = true
			player_collision_shape_2d.set_deferred("disabled", true)
			emit_signal("hurt", area.damage)


func _on_timer_timeout() -> void:
	hurtbox_collision_shape_2d.set_deferred("disabled", false)
	player_collision_shape_2d.set_deferred("disabled", false)
	immune_state = false


func _ready() -> void:
	timer.wait_time = immmune_time
