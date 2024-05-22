extends Node2D

signal destroyed

@export var MIN_REWARD : float = 0.01
@export var MAX_REWARD : float = 0.2

var interactable = true

func show_info_button():
	$Info.visible = true

func hide_info_button():
	$Info.visible = false

func destruction_sequence():
	emit_signal("destroyed")
	$AudioStreamPlayer2D.play()

func _enter_tree():
	name = "Abundant Trilium Crystal"

func _process(_delta):
	$AudioStreamPlayer2D.volume_db = Globals.sfx_volume

func _on_audio_stream_player_2d_finished():
	destroy_crystal()

func destroy_crystal():
	queue_free()
