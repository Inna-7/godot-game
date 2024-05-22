extends TileMap
class_name Overworld

@onready var Dungeon1 : PackedScene = preload("res://Scenes/Levels/dungeon1.tscn")
@onready var Dungeon2 : PackedScene = preload("res://Scenes/Levels/dungeon2.tscn")


func player_drop_item(item_name,item_health, item_position):
	Globals.spawner.spawn(item_name,item_health, item_position)

func _on_dungeon1_entrance_area_body_entered(body):
	call_deferred("_enter_cave", body, "Dungeon1")

func _on_dungeon2_entrance_area_body_entered(body):
	call_deferred("_enter_cave", body, "Dungeon2")

func _enter_cave(body,dungeon):
	$".".visible = false
	$".".set_process_input(false)
	var dungeon_scene
	if dungeon == "Dungeon1":
		dungeon_scene = Dungeon1.instantiate()
		Globals.current_scene = "Dungeon1"
	elif dungeon == "Dungeon2":
		dungeon_scene = Dungeon2.instantiate()
		Globals.current_scene = "Dungeon2"
	dungeon_scene.visible = true
	dungeon_scene.set_process_input(true)
	get_tree().queue_delete(self)
	get_tree().root.get_node("Game").get_node("SceneWrapper").add_child(dungeon_scene)
	var dungeon_area = dungeon_scene.get_node(dungeon+"Area")
	var cave_starting_location = dungeon_area.get_node("CaveStartingLocation")
	if cave_starting_location:
		body.global_position = cave_starting_location.global_position
	dungeon_scene.spawn_boss()
	dungeon_scene.spawn_wood_treasure_chests()
	dungeon_scene.spawn_common_trilium_crystals()
	if dungeon == "Dungeon2":
		dungeon_scene.spawn_miniboss()
		dungeon_scene.spawn_abundant_trilium_crystals()
