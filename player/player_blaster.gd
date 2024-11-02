extends Node2D

const BulletScene = preload("res://player/bullet.tscn")
const MissileScene = preload("res://player/missile.tscn")

@onready var blaster_sprite = $BlasterSprite
@onready var muzzle = $BlasterSprite/Muzzle


func _process(_delta):
	blaster_sprite.rotation = get_local_mouse_position().angle()


func fire_bullet():
	var bullet = Utils.instantiate_scene_on_level(BulletScene, muzzle.global_position, 0, Vector2(1, 1))
	bullet.rotation = blaster_sprite.rotation
	bullet.update_velocity()


func fire_missile():
	var missile = Utils.instantiate_scene_on_level(MissileScene, muzzle.global_position, 0, Vector2(1, 1))
	missile.rotation = blaster_sprite.rotation
	missile.update_velocity()
