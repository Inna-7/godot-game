extends Node

func left_hand() -> Weapon:
	var weapon = Weapon.new()
	weapon.name = "Left Hand"
	weapon.description = "Just what you were born with!"
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1
	weapon.chance_of_critical_hit = 0.01
	weapon.chance_of_miss = 0.05
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 7
	weapon.min_damage = 1
	weapon.max_damage = 3
	weapon.item_health = 100
	#weapon.integrity_ware_and_tear
	weapon.sprite_image_file = "res://Scenes/Items/Default Inventory/left_hand.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.rarity = ""
	return weapon

func abundant_dagger() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Abundant Dagger"		#--%s" % weapon.item_health 
	weapon.description = "A simple dagger."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.03
	weapon.chance_of_miss = 0.08
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 6
	weapon.min_damage = 2
	weapon.max_damage = 5
	weapon.sprite_image_file = "res://Scenes/Items/abundant_dagger.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Abundant"
	return weapon

func common_dagger() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Common Dagger"		#--%s" % weapon.item_health 
	weapon.description = "A common dagger."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.04
	weapon.chance_of_miss = 0.07
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 5
	weapon.min_damage = 3
	weapon.max_damage = 6
	weapon.sprite_image_file = "res://Scenes/Items/common_dagger.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Common"
	return weapon

func rare_dagger() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Rare Dagger"		#--%s" % weapon.item_health 
	weapon.description = "A rare dagger."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.05
	weapon.chance_of_miss = 0.06
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 4
	weapon.min_damage = 4
	weapon.max_damage = 7
	weapon.sprite_image_file = "res://Scenes/Items/rare_dagger.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Rare"
	return weapon

func epic_dagger() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Epic Dagger"		#--%s" % weapon.item_health 
	weapon.description = "An epic dagger."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.06
	weapon.chance_of_miss = 0.05
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 3
	weapon.min_damage = 5
	weapon.max_damage = 8
	weapon.sprite_image_file = "res://Scenes/Items/epic_dagger.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Epic"
	return weapon

func legendary_dagger() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Legendary Dagger"		#--%s" % weapon.item_health 
	weapon.description = "A legendary dagger."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.07
	weapon.chance_of_miss = 0.04
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 2
	weapon.min_damage = 5
	weapon.max_damage = 8
	weapon.sprite_image_file = "res://Scenes/Items/legendary_dagger.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Legendary"
	return weapon

func mythical_dagger() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Mythical Dagger"		#--%s" % weapon.item_health 
	weapon.description = "A mythical dagger."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.08
	weapon.chance_of_miss = 0.03
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 1
	weapon.min_damage = 6
	weapon.max_damage = 9
	weapon.sprite_image_file = "res://Scenes/Items/mythical_dagger.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Mythical"
	return weapon

func abundant_sword() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Abundant Sword"	 	#--%s" % weapon.item_health 
	weapon.description = "A simple sword."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.04
	weapon.chance_of_miss = 0.07
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 7
	weapon.min_damage = 3
	weapon.max_damage = 7
	weapon.sprite_image_file = "res://Scenes/Items/abundant_sword.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Abundant"
	return weapon

func common_sword() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Common Sword"	 	#--%s" % weapon.item_health 
	weapon.description = "An common sword."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.05
	weapon.chance_of_miss = 0.06
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 6
	weapon.min_damage = 4
	weapon.max_damage = 8
	weapon.sprite_image_file = "res://Scenes/Items/common_sword.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Common"
	return weapon

func rare_sword() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Rare Sword"	 	#--%s" % weapon.item_health 
	weapon.description = "A rare sword."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.06
	weapon.chance_of_miss = 0.05
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 5
	weapon.min_damage = 5
	weapon.max_damage = 9
	weapon.sprite_image_file = "res://Scenes/Items/rare_sword.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Rare"
	return weapon

func epic_sword() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Epic Sword"	 	#--%s" % weapon.item_health 
	weapon.description = "An epic sword."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.07
	weapon.chance_of_miss = 0.04
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 4
	weapon.min_damage = 6
	weapon.max_damage = 10
	weapon.sprite_image_file = "res://Scenes/Items/epic_sword.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Epic"
	return weapon

func legendary_sword() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Legendary Sword"	 	#--%s" % weapon.item_health 
	weapon.description = "A legendary sword."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.08
	weapon.chance_of_miss = 0.03
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 3
	weapon.min_damage = 7
	weapon.max_damage = 11
	weapon.sprite_image_file = "res://Scenes/Items/legendary_sword.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Legendary"
	return weapon

func mythical_sword() -> Weapon:
	var weapon = Weapon.new()
	weapon.item_health = 100
	weapon.integrity_ware_and_tear = 1
	weapon.name = "Mythical Sword"	 	#--%s" % weapon.item_health 
	weapon.description = "A mythical sword."
	weapon.weapon_type = "Melee"
	weapon.attack_type = "Physical"
	weapon.critical_hit_multiplier = 1.1
	weapon.chance_of_critical_hit = 0.09
	weapon.chance_of_miss = 0.02
	weapon.level = 1
	weapon.level_multiplier = 1
	weapon.attack_charge_up_time_in_seconds = 2
	weapon.min_damage = 8
	weapon.max_damage = 12
	weapon.sprite_image_file = "res://Scenes/Items/mythical_sword.tscn"
	weapon.item_type = "Weapon"
	weapon.quantity = 1
	weapon.item_ID = ""
	weapon.rarity = "Mythical"
	return weapon
