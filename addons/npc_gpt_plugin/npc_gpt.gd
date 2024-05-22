class_name NpcGpt

extends CharacterBody2D

signal response_received(response)
signal messages_summarized(summary)

@export var chat_gpt_key : String
@export var npc_name : String
@export var npc_back_story : String
@export var sample_npc_question_prompt : String = "Hi, what do you do here?"
@export var sample_npc_prompt_response : String

var url : String = "https://api.openai.com/v1/chat/completions" 
var headers : Array = []
var engine : String = "gpt-3.5-turbo" 
var http_request : HTTPRequest
var summarize_http_request : HTTPRequest
var past_messages_array : Array = []
var num_cache_messages = 4


func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	summarize_http_request = HTTPRequest.new()
	add_child(summarize_http_request)
	summarize_http_request.connect("request_completed", Callable(self, "_on_summarize_request_completed"))
	headers = ["Content-Type: application/json", "Authorization: Bearer " + chat_gpt_key]


func call_GPT(prompt):
	# if using past messages array, and has stored max number of messages, call summarize function which will summarize messages so far and clear the cache
	if past_messages_array.size() >= 2 * num_cache_messages and past_messages_array.size() != 0:
		summarize_GPT(past_messages_array)
		await self.messages_summarized
		
	print("calling GPT")
	var body = JSON.stringify({
		"model": engine,
		"messages": past_messages_array + [{"role": "system", "content": npc_back_story}, {"role": "user", "content": prompt}],
		"temperature": 0.5
	})
	
	# Now call GPT
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		push_error("Something Went Wrong!")
	
	# If using past messages array, add prompt message to the cache
	if num_cache_messages > 0:
		past_messages_array.append({"role": "user", "content": prompt})


func summarize_GPT(messages : Array):
	print("having GPT summarize message cache")
	#print(messages)
	var body = JSON.stringify({
		"model": engine,
		"messages": messages + [{"role": "user", "content": "Summarize the most important points of our conversation so far without being too wordy."}],
		"temperature": 0.5
	})
	var error = summarize_http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		push_error("Something Went Wrong!")


func _on_request_completed(result, responseCode, headers, body):
	# Should recieve 200 if all is fine; if not print code
	if responseCode != 200:
		print("There was an error, response code:" + str(responseCode))
		print(result)
		print(headers)
		print(body)
		return
		
	var data = body.get_string_from_utf8()
	print ("Data received: %s"%data)
	var test_json_conv = JSON.new()
	test_json_conv.parse(data)
	var response = test_json_conv.get_data()
	var choices = response.choices[0]
	var message = choices["message"]
	var AI_generated_dialogue = message["content"]
	
	# Store most recent response if using messages cache
	if num_cache_messages > 0:
		past_messages_array.append(message)
	
	# Let other nodes know that AI generated dialogue is ready from GPT	
	emit_signal("response_received", AI_generated_dialogue)


func _on_summarize_request_completed(result, responseCode, headers, body):
	# Should recieve 200 if all is fine; if not print code
	if responseCode != 200:
		print("There was an error, response code:" + str(responseCode))
		print(result)
		print(headers)
		print(body)
		return
		
	var data = body.get_string_from_utf8()#fix_chunked_response(body.get_string_from_utf8())
	#print ("Data received: %s"%data)
	var test_json_conv = JSON.new()
	test_json_conv.parse(data)
	var response = test_json_conv.get_data()
	var choices = response.choices[0]
	var message = choices["message"]
	var summary = message["content"]
	#print("Summary was:" + summary)
	
	# If using messsages cache, clear messages array now that summary is prepared
	if num_cache_messages > 0:
		past_messages_array.clear()
		# Now add summary to messages cache so it starts the new cache with the summary
		past_messages_array.append(message)
		#print(past_messages_array)
	# Let other nodes know that summary was prepared
	emit_signal("messages_summarized", summary)
