extends Area2D


var level = 1
var hp = 99
var speed = 200.0
var damage = 5
var knockback_amount = 100
var paths = 3
var attack_size = 1.0
var attack_speed = 4.0


var target = Vector2.ZERO
var target_array = []
var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO


var sprite_jav_reg = preload("res://assets/Textures/Items/Weapons/javelin_3_new.png")
var sprite_jav_atk = preload("res://assets/Textures/Items/Weapons/javelin_3_new_attack.png")
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var change_direction_timer: Timer = $ChangeDirectionTimer
@onready var reset_pos_timer: Timer = $ResetPosTimer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


signal remove_from_array(obj)


func _ready() -> void:
	update_jav()


func update_jav():
	level = player.javelin_level
	scale = Vector2(1.0,1.0) * attack_size
	attack_timer.wait_time = attack_speed


func _physics_process(delta: float) -> void:
	if target_array.size() > 0:
		position += angle * speed * delta


func add_paths():
	audio_stream_player_2d.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()


func process_path():
	angle = global_position.direction_to(target)
	change_direction_timer.start()


func enable_attack(atk = true):
	if atk:
		collision_shape_2d.call_deferred("set", "disabled", false)
		sprite_2d.texture = sprite_jav_atk
	else:
		collision_shape_2d.call_deferred("set", "disabled", true)
		sprite_2d.texture = sprite_jav_reg


func _on_attack_timer_timeout() -> void:
	add_paths()


func _on_change_direction_timer_timeout() -> void:
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			audio_stream_player_2d.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		change_direction_timer.stop()
		attack_timer.start()
		enable_attack(false)
