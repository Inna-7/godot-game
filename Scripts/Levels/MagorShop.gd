extends Area2D

@onready var tilemap : TileMap = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(_body):
	tilemap.set_layer_enabled(5, false)
	Globals.magor_atmosphere.visible = false


func _on_body_exited(_body):
	tilemap.set_layer_enabled(5, true)
	Globals.magor_atmosphere.visible = true
