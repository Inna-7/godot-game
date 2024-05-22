class_name InventoryStaticBody extends StaticBody2D

signal destroyed

@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var item_name : String 
@onready var item_health : int 
@onready var spawn_scene: String
var interactable = true


func play_sound():
	if not audio_player.is_playing():
		audio_player.volume_db = Globals.sfx_volume
		audio_player.play()

func show_info_button():
	$Info.visible = true

func hide_info_button():
	$Info.visible = false

func interact():
	play_sound()
	visible = false
	remove_from_game()

func remove_from_game():
	# Remove from game
	emit_signal("destroyed")
	await get_tree().create_timer(0.2).timeout
	queue_free()

#func remove_from_game():
#	if not Globals.multiplayer.is_server():
#		return
#
#	# Remove from game
#	emit_signal("destroyed")
#	await get_tree().create_timer(0.2).timeout
#	queue_free()

func initialize(health:int,scene:String):
	self.item_health = health
	self.spawn_scene = scene
