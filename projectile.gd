class_name Projectile
extends Node2D

const ExplosionEffectScene = preload("res://effects/explosion_effect.tscn")

@export var speed = 250

var velocity = Vector2.ZERO
var screen_entered = false

func update_velocity():
	velocity.x = speed
	velocity = velocity.rotated(rotation)

func _ready():
	Sound.play(Sound.bullet, randf_range(0.6, 1.2))

func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_hitbox_body_entered(body):
	Utils.instantiate_scene_on_level(ExplosionEffectScene, global_position, 0, Vector2(1, 1))
	queue_free()

func _on_hitbox_area_entered(area):
	Utils.instantiate_scene_on_level(ExplosionEffectScene, global_position, 0, Vector2(1, 1))
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	screen_entered = true

func _on_timer_timeout() -> void:
	if screen_entered: return
	queue_free()
