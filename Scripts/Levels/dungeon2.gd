extends TileMap
class_name Dungeon2

const dungeon_2_music = preload("res://Music/Dungeon2.wav")

@export var MIN_RANDOM_ENCOUNTER_TIME = 3
@export var MAX_RANDOM_ENCOUNTER_TIME = 9
@export var CHANCE_OF_COMMON_ENEMY_ENCOUNTER : float = 0.9

@onready var wood_treasure_chest_locations : Node2D = $Dungeon2Area/WoodTreasureChestLocations
@onready var common_trilium_crystal_locations : Node2D = $Dungeon2Area/CommonTriliumCrystalLocations
@onready var abundant_trilium_crystal_locations : Node2D = $Dungeon2Area/AbundantTriliumCrystalLocations
@onready var boss_location : Node2D = $Dungeon2Area/BossLocation
@onready var boss : Node2D = $Dungeon2Area/Boss
@onready var miniboss_location : Node2D = $Dungeon2Area/MiniBossLocation
@onready var miniboss : Node2D = $Dungeon2Area/MiniBoss
@onready var common_trilium_crystals : Node2D = $Dungeon2Area/CommonTriliumCrystals
@onready var abundant_trilium_crystals : Node2D = $Dungeon2Area/AbundantTriliumCrystals
@onready var wood_treasure_chests : Node2D = $Dungeon2Area/WoodTreasureChests

@onready var Overworld : PackedScene = preload("res://Scenes/Levels/overworld.tscn")


var random_encounter_timer : Timer
var time_for_random_encounter : bool = false
var boss_defeated : bool = false
var miniboss_defeated : bool = false


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
		var desert_scrune : Node2D
		if (randf() < CHANCE_OF_COMMON_ENEMY_ENCOUNTER):
			desert_scrune = ItemSpawner.CommonDesertScrune.instantiate()
			desert_scrune.position = point_in_front
			Globals.world_objects.add_child(desert_scrune)
			desert_scrune.connect("destroyed", _on_enemy_defeated)
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
		boss_object = ItemSpawner.Xyloarachs.instantiate()
		boss.call_deferred("add_child", boss_object)
		boss_object.position = child.position
		boss_object.connect("destroyed", _boss_defeated)

func spawn_miniboss():
	# First clear out all child nodes
	for child in miniboss.get_children():
		child.queue_free()
	
	var miniboss_object : Node2D
	
	# Now spawn each of the enemies
	for child in miniboss_location.get_children():
		miniboss_object = ItemSpawner.Vuldrax.instantiate()
		miniboss.call_deferred("add_child", miniboss_object)
		miniboss_object.position = child.position
		miniboss_object.connect("destroyed", _miniboss_defeated)

func _boss_defeated():
	boss_defeated = true

func _miniboss_defeated():
	miniboss_defeated = true

func spawn_wood_treasure_chests():
	# First clear out all child nodes
	for child in wood_treasure_chests.get_children():
		child.queue_free()
	
	var wood_treasure_chest : Node2D
	
	# Now spawn each of the enemies
	for child in wood_treasure_chest_locations.get_children():
		if not Globals.player.sync_completed_quests.has(child.name):
			wood_treasure_chest = ItemSpawner.AbundantTreasureChest.instantiate()
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

func spawn_abundant_trilium_crystals():
	# First clear out all child nodes
	for child in abundant_trilium_crystals.get_children():
		child.queue_free()
	
	var abundant_trilium_crystal : StaticBody2D
	
	# Now spawn each of the enemies
	for child in abundant_trilium_crystal_locations.get_children():
		if not Globals.player.sync_completed_quests.has(child.name):
			abundant_trilium_crystal = ItemSpawner.AbundantTriliumCrystal.instantiate()
			abundant_trilium_crystal.position = child.position
			abundant_trilium_crystals.call_deferred("add_child", abundant_trilium_crystal)
			abundant_trilium_crystal.call_deferred("set_name", abundant_trilium_crystal.name + " " + child.name)
			#abundant_trilium_crystal.name = abundant_trilium_crystal.name + " " + child.name

func _on_body_entered(body):
	if body.in_battle:
		return
	
	Globals.hud.set_local_area('Scrune Cave')
	get_tree().root.get_node("Game").get_node("MusicPlayer").stream = dungeon_2_music
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
	var magor_area = overworld_scene.get_node("MagorRockyDesertAdventureArea2")
	if magor_area:
		body.global_position = magor_area.get_node("CaveExit").global_position
	Globals.current_scene = "Overworld"
