
extends Node

# This is the Amazon AWS service link for the RPC\REST server
const RPC_SERVER = "https://k9xqsxsf3p.us-east-1.awsapprunner.com"

# Global references to the scenes
@onready var hud = get_tree().root.get_node("Game").get_node("HUD")
@onready var world_objects = get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players")
@onready var music_player : AudioStreamPlayer = get_tree().root.get_node("Game").get_node("MusicPlayer")
@onready var magor_atmosphere = get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Camera").get_node("MagorAtmosphere")

# User global variables that we use for starting values
var scene
var user_name := ""
var custom_character_name := ""
var database_player_id := ""
var logged_in := false
var trilium_balance
var error
var hit_points : int
var max_hit_points : int
var magic_points : int
var max_magic_points : int
var experience : int
var level : int
var strength : int
var intelligence : int
var character_sprite_sheet := ""
var character_description := ""
var character_hit_point_bonus : int
var character_magic_point_bonus : int
var character_strength_bonus : int
var character_intelligence_bonus : int
var equipped_weapon : String
var equipped_weapon_health:int
var equipped_armor : String
var equipped_armor_health:int
var equipped_mining_equipment : String
var equipped_mining_equipment_health:int
var equipped_helmet : String
var equipped_helmet_health:int
var crafting_resource: String #NB
var jwt
var character_scene  = ""
var player : PlayerCharacter
var players
var current_scene = ""
var miningLockedTill: float
var scene_wrapper

#SET THE INSTANCE HERE TO EASILY USE IN ALL SCENES
var menu = preload("res://Scenes/Hud/menu.tscn").instantiate()
var active_item_slot
var test_printing: String #FOR TESTING PURPOSES; SHOW ITEM POINTS, PLAYER POSITION, INTERACTION FEEDBACK, ETC. CALLED IN HUD SCRIPT
var potion_count: int = 0
var audio_volume: float = 0.0
var sfx_volume: float = 0.0
var sfx_changed_vol: float = 0.0
var in_item_selection: bool = false #CHECK IF PLAYER IS NOT IN ITEM SUB MENU
var quest:Quest = Quest.new()

#STATES FOR DIALOGUE SYSTEM
var in_dialogue: bool = false
var menu_isOpen := false
var inventory_isOpen := false

const uuid_util = preload('res://Scripts/Utils/uuid.gd')

func check_scene_state():
	scene_wrapper = get_tree().root.get_node("Game").get_node("SceneWrapper")
	if current_scene == "Overworld":
		scene = scene_wrapper.get_node("Overworld")
		if scene == null:
			scene = preload("res://Scenes/Levels/overworld.tscn").instantiate()
			scene_wrapper.add_child(scene)
	elif current_scene == "Dungeon1":
		scene = scene_wrapper.get_node("Dungeon1")
		if scene == null:
			scene = preload("res://Scenes/Levels/dungeon1.tscn").instantiate()
			scene_wrapper.add_child(scene)
	elif current_scene == "Dungeon2":
		scene = scene_wrapper.get_node("Dungeon2")
		if scene == null:
			scene = preload("res://Scenes/Levels/dungeon2.tscn").instantiate()
			scene_wrapper.add_child(scene)
	else:
		scene = scene_wrapper.get_node("Overworld")
	if scene == null:
		scene = preload("res://Scenes/Levels/overworld.tscn").instantiate()
		scene_wrapper.add_child(scene)

func _ready():
	add_child(quest)
