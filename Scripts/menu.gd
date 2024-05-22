extends Node2D

@onready var music_player : AudioStreamPlayer = get_tree().root.get_node("Game").get_node("MusicPlayer")

func _process(_delta):
	Globals.audio_volume = $Wrapper/Panel/SettingsPnl/Audio/mainVol.value
	Globals.sfx_volume = $Wrapper/Panel/SettingsPnl/Audio/effectsVol.value

func update_player_stats():
	$Wrapper/Panel/PlayerStats/Content.text = "\nCharacter Name: %s" % Globals.player.sync_custom_character_name + "\nHit Points: %s" % Globals.player.sync_hit_points + "\nMagic Points: %s" % Globals.player.sync_magic_points + "\nMax Magic Points: %s" % Globals.player.sync_max_magic_points + "\nMax Hit Points: %s" % Globals.player.sync_max_hit_points + "\nStrength: %s" % Globals.player.sync_strength + "\nLevel: %s" % Globals.player.sync_level + "\nExperience: %s" % Globals.player.sync_exp + "\nIntelligence: %s" % Globals.player.sync_intelligence

func _on_exit_pressed():
	get_tree().root.queue_free()
	get_tree().quit()

func _on_close_audio_pressed():
	$Wrapper/Panel/SettingsPnl/Audio.visible = false

func _on_close_credits_pressed():
	$Wrapper/Panel/Credits.visible = false

func _on_credits_btn_pressed():
	$Wrapper/Panel/Credits.visible = true

func _on_close_pressed():
	self.queue_free()
	Globals.menu_isOpen = false

func _on_settings_pressed():
	$Wrapper/Panel/SettingsPnl.visible = true

func _on_close_settings_pressed():
	$Wrapper/Panel/SettingsPnl.visible = false

func _on_audio_btn_pressed():
	$Wrapper/Panel/SettingsPnl/Audio.visible = true

func _on_close_stats_pressed():
	$Wrapper/Panel/PlayerStats.visible = false

func _on_player_stats_pressed():
	update_player_stats() #refreshes when clicked again
	$Wrapper/Panel/PlayerStats.visible = true
