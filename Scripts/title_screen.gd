extends Node2D

var intro_music = preload("res://Music/ObservingTheStar.ogg")
var user_name = ""
var character_select_index = 0
var selectable_characters = []
var overworld = preload("res://Scenes/Levels/overworld.tscn").instantiate()

func _ready():
	# Play the game title screen music
	get_tree().root.get_node("Game").get_node("MusicPlayer").stream = intro_music
	get_tree().root.get_node("Game").get_node("MusicPlayer").play()
	
	# Configure the array of playable characters for character selection screen
	selectable_characters.append({"name": "Male Reptiloid",
	"description": "Most Reptiloids core worlds are hot and harsh resulting in the reptiloids being a physically tough species. Strength Bonus +5%, HP Bonus +3%",
	"selectImage": "res://Images/reptilian/reptilian_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/male_reptilian.tscn",
	"hitPointsBonus": 3,
	"magicPointsBonus": 0,
	"strengthBonus": 5,
	"intelligenceBonus": 0})
	
	selectable_characters.append({"name": "Female Reptiloid",
	"description": "Most Reptiloids core worlds are hot and harsh resulting in the reptiloids being a physically tough species. Strength Bonus +5%, HP Bonus +3%",
	"selectImage": "res://Images/reptilian/reptilian_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/female_reptilian.tscn",
	"hitPointsBonus": 3,
	"magicPointsBonus": 0,
	"strengthBonus": 5,
	"intelligenceBonus": 0})
	
	selectable_characters.append({"name": "Female Grey",
	"description": "Greys are known for using advanced technologies and diplomacy. Intelligence Bonus +5%, MP Bonus +3%",
	"selectImage": "res://Images/grey_alien/female/female_grey_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/female_grey_alien.tscn",
	"hitPointsBonus": 0,
	"magicPointsBonus": 3,
	"strengthBonus": 0,
	"intelligenceBonus": 5})
	
	selectable_characters.append({"name": "Male Grey",
	"description": "Greys are known for using advanced technologies and diplomacy. Intelligence Bonus +5%, MP Bonus +3%",
	"selectImage": "res://Images/grey_alien/male/male_grey_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/male_grey_alien.tscn",
	"hitPointsBonus": 0,
	"magicPointsBonus": 3,
	"strengthBonus": 0,
	"intelligenceBonus": 5})
	
	selectable_characters.append({"name": "Female Little Green Person",
	"description": "The Green People are known for being in tune with nature. Strength Bonus: +3% Intelligence Bonus +2%, MP Bonus +2%",
	"selectImage": "res://Images/little_green_person/female/female_little_green_person_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/female_little_green_person.tscn",
	"hitPointsBonus": 0,
	"magicPointsBonus": 2,
	"strengthBonus": 3,
	"intelligenceBonus": 2})
	
	selectable_characters.append({"name": "Male Little Green Person",
	"description": "The Green People are known for being in tune with nature. Strength Bonus: +3% Intelligence Bonus +2%, MP Bonus +2%",
	"selectImage": "res://Images/little_green_person/male/male_little_green_person_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/male_little_green_person.tscn",
	"hitPointsBonus": 0,
	"magicPointsBonus": 2,
	"strengthBonus": 3,
	"intelligenceBonus": 2})
	
	selectable_characters.append({"name": "Female Human",
	"description": "Humans are from a temperate world and have average stats. Strength Bonus: +2% Intelligence Bonus +2%, HP Bonus: +2%, MP Bonus +2%",
	"selectImage": "res://Images/human/female/female_human_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/female_human.tscn",
	"hitPointsBonus": 2,
	"magicPointsBonus": 2,
	"strengthBonus": 2,
	"intelligenceBonus": 2})
	
	selectable_characters.append({"name": "Male Human",
	"description": "Humans are from a temperate world and have average stats. Strength Bonus: +2% Intelligence Bonus +2%, HP Bonus: +2%, MP Bonus +2%",
	"selectImage": "res://Images/human/male/male_human_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/male_human.tscn",
	"hitPointsBonus": 2,
	"magicPointsBonus": 2,
	"strengthBonus": 2,
	"intelligenceBonus": 2})
	
	selectable_characters.append({"name": "Female Nordic",
	"description": "Nordics resemble humans, but are slightly tougher and less good with magic. Strength Bonus: +3% Intelligence Bonus +1%, HP Bonus: +3%, MP Bonus +1%",
	"selectImage": "res://Images/nordic/female/female_nordic_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/female_nordic.tscn",
	"hitPointsBonus": 3,
	"magicPointsBonus": 1,
	"strengthBonus": 3,
	"intelligenceBonus": 1})
	
	selectable_characters.append({"name": "Male Nordic",
	"description": "Nordics resemble humans, but are slightly tougher and less good with magic. Strength Bonus: +3% Intelligence Bonus +1%, HP Bonus: +3%, MP Bonus +1%",
	"selectImage": "res://Images/nordic/male/male_nordic_still_image_front.png",
	"spriteScene": "res://Scenes/Characters/male_nordic.tscn",
	"hitPointsBonus": 3,
	"magicPointsBonus": 1,
	"strengthBonus": 3,
	"intelligenceBonus": 1})
	
	_set_selectable_character()

@rpc("call_local")
func start_game():
	get_tree().root.get_node("Game").get_node("MusicPlayer").stop()
	get_tree().root.get_node("Game").get_node("HUD").visible = true
	get_tree().root.get_node("Game").get_node("TitleScreen").visible = false
	get_tree().root.get_node("Game").get_node("SceneWrapper").visible = true
	get_tree().root.get_node("Game").get_node("SceneWrapper").add_child(overworld)
	get_tree().root.get_node("Game").get_node("SceneWrapper").create_player()
	get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Camera").visible = true
	var player = str(Globals.player.name)
	get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Camera").target = get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").get_node(player)

func _set_selectable_character():
	$CharacterSelect/Sprite2D.texture = load(selectable_characters[character_select_index]["selectImage"])
	$CharacterSelect/LabelCharacterName.text = selectable_characters[character_select_index]["name"]
	$CharacterSelect/Label2CharacterDesc.text = selectable_characters[character_select_index]["description"]
	$CharacterSelect/ButtonSelect.text = "Select " + selectable_characters[character_select_index]["name"]

func _on_login_pressed():
	$LoginPanel.visible = true

func _on_register_pressed():
	$RegisterPanel.visible = true

func _on_register_close_pressed():
	$RegisterPanel.visible = false

func _on_save_registration_pressed():
	user_name = $RegisterPanel/UserNameText.text.strip_edges()
	var email = $RegisterPanel/EmailText.text.strip_edges()
	var password = $RegisterPanel/PasswordText.text.strip_edges()
	var password_confirm = $RegisterPanel/PasswordConfText.text.strip_edges()
	
	# Check if anything is blank
	if user_name == "" or email == "" or password == "" or password_confirm == "":
		$RegisterPanel/ErrorMessage.text = "All fields are required"
		return
	
	if password != password_confirm:
		$RegisterPanel/ErrorMessage.text = "Passwords do not match"
		return
	
	_make_signup_request({ "username": user_name, "password": password, "email": email})

func _on_login_close_pressed():
	$LoginPanel.visible = false

func _make_signup_request(data_to_send):
	var url = Globals.RPC_SERVER + '/api/signup'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$HTTPSignupRequest.request(url, headers, HTTPClient.METHOD_POST, query)

func _save_player_character(data_to_send):
	var url = Globals.RPC_SERVER + '/api/saveCharacter'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
	$HTTPSavePlayerRequest.request(url, headers, HTTPClient.METHOD_POST, query)

func _make_login_request(data_to_send):
	var url = Globals.RPC_SERVER + '/api/login'
	# Convert data to json string:
	var query = JSON.stringify(data_to_send)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$HTTPLoginRequest.request(url, headers, HTTPClient.METHOD_POST, query)

func _input(event):
	if $LoginPanel/PasswordText.has_focus() and event.is_action_pressed("ui_accept"):
		user_name = $LoginPanel/UserNameText.text.strip_edges()
		var password = $LoginPanel/PasswordText.text.strip_edges()
		_make_login_request({ "usernameOrEmail": user_name, "password": password})

func _on_user_login_pressed():
	user_name = $LoginPanel/UserNameText.text.strip_edges()
	var password = $LoginPanel/PasswordText.text.strip_edges()
	_make_login_request({ "usernameOrEmail": user_name, "password": password})

func _on_http_login_request_request_completed(result, response_code, _headers, body):	
	var json = JSON.parse_string(body.get_string_from_utf8())
	var json_token = json.result
	
	if response_code == 200:
		Globals.user_name = user_name
		var jwt_parts = json_token.split(".")
		
		#print(json_token)
		
		# padding check and correct
		for index in range(len(jwt_parts)):
			match (jwt_parts[index].length() % 4):
				2: jwt_parts[index] += "=="
				3: jwt_parts[index] += "="
		
		var _header_json = JSON.parse_string(Marshalls.base64_to_utf8(jwt_parts[0]))
		var payload_json = JSON.parse_string(Marshalls.base64_to_utf8(jwt_parts[1]))
		
		print(payload_json)
		
		# Set the Global Variables
		Globals.jwt = json_token
		Globals.logged_in = true
		Globals.trilium_balance =  float(payload_json["triliumBalance"])
		Globals.database_player_id = str(payload_json["id"])
		Globals.hit_points = int(payload_json["hitPoints"])
#		Globals.max_hit_points = int(payload_json["maxHitPoints"])
#		Globals.max_magic_points = int(payload_json["maxMagicPoints"])
		Globals.magic_points = int(payload_json["magicPoints"])
		Globals.experience = int(payload_json["experience"])
		Globals.level = int(payload_json["level"])
		Globals.strength = int(payload_json["strength"])
		Globals.intelligence = int(payload_json["intelligence"])
		Globals.equipped_weapon = str(payload_json["equippedWeapon"])
		Globals.equipped_helmet = str(payload_json["equippedHelmet"])
		Globals.equipped_mining_equipment = str(payload_json["equippedMiningEquipment"])
		Globals.equipped_armor = str(payload_json["equippedArmor"])
		Globals.equipped_weapon_health = int(payload_json["equipWeaponHealth"])
		Globals.equipped_armor_health = int(payload_json["equipArmorHealth"])
		Globals.equipped_mining_equipment_health = int(payload_json["equipMiningHealth"])
		Globals.equipped_helmet_health = int(payload_json["equipHelmetHealth"])
		Globals.miningLockedTill = Time.get_unix_time_from_datetime_string(payload_json["lastMined"])
		Globals.quest.load_quests()
		
		if payload_json["characterSpriteScene"] == "NA":
			$CharacterSelect.visible = true
		else:
			Globals.custom_character_name = str(payload_json["characterName"])
			Globals.character_scene = str(payload_json["characterSpriteScene"])
			Globals.character_description = str(payload_json["characterDescription"])
			Globals.character_hit_point_bonus = int(payload_json["characterHitPointsBonus"])
			Globals.character_magic_point_bonus = int(payload_json["characterMagicPointsBonus"])
			Globals.character_strength_bonus = int(payload_json["characterStrengthBonus"])
			Globals.character_intelligence_bonus = int(payload_json["characterIntelligenceBonus"])
			start_game()
			print(Globals.current_scene)
	
	if response_code == 400:
		$LoginPanel/ErrorMessage.text = json.result.message

func _on_http_signup_request_request_completed(result, response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if response_code == 200:
		$RegisterPanel.visible = false
	
	if response_code == 400:
		print(json.result.message)

func _on_button_forward_pressed():
	if character_select_index < selectable_characters.size() - 1:
		character_select_index += 1
	else:
		character_select_index = 0
	
	_set_selectable_character()

func _on_button_back_pressed():
	if character_select_index > 0:
		character_select_index -= 1
	else:
		character_select_index = selectable_characters.size() - 1
	
	_set_selectable_character()

func _on_button_select_pressed():
	var custom_name = $CharacterSelect/CustomCharacterNameText.text.strip_edges()
	
	if custom_name == "":
		custom_name = user_name
	
	Globals.custom_character_name = custom_name
	Globals.character_description = selectable_characters[character_select_index]["spriteScene"]
	Globals.character_hit_point_bonus = selectable_characters[character_select_index]["hitPointsBonus"]
	Globals.character_magic_point_bonus = selectable_characters[character_select_index]["magicPointsBonus"]
	Globals.character_strength_bonus = selectable_characters[character_select_index]["strengthBonus"]
	Globals.character_intelligence_bonus = selectable_characters[character_select_index]["intelligenceBonus"]
	
	Globals.character_scene = selectable_characters[character_select_index]["spriteScene"]
	
	_save_player_character({
		"characterSpriteScene": Globals.character_scene, 
		"characterName": custom_name, 
		"isLoggedIn": true,
		"characterStrengthBonus": Globals.character_strength_bonus,
		"characterHitPointsBonus": Globals.character_hit_point_bonus,
		"characterMagicPointsBonus": Globals.character_magic_point_bonus,
		"characterIntelligenceBonus": Globals.character_intelligence_bonus,
	})

func _on_http_save_player_request_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		start_game()
		get_tree().root.get_node("Game").get_node("MusicPlayer").play()
