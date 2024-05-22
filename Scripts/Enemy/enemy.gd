class_name Enemy extends CharacterBody2D

enum ENEMY_STATE {DORMANT, IN_BATTLE}

@export var sync_position := Vector2.ZERO
@export var sync_state := ENEMY_STATE.DORMANT

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func set_sync_position(pos: Vector2):
	sync_position = pos


func _physics_process(delta):
	if position != sync_position:
		position = sync_position


func _ready():
	state_machine.travel("Idle")
	set_idle_down()


func set_idle_down():
	animation_tree.set("parameters/Idle/blend_position", Vector2.DOWN)


func set_idle_left():
	animation_tree.set("parameters/Idle/blend_position", Vector2.LEFT)


func set_idle_up():
	animation_tree.set("parameters/Idle/blend_position", Vector2.UP)


func set_idle_right():
	animation_tree.set("parameters/Idle/blend_position", Vector2.RIGHT)
