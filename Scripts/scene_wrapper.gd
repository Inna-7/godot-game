extends Node2D

@onready var camera : Camera2D = $Camera
@rpc("any_peer")
func create_player():
	if Globals.current_scene == "":
		Globals.current_scene = "Overworld"
	spawn_player(Globals.character_scene)
	camera.zoom = Vector2(2, 2)
@rpc("any_peer")
func spawn_player(character_scene: String):
	# Instantiate a new player for this client.
	var PlayerScene = load(character_scene)
	var p = PlayerScene.instantiate()
	
	Globals.world_objects.add_child(p)
	Globals.player = p
