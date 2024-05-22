extends CanvasLayer

@onready var mining_cooldown_progress_bar : ProgressBar = $MiningCoolDownProgressBar
@onready var mining_cooldown_label : Label = $MiningCoolDownLabel
@onready var battle_charge_up_progress_bar : ProgressBar = $BattleChargeUpProgressBar
@onready var battle_charge_up_label : Label = $BattleChargeUpLabel
@onready var attack_button : Button = $AttackButton
@onready var dialog_panel : Panel = $DialogPanel
@onready var inventory_panel : Panel = $InventoryPanel
@onready var hud_animation : AnimationPlayer = $HudAnimation
@onready var attack_animation : AnimationPlayer = $AttackAnimation
@onready var inventory_animation : AnimationPlayer = $InventoryAnimation
@onready var save_animation : AnimationPlayer = $SaveAnimation
@onready var mining_cool_down_animation : AnimationPlayer = $MiningCoolDownAnimation
var InventoryGridItem : PackedScene = preload("res://Scenes/Hud/inventory_grid_item.tscn")
var WeaponGridItem : PackedScene = preload("res://Scenes/Hud/inventory_equipped_weapon.tscn")
var MiningEquipmentGridItem : PackedScene = preload("res://Scenes/Hud/inventory_equipped_mining_equipment.tscn")
var HelmetGridItem: PackedScene = preload("res://Scenes/Hud/inventory_equipped_helmet.tscn")
var ArmorGridItem : PackedScene = preload("res://Scenes/Hud/inventory_equipped_armor.tscn")
var item_slot : PackedScene = preload("res://Scenes/Hud/item_slot.tscn")
#var parent_item_slot : PackedScene = preload("res://Scenes/Hud/parent_item_slot.tscn")

var _active_tab: String = ""
var crafting_success : bool

var debug_text_box: Node

func _ready():
	debug_text_box = $InventoryPanel/inventory_extras/outputbg/info

func _physics_process(_delta):
	#$Panel/test.text = Globals.test_printing
	if Globals.player != null:
		if not dialog_panel_is_visible():
			if not Globals.player.in_battle:
				if Input.is_action_just_pressed("ui_inventory"):
					if Globals.menu_isOpen == true:
						pass
					else:
						_toggle_inventory()
				if Input.is_action_just_pressed("ui_pause"):
					_toggle_menu()
	
	$Panel2/fps.text = "FPS: " + str(Engine.get_frames_per_second())
	#$CurrQuest.text = 
	
	_update_mining_cooldown_progress_bar()
	_update_battle_charge_up_progress_bar()
	_update_hit_points()
	_update_magic_points()
	_update_experience()
	_update_inventory_count()
	_update_player_level()
	if Globals.current_scene != "":
		if Input.is_action_just_pressed("use_health"):
			use_health()
		if Input.is_action_just_pressed("use_magic"):
			use_magic()

func loading_complete():
	dialog_panel.loading_complete()

func _update_hit_points():
	if Globals.player != null:
		$Panel/hp.text = "HP: " + str(Globals.player.sync_hit_points) + "/" + str(Globals.player.sync_max_hit_points)

func _update_magic_points():
	if Globals.player != null:
		$Panel/mp.text = "MP: " + str(Globals.player.sync_magic_points) + "/" + str(Globals.player.sync_max_magic_points)

func _update_experience():
	if Globals.player != null:
		$Panel/experience.text = str(Globals.player.sync_exp) + " EXP"

func _update_mining_cooldown_progress_bar():
	if Globals.player != null:
		if !Globals.player.mining_cooldown_timer.is_stopped():
			mining_cooldown_progress_bar.value = Globals.player.mining_cooldown_timer.time_left

func _update_battle_charge_up_progress_bar():
	if Globals.player != null:
		if !Globals.player.battle_charge_up_timer.is_stopped():
			battle_charge_up_progress_bar.value = battle_charge_up_progress_bar.max_value - Globals.player.battle_charge_up_timer.time_left

func _update_player_level():
	if Globals.player != null:
		$Panel/level.text = "%s LVL" % str(Globals.player.sync_level)

func _toggle_inventory():
	if not Globals.player.in_battle:
		if Globals.inventory_isOpen == false:
			_open_inventory()
			Globals.inventory_isOpen = true
		else:
			_close_inventory()
			Globals.inventory_isOpen = false

func _toggle_menu():
		if Globals.menu_isOpen == false:
			_open_menu()
			Globals.menu_isOpen = true
		else:
			_close_menu()
			Globals.menu_isOpen = false

func set_user_name(user_name):
	$Panel/user_name.text = user_name

func set_planet(planet):
	$Panel2/planet.text = planet

func set_land(land):
	$Panel2/land.text = land

func set_coord(coord : Vector2):
	$Panel2/coord.text = "(" + str(int(coord.x)) + "," + str(int(coord.y)) + ")"

func set_local_area(local_area):
	$Panel2/localarea.text = local_area

func _on_show_menu_pressed():
	if not Globals.player.in_battle:
		if Globals.menu_isOpen == false:
			_open_menu()
			Globals.menu_isOpen = true

func set_trilium_balance(trilium_balance):
	var trilium_string = str(trilium_balance)
	var sliced_balance = trilium_string.left(trilium_string.length() - 8)
	$Panel/trilium_balance.text = sliced_balance + ' TLM'

func set_dialog_text(dialog_text):
	$DialogPanel/RichTextLabel.text = dialog_text

func show_dialog_text():
	dialog_panel.show_dialog_panel()

func hide_dialog_text():
	dialog_panel.hide_dialog_panel()

func show_tip_text():
	$TipPanel.visible = true

func hide_tip_text():
	$TipPanel.visible = false

func use_health():
	if Globals.player != null:
		if !Globals.player.in_battle:
			_use_health()
			Globals.player.play_magic_healing_sound_effect()
		else:
			if Globals.player.battle_charge_up_timer.is_stopped():
				_use_health()
				Globals.player.play_magic_healing_sound_effect()
				Globals.player.battle_charge_up_timer.wait_time = Globals.player.sync_equipped_weapon.attack_charge_up_time_in_seconds
				Globals.player.battle_charge_up_timer.one_shot = true
				Globals.player.battle_charge_up_timer.start()
				attack_button.disabled = true

func _use_health():
	for item in Globals.player.sync_inventory:
			if item.quantity <= 0:
				continue
			if (item.name == "Health Potion"):
				print("hud:using health")
				Globals.player.remove_item_from_inventory(item.item_ID) 
				Globals.player._add_hp(25)
				_update_inventory_panel()
				break

func use_magic():
	if Globals.player != null:
		if !Globals.player.in_battle:
			_use_magic()
			Globals.player.play_magic_healing_sound_effect()
		else:
			if Globals.player.battle_charge_up_timer.is_stopped():
				_use_magic()
				Globals.player.play_magic_healing_sound_effect()
				Globals.player.battle_charge_up_timer.wait_time = Globals.player.sync_equipped_weapon.attack_charge_up_time_in_seconds
				Globals.player.battle_charge_up_timer.one_shot = true
				Globals.player.battle_charge_up_timer.start()
				attack_button.disabled = true

func _use_magic():
	for item in Globals.player.sync_inventory:
			if item.quantity <= 0:
				continue
			if (item.name == "Magic Potion"):
				print("hud:using magic")
				Globals.player.remove_item_from_inventory(item.item_ID) 
				Globals.player._add_mp(5)
				_update_inventory_panel()
				break

func _on_texture_button_pressed():
	if not Globals.player.in_battle:
		#_open_inventory()
		if Globals.inventory_isOpen == false:
			_open_inventory()
			Globals.inventory_isOpen = true
		else:
			_close_inventory()
			Globals.inventory_isOpen = false

func reset_current_tab():
	if $InventoryPanel/ItemsScrollContainer.visible:
		$InventoryPanel/tab_buttons/AllBtn.grab_focus()
		_active_tab = "all"
		
	if $InventoryPanel/WeaponsScrollContainer.visible:
		$InventoryPanel/tab_buttons/WeaponsBtn.grab_focus()
		_active_tab = "weapons"
		
	if $InventoryPanel/ConsumablesScrollContainer.visible:
		$InventoryPanel/tab_buttons/ConsumablesBtn.grab_focus()
		_active_tab = "consumables"
		
	if $InventoryPanel/MiningScrollContainer.visible:
		$InventoryPanel/tab_buttons/MiningEquBtn.grab_focus()
		_active_tab = "mining"

func _update_inventory_count():
	if _active_tab == "mining":
		$InventoryPanel/inventory_extras/itemCount.text = str($InventoryPanel/MiningScrollContainer/MiningEquipment.get_child_count())
	if _active_tab == "weapons":
		$InventoryPanel/inventory_extras/itemCount.text = str($InventoryPanel/WeaponsScrollContainer/WeaponsContainer.get_child_count())
	if _active_tab == "consumables":
		$InventoryPanel/inventory_extras/itemCount.text = str($InventoryPanel/ConsumablesScrollContainer/Consumables.get_child_count())
	if _active_tab == "all":
		$InventoryPanel/inventory_extras/itemCount.text = str($InventoryPanel/WeaponsScrollContainer/WeaponsContainer.get_child_count() + 
		$InventoryPanel/ConsumablesScrollContainer/Consumables.get_child_count() + $InventoryPanel/MiningScrollContainer/MiningEquipment.get_child_count())

func _hide_inactive_tab_keys(item):
	if item != Globals.active_item_slot:
		item._show_item_action_keys(false)

func _update_inventory_panel():
	print("resetting inventory panel")
	reset_current_tab()
	Globals.player.sync_inventory.sort_custom(func(a, b): return a.name > b.name)
	for item in $InventoryPanel/ItemsScrollContainer/ItemsContainer.get_children():
		_hide_inactive_tab_keys(item)
		item.queue_free()

	for item in $InventoryPanel/ConsumablesScrollContainer/Consumables.get_children():
		_hide_inactive_tab_keys(item)
		item.queue_free()
	
	for item in $InventoryPanel/WeaponsScrollContainer/WeaponsContainer.get_children():
		_hide_inactive_tab_keys(item)
		item.queue_free()
		
	for item in $InventoryPanel/MiningScrollContainer/MiningEquipment.get_children():
		_hide_inactive_tab_keys(item)
		item.queue_free()
			
	for item in Globals.player.sync_inventory:


		var i = InventoryGridItem.instantiate()
		i.set_item_name(item.name)
		i.set_item_quantity(item.quantity)
		i.set_item_sprite_image(item.sprite_image_file)
		i.set_item_level(item.item_level)
		i.set_item_health(item.item_health)
		i.set_item_id(item.item_ID)
		i.set_item_collection(item.collection_name)
		i.item_state = "normal" #when in inventory tab set as normal.
		
		
		#CONSUMABLES:
		if (item.item_type == "Consumable"):
			i.set_use_button_text("Use")
			_add_item_instance($InventoryPanel/ConsumablesScrollContainer/Consumables, i)
			
		#EQUIPMENT:
		if (item.item_type == "Weapon"):
			i.set_use_button_text("Equip")
			
#			for k in Globals.player.sync_inventory:
#				if item.item_health == k.item_health and item.name == k.name and item.item_ID != k.item_ID: #ONLY STACK IDENTICAL ITEMS
#					pass
#					#item.quantity += 1
			
			if item.quantity == 1:
				i.set_damage_display(item.item_health)	
				
			_add_item_instance($InventoryPanel/WeaponsScrollContainer/WeaponsContainer, i)
			
		if (item.item_type == "Mining Equipment"):
			i.set_use_button_text("Equip")
			
			if item.quantity == 1:
				i.set_damage_display(item.item_health)
				
			_add_item_instance($InventoryPanel/MiningScrollContainer/MiningEquipment, i)
		
		if (item.item_type == "Armor"):
			i.set_use_button_text("Equip")
			
			if item.quantity == 1:
				i.set_damage_display(item.item_health)
				
			_add_item_instance($InventoryPanel/WeaponsScrollContainer/WeaponsContainer, i)
		
		if (item.item_type == "Helmet"):
			i.set_use_button_text("Equip")
			
			if item.quantity == 1:
				i.set_damage_display(item.item_health)
				
			_add_item_instance($InventoryPanel/WeaponsScrollContainer/WeaponsContainer, i)
			
		#CRAFTING RESOURCES:
		if (item.item_type == "Crafting"):
			i.set_use_button_text("Craft")
			_add_item_instance($InventoryPanel/ConsumablesScrollContainer/Consumables, i)
			
		var item_duplicate = i.duplicate()
		item_duplicate.set_item_name(item.name)
		item_duplicate.set_item_quantity(item.quantity)
		item_duplicate.set_item_sprite_image(item.sprite_image_file)
		item_duplicate.set_item_level(item.item_level)
		item_duplicate.set_item_health(item.item_health)
		item_duplicate.set_item_id(item.item_ID)
		item_duplicate.set_item_collection(item.collection_name)
		item_duplicate.item_state = "normal"
		
		if item.quantity == 1:
			_add_item_instance($InventoryPanel/ItemsScrollContainer/ItemsContainer, item_duplicate) #ADD TO ALL TAB
		
#	print_equipment_inventory()

func print_equipment_inventory():
	
	for item in Globals.player.sync_inventory:
		if item.item_type == "Weapon":
			if item.item_health == 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")
			elif item.item_health < 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")
		
		elif item.item_type == "Helmet":
			if item.item_health == 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")
			elif item.item_health < 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")
				
		elif item.item_type == "Armor":
			if item.item_health == 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")
			elif item.item_health < 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")
				
		elif item.item_type == "Mining Equipment":
			if item.item_health == 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")
			elif item.item_health < 100:
				print("There are " + str(item.quantity) + " " + item.name + " with: " + str(item.item_health) + "%")

func _update_equipped_weapon_tab():
	for item in $InventoryPanel/EquippedContainer/weapon_slot.get_children():
			item.queue_free()
			Globals.player.sync_equipped_weapon = Weapons.left_hand()
			Globals.player.save_equipped_weapon({"equippedWeapon": "Left Hand"})
	_update_equipped_weapon()


func _update_equipped_mining_equ_tab():
	for item in $InventoryPanel/EquippedContainerLeft/mining_equ_slot.get_children():
			item.queue_free()
			Globals.player.sync_equipped_mining_equipment = MiningEquipments.right_hand()
			Globals.player.save_equipped_mining_equipment({"equippedWeapon": "Right Hand"})
		
	_update_equipped_mining_equipment()

func _update_equipped_helmet_tab():
	for item in $InventoryPanel/EquippedContainer/helmet_slot.get_children():
			item.queue_free()
			Globals.player.sync_equipped_helmet = Helmets.default_helmet()
			Globals.player.save_equipped_helmet({"equippedHelmet": "Helmet"})
		
	_update_equipped_helmet()

func _update_equipped_armor_tab():
	for item in $InventoryPanel/EquippedContainerLeft/armor_slot.get_children():
			item.queue_free()
			Globals.player.sync_equipped_armor = Armors.default_armor()
			Globals.player.save_equipped_armor({"equippedArmor": "Armor"})
		
	_update_equipped_armor()

func _add_item_instance(container, i):
	var slot_instance = item_slot.instantiate()
	slot_instance.custom_minimum_size = Vector2(25.0, 25.0)
	container.add_child(slot_instance)
	slot_instance.add_child(i)

func _add_multiple_item_slot(container, i):
	var slot_instance = item_slot.instantiate()
	slot_instance.custom_minimum_size = Vector2(25.0, 25.0)
	container.add_child(slot_instance)
	slot_instance.add_child(i)

func _update_equipped_helmet():
	for helmet in $InventoryPanel/EquippedContainer/helmet_slot.get_children():
		helmet.queue_free()
	
	var equipped_helmet = HelmetGridItem.instantiate()
	equipped_helmet.set_item_name(Globals.player.sync_equipped_helmet.name)
	equipped_helmet.set_item_sprite_image(Globals.player.sync_equipped_helmet.sprite_image_file)
	equipped_helmet.set_item_id(Globals.player.sync_equipped_helmet.item_ID)
	equipped_helmet.set_item_health(Globals.player.sync_equipped_helmet.item_health)
	if (Globals.player.sync_equipped_helmet.name == "Helmet" ):
		equipped_helmet.disable_unequip_button()
	else:
		print("Equipped Helmet Damage%s " % Globals.player.sync_equipped_helmet.item_health)
		equipped_helmet.enable_unequip_button()
		
	$InventoryPanel/EquippedContainer/helmet_slot.add_child(equipped_helmet)

func _update_equipped_armor():
	for armor in $InventoryPanel/EquippedContainerLeft/armor_slot.get_children():
		armor.queue_free()
	
	var equipped_armor = ArmorGridItem.instantiate()
	equipped_armor.set_item_name(Globals.player.sync_equipped_armor.name)
	equipped_armor.set_item_sprite_image(Globals.player.sync_equipped_armor.sprite_image_file)
	equipped_armor.set_item_id(Globals.player.sync_equipped_armor.item_ID)
	equipped_armor.set_item_health(Globals.player.sync_equipped_armor.item_health)
	if (Globals.player.sync_equipped_armor.name == "Armor" ):
		equipped_armor.disable_unequip_button()
	else:
		print("Equipped Armor Damage%s " % Globals.player.sync_equipped_armor.item_health)
		equipped_armor.enable_unequip_button()
		
	$InventoryPanel/EquippedContainerLeft/armor_slot.add_child(equipped_armor)

func _update_equipped_weapon():
	for weapon in $InventoryPanel/EquippedContainer/weapon_slot.get_children():
		weapon.queue_free()
	
	var equipped_weapon = WeaponGridItem.instantiate()
	equipped_weapon.set_item_name(Globals.player.sync_equipped_weapon.name)
	equipped_weapon.set_item_sprite_image(Globals.player.sync_equipped_weapon.sprite_image_file)
	equipped_weapon.set_item_level(Globals.player.sync_equipped_weapon.item_level)
	equipped_weapon.set_item_id(Globals.player.sync_equipped_weapon.item_ID)
	equipped_weapon.set_item_health(Globals.player.sync_equipped_weapon.item_health)
	
	
	if (Globals.player.sync_equipped_weapon.name == "Left Hand"):
		equipped_weapon.disable_unequip_button()
	else:
		print("Equipped Weapon Damage%s " % Globals.player.sync_equipped_weapon.item_health)
		equipped_weapon.enable_unequip_button()
	
	$InventoryPanel/EquippedContainer/weapon_slot.add_child(equipped_weapon)

func _update_equipped_mining_equipment():
	for mining_equipment in $InventoryPanel/EquippedContainerLeft/mining_equ_slot.get_children():
		mining_equipment.queue_free()
	
	var equipped_mining_equipment = MiningEquipmentGridItem.instantiate()
	equipped_mining_equipment.set_item_name(Globals.player.sync_equipped_mining_equipment.name)
	equipped_mining_equipment.set_item_sprite_image(Globals.player.sync_equipped_mining_equipment.sprite_image_file)
	equipped_mining_equipment.set_item_level(Globals.player.sync_equipped_mining_equipment.item_level)
	equipped_mining_equipment.set_item_id(Globals.player.sync_equipped_mining_equipment.item_ID)
	equipped_mining_equipment.set_item_health(Globals.player.sync_equipped_mining_equipment.item_health)
	if (Globals.player.sync_equipped_mining_equipment.name == "Right Hand"):
		equipped_mining_equipment.disable_unequip_button()
	else:
		print("Equipped Weapon Damage%s " % Globals.player.sync_equipped_mining_equipment.item_health)
		equipped_mining_equipment.enable_unequip_button()
	
	$InventoryPanel/EquippedContainerLeft/mining_equ_slot.add_child(equipped_mining_equipment)

func _open_inventory():
	_update_inventory_panel()
	_update_equipped_weapon()
	_update_equipped_mining_equipment()
	_update_equipped_helmet()
	_update_equipped_armor()
	_update_craft_panel()
	
	inventory_panel.visible = true
	inventory_animation.play("open_inventory")

func _close_inventory():
	inventory_animation.play("close_inventory")

func _open_menu():
	if Globals.menu == null:
		var menu_instance = load("res://Scenes/Hud/menu.tscn").instantiate()
		add_child(menu_instance)
		Globals.menu = menu_instance
		
	else:
		add_child(Globals.menu)

func _close_menu():
	if Globals.menu != null:
		var settings_pnl = Globals.menu.get_node("Wrapper/Panel/SettingsPnl")
		var credits_pnl = Globals.menu.get_node("Wrapper/Panel/Credits")
		var playerstats_pnl = Globals.menu.get_node("Wrapper/Panel/PlayerStats")
		if settings_pnl != null:
			settings_pnl.visible = false
		if credits_pnl != null:
			credits_pnl.visible = false
		if playerstats_pnl != null:
			playerstats_pnl.visible = false
		remove_child(Globals.menu)

func add_to_craft_tab(craft_resource_name):	
	#var craft_resource = InventoryGridItem.instantiate(craft_resource_name)
	Globals.player.add_to_crafting_panel(craft_resource_name)
	_update_craft_panel()

func _update_craft_panel():
	for slot in $InventoryPanel/CraftingScrollContainer/CraftingContainer.get_children():
		slot.queue_free()
		
	for item in Globals.player.sync_crafting:
		if item.quantity <= 0:
			continue
		
		var i = InventoryGridItem.instantiate()
		i.set_item_name(item.name)
		i.set_item_quantity(item.quantity)
		i.set_item_sprite_image(item.sprite_image_file)
		i.item_state = "in_crafting" #when in inventory tab set as normal.
		#i.set_quantity_display(true)
		_add_item_instance($InventoryPanel/CraftingScrollContainer/CraftingContainer, i)

func craft_new_item():
	debug_text_box.text = ""
	for crafting_resource in Globals.player.sync_crafting:
		if $InventoryPanel/CraftingScrollContainer/CraftingContainer.get_child_count() > 1:
			for k in Globals.player.sync_crafting:
				
				#increase_item_level(crafting_resource, k) #increase rarity of item crafted:
				
				#nested loop to compare
				if crafting_resource.name == "Copper Ingot" and crafting_resource.quantity == 3 and k.name == "Leather" and k.quantity == 1:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Abundant Dagger",100,"Abundant")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Silver Ingot" and crafting_resource.quantity == 3 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Common Dagger",100,"Common")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Iron Ingot" and crafting_resource.quantity == 3 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Rare Dagger",100,"Rare")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Gold Ingot" and crafting_resource.quantity == 3 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Epic Dagger",100,"Epic")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Copper Ingot" and crafting_resource.quantity == 4 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Abundant Sword",100,"Abundant")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Silver Ingot" and crafting_resource.quantity == 4 and k.name == "Leather" and k.quantity == 3:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Common Sword",100,"Common")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Iron Ingot" and crafting_resource.quantity == 4 and k.name == "Leather" and k.quantity == 3:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Rare Sword",100,"Rare")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Gold Ingot" and crafting_resource.quantity == 4 and k.name == "Leather" and k.quantity == 3:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Epic Sword",100,"Epic")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Copper Ingot" and crafting_resource.quantity == 2 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Abundant Shovel",100,"Abundant")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Silver Ingot" and crafting_resource.quantity == 2 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Common Shovel",100,"Common")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Iron Ingot" and crafting_resource.quantity == 2 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Rare Shovel",100,"Rare")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Gold Ingot" and crafting_resource.quantity == 2 and k.name == "Leather" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Epic Shovel",100,"Epic")
					crafting_success = true
					_update_inventory_panel()
						
				elif crafting_resource.name == "Copper Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 3:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Abundant Armor",100,"Abundant")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Silver Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 3:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Common Armor",100,"Common")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Iron Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 3:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Rare Armor",100,"Rare")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Gold Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 3:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Epic Armor",100,"Epic")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Copper Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Abundant Helmet",100,"Abundant")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Silver Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Common Helmet",100,"Common")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Iron Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Rare Helmet",100,"Rare")
					crafting_success = true
					_update_inventory_panel()
					
				elif crafting_resource.name == "Gold Ingot" and crafting_resource.quantity == 2 and k.name == "Cloth" and k.quantity == 2:
					Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
					Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					Globals.player.add_item_to_inventory("Epic Helmet",100,"Epic")
					crafting_success = true
					_update_inventory_panel()
					
				#else:
					#crafting_success = false
					#Globals.player.remove_all_resource_from_crafting(k.name, k.quantity)
					
		elif $InventoryPanel/CraftingScrollContainer/CraftingContainer.get_child_count() == 1:
			#if only one crafting resource is present:
			if crafting_resource.name == "Iron Ore" and crafting_resource.quantity == 2:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Iron Nugget",100,"")
				crafting_success = true
				_update_inventory_panel()
				
			elif crafting_resource.name == "Copper Ore" and crafting_resource.quantity == 2:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Copper Nugget",100,"")
				crafting_success = true
				_update_inventory_panel()
				
			elif crafting_resource.name == "Gold Ore" and crafting_resource.quantity == 2:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Gold Nugget",100,"")
				crafting_success = true
				_update_inventory_panel()
				
			elif crafting_resource.name == "Silver Ore" and crafting_resource.quantity == 2:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Silver Nugget",100,"")
				crafting_success = true
				_update_inventory_panel()
				
			elif crafting_resource.name == "Gold Nugget" and crafting_resource.quantity == 3:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Gold Ingot",100,"")
				crafting_success = true
				_update_inventory_panel()
				
			elif crafting_resource.name == "Silver Nugget" and crafting_resource.quantity == 3:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Silver Ingot",100,"")
				crafting_success = true
				_update_inventory_panel()
				
			elif crafting_resource.name == "Iron Nugget" and crafting_resource.quantity == 3:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Iron Ingot",100,"")
				crafting_success = true
				_update_inventory_panel()
				
			elif crafting_resource.name == "Copper Nugget" and crafting_resource.quantity == 3:
				Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
				Globals.player.add_item_to_inventory("Copper Ingot",100,"")
				crafting_success = true
				_update_inventory_panel()
				
		else:
			crafting_success = false
				
		if crafting_success == false:
			await(get_tree().create_timer(1).timeout)
			debug_text_box.text = "CRAFTING FAILED"
			Globals.player.remove_all_resource_from_crafting(crafting_resource.name, crafting_resource.quantity)
			debug_text_box.text = ""
				
	_update_craft_panel()

func increase_item_level(item1, item2):
	var crafted_item = InventoryGridItem.instantiate()
	
	if item1.item_level == 1 and item2.item_level == 1:
		crafted_item.item_level = 2
		return crafted_item
		
	elif item1.item_level == 2 and item2.item_level == 2:
		crafted_item.item_level = 2
		return crafted_item

func increase_same_item_level(item, output):
	if item.quantity == 2 and item.item_level == 1:
		output.item_level = 2
		return output

func _on_close_button_pressed():
	_close_inventory()
	Globals.inventory_isOpen = false

func _on_attack_button_pressed():
	if Globals.player != null:
		Globals.player.attack()

func _on_weapons_btn_pressed():
	_active_tab = "weapons"
	
	$InventoryPanel/inventory_extras/WeaponTabHeader.visible = true
	$InventoryPanel/inventory_extras/AllTabHeader.visible = false
	$InventoryPanel/inventory_extras/MiningTabHeader.visible = false
	$InventoryPanel/inventory_extras/ConsumeTabHeader.visible = false
	$InventoryPanel/ItemsScrollContainer.visible = false
	$InventoryPanel/ConsumablesScrollContainer.visible = false
	$InventoryPanel/WeaponsScrollContainer.visible = true
	$InventoryPanel/MiningScrollContainer.visible = false

func _on_consumables_btn_pressed():
	_active_tab = "consumables"
	
	$InventoryPanel/inventory_extras/WeaponTabHeader.visible = false
	$InventoryPanel/inventory_extras/AllTabHeader.visible = false
	$InventoryPanel/inventory_extras/MiningTabHeader.visible = false
	$InventoryPanel/inventory_extras/ConsumeTabHeader.visible = true
	$InventoryPanel/ItemsScrollContainer.visible = false
	$InventoryPanel/ConsumablesScrollContainer.visible = true
	$InventoryPanel/WeaponsScrollContainer.visible = false
	$InventoryPanel/MiningScrollContainer.visible = false

func _on_all_btn_pressed():
	_active_tab = "all"
	
	$InventoryPanel/inventory_extras/WeaponTabHeader.visible = false
	$InventoryPanel/inventory_extras/AllTabHeader.visible = true
	$InventoryPanel/inventory_extras/MiningTabHeader.visible = false
	$InventoryPanel/inventory_extras/ConsumeTabHeader.visible = false
	$InventoryPanel/ItemsScrollContainer.visible = true	
	$InventoryPanel/ConsumablesScrollContainer.visible = false
	$InventoryPanel/WeaponsScrollContainer.visible = false
	$InventoryPanel/MiningScrollContainer.visible = false

func _on_mining_equ_btn_pressed():
	_active_tab = "mining"
	
	$InventoryPanel/inventory_extras/WeaponTabHeader.visible = false
	$InventoryPanel/inventory_extras/AllTabHeader.visible = false
	$InventoryPanel/inventory_extras/MiningTabHeader.visible = true
	$InventoryPanel/inventory_extras/ConsumeTabHeader.visible = false
	$InventoryPanel/ItemsScrollContainer.visible = false
	$InventoryPanel/ConsumablesScrollContainer.visible = false
	$InventoryPanel/WeaponsScrollContainer.visible = false
	$InventoryPanel/MiningScrollContainer.visible = true

func set_speaker_name(speaker_name):
	$DialogPanel.set_speaker_name(speaker_name)

func set_speaker_image(image_file : String):
	$DialogPanel.set_speaker_image(image_file)

func dialog_panel_is_visible():
	return $DialogPanel.visible

func show_save_icon():
	save_animation.play("show_diskette")

func hide_save_icon():
	save_animation.play("hide_diskette")

func show_attack_ui():
	attack_animation.play("attack_start")

func hide_attack_ui():
	attack_animation.play("attack_stopped")

func show_mining_cool_down_ui():
	mining_cool_down_animation.play("cool_down_started")

func hide_mining_cool_down_ui():
	mining_cool_down_animation.play("cool_down_stopped")

func show_ui():
	hud_animation.play("hud_animation")

func _on_craft_pressed():
	craft_new_item()

func _on_help_crafting_pressed():
	if $InventoryPanel/inventory_extras/crafting_bg2.visible == true:
		$InventoryPanel/inventory_extras/crafting_bg2.visible = false
	else:
		$InventoryPanel/inventory_extras/crafting_bg2.visible = true
