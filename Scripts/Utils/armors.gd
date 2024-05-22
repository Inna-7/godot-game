extends Node


func default_armor() -> Armor:
	var armor = Armor.new()
	armor.name = "Armor"
	armor.description = "Just what you were born with!"
	armor.sprite_image_file = "res://Scenes/Items/Default Inventory/armor.tscn"
	armor.item_type = "Armor"
	armor.quantity = 1
	armor.item_state = "normal"
	armor.integrity_ware_and_tear = 0
	armor.item_ID = ""
	armor.defence_power = 0
	armor.rarity = ""
	return armor

func abundant_armor() -> Armor:
	var armor = Armor.new()
	armor.name = "Abundant Armor"
	armor.description = "Standard protection for starters"
	armor.sprite_image_file = "res://Scenes/Items/abundant_armor.tscn"
	armor.quantity = 1
	armor.item_type = "Armor"
	armor.item_state = "normal"
	armor.integrity_ware_and_tear = 1
	armor.item_ID = ""
	armor.defence_power = 1
	armor.rarity = "Abundant"
	return armor

func common_armor() -> Armor:
	var armor = Armor.new()
	armor.name = "Common Armor"
	armor.description = "Improved defense with minor perks"
	armor.sprite_image_file = "res://Scenes/Items/common_armor.tscn"
	armor.quantity = 1
	armor.item_type = "Armor"
	armor.item_state = "normal"
	armor.integrity_ware_and_tear = 1
	armor.item_ID = ""
	armor.defence_power = 2
	armor.rarity = "Common"
	return armor

func rare_armor() -> Armor:
	var armor = Armor.new()
	armor.name = "Rare Armor"
	armor.description = "Robust armor with valuable enhancements"
	armor.sprite_image_file = "res://Scenes/Items/rare_armor.tscn"
	armor.quantity = 1
	armor.item_type = "Armor"
	armor.item_state = "normal"
	armor.integrity_ware_and_tear = 1
	armor.item_ID = ""
	armor.defence_power = 3
	armor.rarity = "Rare"
	return armor

func epic_armor() -> Armor:
	var armor = Armor.new()
	armor.name = "Epic Armor"
	armor.description = "Game-changing, formidable protection"
	armor.sprite_image_file = "res://Scenes/Items/epic_armor.tscn"
	armor.quantity = 1
	armor.item_type = "Armor"
	armor.item_state = "normal"
	armor.integrity_ware_and_tear = 1
	armor.item_ID = ""
	armor.defence_power = 4
	armor.rarity = "Epic"
	return armor

func legendary_armor() -> Armor:
	var armor = Armor.new()
	armor.name = "Legendary Armor"
	armor.description = "Legendary gear of unparalleled strength"
	armor.sprite_image_file = "res://Scenes/Items/legendary_armor.tscn"
	armor.quantity = 1
	armor.item_type = "Armor"
	armor.item_state = "normal"
	armor.integrity_ware_and_tear = 1
	armor.item_ID = ""
	armor.defence_power = 5
	armor.rarity = "Legendary"
	return armor

func mythical_armor() -> Armor:
	var armor = Armor.new()
	armor.name = "Mythical Armor"
	armor.description = "Mythical armor of mythical resilience"
	armor.sprite_image_file = "res://Scenes/Items/mythical_armor.tscn"
	armor.quantity = 1
	armor.item_type = "Armor"
	armor.item_state = "normal"
	armor.integrity_ware_and_tear = 1
	armor.item_ID = ""
	armor.defence_power = 6
	armor.rarity = "Mythical"
	return armor
