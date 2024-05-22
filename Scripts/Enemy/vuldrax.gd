extends CharacterBody2D

enum ENEMY_STATE { DORMANT, IN_BATTLE }

signal destroyed

@export var _starting_hit_points_min : int  = 60
@export var _starting_hit_points_max : int = 90
@export var _experience_reward_points : int = 5
@export var _trilium_reward_min : float = 0.1
@export var _trilium_reward_max : float = 0.5
@export var _chance_of_abundant_drop : float = 0.8
@export var _abundant_drops : Array[String] = [
	"res://Scenes/Items/health_potion.tscn",
	"res://Scenes/Items/copper_ingot.tscn",
	"res://Scenes/Items/iron_ingot.tscn",
	"res://Scenes/Items/silver_ingot.tscn",
	"res://Scenes/Items/gold_ingot.tscn"
]
@export var _chance_of_rare_drops : float = 0.02
@export var _rare_drops : Array[String] = [
	"res://Scenes/Items/legendary_dagger.tscn",
	"res://Scenes/Items/legendary_sword.tscn",
	"res://Scenes/Items/legendary_shovel.tscn",
	"res://Scenes/Items/legendary_armor.tscn",
	"res://Scenes/Items/legendary_helmet.tscn",
]
@export var sync_state := ENEMY_STATE.DORMANT
@export var sync_targets : Array
@export var sync_current_target : NodePath

var _hit_points : int

const Fireball : PackedScene = preload("res://Scenes/Items/fireball.tscn")

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var audio_stream : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var poof_sound_effect : AudioStream = preload("res://SoundFX/ES_Suction Pop - SFX Producer.mp3")
@onready var smoke_appear_animation : CPUParticles2D = $SmokeAppearAnimation
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var attack_timer : Timer = $AttackTimer
@onready var FlashingText : PackedScene = preload("res://Scenes/Hud/flashing_text.tscn")
@onready var attackSound : AudioStream = preload("res://SoundFX/enemy_attack.wav")

var x_direction = 0
var y_direction = 0
var direction
var target

func _on_spawn_area_body_entered(body):
	var index = sync_targets.find(body.get_path())
	
	if index == -1:
		return
	
	target = get_node(sync_targets[index])
	
	if target.in_battle:
		return
		
	if sync_state == ENEMY_STATE.DORMANT:
		sync_state = ENEMY_STATE.IN_BATTLE
		_play_appear_effects()
		sprite.visible = true
		$Label.visible = true
		attack_timer.start()
		
		for opponent in sync_targets:
			get_node(opponent).start_battle(get_path())
		
		# Face the proper direction
		var direction_to_player = (target.global_position - global_position).normalized()
		if abs(direction_to_player.x) > abs(direction_to_player.y):
			if direction_to_player.x > 0:
				set_idle_right()
			else:
				set_idle_left()
		else:
			if direction_to_player.y > 0:
				set_idle_up()
			else:
				set_idle_down()

func _physics_process(_delta):
	$AudioStreamPlayer2D.volume_db = Globals.sfx_volume

func _ready():
	randomize()
	name = "Vuldrax"
	_hit_points = randi_range(_starting_hit_points_min, _starting_hit_points_max)
	state_machine.travel("Idle")
	set_idle_down()

func set_idle_down():
	animation_tree.set("parameters/Idle/blend_position", Vector2.DOWN)

func set_idle_left():
	animation_tree.set("parameters/Idle/blend_position", Vector2.LEFT)

func set_idle_up():
	animation_tree.set("parameters/Idle/blend_position", Vector2.UP)

func set_idle_right():
	animation_tree.set("parameters/Idle/blend_position", Vector2.RIGHT)

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

func _play_appear_effects():
	smoke_appear_animation.emitting = true
	audio_stream.stream = poof_sound_effect
	audio_stream.play()

func _on_attack_timer_timeout():
	# Choose a target to attack
	sync_current_target = sync_targets[randi_range(0, sync_targets.size() - 1)]
	
	# Choose an attack to perform
	var attack = randi_range(0, 0)
	
	match (attack):
		0:
			# launch the fireball animation on the server so everyone can see
			_acid_attack(sync_current_target)
			animation_tree.set("parameters/Strike/blend_position", direction)
			state_machine.travel("Strike")
			# Wait for 1.6 second and do random damage to player 
			await get_tree().create_timer(1.6).timeout
			animation_tree.set("parameters/Idle/blend_position", direction)
			state_machine.travel("Idle")
			get_node(sync_current_target).subtract_hp(randi_range(0, 6))
	
	attack_timer.start()

func _acid_attack(enemy_target_path : NodePath):
	if has_node(enemy_target_path):
		var node = get_node(enemy_target_path)
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
		var fireball = Fireball.instantiate()
		fireball.position = position
		fireball.target_position = node.position
		fireball.set_color(Color.CHARTREUSE)
		get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").add_child(fireball)
		audio_stream.stream = attackSound
		audio_stream.play()

func flash_text(display_text):
	var flashing_text = FlashingText.instantiate()
	get_tree().root.get_node("Game").get_node("SceneWrapper").get_node("Players").add_child(flashing_text)
	flashing_text.position = Vector2(position.x, position.y + 36)
	flashing_text.set_text(display_text)
	flashing_text.play_animation()

func subtract_hp(hit_point_amount):
	var display_text : String
	
	if hit_point_amount == 0:
		display_text = "MISS!"
	else:
		display_text = "-" + str(hit_point_amount) + " HP"
		if target.is_magic_attack_enabled:
			if target.global_position.x < self.global_position.x:
				x_direction = -1  # Face left
			elif target.global_position.x > self.global_position.x:
				x_direction = 1  # Face right
			# Check vertical direction
			if target.global_position.y < self.global_position.y:
				y_direction = 1  # Face up
			elif target.global_position.y > self.global_position.y:
				y_direction = -1  # Face down
			direction = Vector2(x_direction,y_direction)
			animation_tree.set("parameters/GettingHitMagicCast/blend_position",direction)
			state_machine.travel("GettingHitMagicCast")
			target.is_magic_attack_enabled = false
		else:
			if target.global_position.x < self.global_position.x:
				x_direction = -1  # Face left
			elif target.global_position.x > self.global_position.x:
				x_direction = 1  # Face right
			# Check vertical direction
			if target.global_position.y < self.global_position.y:
				y_direction = 1  # Face up
			elif target.global_position.y > self.global_position.y:
				y_direction = -1  # Face down
			direction = Vector2(x_direction,y_direction)
			animation_tree.set("parameters/GettingHit/blend_position",direction)
			state_machine.travel("GettingHit")
			target.is_attack_enabled = false
	$HitTimer.start()
	
	# The actual deduction needs to be an RPC
	flash_text(display_text)
	_subtract_hp(hit_point_amount)

func _on_hit_timer_timeout():
	state_machine.travel("Idle")

func _subtract_hp(amount):
	if (_hit_points - amount < 0):
		_hit_points = 0
	else:
		_hit_points -= amount
		print("Remaining hit points: " + str(_hit_points))
	
	if _hit_points == 0:
		animation_tree.set("parameters/Collapse/blend_position",direction)
		state_machine.travel("Collapse")
		await get_tree().create_timer(1.0).timeout
		emit_signal("destroyed")
		
		randomize()
		var node
		var trilium_reward = round_to_dec(randf_range(_trilium_reward_min, _trilium_reward_max), 4)
		for _target in sync_targets:
			if has_node(_target):
				node = get_node(_target)
				node.end_battle()
				
				# Distribute Trilium awards
				node.add_trilium(trilium_reward)
				
				# Distribute experience points
				node.add_experience(_experience_reward_points)
				
				node.flash_global_text("+" + str(_experience_reward_points) + " exp +" + str(trilium_reward) + " TLM")
				
		# Calculate and drop
		if (randf() < _chance_of_rare_drops):
			# rare drop
			_drop_rare_item()
		else:
			if (randf() < _chance_of_abundant_drop):
				_drop_abundant_item()
					
		queue_free()

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

func _on_battle_area_body_entered(body):
	var index = sync_targets.find(body.get_path())
	
	if index != -1:
		target = get_node(sync_targets[index])
		
		if target.in_battle:
			return
		
	sync_targets.append(body.get_path())
	
	if sync_state == ENEMY_STATE.IN_BATTLE:
		body.start_battle(get_path())

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
