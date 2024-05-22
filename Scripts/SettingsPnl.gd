extends Panel

func _ready():
	$Audio/effectsVol.value = Globals.sfx_volume
	$Audio/mainVol.value = Globals.audio_volume
