extends Node2D

var self_name : String
var item_state : String = "normal"
var item_ID : String = ""
var item_health : int
var collection_name : String

func set_item_name(item_name):
	$action_keys_hold/ItemName.text = item_name
	self_name = item_name

func set_item_id(id):
	item_ID = id

func set_item_health(health):
	item_health = health

func set_item_collection(collection):
	collection_name = collection

func set_item_sprite_image(sprite_file_name):
	var SpriteObject : PackedScene = load(sprite_file_name)
	var sprite = SpriteObject.instantiate()
	$SpritePlaceHolder.add_child(sprite)

func set_item_level(item_level):
	$action_keys_hold/ItemLevel.text = "LVL: %s" % item_level

func disable_unequip_button():
	$action_keys_hold/ButtonUnequip.disabled = true

func enable_unequip_button():
	$action_keys_hold/ButtonUnequip.disabled = false

func _unequip_mining_equipment():
	if Globals.player == null:
		return
	
	if Globals.player.sync_equipped_mining_equipment.name != "Right Hand":
		Globals.player.add_item_to_inventory(Globals.player.sync_equipped_mining_equipment.name,Globals.player.sync_equipped_mining_equipment.item_health,Globals.player.sync_equipped_weapon.rarity)
		Globals.player.save_equipped_mining_equipment({"equippedMiningEquipment": "Right Hand"})

func _on_button_unequip_pressed():
	_unequip_mining_equipment()
	Globals.hud._update_inventory_panel()
	Globals.hud._update_equipped_mining_equ_tab()

func _on_button_unequip_mouse_entered():
	Globals.in_item_selection = true

func _on_button_unequip_mouse_exited():
	Globals.in_item_selection = false
	await get_tree().create_timer(0.3).timeout
	if !Globals.in_item_selection:
		self.get_parent()._show_item_action_keys(false)
