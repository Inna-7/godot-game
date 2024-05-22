extends CharacterBody2D

@onready var is_interacting = false

var interactable = true

@onready var animation_player = $AnimationPlayer

var dialouge_intro = "Hey there! My name is Glenn Sundout. I'm a bit of a wanderer, always on the lookout for the next big score.Interact with me again to give any information or items you have got with you right now. And let me tell you, there's no bigger score than the Trilium Crystals found at Mount Bloodcraven. Have you heard of it?"

var diaglouge_got_items = "Hmmm.. I read about the introductory note you gave me. So you are sent to Magor with this introductory note and your family heriloom,'The triactor socket'. I will teach you to switch the Triactor cartridge."

var dialouge_last = "Congratulations on successfully switchinbg triactor and replacing the Statis cartridge with Magori Lungs. Go to a local leader, he will help you find a job for you..."

func show_info_button():
	$Info.visible = true


func hide_info_button():
	$Info.visible = false


func _physics_process(_delta):
	pass


func _ready():
	pass
	

func set_idle_down():
	pass


func set_idle_left():
	pass


func set_idle_up():
	pass


func set_idle_right():
	pass


func interact():
	if not is_interacting:
		is_interacting = true
		
		# Hide the info button and tip text
		hide_info_button()
		Globals.hud.hide_tip_text()
		
		# Set the NPC's name in the UI name box
		Globals.hud.set_speaker_name("Glenn Sundout")
		Globals.hud.set_speaker_image("res://Images/human/male/male_human_still_image_front.png")
		
		if Globals.quest.complete("find_glenn"):
			Globals.hud.set_dialog_text(dialouge_intro)
			Globals.hud.show_dialog_text()
			return
		
		#START TUTORIAL QUEST 0:
		if Globals.quest.complete("give_intro_note"):
			Globals.hud.set_dialog_text(diaglouge_got_items)
			Globals.hud.show_dialog_text()
		else:
			Globals.hud.set_dialog_text(dialouge_last)
			Globals.hud.show_dialog_text()
			Globals.quest.complete("switch_triactor")
	else:
		cancel_interaction()


func cancel_interaction():
	Globals.hud.hide_dialog_text()
	is_interacting = false
