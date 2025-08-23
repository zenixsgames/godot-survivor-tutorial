extends Node2D


@onready var icon = preload("res://icon.svg")
@onready var sprite2 = $Sprite2
@onready var sprite3 = get_node("%Sprite3")
@onready var sprite4 = get_tree().get_first_node_in_group("study")


func _ready() -> void:
	
	$Sprite1.texture = icon
	$Sprite1.position = Vector2(100,100)
	
	sprite2.texture = icon
	sprite2.position = Vector2(300,100)
	
	sprite3.texture = icon
	sprite3.position = Vector2(100,300)
	
	sprite4.texture = icon
	sprite4.position = Vector2(300,300)
