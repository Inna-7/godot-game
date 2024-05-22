extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	if body.in_battle:
		return
	
	if Globals.player != null:
		return
	
	Globals.hud.set_planet('Magor')
	
	if Globals.player == null:
		print("A reference to the player has not been found")