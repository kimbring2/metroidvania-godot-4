class_name Hurtbox
extends Area2D

var is_invincible = false :
	set(value):
		is_invincible = value
		disable.call_deferred(value)


signal hurt(hitbox, damage)


func take_hit(hitbox, damage):
	#print("Hurtbox take_hit()")
	
	if is_invincible: 
		return
		
	hurt.emit(hitbox, damage)


func disable(value):
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = value


func _on_hurt(hitbox: Variant, damage: Variant) -> void:
	pass # Replace with function body.
