class_name BossEnemyScorpion
extends CharacterBody2D

const EnemyDeathEffectScene = preload("res://effects/enemy_death_effect.tscn")
const AttackEffectScene = preload("res://effects/attack_effect.tscn")

@export var max_hp: int = 100
@export var turns_at_ledges = true
@export var speed = 15.0

var STATE_OPTIONS = [idle_state, walk_state, attack_state_1, attack_state_2]
var state_options_left = []
var state = idle_state : set = set_state
var state_init = true : get = get_state_init

var hp : int = max_hp : set = set_hp
var gravity = 200.0
var direction = -1.0

var new_tween : Tween
var step = 0
var latest_anim
var spear_swing_sound_flag = false
var spear_hit_ground_sound_flag = false


@onready var animation_player = $AnimationPlayer
@onready var main = $Main
@onready var floor_cast = $FloorCast
@onready var stats = $Stats
@onready var death_effect_location = $DeathEffectLocation
@onready var starting_position = global_position
@onready var progress_bar = $ProgressBar
@onready var attack_rate_timer = $AttackTimer


func _ready():
	var id = WorldStash.get_id(self, starting_position)
	var died = WorldStash.retrieve(id, "died")
	if died: queue_free()
	
	set_state(walk_state)
	
	
func set_state(value):
	state = value
	state_init = true


func get_state_init():
	var was = state_init
	state_init = false
	return was


func _process(delta):
	state.call(delta)
	pass
	

func check_left_right_direction():
	var player = MainInstances.player
	var direction = global_position.direction_to(player.global_position)
	
	if direction.x >= 0:
		return 1
	else:
		return -1

	
func walk_state(delta):
	var player = MainInstances.player
	var direction = global_position.direction_to(player.global_position)
	
	if direction.x >= 0:
		animation_player.play("walk_right")
	else:
		animation_player.play("walk")
	
	var distant_from_player = player.global_position.x - global_position.x
	if distant_from_player >= 80:
		velocity.x = direction.x * speed
		move_and_slide()
	else:
		state = attack_state_1
	
	
func idle_state(delta):
	var player = MainInstances.player
	var direction = global_position.direction_to(player.global_position)
	
	if direction.x >= 0:
		animation_player.play("idle_right")
	else:
		animation_player.play("idle")
	
	
func attack_state_1(delta):
	var player = MainInstances.player
	var direction = global_position.direction_to(player.global_position)
	
	if attack_rate_timer.time_left == 0:
		attack_rate_timer.start()
		
		if direction.x >= 0:
			animation_player.play("attack_1_right")
		else:
			animation_player.play("attack_1")
			
		spear_swing_sound_flag = true
		spear_hit_ground_sound_flag = true
		
		var distant_from_player = player.global_position.x - global_position.x
		#print("distant_from_player: ", distant_from_player)
		if distant_from_player >= 80:
			state = walk_state
		elif distant_from_player <= 25:
			state = attack_state_2
			
	if animation_player.current_animation_position > 0.30 and spear_swing_sound_flag == true:
		if direction.x <= 0:
			var attack_effect_position = global_position + Vector2(-65, -10)
			var attack_effect_scale = Vector2(-0.2, 0.2)
			var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0, attack_effect_scale)
		else:
			var attack_effect_position = global_position + Vector2(65, -10)
			var attack_effect_scale = Vector2(0.2, 0.2)
			var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0, attack_effect_scale)
		
		Sound.play(Sound.spear_swing, 1.0, -20)
		spear_swing_sound_flag = false
	
	if animation_player.current_animation_position > 0.50 and spear_hit_ground_sound_flag == true:
		Events.add_screenshake.emit(1, 0.01)
		Sound.play(Sound.spear_ground_attack, 1.0, -20)
		spear_hit_ground_sound_flag = false
	

func attack_state_2(delta):
	var player = MainInstances.player
	var direction = global_position.direction_to(player.global_position)
	
	if attack_rate_timer.time_left == 0:
		attack_rate_timer.start()
		
		if direction.x >= 0:
			animation_player.play("attack_2_right")
		else:
			animation_player.play("attack_2")
			
		spear_swing_sound_flag = true
		spear_hit_ground_sound_flag = true
		
		var distant_from_player = player.global_position.x - global_position.x
		if distant_from_player >= 80:
			state = walk_state
			
		elif distant_from_player < 80 and distant_from_player >= 25:
			state = attack_state_2
			
'''
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#if is_on_wall(): 
	#	turn_around()
	
	#if is_at_ledge() and turns_at_ledges:
	#	turn_around()
	
	if step % 100 == 0:
		if direction == 1:
			animation_player.play("attack_1")
		else:
			animation_player.play("attack_1_right")
		
		latest_anim = "attack_1"
		spear_swing_sound_flag = true
		spear_hit_ground_sound_flag = true
	elif step % 201 == 0:
		if direction == 1:
			animation_player.play("attack_2")
		else:
			animation_player.play("attack_2_right")
	
	if direction == 1:
		#animation_player.play("walk")
		#velocity.x = -direction * speed
		#move_and_slide()
		pass
	else:
		#animation_player.play("walk_right")
		#velocity.x = -direction * speed
		#move_and_slide()
		pass
		
	if direction == 1:
		#animation_player.play("idle")
		pass
	else:
		#animation_player.play("idle_right")
		pass
	
	if latest_anim == "attack_1":
		if animation_player.current_animation_position > 0.30 and spear_swing_sound_flag == true:
			if direction == 1:
				var attack_effect_position = global_position + Vector2(-65, -10)
				var attack_effect_scale = Vector2(-0.2, 0.2)
				var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0, attack_effect_scale)
			else:
				var attack_effect_position = global_position + Vector2(65, -10)
				var attack_effect_scale = Vector2(0.2, 0.2)
				var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0, attack_effect_scale)
			
			Sound.play(Sound.spear_swing, 1.0, -20)
			spear_swing_sound_flag = false
		
		if animation_player.current_animation_position > 0.50 and spear_hit_ground_sound_flag == true:
			Events.add_screenshake.emit(1, 0.01)
			Sound.play(Sound.spear_ground_attack, 1.0, -20)
			spear_hit_ground_sound_flag = false
		
	step += 1
	
	#print("animation_player.current_animation: ", animation_player.current_animation)
'''


func abort_animation():
	animation_player.stop()


func set_hp(new_value: int) -> void:
	hp = clamp(new_value, 0, max_hp)
	emit_signal("hp_changed", hp)


func is_at_ledge():
	return is_on_floor() and not floor_cast.is_colliding()


func turn_around():
	direction *= -1.0


func _on_hurtbox_hurt(hitbox, damage):
	stats.health -= damage
	
	var tween := get_tree().create_tween()
	new_tween = tween
	var new_hp = float(stats.health) / float(max_hp) * 100.0
	progress_bar.value = new_hp
	new_tween.tween_property(progress_bar, "value", new_hp, 0.1)
	new_tween.play()
	

func _on_stats_no_health():
	Utils.instantiate_scene_on_level(EnemyDeathEffectScene, death_effect_location.global_position, 0, Vector2(1.0, 1.0))
	var id = WorldStash.get_id(self, starting_position)
	WorldStash.stash(id, "died", true)
	queue_free()
