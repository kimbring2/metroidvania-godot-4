class_name PlayeryShield
extends Area2D

const DefenseEffectScene = preload("res://effects/defense_effect.tscn")
@onready var collision_shape_2d = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func take_hit(hitbox, damage) -> void:
	var hit_weapon = hitbox.get_parent()
	var hit_source = hit_weapon.get_owner()
	
	if get_parent().current_weapon_mode[0] == get_parent().WeaponMode.SWORD:
		if get_parent().sword_animation_player.current_animation == 'defense':
			Sound.play(Sound.shield_defense, 1.0, -20)
			if hit_source.name == "BossEnemyScorpion":
				var hit_source_direction = hit_source.check_left_right_direction()
				
				hit_source.abort_animation()
				var defense_effect_position = hit_weapon.global_position + Vector2(hit_source_direction * 50, 15)
				var defense_effect_effect = Utils.instantiate_scene_on_level(DefenseEffectScene, defense_effect_position, 10, Vector2(0.8, 0.8))
