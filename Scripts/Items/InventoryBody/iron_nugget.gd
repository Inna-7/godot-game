extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Iron Nugget")
	item_name = "Iron Nugget"
