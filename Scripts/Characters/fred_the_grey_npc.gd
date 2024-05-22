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
	set_idle_down()
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
	if not is_interacting:
		is_interacting = true
		# Hide the info button and tip text
		hide_info_button()
		Globals.hud.hide_tip_text()
		
		# Set the NPC's name in the UI name box
		Globals.hud.set_speaker_name(npc_name)
		Globals.hud.set_speaker_image("res://Images/grey_alien/male/male_grey_still_image_front.png")
		
		if Globals.player.sync_completed_quests.has("Find Glenn"):
			Globals.hud.set_dialog_text("I'm so glad that you managed to find Glenn! I hope you enjoy your time here. If you need any help or have any questions, feel free to ask me.")
			Globals.hud.show_dialog_text()
		else:
			Globals.hud.set_dialog_text("Welcome to Magor, adventurer! I hope you enjoy your time here. If you need any help or have any questions, feel free to ask me. By the way, have you seen Glenn around? I haven't been able to find him lately and I'm getting worried.")
			Globals.hud.show_dialog_text()
		
	else:
		cancel_interaction()


func cancel_interaction():
	Globals.hud.hide_dialog_text()
	is_interacting = false


func process_text(input_text):
	var npc_back_story_base = """
		You are Fred, an NPC in Trilium Quest, a MMORPG. You're a male gray alien, 
		unaware you're an NPC. You know the bag icon and 'i' key open the inventory. 
		Giant Ants in the area spit acid. Nearby, common Trilium crystals can be found, 
		which is the galaxy's currency under the Federation. You're in Wandering Dunes, 
		a small town in Planet Magor's rocky desert. The town's people are map-makers 
		and healers, tracking factions. Your job is to welcome players to Magor. """

	sample_npc_question_prompt = """
		What should I do?
	""".replace("\n", "").replace("\t", "")
	
	if Globals.player.sync_completed_quests.has("Find Glenn"):
		npc_back_story = npc_back_story_base.replace("\n", "").replace("\t", "")
		
		sample_npc_prompt_response = """
			Now that you found Glenn, you should explore the area. You can find basic supplies
			and weapons here.  Be careful out in the desert, there are Giant Ants that sput acid!
		""".replace("\n", "").replace("\t", "")
	else:
		npc_back_story = npc_back_story_base.replace("\n", "").replace("\t", "") + """
			You also mention that you can't find Glenn anywhere and you're worried about him. 
		""".replace("\n", "").replace("\t", "")
		
		sample_npc_prompt_response = """
			If you could help me find Glenn, that would be great. I haven't been able to find him
			and I'm getting worried about him.
		""".replace("\n", "").replace("\t", "")
	
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

