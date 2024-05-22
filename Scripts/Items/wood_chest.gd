extends StaticBody2D

signal destroyed

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export var sync_chest_open : bool = false
@export var sync_looted : bool = false

var interactable : bool = true

func _enter_tree():
	call_deferred("set_name", "Wood Treasure Chest")

func _ready():
	animation_player.connect("animation_finished", Callable(self, "_on_animation_player_animation_finished"))

func _process(_delta):
	$AudioStreamPlayer2D.volume_db = Globals.sfx_volume

func show_info_button():
	$Info.visible = true

func hide_info_button():
	$Info.visible = false

func interact():
	if not sync_looted:
		$AudioStreamPlayer2D.play()
		animation_player.play("open_chest")
		sync_chest_open = true
		sync_looted = true

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _on_animation_player_animation_finished(_animation_name):
	# Now that the player has opened the chest and collected the reward,
	# remove this game object from the game
	emit_signal("destroyed")
	queue_free()
