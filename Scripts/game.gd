extends Node

func _process(_delta):
	$MusicPlayer.volume_db = Globals.audio_volume 
