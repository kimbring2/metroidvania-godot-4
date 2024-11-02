class_name Player
extends CharacterBody2D

const DustEffectScene = preload("res://effects/dust_effect.tscn")
const JumpEffectScene = preload("res://effects/jump_effect.tscn")
const WallJumpEffectScene = preload("res://effects/wall_jump_effect.tscn")
const AttackEffectScene = preload("res://effects/attack_effect.tscn")
const ShieldScene = preload("res://effects/energy_shield.tscn")

const BulletScene = preload("res://player/bullet.tscn")

enum WeaponMode {SWORD, BLASTER}

@export var acceleration = 512
@export var max_velocity = 64
@export var friction = 256
@export var air_friction = 64
@export var gravity = 200
@export var jump_force = 128
@export var max_fall_velocity = 128
@export var wall_slide_speed = 42
@export var max_wall_slide_speed = 128
@export var current_weapon_mode: Array[WeaponMode]
var air_jump = false
var state = move_state
var sword_action_index = 0
var doing_defense = false

@onready var sword_animation_player = $SwordAnimationPlayer
@onready var blaster_animation_player = $BlasterAnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var player_sword = $PlayerSword
@onready var player_blaster = $PlayerBlaster
@onready var player_shield = $PlayerShield
@onready var fire_rate_timer = $FireRateTimer
@onready var drop_timer = $DropTimer
@onready var camera_2d = $Camera2D
@onready var hurtbox : = $Hurtbox
@onready var blinking_animation_player = $BlinkingAnimationPlayer
@onready var center = $Center


func _ready():
	PlayerStats.no_health.connect(die)
	if current_weapon_mode[0] == WeaponMode.SWORD:
		player_sword.visible = true
		player_shield.visible = true
		player_blaster.visible = false
		player_shield.collision_shape_2d.disabled = true
	else:
		player_sword.visible = false
		player_shield.visible = false
		player_blaster.visible = true
	

func _enter_tree():
	MainInstances.player = self


func _physics_process(delta):
	state.call(delta)
	
	if Input.is_action_pressed("fire") and fire_rate_timer.time_left == 0 and doing_defense == false:
		fire_rate_timer.start()
		if current_weapon_mode[0] == WeaponMode.SWORD:
			Sound.play(Sound.sword_attack, 1.0, -20)
			
			if sword_action_index == 0:
				sword_animation_player.play("attack_1")
				sword_action_index = 1
				if get_global_mouse_position().x < position.x:
					var attack_effect_position = global_position + Vector2(0, -10)
					var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0, Vector2(-0.1, 0.1))
				else:
					var attack_effect_position = global_position + Vector2(0, -10)
					var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0, Vector2(0.1, 0.1))
			elif sword_action_index == 1:
				sword_animation_player.play("attack_2")
				sword_action_index = 0
				if get_global_mouse_position().x < position.x:
					var attack_effect_position = global_position + Vector2(0, -10)
					var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0.2, Vector2(-0.2, 0.01))
				else:
					var attack_effect_position = global_position + Vector2(0, -10)
					var attack_effect = Utils.instantiate_scene_on_level(AttackEffectScene, attack_effect_position, 0.2, Vector2(0.2, 0.01))
		else:
			fire_rate_timer.start()
			player_blaster.fire_bullet()
	
	if current_weapon_mode[0] == WeaponMode.SWORD:
		if Input.is_action_pressed("defense"):
			if is_on_floor():
				hurtbox.is_invincible = true
				player_shield.collision_shape_2d.disabled = false
				sword_animation_player.play("defense")
				doing_defense = true
		elif doing_defense == true:
			player_shield.collision_shape_2d.disabled = true
			hurtbox.is_invincible = false
			doing_defense = false
			
	if Input.is_action_pressed("fire_missile"):
		if current_weapon_mode[0] == WeaponMode.SWORD:
			if fire_rate_timer.time_left == 0 and PlayerStats.shields > 0 and doing_defense == false:
				var energy_shield_flag = false
				for child_node in get_children():
					if child_node.name == "EnergyShield":
						energy_shield_flag = true
						
				if energy_shield_flag == false:
					fire_rate_timer.start()
					var shield_effect_position = position + Vector2(0, 0)
					var instance = ShieldScene.instantiate()
					add_child.call_deferred(instance)
					instance.position = Vector2(0, -7)
					PlayerStats.shields -= 1
					hurtbox.is_invincible = true
		else:
			if fire_rate_timer.time_left == 0 and PlayerStats.missiles > 0:
				fire_rate_timer.start()
				player_blaster.fire_missile()
				PlayerStats.missiles -= 1
	
	
func _exit_tree():
	MainInstances.player = null


func move_state(delta):
	apply_gravity(delta)
	
	var input_axis = Input.get_axis("move_left", "move_right")
	
	if is_moving(input_axis):
		apply_acceleration(delta, input_axis)
	else:
		apply_friction(delta)
		
	jump_check()
	
	if Input.is_action_just_pressed("crouch"):
		set_collision_mask_value(2, false)
		drop_timer.start()
	
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	
	#print("sword_animation_player.current_animation: ", sword_animation_player.current_animation)
	if doing_defense != true:
		move_and_slide()
	
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()
	
	wall_check()


func wall_slide_state(delta):
	var wall_normal = get_wall_normal()
	blaster_animation_player.play("wall_slide")
	sprite_2d.scale.x = sign(wall_normal.x)
	velocity.y = clampf(velocity.y, -max_wall_slide_speed/2, max_wall_slide_speed)
	wall_jump_check(wall_normal.x)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detatch(delta, wall_normal.x)


func wall_check():
	if not is_on_floor() and is_on_wall():
		if current_weapon_mode[0] == WeaponMode.BLASTER: 
			state = wall_slide_state
			air_jump = true
			create_dust_effect()


func wall_detatch(delta, wall_axis):
	if Input.is_action_just_pressed("move_right") and wall_axis == 1:
		velocity.x = acceleration * delta
		state = move_state
		
	if Input.is_action_just_pressed("move_left") and wall_axis == -1:
		velocity.x = -acceleration * delta
		state = move_state
		
	if not is_on_wall() or is_on_floor():
		state = move_state


func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed("jump"):
		Sound.play(Sound.jump, randf_range(0.8, 1.1), 5.0)
		velocity.x = wall_axis * max_velocity
		state = move_state
		jump(jump_force * 0.75, false)
		var wall_jump_effect_position = global_position + Vector2(wall_axis * 3.5, -2)
		var wall_jump_effect = Utils.instantiate_scene_on_level(WallJumpEffectScene, wall_jump_effect_position, 0, Vector2(1, 1))
		wall_jump_effect.scale.x = wall_axis


func apply_wall_slide_gravity(delta):
	var slide_speed = wall_slide_speed
	if Input.is_action_pressed("crouch"):
		slide_speed = max_wall_slide_speed
		
	velocity.y = move_toward(velocity.y, slide_speed, gravity * delta)


func create_dust_effect():
	Sound.play(Sound.step, randf_range(0.8, 1.1), -5.0)
	Utils.instantiate_scene_on_level(DustEffectScene, global_position, 0, Vector2(1, 1))


func is_moving(input_axis):
	return input_axis != 0


func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)


func apply_acceleration(delta, input_axis):
	if is_moving(input_axis):
		velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)


func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)


func jump_check():
	if is_on_floor():
		air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			if current_weapon_mode[0] == WeaponMode.SWORD:
				sword_animation_player.play("jump")
				
			jump(jump_force)
			
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < -jump_force / 2:
			velocity.y = -jump_force / 2
		
		if Input.is_action_just_pressed("jump") and air_jump:
			if current_weapon_mode[0] == WeaponMode.SWORD:
				sword_animation_player.play("double_jump")
				
			jump(jump_force * 0.75)
			air_jump = false


func jump(force, create_effect = true):
	Sound.play(Sound.jump, randf_range(0.8, 1.1), 5.0)
	velocity.y = -force
	if create_effect:
		Utils.instantiate_scene_on_level(JumpEffectScene, global_position, 0, Vector2(1, 1))


func update_animations(input_axis):
	var current_anim = sword_animation_player.current_animation
	
	scale.x = sign(get_local_mouse_position().x)
	if abs(scale.x) != 1: scale.x = 1
	
	if current_weapon_mode[0] == WeaponMode.SWORD:
		if is_on_floor():
			if current_anim != "attack_1" and current_anim != "attack_2" and current_anim != "defense":
				if is_moving(input_axis):
					sword_animation_player.play("run")
				else:
					sword_animation_player.play("idle")
			elif current_anim == "defense":
				sword_animation_player.play("defense")
		else:		
			if current_anim != "double_jump" and current_anim != "attack_1" and current_anim != "attack_2":
				sword_animation_player.play("jump")
	else:
		if is_moving(input_axis):
			blaster_animation_player.play("run")
			blaster_animation_player.speed_scale = input_axis * sprite_2d.scale.x
		else:
			blaster_animation_player.play("idle")
		
		if not is_on_floor():
			blaster_animation_player.play("jump")
			
			
func die():
	camera_2d.reparent(get_tree().current_scene)
	queue_free()
	Events.player_died.emit()


func _on_drop_timer_timeout():
	set_collision_mask_value(2, true)


func _on_hurtbox_hurt(hitbox, damage):
	Sound.play(Sound.hurt)
	PlayerStats.health -= 1
	hurtbox.is_invincible = true
	blinking_animation_player.play("blink")
	await blinking_animation_player.animation_finished
	hurtbox.is_invincible = false
