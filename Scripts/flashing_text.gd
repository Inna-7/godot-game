extends Node2D

var animation_player : AnimationPlayer
@onready var label_1 : RichTextLabel = $RichTextLabel
@onready var label_2 : RichTextLabel = $RichTextLabel2

func _ready():
	animation_player = $AnimationPlayer
	animation_player.connect("animation_finished", _on_animation_player_finished)


func set_text(flashing_text):
	label_1.text = flashing_text
	label_2.text = flashing_text


func play_animation():
	animation_player.play("scale_up")


func _on_animation_player_finished(_animation_name):
	queue_free()
