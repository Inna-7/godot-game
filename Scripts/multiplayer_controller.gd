extends Node

# The port the server listens to for client connections
const PORT = 4100

#const SERVER_IP = "trilium-quest.net"
const SERVER_IP = "127.0.0.1"

var peer
var error
var overworld = preload("res://Scenes/Levels/overworld.tscn").instantiate()
var dungeon1 = preload("res://Scenes/Levels/dungeon1.tscn").instantiate()
var dungeon2 = preload("res://Scenes/Levels/dungeon2.tscn").instantiate()

func _ready():
	#Start the server if Godot is passed the "--server" argument, and start a client otherwise.
	if "--server" in OS.get_cmdline_args():
		print("Server")
		start_network(true)
		start_game()
	else:
		print("Client")
		start_network(false)
	print("Multiplayer authority: ", is_multiplayer_authority())

@rpc("authority")
func start_game():
	#rpc("rpc_start_game")
	get_tree().root.get_node("Game").get_node("SceneWrapper").add_child(overworld)
	get_tree().root.get_node("Game").get_node("SceneWrapper").add_child(dungeon1)
	get_tree().root.get_node("Game").get_node("SceneWrapper").add_child(dungeon2)
	print("Calling rpc_start_game")
	if Globals.current_scene == "":
		Globals.current_scene = "Overworld"
	Globals.check_scene_state()
	print("rpc start_game called")

func start_network(server: bool):
	multiplayer.peer_connected.connect(_connected)
	multiplayer.peer_disconnected.connect(_disconnected)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.connected_to_server.connect(_connected_to_server)

#	This line is if we want to use WebSockets
#	peer = WebSocketMultiplayerPeer.new()

#	This line is if we want to use the standard multiplayer class
	peer = ENetMultiplayerPeer.new()
#	multiplayer.set_multiplayer_peer(peer)
	if server:
#		Start listening on the given port.
		error = peer.create_server(PORT)
		peer.peer_connected
		multiplayer.set_multiplayer_peer(peer)


		if error != OK:
			if error == 20:
				print("Unable to start server on port " + str(PORT))
			else:
				print("Unable to start server, code: " + str(error))
			set_process(false)
		else:
			print("Server Unique ID: " + str(peer.get_unique_id()))
			print("Server is listening " + str(PORT))
			print("Multiplayer authority: ", is_multiplayer_authority())
	else:
#		This line creates a client for ENetMultiplayerPeer
		error = peer.create_client(SERVER_IP, PORT)

#		This line create a client for Websockets
#		error = peer.create_client(SERVER_IP + ":" + str(PORT))

		if error != OK:
			print("Error message: " + str(error))

	multiplayer.multiplayer_peer = peer

# Function are working only on client side
func _connected_to_server():
	print("You are connected to the server")
# Function are working only on client side
func _connection_failed():
	print("Connection failed")

func _physics_process(_delta):
	# We only need to poll if we're using websockets for a server
	#multiplayer.poll()
	pass

# Function are working only on server side
func _connected(args):
	if "--server" in OS.get_cmdline_args():
		# This is called when a new peer connects, "id" will be the assigned peer id
		print("Client %d connected" % [args])
	else:
		print("Connected! " + str(args))
		print("Unique ID: " + str(multiplayer.get_unique_id()))

# Function are working only on server side
func _disconnected(id, was_clean = false):
	if "--server" in OS.get_cmdline_args():
		# This is called when a client disconnects, "id" will be the one of the
		# disconnecting client, "was_clean" will tell you if the disconnection
		# was correctly notified by the remote peer before closing the socket.
		print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
		for child in Globals.world_objects.get_children():
			if child.name == str(id):
				child.queue_free()
