extends Area2D


@export var experience = 1
var sprite_green = preload("res://assets/Textures/Items/Gems/Gem_green.png")
var sprite_blue = preload("res://assets/Textures/Items/Gems/Gem_blue.png")
var sprite_red = preload("res://assets/Textures/Items/Gems/Gem_red.png")
var target = null
var speed = -1


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	if experience < 5:
		sprite_2d.texture = sprite_green
	elif experience < 20:
		sprite_2d.texture = sprite_blue
	elif experience <100:
		sprite_2d.texture = sprite_red


func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta


func collect():
	audio_stream_player.play()
	collision_shape_2d.call_deferred("set","disabled",true)
	sprite_2d.visible = false
	return experience


func _on_audio_stream_player_finished() -> void:
	queue_free()
