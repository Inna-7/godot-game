extends Sprite2D

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	move()


func move():
	randomize()
	
	# Load the image as a texture
	#var image_texture = ImageTexture.new()
	#var image = Image.new()
	#image.load("res://Images/assets_and_levels/darkclouds1.png") 
	#image_texture.create_from_image(image)
	
	#self.visible = true
	
	var end_position = self.position + Vector2(1000, 0)
	var duration = randf_range(3.0, 10.0)
	tween = create_tween()
	tween.tween_property(self, "position", end_position, duration)

	# Set up a callback to free the sprite after the tween completes
	tween.tween_callback(_on_tween_completed)


func _on_tween_completed():
	self.position = self.position - Vector2(1000, 0)
	#self.visible = false
	move()
