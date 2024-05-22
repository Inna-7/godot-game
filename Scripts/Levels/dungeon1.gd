extends TileMap
class_name Dungeon1

const dungeon_1_music = preload("res://Music/Dungeon1.ogg")

@export var MIN_RANDOM_ENCOUNTER_TIME = 3
@export var MAX_RANDOM_ENCOUNTER_TIME = 9
@export var CHANCE_OF_COMMON_ENEMY_ENCOUNTER : float = 0.9

@onready var wood_treasure_chest_locations : Node2D = $Dungeon1Area/WoodTreasureChestLocations
@onready var common_trilium_crystal_locations : Node2D = $Dungeon1Area/CommonTriliumCrystalLocations
@onready var boss_location : Node2D = $Dungeon1Area/BossLocation
@onready var boss : Node2D = $Dungeon1Area/Boss
@onready var common_trilium_crystals : Node2D = $Dungeon1Area/CommonTriliumCrystals
@onready var wood_treasure_chests : Node2D = $Dungeon1Area/WoodTreasureChests

@onready var Overworld : PackedScene = preload("res://Scenes/Levels/overworld.tscn")


var random_encounter_timer : Timer
var time_for_random_encounter : bool = false
var boss_defeated : bool = false

func _ready():
	# Add the random encounter timer to the screen
	random_encounter_timer = Timer.new()
	add_child(random_encounter_timer)
	random_encounter_timer.connect("timeout", _on_random_encounter_timeout)

func _physics_process(_delta):
	if Globals.player == null:
		return
	
	if time_for_random_encounter and Globals.player.velocity.length() > 0.7 and boss_defeated == false:
		var distance = 60
		var angle = Globals.player.velocity.angle()
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var point_in_front = Globals.player.position + offset
		
		randomize()
		var giant_ant : Node2D
		if (randf() < CHANCE_OF_COMMON_ENEMY_ENCOUNTER):
			giant_ant = ItemSpawner.CommonGiantAnt.instantiate()
			giant_ant.position = point_in_front
			Globals.world_objects.add_child(giant_ant)
			giant_ant.connect("destroyed", _on_enemy_defeated)
		time_for_random_encounter = false


func spawn_boss():
	time_for_random_encounter = false
	random_encounter_timer.stop()
	
	# First clear out all child nodes
	for child in boss.get_children():
		child.queue_free()
	
	var boss_object : Node2D
	
	# Now spawn each of the enemies
	for child in boss_location.get_children():
		boss_object = ItemSpawner.Vuldrax.instantiate()
		boss.call_deferred("add_child", boss_object)
		boss_object.position = child.position
		boss_object.connect("destroyed", _boss_defeated)


func _boss_defeated():
	boss_defeated = true


func spawn_wood_treasure_chests():
	# First clear out all child nodes
	for child in wood_treasure_chests.get_children():
		child.queue_free()
	
	var wood_treasure_chest : Node2D
	
	# Now spawn each of the enemies
	for child in wood_treasure_chest_locations.get_children():
		if not Globals.player.sync_completed_quests.has(child.name):
			wood_treasure_chest = ItemSpawner.WoodTreasureChest.instantiate()
			wood_treasure_chest.position = child.position
			wood_treasure_chests.call_deferred("add_child", wood_treasure_chest)
			wood_treasure_chest.call_deferred("set_name", wood_treasure_chest.name + " " + child.name)

func spawn_common_trilium_crystals():
	# First clear out all child nodes
	for child in common_trilium_crystals.get_children():
		child.queue_free()
	
	var common_trilium_crystal : StaticBody2D
	
	# Now spawn each of the enemies
	for child in common_trilium_crystal_locations.get_children():
		if not Globals.player.sync_completed_quests.has(child.name):
			common_trilium_crystal = ItemSpawner.CommonTriliumCrystal.instantiate()
			common_trilium_crystal.position = child.position
			common_trilium_crystals.call_deferred("add_child", common_trilium_crystal)
			common_trilium_crystal.name = common_trilium_crystal.name + " " + child.name

func _on_body_entered(body):
	if body.in_battle:
		return
	
	Globals.hud.set_local_area('Ant Cave')
	get_tree().root.get_node("Game").get_node("MusicPlayer").stream = dungeon_1_music
	get_tree().root.get_node("Game").get_node("MusicPlayer").play()
	
	randomize()
	random_encounter_timer.wait_time = randf_range(MIN_RANDOM_ENCOUNTER_TIME, MAX_RANDOM_ENCOUNTER_TIME)
	random_encounter_timer.one_shot = true
	random_encounter_timer.start()

func _on_random_encounter_timeout():
	if !boss_defeated:
		time_for_random_encounter = true

func _on_enemy_defeated():
	randomize()
	if boss_defeated == false:
		random_encounter_timer.wait_time = randf_range(MIN_RANDOM_ENCOUNTER_TIME, MAX_RANDOM_ENCOUNTER_TIME)
		random_encounter_timer.one_shot = true
		random_encounter_timer.start()


func player_drop_item(item_name,item_health, item_position):
	Globals.spawner.spawn(item_name,item_health, item_position)

func _on_body_exited(body):
	if body.in_battle:
		return
	
	random_encounter_timer.stop()

func _on_cave_exit_area_body_entered(body):
	call_deferred("_process_cave_exit", body)

func _process_cave_exit(body):
	$".".visible = false
	$".".set_process_input(false)
	var overworld_scene = Overworld.instantiate()
	overworld_scene.visible = true
	overworld_scene.set_process_input(true)
	get_tree().queue_delete(self)
	get_tree().root.get_node("Game").get_node("SceneWrapper").add_child(overworld_scene)
	var magor_area = overworld_scene.get_node("MagorRockyDesertAdventureArea1")
	if magor_area:
		body.global_position = magor_area.get_node("CaveExit").global_position
	Globals.current_scene = "Overworld"
