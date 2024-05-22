@tool
extends EditorPlugin

var npc_gpt_script = preload("res://addons/npc_gpt_plugin/npc_gpt.gd")

func _enter_tree():
	add_custom_type("NpcGpt2D", "NpcGpt2D", npc_gpt_script, null)

func _exit_tree():
	remove_custom_type("NpcGpt2D")
