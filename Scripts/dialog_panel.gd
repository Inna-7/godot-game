extends Panel

@onready var player_img_hold: Sprite2D = $player_img_hold
@onready var dialog_animation: AnimationPlayer = $DialogAnimation
@onready var player_animation: AnimationPlayer = $player_img_hold/AnimationPlayer

var dialog_is_open: bool = false

func _ready():
	hide_dialog_panel()

func _process(_delta):
	if dialog_is_open:
		stop_player()
	else:
		free_player()

func handle_dialog():
	pass
	
func stop_player():
	player_animation.play("idle")
	player_img_hold.visible = true

func free_player():
	player_animation.stop()
	player_img_hold.visible = false

func _on_close_pressed():
	hide_dialog_panel()

func show_dialog_panel():
	dialog_animation.play("open_dialog")
	dialog_is_open = true
	self.visible = true

func hide_dialog_panel():
	dialog_animation.play_backwards("open_dialog")
	dialog_is_open = false
	await dialog_animation.animation_finished
	self.visible = false

func set_speaker_name(speaker_name):
	$SpeakerName.text = speaker_name

func set_speaker_image(image_file: String):
	var texture = load(image_file)
	player_img_hold.texture = texture
