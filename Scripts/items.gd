extends Node

func health_potion() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Health Potion"
	item.description = "Restores 25 HP"
	item.sprite_image_file = "res://Scenes/Items/health_potion.tscn"
	item.quantity = 1
	item.item_type = "Consumable"
	item.item_level = 1
	item.rarity = ""
	return item

func magic_potion() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Magic Potion"
	item.description = "Restores 5 MP"
	item.sprite_image_file = "res://Scenes/Items/magic_potion.tscn"
	item.quantity = 1
	item.item_type = "Consumable"
	item.item_level = 1
	item.rarity = ""
	return item

func bread() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Bread"
	item.description = "Regenerates 25 HP over the course of one minute."
	item.sprite_image_file = "res://Scenes/Items/bread.tscn"
	item.quantity = 1
	item.item_type = "Consumable"
	item.item_level = 1
	item.rarity = ""
	return item

func cloth() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Cloth"
	item.description = "Light, versatile fabric protection"
	item.sprite_image_file = "res://Scenes/Items/cloth.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func copper_nugget() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Copper Nugget"
	item.description = "Basic and versatile metal resource"
	item.sprite_image_file = "res://Scenes/Items/copper_nugget.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func copper_ore() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Copper Ore"
	item.description = "Abundant and malleable metal source"
	item.sprite_image_file = "res://Scenes/Items/copper_ore.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func copper_ingot() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Copper Ingot"
	item.description = "Basic, versatile metal casting"
	item.sprite_image_file = "res://Scenes/Items/copper_ingot.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func gold_nugget() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Gold Nugget"
	item.description = "Valuable, rare crafting material"
	item.sprite_image_file = "res://Scenes/Items/gold_nugget.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item	

func gold_ore() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Gold Ore"
	item.description = "Rare and valuable source of wealth"
	item.sprite_image_file = "res://Scenes/Items/gold_ore.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func gold_ingot() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Gold Ingot"
	item.description = "Valuable, gleaming wealth in metal form"
	item.sprite_image_file = "res://Scenes/Items/gold_ingot.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	item.rarity = ""
	return item

func iron_nugget() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Iron Nugget"
	item.description = "Sturdy foundation for crafting"
	item.sprite_image_file = "res://Scenes/Items/iron_nugget.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func iron_ore() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Iron Ore"
	item.description = "Foundational material for sturdy items"
	item.sprite_image_file = "res://Scenes/Items/iron_ore.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func iron_ingot() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Iron Ingot"
	item.description = "Strong, essential material for forging"
	item.sprite_image_file = "res://Scenes/Items/iron_ingot.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func silver_nugget() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Silver Nugget"
	item.description = "Precious metal for advanced creations"
	item.sprite_image_file = "res://Scenes/Items/silver_nugget.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func silver_ore() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Silver Ore"
	item.description = "Shiny, precious metal waiting to be refined"
	item.sprite_image_file = "res://Scenes/Items/silver_ore.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func silver_ingot() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Silver Ingot"
	item.description = "Precious, refined metal for intricate work"
	item.sprite_image_file = "res://Scenes/Items/silver_ingot.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item

func leather() -> InventoryItem:
	var item = InventoryItem.new()
	item.name = "Leather"
	item.description = "Versatile material for crafting gear"
	item.sprite_image_file = "res://Scenes/Items/leather.tscn"
	item.quantity = 1
	item.item_type = "Crafting"
	item.item_state = "normal"
	item.item_level = 1
	item.rarity = ""
	return item
