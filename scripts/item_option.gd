extends ColorRect


var mouse_over = false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")


@onready var label_name: Label = $LabelName
@onready var label_description: Label = $LabelDescription
@onready var label_level: Label = $LabelLevel
@onready var item_icon: TextureRect = $ColorRect/ItemIcon


signal selected_upgrade(upgrade)


func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_player"))
	if item == null:
		item = "food"
	label_name.text = UpgradeDb.UPGRADES[item]["displayname"]
	label_description.text = UpgradeDb.UPGRADES[item]["details"]
	label_level.text = UpgradeDb.UPGRADES[item]["level"]
	item_icon.texture = load(UpgradeDb.UPGRADES[item]["icon"])


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("click"):
		emit_signal("selected_upgrade", item)
