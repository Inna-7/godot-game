extends Node

#Healers
var HealthPotion : PackedScene = preload("res://Scenes/Items/health_potion.tscn")
var MagicPotion : PackedScene = preload("res://Scenes/Items/magic_potion.tscn")
var Bread : PackedScene = preload("res://Scenes/Items/bread.tscn")
#Mining equipments
var AbundantShovel : PackedScene = preload("res://Scenes/Items/abundant_shovel.tscn")
var CommonShovel : PackedScene = preload("res://Scenes/Items/common_shovel.tscn")
var RareShovel : PackedScene = preload("res://Scenes/Items/rare_shovel.tscn")
var EpicShovel : PackedScene = preload("res://Scenes/Items/epic_shovel.tscn")
var LegendaryShovel : PackedScene = preload("res://Scenes/Items/legendary_shovel.tscn")
var MythicalShovel : PackedScene = preload("res://Scenes/Items/mythical_shovel.tscn")
#Weapons
var AbundantDagger : PackedScene = preload("res://Scenes/Items/abundant_dagger.tscn")
var CommonDagger : PackedScene = preload("res://Scenes/Items/common_dagger.tscn")
var RareDagger : PackedScene = preload("res://Scenes/Items/rare_dagger.tscn")
var EpicDagger : PackedScene = preload("res://Scenes/Items/epic_dagger.tscn")
var LegendaryDagger : PackedScene = preload("res://Scenes/Items/legendary_dagger.tscn")
var MythicalDagger : PackedScene = preload("res://Scenes/Items/mythical_dagger.tscn")
var AbundantSword : PackedScene = preload("res://Scenes/Items/abundant_sword.tscn")
var CommonSword : PackedScene = preload("res://Scenes/Items/common_sword.tscn")
var RareSword : PackedScene = preload("res://Scenes/Items/rare_sword.tscn")
var EpicSword : PackedScene = preload("res://Scenes/Items/epic_sword.tscn")
var LegendarySword : PackedScene = preload("res://Scenes/Items/legendary_sword.tscn")
var MythicalSword : PackedScene = preload("res://Scenes/Items/mythical_sword.tscn")
#Helmets
var AbundantHelmet : PackedScene = preload("res://Scenes/Items/abundant_helmet.tscn")
var CommonHelmet : PackedScene = preload("res://Scenes/Items/common_helmet.tscn")
var RareHelmet : PackedScene = preload("res://Scenes/Items/rare_helmet.tscn")
var EpicHelmet : PackedScene = preload("res://Scenes/Items/epic_helmet.tscn")
var LegendaryHelmet : PackedScene = preload("res://Scenes/Items/legendary_helmet.tscn")
var MythicalHelmet : PackedScene = preload("res://Scenes/Items/mythical_helmet.tscn")
#Armors
var AbundantArmor : PackedScene = preload("res://Scenes/Items/abundant_armor.tscn")
var CommonArmor : PackedScene = preload("res://Scenes/Items/common_armor.tscn")
var RareArmor : PackedScene = preload("res://Scenes/Items/rare_armor.tscn")
var EpicArmor : PackedScene = preload("res://Scenes/Items/epic_armor.tscn")
var LegendaryArmor : PackedScene = preload("res://Scenes/Items/legendary_armor.tscn")
var MythicalArmor : PackedScene = preload("res://Scenes/Items/mythical_armor.tscn")
#Items
var Cloth : PackedScene = preload("res://Scenes/Items/cloth.tscn")
var CopperOre : PackedScene = preload("res://Scenes/Items/copper_ore.tscn")
var IronOre : PackedScene = preload("res://Scenes/Items/iron_ore.tscn")
var GoldenOre : PackedScene = preload("res://Scenes/Items/gold_ore.tscn")
var SilverOre : PackedScene = preload("res://Scenes/Items/silver_ore.tscn")
var SilverNugget : PackedScene = preload("res://Scenes/Items/silver_nugget.tscn")
var GoldNugget : PackedScene = preload("res://Scenes/Items/gold_nugget.tscn")
var IronNugget : PackedScene = preload("res://Scenes/Items/iron_nugget.tscn")
var CopperNugget : PackedScene = preload("res://Scenes/Items/copper_nugget.tscn")
var CopperIngot : PackedScene = preload("res://Scenes/Items/copper_ingot.tscn")
var IronIngot : PackedScene = preload("res://Scenes/Items/iron_ingot.tscn")
var SilverIngot : PackedScene = preload("res://Scenes/Items/silver_ingot.tscn")
var GoldIngot : PackedScene = preload("res://Scenes/Items/gold_ingot.tscn")
var Leather : PackedScene = preload("res://Scenes/Items/leather.tscn")
var WoodTreasureChest : PackedScene = preload("res://Scenes/Items/wood_chest.tscn")
#TriliumCrystals
var AbundantTriliumCrystal : PackedScene = preload("res://Scenes/Items/abundant_trilium_crystal.tscn")
var CommonTriliumCrystal : PackedScene = preload("res://Scenes/Items/common_trilium_crystal.tscn")
#Enemies
var AbundantGiantAnt : PackedScene = preload("res://Scenes/Enemy/Giant Ants/abundant_giant_ant.tscn")
var CommonGiantAnt : PackedScene = preload("res://Scenes/Enemy/Giant Ants/common_giant_ant.tscn")
var AbundantDesertScrune : PackedScene = preload("res://Scenes/Enemy/Desert Scrunes/abundant_desert_scrune.tscn")
var CommonDesertScrune : PackedScene = preload("res://Scenes/Enemy/Desert Scrunes/common_desert_scrune.tscn")
var Vuldrax : PackedScene = preload("res://Scenes/Enemy/Giant Ants/vuldrax.tscn")
var Xyloarachs : PackedScene = preload("res://Scenes/Enemy/Desert Scrunes/xyloarachs.tscn")
var Thug1 : PackedScene = preload("res://Scenes/Enemy/Thugs/thug_1.tscn")
var Thug2 : PackedScene = preload("res://Scenes/Enemy/Thugs/thug_2.tscn")
@rpc("authority")
func get_random_point_in_area(collision_shape):
	randomize()
	var shape : RectangleShape2D = collision_shape.shape
	var area_rect = shape.get_size()
	var area_pos = collision_shape.global_position
	var random_x = randf_range(area_pos.x - area_rect.x / 2, area_pos.x + area_rect.x / 2)
	var random_y = randf_range(area_pos.y - area_rect.y / 2, area_pos.y + area_rect.y / 2)
	return Vector2(random_x, random_y)
@rpc("authority")
func spawn(item_name,item_health,item_position):
	var function_name = 'spawn_' + item_name.to_lower().replace(" ", "_")
	call(function_name, item_position, item_health)
@rpc("authority")
func spawn_health_potion(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var health_potion = HealthPotion.instantiate()
	health_potion.item_health = item_health #tracker
	
	health_potion.position = item_position
	Globals.world_objects.add_child(health_potion)
	print("Health Potion spawned at location " + str(health_potion.position))
@rpc("authority")
func spawn_magic_potion(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var magic_potion = MagicPotion.instantiate()
	magic_potion.item_health = item_health #tracker
	
	magic_potion.position = item_position
	Globals.world_objects.add_child(magic_potion)
	print("Magic Potion spawned at location " + str(magic_potion.position))
@rpc("authority")
func spawn_abundant_shovel(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var abundant_shovel = AbundantShovel.instantiate()
	abundant_shovel.item_health = item_health #tracker
	
	abundant_shovel.position = item_position
	Globals.world_objects.add_child(abundant_shovel)
	print("Abundant Shovel spawned at location " + str(abundant_shovel.position))
@rpc("authority")
func spawn_common_shovel(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var common_shovel = CommonShovel.instantiate()
	common_shovel.item_health = item_health #tracker
	
	common_shovel.position = item_position
	Globals.world_objects.add_child(common_shovel)
	print("Common Shovel spawned at location " + str(common_shovel.position))
@rpc("authority")
func spawn_rare_shovel(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var rare_shovel = RareShovel.instantiate()
	rare_shovel.item_health = item_health #tracker
	
	rare_shovel.position = item_position
	Globals.world_objects.add_child(rare_shovel)
	print("Rare Shovel spawned at location " + str(rare_shovel.position))
@rpc("authority")
func spawn_epic_shovel(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var epic_shovel = EpicShovel.instantiate()
	epic_shovel.item_health = item_health #tracker
	
	epic_shovel.position = item_position
	Globals.world_objects.add_child(epic_shovel)
	print("Epic Shovel spawned at location " + str(epic_shovel.position))
@rpc("authority")
func spawn_legendary_shovel(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var legendary_shovel = LegendaryShovel.instantiate()
	legendary_shovel.item_health = item_health #tracker
	
	legendary_shovel.position = item_position
	Globals.world_objects.add_child(legendary_shovel)
	print("Legendary Shovel spawned at location " + str(legendary_shovel.position))
@rpc("authority")
func spawn_mythical_shovel(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var mythical_shovel = MythicalShovel.instantiate()
	mythical_shovel.item_health = item_health #tracker
	
	mythical_shovel.position = item_position
	Globals.world_objects.add_child(mythical_shovel)
	print("Mythical Shovel spawned at location " + str(mythical_shovel.position))
@rpc("authority")
func spawn_abundant_dagger(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var abundant_dagger = AbundantDagger.instantiate()
	abundant_dagger.item_health = item_health #tracker
	
	abundant_dagger.position = item_position
	Globals.world_objects.add_child(abundant_dagger)
	print("Abundant Dagger spawned at location " + str(abundant_dagger.position))
@rpc("authority")
func spawn_common_dagger(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var common_dagger = CommonDagger.instantiate()
	common_dagger.item_health = item_health #tracker
	
	common_dagger.position = item_position
	Globals.world_objects.add_child(common_dagger)
	print("Common Dagger spawned at location " + str(common_dagger.position))
@rpc("authority")
func spawn_rare_dagger(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var rare_dagger = RareDagger.instantiate()
	rare_dagger.item_health = item_health #tracker
	
	rare_dagger.position = item_position
	Globals.world_objects.add_child(rare_dagger)
	print("Rare Dagger spawned at location " + str(rare_dagger.position))
@rpc("authority")
func spawn_epic_dagger(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var epic_dagger = EpicDagger.instantiate()
	epic_dagger.item_health = item_health #tracker
	
	epic_dagger.position = item_position
	Globals.world_objects.add_child(epic_dagger)
	print("Epic Dagger spawned at location " + str(epic_dagger.position))
@rpc("authority")
func spawn_legendary_dagger(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var legendary_dagger = LegendaryDagger.instantiate()
	legendary_dagger.item_health = item_health #tracker
	
	legendary_dagger.position = item_position
	Globals.world_objects.add_child(legendary_dagger)
	print("Legendary Dagger spawned at location " + str(legendary_dagger.position))
@rpc("authority")
func spawn_mythical_dagger(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var mythical_dagger = MythicalDagger.instantiate()
	mythical_dagger.item_health = item_health #tracker
	
	mythical_dagger.position = item_position
	Globals.world_objects.add_child(mythical_dagger)
	print("Mythical Dagger spawned at location " + str(mythical_dagger.position))
@rpc("authority")
func spawn_abundant_sword(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var abundant_sword = AbundantSword.instantiate()
	abundant_sword.item_health = item_health #tracker
	
	abundant_sword.position = item_position
	Globals.world_objects.add_child(abundant_sword)
	print("Abundant Sword spawned at location " + str(abundant_sword.position))
@rpc("authority")
func spawn_common_sword(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var common_sword = CommonSword.instantiate()
	common_sword.item_health = item_health #tracker
	
	common_sword.position = item_position
	Globals.world_objects.add_child(common_sword)
	print("Common Sword spawned at location " + str(common_sword.position))
@rpc("authority")
func spawn_rare_sword(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var rare_sword = RareSword.instantiate()
	rare_sword.item_health = item_health #tracker
	
	rare_sword.position = item_position
	Globals.world_objects.add_child(rare_sword)
	print("Rare Sword spawned at location " + str(rare_sword.position))
@rpc("authority")
func spawn_epic_sword(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var epic_sword = EpicSword.instantiate()
	epic_sword.item_health = item_health #tracker
	
	epic_sword.position = item_position
	Globals.world_objects.add_child(epic_sword)
	print("Epic Sword spawned at location " + str(epic_sword.position))
@rpc("authority")
func spawn_legendary_sword(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var legendary_sword = LegendarySword.instantiate()
	legendary_sword.item_health = item_health #tracker
	
	legendary_sword.position = item_position
	Globals.world_objects.add_child(legendary_sword)
	print("Legendary Sword spawned at location " + str(legendary_sword.position))
@rpc("authority")
func spawn_mythical_sword(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var mythical_sword = MythicalSword.instantiate()
	mythical_sword.item_health = item_health #tracker
	
	mythical_sword.position = item_position
	Globals.world_objects.add_child(mythical_sword)
	print("Mythical Sword spawned at location " + str(mythical_sword.position))
@rpc("authority")
func spawn_abundant_helmet(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var abundant_helmet = AbundantHelmet.instantiate()
	abundant_helmet.item_health = item_health #tracker
	
	abundant_helmet.position = item_position
	Globals.world_objects.add_child(abundant_helmet)
	print("Abundant Helmet spawned at location " + str(abundant_helmet.position))
@rpc("authority")
func spawn_common_helmet(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return 
	var common_helmet = CommonHelmet.instantiate()
	common_helmet.item_health = item_health #tracker
	
	common_helmet.position = item_position
	Globals.world_objects.add_child(common_helmet)
	print("Common Helmet spawned at location " + str(common_helmet.position))
@rpc("authority")
func spawn_rare_helmet(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var rare_helmet = RareHelmet.instantiate()
	rare_helmet.item_health = item_health #tracker
	
	rare_helmet.position = item_position
	Globals.world_objects.add_child(rare_helmet)
	print("Rare Helmet spawned at location " + str(rare_helmet.position))
@rpc("authority")
func spawn_epic_helmet(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var epic_helmet = EpicHelmet.instantiate()
	epic_helmet.item_health = item_health #tracker
	
	epic_helmet.position = item_position
	Globals.world_objects.add_child(epic_helmet)
	print("Epic Helmet spawned at location " + str(epic_helmet.position))
@rpc("authority")
func spawn_legendary_helmet(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var legendary_helmet = LegendaryHelmet.instantiate()
	legendary_helmet.item_health = item_health #tracker
	
	legendary_helmet.position = item_position
	Globals.world_objects.add_child(legendary_helmet)
	print("Legendary Helmet spawned at location " + str(legendary_helmet.position))
@rpc("authority")
func spawn_mythical_helmet(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var mythical_helmet = MythicalHelmet.instantiate()
	mythical_helmet.item_health = item_health #tracker
	
	mythical_helmet.position = item_position
	Globals.world_objects.add_child(mythical_helmet)
	print("Mythical Helmet spawned at location " + str(mythical_helmet.position))
@rpc("authority")
func spawn_abundant_armor(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var abundant_armor = AbundantArmor.instantiate()
	abundant_armor.item_health = item_health #tracker
	
	abundant_armor.position = item_position
	Globals.world_objects.add_child(abundant_armor)
	print("Abundant Armor spawned at location " + str(abundant_armor.position))
@rpc("authority")
func spawn_common_armor(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var common_armor = CommonArmor.instantiate()
	common_armor.item_health = item_health #tracker
	
	common_armor.position = item_position
	Globals.world_objects.add_child(common_armor)
	print("Common Armor spawned at location " + str(common_armor.position))
@rpc("authority")
func spawn_rare_armor(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var rare_armor = RareArmor.instantiate()
	rare_armor.item_health = item_health #tracker
	
	rare_armor.position = item_position
	Globals.world_objects.add_child(rare_armor)
	print("Rare Armor spawned at location " + str(rare_armor.position))
@rpc("authority")
func spawn_epic_armor(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var epic_armor = EpicArmor.instantiate()
	epic_armor.item_health = item_health #tracker
	
	epic_armor.position = item_position
	Globals.world_objects.add_child(epic_armor)
	print("Epic Armor spawned at location " + str(epic_armor.position))
@rpc("authority")
func spawn_legendary_armor(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var legendary_armor = LegendaryArmor.instantiate()
	legendary_armor.item_health = item_health #tracker
	
	legendary_armor.position = item_position
	Globals.world_objects.add_child(legendary_armor)
	print("Legendary Armor spawned at location " + str(legendary_armor.position))
@rpc("authority")
func spawn_mythical_armor(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var mythical_armor = MythicalArmor.instantiate()
	mythical_armor.item_health = item_health #tracker
	
	mythical_armor.position = item_position
	Globals.world_objects.add_child(mythical_armor)
	print("Mythical Armor spawned at location " + str(mythical_armor.position))
@rpc("authority")
func spawn_copper_ore(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var copper_ore = CopperOre.instantiate()
	copper_ore.item_health = item_health #tracker
	
	copper_ore.position = item_position
	Globals.world_objects.add_child(copper_ore)
	print("Copper Ore spawned at location " + str(copper_ore.position))
@rpc("authority")
func spawn_iron_ore(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var iron_ore = IronOre.instantiate()
	iron_ore.item_health = item_health #tracker
	
	iron_ore.position = item_position
	Globals.world_objects.add_child(iron_ore)
	print("Iron Ore spawned at location " + str(iron_ore.position))
@rpc("authority")
func spawn_gold_ore(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var gold_ore = GoldenOre.instantiate()
	gold_ore.item_health = item_health #tracker
	
	gold_ore.position = item_position
	Globals.world_objects.add_child(gold_ore)
	print("Gold Ore spawned at location " + str(gold_ore.position))
@rpc("authority")
func spawn_silver_ore(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var silver_ore = SilverOre.instantiate()
	silver_ore.item_health = item_health #tracker
	
	silver_ore.position = item_position
	Globals.world_objects.add_child(silver_ore)
	print("Silver Ore spawned at location " + str(silver_ore.position))
@rpc("authority")
func spawn_copper_ingot(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var copper_ingot = CopperIngot.instantiate()
	copper_ingot.item_health = item_health #tracker
	
	copper_ingot.position = item_position
	Globals.world_objects.add_child(copper_ingot)
	print("Copper Ingot spawned at location " + str(copper_ingot.position))
@rpc("authority")
func spawn_iron_ingot(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var iron_ingot = IronIngot.instantiate()
	iron_ingot.item_health = item_health #tracker
	
	iron_ingot.position = item_position
	Globals.world_objects.add_child(iron_ingot)
	print("Iron Ingot spawned at location " + str(iron_ingot.position))
@rpc("authority")
func spawn_silver_ingot(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var silver_ingot = SilverIngot.instantiate()
	silver_ingot.item_health = item_health #tracker
	
	silver_ingot.position = item_position
	Globals.world_objects.add_child(silver_ingot)
	print("Silver Ingot spawned at location " + str(silver_ingot.position))
@rpc("authority")
func spawn_gold_ingot(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var gold_ingot = Cloth.instantiate()
	gold_ingot.item_health = item_health #tracker
	
	gold_ingot.position = item_position
	Globals.world_objects.add_child(gold_ingot)
	print("Gold Ingot spawned at location " + str(gold_ingot.position))
@rpc("authority")
func spawn_silver_nugget(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var silver_nugget = SilverNugget.instantiate()
	silver_nugget.item_health = item_health #tracker
	
	silver_nugget.position = item_position
	Globals.world_objects.add_child(silver_nugget)
	print("Silver Nugget spawned at location " + str(silver_nugget.position))
@rpc("authority")
func spawn_gold_nugget(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var gold_nugget = GoldNugget.instantiate()
	gold_nugget.item_health = item_health #tracker
	
	gold_nugget.position = item_position
	Globals.world_objects.add_child(gold_nugget)
	print("Gold Nugget spawned at location " + str(gold_nugget.position))
@rpc("authority")
func spawn_copper_nugget(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var copper_nugget = CopperNugget.instantiate()
	copper_nugget.item_health = item_health #tracker
	
	copper_nugget.position = item_position
	Globals.world_objects.add_child(copper_nugget)
	print("Copper Nugget spawned at location " + str(copper_nugget.position))
@rpc("authority")
func spawn_iron_nugget(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var iron_nugget = IronNugget.instantiate()
	iron_nugget.item_health = item_health #tracker
	
	iron_nugget.position = item_position
	Globals.world_objects.add_child(iron_nugget)
	print("Iron Nugget spawned at location " + str(iron_nugget.position))
@rpc("authority")
func spawn_leather(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var leather = Leather.instantiate()
	leather.item_health = item_health #tracker
	
	leather.position = item_position
	Globals.world_objects.add_child(leather)
	print("Leather spawned at location " + str(leather.position))
@rpc("authority")
func spawn_cloth(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var cloth = Cloth.instantiate()
	cloth.item_health = item_health #tracker
	
	cloth.position = item_position
	Globals.world_objects.add_child(cloth)
	print("Cloth spawned at location " + str(cloth.position))
@rpc("authority")
func spawn_bread(item_position,item_health):
	if not Globals.multiplayer.is_server():
		return
	var bread = Bread.instantiate()
	bread.item_health = item_health #tracker
	
	bread.position = item_position
	Globals.world_objects.add_child(bread)
	print("Bread spawned at location " + str(bread.position))
@rpc("authority")
func spawn_wood_treasure_chest(item_position):
	if not Globals.multiplayer.is_server():
		return
	var wood_chest = WoodTreasureChest.instantiate()
	
	wood_chest.position = item_position
	Globals.world_objects.add_child(wood_chest)
	print("Wood Treasure Chest spawned at location " + str(wood_chest.position))
@rpc("authority")
func spawn_abundant_trilium_crystal(item_position):
	if not Globals.multiplayer.is_server():
		return
	var abundant_trilium_crystal = AbundantTriliumCrystal.instantiate()
	
	abundant_trilium_crystal.position = item_position
	Globals.world_objects.add_child(abundant_trilium_crystal)
	print("Abundant Trilium Crystal spawned at location " + str(abundant_trilium_crystal.position))
@rpc("authority")
func spawn_common_trilium_crystal(item_position):
	if not Globals.multiplayer.is_server():
		return
	var common_trilium_crystal = CommonTriliumCrystal.instantiate()
	
	common_trilium_crystal.position = item_position
	Globals.world_objects.add_child(common_trilium_crystal)
	print("Common Trilium Crystal spawned at location " + str(common_trilium_crystal.position))
@rpc("authority")
func spawn_abundant_giant_ant(item_position):
	if not Globals.multiplayer.is_server():
		return
	var abundant_giant_ant = AbundantGiantAnt.instantiate()
	
	abundant_giant_ant.position = item_position
	Globals.world_objects.add_child(abundant_giant_ant)
	print("Abundant Giant Ant spawned at location " + str(abundant_giant_ant.position))
@rpc("authority")
func spawn_common_giant_ant(item_position):
	if not Globals.multiplayer.is_server():
		return
	var common_giant_ant = CommonGiantAnt.instantiate()
	
	common_giant_ant.position = item_position
	Globals.world_objects.add_child(common_giant_ant)
	print("Common Giant Ant spawned at location " + str(common_giant_ant.position))
@rpc("authority")
func spawn_abundant_desert_scrune(item_position):
	if not Globals.multiplayer.is_server():
		return
	var abundant_desert_scrune = AbundantDesertScrune.instantiate()
	
	abundant_desert_scrune.position = item_position
	Globals.world_objects.add_child(abundant_desert_scrune)
	print("Abundant Desert Scrune spawned at location " + str(abundant_desert_scrune.position))
@rpc("authority")
func spawn_common_desert_scrune(item_position):
	if not Globals.multiplayer.is_server():
		return
	var common_desert_scrune = CommonDesertScrune.instantiate()
	
	common_desert_scrune.position = item_position
	Globals.world_objects.add_child(common_desert_scrune)
	print("Common Desert Scrune spawned at location " + str(common_desert_scrune.position))
@rpc("authority")
func spawn_xyloarachs(item_position):
	if not Globals.multiplayer.is_server():
		return
	var xyloarachs = Xyloarachs.instantiate()
	
	xyloarachs.position = item_position
	Globals.world_objects.add_child(xyloarachs)
	print("Xyloarachs spawned at location " + str(xyloarachs.position))
@rpc("authority")
func spawn_vuldrax(item_position):
	if not Globals.multiplayer.is_server():
		return
	var vuldrax = Vuldrax.instantiate()
	
	vuldrax.position = item_position
	Globals.world_objects.add_child(vuldrax)
	print("Vuldrax spawned at location " + str(vuldrax.position))
@rpc("authority")
func spawn_thug1(thug_name,weapon_name,thug_position):
	if not Globals.multiplayer.is_server():
		return
	var thug1 = Thug1.instantiate()
	thug1.name = thug_name
	thug1.position = thug_position
	if weapon_name == "Left Hand":
		thug1.sync_equipped_weapon = Weapons.left_hand()
	elif weapon_name == "Abundant Dagger":
		thug1.sync_equipped_weapon = Weapons.abundant_dagger()
	elif weapon_name == "Common Dagger":
		thug1.sync_equipped_weapon = Weapons.common_dagger()
	elif weapon_name == "Rare Dagger":
		thug1.sync_equipped_weapon = Weapons.rare_dagger()
	elif weapon_name == "Epic Dagger":
		thug1.sync_equipped_weapon = Weapons.epic_dagger()
	elif weapon_name == "Legendary Dagger":
		thug1.sync_equipped_weapon = Weapons.legendary_dagger()
	elif weapon_name == "Mythical Dagger":
		thug1.sync_equipped_weapon = Weapons.mythical_dagger()
	elif weapon_name == "Abundant Sword":
		thug1.sync_equipped_weapon = Weapons.abundant_sword()
	elif weapon_name == "Common Sword":
		thug1.sync_equipped_weapon = Weapons.common_sword()
	elif weapon_name == "Rare Sword":
		thug1.sync_equipped_weapon = Weapons.rare_sword()
	elif weapon_name == "Epic Sword":
		thug1.sync_equipped_weapon = Weapons.epic_sword()
	elif weapon_name == "Legendary Sword":
		thug1.sync_equipped_weapon = Weapons.legendary_sword()
	elif weapon_name == "Mythical Sword":
		thug1.sync_equipped_weapon = Weapons.mythical_sword()
	Globals.world_objects.add_child(thug1)
	print("Thug 1 spawned at location" + str(thug1.position))
@rpc("authority")
func spawn_thug2(thug_name,weapon_name,thug_position):
	if not Globals.multiplayer.is_server():
		return
	var thug2 = Thug2.instantiate()
	thug2.name = thug_name
	thug2.position = thug_position
	if weapon_name == "Left Hand":
		thug2.sync_equipped_weapon = Weapons.left_hand()
	elif weapon_name == "Abundant Dagger":
		thug2.sync_equipped_weapon = Weapons.abundant_dagger()
	elif weapon_name == "Common Dagger":
		thug2.sync_equipped_weapon = Weapons.common_dagger()
	elif weapon_name == "Rare Dagger":
		thug2.sync_equipped_weapon = Weapons.rare_dagger()
	elif weapon_name == "Epic Dagger":
		thug2.sync_equipped_weapon = Weapons.epic_dagger()
	elif weapon_name == "Legendary Dagger":
		thug2.sync_equipped_weapon = Weapons.legendary_dagger()
	elif weapon_name == "Mythical Dagger":
		thug2.sync_equipped_weapon = Weapons.mythical_dagger()
	elif weapon_name == "Abundant Sword":
		thug2.sync_equipped_weapon = Weapons.abundant_sword()
	elif weapon_name == "Common Sword":
		thug2.sync_equipped_weapon = Weapons.common_sword()
	elif weapon_name == "Rare Sword":
		thug2.sync_equipped_weapon = Weapons.rare_sword()
	elif weapon_name == "Epic Sword":
		thug2.sync_equipped_weapon = Weapons.epic_sword()
	elif weapon_name == "Legendary Sword":
		thug2.sync_equipped_weapon = Weapons.legendary_sword()
	elif weapon_name == "Mythical Sword":
		thug2.sync_equipped_weapon = Weapons.mythical_sword()
	Globals.world_objects.add_child(thug2)
	print("Thug 2 spawned at location" + str(thug2.position))
