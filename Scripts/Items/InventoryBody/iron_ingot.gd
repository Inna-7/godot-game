extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Iron Ingot")
	item_name = "Iron Ingot"
