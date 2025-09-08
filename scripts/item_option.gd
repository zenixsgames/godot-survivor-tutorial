extends ColorRect


var mouse_over = false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")


signal selected_upgrade(upgrade)


func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_player"))


func _input(event: InputEvent) -> void:
	if event.is_action("click"):
		if mouse_over:
			emit_signal("selected_upgrade", item)


func _on_mouse_entered() -> void:
	mouse_over = true


func _on_mouse_exited() -> void:
	mouse_over = false
