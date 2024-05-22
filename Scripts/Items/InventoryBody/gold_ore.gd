extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Gold Ore")
	item_name = "Gold Ore"
