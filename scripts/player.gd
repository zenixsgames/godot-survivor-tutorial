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
var tornado_level = 0


var javelin = preload("res://scenes/javelin.tscn")
@onready var javelin_base: Node2D = $Attack/JavelinBase
var javelin_ammo = 3
var javelin_level = 1


var experience = 0
var experience_level = 1
var collected_exp = 0


@onready var exp_bar: TextureProgressBar = $GUILayer/GUI/ExpBar
@onready var label_level: Label = $GUILayer/GUI/ExpBar/LabelLevel


@onready var level_up_panel: Panel = $GUILayer/GUI/LevelUp
@onready var upgrade_options: VBoxContainer = $GUILayer/GUI/LevelUp/UpgradeOptions
@onready var level_up_sound: AudioStreamPlayer = $GUILayer/GUI/LevelUp/LevelUpSound


@onready var item_option = preload("res://scenes/item_option.tscn")


func _ready() -> void:
	attack()
	set_expbar(experience, calculate_exp_cap())


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
	if javelin_level > 0:
		spawn_javelin()

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


func spawn_javelin():
	var get_javelin_total = javelin_base.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total
	while  calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelin_base.add_child(javelin_spawn)
		calc_spawns -= 1


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self
	pass # Replace with function body.


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_exp(gem_exp)
	pass # Replace with function body.


func calculate_exp(gem_exp):
	var exp_required = calculate_exp_cap()
	collected_exp += gem_exp
	if experience + collected_exp >= exp_required:
		collected_exp -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_exp_cap()
		levelup()
	else:
		experience += collected_exp
		collected_exp = 0
	set_expbar(experience, exp_required)


func calculate_exp_cap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 * (experience_level - 19) * 8
	else:
		exp_cap = 255 * (experience_level - 39) * 12
	
	return exp_cap


func set_expbar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value


func levelup():
	level_up_sound.play()
	label_level.text = str("Level: ", experience_level)
	level_up_panel.call_deferred("set","visible",true)
	get_tree().paused = true
	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice = item_option.instantiate()
		upgrade_options.add_child(option_choice)
		options += 1


func upgrade_player(upgrade):
	var option_children = upgrade_options.get_children()
	for i in option_children:
		i.queue_free()
	level_up_panel.visible = false
	get_tree().paused = false
	calculate_exp(0)
	
