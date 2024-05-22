extends Panel

func _on_mouse_entered():
	Globals.in_item_selection = true

func _on_mouse_exited():
	Globals.in_item_selection = false
	await get_tree().create_timer(0.2).timeout
	if !Globals.in_item_selection:
		self.get_parent().get_parent()._show_item_action_keys(false)
		self.get_parent().get_parent()._show_in_crafting_keys(false)
