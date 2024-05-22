class_name PlayerCharacter extends CharacterBody2D

@export var move_speed : float = 100

signal destroyed

@onready var animation_tree = $AnimationTree
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var detection_area : Area2D = $Area2D
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var input_direction := Vector2.ZERO
@onready var mining_progress_bar : ProgressBar = $MiningProgressBar
@onready var FlashingText : PackedScene = preload("res://Scenes/Hud/flashing_text.tscn")
@onready var Overworld : PackedScene = preload("res://Scenes/Levels/overworld.tscn")
@onready var Dungeon1 : PackedScene = preload("res://Scenes/Levels/dungeon1.tscn")
@onready var Dungeon2 : PackedScene = preload("res://Scenes/Levels/dungeon2.tscn")
@onready var MagicCast : PackedScene = preload("res://Scenes/Items/magic_cast.tscn")

@onready var http_login_request : HTTPRequest = HTTPRequest.new() # this could be singular
@onready var http_logout_request : HTTPRequest = HTTPRequest.new() # this could be singular
@onready var http_fetch_inventory_request : HTTPRequest = HTTPRequest.new() # this could be singular
@onready var http_fetch_completed_quests_request : HTTPRequest = HTTPRequest.new() # singular 



@onready var player_sound_fx : AudioStreamPlayer = AudioStreamPlayer.new()


# The variables that are synced with the server
@export var sync_input_direction := Vector2.ZERO
@export var sync_velocity := Vector2.ZERO
@export var sync_trilium_balance : float = 0.00
@export var sync_user_name := ""
@export var sync_database_player_id := ""
@export var sync_max_hit_points := 0
@export var sync_hit_points := 0
@export var sync_max_magic_points := 0
@export var sync_magic_points := 0
@export var sync_inventory : Array #[InventoryItem]
@export var sync_completed_quests : Array
@export var sync_exp := 0
@export var sync_level := 0
@export var sync_strength := 0
@export var sync_intelligence := 0
@export var sync_custom_character_name := ""
@export var sync_equipped_mining_equipment : MiningEquipment
@export var sync_equipped_weapon : Weapon
@export var sync_equipped_armor : Armor
@export var sync_equipped_helmet: Helmet
@export var sync_equipped_accessory : InventoryItem
@export var sync_crafting_resource: InventoryItem #NB
@export var sync_crafting: Array
@export var sync_equipment: Array
@export var sync_weapons_in_inventory: Array


var previous_music_stream : AudioStream
var battle_music_stream : AudioStream = preload("res://Music/The Battle of Atheria.ogg")
var magic_healing_sound_effect : AudioStream = preload("res://SoundFX/magical_1.ogg")
var apple_bite_sound_effect : AudioStream = preload("res://SoundFX/apple_bite.ogg")
var ready_sound_effect : AudioStream = preload("res://SoundFX/Ready.wav")
var mining_timer : Timer
var mining_cooldown_timer : Timer
var battle_charge_up_timer : Timer
var magic_replenish_timer : Timer
var interactable_body = null
var jwt = null
var in_battle := false
var is_dead := false

var is_attack_enabled = true
var is_magic_attack_enabled : bool = false

var _target : Node2D
var _previous_position
var _current_chest : String = ""
var _current_item : String = ""

var player_weapon: Weapon #USED TO COMPARE EQUIPPED WEAPONS
var weapon_name_upper
var mining_equipment_name_upper
var is_attacking : bool = false
var is_attacking_w_magic : bool = false
var is_mining: bool = false
var is_casting: bool = false
var weapon_damage : int = 100
var mining_direction
var is_hit : bool = false
var miningSound : AudioStream = preload("res://SoundFX/shovel.ogg")
var magicAttackSound : AudioStream = preload("res://SoundFX/magical_7.ogg")
var swordAttackSound : AudioStream = preload("res://SoundFX/sword.10.ogg")
var direction
var x_direction
var y_direction

const scale_factor = 10.0
const growth_rate = 2
const starting_level = 1

func _ready():
	$CharacterNameLabel.text = sync_custom_character_name
	$CharacterNameLabel.visible = false
	set_collision_layer_value(20, true)
	set_collision_mask_value(20, true)
	mining_progress_bar.step = 1
	
	# The detection area of the player character can detect and
	# interact with objects on layer mask 5. Objects on layer mask
	# 5 can be picked up and added into the player's inventory
	detection_area.set_collision_layer_value(5, true)
	detection_area.set_collision_mask_value(5, true)
	
	# Mining Timer
	# This timer gets activated when the player interacts with
	# Trilium Crystals that can be mined.  THis is how long it
	# takes to actually mine the Crystal
	mining_timer = Timer.new()
	add_child(mining_timer)
	mining_timer.connect("timeout", _on_mining_timer_timeout)
	# Mining Cooldown Timer
	# Players have to wait before they can mine again once they
	# have mined a Trilium Crystal
	mining_cooldown_timer = Timer.new()
	add_child(mining_cooldown_timer)
	mining_cooldown_timer.connect("timeout", _on_mining_cooldown_timer_timeout)
	
	var mining_time_diff:int = Globals.miningLockedTill- int(Time.get_unix_time_from_system())
	if mining_time_diff>0:
		mining_cooldown_timer.wait_time = mining_time_diff
		mining_cooldown_timer.one_shot = true
		mining_cooldown_timer.start()
		Globals.hud.mining_cooldown_progress_bar.max_value = mining_time_diff
		Globals.hud.mining_cooldown_progress_bar.value = mining_time_diff
		Globals.hud.show_mining_cool_down_ui()
	
	# Battle Charge up Timer
	# When the player is in battle, this timer fills up.  When
	# it becomes full, the player can perform a battle action
	battle_charge_up_timer = Timer.new()
	add_child(battle_charge_up_timer)
	battle_charge_up_timer.connect("timeout", _on_battle_charge_up_timer_timeout)
	
	# Magic replelish 
	# Magic will replenish as the time passes while playing the game
	magic_replenish_timer = Timer.new()
	add_child(magic_replenish_timer)
	magic_replenish_timer.wait_time = 10 # every 60 seconds magic pints increses by one 
	magic_replenish_timer.autostart = true
	magic_replenish_timer.one_shot = false
	magic_replenish_timer.start()
	magic_replenish_timer.connect("timeout",_on_magic_replenish_timeout)
	# Add the http request objects
	
	add_child(http_login_request)
	add_child(http_logout_request)
	add_child(http_fetch_inventory_request)

	add_child(http_fetch_completed_quests_request)
	
	# Add the player sound fx object
	add_child(player_sound_fx)
	
	# Connect the http request objects to their respective callback functions

	http_login_request.connect("request_completed", Callable(self, "_on_request_completed"))
	http_logout_request.connect("request_completed", Callable(self, "_on_logout_completed"))
	http_fetch_inventory_request.connect("request_completed", Callable(self, "_on_fetch_inventory_request_completed"))
	http_fetch_completed_quests_request.connect("request_completed", Callable(self, "_on_fetch_completed_quests_request_completed"))
	
	fetch_all_inventory_items()
	fetch_completed_quests()
	Globals.hud.show_ui()
	
	player_weapon = Weapons.left_hand()
	update_stats()

func _enter_tree():
	# set the JWT
	jwt = Globals.jwt
	
	# set the user name on the HUD
	Globals.hud.set_user_name(Globals.user_name)
	
	# Set the custom name
	sync_custom_character_name = Globals.custom_character_name
	print("Custom name is " + sync_custom_character_name)
	
	# Set the user data variables so the server can read
	sync_user_name = Globals.user_name
	sync_database_player_id = Globals.database_player_id
	sync_trilium_balance = Globals.trilium_balance
	sync_max_hit_points = Globals.max_hit_points
	sync_hit_points = Globals.hit_points
	sync_max_magic_points = Globals.max_magic_points
	sync_magic_points = Globals.magic_points
	sync_exp = Globals.experience
	sync_level = Globals.level
	sync_strength = Globals.strength
	sync_intelligence = Globals.intelligence
	
	# Set the mining equipment
	sync_equipped_mining_equipment = _mining_equipment(Globals.equipped_mining_equipment)
	
	# Set the weapon
	sync_equipped_weapon = _weapon(Globals.equipped_weapon)

	#Set the equipped helmet
	sync_equipped_helmet = _helmet(Globals.equipped_helmet)
	sync_equipped_armor = _armor(Globals.equipped_armor)
	
	sync_crafting_resource = _crafting_resource(Globals.crafting_resource)

func _weapon(weapon_name) -> Weapon:
	var weapon : Weapon = Weapons.left_hand()
	
	if weapon_name == "Abundant Dagger":
		weapon = Weapons.abundant_dagger()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Common Dagger":
		weapon = Weapons.common_dagger()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Rare Dagger":
		weapon = Weapons.rare_dagger()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Epic Dagger":
		weapon = Weapons.epic_dagger()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Legendary Dagger":
		weapon = Weapons.legendary_dagger()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Mythical Dagger":
		weapon = Weapons.mythical_dagger()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Abundant Sword":
		weapon = Weapons.abundant_sword()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Common Sword":
		weapon = Weapons.common_sword()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Rare Sword":
		weapon = Weapons.rare_sword()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Epic Sword":
		weapon = Weapons.epic_sword()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Legendary Sword":
		weapon = Weapons.legendary_sword()
		weapon.item_health = Globals.equipped_weapon_health
	if weapon_name == "Mythical Sword":
		weapon = Weapons.mythical_sword()
		weapon.item_health = Globals.equipped_weapon_health
	
	return weapon

func _mining_equipment(mining_equipment_name) -> MiningEquipment:
	var mining_equipment : MiningEquipment = MiningEquipments.right_hand()
	
	if mining_equipment_name == "Abundant Shovel":
		mining_equipment = MiningEquipments.abundant_shovel()
		mining_equipment.item_health  = Globals.equipped_mining_equipment_health
	if mining_equipment_name == "Common Shovel":
		mining_equipment = MiningEquipments.common_shovel()
		mining_equipment.item_health  = Globals.equipped_mining_equipment_health
	if mining_equipment_name == "Rare Shovel":
		mining_equipment = MiningEquipments.rare_shovel()
		mining_equipment.item_health  = Globals.equipped_mining_equipment_health
	if mining_equipment_name == "Epic Shovel":
		mining_equipment = MiningEquipments.epic_shovel()
		mining_equipment.item_health  = Globals.equipped_mining_equipment_health
	if mining_equipment_name == "Legendary Shovel":
		mining_equipment = MiningEquipments.legendary_shovel()
		mining_equipment.item_health  = Globals.equipped_mining_equipment_health
	if mining_equipment_name == "Mythical Shovel":
		mining_equipment = MiningEquipments.mythical_shovel()
		mining_equipment.item_health  = Globals.equipped_mining_equipment_health
	
	return mining_equipment

func _helmet(helmet_name) -> Helmet:
	var helmet : Helmet = Helmets.default_helmet() #NB: UPDATE FOR SINGLE PLAYER
	
	if helmet_name == "Abundant Helmet":
		helmet = Helmets.abundant_helmet()
		helmet.item_health = Globals.equipped_helmet_health
	if helmet_name == "Common Helmet":
		helmet = Helmets.common_helmet()
		helmet.item_health = Globals.equipped_helmet_health
	if helmet_name == "Rare Helmet":
		helmet = Helmets.rare_helmet()
		helmet.item_health = Globals.equipped_helmet_health
	if helmet_name == "Epic Helmet":
		helmet = Helmets.epic_helmet()
		helmet.item_health = Globals.equipped_helmet_health
	if helmet_name == "Legendary Helmet":
		helmet = Helmets.legendary_helmet()
		helmet.item_health = Globals.equipped_helmet_health
	if helmet_name == "Mythical Helmet":
		helmet = Helmets.mythical_helmet()
		helmet.item_health = Globals.equipped_helmet_health
	
	return helmet

func _armor(armor_name) -> Armor:
	var armor : Armor = Armors.default_armor() #NB: UPDATE FOR SINGLE PLAYER
	
	if armor_name == "Abundant Armor":
		armor = Armors.abundant_armor()
		armor.item_health = Globals.equipped_armor_health
	if armor_name == "Common Armor":
		armor = Armors.common_armor()
		armor.item_health = Globals.equipped_armor_health
	if armor_name == "Rare Armor":
		armor = Armors.rare_armor()
		armor.item_health = Globals.equipped_armor_health
	if armor_name == "Epic Armor":
		armor = Armors.epic_armor()
		armor.item_health = Globals.equipped_armor_health
	if armor_name == "Legendary Armor":
		armor = Armors.legendary_armor()
		armor.item_health = Globals.equipped_armor_health
	if armor_name == "Mythical Armor":
		armor = Armors.mythical_armor()
		armor.item_health = Globals.equipped_armor_health
	
	return armor

func _crafting_resource(resource_name):
	var crafting_resource: InventoryItem
	
	if resource_name == "Copper Ore": 
		crafting_resource = Items.copper_ore()
		
	if resource_name == "Iron Ore": 
		crafting_resource = Items.iron_ore()
		
	if resource_name == "Gold Ore": 
		crafting_resource = Items.gold_ore()
		
	if resource_name == "Silver Ore": 
		crafting_resource = Items.silver_ore()
		
	if resource_name == "Iron Ingot": 
		crafting_resource = Items.iron_ingot()
		
	if resource_name == "Copper Ingot": 
		crafting_resource = Items.copper_ingot()
		
	if resource_name == "Silver Ingot": 
		crafting_resource = Items.silver_ingot()
		
	if resource_name == "Gold Ingot": 
		crafting_resource = Items.gold_ingot()
		
	if resource_name == "Silver Nugget": 
		crafting_resource = Items.silver_nugget()
		
	if resource_name == "Gold Nugget": 
		crafting_resource = Items.gold_nugget()
		
	if resource_name == "Iron Nugget": 
		crafting_resource = Items.iron_nugget()
		
	if resource_name == "Copper Nugget": 
		crafting_resource = Items.copper_nugget()
		
	if resource_name == "Cloth": 
		crafting_resource = Items.cloth()
		
	if resource_name == "Leather": 
		crafting_resource = Items.leather()
		
	return crafting_resource

#DYNAMICALLY HANDLE CHARACTER ANIMATIONS
#func change_current_animation(curr_anim: String, new_anim: String, tree_state: String):
	#var animation_tree_root = animation_tree.tree_root 
	
	#NOW TO CHANGE ANIMATION PROPERTY 
	#animation_tree_root.get_node(curr_anim).animation = new_anim
	
	#NOW TOGGLE THE ANIMATIOM TREE STATE
	#var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	#playback.travel(tree_state)

func _physics_process(_delta):
	if not Globals.hud.dialog_panel_is_visible():
		if Input.is_action_just_pressed("ui_interact"):
			print("Interact has been pressed.")
			if in_battle == false and interactable_body != null:
				print(interactable_body.name, " looted", " layer:", interactable_body.collision_layer, " mask:", interactable_body.collision_mask)
				if interactable_body.has_method("interact"):
					if interactable_body.name.contains("Wood Treasure Chest"):
						if _current_chest != interactable_body.name:
							if not interactable_body.sync_looted:
								print(interactable_body.name, " layer:", interactable_body.collision_layer, " mask:", interactable_body.collision_mask, " Doesn't synced")
								# We need to save in the database some notable chests
								# so that they don't respawn if they have been found
								
								#Dungeon 1's chests
								
								if interactable_body.name.contains("Dungeon1Chest1"):
									Globals.player.save_completed_quest("Dungeon1Chest1")
								
								if interactable_body.name.contains("Dungeon1Chest2"):
									Globals.player.save_completed_quest("Dungeon1Chest2")
								
								if interactable_body.name.contains("Dungeon1Chest3"):
									Globals.player.save_completed_quest("Dungeon1Chest3")
								
								if interactable_body.name.contains("Dungeon1Chest4"):
									Globals.player.save_completed_quest("Dungeon1Chest4")
								
								if interactable_body.name.contains("Dungeon1Chest5"):
									Globals.player.save_completed_quest("Dungeon1Chest5")
								
								if interactable_body.name.contains("Dungeon1Chest6"):
									Globals.player.save_completed_quest("Dungeon1Chest6")
								
								if interactable_body.name.contains("Dungeon1Chest7"):
									Globals.player.save_completed_quest("Dungeon1Chest7")
								
								if interactable_body.name.contains("Dungeon1Chest8"):
									Globals.player.save_completed_quest("Dungeon1Chest8")
								
								if interactable_body.name.contains("Dungeon1Chest9"):
									Globals.player.save_completed_quest("Dungeon1Chest9")
								
								if interactable_body.name.contains("Dungeon1Chest10"):
									Globals.player.save_completed_quest("Dungeon1Chest10")
								
								#Dungeon 2's chests
								
								if interactable_body.name.contains("Dungeon2Chest1"):
									Globals.player.save_completed_quest("Dungeon2Chest1")
								
								if interactable_body.name.contains("Dungeon2Chest2"):
									Globals.player.save_completed_quest("Dungeon2Chest2")
								
								if interactable_body.name.contains("Dungeon2Chest3"):
									Globals.player.save_completed_quest("Dungeon2Chest3")
								
								if interactable_body.name.contains("Dungeon2Chest4"):
									Globals.player.save_completed_quest("Dungeon2Chest4")
								
								if interactable_body.name.contains("Dungeon2Chest5"):
									Globals.player.save_completed_quest("Dungeon2Chest5")
								
								if interactable_body.name.contains("Dungeon2Chest6"):
									Globals.player.save_completed_quest("Dungeon2Chest6")
								
								if interactable_body.name.contains("Dungeon2Chest7"):
									Globals.player.save_completed_quest("Dungeon2Chest7")
								
								if interactable_body.name.contains("Dungeon2Chest8"):
									Globals.player.save_completed_quest("Dungeon2Chest8")
								
								if interactable_body.name.contains("Dungeon2Chest9"):
									Globals.player.save_completed_quest("Dungeon2Chest9")
								
								if interactable_body.name.contains("Dungeon2Chest10"):
									Globals.player.save_completed_quest("Dungeon2Chest10")
								
								if interactable_body.name.contains("Dungeon2Chest11"):
									Globals.player.save_completed_quest("Dungeon2Chest11")
								
								if interactable_body.name.contains("Dungeon2Chest12"):
									Globals.player.save_completed_quest("Dungeon2Chest12")
								
								if interactable_body.name.contains("Dungeon2Chest13"):
									Globals.player.save_completed_quest("Dungeon2Chest13")
								
								if interactable_body.name.contains("Dungeon2Chest14"):
									Globals.player.save_completed_quest("Dungeon2Chest14")
								
								if interactable_body.name.contains("Dungeon2Chest15"):
									Globals.player.save_completed_quest("Dungeon2Chest15")
								
								if interactable_body.name.contains("Dungeon2Chest16"):
									Globals.player.save_completed_quest("Dungeon2Chest16")
								
								interactable_body.interact()
								wood_chest_rewards()
								interactable_body.sync_looted = true
								_current_chest = interactable_body.name
					
					if interactable_body.name.contains("Health Potion"):
						interactable_body.interact()
						add_item_to_inventory("Health Potion",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Magic Potion"):
						interactable_body.interact()
						add_item_to_inventory("Magic Potion",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Bread"):
						interactable_body.interact()
						add_item_to_inventory("Bread",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Abundant Shovel"):
						interactable_body.interact()
						add_item_to_inventory("Abundant Shovel",interactable_body.item_health,"Abundant")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Common Shovel"):
						interactable_body.interact()
						add_item_to_inventory("Common Shovel",interactable_body.item_health,"Common")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Rare Shovel"):
						interactable_body.interact()
						add_item_to_inventory("Rare Shovel",interactable_body.item_health,"Rare")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Epic Shovel"):
						interactable_body.interact()
						add_item_to_inventory("Epic Shovel",interactable_body.item_health,"Epic")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Legendary Shovel"):
						interactable_body.interact()
						add_item_to_inventory("Legendary Shovel",interactable_body.item_health,"Legendary")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Mythical Shovel"):
						interactable_body.interact()
						add_item_to_inventory("Mythical Shovel",interactable_body.item_health,"Mythical")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Abundant Sword"):
						interactable_body.interact()
						add_item_to_inventory("Abundant Sword",interactable_body.item_health,interactable_body.rarity)
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Common Sword"):
						interactable_body.interact()
						add_item_to_inventory("Common Sword",interactable_body.item_health,"Common")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Rare Sword"):
						interactable_body.interact()
						add_item_to_inventory("Rare Sword",interactable_body.item_health,"Rare")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Epic Sword"):
						interactable_body.interact()
						add_item_to_inventory("Epic Sword",interactable_body.item_health,"Epic")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Legendary Sword"):
						interactable_body.interact()
						add_item_to_inventory("Legendary Sword",interactable_body.item_health,"Legendary")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Mythical Sword"):
						interactable_body.interact()
						add_item_to_inventory("Mythical Sword",interactable_body.item_health,"Mythical")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Abundant Dagger"):
						interactable_body.interact()
						add_item_to_inventory("Abundant Dagger",interactable_body.item_health,"Abundant")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Common Dagger"):
						interactable_body.interact()
						add_item_to_inventory("Common Dagger",interactable_body.item_health,"Common")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Rare Dagger"):
						interactable_body.interact()
						add_item_to_inventory("Rare Dagger",interactable_body.item_health,"Rare")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Epic Dagger"):
						interactable_body.interact()
						add_item_to_inventory("Epic Dagger",interactable_body.item_health,"Epic")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Legendary Dagger"):
						interactable_body.interact()
						add_item_to_inventory("Legendary Dagger",interactable_body.item_health,"Legendary")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Mythical Dagger"):
						interactable_body.interact()
						add_item_to_inventory("Mythical Dagger",interactable_body.item_health,"Mythical")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Abundant Helmet"):
						interactable_body.interact()
						add_item_to_inventory("Abundant Helmet",interactable_body.item_health,"Abundant")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Common Helmet"):
						interactable_body.interact()
						add_item_to_inventory("Common Helmet",interactable_body.item_health,"Common")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Rare Helmet"):
						interactable_body.interact()
						add_item_to_inventory("Rare Helmet",interactable_body.item_health,"Rare")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Epic Helmet"):
						interactable_body.interact()
						add_item_to_inventory("Epic Helmet",interactable_body.item_health,"Epic")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Legendary Helmet"):
						interactable_body.interact()
						add_item_to_inventory("Legendary Helmet",interactable_body.item_health,"Legendary")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Mythical Helmet"):
						interactable_body.interact()
						add_item_to_inventory("Mythical Helmet",interactable_body.item_health,"Mythical")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Abundant Armor"):
						interactable_body.interact()
						add_item_to_inventory("Abundant Armor",interactable_body.item_health,"Abundant")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Common Armor"):
						interactable_body.interact()
						add_item_to_inventory("Common Armor",interactable_body.item_health,"Common")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Rare Armor"):
						interactable_body.interact()
						add_item_to_inventory("Rare Armor",interactable_body.item_health,"Rare")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Epic Armor"):
						interactable_body.interact()
						add_item_to_inventory("Epic Armor",interactable_body.item_health,"Epic")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Legendary Armor"):
						interactable_body.interact()
						add_item_to_inventory("Legendary Armor",interactable_body.item_health,"Legendary")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Mythical Armor"):
						interactable_body.interact()
						add_item_to_inventory("Mythical Armor",interactable_body.item_health,"Mythical")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Copper Ore"):
						interactable_body.interact()
						add_item_to_inventory("Copper Ore",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Iron Ore"):
						interactable_body.interact()
						add_item_to_inventory("Iron Ore",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Gold Ore"):
						interactable_body.interact()
						add_item_to_inventory("Gold Ore",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Silver Ore"):
						interactable_body.interact()
						add_item_to_inventory("Silver Ore",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Iron Ingot"):
						interactable_body.interact()
						add_item_to_inventory("Iron Ingot",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Copper Ingot"):
						interactable_body.interact()
						add_item_to_inventory("Copper Ingot",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Silver Ingot"):
						interactable_body.interact()
						add_item_to_inventory("Silver Ingot",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Gold Ingot"):
						interactable_body.interact()
						add_item_to_inventory("Gold Ingot",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Silver Nugget"):
						interactable_body.interact()
						add_item_to_inventory("Silver Nugget",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Gold Nugget"):
						interactable_body.interact()
						add_item_to_inventory("Gold Nugget",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Copper Nugget"):
						interactable_body.interact()
						add_item_to_inventory("Copper Nugget",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Iron Nugget"):
						interactable_body.interact()
						add_item_to_inventory("Iron Nugget",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Leather"):
						interactable_body.interact()
						add_item_to_inventory("Leather",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.name.contains("Cloth"):
						interactable_body.interact()
						add_item_to_inventory("Cloth",100,"")
						if _current_item != interactable_body.name:
							_current_item = interactable_body.name
					if interactable_body.is_in_group("npc"):
						#INTERACT ISSUE WITH THE INGAME NPC
						#ADD ALL GAME NPCS TO THIS GROUP TO CONTROL INTERACTION.
						interactable_body.interact()

				if interactable_body.name.contains("Abundant Trilium Crystal"):
					if mining_cooldown_timer.is_stopped():
						is_mining = true
						player_sound_fx.stream = miningSound
						player_sound_fx.play()
						mining_progress_bar.visible = true
						x_direction = 0
						y_direction = 0
						
						if interactable_body.global_position.x < self.global_position.x:
							x_direction = -1  # Face left
						elif interactable_body.global_position.x > self.global_position.x:
							x_direction = 1  # Face right
						if interactable_body.global_position.y < self.global_position.y:
							y_direction = 1  # Face down
						elif interactable_body.global_position.y > self.global_position.y:
							y_direction = -1  # Face up
						# Check vertical direction
						mining_direction = Vector2(x_direction, y_direction)
						# start the timer to mine
						#mining_timer.wait_time = sync_equipped_mining_equipment.mine_time
						mining_timer.one_shot = true
						mining_timer.start(sync_equipped_mining_equipment.mine_time)
						mining_progress_bar.max_value = sync_equipped_mining_equipment.mine_time #dynamically change the max value
				if interactable_body.name.contains("Common Trilium Crystal"):
					if mining_cooldown_timer.is_stopped():
						is_mining = true
						player_sound_fx.stream = miningSound
						player_sound_fx.play()
						mining_progress_bar.visible = true
						x_direction = 0
						y_direction = 0
						
						if interactable_body.global_position.x < self.global_position.x:
							x_direction = -1  # Face left
						elif interactable_body.global_position.x > self.global_position.x:
							x_direction = 1  # Face right
						if interactable_body.global_position.y < self.global_position.y:
							y_direction = 1  # Face down
						elif interactable_body.global_position.y > self.global_position.y:
							y_direction = -1  # Face up
						# Check vertical direction
						mining_direction = Vector2(x_direction, y_direction)
						# start the timer to mine
						#mining_timer.wait_time = sync_equipped_mining_equipment.mine_time
						mining_timer.one_shot = true
						mining_timer.start(sync_equipped_mining_equipment.mine_time)
						mining_progress_bar.max_value = sync_equipped_mining_equipment.mine_time #dynamically change the max value
		
		if Input.is_action_just_pressed("ui_attack"):
			if is_attack_enabled and in_battle and battle_charge_up_timer.is_stopped():
				_damage_to_equipped_item(sync_equipped_weapon)
				if battle_charge_up_timer.time_left <= 0:
					attack()
					battle_charge_up_timer.start()
					is_attack_enabled = false 
					await(get_tree().create_timer(1).timeout)
					is_attacking = false
		
		if Input.is_action_just_pressed("ui_attack_magic"):
			is_magic_attack_enabled = true
			if is_attack_enabled and in_battle and battle_charge_up_timer.is_stopped():
				if battle_charge_up_timer.time_left <= 0 :
					magic_attack()
					battle_charge_up_timer.start()
					is_attack_enabled = false 
					await(get_tree().create_timer(1).timeout)
					#is_magic_attack_enabled turning to false in enemy scene's scripts
		# Get input direction
		if not Globals.hud.dialog_panel_is_visible() and is_mining == false  and Globals.menu_isOpen == false and Globals.inventory_isOpen == false:
			input_direction = Vector2(
				Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
				Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			)
		
		# If the player is in battle, the player is locked in place
		if !in_battle and not Globals.hud.dialog_panel_is_visible():
			# Update Velocity
			velocity = input_direction * move_speed
			sync_velocity = velocity
			
			# Update the animation
			update_animation_parameters(input_direction)
			
			# Set the animation state
			pick_new_state()
			
			# Move and slide
			# object "collision" contains information about the collision
			var collision = move_and_collide(input_direction*5)
			if collision:
				var collide  = input_direction.rotated(10)
				move_and_collide(collide)
			else:
				move_and_slide()
			
			# Tell the server our new input direction
			sync_input_direction = input_direction
				
		if in_battle:
			pick_new_state()
			
		# Keep all HUD values current
		Globals.hud.set_trilium_balance(sync_trilium_balance)
		
		# If the player is mining, update the mining progress bar
		#mining_progress_bar.value = 10 - mining_timer.time_left
		mining_progress_bar.value = int(mining_timer.time_left)
		
		# Set the HUD to coord
		Globals.hud.set_coord(position)
		
		Globals.hit_points = sync_hit_points
		Globals.magic_points = sync_magic_points

	else:
		if Input.is_action_just_pressed("ui_interact"):
			print("Interact has been pressed for npc.")
			if interactable_body != null:
				if interactable_body.is_in_group("npc"):
					if interactable_body.has_method("interact"):
						interactable_body.interact()
						
	handle_character_level() #TOGGLE PLAYER TRAITS

func update_animation_parameters(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

func pick_new_state():
	direction = Vector2(1, 0)  # Default to facing right
	x_direction = 0
	y_direction = 0
	weapon_name_upper = sync_equipped_weapon.name.to_upper()
	mining_equipment_name_upper = sync_equipped_mining_equipment.name.to_upper()
	if is_mining:
		if velocity != Vector2.ZERO:
			state_machine.travel("Walk",false)
	if not in_battle and not is_mining and not is_dead:
		if velocity != Vector2.ZERO:
			state_machine.travel("Walk", false)
		else:
			state_machine.travel("Idle", false)
	elif is_mining and !in_battle and !is_attacking:
		# Original logic to determine which mining animation to play
		state_machine.travel("Mine")
		set_mine_animation_conditions(mining_equipment_name_upper)
	elif in_battle && not is_attacking && not is_attacking_w_magic:
		if _target:
			# Check horizontal direction
			if _target.global_position.x < self.global_position.x:
				x_direction = -1  # Face left
			elif _target.global_position.x > self.global_position.x:
				x_direction = 1  # Face right

			# Check vertical direction
			if _target.global_position.y < self.global_position.y:
				y_direction = 1  # Face up
			elif _target.global_position.y > self.global_position.y:
				y_direction = -1  # Face down

			direction = Vector2(x_direction, y_direction)
		
		# Original logic to determine which combat idle animation to play
		if is_magic_attack_enabled:
			animation_tree.set("parameters/MagicCharge1/blend_position", direction)
			state_machine.travel("MagicCharge1")
		elif sync_equipped_weapon.name.to_upper().contains("DAGGER") :
			state_machine.travel("IdleCombatDagger")
			set_combat_idle_animation_conditions(weapon_name_upper)
		elif sync_equipped_weapon.name.to_upper().contains("SWORD"):
			state_machine.travel("IdleCombatSword")
			set_combat_idle_animation_conditions(weapon_name_upper)
		else:
			animation_tree.set("parameters/IdleCombat/blend_position", direction)
			state_machine.travel("IdleCombat")
	elif in_battle && is_attacking:
		if _target:
			# Check horizontal direction
			if _target.global_position.x < self.global_position.x:
				x_direction = -1  # Face left
			elif _target.global_position.x > self.global_position.x:
				x_direction = 1  # Face right

			# Check vertical direction
			if _target.global_position.y < self.global_position.y:
				y_direction = 1  # Face up
			elif _target.global_position.y > self.global_position.y:
				y_direction = -1  # Face down

			direction = Vector2(x_direction, y_direction)
		
		if sync_equipped_weapon.name.to_upper().contains("DAGGER"):
			state_machine.travel("SwingCombatDagger")
			set_combat_swing_animation_conditions(weapon_name_upper)
		elif sync_equipped_weapon.name.to_upper().contains("SWORD"):
			state_machine.travel("SwingCombatSword")
			set_combat_swing_animation_conditions(weapon_name_upper)
		else:
			animation_tree.set("parameters/SwingJab/blend_position", direction)
			state_machine.travel("SwingJab")
	elif in_battle && is_attacking_w_magic:
		if _target:
			# Check horizontal direction
			if _target.global_position.x < self.global_position.x:
				x_direction = -1  # Face left
			elif _target.global_position.x > self.global_position.x:
				x_direction = 1  # Face right
			# Check vertical direction
			if _target.global_position.y < self.global_position.y:
				y_direction = 1  # Face up
			elif _target.global_position.y > self.global_position.y:
				y_direction = -1  # Face down
			direction = Vector2(x_direction, y_direction)
		animation_tree.set("parameters/MagicCast/blend_position", direction)
		state_machine.travel("MagicCast")

func set_mine_animation_conditions(equipment_name: String):
	# Reset all conditions
	animation_tree["parameters/Mine/conditions/is_mythical"] = false
	animation_tree["parameters/Mine/conditions/is_legendary"] = false
	animation_tree["parameters/Mine/conditions/is_epic"] = false
	animation_tree["parameters/Mine/conditions/is_rare"] = false
	animation_tree["parameters/Mine/conditions/is_common"] = false
	animation_tree["parameters/Mine/conditions/is_abundant"] = false

	# Set conditions based on holding equipment type
	if equipment_name == "ABUNDANT SHOVEL":
		animation_tree.set("parameters/Mine/MineAbundantShovel/blend_position", mining_direction)
		animation_tree["parameters/Mine/conditions/is_abundant"] = true
	elif equipment_name == "COMMON SHOVEL":
		animation_tree.set("parameters/Mine/MineCommonShovel/blend_position", mining_direction)
		animation_tree["parameters/Mine/conditions/is_common"] = true
	elif equipment_name == "RARE SHOVEL":
		animation_tree.set("parameters/Mine/MineRareShovel/blend_position", mining_direction)
		animation_tree["parameters/Mine/conditions/is_rare"] = true
	elif equipment_name == "EPIC SHOVEL":
		animation_tree.set("parameters/Mine/MineEpicShovel/blend_position", mining_direction)
		animation_tree["parameters/Mine/conditions/is_epic"] = true
	elif equipment_name == "LEGENDARY SHOVEL":
		animation_tree.set("parameters/Mine/MineLegendaryShovel/blend_position", mining_direction)
		animation_tree["parameters/Mine/conditions/is_legendary"] = true
	elif equipment_name == "MYTHICAL SHOVEL":
		animation_tree.set("parameters/Mine/MineMythicalShovel/blend_position", mining_direction)
		animation_tree["parameters/Mine/conditions/is_mythical"] = true

func set_combat_idle_animation_conditions(weapon_name: String):
	# Reset all conditions
	animation_tree["parameters/IdleCombatSword/conditions/is_mythical"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_legendary"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_epic"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_rare"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_common"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_abundant"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_mythical"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_legendary"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_epic"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_rare"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_common"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_abundant"] = false

	# Set conditions based on holding weapon type
	if weapon_name == "ABUNDANT DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleAbundantDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_abundant"] = true
	elif weapon_name == "COMMON DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleCommonDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_common"] = true
	elif weapon_name == "RARE DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleRareDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_rare"] = true
	elif weapon_name == "EPIC DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleEpicDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleLegendaryDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_legendary"] = true
	elif weapon_name == "MYTHICAL DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleMythicalDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_mythical"] = true
	elif weapon_name == "ABUNDANT SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleAbundantSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_abundant"] = true
	elif weapon_name == "COMMON SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleCommonSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_common"] = true
	elif weapon_name == "RARE SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleRareSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_rare"] = true
	elif weapon_name == "EPIC SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleEpicSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleLegendarySword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_legendary"] = true
	elif weapon_name == "MYTHICAL SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleMythicalSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_mythical"] = true

func set_combat_swing_animation_conditions(weapon_name: String):
	# Reset all conditions
	animation_tree["parameters/SwingCombatSword/conditions/is_mythical"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_legendary"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_epic"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_rare"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_common"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_abundant"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_mythical"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_legendary"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_epic"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_rare"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_common"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_abundant"] = false

	# Set conditions based on holding weapon type
	if weapon_name == "ABUNDANT DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingAbundantDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_abundant"] = true
	elif weapon_name == "COMMON DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingCommonDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_common"] = true
	elif weapon_name == "RARE DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingRareDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_rare"] = true
	elif weapon_name == "EPIC DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingEpicDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingLegendaryDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_legendary"] = true
	elif weapon_name == "MYTHICAL DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingMythicalDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_mythical"] = true
	elif weapon_name == "ABUNDANT SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingAbundantSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_abundant"] = true
	elif weapon_name == "COMMON SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingCommonSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_common"] = true
	elif weapon_name == "RARE SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingRareSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_rare"] = true
	elif weapon_name == "EPIC SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingEpicSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingLegendarySword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_legendary"] = true
	elif weapon_name == "MYTHICAL SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingMythicalSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_mythical"] = true

func _on_area_2d_body_entered(body):
	if "interactable" in body:
		interactable_body = body
		print(str("Player can now interact with " + body.name))
		body.show_info_button()
		Globals.hud.show_tip_text()

#func _input(event):
#	if event.is_action_pressed("ui_interact"):
#		pass

func _on_area_2d_body_exited(body):
	if "interactable" in body:
		interactable_body = null
		body.hide_info_button()
		Globals.hud.hide_tip_text()
		
		if body.has_method("cancel_interaction"):
			body.cancel_interaction()
		
		if body.name.contains("TriliumCrystal") or body.name.contains("Trilium Crystal"):
			mining_timer.stop()
			mining_progress_bar.value = 0
			mining_progress_bar.visible = false

func wood_chest_rewards():
	var chance_of_abundant_shovel = 0.1
	var chance_of_common_shovel = 0.09
	var chance_of_rare_shovel = 0.08
	var chance_of_epic_shovel = 0.07
	var chance_of_legendary_shovel = 0.06
	var chance_of_mythical_shovel = 0.01
	var chance_of_abundant_health_potion = 0.1
	var chance_of_abundant_magic_potion = 0.1
	var chance_of_abundant_dagger = 0.1
	var chance_of_common_dagger = 0.09
	var chance_of_rare_dagger = 0.08
	var chance_of_epic_dagger = 0.07
	var chance_of_legendary_dagger = 0.06
	var chance_of_mythical_dagger = 0.01
	var chance_of_copper_ore = 0.1
	var chance_of_iron_ore = 0.1
	var chance_of_gold_ore = 0.1
	var chance_of_silver_ore = 0.1
	var chance_of_cloth = 0.1
	var chance_of_leather = 0.1
	var minimum_amount_of_trilium = 0.005
	var maximum_amount_of_trilium = 0.01
	
	if (randf() < chance_of_copper_ore):
		add_item_to_inventory("Copper Ore",100,"")
		flash_text("Found Copper Ore!")
		return
	
	if (randf() < chance_of_iron_ore):
		add_item_to_inventory("Iron Ore",100,"")
		flash_text("Found Iron Ore!")
		return
		
	if (randf() < chance_of_silver_ore):
		add_item_to_inventory("Silver Ore",100,"")
		flash_text("Found Silver Ore!")
		return
	
	if (randf() < chance_of_gold_ore):
		add_item_to_inventory("Gold Ore",100,"")
		flash_text("Found Gold Ore!")
		return
	
	if (randf() < chance_of_cloth):
		add_item_to_inventory("Cloth",100,"")
		flash_text("Found Cloth!")
		return
	
	if (randf() < chance_of_leather):
		add_item_to_inventory("Leather",100,"")
		flash_text("Found Leather!")
		return
		
	if (randf() < chance_of_abundant_shovel):
		add_item_to_inventory("Abundant Shovel",100,"Abundant")
		flash_text("Found a Abundant Shovel!")
		return
	
	if (randf() < chance_of_common_shovel):
		add_item_to_inventory("Common Shovel",100,"Common")
		flash_text("Found an Common Shovel!")
		return
	
	if (randf() < chance_of_rare_shovel):
		add_item_to_inventory("Rare Shovel",100,"Rare")
		flash_text("Found a Rare Shovel!")
		return
	
	if (randf() < chance_of_epic_shovel):
		add_item_to_inventory("Epic Shovel",100,"Epic")
		flash_text("Found an Epic Shovel!")
		return
	
	if (randf() < chance_of_legendary_shovel):
		add_item_to_inventory("Legendary Shovel",100,"Legendary")
		flash_text("Found a Legendary Shovel!")
		return
	
	if (randf() < chance_of_mythical_shovel):
		add_item_to_inventory("Mythical Shovel",100,"Mythical")
		flash_text("Found a Mythical Shovel!")
		return
	
	if (randf() < chance_of_abundant_health_potion):
		add_item_to_inventory("Health Potion",100,"")
		flash_text("Found a Health Potion!")
		return
	
	if (randf() < chance_of_abundant_magic_potion):
		add_item_to_inventory("Magic Potion",100,"")
		flash_text("Found a Magic Potion!")
		return
	
	if (randf() < chance_of_abundant_dagger):
		add_item_to_inventory("Abundant Dagger",100,"Abundant")
		flash_text("Found a Abundant Dagger!")
		return
	
	if (randf() < chance_of_common_dagger):
		add_item_to_inventory("Common Dagger",100,"Common")
		flash_text("Found an Common Dagger!")
		return
	
	if (randf() < chance_of_rare_dagger):
		add_item_to_inventory("Rare Dagger",100,"Rare")
		flash_text("Found a Rare Dagger!")
		return
	
	if (randf() < chance_of_epic_dagger):
		add_item_to_inventory("Epic Dagger",100,"Epic")
		flash_text("Found an Epic Dagger!")
		return
	
	if (randf() < chance_of_legendary_dagger):
		add_item_to_inventory("Legendary Dagger",100,"Legendary")
		flash_text("Found a Legendary Dagger!")
		return
	
	if (randf() < chance_of_mythical_dagger):
		add_item_to_inventory("Mythical Dagger",100,"Mythical")
		flash_text("Found a Mythical Dagger!")
		return
	
	# Didn't get an item, found a small amount of trilium
	var trilium_award = round_to_dec(RandomNumberGenerator.new().randf_range(minimum_amount_of_trilium, maximum_amount_of_trilium), 4)
	sync_trilium_balance += trilium_award
	_save_trilium({"triliumBalance": sync_trilium_balance})
	

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func add_trilium(trilium_amount):
	_add_trilium(trilium_amount)

@rpc("any_peer", "unreliable_ordered")
func _add_trilium(trilium_amount):
	sync_trilium_balance += trilium_amount
	_save_trilium({"triliumBalance": sync_trilium_balance})
	flash_text("+" + str(trilium_amount) + " TLM")
	


func handle_character_level():
	var level = determine_level(sync_exp)
	
	if level > sync_level:
		sync_level = level
		update_stats()


func calculate_xp_for_next_level(current_level):
	# Adjusting formula for exponential growth
	var experience_needed_to_progress = scale_factor * pow(growth_rate, current_level - starting_level)
	return experience_needed_to_progress


# Function to determine the current level based on total XP
func determine_level(total_xp):
	var level = starting_level
	var accumulated_xp = 0.0

	while accumulated_xp <= total_xp:
		accumulated_xp += calculate_xp_for_next_level(level)
		if accumulated_xp > total_xp:
			break
		level += 1

	return level


func update_stats():
	var base_hp = 10
	var base_mp = 10
	var base_strength = 10
	var base_move_speed = 100
	var hp_increase_factor = 0.725
	var mp_increase_rate = 3
	var move_speed_percentage_increase = 0.002
	var strength_percentage_increase = 0.02

	var new_hp = base_hp + (hp_increase_factor * sync_level * sync_level)
	var new_mp = base_mp + (mp_increase_rate * sqrt(sync_level))
	var new_strength = base_strength * (1 + strength_percentage_increase * sync_level)
	var new_speed = base_move_speed * (1 + move_speed_percentage_increase * sync_level)

	# Update the character's stats
	sync_max_hit_points = new_hp
	sync_max_magic_points = new_mp
	sync_strength = new_strength
	move_speed = new_speed


func add_experience(experience_amount):
	_add_experience(experience_amount)

func _add_experience(experience_amount):
	sync_exp += experience_amount
	_save_experience({"experience": sync_exp})

# Remove experience function for Dev's to test level up system
func remove_experience(experience_amount):
	_remove_experience(experience_amount)

func _remove_experience(experience_amount):
	sync_exp -= experience_amount
	_save_experience({"experience": sync_exp})

func _determine_item_type(item_name : String,rarity : String) -> InventoryItem:
	var item : InventoryItem
	
	if item_name.contains("Standard"):
		item_name = item_name.replace("Standard",rarity)
	
	if item_name.contains("Health Potion"):
		item = Items.health_potion()
	
	if item_name.contains("Magic Potion"):
		item = Items.magic_potion()
	
	if item_name.contains("Bread"):
		item = Items.bread()
	
	if item_name.contains("Abundant Shovel"):
		item = MiningEquipments.abundant_shovel()
	
	if item_name.contains("Common Shovel"):
		item = MiningEquipments.common_shovel()
	
	if item_name.contains("Rare Shovel"):
		item = MiningEquipments.rare_shovel()
	
	if item_name.contains("Epic Shovel"):
		item = MiningEquipments.epic_shovel()
	
	if item_name.contains("Legendary Shovel"):
		item = MiningEquipments.legendary_shovel()
	
	if item_name.contains("Mythical Shovel"):
		item = MiningEquipments.mythical_shovel()
	
	if item_name.contains("Abundant Dagger"):
		item = Weapons.abundant_dagger()
	
	if item_name.contains("Common Dagger"):
		item = Weapons.common_dagger()
	
	if item_name.contains("Rare Dagger"):
		item = Weapons.rare_dagger()
	
	if item_name.contains("Epic Dagger"):
		item = Weapons.epic_dagger()
	
	if item_name.contains("Legendary Dagger"):
		item = Weapons.legendary_dagger()
	
	if item_name.contains("Mythical Dagger"):
		item = Weapons.mythical_dagger()
	
	if item_name.contains("Abundant Sword"):
		item = Weapons.abundant_sword()
	
	if item_name.contains("Common Sword"):
		item = Weapons.common_sword()
	
	if item_name.contains("Rare Sword"):
		item = Weapons.rare_sword()
	
	if item_name.contains("Epic Sword"):
		item = Weapons.epic_sword()
	
	if item_name.contains("Legendary Sword"):
		item = Weapons.legendary_sword()
	
	if item_name.contains("Mythical Sword"):
		item = Weapons.mythical_sword()
	
	if item_name.contains("Abundant Helmet"):
		item = Helmets.abundant_helmet()
	
	if item_name.contains("Common Helmet"):
		item = Helmets.common_helmet()
	
	if item_name.contains("Rare Helmet"):
		item = Helmets.rare_helmet()
	
	if item_name.contains("Epic Helmet"):
		item = Helmets.epic_helmet()
	
	if item_name.contains("Legendary Helmet"):
		item = Helmets.legendary_helmet()
	
	if item_name.contains("Mythical Helmet"):
		item = Helmets.mythical_helmet()
	
	if item_name.contains("Abundant Armor"):
		item = Armors.abundant_armor()
	
	if item_name.contains("Common Armor"):
		item = Armors.common_armor()
	
	if item_name.contains("Rare Armor"):
		item = Armors.rare_armor()
	
	if item_name.contains("Epic Armor"):
		item = Armors.epic_armor()
	
	if item_name.contains("Legendary Armor"):
		item = Armors.legendary_armor()
	
	if item_name.contains("Mythical Armor"):
		item = Armors.mythical_armor()
	
	if item_name.contains("Copper Ore"):
		item = Items.copper_ore()
	
	if item_name.contains("Iron Ore"):
		item = Items.iron_ore()
	
	if item_name.contains("Gold Ore"):
		item = Items.gold_ore()
	
	if item_name.contains("Silver Ore"):
		item = Items.silver_ore()
	
	if item_name.contains("Copper Ingot"):
		item = Items.copper_ingot()
		
	if item_name.contains("Iron Ingot"):
		item = Items.iron_ingot()
		
	if item_name.contains("Silver Ingot"):
		item = Items.silver_ingot()
		
	if item_name.contains("Gold Ingot"):
		item = Items.gold_ingot()
		
	if item_name.contains("Silver Nugget"):
		item = Items.silver_nugget()
		
	if item_name.contains("Copper Nugget"):
		item = Items.copper_nugget()
		
	if item_name.contains("Iron Nugget"):
		item = Items.iron_nugget()
		
	if item_name.contains("Gold Nugget"):
		item = Items.gold_nugget()
		
	if item_name.contains("Leather"):
		item = Items.leather()
		
	if item_name.contains("Cloth"):
		item = Items.cloth()
		
	return item

func add_item_to_inventory(item_name: String, item_health: int,rarity : String):
	randomize()
	print("adding " + item_name + " with health: " + str(item_health) + " to inventory. DB + local ")
	var item_to_add = _determine_item_type(item_name,rarity)
	var modified_name

	if item_to_add == null:
		print("Error adding item. Item name or health do not meet requirements")
		return
	else:
		item_to_add.item_health = item_health
		if item_to_add.item_ID == "":
			item_to_add.item_ID = Globals.uuid_util.v4()
		if item_to_add.collection_name == "":
			item_to_add.collection_name = "triliumquest"

		# Initialize the modified name with the original name

		# Check and update the rarity field
		if "Abundant" in item_name:
			modified_name = item_name.replace("Abundant", "Standard")
		elif "Common" in item_name:
			modified_name = item_name.replace("Common", "Standard")
		elif "Rare" in item_name:
			modified_name = item_name.replace("Rare", "Standard")
		elif "Epic" in item_name:
			modified_name = item_name.replace("Epic", "Standard")
		elif "Legendary" in item_name:
			modified_name = item_name.replace("Legendary", "Standard")
		elif "Mythical" in item_name:
			modified_name = item_name.replace("Mythical", "Standard")

		# Append the modified item to the inventory
		sync_weapons_in_inventory.append(item_to_add)

	# Append the original item to the inventory
	sync_inventory.append(item_to_add)

	# Save the item with the modified name
	if item_to_add.rarity != "":
		save_inventory_item({
			"id": item_to_add.item_ID,
			"name": modified_name,
			"equipmentHealth": item_to_add.item_health,
			"collectionName": item_to_add.collection_name,
			"rarity": item_to_add.rarity
		})
	else:
		save_inventory_item({
			"id": item_to_add.item_ID,
			"name": item_to_add.name,
			"equipmentHealth": item_to_add.item_health,
			"collectionName": item_to_add.collection_name
		})
	#print("Attempting to add " + item_name + " to inventory.")
	
	for i in sync_weapons_in_inventory:
		pass
		#print(i.name + str(i.item_ID))

#	for item in sync_inventory:
#			if item.name == item_name:
#				owns_item = true
#				item.quantity += 1
#
#		if not owns_item:
#			var item_to_add = _determine_item_type(item_name)
#			sync_inventory.append(item_to_add)

func separate_items_by_damage():
	pass

func add_to_crafting_panel(item_name):
	var owns_item = false
	var rarity = ""
	
	for item in sync_crafting:
		
		if item.name == item_name:
			owns_item = true
			item.quantity += 1
			rarity = item.rarity
			
	if not owns_item:
		var item_to_add = _determine_item_type(item_name,rarity)
		sync_crafting.append(item_to_add)

func remove_resource_from_crafting(item_name):
	for i in range(sync_crafting.size()):
		if sync_crafting[i].name.contains(item_name):
			if sync_crafting[i].quantity > 0:
				sync_crafting[i].quantity = sync_crafting[i].quantity - 1

func remove_all_resource_from_crafting(item_name, total: int):
	for i in range(sync_crafting.size()):
		if sync_crafting[i].name.contains(item_name):
			if sync_crafting[i].quantity > 0:
				sync_crafting[i].quantity = sync_crafting[i].quantity - total

func remove_item_from_inventory( item_ID:String):
	
	print("trying to remove item from DB: id:"+item_ID)
	for i in range(sync_inventory.size()):
		print(str(i)+": item:"+sync_inventory[i].name)
		if sync_inventory[i].item_ID==item_ID:
			sync_inventory.remove_at(i)
			Globals.hud._update_inventory_panel()
			remove_inventory_item({"id":item_ID})
			return

func _on_mining_timer_timeout():
	# Here is where we would add the trilium to the player
	var trilium_award = round_to_dec(RandomNumberGenerator.new().randf_range(interactable_body.MIN_REWARD, interactable_body.MAX_REWARD), 4)
	sync_trilium_balance += trilium_award * sync_equipped_mining_equipment.multiplier
	flash_text("+" + str(trilium_award) + " TLM")
	_save_trilium({"triliumBalance": sync_trilium_balance})
	
	mining_progress_bar.visible = false
	mining_progress_bar.value = 0
	mining_cooldown_timer.wait_time = sync_equipped_mining_equipment.mining_cooldown_time_in_seconds
	mining_cooldown_timer.one_shot = true
	
	Globals.hud.mining_cooldown_progress_bar.max_value = sync_equipped_mining_equipment.mining_cooldown_time_in_seconds
	Globals.hud.mining_cooldown_progress_bar.value = sync_equipped_mining_equipment.mining_cooldown_time_in_seconds
	Globals.hud.show_mining_cool_down_ui()
	
	_damage_to_equipped_item(sync_equipped_mining_equipment) #DO DAMAGE TO MINING EQUIPMENT
	
	_save_mining_locked_period({"lastMined":int(sync_equipped_mining_equipment.mining_cooldown_time_in_seconds+Time.get_unix_time_from_system())*1000})
	is_mining = false
	remove_child(player_sound_fx)
	mining_cooldown_timer.start()

	
	if interactable_body.name.contains("Dungeon1CommonTriliumCrystal1"):
		Globals.player.save_completed_quest("Dungeon1CommonTriliumCrystal1")
	
	if interactable_body.name.contains("Dungeon2AbundantTriliumCrystal1"):
		Globals.player.save_completed_quest("Dungeon2AbundantTriliumCrystal1")
	
	if interactable_body.name.contains("Dungeon2AbundantTriliumCrystal2"):
		Globals.player.save_completed_quest("Dungeon2AbundantTriliumCrystal2")
	
	if interactable_body.name.contains("Dungeon2AbundantTriliumCrystal3"):
		Globals.player.save_completed_quest("Dungeon2AbundantTriliumCrystal3")
	
	if interactable_body.name.contains("Dungeon2CommonTriliumCrystal1"):
		Globals.player.save_completed_quest("Dungeon2CommonTriliumCrystal1")
	
	# Here is where we would do an animation to get destroy the crystal
	interactable_body.destruction_sequence()

func flash_text(display_text):
	var flashing_text = FlashingText.instantiate()
	add_child(flashing_text)
	flashing_text.position = Vector2(0, 18)
	flashing_text.set_text(display_text)
	flashing_text.play_animation()

func flash_damaged_equipment_text(display_text):
	var flashing_text = FlashingText.instantiate()
	add_child(flashing_text)
	flashing_text.position = Vector2(0, 24)
	flashing_text.set_text(display_text)
	flashing_text.play_animation()

func flash_global_text(display_text):
	flash_text(display_text)

func start_battle(target : NodePath):
	print("Starting battle with:", target)
	_target = get_node(target)
	in_battle = true
	start_battle_music()
	Globals.hud.battle_charge_up_progress_bar.value = 0
	Globals.hud.battle_charge_up_progress_bar.max_value = sync_equipped_weapon.attack_charge_up_time_in_seconds
	battle_charge_up_timer.wait_time = sync_equipped_weapon.attack_charge_up_time_in_seconds
	battle_charge_up_timer.one_shot = true
	battle_charge_up_timer.start()
	Globals.hud.attack_button.disabled = true
	Globals.hud.show_attack_ui()
	print("Battle started. In battle state:", in_battle)

func remove_target():
	_target = null

func end_battle():
	print("End Battle")
	in_battle = false
	is_attacking = false
	end_battle_music()
	battle_charge_up_timer.stop()
	Globals.hud.hide_attack_ui()
	print("Battle ended. In battle state:", in_battle)

func _on_mining_cooldown_timer_timeout():
	Globals.hud.hide_mining_cool_down_ui()

func _on_battle_charge_up_timer_timeout():
	Globals.hud.attack_button.disabled = false
	is_attack_enabled = true
	if in_battle:
		play_ready_sound_effect()

func is_critical_hit() -> bool:
	return randf() < sync_equipped_weapon.chance_of_critical_hit

func is_miss() -> bool:
	return randf() < sync_equipped_weapon.chance_of_miss

func start_battle_music():
	previous_music_stream = Globals.music_player.stream
	Globals.music_player.stop()
	Globals.music_player.stream = battle_music_stream
	Globals.music_player.play()

func end_battle_music():
	Globals.music_player.stop()
	Globals.music_player.stream = previous_music_stream
	Globals.music_player.play()

func add_hp(hit_point_amount : int):
	var display_text : String
	display_text = "+" + str(hit_point_amount) + " HP"
	# The text needs to be shown to everyone on the network
	flash_text(display_text)
	
	_add_hp(hit_point_amount)

func _add_hp(hit_point_amount : int):
	if (sync_hit_points + hit_point_amount > sync_max_hit_points):
		print("setting HP to " + str(sync_max_hit_points))
		sync_hit_points = sync_max_hit_points
		_save_hit_points({"hitPoints" : sync_hit_points})
	else:
		print("setting HP to " + str(sync_hit_points + hit_point_amount))
		sync_hit_points += hit_point_amount
		_save_hit_points({"hitPoints" : sync_hit_points})

func subtract_hp(hit_point_amount):
	var display_text: String
	if hit_point_amount == 0:
		display_text = "MISS!"
		if is_hit:
			is_hit = false
	else:
		display_text = "-" + str(hit_point_amount) + " HP"
		is_hit = true
		# Check horizontal direction
		if _target:
			x_direction = 0
			y_direction = 0
			weapon_name_upper = sync_equipped_weapon.name.to_upper()
			if _target.global_position.x < self.global_position.x:
				x_direction = -1  # Face left
			elif _target.global_position.x > self.global_position.x:
				x_direction = 1  # Face right
			# Check vertical direction
			if _target.global_position.y < self.global_position.y:
				y_direction = -1  # Face up
			elif _target.global_position.y > self.global_position.y:
				y_direction = 1  # Face down
			direction = Vector2(x_direction, y_direction)
			# Update animation based on weapon type
			state_machine.travel("GettingHit")
			animation_tree.set("parameters/GettingHit/blend_position", direction)
			# Set animation conditions
			set_hit_animation_conditions(weapon_name_upper)
	# The text needs to be shown to everyone on the network
	flash_text(display_text)
	
	# The actual deduction needs to be an RPC call as well
	_subtract_hp(hit_point_amount)

func set_hit_animation_conditions(weapon_name: String):
	# Reset all conditions
	animation_tree["parameters/GettingHit/conditions/is_abundant_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_common_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_rare_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_epic_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_legendary_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_mythical_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_abundant_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_common_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_rare_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_epic_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_legendary_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_mythical_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_unarmed"] = false

	# Set conditions based on holding weapon type
	if weapon_name == "ABUNDANT DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_abundant_dagger"] = true
	elif weapon_name == "COMMON DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_common_dagger"] = true
	elif weapon_name == "RARE DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_rare_dagger"] = true
	elif weapon_name == "EPIC DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_epic_dagger"] = true
	elif weapon_name == "LEGENDARY DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_legendary_dagger"] = true
	elif weapon_name == "MYTHICAL DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_mythical_dagger"] = true
	elif weapon_name == "ABUNDANT SWORD":
		animation_tree["parameters/GettingHit/conditions/is_abundant_sword"] = true
	elif weapon_name == "COMMON SWORD":
		animation_tree["parameters/GettingHit/conditions/is_common_sword"] = true
	elif weapon_name == "RARE SWORD":
		animation_tree["parameters/GettingHit/conditions/is_rare_sword"] = true
	elif weapon_name == "EPIC SWORD":
		animation_tree["parameters/GettingHit/conditions/is_epic_sword"] = true
	elif weapon_name == "LEGENDARY SWORD":
		animation_tree["parameters/GettingHit/conditions/is_legendary_sword"] = true
	elif weapon_name == "MYTHICAL SWORD":
		animation_tree["parameters/GettingHit/conditions/is_mythical_sword"] = true
	else:
		animation_tree["parameters/GettingHit/conditions/is_unarmed"] = true

func respawn_player(scene_name):
	var scene = get_tree().root.get_node("Game").get_node("SceneWrapper").get_node(scene_name)
	if scene:
		scene.queue_free()
		var overworld_scene = Overworld.instantiate()
		overworld_scene.visible = true
		overworld_scene.set_process_input(true)
		get_tree().root.get_node("Game").get_node("SceneWrapper").add_child(overworld_scene)
		var wandering_dunes_area = overworld_scene.get_node("WanderingDunesArea")
		var spawn_area = wandering_dunes_area.get_node("SpawnArea")
		if spawn_area:
			Globals.player.global_position = spawn_area.global_position

func _subtract_hp(amount):
	if (sync_hit_points - amount <= 0):
		end_battle()
		is_dead = true
		animation_tree.set("parameters/Collapse/blend_position",direction)
		state_machine.travel("Collapse")
		await get_tree().create_timer(1.0).timeout
		emit_signal("destroyed")
		sync_hit_points = sync_max_hit_points
		sync_trilium_balance = sync_trilium_balance / 2
		_save_trilium({"triliumBalance": sync_trilium_balance})
		_save_hit_points({"hitPoints" : sync_hit_points})
		respawn_player(Globals.current_scene)
		is_dead = false
	else:
		is_hit = true
		var armor_protection_amount = 0
		if!(sync_equipped_armor== null || sync_equipped_armor.name == "Armor" || sync_equipped_armor.name=="Bare Hands" || sync_equipped_armor.name==""):
			armor_protection_amount += sync_equipped_armor.defence_power/10*amount
			print("Armor protected HP:"+ str(armor_protection_amount))
			
		if!(sync_equipped_helmet== null || sync_equipped_helmet.name == "Helmet" || sync_equipped_helmet.name=="Bare Hands" || sync_equipped_helmet.name==""):
			armor_protection_amount += sync_equipped_helmet.defence_power/10*amount
			print("Armor + Helmet protected HP:"+ str(armor_protection_amount))
			
		_damage_to_equipped_item(sync_equipped_armor)
		_damage_to_equipped_item(sync_equipped_helmet) 
		amount -= armor_protection_amount
		sync_hit_points -= amount
		_save_hit_points({"hitPoints" : sync_hit_points})

func destroy_equipped_weapon():
	if Globals.player.sync_equipped_weapon.name != "Left Hand":
		save_equipped_weapon({"equippedWeapon": "Left Hand"})
		Globals.hud._update_equipped_weapon_tab()
		#RESET

func destroy_equipped_mining_eq():
	if Globals.player.sync_equipped_mining_equipment.name != "Right Hand":
		save_equipped_mining_equipment({"equippedMiningEquipment": "Right Hand"})
		Globals.hud._update_equipped_mining_equ_tab()
		#RESET 

func destroy_equipped_helmet():
	if Globals.player.sync_equipped_helmet.name != "Helmet":
		save_equipped_helmet({"equippedHelmet": "Helmet"})
		Globals.hud._update_equipped_helmet_tab()
		#RESET

func destroy_equipped_armor():
	if Globals.player.sync_equipped_armor.name != "":
		save_equipped_armor({"equippedArmor": "Armor"})
		Globals.hud._update_equipped_armor_tab()
		#RESET

func display_damaged_equipment(item, sline):
	if item.name != "Right Hand" or item.name != "Left Hand":
		flash_damaged_equipment_text(sline)

func _damage_to_equipped_item(item):
	item.item_health -= item.integrity_ware_and_tear #APPLY DAMAGE TO THE EQUIPMENT
	if item.item_type == "Weapon":
		if item.item_health <= 0:
			destroy_equipped_weapon()
			display_damaged_equipment(item, "Equipped Weapon damaged!")
		else:
			save_equipped_weapon({"equipWeaponHealth":item.item_health})
	elif item.item_type == "Helmet":
		if item.item_health <= 0:
			destroy_equipped_helmet()
			display_damaged_equipment(item, "Equipped Helmet damaged!")
		else:
			save_equipped_helmet({"equipHelmetHealth":item.item_health})
	elif item.item_type == "Armor":
		if item.item_health <= 0:
			destroy_equipped_armor()
			display_damaged_equipment(item, "Equipped Armor damaged!")
		else:
			save_equipped_armor({"equipArmorHealth":item.item_health})
	elif item.item_type == "Mining Equipment":
		if item.item_health <= 0:
			destroy_equipped_mining_eq()
			display_damaged_equipment(item, "Equipped Mining Equipment damaged!")
		else:
			save_equipped_mining_equipment({"equipMiningHealth":item.item_health})

func fix_equipped_item(item):
	item.item_health = 100
	if item.item_type == "Weapon":
		item.item_health = 100
		
	elif item.item_type == "Mining Equipment":
		item.item_health = 100
		
	elif item.item_type == "Helmet":
		item.item_health = 100
		
	elif item.item_type == "Armor":
		item.item_health = 100

func attack():
	Globals.hud.attack_button.disabled = true
	_attack()

func _attack():
	collision_shape.disabled = true
	_previous_position = position
	z_index = 5
	var tween = create_tween()
	tween.tween_property(self, "position", _target.position, 0.5)
	tween.tween_callback(_melee_attack_on_target.bind(_target.get_path()))

func _melee_attack_on_target(target_path : NodePath):
	_target = get_node(target_path)
	if _target != null:
		if has_node(_target.get_path()):
			# The logic to determine the damage done to the enemy
			#update_attack_animation_parameters(true)
			is_attacking = true
			if is_miss():
				_target.subtract_hp(0)
			else:
				player_sound_fx.stream = swordAttackSound
				player_sound_fx.play()
				randomize()
				var damage = randi_range(sync_equipped_weapon.min_damage, sync_equipped_weapon.max_damage)
				var level_damage = 0.00
				var critical_hit_damage = 0.00
				print("Base damage: " + str(damage))
				level_damage = damage * sync_equipped_weapon.level_multiplier
				if level_damage < 1:
					level_damage = 1
				else:
					level_damage = int(level_damage)
				print("Level damage: " + str(level_damage))
				if is_critical_hit():
					critical_hit_damage = damage * sync_equipped_weapon.critical_hit_multiplier
					if critical_hit_damage < 1:
						critical_hit_damage = 1
					else:
						critical_hit_damage = int(critical_hit_damage)
				print("Critical hit damage: " + str(critical_hit_damage))
				damage = int(damage + critical_hit_damage + level_damage)
				print("Total damage: " + str(damage))
				_target.subtract_hp(damage)
			await(get_tree().create_timer(1).timeout)
			var tween = create_tween()
			tween.tween_property(self, "position", _previous_position, 0.5)
			tween.tween_callback(_melee_attack_finished)
			battle_charge_up_timer.start()
		else:
			end_battle()

func _melee_attack_finished():
	is_attacking = false
	z_index = 0
	collision_shape.disabled = false

func increase_hp_over_time(amount: int, duration: float):
	print("Regenerating HP")
	# Calculate the new target HP value
	var target_hp = min(sync_hit_points + amount, sync_max_hit_points)

	# Start the interpolation
	var tween = create_tween()
	tween.tween_property(self, "sync_hit_points", target_hp, duration)

func _login():
	Globals.hud.show_save_icon()
		
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify({"isLoggedIn": 1})
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	http_login_request.request(url, headers, HTTPClient.METHOD_POST, query)

func logout(token):
	Globals.hud.show_save_icon()
		
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify({"isLoggedIn": 0})
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + token
	]
	http_logout_request.request(url, headers, HTTPClient.METHOD_POST, query)

func _save_hit_points(data_to_send):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_hit_points_request : HTTPRequest = HTTPRequest.new() 
	add_child(http_hit_points_request)
	http_hit_points_request.request_completed.connect(self._on_request_completed.bind(http_hit_points_request))
	
#	http_hit_points_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	http_hit_points_request.request(url, headers, HTTPClient.METHOD_POST, query)

func _save_magic_points(data_to_send):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_hit_points_request : HTTPRequest = HTTPRequest.new() 
	add_child(http_hit_points_request)
	http_hit_points_request.request_completed.connect(self._on_request_completed.bind(http_hit_points_request))
	
# http_hit_points_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	http_hit_points_request.request(url, headers, HTTPClient.METHOD_POST, query)

func _save_trilium(data_to_send):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_trilium_request : HTTPRequest = HTTPRequest.new()
	add_child(http_trilium_request)
	http_trilium_request.request_completed.connect(self._on_request_completed.bind(http_trilium_request))
#	http_trilium_request.connect("request_completed", Callable(self, "_on_request_completed"))
	http_trilium_request.request(url, headers, HTTPClient.METHOD_POST, query)

func _save_experience(data_to_send):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_experience_request : HTTPRequest = HTTPRequest.new() 
	add_child(http_experience_request)
	http_experience_request.request_completed.connect(self._on_request_completed.bind(http_experience_request))	
#	ttp_experience_request.connect("request_completed", Callable(self, "_on_request_completed"))
	http_experience_request.request(url, headers, HTTPClient.METHOD_POST, query)

func save_equipped_weapon(data_to_send):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	print("Saving equipped Weapon.......")
	var http_save_equipped_weapon : HTTPRequest = HTTPRequest.new()
	add_child(http_save_equipped_weapon)
	http_save_equipped_weapon.request_completed.connect(self._on_request_completed.bind(http_save_equipped_weapon))
	http_save_equipped_weapon.request(url, headers, HTTPClient.METHOD_POST, query)

func save_equipped_mining_equipment(data_to_send):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_save_equipped_mining_equipment : HTTPRequest = HTTPRequest.new() 
	add_child(http_save_equipped_mining_equipment)
	http_save_equipped_mining_equipment.request_completed.connect(self._on_request_completed.bind(http_save_equipped_mining_equipment))	
#	http_save_equipped_mining_equipment.connect("request_completed", Callable(self, "_on_request_completed"))
	http_save_equipped_mining_equipment.request(url, headers, HTTPClient.METHOD_POST, query)

func save_equipped_helmet(data_to_send): #NB
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_save_equipped_helmet : HTTPRequest = HTTPRequest.new() 
	add_child(http_save_equipped_helmet)
	http_save_equipped_helmet.request_completed.connect(self._on_request_completed.bind(http_save_equipped_helmet))	
#	http_save_equipped_helmet.connect("request_completed", Callable(self, "_on_request_completed"))
	http_save_equipped_helmet.request(url, headers, HTTPClient.METHOD_POST, query)

func save_equipped_armor(data_to_send): #NB
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_save_equipped_armor : HTTPRequest = HTTPRequest.new() 
	add_child(http_save_equipped_armor)
	http_save_equipped_armor.request_completed.connect(self._on_request_completed.bind(http_save_equipped_armor))
#	http_save_equipped_armor.connect("request_completed", Callable(self, "_on_request_completed"))
	http_save_equipped_armor.request(url, headers, HTTPClient.METHOD_POST, query)

func save_crafting_resource(data_to_send): #NB
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_save_crafting_resource: HTTPRequest = HTTPRequest.new() 
	add_child(http_save_crafting_resource)
	http_save_crafting_resource.request_completed.connect(self._on_request_completed.bind(http_save_crafting_resource))
	
#	http_save_crafting_resource.connect("request_completed", Callable(self, "_on_request_completed")) #NB
	
	http_save_crafting_resource.request(url, headers, HTTPClient.METHOD_POST, query)

func fetch_all_inventory_items():
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/fetchCharacterInventory'
	var query = ""
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	http_fetch_inventory_request.request(url, headers, HTTPClient.METHOD_POST, query)

func save_inventory_item(data_to_send):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/addCharacterInventoryItem'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	print("Sending request: "+query)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_inventory_request : HTTPRequest = HTTPRequest.new() 
	add_child(http_inventory_request)
	http_inventory_request.request_completed.connect(self._on_request_completed.bind(http_inventory_request))		
#	ttp_inventory_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	http_inventory_request.request(url, headers, HTTPClient.METHOD_POST, query)

func save_completed_quest(quest_name):
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/addCompletedQuest'
	# Convert data to json string:
	var query = JSON.stringify({"questName": quest_name})
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_save_completed_quests_request : HTTPRequest = HTTPRequest.new()
	add_child(http_save_completed_quests_request)
	http_save_completed_quests_request.request_completed.connect(self._on_save_completed_quests_request_completed.bind(http_save_completed_quests_request))	
#	http_save_completed_quests_request.connect("request_completed", Callable(self, "_on_save_completed_quests_request_completed"))
	http_save_completed_quests_request.request(url, headers, HTTPClient.METHOD_POST, query)

func _on_save_completed_quests_request_completed(result, response_code, _headers, body, http_request_obj:HTTPRequest):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var quest = json.result
		print(json)
		
		if (json.success):
			sync_completed_quests.append(quest.questName)
	
	Globals.hud.hide_save_icon()
	http_request_obj.queue_free()

func fetch_completed_quests():
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/fetchCompletedQuest'
	# Convert data to json string:
	var query = ""
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	http_fetch_completed_quests_request.request(url, headers, HTTPClient.METHOD_POST, query)

func _on_fetch_completed_quests_request_completed(result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var quests = json.result
		for quest in quests:
			print(quest.questName)
			sync_completed_quests.append(quest.questName)
	
	Globals.hud.hide_save_icon()

func remove_inventory_item(data_to_send):
	Globals.hud.show_save_icon()
	print("removed inventory item:"+JSON.stringify(data_to_send))
	var url = Globals.RPC_SERVER + '/api/removeCharacterInventoryItemById'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_inventory_request : HTTPRequest = HTTPRequest.new() 
	add_child(http_inventory_request)
	http_inventory_request.request_completed.connect(self._on_request_completed.bind(http_inventory_request))			
#	ttp_inventory_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	http_inventory_request.request(url, headers, HTTPClient.METHOD_POST, query)

func _on_fetch_inventory_request_completed(result, response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var items = json.result
#	print("inventory Items: "+ str(items))
	var item_to_add : InventoryItem
	print("Loading inventory from database. . . . . .  . . .  .")
	if response_code == 200:
		for item in items:
#			print("Item : ",item)
			item_to_add = _determine_item_type(item.name,item.rarity)
#			print("ITEM TO ADD: ",item_to_add)
			if item_to_add != null:
#				if item.name.contains("Standard"):
#					var modified_name = item.name.replace("Standard", item.rarity)
#					item_to_add.name = modified_name

#				print("ITEM: ",item_to_add.collection_name)
				item_to_add.item_ID = item.id
				item_to_add.rarity = item.rarity
				item_to_add.quantity = 1 # quantity of all item will be one 
				item_to_add.item_health = item.equipmentHealth
				if item.collectionName == "":
					item_to_add.collection_name = "triliumquest"
				else:
					item_to_add.collection_name = item.collectionName
				sync_inventory.append(item_to_add)
				print("Loaded " + item.name + " with health: " + str(item_to_add.item_health))
	
	Globals.hud.hide_save_icon()

func _on_request_completed(_result, _responseCode, _headers, _body, http_request_obj:HTTPRequest):
	Globals.hud.hide_save_icon()
	print(" Request completed...")
	http_request_obj.queue_free()

func _on_logout_completed(_result, _responseCode, _headers, _body):
	queue_free()

func play_magic_healing_sound_effect():
	if not player_sound_fx.is_playing():
		player_sound_fx.volume_db = Globals.sfx_volume
		player_sound_fx.stream = magic_healing_sound_effect
		player_sound_fx.play()

func play_apple_bite_sound_effect():
	if not player_sound_fx.is_playing():
		player_sound_fx.volume_db = Globals.sfx_volume
		player_sound_fx.stream = apple_bite_sound_effect
		player_sound_fx.play()

func play_ready_sound_effect():
	if not player_sound_fx.is_playing():
		player_sound_fx.volume_db = Globals.sfx_volume
		player_sound_fx.stream = ready_sound_effect
		player_sound_fx.play()

func magic_attack():
	if Globals.player.sync_magic_points>0:
		Globals.hud.attack_button.disabled = true
		_magic_attack()

func _magic_attack():
	collision_shape.disabled = true
	_previous_position = position
	z_index = 5
	var timer = Timer.new()
	timer.connect("timeout",_magic_attack_on_target.bind(_target.get_path()))
	timer.wait_time = 0.5
	timer.one_shot = true
	add_child(timer)
	timer.start()

func _magic_attack_on_target(target_path : NodePath):
	_target = get_node(target_path)
	if _target != null:
		if has_node(_target.get_path()):
			# The logic to determine the damage done to the enemy
			#update_attack_animation_parameters(true)
			is_attacking_w_magic = true
			var final_damage_done : int= 0
			if is_miss():
				_target.subtract_hp(0)
			else:
				randomize()
				var damage = randi_range(sync_equipped_weapon.min_damage, sync_equipped_weapon.max_damage)
				var level_damage = 0.00
				var critical_hit_damage = 0.00
			
				print("Base damage: " + str(damage))
			
				level_damage = damage * sync_equipped_weapon.level_multiplier
			
				if level_damage < 1:
					level_damage = 1
				else:
					level_damage = int(level_damage)
				
				print("Level damage: " + str(level_damage))
			
				if is_critical_hit():
					critical_hit_damage = damage * sync_equipped_weapon.critical_hit_multiplier
				
					if critical_hit_damage < 1:
						critical_hit_damage = 1
					else:
						critical_hit_damage = int(critical_hit_damage)
					
				print("Critical hit damage: " + str(critical_hit_damage))
				
				damage = int(damage + critical_hit_damage + level_damage)
			
				print("Total damage: " + str(damage))
			
				final_damage_done = damage
		
			await(get_tree().create_timer(1).timeout)
#			var tween = create_tween()
#			tween.tween_property(self, "position", _previous_position, 0.5)
#			tween.tween_callback(_magic_attack_finished)
			_magic_attack_animation(target_path)
			var timer = Timer.new()
			timer.connect("timeout",self._magic_attack_finished.bind(_target,final_damage_done))
			timer.wait_time = 0.5
			timer.one_shot = true
			add_child(timer)
			timer.start()
			battle_charge_up_timer.start()
			player_sound_fx.stream = magicAttackSound

			player_sound_fx.play()
		else:
			end_battle()

func _magic_attack_animation(enemy_target_path : NodePath):
	if has_node(enemy_target_path):
		var enemy = get_node(enemy_target_path)
		var magic_cast = MagicCast.instantiate()
		magic_cast.position = position
		magic_cast.target_position = enemy.position
		get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").add_child(magic_cast)

func _magic_attack_finished(enemy_target_path : Node2D,final_damage_done:int):
	print("magic attack finished")
	enemy_target_path.subtract_hp(final_damage_done)
	subtract_mp(1)
	is_attacking_w_magic = false
	z_index = 0
	collision_shape.disabled = false
	is_hit = false

func subtract_mp(mp:int):
	var display_text = "- "+str(mp)+" MP"
		# The text needs to be shown to everyone on the network
	flash_text(display_text)
	
	# The actual deduction needs to be an RPC call as well
	_subtract_mp(mp)
	magic_replenish_timer.start()

func _subtract_mp(mp:int):
	Globals.player.sync_magic_points-=mp
	_save_magic_points({
		"magicPoints": Globals.player.sync_magic_points
	})

func add_mp(magic_point_amount : int):
	var display_text : String
	display_text = "+" + str(magic_point_amount) + " MP"
	# The text needs to be shown to everyone on the network
	flash_text(display_text)
	_add_mp(magic_point_amount)

func _add_mp(magic_point_amount:int):
	if sync_magic_points == sync_max_magic_points:
		return
	elif (sync_magic_points + magic_point_amount > sync_max_magic_points):
		print("setting MP to " + str(sync_max_magic_points))
		sync_magic_points = sync_max_magic_points
	else:
		print("setting MP to " + str(sync_magic_points + magic_point_amount))
		sync_magic_points += magic_point_amount
		_save_magic_points({"magicPoints" : sync_magic_points})

func _on_magic_replenish_timeout():
	print("Magic added by 1")
	if(sync_magic_points<sync_max_magic_points):
		add_mp(1)
	else:
		magic_replenish_timer.stop()


func _save_mining_locked_period(data_to_send):
	Globals.hud.show_save_icon()
	print("saving mining lockdown timer")
	print(data_to_send)
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	var http_save_locked_period : HTTPRequest = HTTPRequest.new() 
	add_child(http_save_locked_period)
	http_save_locked_period.request_completed.connect(self._on_request_completed.bind(http_save_locked_period))
	
#	http_save_locked_period.connect("request_completed", Callable(self, "_on_request_completed"))
	
	http_save_locked_period.request(url, headers, HTTPClient.METHOD_POST, query)
