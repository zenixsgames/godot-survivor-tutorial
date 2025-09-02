extends CharacterBody2D


var player_speed = 100.0
var player_hp = 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var icespear = load("res://scenes/ice_spear.tscn")
@onready var ice_spear_timer: Timer = $Attack/IceSpearTimer
@onready var ice_spear_attack_timer: Timer = $Attack/IceSpearTimer/IceSpearAttackTimer
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 0
var enemy_close = []


var last_movement = Vector2.ZERO
var tornado = load("res://scenes/tornado.tscn")
@onready var tornado_timer: Timer = $Attack/TornadoTimer
@onready var tornado_attack_timer: Timer = $Attack/TornadoTimer/TornadoAttackTimer
var tornado_ammo = 0
var tornado_baseammo = 5
var tornado_attackspeed = 3
var tornado_level = 1


func _ready() -> void:
	attack()


func _physics_process(delta: float) -> void:
	var x_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_direction = Input.get_action_strength("down") - Input.get_action_strength("up")
	var direction = Vector2(x_direction, y_direction)
	
	if direction.x > 0:
		animated_sprite_2d.flip_h = true
	elif direction.x < 0:
		animated_sprite_2d.flip_h = false
	
	velocity = direction.normalized() * player_speed
	if velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
	
	if direction != Vector2.ZERO:
		last_movement = direction
	
	move_and_slide()


func attack():
	if icespear_level > 0:
		ice_spear_timer.wait_time = icespear_attackspeed
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()
	if tornado_level > 0:
		tornado_timer.wait_time = tornado_attackspeed
		if tornado_timer.is_stopped():
			tornado_timer.start()


func _on_player_hurtbox_hurt(damage, _angle, _knockback) -> void:
	player_hp -= damage
	print(player_hp)


func _on_ice_spear_timer_timeout() -> void:
	icespear_ammo += icespear_baseammo
	ice_spear_attack_timer.start()


func _on_ice_spear_attack_timer_timeout() -> void:
	if icespear_ammo > 0:
		var icespear_attack = icespear.instantiate()
		icespear_attack.position = global_position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		
		if icespear_ammo > 0 and icespear_attack.target != Vector2.ZERO:
			add_child(icespear_attack)
			ice_spear_attack_timer.start()
			icespear_ammo -= 1
		else:
			icespear_ammo = 0
			ice_spear_attack_timer.stop()


func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.ZERO


func _on_enemy_detection_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_baseammo
	tornado_attack_timer.start()


func _on_tornado_attack_timer_timeout() -> void:
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = global_position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		
		if tornado_ammo > 0 and tornado_attack.last_movement != Vector2.ZERO:
			add_child(tornado_attack)
			tornado_attack_timer.start()
			tornado_ammo -= 1
		else:
			tornado_ammo = 0
			tornado_attack_timer.stop()
