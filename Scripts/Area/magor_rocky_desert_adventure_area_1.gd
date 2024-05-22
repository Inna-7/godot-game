extends Area2D

const adventure_area_1_background_music = preload("res://Music/adventure.mp3")

@export var MIN_RANDOM_ENCOUNTER_TIME = 5
@export var MAX_RANDOM_ENCOUNTER_TIME = 15
@export var CHANCE_OF_ABUNDANT_ANT_ENCOUNTER : float = 0.7

@onready var collision_shape = $CollisionShape2D

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
	spawn_copper_ore()
	spawn_iron_ore()
	spawn_gold_ore()
	spawn_silver_ore()
	spawn_copper_ore()
	
	# these are test items that spawn near the player origin
#	spawn_test_abundant_helmet()
#	spawn_test_common_helmet()
#	spawn_test_rare_helmet()
#	spawn_test_epic_helmet()
#	spawn_test_legendary_helmet()
#	spawn_test_mythical_helmet()
#	spawn_test_abundant_armor()
#	spawn_test_common_armor()
#	spawn_test_rare_armor()
#	spawn_test_epic_armor()
#	spawn_test_legendary_armor()
#	spawn_test_mythical_armor()
#	spawn_test_health_potion()
#	spawn_test_magic_potion()
#	spawn_test_bread()
#	spawn_test_abundant_trilium_crystal()
#	spawn_test_common_trilium_crystal()
#	spawn_test_abundant_shovel()
#	spawn_test_common_shovel()
#	spawn_test_rare_shovel()
#	spawn_test_epic_shovel()
#	spawn_test_legendary_shovel()
#	spawn_test_mythical_shovel()
#	spawn_test_abundant_giant_ant()
#	spawn_test_thug1("Legendary Sword","Thug 1")
#	spawn_test_thug2("Abundant Dagger","Thug 2")
#	spawn_test_abundant_desert_scrune()
#	spawn_test_abundant_sword()
#	spawn_test_common_sword()
#	spawn_test_rare_sword()
#	spawn_test_epic_sword()
#	spawn_test_legendary_sword()
#	spawn_test_mythical_sword()
#	spawn_test_abundant_dagger()
#	spawn_test_common_dagger()
#	spawn_test_rare_dagger()
#	spawn_test_epic_dagger()
#	spawn_test_legendary_dagger()
#	spawn_test_mythical_dagger()
#	spawn_test_wood_treasure_chest()
#	spawn_test_leather()
#	spawn_test_copper_ore()
#	spawn_test_iron_ore()
#	spawn_test_gold_ore()
#	spawn_test_silver_ore()
#	spawn_test_cloth()

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
		if rng <= CHANCE_OF_ABUNDANT_ANT_ENCOUNTER:
			spawn_abundant_giant_ant(point_in_front)
		time_for_random_encounter = false

func spawn_test_wood_treasure_chest():
	var pos = Vector2(750, 0)
	ItemSpawner.spawn_wood_treasure_chest(pos)

func spawn_test_iron_ore():
	var pos = Vector2(750,50)
	ItemSpawner.spawn_iron_ore(pos,100)

func spawn_test_gold_ore():
	var pos = Vector2(800, 50)
	ItemSpawner.spawn_gold_ore(pos,100)

func spawn_test_copper_ore():
	var pos = Vector2(850, 50)
	ItemSpawner.spawn_copper_ore(pos,100)

func spawn_test_silver_ore():
	var pos = Vector2(900, 50)
	ItemSpawner.spawn_copper_ore(pos,100)

func spawn_test_abundant_helmet():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(750, 100)
	ItemSpawner.spawn_abundant_helmet(pos,100)

func spawn_test_common_helmet():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(800, 100)
	ItemSpawner.spawn_common_helmet(pos,100)

func spawn_test_rare_helmet():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(850, 100)
	ItemSpawner.spawn_rare_helmet(pos,100)

func spawn_test_epic_helmet():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(900, 100)
	ItemSpawner.spawn_epic_helmet(pos,100)

func spawn_test_legendary_helmet():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(950, 100)
	ItemSpawner.spawn_legendary_helmet(pos,100)

func spawn_test_mythical_helmet():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(1000, 100)
	ItemSpawner.spawn_mythical_helmet(pos,100)

func spawn_test_abundant_armor():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(750, 150)
	ItemSpawner.spawn_abundant_armor(pos,100)

func spawn_test_common_armor():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(800, 150)
	ItemSpawner.spawn_common_armor(pos,100)

func spawn_test_rare_armor():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(850, 150)
	ItemSpawner.spawn_rare_armor(pos,100)

func spawn_test_epic_armor():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(850, 150)
	ItemSpawner.spawn_epic_armor(pos,100)

func spawn_test_legendary_armor():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(900, 150)
	ItemSpawner.spawn_legendary_armor(pos,100)

func spawn_test_mythical_armor():
	if not Globals.multiplayer.is_server():
		return
	
	var pos = Vector2(1000, 150)
	ItemSpawner.spawn_mythical_armor(pos,100)

func spawn_test_abundant_shovel():
	var pos = Vector2(750, 200)
	ItemSpawner.spawn_abundant_shovel(pos,100)

func spawn_test_common_shovel():
	var pos = Vector2(800, 200)
	ItemSpawner.spawn_common_shovel(pos,100)

func spawn_test_rare_shovel():
	var pos = Vector2(850, 200)
	ItemSpawner.spawn_rare_shovel(pos,100)

func spawn_test_epic_shovel():
	var pos = Vector2(900, 200)
	ItemSpawner.spawn_epic_shovel(pos,100)

func spawn_test_legendary_shovel():
	var pos = Vector2(950, 200)
	ItemSpawner.spawn_legendary_shovel(pos,100)

func spawn_test_mythical_shovel():
	var pos = Vector2(1000, 200)
	ItemSpawner.spawn_mythical_shovel(pos,100)

func spawn_test_abundant_dagger():
	var pos = Vector2(750, 250)
	ItemSpawner.spawn_abundant_dagger(pos,100)

func spawn_test_common_dagger():
	var pos = Vector2(800, 250)
	ItemSpawner.spawn_common_dagger(pos,100)

func spawn_test_rare_dagger():
	var pos = Vector2(850, 250)
	ItemSpawner.spawn_rare_dagger(pos,100)

func spawn_test_epic_dagger():
	var pos = Vector2(900, 250)
	ItemSpawner.spawn_epic_dagger(pos,100)

func spawn_test_legendary_dagger():
	var pos = Vector2(950, 250)
	ItemSpawner.spawn_legendary_dagger(pos,100)

func spawn_test_mythical_dagger():
	var pos = Vector2(1000, 250)
	ItemSpawner.spawn_mythical_dagger(pos,100)

func spawn_test_abundant_sword():
	var pos = Vector2(750, 300)
	ItemSpawner.spawn_abundant_sword(pos,100)

func spawn_test_common_sword():
	var pos = Vector2(800, 300)
	ItemSpawner.spawn_common_sword(pos,100)

func spawn_test_rare_sword():
	var pos = Vector2(850, 300)
	ItemSpawner.spawn_rare_sword(pos,100)

func spawn_test_epic_sword():
	var pos = Vector2(900, 300)
	ItemSpawner.spawn_epic_sword(pos,100)

func spawn_test_legendary_sword():
	var pos = Vector2(950, 300)
	ItemSpawner.spawn_legendary_sword(pos,100)

func spawn_test_mythical_sword():
	var pos = Vector2(1000, 300)
	ItemSpawner.spawn_mythical_sword(pos,100)

func spawn_test_abundant_trilium_crystal():
	var pos = Vector2(600, 500)
	ItemSpawner.spawn_abundant_trilium_crystal(pos)

func spawn_test_common_trilium_crystal():
	var pos = Vector2(850, 50)
	ItemSpawner.spawn_copper_ore(pos,100)

func spawn_test_bread():
	var pos = Vector2(750, 350)
	ItemSpawner.spawn_bread(pos,100)

func spawn_test_cloth():
	var pos = Vector2(750, 400)
	ItemSpawner.spawn_cloth(pos,100)

func spawn_test_health_potion():
	var pos = Vector2(750, 450)
	ItemSpawner.spawn_health_potion(pos,100)

func spawn_test_magic_potion():
	var pos = Vector2(800, 450)
	ItemSpawner.spawn_magic_potion(pos,100)

func spawn_test_leather():
	var pos = Vector2(700, 500)
	ItemSpawner.spawn_leather(pos,100)

func spawn_test_abundant_giant_ant():
	var pos = Vector2(0, -485)
	ItemSpawner.spawn_abundant_giant_ant(pos)

func spawn_test_abundant_desert_scrune():
	var pos = Vector2(0, -685)
	ItemSpawner.spawn_abundant_desert_scrune(pos)

func spawn_test_thug1(thug_name,weapon_name):
	var pos = Vector2(100,-590)
	ItemSpawner.spawn_thug1(thug_name,weapon_name,pos)

func spawn_test_thug2(weapon_name,thug_name):
	var pos = Vector2(100,-490)
	ItemSpawner.spawn_thug1(thug_name,weapon_name,pos)

func spawn_health_potion():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_health_potion(pos,100)

func spawn_magic_potion():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_magic_potion(pos,100)

func spawn_copper_ore():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_copper_ore(pos,100)

func spawn_iron_ore():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_iron_ore(pos,100)

func spawn_gold_ore():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_gold_ore(pos,100)

func spawn_silver_ore():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_silver_ore(pos,100)

func spawn_wood_treasure_chest():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_wood_treasure_chest(pos)

func spawn_abundant_trilium_crystal():
	var pos = ItemSpawner.get_random_point_in_area(collision_shape)
	ItemSpawner.spawn_abundant_trilium_crystal(pos)

func spawn_abundant_giant_ant(pos):
	var abundant_giant_ant = ItemSpawner.AbundantGiantAnt.instantiate()
	
	abundant_giant_ant.position = pos
	Globals.world_objects.add_child(abundant_giant_ant)
	print("Abundant Giant Ant spawned at a random location " + str(abundant_giant_ant.position))
	abundant_giant_ant.connect("destroyed", _on_enemy_defeated)

func _on_health_potions_spawn_timer_timeout():
	spawn_health_potion()

func _on_magic_potions_spawn_timer_timeout():
	spawn_magic_potion()

func _on_wood_chest_spawn_timer_timeout():
	spawn_wood_treasure_chest()

func _on_abundant_trilium_crystal_spawn_timer_timeout():
	spawn_abundant_trilium_crystal()

func _on_copper_ore_spawn_timer_timeout():
	spawn_copper_ore()

func _on_iron_ore_spawn_timer_timeout():
	spawn_iron_ore()

func _on_gold_ore_spawn_timer_timeout():
	spawn_gold_ore()

func _on_silver_ore_spawn_timer_timeout():
	spawn_silver_ore()

func _on_random_encounter_timeout():
	time_for_random_encounter = true

func _on_body_entered(body):
	if body.in_battle:
		return
	
	Globals.hud.set_local_area('Ant Wastes')
	get_tree().root.get_node("Game").get_node("MusicPlayer").stream = adventure_area_1_background_music
	get_tree().root.get_node("Game").get_node("MusicPlayer").play()
	
	randomize()
	random_encounter_timer.wait_time = randf_range(MIN_RANDOM_ENCOUNTER_TIME, MAX_RANDOM_ENCOUNTER_TIME)
	random_encounter_timer.one_shot = true
	random_encounter_timer.start()

func _on_enemy_defeated():
	randomize()
	random_encounter_timer.wait_time = randf_range(MIN_RANDOM_ENCOUNTER_TIME, MAX_RANDOM_ENCOUNTER_TIME)
	random_encounter_timer.one_shot = true
	random_encounter_timer.start()

func _on_body_exited(body):
	if body.in_battle:
		return
	random_encounter_timer.stop()
