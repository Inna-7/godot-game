extends Node2D

var item_state : String
var self_name : String
var item_ID : String
var item_health : int
var collection_name : String

func _ready():
	pass
	
func set_use_button_text(text):
	$action_keys_hold/ButtonUse.text = text

func set_item_id(id):
	item_ID = id


func set_item_health(health):
	item_health = health

func set_item_name(item_name):
	$action_keys_hold/ItemName.text = item_name
	$in_crafting_keys/ItemName.text = item_name
	self_name = item_name

func set_item_collection(collection):
	if collection == "triliumquest":
		$action_keys_hold/ItemCollection.text = "Trilium Quest"
		$in_crafting_keys/ItemCollection.text = "Trilium Quest"
	else:
		$action_keys_hold/ItemCollection.text = "Alien Worlds"
		$in_crafting_keys/ItemCollection.text = "Alien Worlds"
	collection_name = collection

func set_item_sprite_image(sprite_file_name):
	var SpriteObject : PackedScene = load(sprite_file_name)
	if SpriteObject != null:
		var sprite = SpriteObject.instantiate()
		$SpritePlaceHolder.add_child(sprite)


func set_item_quantity(qty):
	$Panel/ItemQuantity.text = str(qty)
	$Panel/ItemQuantity2.text = str(qty)
	
	
func set_item_state(state: String):
	item_state = state

func set_quantity_display(state: bool):
	$Panel/ItemQuantity.visible = !state
	$Panel/ItemQuantity2.visible = state
	$Panel/CraftingTotal.visible = state

func set_item_level(item_level):
	$action_keys_hold/ItemLevel.text = "LVL: %s" % item_level
	
func set_damage_display(x):
	$Panel/ItemDamage.visible = true
	$Panel/ItemDamage.text = str(x)
	
func _use_health():
	for item in Globals.player.sync_inventory:
		if (item.item_ID == item_ID):
			Globals.player._add_hp(25)
			return
		else:
			print("couldnot find health of id:"+item_ID)

func _use_magic():
	for item in Globals.player.sync_inventory:
		if (item.item_ID == item_ID):
			Globals.player._add_mp(5)
			return
		else:
			print("couldnot find magic of id:"+item_ID)

func _update_damage(damage_item_ID):
	for i in Globals.player.sync_inventory:
		if i.item_type == "Weapon" and i.item_ID == damage_item_ID:
			Globals.player.sync_equipped_weapon.item_health = i.item_health
		elif i.item_type == "Mining Equipment" and i.item_ID == damage_item_ID:
			Globals.player.sync_equipped_mining_equipment.item_health = i.item_health
		elif i.item_type == "Helmet" and i.item_ID == damage_item_ID:
			Globals.player.sync_equipped_helmet.item_health = i.item_health
		elif i.item_type == "Armor" and i.item_ID == damage_item_ID:
			Globals.player.sync_equipped_armor.item_health = i.item_health

func _on_button_use_pressed():
	if Globals.player == null:
		return
	var item_name : String = $action_keys_hold/ItemName.text
	#CONSUMABLES:
	if item_name.contains("Health Potion"):
		if not Globals.player.in_battle:
			_use_health()
			print("health used since player not in battle")
			Globals.player.play_magic_healing_sound_effect()
		else:
			if Globals.player.battle_charge_up_timer.is_stopped():
				_use_health()
				print("health used since battle charge up timer is stopped?!?")
				Globals.player.play_magic_healing_sound_effect()
				Globals.player.battle_charge_up_timer.wait_time = Globals.player.sync_equipped_weapon.attack_charge_up_time_in_seconds
				Globals.player.battle_charge_up_timer.one_shot = true
				Globals.player.battle_charge_up_timer.start()
				Globals.hud.attack_button.disabled = true
			else :
				print("not used health but still subtracted the item!!")
	if item_name.contains("Magic Potion"):
		if not Globals.player.in_battle:
			_use_magic()
			print("magic used since player not in battle")
			Globals.player.play_magic_healing_sound_effect()
		else:
			if Globals.player.battle_charge_up_timer.is_stopped():
				_use_health()
				print("magic used since battle charge up timer is stopped?!?")
				Globals.player.play_magic_healing_sound_effect()
				Globals.player.battle_charge_up_timer.wait_time = Globals.player.sync_equipped_weapon.attack_charge_up_time_in_seconds
				Globals.player.battle_charge_up_timer.one_shot = true
				Globals.player.battle_charge_up_timer.start()
				Globals.hud.attack_button.disabled = true
			else :
				print("not used magic but still subtracted the item!!")
	if item_name.contains("Bread"):
		Globals.player.increase_hp_over_time(25, 60.0)
		Globals.player.play_apple_bite_sound_effect()
	
	#EQUIPMENT:
	if item_name.contains("Abundant Dagger"):
		Globals.player.sync_equipped_weapon = Weapons.abundant_dagger()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Common Dagger"):
		Globals.player.sync_equipped_weapon = Weapons.common_dagger()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Rare Dagger"):
		Globals.player.sync_equipped_weapon = Weapons.rare_dagger()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Epic Dagger"):
		Globals.player.sync_equipped_weapon = Weapons.epic_dagger()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Legendary Dagger"):
		Globals.player.sync_equipped_weapon = Weapons.legendary_dagger()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Mythical Dagger"):
		Globals.player.sync_equipped_weapon = Weapons.mythical_dagger()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Abundant Sword"):
		Globals.player.sync_equipped_weapon = Weapons.abundant_sword()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Common Sword"):
		Globals.player.sync_equipped_weapon = Weapons.common_sword()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Rare Sword"):
		Globals.player.sync_equipped_weapon = Weapons.rare_sword()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Epic Sword"):
		Globals.player.sync_equipped_weapon = Weapons.epic_sword()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Legendary Sword"):
		Globals.player.sync_equipped_weapon = Weapons.legendary_sword()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Mythical Sword"):
		Globals.player.sync_equipped_weapon = Weapons.mythical_sword()
		_update_damage(item_ID)
		Globals.hud._update_equipped_weapon()
		Globals.player.save_equipped_weapon({"equippedWeapon": item_name,"equipWeaponHealth":Globals.player.sync_equipped_weapon.item_health})
	
	if item_name.contains("Abundant Shovel"):
		Globals.player.sync_equipped_mining_equipment = MiningEquipments.abundant_shovel()
		_update_damage(item_ID)
		Globals.hud._update_equipped_mining_equipment()
		Globals.player.save_equipped_mining_equipment({"equippedMiningEquipment": item_name,"equipMiningHealth":Globals.player.sync_equipped_mining_equipment.item_health})
	
	if item_name.contains("Common Shovel"):
		Globals.player.sync_equipped_mining_equipment = MiningEquipments.common_shovel()
		_update_damage(item_ID)
		Globals.hud._update_equipped_mining_equipment()
		Globals.player.save_equipped_mining_equipment({"equippedMiningEquipment": item_name,"equipMiningHealth":Globals.player.sync_equipped_mining_equipment.item_health})
	
	if item_name.contains("Rare Shovel"):
		Globals.player.sync_equipped_mining_equipment = MiningEquipments.rare_shovel()
		_update_damage(item_ID)
		Globals.hud._update_equipped_mining_equipment()
		Globals.player.save_equipped_mining_equipment({"equippedMiningEquipment": item_name,"equipMiningHealth":Globals.player.sync_equipped_mining_equipment.item_health})
	
	if item_name.contains("Epic Shovel"):
		Globals.player.sync_equipped_mining_equipment = MiningEquipments.epic_shovel()
		_update_damage(item_ID)
		Globals.hud._update_equipped_mining_equipment()
		Globals.player.save_equipped_mining_equipment({"equippedMiningEquipment": item_name,"equipMiningHealth":Globals.player.sync_equipped_mining_equipment.item_health})
	
	if item_name.contains("Legendary Shovel"):
		Globals.player.sync_equipped_mining_equipment = MiningEquipments.legendary_shovel()
		_update_damage(item_ID)
		Globals.hud._update_equipped_mining_equipment()
		Globals.player.save_equipped_mining_equipment({"equippedMiningEquipment": item_name,"equipMiningHealth":Globals.player.sync_equipped_mining_equipment.item_health})
	
	if item_name.contains("Mythical Shovel"):
		Globals.player.sync_equipped_mining_equipment = MiningEquipments.mythical_shovel()
		_update_damage(item_ID)
		Globals.hud._update_equipped_mining_equipment()
		Globals.player.save_equipped_mining_equipment({"equippedMiningEquipment": item_name,"equipMiningHealth":Globals.player.sync_equipped_mining_equipment.item_health})
	
	if item_name.contains("Abundant Helmet"):
		Globals.player.sync_equipped_helmet = Helmets.abundant_helmet()
		_update_damage(item_ID)
		Globals.hud._update_equipped_helmet()
		Globals.player.save_equipped_helmet({"equippedHelmet": item_name,"equipHelmetHealth":Globals.player.sync_equipped_mining_equipment.item_health})
		
	if item_name.contains("Common Helmet"):
		Globals.player.sync_equipped_helmet = Helmets.common_helmet()
		_update_damage(item_ID)
		Globals.hud._update_equipped_helmet()
		Globals.player.save_equipped_helmet({"equippedHelmet": item_name,"equipHelmetHealth":Globals.player.sync_equipped_mining_equipment.item_health})
		
	if item_name.contains("Rare Helmet"):
		Globals.player.sync_equipped_helmet = Helmets.rare_helmet()
		_update_damage(item_ID)
		Globals.hud._update_equipped_helmet()
		Globals.player.save_equipped_helmet({"equippedHelmet": item_name,"equipHelmetHealth":Globals.player.sync_equipped_mining_equipment.item_health})
		
	if item_name.contains("Epic Helmet"):
		Globals.player.sync_equipped_helmet = Helmets.epic_helmet()
		_update_damage(item_ID)
		Globals.hud._update_equipped_helmet()
		Globals.player.save_equipped_helmet({"equippedHelmet": item_name,"equipHelmetHealth":Globals.player.sync_equipped_mining_equipment.item_health})
		
	if item_name.contains("Legendary Helmet"):
		Globals.player.sync_equipped_helmet = Helmets.legendary_helmet()
		_update_damage(item_ID)
		Globals.hud._update_equipped_helmet()
		Globals.player.save_equipped_helmet({"equippedHelmet": item_name,"equipHelmetHealth":Globals.player.sync_equipped_mining_equipment.item_health})
		
	if item_name.contains("Mythical Helmet"):
		Globals.player.sync_equipped_helmet = Helmets.mythical_helmet()
		_update_damage(item_ID)
		Globals.hud._update_equipped_helmet()
		Globals.player.save_equipped_helmet({"equippedHelmet": item_name,"equipHelmetHealth":Globals.player.sync_equipped_mining_equipment.item_health})
		
	if item_name.contains("Abundant Armor"):
		Globals.player.sync_equipped_armor = Armors.abundant_armor()
		_update_damage(item_ID)
		Globals.hud._update_equipped_armor()
		Globals.player.save_equipped_armor({"equippedArmor": item_name,"equipArmorHealth":Globals.player.sync_equipped_armor.item_health})
		
	if item_name.contains("Common Armor"):
		Globals.player.sync_equipped_armor = Armors.common_armor()
		_update_damage(item_ID)
		Globals.hud._update_equipped_armor()
		Globals.player.save_equipped_armor({"equippedArmor": item_name,"equipArmorHealth":Globals.player.sync_equipped_armor.item_health})
		
	if item_name.contains("Rare Armor"):
		Globals.player.sync_equipped_armor = Armors.rare_armor()
		_update_damage(item_ID)
		Globals.hud._update_equipped_armor()
		Globals.player.save_equipped_armor({"equippedArmor": item_name,"equipArmorHealth":Globals.player.sync_equipped_armor.item_health})
		
	if item_name.contains("Epic Armor"):
		Globals.player.sync_equipped_armor = Armors.epic_armor()
		_update_damage(item_ID)
		Globals.hud._update_equipped_armor()
		Globals.player.save_equipped_armor({"equippedArmor": item_name,"equipArmorHealth":Globals.player.sync_equipped_armor.item_health})
		
	if item_name.contains("Legendary Armor"):
		Globals.player.sync_equipped_armor = Armors.legendary_armor()
		_update_damage(item_ID)
		Globals.hud._update_equipped_armor()
		Globals.player.save_equipped_armor({"equippedArmor": item_name,"equipArmorHealth":Globals.player.sync_equipped_armor.item_health})
		
	if item_name.contains("Mythical Armor"):
		Globals.player.sync_equipped_armor = Armors.mythical_armor()
		_update_damage(item_ID)
		Globals.hud._update_equipped_armor()
		Globals.player.save_equipped_armor({"equippedArmor": item_name,"equipArmorHealth":Globals.player.sync_equipped_armor.item_health})
		
	#CRAFTING RESOURCES:
	if item_name.contains("Copper Ore"):
		Globals.player.sync_crafting_resource = Items.copper_ore()
		Globals.hud.add_to_craft_tab("Copper Ore")
		#Globals.player.save_crafting_resource({"craftingResource": item_name})
		
	if item_name.contains("Iron Ore"):
		Globals.player.sync_crafting_resource = Items.iron_ore()
		Globals.hud.add_to_craft_tab("Iron Ore")
	
	if item_name.contains("Gold Ore"):
		Globals.player.sync_crafting_resource = Items.gold_ore()
		Globals.hud.add_to_craft_tab("Gold Ore")
	
	if item_name.contains("Silver Ore"):
		Globals.player.sync_crafting_resource = Items.silver_ore()
		Globals.hud.add_to_craft_tab("Silver Ore")
	
	if item_name.contains("Gold Ingot"):
		Globals.player.sync_crafting_resource = Items.gold_ingot()
		Globals.hud.add_to_craft_tab("Gold Ingot")
	
	if item_name.contains("Copper Ingot"):
		Globals.player.sync_crafting_resource = Items.copper_ingot()
		Globals.hud.add_to_craft_tab("Copper Ingot")
	
	if item_name.contains("Iron Ingot"):
		Globals.player.sync_crafting_resource = Items.iron_ingot()
		Globals.hud.add_to_craft_tab("Iron Ingot")
	
	if item_name.contains("Silver Ingot"):
		Globals.player.sync_crafting_resource = Items.silver_ingot()
		Globals.hud.add_to_craft_tab("Silver Ingot")
	
	if item_name.contains("Gold Nugget"):
		Globals.player.sync_crafting_resource = Items.gold_nugget()
		Globals.hud.add_to_craft_tab("Gold Nugget")
	
	if item_name.contains("Silver Nugget"):
		Globals.player.sync_crafting_resource = Items.silver_nugget()
		Globals.hud.add_to_craft_tab("Silver Nugget")
	
	if item_name.contains("Iron Nugget"):
		Globals.player.sync_crafting_resource = Items.iron_nugget()
		Globals.hud.add_to_craft_tab("Iron Nugget")
	
	if item_name.contains("Copper Nugget"):
		Globals.player.sync_crafting_resource = Items.copper_nugget()
		Globals.hud.add_to_craft_tab("Copper Nugget")
	
	if item_name.contains("Leather"):
		Globals.player.sync_crafting_resource = Items.leather()
		Globals.hud.add_to_craft_tab("Leather")
	
	if item_name.contains("Cloth"):
		Globals.player.sync_crafting_resource = Items.cloth()
		Globals.hud.add_to_craft_tab("Cloth")
	_subtract_item()
	
func drop_item():
	# $action_keys_hold/ItemName.text
	print("the item trying be dropped is: "+ item_ID)
	_subtract_item()
	
	Globals.check_scene_state()
	if Globals.current_scene == "Overworld":
		Globals.scene.player_drop_item(self_name,item_health, Globals.player.position)
	if Globals.current_scene == "Dungeon1":
		Globals.scene.player_drop_item(self_name,item_health, Globals.player.position)
	if Globals.current_scene == "Dungeon2":
		Globals.scene.player_drop_item(self_name,item_health, Globals.player.position)
	Globals.hud._update_inventory_panel()
	
func _subtract_item():
	print("item is being removed from game:"+self_name)
	#var item_name = $action_keys_hold/ItemName.text
	Globals.player.remove_item_from_inventory(item_ID)
	queue_free()

func _on_button_drop_pressed():
	drop_item()

func _on_button_use_mouse_entered():
	Globals.in_item_selection = true

func _on_button_drop_mouse_entered():
	Globals.in_item_selection = true


func _on_button_use_mouse_exited():
	Globals.in_item_selection = false
	await get_tree().create_timer(0.3).timeout
	if !Globals.in_item_selection:
		self.get_parent()._show_item_action_keys(false)


func _on_button_drop_mouse_exited():
	Globals.in_item_selection = false
	await get_tree().create_timer(0.3).timeout
	if !Globals.in_item_selection:
		self.get_parent()._show_item_action_keys(false)


func _on_button_remove_pressed():
	if Globals.player == null:
		return
	var item_name : String = $action_keys_hold/ItemName.text
	
	if item_state == "in_crafting":
		#set_quantity_display(false)
		Globals.player.remove_resource_from_crafting(item_name)
		
		Globals.player.add_item_to_inventory(item_name,100,"") #needs review 
		
		Globals.hud._update_inventory_panel()
		Globals.hud._update_craft_panel()
		
		get_parent().queue_free() #remove this slot_instance from the game

func _on_button_remove_mouse_entered():
	Globals.in_item_selection = true


func _on_button_remove_mouse_exited():
	Globals.in_item_selection = false
	await get_tree().create_timer(0.3).timeout
	if !Globals.in_item_selection:
		self.get_parent()._show_in_crafting_keys(false)

