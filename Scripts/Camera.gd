extends Camera2D
class_name Camera

enum MODES  {TARGET}

@export var target : Node = null
@export var mode : MODES = MODES.TARGET
@export var MAX_DISTANCE : float = 640
@export var SMOOTH_SPEED : float = 15

var target_position := Vector2.INF
var fallback_target : Node = null

func _ready():
	fallback_target = target

func _process(delta):
	match(mode):
		MODES.TARGET:
			if target:
				target_position = target.position
	
	if target_position != Vector2.INF:
		position = lerp(position, target_position, SMOOTH_SPEED * delta)

func change_mode(new_mode: MODES) -> void:
	mode = new_mode
