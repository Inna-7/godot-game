extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Health Potion")
	item_name = "Health Potion"
