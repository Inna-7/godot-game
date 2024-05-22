extends Node2D

var target_position : Vector2

func set_color(color : Color):
	$CPUParticles2D.color = color

func _enter_tree():
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 1)
	tween.tween_callback(self.queue_free)
