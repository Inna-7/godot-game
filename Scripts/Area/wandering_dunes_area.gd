extends Area2D

const treasure_hunter_city_background_music = preload("res://Music/DesertBackgroundMusic.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body.in_battle:
		return
	
	Globals.hud.set_local_area('Wandering Dunes')
	get_tree().root.get_node("Game").get_node("MusicPlayer").stream = treasure_hunter_city_background_music
	get_tree().root.get_node("Game").get_node("MusicPlayer").play()
