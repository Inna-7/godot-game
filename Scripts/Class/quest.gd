
"""
Name: Quests
Author: SatyamKhadka
Description: This class is used to manage quest progress of player throught the game.
It pulls the serialized JSON string from the database, deserializes it and makes it available for the game.
It stores the state of the quest to the database as well. It serializes the JSON quest object,
and stores it in the database.
It also updates the state of the quest as the user progresses. 
"""

class_name Quest extends Node

var initialized:bool = false
var initializedwerror:bool = false
var quests_raw_string:String
var completed_quests:Array





func _init():
	pass

"""
get current quest state
"""
func get_quests()->Array:
	return completed_quests


"""
saves completed quest in database
returns true if saved in database
returns false if quest is already complated
"""
func complete(quest:String)->bool:
	if completed_quests.has(quest):
		return false
	
	#do something if some quest is completed
	match quest:
		"switch_triactor":
			complete_switch_triactor()
		_:
			print("No quest matched with that name")
			return false
	#save quest
	_generic_save_completed_quest(quest)
	return true
	
func check_quest_completed(quest:String)->bool:
	return completed_quests.has(quest)


















"""
completed quest
"""
func _generic_save_completed_quest(quest_name:String):
	#find glenn
	_add_completed_quest(quest_name)
	completed_quests.append(quest_name)

func complete_switch_triactor():
	Globals.player.add_trilium(15)
	
"""
end of "completed quests"
"""





"""
task functions for quest completion
"""
func complete_find_glen()->bool:
	# earn 15xp
	if !completed_quests.has("Find Glenn"):
		print("found glen")
		_add_completed_quest("Find Glenn")
		return true
	else:
		print("Already Found Glen")
		return false

func complete_0a():
	print("receive 15XP")


"""
end of task functions for quest completion
"""























"""NETWORKING"""

func get_headers()->Array:
	return [
		"Content-Type: application/json",
		"Authorization: Bearer " + Globals.jwt
	]
"""
loads quests from the database
"""
func load_quests():
	
	#save it in the database
	Globals.hud.show_save_icon()
	
	var url = Globals.RPC_SERVER + '/api/fetchCompletedQuest'
	# Convert data to json string:
	# Add 'Content-Type' header:

	var http_fetch_completed_quest : HTTPRequest = HTTPRequest.new() 
	add_child(http_fetch_completed_quest)
	http_fetch_completed_quest.request_completed.connect(self._on_fetch_quest_completed.bind(http_fetch_completed_quest))
	
	http_fetch_completed_quest.request(url, get_headers(), HTTPClient.METHOD_POST, "")
	
func _add_completed_quest(quest_name:String):
	print("initiated add completed quest sequence")
	Globals.hud.show_save_icon()

	var url = Globals.RPC_SERVER + '/api/addCompletedQuest'
	# Convert data to json string:
	var query = JSON.stringify({"questName": quest_name})
	# Add 'Content-Type' header:

	var http_save_completed_quests_request : HTTPRequest = HTTPRequest.new()
	add_child(http_save_completed_quests_request)
	http_save_completed_quests_request.request_completed.connect(self._on_save_completed_quests_request_completed.bind(http_save_completed_quests_request))	
	#	http_save_completed_quests_request.connect("request_completed", Callable(self, "_on_save_completed_quests_request_completed"))
	http_save_completed_quests_request.request(url, get_headers(), HTTPClient.METHOD_POST, query)
	
	
func _on_request_completed(_result, _responseCode, _headers, _body, http_request_obj:HTTPRequest):
	Globals.hud.hide_save_icon()
	http_request_obj.queue_free()

func _on_fetch_quest_completed(_result, _responseCode, _headers, _body, http_request_obj:HTTPRequest):
	if _responseCode == 200:
		var json = JSON.parse_string(_body.get_string_from_utf8())
		var quests = json.result
		for quest in quests:
			print(quest.questName)
			completed_quests.append(quest.questName)
	http_request_obj.queue_free()

func _on_save_completed_quests_request_completed(result, response_code, _headers, body, http_request_obj:HTTPRequest):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var quest = json.result

		
		if (json.success):
			completed_quests.append(quest.questName)
	
	Globals.hud.hide_save_icon()
	http_request_obj.queue_free()

"""END OF NETWORKING"""

