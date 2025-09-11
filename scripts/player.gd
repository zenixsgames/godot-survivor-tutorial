extends CharacterBody2D


var movement_speed = 100.0
var hp = 100
var maxhp = 100
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
var tornado_baseammo = 1
var tornado_attackspeed = 3
var tornado_level = 0


var javelin = preload("res://scenes/javelin.tscn")
@onready var javelin_base: Node2D = $Attack/JavelinBase
var javelin_ammo = 0
var javelin_level = 0


var experience = 0
var experience_level = 1
var collected_exp = 0


@onready var exp_bar: TextureProgressBar = $GUILayer/GUI/ExpBar
@onready var label_level: Label = $GUILayer/GUI/ExpBar/LabelLevel


@onready var level_up_panel: Panel = $GUILayer/GUI/LevelUp
@onready var upgrade_option: VBoxContainer = $GUILayer/GUI/LevelUp/UpgradeOption
@onready var level_up_sound: AudioStreamPlayer = $GUILayer/GUI/LevelUp/LevelUpSound
@onready var item_option = preload("res://scenes/item_option.tscn")


var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0


@onready var health_bar: TextureProgressBar = $GUILayer/GUI/HealthBar
@onready var label_timer: Label = $GUILayer/GUI/LabelTimer
var time = 0


func _ready() -> void:
	attack()
	set_expbar(experience, calculate_exp_cap())
	_on_player_hurtbox_hurt(0,0,0)


func _physics_process(delta: float) -> void:
	var x_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_direction = Input.get_action_strength("down") - Input.get_action_strength("up")
	var direction = Vector2(x_direction, y_direction)
	
	if direction.x > 0:
		animated_sprite_2d.flip_h = true
	elif direction.x < 0:
		animated_sprite_2d.flip_h = false
	
	velocity = direction.normalized() * movement_speed
	if velocity == Vector2.ZERO:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
	
	if direction != Vector2.ZERO:
		last_movement = direction
	
	move_and_slide()


func attack():
	if icespear_level > 0:
		ice_spear_timer.wait_time = icespear_attackspeed * (1 - spell_cooldown)
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()
	if tornado_level > 0:
		tornado_timer.wait_time = tornado_attackspeed * (1 - spell_cooldown)
		if tornado_timer.is_stopped():
			tornado_timer.start()
	if javelin_level > 0:
		spawn_javelin()

func _on_player_hurtbox_hurt(damage, _angle, _knockback) -> void:
	hp -= clamp(damage - armor, 1.0, 999.0)
	health_bar.max_value = maxhp
	health_bar.value = hp
	print(hp)


func _on_ice_spear_timer_timeout() -> void:
	icespear_ammo += icespear_baseammo + additional_attacks
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
	tornado_ammo += tornado_baseammo + additional_attacks
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
	var calc_spawns = javelin_ammo + additional_attacks - get_javelin_total
	while  calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelin_base.add_child(javelin_spawn)
		calc_spawns -= 1
	var get_javelins = javelin_base.get_children()
	for i in get_javelins:
		if i.has_method("update_jav"):
			i.update_jav()


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_exp(gem_exp)


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
		option_choice.item = get_random_item()
		upgrade_option.add_child(option_choice)
		options += 1


func upgrade_player(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
	attack()
	var option_children = upgrade_option.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	level_up_panel.visible = false
	get_tree().paused = false
	calculate_exp(0)


func get_random_item():
	var dbList = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if n not in collected_upgrades:
					to_add = false
			if to_add:
				dbList.append(i)
		else :
			dbList.append(i)
	if dbList.size() > 0:
		var random_item = dbList.pick_random()
		upgrade_options.append(random_item)
		return random_item
	else:
		return null


func change_time(argtime = 0):
	time = argtime
	var get_m = int(time / 60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	label_timer.text = str(get_m, ':', get_s)
