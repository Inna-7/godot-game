class_name ThugCharacter extends CharacterBody2D

enum ENEMY_STATE { DORMANT, IN_BATTLE }

signal destroyed

@export var _starting_hit_points_min : int  = 20
@export var _starting_hit_points_max : int = 40
@export var _experience_reward_points : int = 2
@export var _chance_of_abundant_drop : float = 0.8
@export var _abundant_drops : Array[String] = [
	"res://Scenes/Items/health_potion.tscn",
	"res://Scenes/Items/cloth.tscn",
	"res://Scenes/Items/leather.tscn",
]
@export var _chance_of_rare_drops : float = 0.01
@export var _rare_drops : Array[String] = [
	"res://Scenes/Items/rare_dagger.tscn",
	"res://Scenes/Items/rare_sword.tscn",
	"res://Scenes/Items/rare_shovel.tscn",
	"res://Scenes/Items/rare_helmet.tscn",
	"res://Scenes/Items/rare_armor.tscn",
	"res://Scenes/Items/copper_nugget.tscn",
	"res://Scenes/Items/iron_nugget.tscn",
	"res://Scenes/Items/silver_nugget.tscn",
	"res://Scenes/Items/gold_nugget.tscn",
]
@export var sync_state := ENEMY_STATE.DORMANT
@export var sync_targets : Array
@export var sync_current_target : NodePath
@export var sync_equipped_weapon : Weapon
@export var move_speed : float = 100
@export var sync_velocity := Vector2.ZERO
@export var sync_input_direction := Vector2.ZERO

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var audio_stream : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var poof_sound_effect : AudioStream = preload("res://SoundFX/ES_Suction Pop - SFX Producer.mp3")
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var attack_timer : Timer = $AttackTimer
@onready var hit_timer : Timer = $HitTimer
@onready var FlashingText : PackedScene = preload("res://Scenes/Hud/flashing_text.tscn")
@onready var attackSound : AudioStream = preload("res://SoundFX/enemy_attack.wav")
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var player_sound_fx : AudioStreamPlayer = AudioStreamPlayer.new()
@onready var input_direction := Vector2.ZERO
@onready var MagicCast : PackedScene = preload("res://Scenes/Items/magic_cast.tscn")

var x_direction = 0
var y_direction = 0
var direction
var target
var _hit_points : int
var is_attack_enabled := true
var is_magic_attack_enabled := false
var is_magic : int = randi() % 11
var is_hit : bool = false
var in_battle := false
var is_dead := false
var _previous_position
var is_attacking_w_melee : bool = false
var is_attacking_w_magic : bool = false
var magicAttackSound : AudioStream = preload("res://SoundFX/magical_7.ogg")
var swordAttackSound : AudioStream = preload("res://SoundFX/sword.10.ogg")
var previous_music_stream : AudioStream
var weapon_name_upper

func _ready():
	randomize()
	_hit_points = randi_range(_starting_hit_points_min, _starting_hit_points_max)
	state_machine.travel("Idle")
	animation_tree.set("parameters/Idle/blend_position", direction)

func _physics_process(_delta):
	$AudioStreamPlayer2D.volume_db = Globals.sfx_volume
	update_animation_parameters(input_direction)
	
	# Set the animation state
	pick_new_state()
	
	# Move and slide
	# object "collision" contains information about the collision
	var collision = move_and_collide(input_direction*5)
	if collision:
		var collide  = input_direction.rotated(10)
		move_and_collide(collide)
#	else:
#		move_and_slide()
			
	# Tell the server our new input direction
	sync_input_direction = input_direction
		
	if ENEMY_STATE.IN_BATTLE && in_battle:
		pick_new_state()

func set_combat_idle_animation_conditions(weapon_name: String):
	# Reset all conditions
	animation_tree["parameters/IdleCombatSword/conditions/is_mythical"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_legendary"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_epic"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_rare"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_common"] = false
	animation_tree["parameters/IdleCombatSword/conditions/is_abundant"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_mythical"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_legendary"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_epic"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_rare"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_common"] = false
	animation_tree["parameters/IdleCombatDagger/conditions/is_abundant"] = false

	# Set conditions based on holding weapon type
	if weapon_name == "ABUNDANT DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleAbundantDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_abundant"] = true
	elif weapon_name == "common DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleCommonDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_common"] = true
	elif weapon_name == "RARE DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleRareDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_rare"] = true
	elif weapon_name == "EPIC DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleEpicDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleLegendaryDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_legendary"] = true
	elif weapon_name == "Mythical DAGGER":
		animation_tree.set("parameters/IdleCombatDagger/IdleMythicalDagger/blend_position", direction)
		animation_tree["parameters/IdleCombatDagger/conditions/is_mythical"] = true
	elif weapon_name == "ABUNDANT SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleAbundantSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_abundant"] = true
	elif weapon_name == "common SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleCommonSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_common"] = true
	elif weapon_name == "RARE SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleRareSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_rare"] = true
	elif weapon_name == "EPIC SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleEpicSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleLegendarySword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_legendary"] = true
	elif weapon_name == "Mythical SWORD":
		animation_tree.set("parameters/IdleCombatSword/IdleMythicalSword/blend_position", direction)
		animation_tree["parameters/IdleCombatSword/conditions/is_mythical"] = true

func set_combat_swing_animation_conditions(weapon_name: String):
	# Reset all conditions
	animation_tree["parameters/SwingCombatSword/conditions/is_mythical"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_legendary"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_epic"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_rare"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_common"] = false
	animation_tree["parameters/SwingCombatSword/conditions/is_abundant"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_mythical"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_legendary"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_epic"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_rare"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_common"] = false
	animation_tree["parameters/SwingCombatDagger/conditions/is_abundant"] = false

	# Set conditions based on holding weapon type
	if weapon_name == "ABUNDANT DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingAbundantDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_abundant"] = true
	elif weapon_name == "common DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingCommonDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_common"] = true
	elif weapon_name == "RARE DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingRareDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_rare"] = true
	elif weapon_name == "EPIC DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingEpicDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingLegendaryDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_legendary"] = true
	elif weapon_name == "Mythical DAGGER":
		animation_tree.set("parameters/SwingCombatDagger/SwingMythicalDagger/blend_position", direction)
		animation_tree["parameters/SwingCombatDagger/conditions/is_mythical"] = true
	elif weapon_name == "ABUNDANT SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingAbundantSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_abundant"] = true
	elif weapon_name == "common SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingCommonSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_common"] = true
	elif weapon_name == "RARE SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingRareSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_rare"] = true
	elif weapon_name == "EPIC SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingEpicSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_epic"] = true
	elif weapon_name == "LEGENDARY SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingLegendarySword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_legendary"] = true
	elif weapon_name == "Mythical SWORD":
		animation_tree.set("parameters/SwingCombatSword/SwingMythicalSword/blend_position", direction)
		animation_tree["parameters/SwingCombatSword/conditions/is_mythical"] = true

func set_hit_animation_conditions(weapon_name: String):
	# Reset all conditions
	animation_tree["parameters/GettingHit/conditions/is_abundant_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_common_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_rare_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_epic_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_legendary_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_mythical_dagger"] = false
	animation_tree["parameters/GettingHit/conditions/is_abundant_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_common_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_rare_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_epic_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_legendary_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_mythical_sword"] = false
	animation_tree["parameters/GettingHit/conditions/is_unarmed"] = false
	animation_tree["parameters/GettingHit/conditions/is_magic"] = false

	# Set conditions based on holding weapon type
	if weapon_name == "ABUNDANT DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_abundant_dagger"] = true
	elif weapon_name == "common DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_common_dagger"] = true
	elif weapon_name == "RARE DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_rare_dagger"] = true
	elif weapon_name == "EPIC DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_epic_dagger"] = true
	elif weapon_name == "LEGENDARY DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_legendary_dagger"] = true
	elif weapon_name == "Mythical DAGGER":
		animation_tree["parameters/GettingHit/conditions/is_mythical_dagger"] = true
	elif weapon_name == "ABUNDANT SWORD":
		animation_tree["parameters/GettingHit/conditions/is_abundant_sword"] = true
	elif weapon_name == "common SWORD":
		animation_tree["parameters/GettingHit/conditions/is_common_sword"] = true
	elif weapon_name == "RARE SWORD":
		animation_tree["parameters/GettingHit/conditions/is_rare_sword"] = true
	elif weapon_name == "EPIC SWORD":
		animation_tree["parameters/GettingHit/conditions/is_epic_sword"] = true
	elif weapon_name == "LEGENDARY SWORD":
		animation_tree["parameters/GettingHit/conditions/is_legendary_sword"] = true
	elif weapon_name == "Mythical SWORD":
		animation_tree["parameters/GettingHit/conditions/is_mythical_sword"] = true
	elif weapon_name == "MAGIC ATTACK":
		animation_tree["parameters/GettingHit/conditions/is_magic"] = true
	else:
		animation_tree["parameters/GettingHit/conditions/is_unarmed"] = true

func pick_new_state():
	# Original logic to determine direction
	if has_node(sync_current_target):
		var node = get_node(sync_current_target)
		if node.global_position.x < self.global_position.x:
			x_direction = -1  # Face left
		elif node.global_position.x > self.global_position.x:
			x_direction = 1  # Face right
		# Check vertical direction
		if node.global_position.y < self.global_position.y:
			y_direction = 1  # Face up
		elif node.global_position.y > self.global_position.y:
			y_direction = -1  # Face down
		direction = Vector2(x_direction,y_direction)
	weapon_name_upper = sync_equipped_weapon.name.to_upper()

func _on_spawn_area_body_entered(body):
	var index = sync_targets.find(body.get_path())
	
	if index == -1:
		return
	
	target = get_node(sync_targets[index])
	
	if target.in_battle:
		return
		
	if sync_state == ENEMY_STATE.DORMANT:
		sync_state = ENEMY_STATE.IN_BATTLE
		sprite.visible = true
		$Label.visible = true
		attack_timer.start()
		
		for opponent in sync_targets:
			get_node(opponent).start_battle(get_path())

func _on_battle_area_body_entered(body):
	var index = sync_targets.find(body.get_path())
	in_battle = true
	if index != -1:
		target = get_node(sync_targets[index])
		
		if target.in_battle:
			return
		
	sync_targets.append(body.get_path())
	if is_magic_attack_enabled:
		animation_tree.set("parameters/MagicCharge1/blend_position", direction)
		state_machine.travel("MagicCharge1")
	elif sync_equipped_weapon.name.to_upper().contains("DAGGER"):
		state_machine.travel("IdleCombatDagger")
		set_combat_idle_animation_conditions(weapon_name_upper)
	elif sync_equipped_weapon.name.to_upper().contains("SWORD"):
		state_machine.travel("IdleCombatSword")
		set_combat_idle_animation_conditions(weapon_name_upper)
	else:
		animation_tree.set("parameters/IdleCombat/blend_position", direction)
		state_machine.travel("IdleCombat")
	if sync_state == ENEMY_STATE.IN_BATTLE:
		body.start_battle(get_path())
		attack_timer.start()

func _on_attack_timer_timeout():
	# Choose a target to attack
	sync_current_target = sync_targets[randi_range(0, sync_targets.size() - 1)]
	is_magic = randi() % 11
	
	if is_magic > 5:
		is_magic_attack_enabled = true
		is_attack_enabled = false
	else:
		is_magic_attack_enabled = false
		is_attack_enabled = true
	
	if in_battle:
		if is_attack_enabled:
			attack()
		elif is_magic_attack_enabled:
			magic_attack()

		if sync_equipped_weapon.name.to_upper().contains("DAGGER") and is_magic < 5:
			state_machine.travel("SwingCombatDagger")
			set_combat_swing_animation_conditions(weapon_name_upper)
		elif sync_equipped_weapon.name.to_upper().contains("SWORD") and is_magic < 5:
			state_machine.travel("SwingCombatSword")
			set_combat_swing_animation_conditions(weapon_name_upper)
		elif is_magic > 5:
			animation_tree.set("parameters/MagicCast/blend_position", direction)
			state_machine.travel("MagicCast")
		else:
			animation_tree.set("parameters/SwingJab/blend_position", direction)
			state_machine.travel("SwingJab")
		
		is_attack_enabled = false
		is_magic_attack_enabled = false

		await(get_tree().create_timer(1.6).timeout)
		is_attacking_w_melee = false
		is_attacking_w_magic = false

		# Original logic to determine which combat idle animation to play
		if is_magic_attack_enabled:
			animation_tree.set("parameters/MagicCharge1/blend_position", direction)
			state_machine.travel("MagicCharge1")
		elif sync_equipped_weapon.name.to_upper().contains("DAGGER"):
			state_machine.travel("IdleCombatDagger")
			set_combat_idle_animation_conditions(weapon_name_upper)
		elif sync_equipped_weapon.name.to_upper().contains("SWORD"):
			state_machine.travel("IdleCombatSword")
			set_combat_idle_animation_conditions(weapon_name_upper)
		else:
			animation_tree.set("parameters/IdleCombat/blend_position", direction)
			state_machine.travel("IdleCombat")

		get_node(sync_current_target).subtract_hp(randi_range(0, 3))

	# Move the timer start outside the in_battle check
	attack_timer.start()

func _melee_attack_on_target(target_path : NodePath):
	is_attacking_w_magic = false
	target = get_node(target_path)
	if target != null:
		if has_node(target.get_path()):
			# The logic to determine the damage done to the enemy
			#update_attack_animation_parameters(true)
			is_attacking_w_melee = true
			if is_miss():
				target.subtract_hp(0)
			else:
				if not player_sound_fx.is_inside_tree():
					add_child(player_sound_fx)
					player_sound_fx.stream = swordAttackSound
					player_sound_fx.play()
				randomize()
				var damage = randi_range(sync_equipped_weapon.min_damage, sync_equipped_weapon.max_damage)
				var level_damage = 0.00
				var critical_hit_damage = 0.00
				print("Base damage: " + str(damage))
				level_damage = damage * sync_equipped_weapon.level_multiplier
				if level_damage < 1:
					level_damage = 1
				else:
					level_damage = int(level_damage)
				print("Level damage: " + str(level_damage))
				if is_critical_hit():
					critical_hit_damage = damage * sync_equipped_weapon.critical_hit_multiplier
					if critical_hit_damage < 1:
						critical_hit_damage = 1
					else:
						critical_hit_damage = int(critical_hit_damage)
				print("Critical hit damage: " + str(critical_hit_damage))
				damage = int(damage + critical_hit_damage + level_damage)
				print("Total damage: " + str(damage))
				target.subtract_hp(damage)
			await(get_tree().create_timer(1).timeout)
			var tween = create_tween()
			tween.tween_property(self, "position", _previous_position, 0.5)
			tween.tween_callback(_melee_attack_finished)
			attack_timer.start()
		else:
			end_battle()

func attack():
	collision_shape.disabled = true
	_previous_position = position
	z_index = 5
	var tween = create_tween()
	print("TWEEN: ", tween)
	tween.tween_property(self, "position", target.position, 0.5)
	print("TARGET: ", target)
	tween.tween_callback(_melee_attack_on_target.bind(target.get_path()))

func magic_attack():
	collision_shape.disabled = true
	_previous_position = position
	z_index = 5
	var timer = Timer.new()
	timer.connect("timeout",_magic_attack_on_target.bind(target.get_path()))
	timer.wait_time = 0.5
	timer.one_shot = true
	add_child(timer)
	timer.start()

func _magic_attack_on_target(target_path : NodePath):
	is_attacking_w_melee = false
	target = get_node(target_path)
	if target != null:
		if has_node(target.get_path()):
			# The logic to determine the damage done to the enemy
			#update_attack_animation_parameters(true)
			is_attacking_w_magic = true
			var final_damage_done : int= 0
			if is_miss():
				target.subtract_hp(0)
			else:
				randomize()
				var damage = randi_range(sync_equipped_weapon.min_damage, sync_equipped_weapon.max_damage)
				var level_damage = 0.00
				var critical_hit_damage = 0.00
			
				print("Base damage: " + str(damage))
			
				level_damage = damage * sync_equipped_weapon.level_multiplier
			
				if level_damage < 1:
					level_damage = 1
				else:
					level_damage = int(level_damage)
				
				print("Level damage: " + str(level_damage))
			
				if is_critical_hit():
					critical_hit_damage = damage * sync_equipped_weapon.critical_hit_multiplier
				
					if critical_hit_damage < 1:
						critical_hit_damage = 1
					else:
						critical_hit_damage = int(critical_hit_damage)
					
				print("Critical hit damage: " + str(critical_hit_damage))
				
				damage = int(damage + critical_hit_damage + level_damage)
			
				print("Total damage: " + str(damage))
			
				final_damage_done = damage
		
			await(get_tree().create_timer(1).timeout)
			_magic_attack_animation(target_path)
			var timer = Timer.new()
			timer.connect("timeout",self._magic_attack_finished.bind(target,final_damage_done))
			timer.wait_time = 0.5
			timer.one_shot = true
			add_child(timer)
			timer.start()
			attack_timer.start()
			if not player_sound_fx.is_inside_tree():
				add_child(player_sound_fx)
				player_sound_fx.stream = magicAttackSound
				player_sound_fx.play()
		else:
			end_battle()

func _magic_attack_animation(enemy_target_path : NodePath):
	if has_node(enemy_target_path):
		var enemy = get_node(enemy_target_path)
		var magic_cast = MagicCast.instantiate()
		magic_cast.position = position
		magic_cast.target_position = enemy.position
		get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").add_child(magic_cast)

func _magic_attack_finished(enemy_target_path : Node2D,final_damage_done:int):
	print("magic attack finished")
	enemy_target_path.subtract_hp(final_damage_done)
	is_attacking_w_magic = false
	z_index = 0
	collision_shape.disabled = false
	is_hit = false

func is_miss() -> bool:
	return randf() < sync_equipped_weapon.chance_of_miss

func is_critical_hit() -> bool:
	return randf() < sync_equipped_weapon.chance_of_critical_hit

func _melee_attack_finished():
	is_attacking_w_melee = false
	z_index = 0
	collision_shape.disabled = false

func _on_hit_timer_timeout():
	# Wait for 1.6 second and do random damage to player 
	await get_tree().create_timer(1.6).timeout
	# Original logic to determine which combat idle animation to play
	if is_magic_attack_enabled:
		animation_tree.set("parameters/MagicCharge1/blend_position", direction)
		state_machine.travel("MagicCharge1")
	elif sync_equipped_weapon.name.to_upper().contains("DAGGER") :
		state_machine.travel("IdleCombatDagger")
		set_combat_idle_animation_conditions(weapon_name_upper)
	elif sync_equipped_weapon.name.to_upper().contains("SWORD"):
		state_machine.travel("IdleCombatSword")
		set_combat_idle_animation_conditions(weapon_name_upper)
	else:
		animation_tree.set("parameters/IdleCombat/blend_position", direction)
		state_machine.travel("IdleCombat")

func flash_text(display_text):
	var flashing_text = FlashingText.instantiate()
	get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").add_child(flashing_text)
	flashing_text.position = Vector2(position.x, position.y + 36)
	flashing_text.set_text(display_text)
	flashing_text.play_animation()

func end_battle_music():
	Globals.music_player.stop()
	Globals.music_player.stream = previous_music_stream
	Globals.music_player.play()

func end_battle():
	print("End Battle")
	in_battle = false
	sync_state = ENEMY_STATE.DORMANT
	is_attacking_w_melee = false
	is_attacking_w_magic = false
	end_battle_music()
	attack_timer.stop()
	Globals.hud.hide_attack_ui()
	print("Battle ended. In battle state:", in_battle)
	print("Battle ended. In battle state:", sync_state)

func _drop_abundant_item():
	if _abundant_drops.size() > 0:
		var chosen_reward = load(_abundant_drops[randi() % _abundant_drops.size()])  # Using % to ensure a valid index
		var item = chosen_reward.instantiate()
		item.position = position
		get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").add_child(item)

func _drop_rare_item():
	if _rare_drops.size() > 0:
		var chosen_reward = load(_rare_drops[randi() % _rare_drops.size()])  # Using % to ensure a valid index
		var item = chosen_reward.instantiate()
		item.position = position
		get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").add_child(item)

func update_animation_parameters(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

func _on_battle_area_body_exited(body):
	var index = sync_targets.find(body.get_path())
	
	target = get_node(sync_targets[index])
	
	if target.in_battle:
		return
	
	sync_targets.pop_at(index)
	
	body.remove_target()
	
	if sync_state == ENEMY_STATE.IN_BATTLE:
		body.end_battle()
	
	if sync_targets.size() == 0:
		if sync_state == ENEMY_STATE.IN_BATTLE:
			sync_state = ENEMY_STATE.DORMANT
			sprite.visible = false
			$Label.visible = false
			attack_timer.stop()

func subtract_hp(hit_point_amount):
	var display_text : String
	
	if hit_point_amount == 0:
		display_text = "MISS!"
		if is_hit:
			is_hit = false
	else:
		display_text = "-" + str(hit_point_amount) + " HP"
		is_hit = true
		if target.is_magic_attack_enabled:
			animation_tree.set("parameters/GettingHit/blend_position",direction)
			state_machine.travel("GettingHit")
			# Set animation conditions
			set_hit_animation_conditions("MAGIC ATTACK")
			target.is_magic_attack_enabled = false
		else:
			animation_tree.set("parameters/GettingHit/blend_position",direction)
			state_machine.travel("GettingHit")
			# Set animation conditions
			set_hit_animation_conditions(weapon_name_upper)
			target.is_attack_enabled = false
	hit_timer.start()
	
	# The actual deduction needs to be an RPC
	flash_text(display_text)
	_subtract_hp(hit_point_amount)

func _subtract_hp(amount):
	if (_hit_points - amount < 0):
		_hit_points = 0
	else:
		_hit_points -= amount
		print("Remaining hit points: " + str(_hit_points))
	
	if _hit_points == 0:
		is_hit = true
		animation_tree.set("parameters/Collapse/blend_position",direction)
		state_machine.travel("Collapse")
		await get_tree().create_timer(1.6).timeout
		emit_signal("destroyed")

		randomize()
		var node
		for enemy in sync_targets:
			if has_node(enemy):
				node = get_node(enemy)
				node.end_battle()
				
				node.flash_global_text("+" + str(_experience_reward_points) + " exp")
				
		# Calculate and drop
		if (randf() < _chance_of_rare_drops):
			# rare drop
			_drop_rare_item()
		else:
			if (randf() < _chance_of_abundant_drop):
				_drop_abundant_item()
					
		queue_free()

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
