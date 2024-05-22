extends NpcGpt

@onready var is_interacting = false

var interactable = true


func show_info_button():
	$Info.visible = true


func hide_info_button():
	$Info.visible = false


func _physics_process(_delta):
	pass

func _ready():
	super()
	$AnimationPlayer.play("turquoise")

func interact():
	print("Interact method called.")
	
	if not is_interacting:
		is_interacting = true
		
		# Hide the info button and tip text
		hide_info_button()
		Globals.hud.hide_tip_text()
		
		# Set the NPC's name in the UI name box
		Globals.hud.set_speaker_name(npc_name)
		Globals.hud.set_speaker_image("res://Images/dancer/female/female_dancer_turquoise_still_image.png")
		
		if not Globals.player.sync_completed_quests.has("Find Glenn"):
			Globals.hud.set_dialog_text("Make no mistake, I'm the best entertainment on Magor! Glenn? Yeah, he was awkwardly flirting with me before he went East.")
		else:
			Globals.hud.set_dialog_text("Make no mistake, I'm the best entertainment on Magor!")
		
		Globals.hud.show_dialog_text()
	else:
		cancel_interaction()


func cancel_interaction():
	Globals.hud.hide_dialog_text()
	is_interacting = false
