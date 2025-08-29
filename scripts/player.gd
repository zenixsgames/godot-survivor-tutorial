extends CharacterBody2D


var player_speed = 100.0
var player_hp = 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var icespear = load("res://scenes/ice_spear.tscn")
@onready var ice_spear_timer: Timer = $Attack/IceSpearTimer
@onready var ice_spear_attack_timer: Timer = $Attack/IceSpearTimer/IceSpearAttackTimer


var icespear_ammo = 0
var icespear_baseammo = 3
var icespear_attackspeed = 1.5
var icespear_level = 1
var enemy_close = []


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
	
	move_and_slide()


func attack():
	if icespear_level > 0:
		ice_spear_timer.wait_time = icespear_attackspeed
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()


func _on_player_hurtbox_hurt(damage: Variant) -> void:
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
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			ice_spear_attack_timer.start()
		else:
			ice_spear_attack_timer.stop()


func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)
