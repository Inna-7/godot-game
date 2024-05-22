extends Node

func default_helmet() -> Helmet:
	var helmet = Helmet.new()
	helmet.name = "Helmet"
	helmet.description = "Just what you were born with!"
	helmet.sprite_image_file = "res://Scenes/Items/Default Inventory/helmet.tscn"
	helmet.item_type = "Helmet"
	helmet.quantity = 1
	helmet.item_state = "normal"
	helmet.item_health = 100
	helmet.integrity_ware_and_tear = 0
	helmet.defence_power = 0
	helmet.rarity = ""
	return helmet
	
func abundant_helmet() -> Helmet:
	var helmet = Helmet.new()
	helmet.name = "Abundant Helmet"
	helmet.description = "Basic head protection for beginners"
	helmet.sprite_image_file = "res://Scenes/Items/abundant_helmet.tscn"
	helmet.quantity = 1
	helmet.item_type = "Helmet"
	helmet.item_state = "normal"
	helmet.item_health = 100
	helmet.integrity_ware_and_tear = 1
	helmet.defence_power = 1
	helmet.rarity = "Abundant"
	return helmet

func common_helmet() -> Helmet:
	var helmet = Helmet.new()
	helmet.name = "Common Helmet"
	helmet.description = "Enhanced defense with minor bonuses"
	helmet.sprite_image_file = "res://Scenes/Items/common_helmet.tscn"
	helmet.quantity = 1
	helmet.item_type = "Helmet"
	helmet.item_state = "normal"
	helmet.item_health = 100
	helmet.integrity_ware_and_tear = 1
	helmet.defence_power = 2
	helmet.rarity = "Common"
	return helmet

func rare_helmet() -> Helmet:
	var helmet = Helmet.new()
	helmet.name = "Rare Helmet"
	helmet.description = "Solid protection, valuable buffs"
	helmet.sprite_image_file = "res://Scenes/Items/rare_helmet.tscn"
	helmet.quantity = 1
	helmet.item_type = "Helmet"
	helmet.item_state = "normal"
	helmet.item_health = 100
	helmet.integrity_ware_and_tear = 1
	helmet.defence_power = 3
	helmet.rarity = "Rare"
	return helmet

func epic_helmet() -> Helmet:
	var helmet = Helmet.new()
	helmet.name = "Epic Helmet"
	helmet.description = "Powerful, game-changing headgear"
	helmet.sprite_image_file = "res://Scenes/Items/epic_helmet.tscn"
	helmet.quantity = 1
	helmet.item_type = "Helmet"
	helmet.item_state = "normal"
	helmet.item_health = 100
	helmet.integrity_ware_and_tear = 1
	helmet.defence_power = 4
	helmet.rarity = "Epic"
	return helmet

func legendary_helmet() -> Helmet:
	var helmet = Helmet.new()
	helmet.name = "Legendary Helmet"
	helmet.description = "Legendary helm of ultimate power"
	helmet.sprite_image_file = "res://Scenes/Items/legendary_helmet.tscn"
	helmet.quantity = 1
	helmet.item_type = "Helmet"
	helmet.item_state = "normal"
	helmet.item_health = 100
	helmet.integrity_ware_and_tear = 1
	helmet.defence_power = 5
	helmet.rarity = "Legendary"
	return helmet

func mythical_helmet() -> Helmet:
	var helmet = Helmet.new()
	helmet.name = "Mythical Helmet"
	helmet.description = "Mythical helm of untold might"
	helmet.sprite_image_file = "res://Scenes/Items/mythical_helmet.tscn"
	helmet.quantity = 1
	helmet.item_type = "Helmet"
	helmet.item_state = "normal"
	helmet.item_health = 100
	helmet.integrity_ware_and_tear = 1
	helmet.defence_power = 6
	helmet.rarity = "Mythical"
	return helmet
