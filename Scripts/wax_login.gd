extends Node2D

var game = preload("res://Scenes/Main/game.tscn")
var desert_background_music = preload("res://Music/DesertBackgroundMusic.ogg")
var login_callback = JavaScriptBridge.create_callback(set_user)
var set_balances_callback = JavaScriptBridge.create_callback(set_balances)

func _ready():
	$Panel/WCW.visible = true


func set_user(args) -> void:
	var window = JavaScriptBridge.get_interface("window")
	var console = JavaScriptBridge.get_interface("console")
	console.log("set_user method called");
	Globals.user_name = args[0]
	window.getBalances(args[0], set_balances_callback)
	get_tree().root.get_node("Game").get_node("TitleScreen").visible = false
	get_tree().root.get_node("Game").get_node("Overworld").visible = true
	get_tree().root.get_node("Game").get_node("Overworld").create_player()
	get_tree().root.get_node("Game").get_node("MusicPlayer").stream = desert_background_music
	get_tree().root.get_node("Game").get_node("MusicPlayer").play()


func set_balances(args) -> void:
	var console = JavaScriptBridge.get_interface("console")
	console.log("Engine received: " + str(args[0]))
	Globals.wax_balance = str(args[0])


func _on_close_pressed():
	queue_free()


func _on_anchor_pressed():
	var window = JavaScriptBridge.get_interface("window")
	window.anchorLogin(login_callback)
	Globals.using_wax_cloud_wallet = false
	Globals.using_anchor_wallet = true
	Globals.logged_in = true


func _on_wcw_pressed():
	var window = JavaScriptBridge.get_interface("window")
	window.waxCloudWalletLogin(login_callback)
	Globals.using_wax_cloud_wallet = true
	Globals.using_anchor_wallet = false
	Globals.logged_in = true
