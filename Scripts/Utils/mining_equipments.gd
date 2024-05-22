extends Node

func right_hand() -> MiningEquipment:
	var mining_equipment = MiningEquipment.new()
	mining_equipment.name = "Right Hand"
	mining_equipment.description = "Just what you were born with!"
	mining_equipment.multiplier = 1
	mining_equipment.mining_cooldown_time_in_seconds = 1800
	mining_equipment.sprite_image_file = "res://Scenes/Items/Default Inventory/right_hand.tscn"
	mining_equipment.item_type = "Mining Equipment"
	mining_equipment.quantity = 1
	mining_equipment.item_level = 1
	mining_equipment.mine_time = 20
	mining_equipment.item_health = 100
	mining_equipment.integrity_ware_and_tear = 0
	mining_equipment.item_state = "normal"
	mining_equipment.rarity = ""
	return mining_equipment

func abundant_shovel() -> MiningEquipment:
	var mining_equipment = MiningEquipment.new()
	mining_equipment.name = "Abundant Shovel"
	mining_equipment.description = "It's a shovel. Can you dig it?"
	mining_equipment.multiplier = 1.01
	mining_equipment.mining_cooldown_time_in_seconds = 1700
	mining_equipment.sprite_image_file = "res://Scenes/Items/abundant_shovel.tscn"
	mining_equipment.item_type = "Mining Equipment"
	mining_equipment.quantity = 1
	mining_equipment.item_level = 1
	mining_equipment.mine_time = 17
	mining_equipment.item_health = 100
	mining_equipment.integrity_ware_and_tear = 1
	mining_equipment.item_state = "normal"
	mining_equipment.rarity = "Abundant"
	return mining_equipment

func common_shovel() -> MiningEquipment:
	var mining_equipment = MiningEquipment.new()
	mining_equipment.name = "Common Shovel"
	mining_equipment.description = "It's a shovel. Can you dig it?"
	mining_equipment.multiplier = 1.01
	mining_equipment.mining_cooldown_time_in_seconds = 1600
	mining_equipment.sprite_image_file = "res://Scenes/Items/common_shovel.tscn"
	mining_equipment.item_type = "Mining Equipment"
	mining_equipment.quantity = 1
	mining_equipment.item_level = 1
	mining_equipment.mine_time = 16
	mining_equipment.item_health = 100
	mining_equipment.integrity_ware_and_tear = 1
	mining_equipment.item_state = "normal"
	mining_equipment.rarity = "Common"
	return mining_equipment

func rare_shovel() -> MiningEquipment:
	var mining_equipment = MiningEquipment.new()
	mining_equipment.name = "Rare Shovel"
	mining_equipment.description = "It's a shovel. Can you dig it?"
	mining_equipment.multiplier = 1.01
	mining_equipment.mining_cooldown_time_in_seconds = 1500
	mining_equipment.sprite_image_file = "res://Scenes/Items/rare_shovel.tscn"
	mining_equipment.item_type = "Mining Equipment"
	mining_equipment.quantity = 1
	mining_equipment.item_level = 1
	mining_equipment.mine_time = 15
	mining_equipment.item_health = 100
	mining_equipment.integrity_ware_and_tear = 1
	mining_equipment.item_state = "normal"
	mining_equipment.rarity = "Rare"
	return mining_equipment

func epic_shovel() -> MiningEquipment:
	var mining_equipment = MiningEquipment.new()
	mining_equipment.name = "Epic Shovel"
	mining_equipment.description = "It's a shovel. Can you dig it?"
	mining_equipment.multiplier = 1.01
	mining_equipment.mining_cooldown_time_in_seconds = 1400
	mining_equipment.sprite_image_file = "res://Scenes/Items/epic_shovel.tscn"
	mining_equipment.item_type = "Mining Equipment"
	mining_equipment.quantity = 1
	mining_equipment.item_level = 1
	mining_equipment.mine_time = 14
	mining_equipment.item_health = 100
	mining_equipment.integrity_ware_and_tear = 1
	mining_equipment.item_state = "normal"
	mining_equipment.rarity = "Epic"
	return mining_equipment

func legendary_shovel() -> MiningEquipment:
	var mining_equipment = MiningEquipment.new()
	mining_equipment.name = "Legendary Shovel"
	mining_equipment.description = "It's a shovel. Can you dig it?"
	mining_equipment.multiplier = 1.01
	mining_equipment.mining_cooldown_time_in_seconds = 1300
	mining_equipment.sprite_image_file = "res://Scenes/Items/legendary_shovel.tscn"
	mining_equipment.item_type = "Mining Equipment"
	mining_equipment.quantity = 1
	mining_equipment.item_level = 1
	mining_equipment.mine_time = 13
	mining_equipment.item_health = 100
	mining_equipment.integrity_ware_and_tear = 1
	mining_equipment.item_state = "normal"
	mining_equipment.rarity = "Legendary"
	return mining_equipment

func mythical_shovel() -> MiningEquipment:
	var mining_equipment = MiningEquipment.new()
	mining_equipment.name = "Mythical Shovel"
	mining_equipment.description = "It's a shovel. Can you dig it?"
	mining_equipment.multiplier = 1.01
	mining_equipment.mining_cooldown_time_in_seconds = 1200
	mining_equipment.sprite_image_file = "res://Scenes/Items/mythical_shovel.tscn"
	mining_equipment.item_type = "Mining Equipment"
	mining_equipment.quantity = 1
	mining_equipment.item_level = 1
	mining_equipment.mine_time = 12
	mining_equipment.item_health = 100
	mining_equipment.integrity_ware_and_tear = 1
	mining_equipment.item_state = "normal"
	mining_equipment.rarity = "Mythical"
	return mining_equipment
