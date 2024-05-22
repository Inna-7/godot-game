extends InventoryStaticBody

func _ready():
	call_deferred("set_name", "Bread")
	item_name = "Bread"

