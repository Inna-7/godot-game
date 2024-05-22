extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Iron Ore")
	item_name = "Iron Ore"
