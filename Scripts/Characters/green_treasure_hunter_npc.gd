extends NpcGpt

@onready var is_interacting = false

var interactable = true

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")


func show_info_button():
	$Info.visible = true


func hide_info_button():
	$Info.visible = false


func _physics_process(_delta):
	pass


func _ready():
	super()
	state_machine.travel("Idle")
	set_idle_left()
	connect("messages_summarized", Callable(self, "_on_messages_summarized"))
	connect("response_received", Callable(self, "_on_response_received"))
	

func set_idle_down():
	animation_tree.set("parameters/Idle/blend_position", Vector2.DOWN)


func set_idle_left():
	animation_tree.set("parameters/Idle/blend_position", Vector2.LEFT)


func set_idle_up():
	animation_tree.set("parameters/Idle/blend_position", Vector2.UP)


func set_idle_right():
	animation_tree.set("parameters/Idle/blend_position", Vector2.RIGHT)


func interact():
	print("Interact method called.")
	
	if not is_interacting:
		is_interacting = true
		
		# Hide the info button and tip text
		hide_info_button()
		Globals.hud.hide_tip_text()
		
		# Set the NPC's name in the UI name box
		Globals.hud.set_speaker_name(npc_name)
		Globals.hud.set_speaker_image("res://Images/little_green_person/male/male_little_green_person_still_image_front.png")
		
		if not Globals.player.sync_completed_quests.has("Find Glenn"):
			Globals.hud.set_dialog_text("This small encampment is mostly treasure hunters. The best treasure is found on Magor. Oh, Glenn?  I think I saw him heading East into the Adventuring Area.")
		else:
			Globals.hud.set_dialog_text("This small encampment is mostly treasure hunters. The best treasure is found on Magor.")
		
		Globals.hud.show_dialog_text()
	else:
		cancel_interaction()


func cancel_interaction():
	Globals.hud.hide_dialog_text()
	is_interacting = false


func process_text(input_text):
	call_GPT(input_text.replace("\n", "").replace("\t", ""))


func _on_messages_summarized(summary):
	if is_interacting:
		Globals.hud.set_dialog_text(summary)
		Globals.hud.show_dialog_text()
		Globals.hud.loading_complete()


func _on_response_received(response):
	if is_interacting:
		Globals.hud.set_dialog_text(response)
		Globals.hud.show_dialog_text()
		Globals.hud.loading_complete()
