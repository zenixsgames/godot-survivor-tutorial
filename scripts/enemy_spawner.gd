extends Node2D


@export var spawn_arr: Array[Spawn_info]
@onready var player = get_tree().get_first_node_in_group("player")
var time = 299


signal changetime(time)


func _ready() -> void:
	connect("changetime", Callable(player, "change_time"))
	#spawn_arr.append(load("res://resoures/new_resource.tres"))


func _on_timer_timeout() -> void:
	time += 1
	for i in spawn_arr:
		if time >= i.time_start and time <= i.time_end:
			i.spawn_delay_counter += 1
			if i.spawn_delay_counter >= i.enemy_spawn_delay:
				i.spawn_delay_counter = 0
				var count = 0
				while i.enemy_num > count:
					var tmp_enemy = i.enemy.instantiate()
					tmp_enemy.global_position = get_rand_pos()
					add_child(tmp_enemy)
					count += 1
	emit_signal("changetime", time)


func get_rand_pos():
	var viewport_rect_size = get_viewport_rect().size * 0.6
	var pos_side = ["north", "south", "east", "west"].pick_random()
	var rand_pos: Vector2
	match pos_side:
		"north":
			rand_pos = Vector2(
				player.global_position.x + randf_range(-viewport_rect_size.x, viewport_rect_size.x),
				player.global_position.y - viewport_rect_size.y
			)
		"south":
			rand_pos = Vector2(
				player.global_position.x + randf_range(-viewport_rect_size.x, viewport_rect_size.x),
				player.global_position.y + viewport_rect_size.y
			)
		"east":
			rand_pos = Vector2(
				player.global_position.x + viewport_rect_size.x,
				player.global_position.y + randf_range(-viewport_rect_size.y, viewport_rect_size.y)
			)
		"west":
			rand_pos = Vector2(
				player.global_position.x - viewport_rect_size.x,
				player.global_position.y + randf_range(-viewport_rect_size.y, viewport_rect_size.y)
			)
	return rand_pos
