extends Panel

@onready var _border : Panel = $border
@export var slot_active: bool
var mouse_inside = false
					
func _process(_delta):
	if !slot_active and !Globals.in_item_selection:
		mouse_filter = Control.MOUSE_FILTER_STOP
		
func _get_slot_node():
	var slot_item: Node
	if self.get_parent().is_in_group("equipmentcontainer"):
		if self.get_child_count() > 0:
			slot_item = self.get_child(0)
	if self.get_child_count() > 2:
		slot_item = self.get_child(2)
	
	return slot_item


func _get_item_name():
	var slot_node = _get_slot_node()
	if slot_node and slot_node.has_node("action_keys_hold/ItemName"):
		return slot_node.get_node("action_keys_hold/ItemName").text
	return ""

func _get_item_quantity():
	var slot_node = _get_slot_node()
	if slot_node and slot_node.has_node("action_keys_hold/ItemName"):
		return slot_node.get_item_quantity()
		
func _show_item_action_keys(state):
	var slot_node = _get_slot_node()
	
	if slot_node and is_instance_valid(slot_node.get_node("action_keys_hold")):
		var action_keys_node = slot_node.get_node("action_keys_hold")
		if is_instance_valid(action_keys_node):
			action_keys_node.visible = state
			
		if state == true:
			#ITEM MENU POPUP SHOULD SHOW ABOVE ALL ITEMS INCLUDING INPUT HANDLING:
			action_keys_node.size = Vector2(98, 54)
			if self.get_parent().is_in_group("equipmentcontainer"):
				action_keys_node.position = get_global_mouse_position() + Vector2(-70, 0)
			else:
				action_keys_node.position = get_global_mouse_position()
			
	if is_instance_valid(_border):
		_border.visible = state

func _show_in_crafting_keys(state):
	var slot_node = _get_slot_node()
	
	if slot_node.get_parent().name != "EquippedContainerLeft" or slot_node.get_parent().name != "EquippedContainer":
		if slot_node and is_instance_valid(slot_node.get_node("in_crafting_keys")):
			var crafting_keys_node = slot_node.get_node("in_crafting_keys")
			if is_instance_valid(crafting_keys_node):
				crafting_keys_node.visible = state
				
			if state == true:
				#ITEM MENU POPUP SHOULD SHOW ABOVE ALL ITEMS INCLUDING INPUT HANDLING:
				crafting_keys_node.size = Vector2(98, 54)
				crafting_keys_node.position = get_global_mouse_position()
				
		if is_instance_valid(_border):
			_border.visible = state
		
func _on_gui_input(_event):
	Globals.active_item_slot = self
	
	if Input.is_action_pressed("ui_click"):
		slot_active = !slot_active
		
		if _get_slot_node().item_state == "in_crafting":
			_show_in_crafting_keys(slot_active)
			
		else:
			_show_item_action_keys(slot_active)
			
#			for slot in get_parent().get_children():
#				if slot != Globals.active_item_slot:
#					slot.mouse_filter = Control.MOUSE_FILTER_IGNORE	

func _on_mouse_entered():
	mouse_inside = true
	Globals.in_item_selection = true
	
func _on_mouse_exited():
	mouse_inside = false
	await(get_tree().create_timer(0.5).timeout)
	if not mouse_inside and !Globals.in_item_selection:
		_show_item_action_keys(false)
		
	#get_tree().create_timer(0.5).connect("timeout", _on_delayed_mouse_exit)

func _on_delayed_mouse_exit():
	if not mouse_inside and not Globals.in_item_selection:
		_show_item_action_keys(false)
