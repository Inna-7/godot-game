extends Node2D

@onready var door_static_body : StaticBody2D = $Door
@onready var door_sprite : Sprite2D = $Door/Door
@onready var door_collision_shape : CollisionShape2D = $Door/CollisionShape2D
@onready var door_sound_effect : AudioStreamPlayer2D = $AudioStreamPlayer2D

var _locked : bool = false


func open_door():
	if _locked:
		return
	
	call_deferred("_deferred_open_door")

func _deferred_open_door():
	door_sprite.visible = false
	door_collision_shape.disabled = true
	door_static_body.collision_layer = 0
	door_static_body.collision_mask = 0
	door_sound_effect.play()

func close_door():
	call_deferred("_deferred_close_door")

func _deferred_close_door():
	door_sprite.visible = true
	door_collision_shape.disabled = false
	door_static_body.collision_layer = 1
	door_static_body.collision_mask = 1
	door_sound_effect.play()

func lock_door():
	_locked = true

func unlock_door():
	_locked = false

func _on_area_2d_body_entered(_body):
	open_door()

func _on_area_2d_body_exited(_body):
	close_door()
