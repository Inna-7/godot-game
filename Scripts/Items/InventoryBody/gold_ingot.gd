extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Gold Ingot")
	item_name = "Gold Ingot"
