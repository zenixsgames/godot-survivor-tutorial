extends TextureRect


var upgrade = null


func _ready() -> void:
	if upgrade != null:
		$ItemTexture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
