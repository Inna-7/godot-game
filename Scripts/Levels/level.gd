extends TileMap

func create_player(character_scene: String):
	# Instantiate a new player for this client.
	var PlayerScene = load(character_scene)
	var p = PlayerScene.instantiate()
	add_child(p)
