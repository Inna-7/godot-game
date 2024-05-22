extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Magic Potion")
	item_name = "Magic Potion"
