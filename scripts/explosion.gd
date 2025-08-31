extends AnimatedSprite2D


func _ready() -> void:
	$AnimationPlayer.play("explode")


func _on_animation_finished() -> void:
	queue_free()
