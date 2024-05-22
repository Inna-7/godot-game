extends Area2D

const adventure_area_3_background_music = preload("res://Music/Level_3_Adv_Area.ogg")

@export var MIN_RANDOM_ENCOUNTER_TIME = 5
@export var MAX_RANDOM_ENCOUNTER_TIME = 15
@export var CHANCE_OF_COMMON_ANT_ENCOUNTER : float = 0.4
@export var CHANCE_OF_ABUNDANT_SCRUNE_ENCOUNTER : float = 0.2

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var random_encounter_timer : Timer
var time_for_random_encounter : bool = false

func _ready():
	# Add the random encounter timer to the screen
	random_encounter_timer = Timer.new()
	add_child(random_encounter_timer)
	random_encounter_timer.connect("timeout", _on_random_encounter_timeout)
	
	# spawn one of each in a random location
	spawn_wood_treasure_chest()
	spawn_health_potion()
	spawn_magic_potion()

func _on_body_entered(body):
	if body.in_battle:
		return
		
	Globals.hud.set_local_area('Adv Area 3')
	get_tree().root.get_node("Game").get_node("MusicPlayer").stream = adventure_area_3_background_music
	get_tree().root.get_node("Game").get_node("MusicPlayer").play()
	
	randomize()
	random_encounter_timer.wait_time = randf_range(MIN_RANDOM_ENCOUNTER_TIME, MAX_RANDOM_ENCOUNTER_TIME)
	random_encounter_timer.one_shot = true
	random_encounter_timer.start()

func _physics_process(_delta):
	if Globals.player == null:
		return
	
	if time_for_random_encounter and Globals.player.velocity.length() > 0.7:
		var distance = 60
		var angle = Globals.player.velocity.angle()
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var point_in_front = Globals.player.position + offset
		
		randomize()
		var rng = randf()
		if rng <= CHANCE_OF_COMMON_ANT_ENCOUNTER:
			spawn_common_giant_ant(point_in_front)
		elif rng >= CHANCE_OF_COMMON_ANT_ENCOUNTER + CHANCE_OF_ABUNDANT_SCRUNE_ENCOUNTER:
			spawn_abundant_desert_scrune(point_in_front)
		else:
			spawn_abundant_giant_ant(point_in_front)
		time_for_random_encounter = false

func spawn_common_giant_ant(pos):
	var common_giant_ant = ItemSpawner.CommonGiantAnt.instantiate()
	
	common_giant_ant.position = pos
	Globals.world_objects.add_child(common_giant_ant)
	print("Common Giant Ant spawned at location " + str(common_giant_ant.position))
	common_giant_ant.connect("destroyed", _on_enemy_defeated)

func spawn_abundant_giant_ant(pos):
	var abundant_giant_ant = ItemSpawner.AbundantGiantAnt.instantiate()
	
	abundant_giant_ant.position = pos
	Globals.world_objects.add_child(abundant_giant_ant)
	print("Abundant Giant Ant spawned at location " + str(abundant_giant_ant.position))
	abundant_giant_ant.connect("destroyed", _on_enemy_defeated)

func spawn_abundant_desert_scrune(pos):
	var abundant_desert_scrune = ItemSpawner.AbundantDesertScrune.instantiate()
	
	abundant_desert_scrune.position = pos
	Globals.world_objects.add_child(abundant_desert_scrune)
	print("Abundant Desert Scrune spawned at a random location " + str(abundant_desert_scrune.position))
	abundant_desert_scrune.connect("destroyed",_on_enemy_defeated)

func spawn_health_potion():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_health_potion(pos,100)

func spawn_magic_potion():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_magic_potion(pos,100)

func spawn_wood_treasure_chest():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_wood_treasure_chest(pos)

func spawn_abundant_trilium_crystal():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_abundant_trilium_crystal(pos)

func _on_random_encounter_timeout():
	time_for_random_encounter = true

func _on_health_potions_spawn_timer_timeout():
	spawn_health_potion()

func _on_magic_potions_spawn_timer_timeout():
	spawn_magic_potion()

func _on_wood_chest_spawn_timer_timeout():
	spawn_wood_treasure_chest()

func _on_abundant_trilium_crystal_spawn_timer_timeout():
	spawn_abundant_trilium_crystal()

func _on_enemy_defeated():
	randomize()
	random_encounter_timer.wait_time = randf_range(MIN_RANDOM_ENCOUNTER_TIME, MAX_RANDOM_ENCOUNTER_TIME)
	random_encounter_timer.one_shot = true
	random_encounter_timer.start()

func _on_body_exited(body):
	if body.in_battle:
		return
	
	random_encounter_timer.stop()
